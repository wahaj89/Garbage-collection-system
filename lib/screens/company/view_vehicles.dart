import 'package:flutter/material.dart';
import 'package:garbage_collection_system/Api/CompanyController.dart';
import 'package:garbage_collection_system/custom_widgets/card.dart';


class ViewVehicles extends StatefulWidget {
  const ViewVehicles({super.key});

  @override
  State<ViewVehicles> createState() => _ViewVehiclesState();
}

class _ViewVehiclesState extends State<ViewVehicles> {
  List vehicles = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadVehicles();
  }

  /// 🔹 Fetch vehicles
  Future<void> loadVehicles() async {
    try {
      final data = await CompanyApi.getCompanyVehicles();

      setState(() {
        vehicles = data;
        isLoading = false;
      });
    } catch (e) {
      print("Error: $e");

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Vehicles"),
        backgroundColor: const Color(0xFF99C13D),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : vehicles.isEmpty
              ? const Center(
                  child: Text(
                    "No Vehicles Found",
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: loadVehicles,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: vehicles.length,
                    itemBuilder: (context, index) {
                      final v = vehicles[index];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: CustomCard(
                          icon: Icons.local_shipping,
                          title: v['PlateNumber'] ?? 'N/A',
                          subtitle:
                              "Model: ${v['Model'] ?? 'N/A'}\nCapacity: ${v['Capacity'] ?? 'N/A'} KG",
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Vehicle: ${v['PlateNumber']}",
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}