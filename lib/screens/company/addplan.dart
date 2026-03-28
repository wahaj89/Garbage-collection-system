import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:garbage_collection_system/Api/CompanyController.dart';
import 'package:garbage_collection_system/custom_widgets/button.dart';
import 'package:garbage_collection_system/custom_widgets/inputfield.dart';


class Addplan extends StatefulWidget {
  const Addplan({super.key});

  @override
  State<Addplan> createState() => _AddplanState();
}

class _AddplanState extends State<Addplan> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController planNameController = TextEditingController();
  final TextEditingController bagsPerDayController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    planNameController.dispose();
    bagsPerDayController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await CompanyApi().addPlan(
        planNameController.text.trim(),
        int.parse(bagsPerDayController.text.trim()),
        priceController.text.trim(),
        descriptionController.text.trim(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Success
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Plan added successfully ")),
        );
        _formKey.currentState!.reset();
      } else {
        // Server returned an error
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              data['message'] ?? 'Failed to add plan ',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Plan"),
        backgroundColor: const Color(0xFF99C13D),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 30),
                const Center(
                  child: Text(
                    "Add New Plan",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                CustomInput(
                  label: "Plan Name",
                  controller: planNameController,
                  suffixIcon: const Icon(Icons.edit_outlined),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Plan name is required";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 25),

                CustomInput(
                  label: "Bags Per Day",
                  controller: bagsPerDayController,
                  keyboardType: TextInputType.number,
                  suffixIcon: const Icon(Icons.add_box_outlined),
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Enter number of bags";
                
                    if (int.parse(value) <= 0) return "Must be greater than 0";
                    return null;
                  },
                ),
                const SizedBox(height: 25),

                CustomInput(
                  label: "Price",
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  suffixIcon: const Icon(Icons.attach_money_outlined),
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Price is required";
                    if (double.tryParse(value) == null) return "Enter valid price";
                    if (double.parse(value) <= 0) return "Price must be greater than 0";
                    return null;
                  },
                ),
                const SizedBox(height: 25),

                CustomInput(
                  label: "Description",
                  controller: descriptionController,
                  suffixIcon: const Icon(Icons.description_outlined),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return "Description is required";
                    if (value.length < 10) return "Minimum 10 characters required";
                    return null;
                  },
                ),
                const SizedBox(height: 40),

                _isLoading
                    ? const CircularProgressIndicator()
                    : CustomButton(
                        text: "Add Plan",
                        onPressed: _submitForm,
                      ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}