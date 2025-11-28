import 'package:flutter/material.dart';
import '../models/disaster_model.dart';

class InfoScreen extends StatelessWidget {
  final List<DisasterModel> disasters = [
    DisasterModel(
      title: 'Earthquake',
      description: 'Sudden shaking of ground due to tectonic movement.',
      advice: 'Drop, Cover & Hold. Stay away from windows. Move to open area if outside.',
    ),
    DisasterModel(
      title: 'Flood',
      description: 'Overflow of water onto normally dry land.',
      advice: 'Move to higher ground. Avoid walking/driving through floodwater.',
    ),
    DisasterModel(
      title: 'Landslide',
      description: 'Downward movement of rock/soil on slopes.',
      advice: 'Stay alert to unusual cracks/rumbling. Move away from slope.',
    ),
    DisasterModel(
      title: 'Fire',
      description: 'Uncontrolled flame and smoke.',
      advice: 'Stop, Drop & Roll if clothes catch fire. Crawl under smoke to exit.',
    ),
  ];

  InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Disaster Information'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF5F5F5), Color(0xFFEEEEEE)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          itemCount: disasters.length,
          separatorBuilder: (_, _) => SizedBox(height: 12),
          itemBuilder: (context, index) {
            final d = disasters[index];
            final colors = [
              Color(0xFFD32F2F), // Red for Earthquake
              Color(0xFF1976D2), // Blue for Flood
              Color(0xFF388E3C), // Green for Landslide
              Color(0xFFF57C00), // Orange for Fire
            ];
            final color = colors[index % colors.length];
            
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withValues(alpha: 0.1), color.withValues(alpha: 0.05)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                ),
                child: ExpansionTile(
                  title: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                        padding: EdgeInsets.all(10),
                        child: Icon(
                          _getDisasterIcon(d.title),
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          d.title,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: EdgeInsets.only(left: 52, top: 8),
                    child: Text(
                      d.description,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Divider(),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.check_circle, color: color, size: 20),
                              SizedBox(width: 12),
                              Expanded(
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
                          SizedBox(height: 8),
                          Text(
                            d.advice,
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 14,
                              height: 1.5,
                            ),
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
