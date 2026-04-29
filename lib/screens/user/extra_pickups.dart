import 'package:flutter/material.dart';
import 'package:garbage_collection_system/Api/userController.dart';
import 'package:garbage_collection_system/custom_widgets/button.dart';
import 'package:garbage_collection_system/custom_widgets/inputfield.dart';

class ExtraPickups extends StatefulWidget {
  const ExtraPickups({super.key});

  @override
  State<ExtraPickups> createState() => _ExtraPickupsState();
}

class _ExtraPickupsState extends State<ExtraPickups> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController bagsController = TextEditingController();

  bool isSubmitting = false;

  @override
  void dispose() {
    bagsController.dispose();
    super.dispose();
  }

  // 🔥 SUBMIT REQUEST
  Future<void> submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSubmitting = true);

    bool success = await UserApi().requestExtraPickup(
      bags: int.parse(bagsController.text),
    );

    setState(() => isSubmitting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Request Submitted Successfully"),
          backgroundColor: Colors.green,
        ),
      );

      bagsController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to submit request"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Request Extra Pickups"),
        centerTitle: true,
        backgroundColor: const Color(0xFF99C13D),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              /// 🔹 Bags Input
              CustomInput(
                label: "Number of Bags",
                controller: bagsController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Enter number of bags";
                  }
                  if (int.tryParse(value) == null) {
                    return "Enter valid number";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 30),

              /// 🔹 Submit Button
              isSubmitting
                  ? const CircularProgressIndicator()
                  : CustomButton(
                      text: "Submit Request",
                      onPressed: submitRequest,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}