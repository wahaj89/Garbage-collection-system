import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:garbage_collection_system/Api/companyController.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class AddZone extends StatefulWidget {
  const AddZone({super.key});

  @override
  State<AddZone> createState() => _AddZoneState();
}

class _AddZoneState extends State<AddZone> {
  GoogleMapController? mapController;

  List<LatLng> polygonPoints = [];
  Set<Polygon> polygons = {};
  Set<Marker> markers = {};

  // 📍 GeoJSON function
  Map<String, dynamic> createGeoJSON() {
    return {
      "type": "Polygon",
      "coordinates": [
        polygonPoints
            .map((point) => [point.longitude, point.latitude])
            .toList()
      ]
    };
  }

  // 🚀 Save Zone
  void saveZone() async {
    if (polygonPoints.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("At least 3 points required")),
      );
      return;
    }

    final geoJson = createGeoJSON();

    final response = await CompanyApi.addZone(
      companyId: 1, 
      name: "Zone 1",
      description: "Test Zone",
      geoJson: geoJson,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(response)),
    );
  }

  // ❌ Clear
  void clearPolygon() {
    setState(() {
      polygonPoints.clear();
      polygons.clear();
      markers.clear();
    });
  }

  // ↩️ Undo
  void undoLast() {
    if (polygonPoints.isNotEmpty) {
      setState(() {
        polygonPoints.removeLast();
        updatePolygon();
      });
    }
  }

  void updatePolygon() {
    polygons.clear();

    polygons.add(
      Polygon(
        polygonId: const PolygonId("zone"),
        points: polygonPoints,
        strokeWidth: 2,
        strokeColor: Colors.blue,
        fillColor: Colors.blue.withOpacity(0.3),
      ),
    );

    markers = polygonPoints.map((point) {
      return Marker(
        markerId: MarkerId(point.toString()),
        position: point,
      );
    }).toSet();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Zone"),
        actions: [
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: undoLast,
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: clearPolygon,
          ),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(33.6844, 73.0479), // Islamabad
          zoom: 14,
        ),
        onMapCreated: (controller) {
          mapController = controller;
        },
        onTap: (LatLng point) {
          setState(() {
            polygonPoints.add(point);
            updatePolygon();
          });
        },
        polygons: polygons,
        markers: markers,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: saveZone,
        child: const Icon(Icons.save),
      ),
    );
  }
}