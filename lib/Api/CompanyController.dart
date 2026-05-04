import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CompanyApi {
  static const String _baseUrl =
      "https://pauseful-raymon-unilluminant.ngrok-free.dev/api";

  // Common headers for ngrok + JSON
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      };


  // ================= LOGIN =================
  Future<http.Response> login(String email, String password) async {
    final url = Uri.parse("$_baseUrl/company/login");

    final response = await http.post(
      url,
      headers: _headers,
      body: jsonEncode({'Email': email, 'Password': password}),
    );

    if (response.statusCode == 200) {
      return response;
    } else {
      throw HttpException('Login failed: ${response.body}');
    }
  }

  // ================= TOKEN =================
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // ================= FETCH COMPANIES =================
  Future<List<dynamic>> fetchCompanies() async {
    final url = Uri.parse("$_baseUrl/company/viewCompanies");

    final response = await http.get(
      url,
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw HttpException('Failed to load companies: ${response.body}');
    }
  }

  // ================= FETCH PLANS =================
  Future<List<dynamic>> fetchPlans(int companyId) async {
    final url = Uri.parse(
        "$_baseUrl/subscriptions/viewPlans?CompanyID=$companyId");

    final response = await http.get(
      url,
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load plans: ${response.body}');
    }
  }

  // ================= SUBSCRIBE PLAN =================
  Future<http.Response> subscribePlan(int planId, int companyId) async {
    final token = await getToken();
    if (token == null) {
      return Future.error('No token found');
    }

    final url = Uri.parse("$_baseUrl/subscriptions/buySubscription");

    final response = await http.post(
      url,
      headers: {
        ..._headers,
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'PlanID': planId, 'CompanyID': companyId}),
    );

    return response;
  }

  // ================= ADD COMPANY =================
  Future<http.Response> addCompany(
    String name,
    String email,
    String phone,
    String address,
    String regNo,
    String password,
  ) async {
    final url = Uri.parse("$_baseUrl/company/addCompany");

    final response = await http.post(
      url,
      headers: _headers,
      body: jsonEncode({
        "Name": name,
        "Email": email,
        "Phone": phone,
        "Address": address,
        "RegistrationNumber": regNo,
        "Password": password,
      }),
    );

    return response;
  }


// =================== fetch services ===================
Future<List<dynamic>> fetchCompanyServices(int CompanyID) async {
  final url = Uri.parse("$_baseUrl/company/viewServices?CompanyID=$CompanyID");

  final response = await http.get(
    url,
    headers: {
      'Content-Type': 'application/json', 
      'ngrok-skip-browser-warning': 'true',
    },
  );

  if (response.statusCode == 200) {
    print("Services JSON: ${response.body}");
    return jsonDecode(response.body) as List<dynamic>;
  } else {
    throw HttpException('Failed to load services: ${response.body}');
  }
}
//add plan
Future<http.Response> addPlan(
  String Name,
  int bagsperDay,
  String MonthlyPrice,
  String Description,

) async {
  final token = await getToken();
  print(token);
  if (token == null) {
    return Future.error('No token found');
  }

  final url = Uri.parse("$_baseUrl/subscriptions/addPlan");

  final response = await http.post(
    url,
    headers: {
      ..._headers,
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({
      "Name": Name,
      "BagsperDay": bagsperDay,
      "MonthlyPrice": MonthlyPrice,
      "Description": Description,
    }),
  );
  print(response.body);
  return response;

}
// =================== view plans ===================
Future<List<dynamic>> viewPlans() async {
  final prefs = await SharedPreferences.getInstance();

  int? companyId = prefs.getInt('CompanyID');

  if (companyId == null) {
    throw Exception("CompanyID not found in SharedPreferences");
  }

  final url = Uri.parse(
    "$_baseUrl/subscriptions/viewPlans?CompanyID=$companyId",
  );

  final response = await http.get(
    url,
    headers: {
      ..._headers,
    },
  );

  if (response.statusCode == 200) {
    print("Plans JSON: ${response.body}");
    return jsonDecode(response.body) as List<dynamic>;
  } else {
    throw HttpException('Failed to load plans: ${response.body}');
  }
}

  //
  static Future<String> addZone({
    required int companyId,
    required String name,
    required String description,
    required Map<String, dynamic> geoJson,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/zones/addZone"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "CompanyID": companyId,
          "Name": name,
          "Description": description,
          "GeoJSON": geoJson,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return data["message"];
      } else {
        return data["message"] ?? "Error";
      }
    } catch (e) {
      return "Error: $e";
    }
  }
  //
  static Future<List<dynamic>> getZones(int companyId) async {
    try {
      final response = await http.get(
        Uri.parse("$_baseUrl/zones/viewCompanyZones?CompanyID=$companyId"),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
  // add bag
   static Future<Map<String, dynamic>> generateBags({
    required int userId,
    required int quantity,
    required String bagType,
    required double weightLimit,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    int? companyId = prefs.getInt('CompanyID');

    if (companyId == null) {
      return {"error": "CompanyID not found"};
    }

    final url = Uri.parse("$_baseUrl/bags/add");

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
      body: jsonEncode({
        "UserID": userId,
        "CompanyID": companyId,
        "Quantity": quantity,
        "BagType": bagType,
        "WeightLimit": weightLimit,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      return {
        "error": "Failed to generate bags: ${response.body}",
      };
    }
  }

 static Future<Map<String, dynamic>> generateBags1({
    required int userId,
    required int quantity,
    required String bagType,
    required double weightLimit,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    int? companyId = prefs.getInt('CompanyID');

    if (companyId == null) {
      return {"error": "CompanyID not found"};
    }

    final url = Uri.parse("$_baseUrl/bags/extra");

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
      body: jsonEncode({
        "UserID": userId,
        "CompanyID": companyId,
        "Quantity": quantity,
        "BagType": bagType,
        "WeightLimit": weightLimit,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      return {
        "error": "Failed to generate bags: ${response.body}",
      };
    }
  }

  // fetch subscribers
  Future<Map<String, dynamic>> fetchSubscribers() async {
  final prefs = await SharedPreferences.getInstance();
  final CompanyId = prefs.getInt('CompanyID'); 

  if (CompanyId == null) {
    throw Exception("CompanyID not found in SharedPreferences");
  }

  final url = Uri.parse("$_baseUrl/company/viewSubscribedUsers?CompanyID=$CompanyId");

  final response = await http.get(url, headers: _headers);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    return {
      "active": data["active"] ?? [],
      "inactive": data["inactive"] ?? [],
    };
  } else {
    throw Exception("Failed to load subscribers: ${response.body}");
  }
}
// fetch companies by vehicles
 static Future<List<dynamic>> getCompanyVehicles() async {
   final prefs = await SharedPreferences.getInstance();

  int? companyId = prefs.getInt('CompanyID');
    final response = await http.get(
      Uri.parse("$_baseUrl/vehicle/companyVehicles?CompanyID=$companyId"),
      headers: {
        "Content-Type": "application/json",
        "ngrok-skip-browser-warning": "true",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load vehicles");
    }
  }
  //view extra pickup requests
  static Future<Map<String, dynamic>> viewExtraPickupRequests() async {
  final prefs = await SharedPreferences.getInstance();
  int? companyId = prefs.getInt('CompanyID');

  final response = await http.get(
    Uri.parse("$_baseUrl/company/viewExtraRequests?CompanyID=$companyId "),
    headers: {
      "Content-Type": "application/json",
      "ngrok-skip-browser-warning": "true"
      ,
    },
  );

  final data = jsonDecode(response.body);

  if (response.statusCode == 200) {
    return {
      "requests": data["requests"],
    };
  } else {
    return {
      "error": data["message"] ?? "Something went wrong",
    };
  }
}

//add driver
 static Future<bool> addDriver({
    required String fullName,
    required String phone,
    required String license,
    required int vehicleId,
    required String password,
    required int collectorId,
   
  }) async {
    final prefs = await SharedPreferences.getInstance();
    int? companyId = prefs.getInt('CompanyID');
    final response = await http.post(
      Uri.parse("$_baseUrl/drivers/addDriver?CompanyID=$companyId"),
      headers: {
        "Content-Type": "application/json",
        "ngrok-skip-browser-warning": "true",
      },
      body: jsonEncode({
        "FullName": fullName,
        "Phone": phone,
        "LicenseNumber": license,
        "VehicleID": vehicleId,
        "Password": password,
        "CollectorID": collectorId,
      }),
    ); 
      print("ADD DRIVER RESPONSE: ${response.body}");

    return response.statusCode == 201;
  }
  //add vehicle
  static Future<bool> addVehicle({
  required String plateNumber,
  required String model,
  required String capacity,
}) async {
  final prefs = await SharedPreferences.getInstance();
  int? companyId = prefs.getInt('CompanyID');

  final response = await http.post(
    Uri.parse("$_baseUrl/vehicle/addVehicle?CompanyID=$companyId"),
    headers: {
      "Content-Type": "application/json",
      "ngrok-skip-browser-warning": "true",
    },
    body: jsonEncode({
      "PlateNumber": plateNumber,
      "Model": model,
      "Capacity": capacity,
    }),
  );

  print("ADD VEHICLE RESPONSE: ${response.body}");

  return response.statusCode == 201;
}
//view complaints
  static Future<Map<String, List>> getComplaints() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      int? companyId = prefs.getInt('CompanyID');
      final response =
          await http.get(Uri.parse("$_baseUrl/users/viewComplaints?CompanyID=$companyId"));

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);

        List resolved =
            data.where((c) => c['Status'] == 'Resolved').toList();

        List pending =
            data.where((c) => c['Status'] != 'Resolved').toList();

        return {
          "resolved": resolved,
          "pending": pending,
        };
      } else {
        throw Exception("Failed to load complaints");
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
  //view drivers with vehicles
  static Future<List> getDrivers() async {
    final prefs = await SharedPreferences.getInstance();
    int? companyId = prefs.getInt('CompanyID');
    final res = await http.get(
      Uri.parse('$_baseUrl/company/getDriversWithVehicles?CompanyID=$companyId'),
      headers: {
        "Content-Type": "application/json",
       
      },
    );
    print(res.body);
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Failed to load drivers");
    }
  }

  // ✅ Create Slot + Schedule (combined API)
  static Future<void> createSlot({
  required int zoneID,
  required String dayOfWeek,
  required String startTime,
  required String endTime,
  required int driverID,
}) async {
  final res = await http.post(
    Uri.parse('$_baseUrl/company/createSlot'),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "ZoneID": zoneID,
      "DayOfWeek": dayOfWeek,
      "StartTime": startTime,
      "EndTime": endTime,
      "DriverID": driverID
    }),
  );


  if (res.statusCode != 200) {
    throw Exception(jsonDecode(res.body)["message"]);
  }
}
//view schedules
static Future<List> getSchedules() async {
  final prefs = await SharedPreferences.getInstance();

  final raw = prefs.get("CompanyID");

  if (raw == null) {
    throw Exception("CompanyID not found in SharedPreferences");
  }

  int companyId = int.parse(raw.toString());

  final url = Uri.parse(
    "$_baseUrl/company/getCompanySchedule?CompanyID=$companyId"
  );

  final res = await http.get(
    url,
    headers: {"Content-Type": "application/json"},
  );

  print("STATUS: ${res.statusCode}");
  print("BODY: ${res.body}");

  if (res.statusCode == 200) {
    return jsonDecode(res.body);
  } else {
    throw Exception("Failed to load schedules: ${res.body}");
  }
}


//view drivers
 Future<http.Response> fetchDrivers() async {
    final url = Uri.parse("$_baseUrl/drivers/viewCompanyDrivers");
    String? token = await getToken();
    if (token == null) {
      print(token);
      return Future.error('No token found');
    }

    var res = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 200) {
      print(res.body);
      return res;
    } else {
      throw HttpException('Failed to load drivers: ${res.body}');
    }
  }
//get collector
Future<List<dynamic>> getCompanyCollectors() async {
  final prefs = await SharedPreferences.getInstance();
  final companyId = prefs.getInt('CompanyID') ?? 0;
  try {
    final response = await http.get(
      Uri.parse("$_baseUrl/collector/viewCollector?CompanyID=$companyId"),
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
}
