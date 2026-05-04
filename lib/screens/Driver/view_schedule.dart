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

String formatTime(dynamic raw) {
  if (raw == null) return 'N/A';

  try {
    String value = raw.toString();

    int hour = 0;
    int minute = 0;

    // ✅ Case 1: ISO format (1970-01-01T06:00:00.000Z)
    if (value.contains('T')) {
      final dt = DateTime.parse(value).toLocal();
      hour = dt.hour;
      minute = dt.minute;
    } 
    // ✅ Case 2: Normal time (06:00:00.0000000)
    else {
      final cleaned = value.split('.')[0]; // remove nanoseconds
      final parts = cleaned.split(':');

      if (parts.length < 2) return value;

      hour = int.tryParse(parts[0]) ?? 0;
      minute = int.tryParse(parts[1]) ?? 0;
    }

    // ✅ Convert to 12-hour format
    final period = hour >= 12 ? 'PM' : 'AM';

    if (hour == 0) {
      hour = 12;
    } else if (hour > 12) {
      hour -= 12;
    }

    final minStr = minute.toString().padLeft(2, '0');

    return '$hour:$minStr $period';
  } catch (e) {
    print("Time error: $e");
    return raw.toString();
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
         backgroundColor: const Color(0xFF99C13D)
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