import 'package:flutter/material.dart';

class VolunteerScreen extends StatefulWidget {
  const VolunteerScreen({super.key});

  @override
  State<VolunteerScreen> createState() => _VolunteerScreenState();
}

class _VolunteerScreenState extends State<VolunteerScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _phone = '';
  String _skills = '';

  List<Map<String, String>> volunteers = []; // in-memory storage for demo

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      final newVol = {'name': _name, 'phone': _phone, 'skills': _skills};
      setState(() {
        volunteers.add(newVol);
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Thank you for volunteering!')));
      _formKey.currentState?.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Volunteer Signup'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Join as volunteer — we will contact you during local emergencies.', style: TextStyle(fontSize: 16)),
            SizedBox(height: 12),
            Form(
              key: _formKey,
              child: Column(children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'Full name'),
                  onSaved: (v) => _name = v?.trim() ?? '',
                  validator: (v) => (v?.trim().isEmpty ?? true) ? 'Enter name' : null,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Phone number'),
                  keyboardType: TextInputType.phone,
                  onSaved: (v) => _phone = v?.trim() ?? '',
                  validator: (v) => (v?.trim().isEmpty ?? true) ? 'Enter phone' : null,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Skills / Experience'),
                  onSaved: (v) => _skills = v?.trim() ?? '',
                ),
                SizedBox(height: 12),
                ElevatedButton(onPressed: _submit, child: Text('Sign Up')),
              ]),
            ),
            SizedBox(height: 18),
            Expanded(
              child: volunteers.isEmpty
                  ? Center(child: Text('No volunteers signed up yet.'))
                  : ListView.builder(
                      itemCount: volunteers.length,
                      itemBuilder: (context, i) {
                        final v = volunteers[i];
                        return Card(
                          child: ListTile(
                            leading: Icon(Icons.person),
                            title: Text(v['name']!),
                            subtitle: Text('${v['phone']}\n${v['skills'] ?? ''}'),
                            isThreeLine: true,
                          ),
                        );
                      }),
            ),
          ],
        ),
      ),
    );
  }
}
