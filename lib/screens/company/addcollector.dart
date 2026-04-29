import 'package:flutter/material.dart';
import 'package:garbage_collection_system/Api/collectorcontroller.dart';

class AddCollectorScreen extends StatefulWidget {
  final int companyId;

  const AddCollectorScreen({super.key, required this.companyId});

  @override
  State<AddCollectorScreen> createState() => _AddCollectorScreenState();
}

class _AddCollectorScreenState extends State<AddCollectorScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final result = await CollectorApi.addCollector(
      CompanyID: widget.companyId,
      FullName: nameController.text.trim(),
      phone: phoneController.text.trim(),
      password: passwordController.text.trim(),
    );

    setState(() => isLoading = false);

    if (result.containsKey("error")) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result["error"])),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result["message"])),
      );

      // 🔥 clear fields
      nameController.clear();
      phoneController.clear();
      passwordController.clear();
    }
  }

  InputDecoration inputStyle(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xFFD0E5FF),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Collector"),
        backgroundColor: const Color(0xFF99C13D),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 🔥 NAME
              TextFormField(
                controller: nameController,
                decoration: inputStyle("Full Name"),
                validator: (value) =>
                    value!.isEmpty ? "Enter name" : null,
              ),

              const SizedBox(height: 15),

              // 🔥 PHONE
              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: inputStyle("Phone"),
                validator: (value) =>
                    value!.isEmpty ? "Enter phone" : null,
              ),

              const SizedBox(height: 15),

              // 🔥 PASSWORD
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: inputStyle("Password"),
                validator: (value) =>
                    value!.isEmpty ? "Enter password" : null,
              ),

              const SizedBox(height: 25),

              // 🔥 BUTTON
              isLoading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF99C13D),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text("Add Collector"),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}