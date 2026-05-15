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
  Timer? routeMoveTimer;

  Position? lastPosition;
  Position? lastSentPosition;

  double bearing = 0;

  BitmapDescriptor? truckIcon;

  List<LatLng> routePoints = [];

  bool isRouteStarted = false;
  bool isMoving = false;

  static const double jumpMeters = 5;
  static const int jumpSeconds = 2;

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
      // ✅ Jab manual route start ya pause ho, GPS truck ko wapis real location par nahi le jayega
      if (isRouteStarted) return;

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

  void sendCurrentLatLngToApi() {
    if (currentLocation == null) return;

    DriverApi.updateDriverLocation(
      lat: currentLocation!.latitude,
      lng: currentLocation!.longitude,
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
      removeReachedStops();

      if (selectedStops.isEmpty) {
        polylines.clear();
        routePoints.clear();

        if (mounted) setState(() {});
        return;
      }

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

      routePoints = poly;

      polylines.clear();

      polylines.add(
        Polyline(
          polylineId: const PolylineId("route"),
          color: Colors.blue,
          width: 6,
          points: poly,
        ),
      );

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint("Draw route error: $e");
    }
  }

  // ================= START / PAUSE / RESUME BUTTON =================
  Future<void> startRouteFromButton() async {
    // ✅ Agar truck chal raha hai to pause karo
    if (isMoving) {
      pauseRouteMovement();
      return;
    }

    if (currentLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Current location not found"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (selectedStops.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No pickup points selected"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      // ✅ Start ya resume dono case mein true
      isRouteStarted = true;
      isMoving = true;
    });

    // ✅ Current paused position se fresh route banao
    await drawMultiRoute();

    if (routePoints.isEmpty) {
      setState(() {
        isMoving = false;

        // ✅ false nahi karna, warna GPS stream truck ko wapis real location par le jayegi
        isRouteStarted = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Route not found"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    startJumpMovement();
  }

  // ================= 5 METER JUMP EVERY 2 SEC =================
  void startJumpMovement() {
    routeMoveTimer?.cancel();

    routeMoveTimer = Timer.periodic(
      const Duration(seconds: jumpSeconds),
      (timer) async {
        if (currentLocation == null) return;

        if (selectedStops.isEmpty) {
          stopRouteMovement();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Route completed"),
              backgroundColor: Color(0xFF99C13D),
            ),
          );
          return;
        }

        if (routePoints.length < 2) {
          await drawMultiRoute();
          return;
        }

        LatLng? nextPosition = getNextPositionByMeters(jumpMeters);

        if (nextPosition == null) {
          await drawMultiRoute();
          return;
        }

        bearing = calculateBearing(currentLocation!, nextPosition);
        currentLocation = nextPosition;

        updateMarkers();
        sendCurrentLatLngToApi();

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

        // ✅ Har 2 sec baad route current truck location se dobara update
        await drawMultiRoute();
      },
    );
  }

  LatLng? getNextPositionByMeters(double meters) {
    if (currentLocation == null || routePoints.length < 2) return null;

    LatLng current = currentLocation!;
    double remainingMeters = meters;

    for (int i = 0; i < routePoints.length - 1; i++) {
      LatLng end = routePoints[i + 1];

      double distanceFromCurrentToEnd = Geolocator.distanceBetween(
        current.latitude,
        current.longitude,
        end.latitude,
        end.longitude,
      );

      if (distanceFromCurrentToEnd == 0) continue;

      if (distanceFromCurrentToEnd <= remainingMeters) {
        current = end;
        remainingMeters -= distanceFromCurrentToEnd;
        continue;
      }

      double ratio = remainingMeters / distanceFromCurrentToEnd;

      double lat = current.latitude + (end.latitude - current.latitude) * ratio;
      double lng =
          current.longitude + (end.longitude - current.longitude) * ratio;

      return LatLng(lat, lng);
    }

    return routePoints.isNotEmpty ? routePoints.last : null;
  }

  // ================= PAUSE ROUTE =================
  void pauseRouteMovement() {
    routeMoveTimer?.cancel();
    routeMoveTimer = null;

    if (mounted) {
      setState(() {
        isMoving = false;

        // ✅ Important: true rakho taake GPS stream truck ko wapis na le jaye
        isRouteStarted = true;
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Route paused"),
        backgroundColor: Colors.orange,
      ),
    );
  }

  // ================= STOP ROUTE COMPLETELY =================
  void stopRouteMovement() {
    routeMoveTimer?.cancel();
    routeMoveTimer = null;

    if (mounted) {
      setState(() {
        isMoving = false;
        isRouteStarted = false;
      });
    }
  }

  // ================= REMOVE REACHED STOPS =================
  void removeReachedStops() {
    if (currentLocation == null) return;

    selectedStops.removeWhere((index) {
      final p = points[index];

      final lat = double.tryParse(p['Latitude'].toString());
      final lng = double.tryParse(p['Longitude'].toString());

      if (lat == null || lng == null) return false;

      double distance = Geolocator.distanceBetween(
        currentLocation!.latitude,
        currentLocation!.longitude,
        lat,
        lng,
      );

      // ✅ 8 meter ke andar point reached maan lo
      return distance <= 8;
    });
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

  @override
  void dispose() {
    positionStream?.cancel();
    locationTimer?.cancel();
    routeMoveTimer?.cancel();
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
                  child: SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: isMoving ? "Stop Route" : "Start Route",
                      icon: isMoving
                          ? Icons.pause_circle_outline
                          : Icons.alt_route,
                      onPressed: startRouteFromButton,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}