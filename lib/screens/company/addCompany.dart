import 'package:flutter/material.dart';
import 'package:garbage_collection_system/Api/CompanyController.dart';
import 'package:garbage_collection_system/custom_widgets/button.dart';
import 'package:garbage_collection_system/custom_widgets/inputfield.dart';

import 'package:garbage_collection_system/screens/company/companyLogin.dart';

class Addcompany extends StatefulWidget {
  const Addcompany({super.key});

  @override
  State<Addcompany> createState() => _AddcompanyState();
}

class _AddcompanyState extends State<Addcompany> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController regNoController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Future<void> registerCompany() async {
    if (!_formKey.currentState!.validate()) return;

    var res = await CompanyApi().addCompany(
      nameController.text.trim(),
      emailController.text.trim(),
      phoneController.text.trim(),
      addressController.text.trim(),
      regNoController.text.trim(),
      passwordController.text.trim(),
    );

    if (res.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Company registered successfully waiting for approval"),
          backgroundColor: Colors.green,
        ),
      );
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Loginscreen()),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to register company"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Image.asset(
                  'assets/app_icon.jpg',
                  height: 250,
                  width: 250,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 20),

                /// Company Name
                SizedBox(
                  width: 370,
                  child: CustomInput(
                    label: "Company Name",
                    controller: nameController,
                    suffixIcon: const Icon(Icons.business),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Company Name is required";
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 10),

                /// Email
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
                const SizedBox(height: 10),

                /// Phone
                SizedBox(
                  width: 370,
                  child: CustomInput(
                    label: "Phone",
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    suffixIcon: const Icon(Icons.phone),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Phone number is required";
                      }
                      if (value.length < 10) {
                        return "Enter valid phone number";
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 10),

                /// Address
                SizedBox(
                  width: 370,
                  child: CustomInput(
                    label: "Address",
                    controller: addressController,
                    suffixIcon: const Icon(Icons.location_on),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Address is required";
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 10),

                /// Registration Number
                SizedBox(
                  width: 370,
                  child: CustomInput(
                    label: "Registration Number",
                    controller: regNoController,
                    suffixIcon: const Icon(Icons.confirmation_number),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Registration Number is required";
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 20),

                /// Registration Number
                SizedBox(
                  width: 370,
                  child: CustomInput(
                    label: "Password",
                    controller: passwordController,
                    suffixIcon: const Icon(Icons.lock),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Password is required";
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
                const SizedBox(height: 20),

                /// Register Button
                CustomButton(text: "Register", onPressed: registerCompany),
                 Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have a company? "),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder:  (_) => const Loginscreen()));
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
    );
  }
}
