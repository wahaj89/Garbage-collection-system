import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? _currentLocation;
  final Set<Marker> _markers = {};

  final BitmapDescriptor currentLocationIcon =
      BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);

  final BitmapDescriptor selectedLocationIcon =
      BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  // ================= GET CURRENT LOCATION =================
  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);

        _markers.add(
          Marker(
            markerId: const MarkerId("current"),
            position: _currentLocation!,
            icon: currentLocationIcon,
            infoWindow: const InfoWindow(title: "Your Location"),
          ),
        );
      });
    } catch (e) {
      debugPrint("Location error: $e");
    }
  }

  // ================= MAP TAP (RETURN DATA) =================
  Future<void> _onMapTapped(LatLng point) async {
  double lat = point.latitude;
  double lng = point.longitude;

  setState(() {
    // Remove previous selected marker
    _markers.removeWhere(
        (marker) => marker.markerId.value == "selected");

    // Add new marker at tapped location
    _markers.add(
      Marker(
        markerId: const MarkerId("selected"),
        position: point,
        icon: selectedLocationIcon,
        infoWindow: InfoWindow(
            title: "Selected Location",
            snippet: "Lat: $lat, Lng: $lng"),
      ),
    );
  });

  // Return latitude and longitude to previous screen
  Navigator.pop(context, {
    "latitude": lat,
    "longitude": lng,
  });
}

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Location"),
        backgroundColor: const Color(0xFF99C13D),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
        
          target: _currentLocation ?? const LatLng(33.6844, 73.0479),
          zoom: 14,
        ),
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        markers: _markers,
        onTap: _onMapTapped,
      ),
    );
  }
}
