// lib/screens/live_map_screen.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

enum RiskLevel { low, moderate, high }

class RiskZone {
  final String id;
  final String name;
  final double lat;
  final double lng;
  final RiskLevel risk;

  RiskZone({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.risk,
  });

  factory RiskZone.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final riskString = (data['risk'] ?? 'low').toString().toLowerCase();
    final risk = riskString == 'high'
        ? RiskLevel.high
        : (riskString == 'moderate' ? RiskLevel.moderate : RiskLevel.low);

    return RiskZone(
      id: doc.id,
      name: data['name'] ?? 'Unknown',
      lat: (data['lat'] is num)
          ? (data['lat'] as num).toDouble()
          : double.parse(data['lat'].toString()),
      lng: (data['lng'] is num)
          ? (data['lng'] as num).toDouble()
          : double.parse(data['lng'].toString()),
      risk: risk,
    );
  }
}

class LiveMapScreen extends StatefulWidget {
  final LatLng? initialFocus;
  final String? initialLabel;
  const LiveMapScreen({super.key, this.initialFocus, this.initialLabel});

  @override
  State<LiveMapScreen> createState() => _LiveMapScreenState();
}

class _LiveMapScreenState extends State<LiveMapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> _markers = {};
  List<RiskZone> _zones = [];
  bool _loading = true;
  static const CameraPosition _initialCamera = CameraPosition(
    target: LatLng(20.5937, 78.9629), // India center fallback
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
        _zones = snap.docs.map((d) => RiskZone.fromFirestore(d)).toList();
      } else {
        // Fallback sample data
        _zones = _sampleZones();
      }
    } catch (e) {
      // If Firestore fails (e.g., offline), fallback to sample data
      _zones = _sampleZones();
    }

    _buildMarkers();
    setState(() {
      _loading = false;
    });
  }

  List<RiskZone> _sampleZones() {
    return [
      RiskZone(
        id: 's1',
        name: 'Riverbank - High',
        lat: 28.7041,
        lng: 77.1025,
        risk: RiskLevel.high,
      ),
      RiskZone(
        id: 's2',
        name: 'Lowland Area - Moderate',
        lat: 28.5355,
        lng: 77.3910,
        risk: RiskLevel.moderate,
      ),
      RiskZone(
        id: 's3',
        name: 'Upland - Low',
        lat: 28.4595,
        lng: 77.0266,
        risk: RiskLevel.low,
      ),
    ];
  }

  void _buildMarkers() {
    _markers.clear();
    for (final z in _zones) {
      final hue = _hueForRisk(z.risk);
      final marker = Marker(
        markerId: MarkerId(z.id),
        position: LatLng(z.lat, z.lng),
        infoWindow: InfoWindow(title: z.name, snippet: _labelForRisk(z.risk)),
        icon: BitmapDescriptor.defaultMarkerWithHue(hue),
        onTap: () {
          // optional extra behaviour
        },
      );
      _markers.add(marker);
    }
  }

  double _hueForRisk(RiskLevel r) {
    switch (r) {
      case RiskLevel.high:
        return BitmapDescriptor.hueRed; // red
      case RiskLevel.moderate:
        return BitmapDescriptor.hueYellow; // yellow
      case RiskLevel.low:
      default:
        return BitmapDescriptor.hueBlue; // blue
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

  Future<void> _animateTo(LatLng target, {double zoom = 14}) async {
    final controller = await _controller.future;
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: target, zoom: zoom),
      ),
    );
  }

  Widget _legend() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _legendItem(Colors.red, 'High'),
            const SizedBox(width: 8),
            _legendItem(Colors.yellow[800]!, 'Moderate'),
            const SizedBox(width: 8),
            _legendItem(Colors.blue, 'Low'),
          ],
        ),
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Risk Zones Map')),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _initialCamera,
            markers: _markers,
            myLocationEnabled: false,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false,
            onMapCreated: (GoogleMapController ctrl) {
              if (!_controller.isCompleted) _controller.complete(ctrl);
            },
            onTap: (_) {
              // hide open details if you implement them
            },
          ),
          Positioned(top: 12, left: 12, child: _legend()),
          // Right-side list of zones to jump to
          Positioned(
            right: 8,
            top: 80,
            bottom: 16,
            child: SizedBox(
              width: 260,
              child: Card(
                margin: EdgeInsets.zero,
                child: _loading
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Zones (${_zones.length})',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          const Divider(height: 1),
                          Expanded(
                            child: ListView.builder(
                              itemCount: _zones.length,
                              itemBuilder: (context, i) {
                                final z = _zones[i];
                                final color = (z.risk == RiskLevel.high)
                                    ? Colors.red
                                    : (z.risk == RiskLevel.moderate
                                          ? Colors.yellow[800]
                                          : Colors.blue);
                                return ListTile(
                                  leading: CircleAvatar(backgroundColor: color),
                                  title: Text(z.name),
                                  subtitle: Text(_labelForRisk(z.risk)),
                                  onTap: () async {
                                    await _animateTo(
                                      LatLng(z.lat, z.lng),
                                      zoom: 15,
                                    );
                                  },
                                );
                              },
                            ),
                          ),
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
