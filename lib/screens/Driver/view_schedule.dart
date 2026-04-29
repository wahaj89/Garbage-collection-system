import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:garbage_collection_system/Api/driver_contoller.dart';
import 'package:garbage_collection_system/custom_widgets/card.dart';

class ViewSchedule extends StatefulWidget {
  const ViewSchedule({super.key});

  @override
  State<ViewSchedule> createState() => _ViewScheduleState();
}

class _ViewScheduleState extends State<ViewSchedule> {
  List data = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadSchedule();
  }

  Future<void> loadSchedule() async {
    try {
      final res = await DriverApi().fetchTodaysSchedule();
      final decoded = jsonDecode(res.body);

      setState(() {
        data = List.from(decoded);
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      print("Schedule error: $e");
    }
  }

  // ✅ FIX: clean time formatting
  String formatTime(String? time) {
    if (time == null || time.isEmpty) return "N/A";

    try {
      DateTime dt = DateTime.parse(time).toLocal();
      String hour = dt.hour.toString().padLeft(2, '0');
      String min = dt.minute.toString().padLeft(2, '0');
      return "$hour:$min";
    } catch (e) {
      return "Invalid Time";
    }
  }

  // ✅ safe text
  String safe(value) => (value == null || value.toString().isEmpty)
      ? "N/A"
      : value.toString();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Today's Schedule"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : data.isEmpty
              ? const Center(child: Text("No schedule found"))
              : ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final item = data[index];

                    return CustomCard(
                      title: safe(item['ZoneName']),
                      subtitle:
                          "DriverID: ${safe(item['DriverID'])}\n"
                          "Time: ${formatTime(item['StartTime'])} - ${formatTime(item['EndTime'])}",
                      icon: Icons.schedule,
                      onTap: () {},
                    );
                  },
                ),
    );
  }
}