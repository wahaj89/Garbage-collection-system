import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:garbage_collection_system/Api/collectorcontroller.dart';
import 'package:garbage_collection_system/Api/driver_contoller.dart';
import 'package:garbage_collection_system/Api/userController.dart';
import 'package:garbage_collection_system/custom_widgets/button.dart';
import 'package:garbage_collection_system/custom_widgets/inputfield.dart';
import 'package:garbage_collection_system/screens/user/newuserdashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class Loginscreen extends StatefulWidget {
  const Loginscreen({super.key});

  @override
  State<Loginscreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  // ✅ Role Dropdown
  String selectedRole = 'User';
  final List<String> roles = ['User', 'Driver', 'Collector'];

  

  Future <void> loginUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      dynamic res;

      // ✅ ROLE BASED API CALL
      if (selectedRole == 'Driver') {
        res = await DriverApi.loginDriver(
          emailController.text.trim(),
          passwordController.text.trim(),
        );
      } 
      else if (selectedRole == 'Collector') {
         res = await CollectorApi.loginCollector(
           emailController.text.trim(),
           passwordController.text.trim(),
         );
      } 
      else {
        res = await UserApi.login(
          emailController.text.trim(),
          passwordController.text.trim(),
        );
      }

      final data = res;

      // =========================
      // ✅ USER LOGIN (WITH TOKEN)
      // =========================
      if (selectedRole == 'User') {
        final data = jsonDecode(res.body);
        final String token = data['token'] ?? "";

        if (token.isEmpty) {
          throw Exception("Token missing from response");
        }

        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);

        final String userName = decodedToken['UserName'] ?? "Unknown";
        final int userId = decodedToken['UserId'] ?? 0;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('UserName', userName);
        await prefs.setInt('UserId', userId);
      }

      // =========================
      //  DRIVER / COLLECTOR (NO TOKEN)
      // =========================
      else {
        final userData = data['driver'] ?? data['collector'];

        if (userData == null) {
          throw Exception("Invalid response from server");
        }

        final int id = userData['DriverID'] ??
            userData['CollectorID'] ??
            0;

        final String name = userData['FullName'] ?? "Unknown";
        final String phone = userData['Phone'] ?? "N/A";
        final String license = userData['LicenseNo'] ?? "N/A";


        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('UserId', id);
        await prefs.setString('UserName', name);
        await prefs.setString('UserPhone', phone);
        await prefs.setString('LicenseNo', license);
       

        await prefs.setString('role', selectedRole);
      }

      // =========================
      // ✅ SUCCESS MESSAGE
      // =========================
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Login Successful"),
          backgroundColor: Colors.green,
        ),
      );

      if (!mounted) return;

      // =========================
      // ✅ NAVIGATION
      // =========================
      if (selectedRole == 'Driver') {
        Navigator.pushReplacementNamed(context, '/driverDashboard');
      } 
      else if (selectedRole == 'Collector') {
        Navigator.pushReplacementNamed(context, '/collectorDashboard');
      } 
      else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Newuserdashboard(),
          ),
        );
      }

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Login Failed: $e"),
          backgroundColor: Colors.red,
        ),
      );
      print("Login error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Center(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/app_icon.jpg', width: 200),
                  const SizedBox(height: 20),
              
                  const Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              
                  const SizedBox(height: 20),
              
                  // ✅ Email
                  SizedBox(
                    width: 370,
                    child: CustomInput(
                      label: "Email or Phone",
                      controller: emailController,
                      suffixIcon: const Icon(Icons.email),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Email is required";
                        }
                    
                      },
                    ),
                  ),
              
                  const SizedBox(height: 15),
              
                  // ✅ Password
                  SizedBox(
                    width: 370,
                    child: CustomInput(
                      label: "Password",
                      controller: passwordController,
                      obscureText: true,
                      suffixIcon: const Icon(Icons.lock),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Password is required";
                        }
                        if (value.length < 6) {
                          return "Minimum 6 characters";
                        }
                        return null;
                      },
                    ),
                  ),
              
                  const SizedBox(height: 15),
              
                  // ✅ Role Dropdown
                  SizedBox(
                    width: 370,
                    child: DropdownButtonFormField<String>(
                      value: selectedRole,
                      decoration: const InputDecoration(
                        labelText: "Select Role",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFD0E5FF),
                      ),
                      items: roles.map((role) {
                        return DropdownMenuItem(
                          value: role,
                          child: Text(role),
                          
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedRole = value!;
                        });
                      },
                    ),
                  ),
              
                  const SizedBox(height: 25),
              
                  // ✅ Button / Loader
                  isLoading
                      ? const CircularProgressIndicator()
                      : CustomButton(
                          text: "Login",
                          onPressed: loginUser,
                        ),
              
                  const SizedBox(height: 20),
              
                  // ✅ Signup
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account? "),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/signup');
                        },
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}