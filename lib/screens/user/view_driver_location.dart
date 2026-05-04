import 'dart:async';
import 'package:flutter/material.dart';
import 'package:garbage_collection_system/Api/userController.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ViewDriverLocation extends StatefulWidget {
  const ViewDriverLocation({super.key});

  @override
  State<ViewDriverLocation> createState() => _ViewDriverLocationState();
}

class _ViewDriverLocationState extends State<ViewDriverLocation> {
  GoogleMapController? mapController;

  LatLng? driverLocation;
  Timer? timer;

  final Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    startTracking();
  }

  // ================= START TRACKING =================
  void startTracking() {
    // first fetch
    fetchDriverLocation();

    // 🔥 every 10 seconds
    timer = Timer.periodic(const Duration(seconds: 10), (_) {
      fetchDriverLocation();
    });
  }

  // ================= FETCH LOCATION =================
  Future<void> fetchDriverLocation() async {
    final data = await UserApi.getDriverLiveLocation();

    if (data == null) return;

    double lat = double.parse(data['Latitude'].toString());
    double lng = double.parse(data['Longitude'].toString());

    LatLng newLocation = LatLng(lat, lng);

    setState(() {
      driverLocation = newLocation;

      markers.clear();
      markers.add(
        Marker(
          markerId: const MarkerId("driver"),
          position: newLocation,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueBlue,
          ),
          infoWindow: const InfoWindow(title: "Driver"),
        ),
      );
    });

    // move camera smoothly
    mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(newLocation, 15),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Track Driver")),
      body: driverLocation == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: driverLocation!,
                zoom: 14,
              ),
              markers: markers,
              myLocationEnabled: false,
              onMapCreated: (c) => mapController = c,
            ),
    );
  }
}