import 'package:flutter/material.dart';
import '../services/alert_service.dart';

class SafeLocationsScreen extends StatelessWidget {
  final List<Map<String, String>> shelters = [
    {
      'name': 'Govt School - Shelter Camp',
      'address': 'Govt School, Shimla',
    },
    {
      'name': 'District Hospital',
      'address': 'District Hospital, Shimla',
    },
    {
      'name': 'Community Hall',
      'address': 'Community Hall, Local Area',
    },
    {
      'name': 'Sports Complex Safe Zone',
      'address': 'Sports Complex, Main Rd',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Safe Locations'),
      ),
      body: ListView.separated(
        padding: EdgeInsets.all(16),
        itemCount: shelters.length,
        separatorBuilder: (_, __) => SizedBox(height: 10),
        itemBuilder: (context, index) {
          final s = shelters[index];
          return Card(
            child: ListTile(
              leading: Icon(Icons.place, color: Colors.green),
              title: Text(s['name']!),
              subtitle: Text(s['address']!),
              trailing: Icon(Icons.map),
              onTap: () {
                // open the address in maps
                AlertService.openInMaps('${s['name']}, ${s['address']}');
              },
            ),
          );
        },
      ),
    );
  }
}
