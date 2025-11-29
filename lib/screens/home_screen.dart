// lib/screens/home_screen.dart
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:aapda_rakshak/widgets/homecard.dart';
import 'package:aapda_rakshak/screens/alert_screen.dart';
import 'package:aapda_rakshak/screens/info_screen.dart';
import 'package:aapda_rakshak/screens/safe_locations_screen.dart';
import 'package:aapda_rakshak/screens/volunteer_screen.dart';
import 'package:aapda_rakshak/screens/about_screen.dart';
import 'package:aapda_rakshak/screens/live_map_screen.dart';

enum RiskLevel { low, moderate, high }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Map controller
  final Completer<GoogleMapController> _mapController = Completer();

  // Markers, circles, polygons and zones
  final Set<Marker> _markers = {};
  final Set<Circle> _circles = {};
  final Set<Polygon> _polygons = {};
  bool _mapLoading = true;
  List<_Zone> _zones = [];

  // UI state
  bool _showAreas = true;
  MapType _mapType = MapType.normal;

  // Initial camera: India center
  static const CameraPosition _initialCamera = CameraPosition(
    target: LatLng(20.5937, 78.9629),
    zoom: 4.5,
  );

  @override
  void initState() {
    super.initState();
    _loadZones();
  }

  Future<void> _loadZones() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('risk_zones')
          .get();
      if (snap.docs.isNotEmpty) {
        _zones = snap.docs.map((d) {
          final data = d.data();
          final riskString = (data['risk'] ?? 'low').toString().toLowerCase();
          final risk = riskString == 'high'
              ? RiskLevel.high
              : (riskString == 'moderate' ? RiskLevel.moderate : RiskLevel.low);

          final lat = data['lat'] != null
              ? (data['lat'] as num).toDouble()
              : null;
          final lng = data['lng'] != null
              ? (data['lng'] as num).toDouble()
              : null;

          // optional radius (meters)
          final radius = data['radius_m'] != null
              ? (data['radius_m'] as num).toDouble()
              : null;

          // optional polygon: a list of {lat: x, lng: y}
          List<LatLng>? polygon;
          if (data['polygon'] is Iterable) {
            try {
              polygon = (data['polygon'] as Iterable)
                  .map(
                    (p) => LatLng(
                      (p['lat'] as num).toDouble(),
                      (p['lng'] as num).toDouble(),
                    ),
                  )
                  .toList();
            } catch (_) {
              polygon = null;
            }
          }

          return _Zone(
            id: d.id,
            name: (data['name'] ?? 'Zone'),
            lat: lat ?? 0.0,
            lng: lng ?? 0.0,
            risk: risk,
            radiusMeters: radius,
            polygon: polygon,
          );
        }).toList();
      } else {
        _zones = _sampleZones();
      }
    } catch (_) {
      // fallback
      _zones = _sampleZones();
    }

    _buildMapShapes();
    setState(() => _mapLoading = false);
  }

  List<_Zone> _sampleZones() {
    return [
      _Zone(
        id: 's1',
        name: 'Riverbank - High',
        lat: 28.7041,
        lng: 77.1025,
        risk: RiskLevel.high,
        radiusMeters: 600,
      ),
      _Zone(
        id: 's2',
        name: 'Lowland - Moderate',
        lat: 28.5355,
        lng: 77.3910,
        risk: RiskLevel.moderate,
        radiusMeters: 400,
      ),
      _Zone(
        id: 's3',
        name: 'Upland - Low',
        lat: 28.4595,
        lng: 77.0266,
        risk: RiskLevel.low,
        radiusMeters: 250,
      ),
    ];
  }

  void _buildMapShapes() {
    _markers.clear();
    _circles.clear();
    _polygons.clear();

    for (final z in _zones) {
      // Marker
      final marker = Marker(
        markerId: MarkerId(z.id),
        position: LatLng(z.lat, z.lng),
        infoWindow: InfoWindow(title: z.name, snippet: _labelForRisk(z.risk)),
        icon: BitmapDescriptor.defaultMarkerWithHue(_hueForRisk(z.risk)),
        onTap: () {
          // center to marker when tapped
          _animateTo(LatLng(z.lat, z.lng), zoom: 14);
        },
      );
      _markers.add(marker);

      // Polygon (if provided)
      if (z.polygon != null && z.polygon!.length >= 3) {
        final poly = Polygon(
          polygonId: PolygonId('${z.id}_poly'),
          points: z.polygon!,
          fillColor: _colorForRisk(z.risk).withOpacity(0.12),
          strokeColor: _colorForRisk(z.risk).withOpacity(0.6),
          strokeWidth: 2,
        );
        _polygons.add(poly);
      } else {
        // Circle fallback (radiusMeters or default 300m)
        final radius = z.radiusMeters ?? 300.0;
        final circle = Circle(
          circleId: CircleId('${z.id}_circle'),
          center: LatLng(z.lat, z.lng),
          radius: radius,
          fillColor: _colorForRisk(z.risk).withOpacity(0.12),
          strokeColor: _colorForRisk(z.risk).withOpacity(0.7),
          strokeWidth: 2,
        );
        _circles.add(circle);
      }
    }
  }

  double _hueForRisk(RiskLevel r) {
    switch (r) {
      case RiskLevel.high:
        return BitmapDescriptor.hueRed;
      case RiskLevel.moderate:
        return BitmapDescriptor.hueYellow;
      case RiskLevel.low:
      default:
        return BitmapDescriptor.hueBlue;
    }
  }

  Color _colorForRisk(RiskLevel r) {
    switch (r) {
      case RiskLevel.high:
        return Colors.red;
      case RiskLevel.moderate:
        return Colors.yellow[800]!;
      case RiskLevel.low:
      default:
        return Colors.blue;
    }
  }

  String _labelForRisk(RiskLevel r) {
    switch (r) {
      case RiskLevel.high:
        return 'High risk';
      case RiskLevel.moderate:
        return 'Moderate risk';
      case RiskLevel.low:
      default:
        return 'Low risk';
    }
  }

  // Map actions
  Future<void> _openFullMap() async {
    Navigator.push(context, MaterialPageRoute(builder: (_) => LiveMapScreen()));
  }

  Future<void> _animateTo(LatLng target, {double zoom = 14}) async {
    try {
      final controller = await _mapController.future;
      await controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: target, zoom: zoom),
        ),
      );
    } catch (_) {}
  }

  Future<void> _fitAll() async {
    // compute LatLngBounds covering markers and circles
    final allPoints = <LatLng>[];
    for (final m in _markers) allPoints.add(m.position);
    for (final c in _circles) allPoints.add(c.center);
    for (final p in _polygons) allPoints.addAll(p.points);

    if (allPoints.isEmpty) return;

    double minLat = allPoints.first.latitude, maxLat = allPoints.first.latitude;
    double minLng = allPoints.first.longitude,
        maxLng = allPoints.first.longitude;
    for (final p in allPoints) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    final southWest = LatLng(minLat, minLng);
    final northEast = LatLng(maxLat, maxLng);
    final bounds = LatLngBounds(southwest: southWest, northeast: northEast);

    final controller = await _mapController.future;
    await controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 60));
  }

  void _toggleMapType() {
    setState(() {
      _mapType = (_mapType == MapType.normal)
          ? MapType.hybrid
          : (_mapType == MapType.hybrid ? MapType.satellite : MapType.normal);
    });
  }

  void _toggleAreas() {
    setState(() {
      _showAreas = !_showAreas;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mapHeight = MediaQuery.of(context).size.height * 0.45;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Aapda Rakshak',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22),
        ),
        elevation: 0,
      ),
      drawer: _buildDrawer(context),
      body: Column(
        children: [
          // Map area at top
          SizedBox(
            height: mapHeight,
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    child: GoogleMap(
                      initialCameraPosition: _initialCamera,
                      mapType: _mapType,
                      markers: _markers,
                      circles: _showAreas ? _circles : <Circle>{},
                      polygons: _showAreas ? _polygons : <Polygon>{},
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: true,
                      compassEnabled: true,
                      rotateGesturesEnabled: true,
                      tiltGesturesEnabled: true,
                      onMapCreated: (ctrl) {
                        if (!_mapController.isCompleted)
                          _mapController.complete(ctrl);
                      },
                      onTap: (_) {
                        // hide overlays if any
                      },
                    ),
                  ),
                ),

                // Loading overlay
                if (_mapLoading)
                  const Positioned.fill(
                    child: Center(child: CircularProgressIndicator()),
                  ),

                // Legend
                Positioned(
                  top: 12,
                  left: 12,
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _legendDot(Colors.red),
                          const SizedBox(width: 6),
                          const Text('High'),
                          const SizedBox(width: 10),
                          _legendDot(Colors.yellow),
                          const SizedBox(width: 6),
                          const Text('Moderate'),
                          const SizedBox(width: 10),
                          _legendDot(Colors.blue),
                          const SizedBox(width: 6),
                          const Text('Low'),
                        ],
                      ),
                    ),
                  ),
                ),

                // Map controls column (toggle areas, toggle map type, fit bounds)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Column(
                    children: [
                      FloatingActionButton.small(
                        heroTag: 'toggleAreas',
                        onPressed: _toggleAreas,
                        child: Icon(
                          _showAreas ? Icons.layers : Icons.layers_clear,
                        ),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton.small(
                        heroTag: 'mapType',
                        onPressed: _toggleMapType,
                        child: const Icon(Icons.map),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton.small(
                        heroTag: 'fit',
                        onPressed: _fitAll,
                        child: const Icon(Icons.center_focus_strong),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton.small(
                        heroTag: 'openFull',
                        onPressed: _openFullMap,
                        child: const Icon(Icons.open_in_full),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Remaining content: quick actions and info
          Expanded(
            child: Container(
              color: const Color(0xFFF5F5F5),
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                children: [
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),

                  HomeCard(
                    title: 'Emergency Alert',
                    subtitle: 'Send SOS message quickly',
                    icon: Icons.warning_amber_rounded,
                    color: const Color(0xFFD32F2F),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AlertScreen()),
                    ),
                  ),
                  const SizedBox(height: 12),

                  HomeCard(
                    title: 'Disaster Info',
                    subtitle: 'Guidelines and safety tips',
                    icon: Icons.info_outline,
                    color: const Color(0xFF1976D2),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => InfoScreen()),
                    ),
                  ),
                  const SizedBox(height: 12),

                  HomeCard(
                    title: 'Safe Locations',
                    subtitle: 'Shelters, hospitals & rescue',
                    icon: Icons.location_on,
                    color: const Color(0xFF388E3C),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => SafeLocationsScreen()),
                    ),
                  ),
                  const SizedBox(height: 12),

                  HomeCard(
                    title: 'Volunteer',
                    subtitle: 'Join as first responder',
                    icon: Icons.volunteer_activism,
                    color: const Color(0xFFF57C00),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => VolunteerScreen()),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // About card
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFE0B2), Color(0xFFFFCDD2)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFFF6F00).withOpacity(0.3),
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => AboutScreen()),
                        ),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: const [
                              Icon(
                                Icons.info,
                                color: Color(0xFFD32F2F),
                                size: 28,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'About This App',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Learn more about emergency preparedness',
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 14,
                                color: Color(0xFFD32F2F),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color c) => Container(
    width: 12,
    height: 12,
    decoration: BoxDecoration(color: c, shape: BoxShape.circle),
  );

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFD32F2F), Color(0xFFC62828)],
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(12),
                    child: const Icon(
                      Icons.security,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Aapda Rakshak',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Emergency Response',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Color(0xFFD32F2F)),
              title: const Text('Home'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(
                Icons.warning_amber,
                color: Color(0xFFD32F2F),
              ),
              title: const Text('Emergency Alert'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AlertScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.school, color: Color(0xFF1976D2)),
              title: const Text('Disaster Info'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => InfoScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_on, color: Color(0xFF388E3C)),
              title: const Text('Safe Locations'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SafeLocationsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.volunteer_activism,
                color: Color(0xFFF57C00),
              ),
              title: const Text('Volunteer'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => VolunteerScreen()),
                );
              },
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(),
            ),
            ListTile(
              leading: const Icon(Icons.info_outline, color: Color(0xFFD32F2F)),
              title: const Text('About'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AboutScreen()),
                );
              },
            ),
            const Spacer(),
            const Divider(),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Version 1.0.0',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Internal lightweight zone model for the HomeScreen
class _Zone {
  final String id;
  final String name;
  final double lat;
  final double lng;
  final RiskLevel risk;
  final double? radiusMeters;
  final List<LatLng>? polygon;

  _Zone({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.risk,
    this.radiusMeters,
    this.polygon,
  });
}
