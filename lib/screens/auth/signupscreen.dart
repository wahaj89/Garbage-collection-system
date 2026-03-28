// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:garbage_collection_system/Api/userController.dart';
import 'package:garbage_collection_system/screens/maps/mapscreen.dart';
import 'package:garbage_collection_system/custom_widgets/button.dart';
import 'package:garbage_collection_system/custom_widgets/inputfield.dart';

class Signupscreen extends StatefulWidget {
  const Signupscreen({super.key});

  @override
  State<Signupscreen> createState() => _SignupscreenState();
}

class _SignupscreenState extends State<Signupscreen> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  double? selectedLat;
  double? selectedLng;

  Future<void> signupUser() async {
  
    if (!_formKey.currentState!.validate()) return;

    if (selectedLat == null || selectedLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select your location on map"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final res = await UserApi.signup(
        nameController.text.trim(),
        emailController.text.trim(),
        phoneController.text.trim(),
        addressController.text.trim(),
        passwordController.text.trim(),
      );

      final data = jsonDecode(res.body);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(data['message']),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Signup Failed"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  bool isValidEmail(String email) {
    return RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    ).hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Image.asset('assets/app_icon.jpg', width: 250, height: 250),
                  const SizedBox(height: 10),
                  const Text(
                    'Sign Up',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  /// 🔹 Full Name
                  SizedBox(
                    width: 370,
                    child: CustomInput(
                      label: "Full Name",
                      controller: nameController,
                      suffixIcon: const Icon(Icons.person),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Full name is required";
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  /// 🔹 Email
                  SizedBox(
                    width: 370,
                    child: CustomInput(
                      label: "Email",
                      controller: emailController,
                      suffixIcon: const Icon(Icons.email),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Email is required";
                        }
                        if (!isValidEmail(value)) {
                          return "Enter valid email";
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  /// 🔹 Phone
                  SizedBox(
                    width: 370,
                    child: CustomInput(
                      label: "Phone Number",
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      suffixIcon: const Icon(Icons.phone),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Phone number required";
                        }
                        if (value.length < 11) {
                          return "Enter valid phone number";
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  /// 🔹 Address (Pick Lat/Lng from Map)
                  SizedBox(
                    width: 370,
                    child: CustomInput(
                      label: "Location (Lat, Lng)",
                      controller: addressController,
                      button: CustomButton(
                        text: "Pin on Map",
                        icon: Icons.location_on,
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MapScreen(),
                            ),
                          );

                          if (result != null) {
                            setState(() {
                              selectedLat = result['latitude'];
                              selectedLng = result['longitude'];
                              addressController.text =
                                  "${selectedLat!.toStringAsFixed(6)}, ${selectedLng!.toStringAsFixed(6)}";
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

          
                  SizedBox(
                    width: 370,
                    child: CustomInput(
                      label: "Password",
                      controller: passwordController,
                      obscureText: true,
                      
                      suffixIcon: const Icon(Icons.lock),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Password required";
                        }
                        if (value.length < 6) {
                          return "Minimum 6 characters";
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                   SizedBox(
                  width: 370,
                  child: CustomInput(
                    label: "Confirm password",
                    controller: confirmPasswordController,
                    suffixIcon: const Icon(Icons.lock),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Confirm password is required";
                      }
                      if (value != passwordController.text) {
                        return "Passwords do not match";
                      }
                      return null;
                    },
                  ),
                ),
                  const SizedBox(height: 15),
                  CustomButton(
                    text: "Signup",
                    onPressed: signupUser,
                  ),
                  const SizedBox(height: 15),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account? "),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        child: const Text(
                          'Login',
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