import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:garbage_collection_system/Api/companyController.dart';
import 'package:garbage_collection_system/custom_widgets/inputfield.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  // 🔹 Controllers
  TextEditingController nameController = TextEditingController();
  TextEditingController descController = TextEditingController();

  // 📍 GeoJSON
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

    if (nameController.text.isEmpty || descController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Name & Description required")),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    int? companyId = prefs.getInt('CompanyID');

    if (companyId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("CompanyID not found")),
      );
      return;
    }

    final geoJson = createGeoJSON();

    final response = await CompanyApi.addZone(
      companyId: companyId,
      name: nameController.text.trim(),
      description: descController.text.trim(),
      geoJson: geoJson,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(response)),
    );

    // 🔥 Clear after save
    clearPolygon();
    nameController.clear();
    descController.clear();
  }

  // 🧹 Clear
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

  // 🔄 Update polygon
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
        backgroundColor:  const Color(0xFF99C13D),
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

      body: Column(
        children: [
          // 🔹 Custom Inputs
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomInput(
              label: "Zone Name",
              controller: nameController,
              suffixIcon: const Icon(Icons.map),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomInput(
              label: "Description",
              controller: descController,
              suffixIcon: const Icon(Icons.description),
            ),
          ),

          // 🗺️ Map
          Expanded(
            child: GoogleMap(
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
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: saveZone,
        child: const Icon(Icons.add),
      ),
    );
  }
}