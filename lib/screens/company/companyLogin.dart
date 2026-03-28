import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:garbage_collection_system/Api/CompanyController.dart';
import 'package:garbage_collection_system/custom_widgets/button.dart';
import 'package:garbage_collection_system/custom_widgets/inputfield.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  bool isValidEmail(String email) {
    return RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    ).hasMatch(email);
  }

  Future<void> loginCompany() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => isLoading = true);

  try {
    final res = await CompanyApi().login(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    final data = jsonDecode(res.body);


  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('token', data['token']);
  print("Token saved: ${prefs.getString('token')}");

   
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(data['message'] ?? "Login Successful"),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pushReplacementNamed(context, '/companyDashboard');

  } catch (e) {
    print("Login Error: $e"); // 🔥 important
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Login Failed"),
        backgroundColor: Colors.red,
      ),
    );
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/app_icon.jpg', width: 200),

                const SizedBox(height: 20),

                const Text(
                  'Login',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 20),

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

                const SizedBox(height: 15),

          
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

                const SizedBox(height: 25),

                isLoading
                    ? const CircularProgressIndicator()
                    : CustomButton(
                        text: "Login",
                        onPressed: loginCompany,
                      ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have a Company? "),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/addCompany');
                      },
                      child: const Text(
                        'Register Here',
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
    );
  }
}