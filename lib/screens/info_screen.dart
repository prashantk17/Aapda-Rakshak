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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Disaster Information'),
      ),
      body: ListView.separated(
        padding: EdgeInsets.all(16),
        itemCount: disasters.length,
        separatorBuilder: (_, __) => SizedBox(height: 12),
        itemBuilder: (context, index) {
          final d = disasters[index];
          return Card(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(d.title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text(d.description),
                  SizedBox(height: 8),
                  Text('What to do: ${d.advice}', style: TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
