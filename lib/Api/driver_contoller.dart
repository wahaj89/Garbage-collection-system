import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DriverApi {
  static const String _baseUrl =
      "https://pauseful-raymon-unilluminant.ngrok-free.dev/api";

  Future<int?> getId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('id');
  }
  // driver login
  static Future<Map<String, dynamic>> loginDriver(
    String phone,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/drivers/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"Phone": phone, "Password": password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // return full response (message + driver)
        return {
          "success": true,
          "message": data["message"],
          "driver": data["driver"],
        };
      } else {
        return {"success": false, "message": data["message"] ?? "Login failed"};
      }
    } catch (e) {
      return {"success": false, "message": "Server error: $e"};
    }
  }

  // get todays schedule for driver
  Future<http.Response> fetchTodaysSchedule() async {
    final pref = await SharedPreferences.getInstance();
    final driverId = pref.getInt('UserId');
    print(driverId);
    final url = Uri.parse(
      "$_baseUrl/drivers/getDriverSchedule?DriverID=$driverId",
    );

    var res = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
    );
    print(res.body);
    if (res.statusCode == 200) {
      return res;
    } else {
      throw HttpException('Failed to load schedule: ${res.body}');
    }
  }
   Future<List> getPickupPoints() async {
    final prefs = await SharedPreferences.getInstance();
    final driverId = prefs.getInt('UserId');
    final res = await http.get(
      Uri.parse("$_baseUrl/drivers/getDriverPickupPoints?DriverID=$driverId"),
    );
    print(res.body);
   if (res.statusCode == 200) {
      final decoded = jsonDecode(res.body);

      // 🔥 IMPORTANT FIX HERE
      return decoded['data'] ?? [];
    } else {
      throw Exception("Failed to load data");
    }
  }
  // update driver location
  static Future<void> updateDriverLocation({
  required double lat,
  required double lng,
}) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final driverId = prefs.getInt('UserId') ?? 0;
    await http.post(
      Uri.parse("$_baseUrl/drivers/updateLocation?DriverID=$driverId"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "Latitude": lat,
        "Longitude": lng,
      }),
    );
  } catch (e) {
    print("Location update failed: $e");
  }
}
}
