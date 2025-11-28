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

  SafeLocationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Safe Locations'),
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
          itemCount: shelters.length,
          separatorBuilder: (_, __) => SizedBox(height: 12),
          itemBuilder: (context, index) {
            final s = shelters[index];
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF388E3C).withOpacity(0.1), Color(0xFF388E3C).withOpacity(0.05)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Color(0xFF388E3C).withOpacity(0.3)),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    AlertService.openInMaps('${s['name']}, ${s['address']}');
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF388E3C), Color(0xFF2E7D32)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF388E3C).withOpacity(0.3),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          padding: EdgeInsets.all(12),
                          child: Icon(Icons.location_on, color: Colors.white, size: 24),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s['name']!,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(Icons.place, size: 14, color: Colors.grey[600]),
                                  SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      s['address']!,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 13,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF388E3C)),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
