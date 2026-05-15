import 'dart:convert';
import 'dart:io';
import 'package:garbage_collection_system/Api/ip.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DriverApi {
 // static const String _baseUrl ="https://pauseful-raymon-unilluminant.ngrok-free.dev/api";
    static final String _baseUrl = Ip.baseUrl;  

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

String formatDate(DateTime date) {
    return "${date.year.toString().padLeft(4, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.day.toString().padLeft(2, '0')}";
  }

  dynamic _decodeResponse(http.Response response) {
    print("STATUS CODE: ${response.statusCode}");
    print("RESPONSE BODY: ${response.body}");

    if (response.body.isEmpty) {
      throw Exception("Empty response from server");
    }

    try {
      return jsonDecode(response.body);
    } catch (e) {
      throw Exception(
        "Server JSON nahi bhej raha. Route ya URL wrong ho sakta hai. Body: ${response.body}",
      );
    }
  }

  
  
  Future<Map<String, dynamic>> applyDriverLeave({
    required int driverId,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
  }) async {
    final url = Uri.parse(
      "$_baseUrl/drivers/applyDriverLeave?DriverID=$driverId",
    );

    print("APPLY LEAVE URL: $url");

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "StartDate": formatDate(startDate),
        "EndDate": formatDate(endDate),
        "Reason": reason,
      }),
    );

    final data = _decodeResponse(response);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Map<String, dynamic>.from(data);
    } else {
      throw Exception(data["message"] ?? "Leave apply failed");
    }
  }

  Future<List<dynamic>> getDriverLeaves({
    required int companyId,
    String? status,
  }) async {
    String url = "$_baseUrl/drivers/getDriverLeaves?CompanyID=$companyId";

    if (status != null && status.isNotEmpty) {
      url += "&Status=$status";
    }

    print("GET LEAVES URL: $url");

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    final data = _decodeResponse(response);

    if (response.statusCode == 200) {
      return List<dynamic>.from(data);
    } else {
      throw Exception(data["message"] ?? "Failed to load leaves");
    }
  }

  Future<Map<String, dynamic>> reviewDriverLeave({
    required int leaveId,
    required String status,
    String remarks = "",
  }) async {
    final url = Uri.parse(
      "$_baseUrl/drivers/reviewDriverLeave/$leaveId",
    );

    print("REVIEW LEAVE URL: $url");

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "Status": status,
        "Remarks": remarks,
      }),
    );

    final data = _decodeResponse(response);

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(data);
    } else {
      throw Exception(data["message"] ?? "Review failed");
    }
  }

  Future<Map<String, dynamic>> driverReturned({
    required int leaveId,
  }) async {
    final url = Uri.parse(
      "$_baseUrl/drivers/driverReturned/$leaveId",
    );

    print("DRIVER RETURNED URL: $url");

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    final data = _decodeResponse(response);

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(data);
    } else {
      throw Exception(data["message"] ?? "Return failed");
    }
  }}