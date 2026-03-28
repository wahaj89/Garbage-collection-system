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
    String address,
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
        "Address": address,
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
}