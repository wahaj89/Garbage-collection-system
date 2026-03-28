import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DriverApi{
  
   static const String _baseUrl =
      "https://pauseful-raymon-unilluminant.ngrok-free.dev/api";
     
     Future<int?> getId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('id');
  }
  Future <String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

      Future<http.Response> fetchDrivers() async {
    final url = Uri.parse("$_baseUrl/drivers/viewCompanyDrivers");
    String? token= await getToken();
       if (token == null) {
        print(token);
      return Future.error('No token found');

    }

    var res=await http.get(url,
  headers: {
  'Content-Type': 'application/json',
  'ngrok-skip-browser-warning': 'true',
  'Authorization': 'Bearer $token',
  
},);
      
    if (res.statusCode == 200) {
      print(res.body);
      return res;
    } else {
      throw HttpException('Failed to load drivers: ${res.body}');
    }

      }
}