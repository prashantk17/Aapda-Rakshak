import 'package:flutter/material.dart';
import '../widgets/homecard.dart';
import 'alert_screen.dart';
import 'info_screen.dart';
import 'safe_locations_screen.dart';
import 'volunteer_screen.dart';
import 'about_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Aapda Rakshak',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22),
        ),
        elevation: 0,
      ),
      drawer: _buildDrawer(context),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF5F5F5), Color(0xFFEEEEEE)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Header section with gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFD32F2F), Color(0xFFC62828)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome Back',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Stay prepared. Help others. Be safe.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Main content
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 16),
                  HomeCard(
                    title: 'Emergency Alert',
                    subtitle: 'Send SOS message quickly',
                    icon: Icons.warning_amber_rounded,
                    color: Color(0xFFD32F2F),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AlertScreen())),
                  ),
                  SizedBox(height: 12),
                  HomeCard(
                    title: 'Disaster Info',
                    subtitle: 'Guidelines and safety tips',
                    icon: Icons.info_outline,
                    color: Color(0xFF1976D2),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => InfoScreen())),
                  ),
                  SizedBox(height: 12),
                  HomeCard(
                    title: 'Safe Locations',
                    subtitle: 'Shelters, hospitals & rescue',
                    icon: Icons.location_on,
                    color: Color(0xFF388E3C),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SafeLocationsScreen())),
                  ),
                  SizedBox(height: 12),
                  HomeCard(
                    title: 'Volunteer',
                    subtitle: 'Join as first responder',
                    icon: Icons.volunteer_activism,
                    color: Color(0xFFF57C00),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => VolunteerScreen())),
                  ),
                  SizedBox(height: 28),
                  
                  // About card
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFFFE0B2), Color(0xFFFFCDD2)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Color(0xFFFF6F00).withOpacity(0.3)),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AboutScreen())),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(Icons.info, color: Color(0xFFD32F2F), size: 28),
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
                              Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFFD32F2F)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFD32F2F), Color(0xFFC62828)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    padding: EdgeInsets.all(12),
                    child: Icon(Icons.security, color: Colors.white, size: 28),
                  ),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
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
              leading: Icon(Icons.home, color: Color(0xFFD32F2F)),
              title: Text('Home'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.warning_amber, color: Color(0xFFD32F2F)),
              title: Text('Emergency Alert'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => AlertScreen()));
              },
            ),
            ListTile(
              leading: Icon(Icons.school, color: Color(0xFF1976D2)),
              title: Text('Disaster Info'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => InfoScreen()));
              },
            ),
            ListTile(
              leading: Icon(Icons.location_on, color: Color(0xFF388E3C)),
              title: Text('Safe Locations'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => SafeLocationsScreen()));
              },
            ),
            ListTile(
              leading: Icon(Icons.volunteer_activism, color: Color(0xFFF57C00)),
              title: Text('Volunteer'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => VolunteerScreen()));
              },
            ),
            Divider(margin: EdgeInsets.symmetric(vertical: 8)),
            ListTile(
              leading: Icon(Icons.info_outline, color: Color(0xFFD32F2F)),
              title: Text('About'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => AboutScreen()));
              },
            ),
            Spacer(),
            Divider(),
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Version 1.0.0',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
