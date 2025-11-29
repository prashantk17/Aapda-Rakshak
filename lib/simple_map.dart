import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class SimpleMap extends StatelessWidget {
  const SimpleMap({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Aapada Rakshak Map")),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(31.1048, 77.1734),
          initialZoom: 13,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            userAgentPackageName: 'com.example.aapada_rakshak',
          ),
        ],
      ),
    );
  }
}
