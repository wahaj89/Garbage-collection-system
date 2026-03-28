import 'package:flutter/material.dart';
import 'package:garbage_collection_system/custom_widgets/button.dart';
import 'package:garbage_collection_system/custom_widgets/inputfield.dart';

class AddDriver extends StatefulWidget {
  const AddDriver({super.key});

  @override
  State<AddDriver> createState() => _AddDriverState();
}

class _AddDriverState extends State<AddDriver> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController fullNameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController licenseController = TextEditingController();
  TextEditingController vehicleIdController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool isSubmitting = false;

  Future<void> submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSubmitting = true);

    await Future.delayed(const Duration(seconds: 1));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Driver Added Successfully"),
        backgroundColor: Colors.green,
      ),
    );

    setState(() => isSubmitting = false);

    fullNameController.clear();
    phoneController.clear();
    licenseController.clear();
    vehicleIdController.clear();
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
                  const SizedBox(height: 40),

                  Image.asset(
                    'assets/app_icon.jpg',
                    width: 200,
                    height: 200,
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Add Driver",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// 🔹 Full Name
                  SizedBox(
                    width: 370,
                    child: CustomInput(
                      label: "Full Name",
                      controller: fullNameController,
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

                  /// 🔹 License Number
                  SizedBox(
                    width: 370,
                    child: CustomInput(
                      label: "License Number",
                      controller: licenseController,
                      suffixIcon: const Icon(Icons.badge),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "License number required";
                        }
                        return null;
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// 🔹 Vehicle ID
                  SizedBox(
                    width: 370,
                    child: CustomInput(
                      label: "Vehicle ID",
                      controller: vehicleIdController,
                      keyboardType: TextInputType.number,
                      suffixIcon: const Icon(Icons.local_shipping),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Vehicle ID required";
                        }
                        return null;
                      },
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
                          return "Password is required";
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 25),

                  isSubmitting
                      ? const CircularProgressIndicator()
                      : CustomButton(
                          text: "Add Driver",
                          icon: Icons.person_add,
                          onPressed: submitForm,
                        ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}