import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:garbage_collection_system/Api/driver_contoller.dart';
import 'package:garbage_collection_system/custom_widgets/button.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

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
  List<int> selectedStops = [];

  StreamSubscription<Position>? positionStream;

  Timer? locationTimer;
  Position? lastPosition;
  Position? lastSentPosition;

  double bearing = 0;

  BitmapDescriptor? truckIcon;

  @override
  void initState() {
    super.initState();
    loadTruckIcon();
    startLiveTracking();
    loadPoints();
  }

  // ================= LOAD SMALL TRUCK ICON =================
  Future<void> loadTruckIcon() async {
    truckIcon = await getResizedMarkerIcon(
      'assets/truck.png',
      50, 
    );

    updateMarkers();
  }

  Future<BitmapDescriptor> getResizedMarkerIcon(String path, int width) async {
    final ByteData data = await rootBundle.load(path);

    final ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: width,
    );

    final ui.FrameInfo frameInfo = await codec.getNextFrame();

    final ByteData? byteData = await frameInfo.image.toByteData(
      format: ui.ImageByteFormat.png,
    );

    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }

  // ================= LIVE TRACKING =================
  void startLiveTracking() async {
    final prefs = await SharedPreferences.getInstance();
    final driverId = prefs.getInt('DriverID') ?? 0;

    positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen((Position position) {
      if (lastPosition != null) {
        bearing = calculateBearing(
          LatLng(lastPosition!.latitude, lastPosition!.longitude),
          LatLng(position.latitude, position.longitude),
        );
      }

      lastPosition = position;
      currentLocation = LatLng(position.latitude, position.longitude);

      updateMarkers();

      mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: currentLocation!,
            zoom: 17,
            tilt: 45,
            bearing: bearing,
          ),
        ),
      );
    });
    
    locationTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (lastPosition == null) return;

      if (lastSentPosition == null) {
        sendLocation(driverId, lastPosition!);
        lastSentPosition = lastPosition;
        return;
      }

      double distance = Geolocator.distanceBetween(
        lastSentPosition!.latitude,
        lastSentPosition!.longitude,
        lastPosition!.latitude,
        lastPosition!.longitude,
      );

      if (distance > 5) {
        sendLocation(driverId, lastPosition!);
        lastSentPosition = lastPosition;
      }
    });
  }

  void sendLocation(int driverId, Position pos) {
    DriverApi.updateDriverLocation(
      lat: pos.latitude,
      lng: pos.longitude,
    );
  }

  // ================= LOAD POINTS =================
  Future<void> loadPoints() async {
    try {
      final data = await DriverApi().getPickupPoints();

      points = data;
      selectedStops = List.generate(points.length, (i) => i);
      loading = false;

      updateMarkers();
      await drawMultiRoute();
    } catch (e) {
      loading = false;
      if (mounted) setState(() {});
      debugPrint("Load points error: $e");
    }
  }

  // ================= UPDATE MARKERS =================
  void updateMarkers() {
    markers.clear();

    // Driver small truck marker
    if (currentLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId("driver"),
          position: currentLocation!,
          rotation: bearing,
          flat: true,
          anchor: const Offset(0.5, 0.5),
          icon: truckIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(
            title: "Driver Location",
          ),
        ),
      );
    }

    // Pickup point markers
    for (int i = 0; i < points.length; i++) {
      final p = points[i];

      final lat = double.tryParse(p['Latitude'].toString());
      final lng = double.tryParse(p['Longitude'].toString());

      if (lat == null || lng == null) continue;

      markers.add(
        Marker(
          markerId: MarkerId(p['UserID'].toString()),
          position: LatLng(lat, lng),
          icon: selectedStops.contains(i)
              ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen)
              : BitmapDescriptor.defaultMarker,
          infoWindow: InfoWindow(
            title: p['Name']?.toString() ?? "Pickup Point",
          ),
          onTap: () {
            if (!selectedStops.contains(i)) {
              selectedStops.add(i);
            }

            updateMarkers();

            mapController?.animateCamera(
              CameraUpdate.newLatLngZoom(
                LatLng(lat, lng),
                15,
              ),
            );

            drawMultiRoute();
          },
        ),
      );
    }

    if (mounted) {
      setState(() {});
    }
  }

  // ================= ROUTE OPTIMIZATION =================
  List<int> optimizeRouteOrder(List<int> stops) {
    if (currentLocation == null) return stops;

    List<int> remaining = List.from(stops);
    List<int> ordered = [];
    LatLng last = currentLocation!;

    while (remaining.isNotEmpty) {
      double minDist = double.infinity;
      int closestIndex = 0;

      for (int i = 0; i < remaining.length; i++) {
        final p = points[remaining[i]];

        final lat = double.tryParse(p['Latitude'].toString());
        final lng = double.tryParse(p['Longitude'].toString());

        if (lat == null || lng == null) continue;

        double dist = Geolocator.distanceBetween(
          last.latitude,
          last.longitude,
          lat,
          lng,
        );

        if (dist < minDist) {
          minDist = dist;
          closestIndex = i;
        }
      }

      ordered.add(remaining[closestIndex]);

      final p = points[remaining[closestIndex]];

      last = LatLng(
        double.parse(p['Latitude'].toString()),
        double.parse(p['Longitude'].toString()),
      );

      remaining.removeAt(closestIndex);
    }

    return ordered;
  }

  // ================= DRAW ROUTE =================
  Future<void> drawMultiRoute() async {
    if (currentLocation == null || selectedStops.isEmpty) return;

    try {
      List<int> optimized = optimizeRouteOrder(selectedStops);

      String coords =
          "${currentLocation!.longitude},${currentLocation!.latitude};";

      for (int i = 0; i < optimized.length; i++) {
        final p = points[optimized[i]];
        coords += "${p['Longitude']},${p['Latitude']}";

        if (i != optimized.length - 1) {
          coords += ";";
        }
      }

      String url =
          "https://router.project-osrm.org/route/v1/driving/$coords?overview=full&geometries=geojson";

      final res = await http.get(Uri.parse(url));

      if (res.statusCode != 200) return;

      final data = jsonDecode(res.body);

      if (data['routes'] == null || data['routes'].isEmpty) return;

      List route = data['routes'][0]['geometry']['coordinates'];

      List<LatLng> poly = [];

      for (var c in route) {
        poly.add(
          LatLng(
            c[1],
            c[0],
          ),
        );
      }

      polylines.clear();

      polylines.add(
        Polyline(
          polylineId: const PolylineId("route"),
          color: Colors.blue,
          width: 6,
          points: poly,
          onTap: () => moveAlongRoute(poly),
        ),
      );

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint("Draw route error: $e");
    }
  }

  // ================= BEARING =================
  double calculateBearing(LatLng start, LatLng end) {
    double lat1 = start.latitude * (math.pi / 180);
    double lat2 = end.latitude * (math.pi / 180);
    double dLon = (end.longitude - start.longitude) * (math.pi / 180);

    double y = math.sin(dLon) * math.cos(lat2);

    double x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);

    return (math.atan2(y, x) * 180 / math.pi + 360) % 360;
  }

  // ================= SMOOTH MOVEMENT =================
  Future<void> moveAlongRoute(List<LatLng> poly) async {
    for (int i = 0; i < poly.length - 1; i++) {
      LatLng start = poly[i];
      LatLng end = poly[i + 1];

      for (double t = 0; t <= 1; t += 0.1) {
        await Future.delayed(const Duration(milliseconds: 100));

        double lat = start.latitude + (end.latitude - start.latitude) * t;
        double lng = start.longitude + (end.longitude - start.longitude) * t;

        LatLng newPos = LatLng(lat, lng);

        bearing = calculateBearing(start, end);
        currentLocation = newPos;

        updateMarkers();

        mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: newPos,
              zoom: 17,
              tilt: 45,
              bearing: bearing,
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    positionStream?.cancel();
    locationTimer?.cancel();
    mapController?.dispose();
    super.dispose();
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pickup Points"),
        backgroundColor: const Color(0xFF99C13D),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Expanded(
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: currentLocation ?? const LatLng(33.6844, 73.0479),
                      zoom: 13,
                    ),
                    markers: markers,
                    polylines: polylines,
                    onMapCreated: (controller) {
                      mapController = controller;

                      if (currentLocation != null) {
                        mapController?.animateCamera(
                          CameraUpdate.newLatLngZoom(
                            currentLocation!,
                            17,
                          ),
                        );
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: CustomButton(
                    text: "Start Route",
                    icon: Icons.alt_route,
                    onPressed: drawMultiRoute,
                  ),
                ),
              ],
            ),
    );
  }
}