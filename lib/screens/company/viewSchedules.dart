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

  List zones = [];
  List vehicles = [];

  @override
  void initState() {
    super.initState();
    loadSchedules();
  }

  Future<void> loadSchedules() async {
    try {
      final data = await CompanyApi.getSchedules();

      print("API DATA: $data"); // 🔥 DEBUG

      schedules = data;
      extractData();

      setState(() {
        loading = false;
      });
    } catch (e) {
      print("Error loading schedules: $e");
      setState(() => loading = false);
    }
  }

  // 🔥 Extract Zones & Vehicles
  void extractData() {
    final zSet = <String>{};
    final vSet = <String>{};

    for (var s in schedules) {
      if (s['Name'] != null) zSet.add(s['Name']);
      if (s['PlateNumber'] != null) vSet.add(s['PlateNumber']);
    }

    zones = zSet.toList();
    vehicles = vSet.toList();
  }

  // 🔥 FIXED TIME FORMAT FUNCTION
  String formatTime(dynamic time) {
    if (time == null) return "";

    try {
      DateTime dt = DateTime.parse(time.toString()).toLocal(); // 🔥 FIX

      int hour = dt.hour;
      int minute = dt.minute;

      if (hour == 0 && minute == 0) return "";

      String period = hour >= 12 ? "PM" : "AM";

      hour = hour % 12;
      if (hour == 0) hour = 12;

      return "$hour:${minute.toString().padLeft(2, '0')} $period";
    } catch (e) {
      print("Time parse error: $e");
      return "";
    }
  }

  // 🔥 Get Time for each cell
  String getTime(String zone, String vehicle) {
    for (var s in schedules) {
      if (s['Name'] == zone && s['PlateNumber'] == vehicle) {
        print("MATCH FOUND: $s"); // 🔥 DEBUG

        final start = formatTime(s['StartTime']);
        final end = formatTime(s['EndTime']);

        if (start.isEmpty && end.isEmpty) return "";

        return "$start - $end";
      }
    }
    return "";
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
              : Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 30),

                      const Text(
                        "Weekly  Schedule",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 30),

                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue, width: 3),
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.white,
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Table(
                            defaultColumnWidth:
                                const FixedColumnWidth(110),

                            children: [
                              // 🔥 HEADER ROW
                              TableRow(
                                children: [
                                  buildHeaderCell("Zones"),
                                  ...vehicles
                                      .map((v) => buildHeaderCell(v)),
                                ],
                              ),

                              // 🔥 DATA ROWS
                              ...zones.map((zone) {
                                return TableRow(
                                  children: [
                                    buildHeaderCell(zone),

                                    ...vehicles.map((vehicle) {
                                      final time =
                                          getTime(zone, vehicle);
                                      return buildCell(time);
                                    }).toList(),
                                  ],
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  // 🔥 Header Cell
  Widget buildHeaderCell(String text) {
    return Container(
      height: 55,
      alignment: Alignment.center,
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  // 🔥 Normal Cell
  Widget buildCell(String text) {
    return Container(
      height: 55,
      alignment: Alignment.center,
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: text.isNotEmpty
            ? Colors.green.shade200
            : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
    );
  }
}