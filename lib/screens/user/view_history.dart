import 'package:flutter/material.dart';
import 'package:garbage_collection_system/Api/userController.dart';

class ViewHistory extends StatefulWidget {
  const ViewHistory({super.key});

  @override
  State<ViewHistory> createState() => _ViewHistoryState();
}

class _ViewHistoryState extends State<ViewHistory> {
  List pickups = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadPickups();
  }

  Future<void> loadPickups() async {
    try {
      final data = await UserApi().getPastPickups();

      setState(() {
        pickups = data;
        isLoading = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget buildCard(item) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFD0E5FF),
            Color(0xFFD0E5FF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Driver: ${item['DriverName'] ?? 'N/A'}",
            style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),

          Text(
            "Bag ID: ${item['BagID']}",
            style: const TextStyle(color: Colors.black45),
          ),

          Text(
            "Vehicle ID: ${item['VehicleID']}",
            style: const TextStyle(color: Colors.black45),
          ),

          Text(
            "Date: ${item['ScannedAt']}",
            style: const TextStyle(color: Colors.black45),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pickup History"),
        backgroundColor: const Color(0xFF99C13D),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : pickups.isEmpty
              ? const Center(
                  child: Text(
                    "No pickups found",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                )
              : Center(
                child: ListView.builder(
                    itemCount: pickups.length,
                    itemBuilder: (context, index) {
                      return buildCard(pickups[index]);
                    },
                  ),
              ),
    );
  }
}