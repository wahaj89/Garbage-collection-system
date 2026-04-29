import 'package:flutter/material.dart';
import 'package:garbage_collection_system/Api/CompanyController.dart';
import 'package:garbage_collection_system/custom_widgets/button.dart';
import 'package:garbage_collection_system/custom_widgets/inputfield.dart';

class AddVehicle extends StatefulWidget {
  const AddVehicle({super.key});

  @override
  State<AddVehicle> createState() => _AddVehicleState();
}

class _AddVehicleState extends State<AddVehicle> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController plateController = TextEditingController();
  TextEditingController modelController = TextEditingController();
  TextEditingController capacityController = TextEditingController();

  bool isLoading = false;

  /// 🔹 Submit Vehicle
  Future<void> submitVehicle() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final success = await CompanyApi.addVehicle(
        plateNumber: plateController.text.trim(),
        model: modelController.text.trim(),
        capacity: capacityController.text.trim(),
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Vehicle Added Successfully"),
            backgroundColor: Colors.green,
          ),
        );

        plateController.clear();
        modelController.clear();
        capacityController.clear();
      } else {
        throw Exception("Failed to add vehicle");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Center(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 50),

                  const Icon(
                    Icons.local_shipping,
                    size: 120,
                    color: Colors.blue,
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Add Vehicle",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// 🔹 Plate Number
                  SizedBox(
                    width: 370,
                    child: CustomInput(
                      label: "Plate Number",
                      controller: plateController,
                      suffixIcon: const Icon(Icons.confirmation_number),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Plate number is required";
                        }
                        return null;
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// 🔹 Model
                  SizedBox(
                    width: 370,
                    child: CustomInput(
                      label: "Model",
                      controller: modelController,
                      suffixIcon: const Icon(Icons.directions_car),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Model is required";
                        }
                        return null;
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// 🔹 Capacity
                  SizedBox(
                    width: 370,
                    child: CustomInput(
                      label: "Capacity (KG)",
                      controller: capacityController,
                      keyboardType: TextInputType.number,
                      suffixIcon: const Icon(Icons.scale),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Capacity is required";
                        }
                        return null;
                      },
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// 🔹 Button
                  isLoading
                      ? const CircularProgressIndicator()
                      : CustomButton(
                          text: "Add Vehicle",
                          icon: Icons.add,
                          onPressed: submitVehicle,
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