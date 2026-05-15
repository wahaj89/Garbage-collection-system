import 'dart:async';
import 'dart:convert';
import 'dart:math';
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

  Timer? movementTimer;
  Timer? apiSyncTimer;

  final Set<Marker> markers = {};
  final Set<Polyline> polylines = {};

  bool isLoading = true;
  bool isRouteLoading = false;

  BitmapDescriptor? truckIcon;

  List<LatLng> routePoints = [];

  double remainingDistanceKm = 0.0;
  double etaMinutes = 0.0;

  static const Color appColor = Color(0xFF99C13D);

  // ✅ Har 2 sec baad 5 meter move
  static const double jumpMeters = 5.0;

  @override
  void initState() {
    super.initState();
    initializeScreen();
  }

  // ================= INITIALIZE SCREEN =================
  Future<void> initializeScreen() async {
    await loadTruckIcon();

    await fetchUserLocation();
    await fetchDriverLocationFromApi();

    if (driverLocation != null && userLocation != null) {
      await drawRouteWithOSM(driverLocation!, userLocation!);
      updateMarkers();
      fitCameraToMarkers();
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }

    startSmoothJumpTracking();
    startApiSync();
  }

  // ================= LOAD TRUCK ICON =================
  Future<void> loadTruckIcon() async {
    try {
      truckIcon = await getResizedMarkerIcon(
        "assets/truck.png",
        45,
      );
    } catch (e) {
      debugPrint("Truck icon load error: $e");
      truckIcon = BitmapDescriptor.defaultMarkerWithHue(
        BitmapDescriptor.hueBlue,
      );
    }
  }

  // ================= RESIZE ICON =================
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

  // ================= FETCH USER LOCATION =================
  Future<void> fetchUserLocation() async {
    try {
      final data = await UserApi.getUserLocation();

      if (data == null) return;

      final double lat = double.parse(data['Latitude'].toString());
      final double lng = double.parse(data['Longitude'].toString());

      userLocation = LatLng(lat, lng);
    } catch (e) {
      debugPrint("User location fetch error: $e");
    }
  }

  // ================= FETCH DRIVER LOCATION FIRST TIME ONLY =================
  Future<void> fetchDriverLocationFromApi() async {
    try {
      final data = await UserApi.getDriverLiveLocation();

      if (data == null) return;

      final double lat = double.parse(data['Latitude'].toString());
      final double lng = double.parse(data['Longitude'].toString());

      driverLocation = LatLng(lat, lng);
    } catch (e) {
      debugPrint("Driver location fetch error: $e");
    }
  }

  // ================= START 2 SEC MOVEMENT =================
  void startSmoothJumpTracking() {
    movementTimer?.cancel();

    movementTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      await moveDriverForwardBy5Meters();
    });
  }

  // ================= API SYNC WITHOUT DRIVER RESET =================
  void startApiSync() {
    apiSyncTimer?.cancel();

    apiSyncTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      try {
        // ✅ Sirf user location refresh
        // ❌ Driver location overwrite nahi hogi
        await fetchUserLocation();

        if (driverLocation != null && userLocation != null) {
          await drawRouteWithOSM(driverLocation!, userLocation!);
          updateMarkers();
        }
      } catch (e) {
        debugPrint("API sync error: $e");
      }
    });
  }

  // ================= MOVE DRIVER FORWARD =================
  Future<void> moveDriverForwardBy5Meters() async {
    if (driverLocation == null || userLocation == null) return;

    if (routePoints.length < 2) {
      await drawRouteWithOSM(driverLocation!, userLocation!);
      return;
    }

    double distanceToMove = jumpMeters;

    List<LatLng> updatedRoute = List.from(routePoints);

    updatedRoute[0] = driverLocation!;

    while (updatedRoute.length >= 2 && distanceToMove > 0) {
      final LatLng start = updatedRoute[0];
      final LatLng next = updatedRoute[1];

      final double segmentDistance = calculateDistanceMeters(start, next);

      if (segmentDistance <= 0) {
        updatedRoute.removeAt(0);
        continue;
      }

      if (segmentDistance > distanceToMove) {
        final double ratio = distanceToMove / segmentDistance;

        final LatLng newPosition = interpolateLatLng(start, next, ratio);

        driverLocation = newPosition;
        updatedRoute[0] = newPosition;
        routePoints = updatedRoute;

        break;
      } else {
        distanceToMove -= segmentDistance;
        driverLocation = next;
        updatedRoute.removeAt(0);
      }
    }

    final double distanceToUser = calculateDistanceMeters(
      driverLocation!,
      userLocation!,
    );

    if (distanceToUser <= 10) {
      driverLocation = userLocation;
      routePoints = [userLocation!];
      remainingDistanceKm = 0;
      etaMinutes = 0;
      movementTimer?.cancel();
    } else {
      routePoints = updatedRoute;
      updateRemainingDistanceAndEta();
    }

    updateMarkers();
    updateRoutePolyline();

    if (mapController != null && driverLocation != null) {
      mapController!.animateCamera(
        CameraUpdate.newLatLng(driverLocation!),
      );
    }

    if (mounted) setState(() {});
  }

  // ================= DRAW ROUTE OSRM =================
  Future<void> drawRouteWithOSM(LatLng driver, LatLng user) async {
    try {
      if (mounted) {
        setState(() {
          isRouteLoading = true;
        });
      }

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

      final route = data['routes'][0];

      final List coordinates = route['geometry']['coordinates'];

      routePoints = coordinates.map<LatLng>((point) {
        final double lng = point[0].toDouble();
        final double lat = point[1].toDouble();

        return LatLng(lat, lng);
      }).toList();

      final double distanceMeters = route['distance']?.toDouble() ?? 0.0;
      final double durationSeconds = route['duration']?.toDouble() ?? 0.0;

      remainingDistanceKm = distanceMeters / 1000;
      etaMinutes = durationSeconds / 60;

      updateRoutePolyline();
    } catch (e) {
      debugPrint("Route draw error: $e");
    } finally {
      if (mounted) {
        setState(() {
          isRouteLoading = false;
        });
      }
    }
  }

  // ================= UPDATE POLYLINE =================
  void updateRoutePolyline() {
    polylines.clear();

    if (routePoints.length >= 2) {
      polylines.add(
        Polyline(
          polylineId: const PolylineId("driver_user_route"),
          points: routePoints,
          color: Colors.blueAccent,
          width: 5,
          geodesic: true,
        ),
      );
    }

    if (mounted) setState(() {});
  }

  // ================= UPDATE MARKERS =================
  void updateMarkers() {
    markers.clear();

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
            snippet: "Moving",
          ),
          anchor: const Offset(0.5, 0.5),
        ),
      );
    }

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

    if (mounted) setState(() {});
  }

  // ================= DISTANCE =================
  double calculateDistanceMeters(LatLng point1, LatLng point2) {
    const double earthRadius = 6371000;

    final double lat1 = point1.latitude * pi / 180;
    final double lat2 = point2.latitude * pi / 180;

    final double dLat = (point2.latitude - point1.latitude) * pi / 180;
    final double dLng = (point2.longitude - point1.longitude) * pi / 180;

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLng / 2) * sin(dLng / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  // ================= INTERPOLATE =================
  LatLng interpolateLatLng(LatLng start, LatLng end, double ratio) {
    final double lat =
        start.latitude + ((end.latitude - start.latitude) * ratio);

    final double lng =
        start.longitude + ((end.longitude - start.longitude) * ratio);

    return LatLng(lat, lng);
  }

  // ================= ETA =================
  void updateRemainingDistanceAndEta() {
    if (routePoints.length < 2) {
      remainingDistanceKm = 0;
      etaMinutes = 0;
      return;
    }

    double totalMeters = 0;

    for (int i = 0; i < routePoints.length - 1; i++) {
      totalMeters += calculateDistanceMeters(
        routePoints[i],
        routePoints[i + 1],
      );
    }

    remainingDistanceKm = totalMeters / 1000;

    const double averageSpeedKmh = 20;
    etaMinutes = (remainingDistanceKm / averageSpeedKmh) * 60;
  }

  // ================= FIT CAMERA =================
  void fitCameraToMarkers() {
    if (mapController == null ||
        driverLocation == null ||
        userLocation == null) {
      return;
    }

    final double southWestLat = min(
      driverLocation!.latitude,
      userLocation!.latitude,
    );

    final double southWestLng = min(
      driverLocation!.longitude,
      userLocation!.longitude,
    );

    final double northEastLat = max(
      driverLocation!.latitude,
      userLocation!.latitude,
    );

    final double northEastLng = max(
      driverLocation!.longitude,
      userLocation!.longitude,
    );

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

  // ================= REFRESH ROUTE =================
  Future<void> refreshRoute() async {
    try {
      await fetchUserLocation();

      if (driverLocation != null && userLocation != null) {
        await drawRouteWithOSM(driverLocation!, userLocation!);
        updateMarkers();
        fitCameraToMarkers();
      }
    } catch (e) {
      debugPrint("Manual refresh error: $e");
    }
  }

  @override
  void dispose() {
    movementTimer?.cancel();
    apiSyncTimer?.cancel();
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
        elevation: 0,
        actions: [
          IconButton(
            onPressed: refreshRoute,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: appColor,
              ),
            )
          : driverLocation == null || userLocation == null
              ? _buildLocationNotAvailable()
              : Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: driverLocation!,
                        zoom: 15,
                      ),
                      markers: markers,
                      polylines: polylines,
                      myLocationEnabled: false,
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                      mapToolbarEnabled: false,
                      compassEnabled: true,
                      mapType: MapType.normal,
                      onMapCreated: (controller) {
                        mapController = controller;

                        Future.delayed(
                          const Duration(milliseconds: 700),
                          () {
                            fitCameraToMarkers();
                          },
                        );
                      },
                    ),

                    // ✅ Simple bottom card
                    Positioned(
                      left: 12,
                      right: 12,
                      bottom: 16,
                      child: _buildSimpleBottomCard(),
                    ),
                  ],
                ),
    );
  }

  // ================= SIMPLE BOTTOM CARD =================
  Widget _buildSimpleBottomCard() {
    final String distanceText = remainingDistanceKm <= 0
        ? "Arrived"
        : "${remainingDistanceKm.toStringAsFixed(2)} km";

    final String etaText = etaMinutes <= 0 ? "0 min" : "${etaMinutes.ceil()} min";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.14),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.local_shipping,
            color: Colors.black87,
            size: 26,
          ),
          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isRouteLoading ? "Updating route..." : "Driver moving",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  "$distanceText • $etaText",
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: fitCameraToMarkers,
            icon: const Icon(Icons.my_location),
            color: Colors.black87,
          ),
        ],
      ),
    );
  }

  // ================= LOCATION NOT AVAILABLE UI =================
  Widget _buildLocationNotAvailable() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.location_off,
              size: 60,
              color: Colors.black38,
            ),
            const SizedBox(height: 12),
            const Text(
              "Location not available",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Driver ya user location fetch nahi ho rahi.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: refreshRoute,
              style: ElevatedButton.styleFrom(
                backgroundColor: appColor,
                foregroundColor: Colors.black,
              ),
              child: const Text("Retry"),
            ),
          ],
        ),
      ),
    );
  }
}