import 'dart:async';
import 'package:flutter/material.dart';
import 'package:garbage_collection_system/Api/driver_contoller.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';

class PickupPoints extends StatefulWidget {
  const PickupPoints({super.key});

  @override
  State<PickupPoints> createState() => _PickupPointsState();
}

class _PickupPointsState extends State<PickupPoints> {
  List points = [];
  bool loading = true;

  GoogleMapController? mapController;

  final Set<Marker> markers = {};
  final Set<Polyline> polylines = {};

  LatLng? currentLocation;

  final String apiKey = "AIzaSyCdmIHvKSHu-vKEeN0hcvjQrOtr8row6qE";

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
    loadPoints();
  }

  // 🟢 GET CURRENT LOCATION
  Future<void> getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      currentLocation = LatLng(position.latitude, position.longitude);
    });
  }

  Future<void> loadPoints() async {
    try {
      final data = await DriverApi().getPickupPoints();

      setState(() {
        points = data;
        loading = false;
      });

      setMarkers();
    } catch (e) {
      setState(() => loading = false);
      print("ERROR: $e");
    }
  }

  // 🟢 MARKERS
  void setMarkers() {
    markers.clear();

    for (var p in points) {
      final lat = double.parse(p['Latitude'].toString());
      final lng = double.parse(p['Longitude'].toString());

      markers.add(
        Marker(
          markerId: MarkerId(p['UserID'].toString()),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(title: p['Name']),
        ),
      );
    }

    setState(() {});
  }

  // 🔥 UBER STYLE ROUTE
  Future<void> drawRoute(double destLat, double destLng) async {
    if (currentLocation == null) return;

   PolylinePoints polylinePoints = PolylinePoints();

PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
  request: PolylineRequest(
    origin: PointLatLng(
      currentLocation!.latitude,
      currentLocation!.longitude,
    ),
    destination: PointLatLng(destLat, destLng),
    mode: TravelMode.driving,
  ),
);

    if (result.points.isNotEmpty) {
      List<LatLng> routeCoords = [];

      for (var point in result.points) {
        routeCoords.add(LatLng(point.latitude, point.longitude));
      }

      setState(() {
        polylines.clear();
        polylines.add(
          Polyline(
            polylineId: const PolylineId("route"),
            color: Colors.blue,
            width: 6,
            points: routeCoords,
          ),
        );
      });

      mapController?.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: currentLocation!,
            northeast: LatLng(destLat, destLng),
          ),
          100,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pickup Points")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 🗺️ MAP
                Expanded(
                  flex: 2,
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: currentLocation ?? const LatLng(33.6844, 73.0479),
                      zoom: 13,
                    ),
                    markers: markers,
                    polylines: polylines,
                    myLocationEnabled: true,
                    onMapCreated: (controller) {
                      mapController = controller;
                    },
                  ),
                ),

                // 📋 LIST
                Expanded(
                  flex: 1,
                  child: ListView.builder(
                    itemCount: points.length,
                    itemBuilder: (context, index) {
                      final p = points[index];

                      final lat = double.parse(p['Latitude'].toString());
                      final lng = double.parse(p['Longitude'].toString());

                      return Card(
                        margin: const EdgeInsets.all(8),
                        child: ListTile(
                          title: Text(p['Name'] ?? "No Name"),
                          subtitle: Text("Lat: $lat | Lng: $lng"),
                          trailing: ElevatedButton(
                            onPressed: () {
                              print("Navigating ");
                              drawRoute(lat, lng);
                            },
                            child: const Text("Navigate"),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}