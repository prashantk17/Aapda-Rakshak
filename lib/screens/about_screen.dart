import 'package:flutter/material.dart';
import '../services/alert_service.dart';

class AboutScreen extends StatelessWidget {
  static void openExternal(BuildContext context, String url) {
    // small helper to open url and show progress/feedback
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Opening link...')));
    AlertService.openUrl(url).catchError((_) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not open link')));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About / Inspiration'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Aapda Rakshak', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Text(
              'Inspired by the Indian Red Cross Society. This app is a student-built, tech-first approach to disaster preparedness, emergency alerts, volunteer coordination and safe locations.',
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => openExternal(context, 'https://www.indianredcross.org/'),
              icon: Icon(Icons.public),
              label: Text('Visit Indian Red Cross'),
            ),
            SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => openExternal(context, 'https://github.com/prashantk17/Aapda-Rakshak'),
              icon: Icon(Icons.code),
              label: Text('View upstream repo'),
            ),
          ],
        ),
      ),
    );
  }
}
