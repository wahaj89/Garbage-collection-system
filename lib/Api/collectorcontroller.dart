import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CollectorApi {
  static const String baseUrl ="https://pauseful-raymon-unilluminant.ngrok-free.dev/api"; // 🔥 change this

  static Future<Map<String, dynamic>> addCollector({
    required int CompanyID,
    required String FullName,
    required String phone,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/collector/addCollector"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "CompanyID": CompanyID,
          "FullName": FullName,
          "Phone": phone,
          "Password": password,
        }),
      );

      final data = jsonDecode(response.body);
      print(response.body); // 🔥 DEBUG

      if (response.statusCode == 201) {
        return {"success": true, "message": data["message"]};
      } else {
        return {"error": data["message"] ?? "Something went wrong"};
      }
    } catch (e) {
      return {"error": e.toString()};
    }
  }
  //view collectors
Future<List<dynamic>> viewCollectors() async {
  final prefs = await SharedPreferences.getInstance();
  final companyId = prefs.getInt('CompanyID') ?? 0;
  try {
    final response = await http.get(
      Uri.parse("$baseUrl/collector/viewCollector?CompanyID=$companyId"),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (data is List) {
        return data; // 🔥 direct list case
      } else {
        return data['collectors'] ?? [];
      }
    }

    return [];
  } catch (e) {
    print("Error fetching collectors: $e");
    return [];
  }
}
//login
static Future<Map<String, dynamic>> loginCollector(
      String phone, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/collector/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "Phone": phone,
          "Password": password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          "success": true,
          "collector": data["collector"],
          "message": data["message"]
        };
      } else {
        return {
          "success": false,
          "message": data["message"] ?? "Login failed"
        };
      }
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }
  //scan
  
static Future<Map<String, dynamic>> scanBagAndPickup({
  required String qrCode,
  required int collectorId,
  required double latitude,
  required double longitude,
}) async {
  try {
    final response = await http.post(
      Uri.parse("$baseUrl/pickup/Scan"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "QRCode": qrCode,
        "CollectorID": collectorId,
        "Latitude": latitude,
        "Longitude": longitude,
      }),
    );

    final data = jsonDecode(response.body);

    return {
      "success": response.statusCode == 200,
      "message": data["message"]
    };

  } catch (e) {
    return {"success": false, "message": e.toString()};
  }
}
}