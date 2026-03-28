import 'package:flutter/material.dart';
import 'package:garbage_collection_system/custom_widgets/button.dart';
import 'package:garbage_collection_system/custom_widgets/inputfield.dart';

class Fileacomplaint extends StatefulWidget {
  const Fileacomplaint({super.key});

  @override
  State<Fileacomplaint> createState() => _FileacomplaintState();
}

class _FileacomplaintState extends State<Fileacomplaint> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController companyIdController = TextEditingController();
  TextEditingController subjectController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  bool isSubmitting = false;

  Future<void> submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSubmitting = true);

    await Future.delayed(const Duration(seconds: 1));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Complaint Submitted Successfully"),
        backgroundColor: Colors.green,
      ),
    );

    setState(() => isSubmitting = false);

    companyIdController.clear();
    subjectController.clear();
    descriptionController.clear();
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
                    "File a Complaint",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// 🔹 Company ID
                  SizedBox(
                    width: 370,
                    child: CustomInput(
                      label: "Company ID",
                      controller: companyIdController,
                      keyboardType: TextInputType.number,
                      suffixIcon: const Icon(Icons.business),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Company ID is required";
                        }
                        return null;
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// 🔹 Subject
                  SizedBox(
                    width: 370,
                    child: CustomInput(
                      label: "Subject",
                      controller: subjectController,
                      suffixIcon: const Icon(Icons.subject),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Subject is required";
                        }
                        if (value.length < 5) {
                          return "Minimum 5 characters required";
                        }
                        return null;
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// 🔹 Description
                  SizedBox(
                    width: 370,
                    child: CustomInput(
                      label: "Description",
                      controller: descriptionController,
            
                      suffixIcon: const Icon(Icons.description),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Description is required";
                        }
                        if (value.length < 10) {
                          return "Minimum 10 characters required";
                        }
                        return null;
                      },
                    ),
                  ),

                  const SizedBox(height: 25),

                  isSubmitting
                      ? const CircularProgressIndicator()
                      : CustomButton(
                          text: "Submit Complaint",
                          icon: Icons.report_problem,
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