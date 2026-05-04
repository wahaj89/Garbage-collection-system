import 'package:flutter/material.dart';
import 'package:garbage_collection_system/Api/CompanyController.dart';

class Viewschedules extends StatefulWidget {
  const Viewschedules({super.key});

  @override
  State<Viewschedules> createState() => _ViewschedulesState();
}

class _ViewschedulesState extends State<Viewschedules> {
  List schedules = [];
  bool loading = true;

  // Columns = Days of week (fixed order)
  final List<String> days = [
    "Monday", "Tuesday", "Wednesday",
    "Thursday", "Friday", "Saturday", "Sunday"
  ];

  List<String> zones = [];

  @override
  void initState() {
    super.initState();
    loadSchedules();
  }

  Future<void> loadSchedules() async {
    try {
      final data = await CompanyApi.getSchedules();
      print("API DATA: $data");
      setState(() {
        schedules = data;
        zones = _extractZones(data);
        loading = false;
      });
    } catch (e) {
      print("Error loading schedules: $e");
      setState(() => loading = false);
    }
  }

  // ✅ Unique zones extract karo (ZoneName use karo)
  List<String> _extractZones(List data) {
    final zSet = <String>{};
    for (var s in data) {
      if (s['ZoneName'] != null) zSet.add(s['ZoneName']);
    }
    return zSet.toList()..sort();
  }

  // ✅ Zone + Day ke liye SAARE schedules laao (multiple drivers ho sakty hain)
  List<Map> _getSlots(String zone, String day) {
    return schedules.where((s) {
      return s['ZoneName'] == zone && s['DayOfWeek'] == day;
    }).toList().cast<Map>();
  }

  // ✅ Time format
  String formatTime(dynamic time) {
    if (time == null) return "";
    try {
      // "HH:mm:ss" ya DateTime string dono handle karo
      DateTime dt;
      final str = time.toString();

      if (str.contains("T") || str.contains("-")) {
        dt = DateTime.parse(str).toLocal();
      } else {
        // "08:00:00" format
        final parts = str.split(":");
        final now = DateTime.now();
        dt = DateTime(now.year, now.month, now.day,
            int.parse(parts[0]), int.parse(parts[1]));
      }

      int hour = dt.hour;
      int minute = dt.minute;
      if (hour == 0 && minute == 0) return "";

      String period = hour >= 12 ? "PM" : "AM";
      hour = hour % 12;
      if (hour == 0) hour = 12;
      return "$hour:${minute.toString().padLeft(2, '0')} $period";
    } catch (e) {
      print("Time parse error: $e for value: $time");
      return time.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text("Schedule"),
        backgroundColor: const Color(0xFF99C13D),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : schedules.isEmpty
              ? const Center(child: Text("No schedules found"))
              : Column(
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      "Weekly Schedule",
                      style: TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),

                    // ✅ Scroll both horizontally and vertically
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.all(12),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: const Color(0xFF99C13D), width: 2),
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white,
                            ),
                            padding: const EdgeInsets.all(8),
                            child: Table(
                              defaultColumnWidth:
                                  const FixedColumnWidth(120),
                              border: TableBorder.all(
                                  color: Colors.grey.shade300, width: 1),
                              children: [
                                // ✅ Header Row — Days
                                TableRow(
                                  decoration: BoxDecoration(
                                      color: const Color(0xFF99C13D)
                                          .withOpacity(0.2)),
                                  children: [
                                    buildHeaderCell("Zone"),
                                    ...days.map(
                                        (d) => buildHeaderCell(d)),
                                  ],
                                ),

                                // ✅ Data Rows — Zone × Day
                                ...zones.map((zone) {
                                  return TableRow(
                                    children: [
                                      buildHeaderCell(zone),
                                      ...days.map((day) {
                                        final slots =
                                            _getSlots(zone, day);
                                        return buildCell(slots);
                                      }).toList(),
                                    ],
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),
                  ],
                ),
    );
  }

  Widget buildHeaderCell(String text) {
    return Container(
      height: 50,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
            fontWeight: FontWeight.bold, fontSize: 13),
      ),
    );
  }

  // ✅ Ek cell mein multiple drivers show karo
  Widget buildCell(List<Map> slots) {
    if (slots.isEmpty) {
      return Container(
        height: 55,
        alignment: Alignment.center,
        color: Colors.grey.shade50,
        child: const Text("-",
            style: TextStyle(color: Colors.grey)),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      color: Colors.green.shade50,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: slots.map((slot) {
          final start = formatTime(slot['StartTime']);
          final end = formatTime(slot['EndTime']);
          final driver = slot['DriverName'] ?? '';
          final plate = slot['PlateNumber'] ?? '';

          return Container(
            margin: const EdgeInsets.symmetric(vertical: 2),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.green.shade200,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              children: [
                Text(
                  "$start - $end",
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                Text(
                  driver,
                  style: const TextStyle(fontSize: 10),
                  textAlign: TextAlign.center,
                ),
                Text(
                  plate,
                  style: TextStyle(
                      fontSize: 10, color: Colors.grey.shade700),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}