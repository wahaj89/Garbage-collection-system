import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:garbage_collection_system/Api/driver_contoller.dart';
import 'package:garbage_collection_system/custom_widgets/card.dart';

class Viewdrivers extends StatefulWidget {
  const Viewdrivers({super.key});

  @override
  State<Viewdrivers> createState() => _ViewdriversState();
}

class _ViewdriversState extends State<Viewdrivers> {

  List drivers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDrivers();
  }

  Future<void> fetchDrivers() async {
    final response = await DriverApi().fetchDrivers();

    if (response.statusCode == 200) {

      final data = jsonDecode(response.body);

      setState(() {
        drivers = data; 
        isLoading = false;
      });

    } else {
      print("Failed: ${response.statusCode}");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Drivers'),
        backgroundColor: const Color(0xFF99C13D),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : drivers.isEmpty
                ? const Center(child: Text("No Active Drivers"))
                : ListView.builder(
                    itemCount: drivers.length,
                    itemBuilder: (context, index) {

                      final driver = drivers[index];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: CustomCard(
                          title: driver["FullName"],
                          subtitle: driver["Phone"],
                          icon: Icons.person,
                          onTap: () {
                            print("Driver tapped: ${driver["DriverID"]}");
                          },

                      
                          extraWidget: Column(
                            children: [
                              const SizedBox(height: 8),
                              Text(
                                "License: ${driver["LicenseNo"]}",
                                style: const TextStyle(fontSize: 13),
                              ),
                              Text(
                                "Vehicle ID: ${driver["VehicleID"]}",
                                style: const TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}