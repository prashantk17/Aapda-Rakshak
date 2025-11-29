// lib/screens/info_screen.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:aapda_rakshak/models/disaster_model.dart';
import 'package:aapda_rakshak/screens/live_map_screen.dart';

class InfoScreen extends StatelessWidget {
  final List<DisasterModel> disasters = [
    DisasterModel(
      title: 'Earthquake',
      description: 'Sudden shaking of ground due to tectonic movement.',
      advice:
          'Drop, Cover & Hold. Stay away from windows. Move to open area if outside.',
      lat: 28.7041,
      lng: 77.1025,
    ),
    DisasterModel(
      title: 'Flood',
      description: 'Overflow of water onto normally dry land.',
      advice:
          'Move to higher ground. Avoid walking/driving through floodwater.',
      lat: 26.8467,
      lng: 80.9462,
    ),
    DisasterModel(
      title: 'Landslide',
      description: 'Downward movement of rock/soil on slopes.',
      advice: 'Stay alert to unusual cracks/rumbling. Move away from slope.',
      lat: 32.2210,
      lng: 77.1893,
    ),
    DisasterModel(
      title: 'Fire',
      description: 'Uncontrolled flame and smoke.',
      advice:
          'Stop, Drop & Roll if clothes catch fire. Crawl under smoke to exit.',
      lat: 28.5355,
      lng: 77.3910,
    ),
    // You can add more with null lat/lng to test the guard behavior
    DisasterModel(
      title: 'Unknown Area Example',
      description: 'Example with no coordinates',
      advice: 'No coordinates available for this entry.',
      lat: null,
      lng: null,
    ),
  ];

  InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Disaster Information'),
        actions: [
          IconButton(
            tooltip: 'Open Live Disaster Map',
            icon: const Icon(Icons.map),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => LiveMapScreen()),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => LiveMapScreen()),
          );
        },
        label: const Text('Open Map'),
        icon: const Icon(Icons.map),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF5F5F5), Color(0xFFEEEEEE)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          itemCount: disasters.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final d = disasters[index];
            final colors = [
              const Color(0xFFD32F2F), // Red for Earthquake
              const Color(0xFF1976D2), // Blue for Flood
              const Color(0xFF388E3C), // Green for Landslide
              const Color(0xFFF57C00), // Orange for Fire
            ];
            final color = colors[index % colors.length];

            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withAlpha(25), color.withAlpha(13)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withAlpha(76)),
              ),
              child: Theme(
                data: Theme.of(
                  context,
                ).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  title: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(10),
                        child: Icon(
                          _getDisasterIcon(d.title),
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          d.title,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(left: 52, top: 8),
                    child: Text(
                      d.description,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Divider(),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.check_circle, color: color, size: 20),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'What to do:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            d.advice,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Map buttons
                          Row(
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => LiveMapScreen(),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.map),
                                label: const Text('Open Map'),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                ),
                                onPressed: () {
                                  // Guard: only navigate if both coordinates are present
                                  if (d.lat != null && d.lng != null) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => LiveMapScreen(
                                          initialFocus: LatLng(d.lat!, d.lng!),
                                          initialLabel: d.title,
                                        ),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Location not available for this disaster',
                                        ),
                                      ),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.place),
                                label: const Text('Show on Map'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  IconData _getDisasterIcon(String title) {
    switch (title.toLowerCase()) {
      case 'earthquake':
        return Icons.vibration;
      case 'flood':
        return Icons.water_drop;
      case 'landslide':
        return Icons.terrain;
      case 'fire':
        return Icons.local_fire_department;
      default:
        return Icons.warning;
    }
  }
}
