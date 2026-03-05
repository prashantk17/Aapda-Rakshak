// lib/screens/live_map_screen.dart
import 'dart:async';
import 'dart:math' show cos, sin, sqrt, asin, pi;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

enum RiskLevel { low, moderate, high }

class RiskZone {
  final String id;
  final String name;
  final double lat;
  final double lng;
  final RiskLevel risk;
  final double radius;
  final String description;

  RiskZone({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.risk,
    this.radius = 300,
    this.description = '',
  });

  factory RiskZone.fromFirestore(String id, Map<String, dynamic> d) {
    final r = (d['risk'] ?? 'low') as String;
    return RiskZone(
      id: id,
      name: (d['name'] ?? '') as String,
      lat: (d['lat'] ?? 0.0).toDouble(),
      lng: (d['lng'] ?? 0.0).toDouble(),
      risk: _riskFromString(r),
      radius: (d['radius'] ?? 300).toDouble(),
      description: (d['description'] ?? '') as String,
    );
  }

  static RiskLevel _riskFromString(String s) {
    switch (s.toLowerCase()) {
      case 'high':
        return RiskLevel.high;
      case 'moderate':
        return RiskLevel.moderate;
      default:
        return RiskLevel.low;
    }
  }
}

class LiveMapScreen extends StatefulWidget {
  const LiveMapScreen({super.key});

  @override
  State<LiveMapScreen> createState() => _LiveMapScreenState();
}

class _LiveMapScreenState extends State<LiveMapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  static final CameraPosition _initialCamera = CameraPosition(
    target: LatLng(31.1048, 77.1734), // fallback center
    zoom: 10.5,
  );

  // realtime Firestore subscription
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _zonesSub;
  List<RiskZone> _zones = [];

  // overlays
  final Map<CircleId, Circle> _circles = {};
  final Map<MarkerId, Marker> _markers = {};

  // filters
  bool _showLow = true;
  bool _showModerate = true;
  bool _showHigh = true;

  // palette toggle (false = default, true = color-blind safe)
  bool _colorBlindPalette = false;

  // user location
  LatLng? _userLocation;
  Marker? _userMarker;

  // nearest high-risk
  List<RiskZone> _nearestHigh = [];

  @override
  void initState() {
    super.initState();
    _subscribeZones();
    _determinePosition(); // get user location once (and request permissions)
  }

  @override
  void dispose() {
    _zonesSub?.cancel();
    super.dispose();
  }

  void _subscribeZones() {
    _zonesSub = FirebaseFirestore.instance
        .collection('risk_zones')
        .snapshots()
        .listen((qs) {
      final loaded = qs.docs
          .map((d) => RiskZone.fromFirestore(d.id, d.data()))
          .toList();
      _zones = loaded;
      _updateMapOverlays();
      _computeNearestHigh();
    }, onError: (e) {
      debugPrint('Error loading zones: $e');
    });
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever
      return;
    }

    final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    _userLocation = LatLng(pos.latitude, pos.longitude);
    _userMarker = Marker(
      markerId: MarkerId('user_marker'),
      position: _userLocation!,
      infoWindow: InfoWindow(title: 'You are here'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
    );
    setState(() {});
    _computeNearestHigh();
  }

  void _updateMapOverlays() {
    _circles.clear();
    _markers.clear();

    // user marker (if found)
    if (_userMarker != null) {
      _markers[_userMarker!.markerId] = _userMarker!;
    }

    for (final z in _zones) {
      if ((z.risk == RiskLevel.low && !_showLow) ||
          (z.risk == RiskLevel.moderate && !_showModerate) ||
          (z.risk == RiskLevel.high && !_showHigh)) {
        continue;
      }

      final cid = CircleId(z.id);
      _circles[cid] = Circle(
        circleId: cid,
        center: LatLng(z.lat, z.lng),
        radius: z.radius,
        strokeWidth: 2,
        strokeColor: _colorForRisk(z.risk).withValues(alpha: 0.95),
        fillColor: _colorForRisk(z.risk).withValues(alpha: 0.18),
        onTap: () => _onZoneTap(z),
      );

      final mid = MarkerId('m_${z.id}');
      _markers[mid] = Marker(
        markerId: mid,
        position: LatLng(z.lat, z.lng),
        infoWindow: InfoWindow(title: z.name, snippet: _labelForRisk(z.risk)),
        onTap: () => _onZoneTap(z),
        icon: BitmapDescriptor.defaultMarkerWithHue(_hueForRisk(z.risk)),
      );
    }

    setState(() {});
  }

  void _computeNearestHigh() {
    if (_userLocation == null) return;
    final userLat = _userLocation!.latitude;
    final userLng = _userLocation!.longitude;

    // compute distances to high-risk zones
    final highs = _zones.where((z) => z.risk == RiskLevel.high).toList();
    highs.sort((a, b) {
      final da = _haversine(userLat, userLng, a.lat, a.lng);
      final db = _haversine(userLat, userLng, b.lat, b.lng);
      return da.compareTo(db);
    });

    // pick top 3 nearest high-risk zones
    _nearestHigh = highs.take(3).toList();

    // optionally highlight nearest high by increasing stroke width
    for (final z in _zones) {
      final cid = CircleId(z.id);
      final base = _circles[cid];
      if (base != null) {
        final isNearest = _nearestHigh.any((nh) => nh.id == z.id);
        final updated = base.copyWith(strokeWidthParam: isNearest ? 4 : 2);
        _circles[cid] = updated;
      }
    }

    setState(() {});
  }

  // Haversine distance in meters
  double _haversine(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371000; // metres
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) * cos(_deg2rad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * asin(sqrt(a));
    return R * c;
  }

  double _deg2rad(double deg) => deg * (pi / 180.0);

  Color _colorForRisk(RiskLevel r) {
    if (_colorBlindPalette) {
      // color-blind friendly palette (distinct, accessible)
      switch (r) {
        case RiskLevel.high:
          return Color(0xFFD55E00); // orange (color-blind friendly as high)
        case RiskLevel.moderate:
          return Color(0xFF0072B2); // blue
        case RiskLevel.low:
          return Color(0xFF009E73); // green
      }
    } else {
      // default palette
      switch (r) {
        case RiskLevel.high:
          return Colors.red;
        case RiskLevel.moderate:
          return Colors.orange;
        case RiskLevel.low:
          return Colors.green;
      }
    }
  }

  double _hueForRisk(RiskLevel r) {
    if (_colorBlindPalette) {
      switch (r) {
        case RiskLevel.high:
          return 14.0; // approximate orange
        case RiskLevel.moderate:
          return BitmapDescriptor.hueBlue;
        case RiskLevel.low:
          return BitmapDescriptor.hueGreen;
      }
    } else {
      switch (r) {
        case RiskLevel.high:
          return BitmapDescriptor.hueRed;
        case RiskLevel.moderate:
          return BitmapDescriptor.hueOrange;
        case RiskLevel.low:
          return BitmapDescriptor.hueGreen;
      }
    }
  }

  double _haversineDistanceToZone(RiskZone z) {
    if (_userLocation == null) return double.infinity;
    return _haversine(_userLocation!.latitude, _userLocation!.longitude, z.lat, z.lng);
  }

  void _onZoneTap(RiskZone z) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        final distMeters = _haversineDistanceToZone(z);
        final distText = distMeters.isFinite ? '${(distMeters / 1000).toStringAsFixed(2)} km' : 'Unknown';
        return Padding(
          padding: EdgeInsets.all(16),
          child: Wrap(
            children: [
              Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: _colorForRisk(z.risk)),
                  SizedBox(width: 12),
                  Expanded(child: Text(z.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700))),
                ],
              ),
              SizedBox(height: 8),
              Text(_labelForRisk(z.risk), style: TextStyle(fontWeight: FontWeight.w600)),
              SizedBox(height: 12),
              Text(z.description),
              SizedBox(height: 12),
              Text('Radius: ${z.radius.toStringAsFixed(0)} m'),
              SizedBox(height: 8),
              Text('Distance: $distText'),
              SizedBox(height: 14),
              ElevatedButton.icon(
                onPressed: () async {
                  final c = await _controller.future;
                  await c.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
                    target: LatLng(z.lat, z.lng),
                    zoom: 15,
                  )));
                  Navigator.of(ctx).pop();
                },
                icon: Icon(Icons.map),
                label: Text('Focus here'),
              ),
            ],
          ),
        );
      },
    );
  }

  String _labelForRisk(RiskLevel r) {
    switch (r) {
      case RiskLevel.high:
        return 'High risk';
      case RiskLevel.moderate:
        return 'Moderate risk';
      case RiskLevel.low:
        return 'Low risk';
    }
  }

  Widget _legendItem(Color color, String text) {
    return Row(
      children: [
        Container(width: 14, height: 14, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        SizedBox(width: 6),
        Text(text, style: TextStyle(fontSize: 12)),
      ],
    );
  }

  void _openFilterDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        bool tmpLow = _showLow;
        bool tmpModerate = _showModerate;
        bool tmpHigh = _showHigh;
        return StatefulBuilder(builder: (c, setSt) {
          return AlertDialog(
            title: Text('Show risk levels'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CheckboxListTile(
                  title: Text('Low'),
                  value: tmpLow,
                  onChanged: (v) => setSt(() => tmpLow = v ?? true),
                ),
                CheckboxListTile(
                  title: Text('Moderate'),
                  value: tmpModerate,
                  onChanged: (v) => setSt(() => tmpModerate = v ?? true),
                ),
                CheckboxListTile(
                  title: Text('High'),
                  value: tmpHigh,
                  onChanged: (v) => setSt(() => tmpHigh = v ?? true),
                ),
                Divider(),
                SwitchListTile(
                  title: Text('Color-blind friendly palette'),
                  value: _colorBlindPalette,
                  onChanged: (v) => setState(() => _colorBlindPalette = v),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  setState(() {
                    _showLow = tmpLow;
                    _showModerate = tmpModerate;
                    _showHigh = tmpHigh;
                    _updateMapOverlays();
                    _computeNearestHigh();
                  });
                },
                child: Text('Apply'),
              )
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final paletteLegend = Row(
      children: [
        _legendItem(_colorForRisk(RiskLevel.high), 'High'),
        SizedBox(width: 8),
        _legendItem(_colorForRisk(RiskLevel.moderate), 'Moderate'),
        SizedBox(width: 8),
        _legendItem(_colorForRisk(RiskLevel.low), 'Low'),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Risk Map'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => _subscribeZones(), // re-subscribe / reload
            tooltip: 'Reload zones',
          ),
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _openFilterDialog,
            tooltip: 'Filter layers',
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _initialCamera,
            onMapCreated: (controller) {
              if (!_controller.isCompleted) _controller.complete(controller);
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            markers: Set<Marker>.of(_markers.values),
            circles: Set<Circle>.of(_circles.values),
            zoomControlsEnabled: false,
          ),

          // Legend
          Positioned(
            top: 12,
            left: 12,
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: paletteLegend,
              ),
            ),
          ),

          // Nearest high risk hint (bottom-left)
          if (_nearestHigh.isNotEmpty)
            Positioned(
              left: 12,
              bottom: 20,
              child: Card(
                color: Colors.white.withValues(alpha: 0.95),
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Nearby high-risk zones', style: TextStyle(fontWeight: FontWeight.w700)),
                      SizedBox(height: 8),
                      ..._nearestHigh.toList().map((z) {
                        final dist = _haversineDistanceToZone(z);
                        final distKm = (dist / 1000).toStringAsFixed(2);
                        return ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.place, color: _colorForRisk(z.risk)),
                          title: Text(z.name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          subtitle: Text('$distKm km • radius ${z.radius.toInt()} m'),
                          onTap: () async {
                            final c = await _controller.future;
                            await c.animateCamera(CameraUpdate.newCameraPosition(
                                CameraPosition(target: LatLng(z.lat, z.lng), zoom: 15)));
                          },
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
