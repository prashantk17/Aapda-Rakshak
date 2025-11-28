import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(AapdaRakshakApp());
}

class AapdaRakshakApp extends StatelessWidget {
  const AapdaRakshakApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aapda Rakshak',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: HomeScreen(),
    );
  }
}
