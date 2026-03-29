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
  // fetch subscribers
   Future<List<dynamic>> fetchSubscribers() async {
    final prefs = await SharedPreferences.getInstance();
    final CompanyId = prefs.getInt('CompanyID'); 

    if (CompanyId == null) {
      throw Exception("CompanyID not found in SharedPreferences");
    }

    final url = Uri.parse("$_baseUrl/company/viewSubscribedUsers?CompanyID=$CompanyId");

    final response = await http.get(url, headers: _headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception("Failed to load subscribers: ${response.body}");
    }
  }

}
