import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserApi {
  static const String _baseUrl = "https://pauseful-raymon-unilluminant.ngrok-free.dev/api";
   Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<http.Response> login(
    String email,
    String password,
    
  ) async {
    final url = Uri.parse("$_baseUrl/users/login");
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'Email': email,      
        'Password': password
      }),
    );


    if (response.statusCode == 200) {
      return response;
    } else {
      final error = jsonDecode(response.body);
      throw HttpException(error['message'] ?? 'Login failed');
    }
  }
  
  static Future<http.Response> signup(
    String fullName,
    String email,
    String phone,
    String latlng,
    String password,
  ) async {
    final url = Uri.parse("$_baseUrl/users/register");

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "FullName": fullName,
        "Email": email,
        "Phone": phone,
        "latlng": latlng,
        "Password": password,
      }),
    );

    return response;
  }
  
  Future<http.Response> fetchSubscribedUsers() async {
    final url = Uri.parse("$_baseUrl/users/viewSubscribedUsers");
    final token = await getToken();
    print(token);
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return response;
    } else {
      throw HttpException('Failed to load users: ${response.body}');
    }
  }
  //subscription status
  Future<http.Response> checkSubscriptionStatus() async {
    final url = Uri.parse("$_baseUrl/users/isSubscribed");
    final token = await getToken();

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return response;
    } else {
      throw HttpException('Failed to check subscription status: ${response.body}');
    }
  }

  // subscription details
  Future<http.Response> fetchSubscriptionDetails() async {
    final url = Uri.parse("$_baseUrl/users/viewstatus");
    final token = await getToken();

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return response;
    } else {
      throw HttpException('Failed to fetch subscription details: ${response.body}');
    }
  }
  //get user details
  Future<http.Response> fetchUserDetails() async {
    final url = Uri.parse("$_baseUrl/users/userInfo");
    final token = await getToken();

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return response;
    } else {
      throw HttpException('Failed to fetch user details: ${response.body}');
    }
}
//cancel subscription
Future<Map<String, dynamic>> cancelSubscription({
  required int SubscriptionID,
  required int CompanyID,
}) async {
  final token = await getToken();
  final url = Uri.parse('$_baseUrl/subscriptions/cancelSubscription');

  final response = await http.post(
    url,
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
      'ngrok-skip-browser-warning': 'true',
    },
    body: jsonEncode({
      "SubscriptionID": SubscriptionID,
      "CompanyID": CompanyID,
    }),
  );

  print("STATUS: ${response.statusCode}");
  print("BODY: ${response.body}");

  try {
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Failed to cancel subscription');
    }
  } catch (e) {
    throw Exception("Invalid JSON response: ${response.body}");
  }
}
//get company by location
Future<List<dynamic>> getCompaniesByLocation() async {
  final token = await getToken();
  print("TOKEN: $token");

  final response = await http.get(
    Uri.parse('$_baseUrl/users/getCompaniesByLocation'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  print("STATUS CODE: ${response.statusCode}");
  print("RESPONSE BODY: ${response.body}");

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['data'] ?? [];
  } else {
    throw Exception('Failed: ${response.body}');
  }
}
//get company by id
Future<String?> getUserCompany() async {
  try {
    final token = await getToken();
    final response = await http.get(
      Uri.parse("$_baseUrl/users/getUserCompany"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token", // 👈 agar JWT use ho raha hai
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return data["CompanyID"].toString();
    } 
    else if (response.statusCode == 404) {
      print("No subscription found");
      return null;
    } 
    else {
      print("Error: ${response.body}");
      return null;
    }

  } catch (e) {
    print("Exception: $e");
    return null;
  }
}
//submit complaint
  Future<bool> submitComplaint({
  required String subject,
  required String description,
}) async {
  final url = Uri.parse("$_baseUrl/users/submitComplaint");
  final  token = await getToken();
  final response = await http.post(
    url,
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    },
    body: jsonEncode({
      "Subject": subject,
      "Description": description,
    }),
  );

  return response.statusCode == 200;
}
//request extra pickup
Future<bool> requestExtraPickup({
  required int bags,
}) async {
  final token = await getToken();

  final response = await http.post(
    Uri.parse("$_baseUrl/users/requestExtraPickup"),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    },
    body: jsonEncode({
      "BagsRequested": bags,
    }),
  );

  return response.statusCode == 200;
}
//

  Future<List<dynamic>> getPastPickups()async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse("$_baseUrl/users/getUserPickups"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["pickups"];
    } else {
      throw Exception("Failed to load pickups");
    }
  }
}

