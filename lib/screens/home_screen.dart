import 'package:flutter/material.dart';
import '../widgets/homecard.dart';
import 'alert_screen.dart';
import 'info_screen.dart';
import 'safe_locations_screen.dart';
import 'volunteer_screen.dart';
import 'about_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Aapda Rakshak'),
        centerTitle: true,
      ),
      drawer: _buildDrawer(context),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView(
          children: [
            Text('Welcome,', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            Text('Stay prepared. Help others. Be safe.',
                style: TextStyle(color: Colors.grey[700])),
            SizedBox(height: 20),

            HomeCard(
              title: 'Emergency Alert',
              subtitle: 'Send SOS message quickly',
              icon: Icons.warning_amber_rounded,
              color: Colors.red,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AlertScreen())),
            ),
            SizedBox(height: 12),

            HomeCard(
              title: 'Disaster Info',
              subtitle: 'Guidelines and safety tips',
              icon: Icons.info_outline,
              color: Colors.blue,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => InfoScreen())),
            ),
            SizedBox(height: 12),

            HomeCard(
              title: 'Safe Locations',
              subtitle: 'Shelters, hospitals & rescue points',
              icon: Icons.location_on,
              color: Colors.green,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SafeLocationsScreen())),
            ),
            SizedBox(height: 12),

            HomeCard(
              title: 'Volunteer',
              subtitle: 'Join as volunteer / first responder',
              icon: Icons.volunteer_activism,
              color: Colors.orange,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => VolunteerScreen())),
            ),

            SizedBox(height: 28),
            Card(
              child: ListTile(
                leading: Icon(Icons.favorite, color: Colors.red),
                title: Text('Inspired by Indian Red Cross Society'),
                subtitle: Text('Humanitarian values — help, donate, volunteer'),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AboutScreen())),
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
            UserAccountsDrawerHeader(
              currentAccountPicture: CircleAvatar(child: Icon(Icons.person)),
              accountName: Text('Aapda Rakshak'),
              accountEmail: Text('help@aapdarakshak.example'),
              decoration: BoxDecoration(color: Colors.red),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.warning),
              title: Text('Emergency Alert'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => AlertScreen()));
              },
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: Text('Disaster Info'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => InfoScreen()));
              },
            ),
            ListTile(
              leading: Icon(Icons.location_on),
              title: Text('Safe Locations'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => SafeLocationsScreen()));
              },
            ),
            ListTile(
              leading: Icon(Icons.volunteer_activism),
              title: Text('Volunteer'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => VolunteerScreen()));
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.public),
              title: Text('Visit IRCS (inspiration)'),
              onTap: () {
                Navigator.pop(context);
                // open indian red cross website
                AboutScreen.openExternal(context, 'https://www.indianredcross.org/');
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Close'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
