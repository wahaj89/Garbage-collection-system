import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:garbage_collection_system/Api/userController.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class ViewDriverLocation extends StatefulWidget {
  const ViewDriverLocation({super.key});

  @override
  State<ViewDriverLocation> createState() => _ViewDriverLocationState();
}

class _ViewDriverLocationState extends State<ViewDriverLocation> {
  GoogleMapController? mapController;

  LatLng? driverLocation;
  LatLng? userLocation;

  Timer? timer;

  final Set<Marker> markers = {};
  final Set<Polyline> polylines = {};

  bool isLoading = true;

  BitmapDescriptor? truckIcon;

  static const Color appColor = Color(0xFF99C13D);

  @override
  void initState() {
    super.initState();
    initializeScreen();
  }

  // ================= INITIALIZE SCREEN =================
  Future<void> initializeScreen() async {
    await loadTruckIcon();
    await startTracking();
  }

  // ================= LOAD SMALL TRUCK ICON SAFELY =================
  Future<void> loadTruckIcon() async {
    try {
      truckIcon = await getResizedMarkerIcon(
        "assets/truck.png",
        50, 
      );

      debugPrint("Truck icon loaded successfully");
    } catch (e) {
      debugPrint("Truck icon load error: $e");
      truckIcon = BitmapDescriptor.defaultMarkerWithHue(
        BitmapDescriptor.hueBlue,
      );
    }
  }

  // ================= RESIZE MARKER ICON =================
  Future<BitmapDescriptor> getResizedMarkerIcon(
    String assetPath,
    int width,
  ) async {
    final ByteData data = await rootBundle.load(assetPath);

    final ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: width,
    );

    final ui.FrameInfo frameInfo = await codec.getNextFrame();

    final ByteData? byteData = await frameInfo.image.toByteData(
      format: ui.ImageByteFormat.png,
    );

    if (byteData == null) {
      throw Exception("Unable to convert marker image to bytes");
    }

    final Uint8List resizedImage = byteData.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(resizedImage);
  }

  // ================= START TRACKING =================
  Future<void> startTracking() async {
    await fetchUserLocation();
    await fetchDriverLocation();

    timer = Timer.periodic(const Duration(seconds: 10), (_) async {
      await fetchDriverLocation();
    });
  }

  // ================= FETCH USER LOCATION =================
  Future<void> fetchUserLocation() async {
    try {
      final data = await UserApi.getUserLocation();

      if (data == null) {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
        return;
      }

      final double lat = double.parse(data['Latitude'].toString());
      final double lng = double.parse(data['Longitude'].toString());

      userLocation = LatLng(lat, lng);

      updateMarkers();
    } catch (e) {
      debugPrint("User location fetch error: $e");

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // ================= FETCH DRIVER LOCATION =================
  Future<void> fetchDriverLocation() async {
    try {
      final data = await UserApi.getDriverLiveLocation();

      if (data == null) {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
        return;
      }

      final double lat = double.parse(data['Latitude'].toString());
      final double lng = double.parse(data['Longitude'].toString());

      driverLocation = LatLng(lat, lng);

      updateMarkers();

      if (driverLocation != null && userLocation != null) {
        await drawRouteWithOSM(
          driverLocation!,
          userLocation!,
        );

        fitCameraToMarkers();
      }

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Driver location fetch error: $e");

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // ================= UPDATE MARKERS =================
  void updateMarkers() {
    markers.clear();

    // ✅ Driver marker with small truck icon
    if (driverLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId("driver"),
          position: driverLocation!,
          icon: truckIcon ??
              BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueBlue,
              ),
          infoWindow: const InfoWindow(
            title: "Driver",
            snippet: "Driver current location",
          ),
          anchor: const Offset(0.5, 1.0), // ✅ marker jaisa anchor
        ),
      );
    }

    // ✅ User location marker
    if (userLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId("user"),
          position: userLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
          infoWindow: const InfoWindow(
            title: "You",
            snippet: "Your location",
          ),
        ),
      );
    }

    if (mounted) {
      setState(() {});
    }
  }

  // ================= DRAW ROUTE USING OSM / OSRM =================
  Future<void> drawRouteWithOSM(LatLng driver, LatLng user) async {
    try {
      final String url =
          "https://router.project-osrm.org/route/v1/driving/"
          "${driver.longitude},${driver.latitude};"
          "${user.longitude},${user.latitude}"
          "?overview=full&geometries=geojson";

      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        debugPrint("OSRM route error: ${response.body}");
        return;
      }

      final data = jsonDecode(response.body);

      if (data['routes'] == null || data['routes'].isEmpty) {
        debugPrint("No route found");
        return;
      }

      final List coordinates = data['routes'][0]['geometry']['coordinates'];

      final List<LatLng> routePoints = coordinates.map<LatLng>((point) {
        final double lng = point[0].toDouble();
        final double lat = point[1].toDouble();

        return LatLng(lat, lng);
      }).toList();

      polylines.clear();

      polylines.add(
        Polyline(
          polylineId: const PolylineId("driver_user_route"),
          points: routePoints,
          color: Colors.blueAccent,
          width: 5,
        ),
      );

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint("Route draw error: $e");
    }
  }

  // ================= FIT CAMERA =================
  void fitCameraToMarkers() {
    if (mapController == null ||
        driverLocation == null ||
        userLocation == null) {
      return;
    }

    final double southWestLat =
        driverLocation!.latitude < userLocation!.latitude
            ? driverLocation!.latitude
            : userLocation!.latitude;

    final double southWestLng =
        driverLocation!.longitude < userLocation!.longitude
            ? driverLocation!.longitude
            : userLocation!.longitude;

    final double northEastLat =
        driverLocation!.latitude > userLocation!.latitude
            ? driverLocation!.latitude
            : userLocation!.latitude;

    final double northEastLng =
        driverLocation!.longitude > userLocation!.longitude
            ? driverLocation!.longitude
            : userLocation!.longitude;

    final bounds = LatLngBounds(
      southwest: LatLng(southWestLat, southWestLng),
      northeast: LatLng(northEastLat, northEastLng),
    );

    try {
      mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 80),
      );
    } catch (e) {
      debugPrint("Camera fit error: $e");
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    mapController?.dispose();
    super.dispose();
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Track Driver"),
        centerTitle: true,
        backgroundColor: appColor,
        foregroundColor: Colors.black,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: appColor,
              ),
            )
          : driverLocation == null || userLocation == null
              ? const Center(
                  child: Text(
                    "Location not available",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                )
              : GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: driverLocation!,
                    zoom: 14,
                  ),
                  markers: markers,
                  polylines: polylines,
                  myLocationEnabled: false,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  mapType: MapType.normal,
                  onMapCreated: (controller) {
                    mapController = controller;

                    Future.delayed(const Duration(milliseconds: 700), () {
                      fitCameraToMarkers();
                    });
                  },
                ),
    );
  }
}