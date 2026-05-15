import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:garbage_collection_system/Api/ip.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserApi {
  static final String _baseUrl = Ip.baseUrl;

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
  //
  Future<http.Response> loginadmin(String email, String password) async {
    final url = Uri.parse("$_baseUrl/users/loginadmin");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "Email": email,
        "Password": password,
      }),
    );

    return response;
  }

  Future<List> getPendingCompanies() async {
    final url = Uri.parse("$_baseUrl/users/pendingCompanies");

    final response = await http.get(url);

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (data is List) {
        return data;
      }

      if (data['companies'] != null) {
        return data['companies'];
      }

      if (data['pendingCompanies'] != null) {
        return data['pendingCompanies'];
      }

      return [];
    } else {
      throw Exception(data['message'] ?? "Failed to load companies");
    }
  }

  Future<String> approveCompany(int companyId) async {
    final url = Uri.parse("$_baseUrl/users/approveCompany/$companyId");

    final response = await http.put(url);

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data['message'] ?? "Company approved successfully";
    } else {
      throw Exception(data['message'] ?? "Failed to approve company");
    }
  }

  Future<String> rejectCompany(int companyId) async {
    final url = Uri.parse("$_baseUrl/users/rejectCompany/$companyId");

    final response = await http.put(url);

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data['message'] ?? "Company rejected successfully";
    } else {
      throw Exception(data['message'] ?? "Failed to reject company");
    }
  }

  // =========================================================
  // LOGIN
  // =========================================================
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
        'Password': password,
      }),
    );

    print(response.body);

    if (response.statusCode == 200) {
      return response;
    } else {
      final error = jsonDecode(response.body);
      throw HttpException(error['message'] ?? 'Login failed');
    }
  }

  // =========================================================
  // SIGNUP
  // =========================================================
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

  // =========================================================
  // VIEW SUBSCRIBED USERS
  // =========================================================
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

  // =========================================================
  // CHECK SUBSCRIPTION STATUS
  // =========================================================
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
      throw HttpException(
        'Failed to check subscription status: ${response.body}',
      );
    }
  }

  // =========================================================
  // SUBSCRIPTION DETAILS - MULTIPLE SUBSCRIPTIONS
  // =========================================================
  Future<List<Map<String, dynamic>>> fetchSubscriptionDetails() async {
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
      final data = jsonDecode(response.body);

      if (data is Map && data['subscriptions'] is List) {
        return List<Map<String, dynamic>>.from(
          data['subscriptions'].map(
            (item) => Map<String, dynamic>.from(item),
          ),
        );
      }

      if (data is List) {
        return List<Map<String, dynamic>>.from(
          data.map(
            (item) => Map<String, dynamic>.from(item),
          ),
        );
      }

      if (data is Map<String, dynamic>) {
        return [data];
      }

      return [];
    }

    if (response.statusCode == 404) {
      return [];
    }

    throw Exception("Failed to fetch subscription details: ${response.body}");
  }

  // =========================================================
  // GET USER DETAILS
  // =========================================================
  Future<http.Response> fetchUserDetails() async {
    final token = await getToken();

    final response = await http.get(
      Uri.parse("$_baseUrl/users/userInfo"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    return response;
  }

  // =========================================================
  // CANCEL SUBSCRIPTION
  // =========================================================
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

  // =========================================================
  // GET COMPANIES BY LOCATION
  // =========================================================
 Future<List<dynamic>> getCompaniesByLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final token = prefs.getString('token') ??
          prefs.getString('Token') ??
          prefs.getString('authToken') ??
          '';

      final response = await http.get(
        Uri.parse('$_baseUrl/users/getCompaniesByLocation'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (decoded is Map && decoded['data'] is List) {
          return decoded['data'];
        }

        if (decoded is List) {
          return decoded;
        }

        return [];
      } else {
        throw Exception(decoded['message'] ?? 'Failed to load companies');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
  // =========================================================
  // GET USER COMPANY
  // =========================================================
  Future<String?> getUserCompany() async {
    try {
      final token = await getToken();

      final response = await http.get(
        Uri.parse("$_baseUrl/users/getUserCompany"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
          'ngrok-skip-browser-warning': 'true',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["CompanyID"].toString();
      } else if (response.statusCode == 404) {
        print("No subscription found");
        return null;
      } else {
        print("Error: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Exception: $e");
      return null;
    }
  }

  // =========================================================
  // SUBMIT COMPLAINT - OLD SIMPLE METHOD
  // =========================================================
  Future<bool> submitComplaint({
    required String subject,
    required String description,
  }) async {
    final url = Uri.parse("$_baseUrl/users/submitComplaint");
    final token = await getToken();

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
        'ngrok-skip-browser-warning': 'true',
      },
      body: jsonEncode({
        "Subject": subject,
        "Description": description,
      }),
    );

    return response.statusCode == 200;
  }

Future<bool> requestExtraPickup({
  required int companyId,
  required int bags,
  required String requestedFor,
}) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final response = await http.post(
      Uri.parse("$_baseUrl/users/requestExtraPickup"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "CompanyID": companyId,
        "BagsRequested": bags,
        "Requestedfor": requestedFor,
      }),
    );

    print("Extra Pickup Status: ${response.statusCode}");
    print("Extra Pickup Body: ${response.body}");

    return response.statusCode == 200 || response.statusCode == 201;
  } catch (e) {
    print("requestExtraPickup error: $e");
    return false;
  }
}
Future<List<dynamic>> getMyExtraPickupRequests() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final response = await http.get(
      Uri.parse("$_baseUrl/users/getMyExtraPickupRequests"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    print("Get Extra Requests Status: ${response.statusCode}");
    print("Get Extra Requests Body: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is List) {
        return data;
      }

      if (data is Map && data['recordset'] is List) {
        return data['recordset'];
      }

      return [];
    }

    return [];
  } catch (e) {
    print("getMyExtraPickupRequests error: $e");
    return [];
  }
}
  // =========================================================
  // GET PAST PICKUPS
  // =========================================================
  Future<List<dynamic>> getPastPickups() async {
    final token = await getToken();

    final response = await http.get(
      Uri.parse("$_baseUrl/users/getUserPickups"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
        'ngrok-skip-browser-warning': 'true',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["pickups"] ?? [];
    } else {
      throw Exception("Failed to load pickups");
    }
  }

  // =========================================================
  // TRACK DRIVER LIVE LOCATION
  // =========================================================
  static Future<Map<String, dynamic>?> getDriverLiveLocation() async {
    try {
      final token = await UserApi().getToken();

      final response = await http.get(
        Uri.parse("$_baseUrl/users/getDriverLiveLocation"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
          'ngrok-skip-browser-warning': 'true',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        print("API ERROR: ${data["message"]}");
        return null;
      }
    } catch (e) {
      print("API EXCEPTION: $e");
      return null;
    }
  }

  // =========================================================
  // GET SCHEDULED PICKUP - ONLY SECOND API / SUBSCRIPTION BASED
  // =========================================================
  Future<Map<String, dynamic>> getScheduledPickup() async {
    final url = Uri.parse("$_baseUrl/users/getScheduledPickup");
    final token = await getToken();

    if (token == null || token.isEmpty) {
      return {
        "pickup": null,
        "pickups": [],
        "message": "Token not found. Please login again.",
      };
    }

    final headers = {
      'Content-Type': 'application/json',
      'ngrok-skip-browser-warning': 'true',
      'Authorization': 'Bearer $token',
      'Connection': 'close',
    };

    Future<http.Response> callApiOnce() async {
      final client = http.Client();

      try {
        return await client
            .get(
              url,
              headers: headers,
            )
            .timeout(const Duration(seconds: 20));
      } finally {
        client.close();
      }
    }

    for (int attempt = 1; attempt <= 3; attempt++) {
      try {
        final response = await callApiOnce();

        print("SCHEDULE API URL: $url");
        print("SCHEDULE STATUS: ${response.statusCode}");
        print("SCHEDULE BODY: ${response.body}");

        Map<String, dynamic> data = {};

        try {
          final decoded = jsonDecode(response.body);

          if (decoded is Map<String, dynamic>) {
            data = decoded;
          }
        } catch (e) {
          return {
            "pickup": null,
            "pickups": [],
            "message": "Invalid JSON response from server",
            "error": response.body,
          };
        }

        if (response.statusCode == 200) {
          final List pickups = data["pickups"] ?? [];

          return {
            "pickup": data["pickup"] ?? (pickups.isNotEmpty ? pickups[0] : null),
            "pickups": pickups,
            "message": data["message"] ?? "Scheduled pickup loaded successfully",
            "debug": data["debug"],
          };
        }

        if (response.statusCode == 404) {
          return {
            "pickup": null,
            "pickups": [],
            "message": data["message"] ?? "No pickup scheduled",
            "debug": data["debug"],
          };
        }

        if (response.statusCode == 401) {
          return {
            "pickup": null,
            "pickups": [],
            "message": data["message"] ?? "Unauthorized. Please login again.",
          };
        }

        return {
          "pickup": null,
          "pickups": [],
          "message": data["message"] ??
              "Scheduled pickup API failed: ${response.statusCode}",
          "error": data["error"],
        };
      } on SocketException catch (e) {
        print("Socket error attempt $attempt: $e");

        if (attempt == 3) {
          return {
            "pickup": null,
            "pickups": [],
            "message": "Network error. Please try again.",
          };
        }

        await Future.delayed(Duration(seconds: attempt));
      } on TimeoutException catch (e) {
        print("Timeout attempt $attempt: $e");

        if (attempt == 3) {
          return {
            "pickup": null,
            "pickups": [],
            "message": "Request timeout. Please try again.",
          };
        }

        await Future.delayed(Duration(seconds: attempt));
      } on http.ClientException catch (e) {
        print("Client error attempt $attempt: $e");

        if (attempt == 3) {
          return {
            "pickup": null,
            "pickups": [],
            "message": "Connection failed. Please try again.",
          };
        }

        await Future.delayed(Duration(seconds: attempt));
      } catch (e) {
        print("Pickup API unknown error attempt $attempt: $e");

        if (attempt == 3) {
          return {
            "pickup": null,
            "pickups": [],
            "message": "Something went wrong.",
            "error": e.toString(),
          };
        }

        await Future.delayed(Duration(seconds: attempt));
      }
    }

    return {
      "pickup": null,
      "pickups": [],
      "message": "Failed to load pickup",
    };
  }

  // =========================================================
  // GET USER LOCATION
  // =========================================================
  static Future<Map<String, dynamic>?> getUserLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final int? userId = prefs.getInt('UserId');

      if (userId == null) {
        print("User ID not found");
        return null;
      }

      final response = await http.get(
        Uri.parse("$_baseUrl/users/getUserLocation?UserID=$userId"),
        headers: {
          "Content-Type": "application/json",
          'ngrok-skip-browser-warning': 'true',
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded['data'];
      } else {
        print("User location error: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Get user location error: $e");
      return null;
    }
  }

  // =========================================================
  // RATE COMPANY
  // =========================================================
  Future<Map<String, dynamic>> rateCompany({
    required int rating,
    required String review,
  }) async {
    final pref = await SharedPreferences.getInstance();
    final int? userId = pref.getInt("UserId");

    if (userId == null) {
      throw Exception("User ID not found. Please login again.");
    }

    final url = Uri.parse("$_baseUrl/users/rateCompany?UserID=$userId");

    print("Rating API URL: $url");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        'ngrok-skip-browser-warning': 'true',
      },
      body: jsonEncode({
        "Rating": rating,
        "Review": review,
      }),
    );

    print("Rating API status: ${response.statusCode}");
    print("Rating API body: ${response.body}");

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return data;
    } else {
      throw Exception(data["message"] ?? "Failed to submit rating");
    }
  }

  // =========================================================
  // GET USER SUBSCRIBED COMPANIES
  // =========================================================
  Future<List<Map<String, dynamic>>> getUserSubscribedCompanies() async {
    try {
      final pref = await SharedPreferences.getInstance();
      final int? userId = pref.getInt("UserId");

      if (userId == null) {
        throw Exception("User ID not found. Please login again.");
      }

      final response = await http.get(
        Uri.parse("$_baseUrl/users/getUserSubscribedCompanies?UserID=$userId"),
        headers: {
          "Content-Type": "application/json",
          'ngrok-skip-browser-warning': 'true',
        },
      );

      final data = jsonDecode(response.body);

      print(response.body);

      if (response.statusCode == 200) {
        final List companies = data["companies"] ?? [];

        return companies
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      } else {
        throw Exception(data["message"] ?? "Failed to load companies");
      }
    } catch (e) {
      throw Exception("Company API error: $e");
    }
  }

  // =========================================================
  // SUBMIT COMPLAINT - UPDATED METHOD
  // =========================================================
  Future<bool> submitComplaint1({
    required int companyId,
    required String subject,
    required String description,
    required String against,
  }) async {
    try {
      final pref = await SharedPreferences.getInstance();
      final int? userId = pref.getInt("UserId");

      if (userId == null) {
        print("User ID not found");
        return false;
      }

      final response = await http.post(
        Uri.parse("$_baseUrl/users/submitComplaint?UserID=$userId"),
        headers: {
          "Content-Type": "application/json",
          'ngrok-skip-browser-warning': 'true',
        },
        body: jsonEncode({
          "CompanyID": companyId,
          "Subject": subject,
          "Description": description,
          "against": against,
        }),
      );

      print(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print("Complaint submit failed: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Complaint API error: $e");
      return false;
    }
  }
}