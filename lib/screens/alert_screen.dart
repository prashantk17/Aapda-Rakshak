import 'package:flutter/material.dart';
import '../services/alert_service.dart';

class AlertScreen extends StatefulWidget {
  @override
  State<AlertScreen> createState() => _AlertScreenState();
}

class _AlertScreenState extends State<AlertScreen> {
  bool sending = false;

  void _sendSos() async {
    setState(() => sending = true);

    final message = "SOS! I need help. My approximate location: [add location]. - Aapda Rakshak";

    try {
      // leave phone empty to let user choose recipient
      await AlertService.sendSmsAlert(phone: '', message: message);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('SMS Intent opened — complete sending in messages app')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not open SMS app')));
    } finally {
      setState(() => sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Emergency Alert'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Use SOS to quickly send an emergency message. This opens your SMS app with a prepared message.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 24),
            sending
                ? CircularProgressIndicator()
                : ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                    ),
                    icon: Icon(Icons.sos, size: 26),
                    label: Text('Send SOS', style: TextStyle(fontSize: 18)),
                    onPressed: _sendSos,
                  ),
            SizedBox(height: 20),
            Card(
              child: ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('Tip'),
                subtitle: Text('Add your real location in the message before sending. Later we can auto-attach GPS.'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
