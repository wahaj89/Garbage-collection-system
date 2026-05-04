import 'package:flutter/material.dart';
import 'package:garbage_collection_system/Api/CompanyController.dart';
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
  TextEditingController passwordController = TextEditingController();

  bool isSubmitting = false;

  // ✅ Vehicles
  List vehicles = [];
  int? selectedVehicleId;

  // ✅ Collectors
  List collectors = [];
  int? selectedCollectorId;

  @override
  void initState() {
    super.initState();
    fetchVehicles();
    fetchCollectors();
  }

  /// 🔹 Fetch Vehicles
  Future<void> fetchVehicles() async {
    try {
      final data = await CompanyApi.getCompanyVehicles();
      setState(() {
        vehicles = data;
      });
    } catch (e) {
      print("Error fetching vehicles: $e");
    }
  }

  /// 🔹 Fetch Collectors
  Future<void> fetchCollectors() async {
    try {
      final data = await CompanyApi().getCompanyCollectors();
      setState(() {
        collectors = data;
      });
    } catch (e) {
      print("Error fetching collectors: $e");
    }
  }

  /// 🔹 Submit Form
  Future<void> submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedVehicleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a vehicle"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (selectedCollectorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a collector"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isSubmitting = true);

    try {
      final success = await CompanyApi.addDriver(
        fullName: fullNameController.text,
        phone: phoneController.text,
        license: licenseController.text,
        vehicleId: selectedVehicleId!,
         // ✅ NEW
        password: passwordController.text,
        collectorId: selectedCollectorId!,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Driver Added Successfully"),
            backgroundColor: Colors.green,
          ),
        );

        fullNameController.clear();
        phoneController.clear();
        licenseController.clear();
        passwordController.clear();

        setState(() {
          selectedVehicleId = null;
          selectedCollectorId = null;
        });
      } else {
        throw Exception("Failed");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() => isSubmitting = false);
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

                  /// 🔹 Vehicle Dropdown
                  SizedBox(
                    width: 370,
                    child: DropdownButtonFormField<int>(
                      value: selectedVehicleId,
                      decoration: InputDecoration(
                        labelText: "Select Vehicle",
                        filled: true,
                        fillColor: const Color(0xFFD0E5FF),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        suffixIcon: const Icon(Icons.local_shipping),
                      ),
                      items: vehicles.map<DropdownMenuItem<int>>((vehicle) {
                        return DropdownMenuItem<int>(
                          value: vehicle['VehicleID'],
                          child: Text(
                            "${vehicle['PlateNumber']} (${vehicle['Model']})",
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedVehicleId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return "Please select a vehicle";
                        }
                        return null;
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// 🔹 Collector Dropdown
                  SizedBox(
                    width: 370,
                    child: DropdownButtonFormField<int>(
                      value: selectedCollectorId,
                      decoration: InputDecoration(
                        labelText: "Select Collector",
                        filled: true,
                        fillColor: const Color(0xFFD0E5FF),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        suffixIcon: const Icon(Icons.people),
                      ),
                      items: collectors.map<DropdownMenuItem<int>>((collector) {
                        return DropdownMenuItem<int>(
                          value: collector['CollectorID'],
                          child: Text(
                            "${collector['FullName']}",
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCollectorId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return "Please select a collector";
                        }
                        return null;
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// 🔹 Password
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