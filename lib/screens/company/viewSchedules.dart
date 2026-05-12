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

  static const Color appColor = Color(0xFF99C13D);
  static const Color cardColor = Color(0xFFD0E5FF);

  final List<String> days = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday",
  ];

  List<String> zones = [];

  @override
  void initState() {
    super.initState();
    loadSchedules();
  }

  Future<void> loadSchedules() async {
    try {
      setState(() {
        loading = true;
      });

      final data = await CompanyApi.getSchedules();

      setState(() {
        schedules = data;
        zones = _extractZones(data);
        loading = false;
      });
    } catch (e) {
      print("Error loading schedules: $e");

      setState(() {
        loading = false;
      });
    }
  }

  List<String> _extractZones(List data) {
    final zSet = <String>{};

    for (var s in data) {
      if (s['ZoneName'] != null) {
        zSet.add(s['ZoneName']);
      } else if (s['Name'] != null) {
        zSet.add(s['Name']);
      }
    }

    return zSet.toList()..sort();
  }

  List<Map> _getSlots(String zone, String day) {
    return schedules.where((s) {
      final zoneName = s['ZoneName'] ?? s['Name'];
      return zoneName == zone && s['DayOfWeek'] == day;
    }).toList().cast<Map>();
  }

  String formatTime(dynamic time) {
    if (time == null) return "";

    try {
      DateTime dt;
      final str = time.toString();

      if (str.contains("T") || str.contains("-")) {
        dt = DateTime.parse(str).toLocal();
      } else {
        final parts = str.split(":");
        final now = DateTime.now();

        dt = DateTime(
          now.year,
          now.month,
          now.day,
          int.parse(parts[0]),
          int.parse(parts[1]),
        );
      }

      int hour = dt.hour;
      int minute = dt.minute;

      String period = hour >= 12 ? "PM" : "AM";

      hour = hour % 12;
      if (hour == 0) hour = 12;

      return "$hour:${minute.toString().padLeft(2, '0')} $period";
    } catch (e) {
      print("Time parse error: $e for value: $time");
      return time.toString();
    }
  }

  int get totalSlots => schedules.length;

  int get activeZones => zones.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F1),
      appBar: AppBar(
        title: const Text(
          "Schedules",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: appColor,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
        actions: [
          IconButton(
            onPressed: loadSchedules,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(
                color: appColor,
              ),
            )
          : schedules.isEmpty
              ? buildEmptyState()
              : SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: [
                      buildTopHeader(),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: buildScheduleTable(),
                      ),
                      const SizedBox(height: 25),
                    ],
                  ),
                ),
    );
  }

  Widget buildTopHeader() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: appColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Weekly Schedule",
            style: TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Manage driver routes zone-wise",
            style: TextStyle(
              color: Colors.black87,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              buildStatsBox(
                title: "Zones",
                value: activeZones.toString(),
                icon: Icons.location_on,
              ),
              const SizedBox(width: 12),
              buildStatsBox(
                title: "Slots",
                value: totalSlots.toString(),
                icon: Icons.schedule,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildStatsBox({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 10,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.35),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.black.withOpacity(0.12),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.black,
              size: 22,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildScheduleTable() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(10),
      child: Table(
        defaultColumnWidth: const FixedColumnWidth(135),
        border: TableBorder.symmetric(
          inside: BorderSide(
            color: Colors.grey.shade100,
            width: 6,
          ),
        ),
        children: [
          TableRow(
            children: [
              buildHeaderCell("Zone"),
              ...days.map((day) => buildHeaderCell(shortDay(day))),
            ],
          ),
          ...zones.map((zone) {
            return TableRow(
              children: [
                buildZoneCell(zone),
                ...days.map((day) {
                  final slots = _getSlots(zone, day);
                  return buildCell(slots);
                }).toList(),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  String shortDay(String day) {
    switch (day) {
      case "Monday":
        return "Mon";
      case "Tuesday":
        return "Tue";
      case "Wednesday":
        return "Wed";
      case "Thursday":
        return "Thu";
      case "Friday":
        return "Fri";
      case "Saturday":
        return "Sat";
      case "Sunday":
        return "Sun";
      default:
        return day;
    }
  }

  Widget buildHeaderCell(String text) {
    return SizedBox(
      height: 58,
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: appColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.black.withOpacity(0.10),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildZoneCell(String text) {
    return SizedBox(
      height: 140,
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.black.withOpacity(0.12),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildCell(List<Map> slots) {
    if (slots.isEmpty) {
      return SizedBox(
        height: 140,
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.grey.shade200,
              ),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 7,
                horizontal: 14,
              ),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "Free",
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 140,
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            // schedule cell background change nahi kiya
            color: const Color(0xFFF9FCF2),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFF99C13D).withOpacity(0.18),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: slots.map((slot) {
                final start = formatTime(slot['StartTime']);
                final end = formatTime(slot['EndTime']);
                final driver = slot['DriverName'] ?? 'No Driver';
                final plate = slot['PlateNumber'] ?? 'No Vehicle';

                return SizedBox(
                  width: double.infinity,
                  height: 112,
                  child: AspectRatio(
                    aspectRatio: 1.2,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        // sirf actual schedule card ka color change kiya
                        color: cardColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.black.withOpacity(0.12),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.access_time,
                                size: 13,
                                color: Colors.black,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  "$start - $end",
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            driver,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.local_shipping,
                                size: 13,
                                color: Colors.black87,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  plate,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.black87,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildEmptyState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.event_busy,
              size: 70,
              color: Colors.black,
            ),
            const SizedBox(height: 14),
            const Text(
              "No schedules found",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Create a schedule to see it here.",
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: loadSchedules,
              icon: const Icon(Icons.refresh),
              label: const Text("Refresh"),
              style: ElevatedButton.styleFrom(
                backgroundColor: appColor,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}