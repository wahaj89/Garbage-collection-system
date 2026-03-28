import 'package:flutter/material.dart';
import 'package:garbage_collection_system/Api/companyController.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class ViewAllZones extends StatefulWidget {
  const ViewAllZones({super.key});

  @override
  State<ViewAllZones> createState() => _ViewAllZonesState();
}

class _ViewAllZonesState extends State<ViewAllZones> {
  GoogleMapController? mapController;

  Set<Polygon> polygons = {};

  @override
  void initState() {
    super.initState();
    loadZones();
  }

  // 🔥 Load zones from DB
  Future<void> loadZones() async {
    final zones = await CompanyApi.getZones(1); // TODO: dynamic CompanyID

    Set<Polygon> loadedPolygons = {};

    for (var zone in zones) {
      if (zone["GeoJSON"] != null) {
        List coordinates = zone["GeoJSON"]["coordinates"][0];

        List<LatLng> points = coordinates.map<LatLng>((coord) {
          return LatLng(coord[1], coord[0]); // lat, lng
        }).toList();

        loadedPolygons.add(
          Polygon(
            polygonId: PolygonId(zone["ZoneID"].toString()),
            points: points,
            strokeWidth: 2,
            strokeColor: Colors.red,
            fillColor: Colors.red.withOpacity(0.3),
          ),
        );
      }
    }

    setState(() {
      polygons = loadedPolygons;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Zones"),
      ),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(33.6844, 73.0479), // default
          zoom: 13,
        ),
        onMapCreated: (controller) {
          mapController = controller;
        },
        polygons: polygons,
      ),
    );
  }
}