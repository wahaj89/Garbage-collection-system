import 'package:flutter/material.dart';
import 'package:garbage_collection_system/Api/CompanyController.dart';
import 'package:garbage_collection_system/custom_widgets/inputfield.dart';
import 'package:garbage_collection_system/custom_widgets/button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddSchedule extends StatefulWidget {
  const AddSchedule({super.key});

  @override
  State<AddSchedule> createState() => _AddScheduleState();
}

class _AddScheduleState extends State<AddSchedule> {
  List drivers = [];
  List zones = [];

  int? selectedDriverID;
  int? selectedZoneID;
  String? selectedDayOfWeek;
  DateTime? selectedDate;

  final TextEditingController startController = TextEditingController();
  final TextEditingController endController = TextEditingController();

  TimeOfDay? startTime;
  TimeOfDay? endTime;

  List<String> days = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday"
  ];

  @override
  void initState() {
    super.initState();
    loadDrivers();
    loadZones();
  }

  // ---------------- DRIVERS ----------------
  Future<void> loadDrivers() async {
    try {
      final data = await CompanyApi.getDrivers();
      setState(() => drivers = data);
    } catch (e) {
      print(e);
    }
  }

  // ---------------- ZONES ----------------
  Future<void> loadZones() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      int? companyId = prefs.getInt('CompanyID');

      if (companyId == null) return;

      final data = await CompanyApi.getZones(companyId);
      setState(() => zones = data);
    } catch (e) {
      print(e);
    }
  }

  // ---------------- TIME ----------------
  Future<void> pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        startTime = picked;
        startController.text = picked.format(context);
      });
    }
  }

  Future<void> pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        endTime = picked;
        endController.text = picked.format(context);
      });
    }
  }


  

  String formatDate(DateTime date) {
    return date.toIso8601String().split("T")[0];
  }

  String formatTime(TimeOfDay time) {
    return "${time.hour}:${time.minute}:00";
  }

  // ---------------- SUBMIT ----------------
  void submit() async {
    if (selectedZoneID == null ||
        selectedDriverID == null ||
        selectedDayOfWeek == null ||
        startTime == null ||
        endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fill all fields")),
      );
      return;
    }

    try {
      await CompanyApi.createSlot(
        zoneID: selectedZoneID!,
        dayOfWeek: selectedDayOfWeek!,
        startTime: formatTime(startTime!),
        endTime: formatTime(endTime!),
        driverID: selectedDriverID!,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Schedule Created Successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Schedule"),
        backgroundColor: const Color(0xFF99C13D),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // ---------------- ZONE ----------------
            DropdownButtonFormField<int>(
              value: selectedZoneID,
              hint: const Text("Select Zone"),
              items: zones.map<DropdownMenuItem<int>>((z) {
                return DropdownMenuItem(
                  value: z['ZoneID'],
                  child: Text(z['ZoneName'] ?? "Zone ${z['ZoneID']}"),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => selectedZoneID = value);
              },
              decoration: const InputDecoration(
                filled: true,
                fillColor: Color(0xFFD0E5FF),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            // ---------------- DRIVER ----------------
            DropdownButtonFormField<int>(
              value: selectedDriverID,
              hint: const Text("Select Driver"),
              items: drivers.map<DropdownMenuItem<int>>((d) {
                return DropdownMenuItem(
                  value: d['DriverID'],
                  child: Text(
                    "${d['FullName']} (${d['PlateNumber'] ?? 'No Vehicle'})",
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => selectedDriverID = value);
              },
              decoration: const InputDecoration(
                filled: true,
                fillColor: Color(0xFFD0E5FF),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            // ---------------- DAY OF WEEK ----------------
            DropdownButtonFormField<String>(
              value: selectedDayOfWeek,
              hint: const Text("Select Day"),
              items: days.map((day) {
                return DropdownMenuItem(
                  value: day,
                  child: Text(day),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => selectedDayOfWeek = value);
              },
              decoration: const InputDecoration(
                filled: true,
                fillColor: Color(0xFFD0E5FF),
                border: OutlineInputBorder(),
              ),
            ),

        
           

            const SizedBox(height: 15),

            // ---------------- START TIME ----------------
            CustomInput(
              label: "Start Time",
              controller: startController,
              readOnly: true,
              button: CustomButton(
                text: "Pick",
                icon: Icons.access_time,
                onPressed: pickStartTime,
              ),
            ),

            const SizedBox(height: 15),

            // ---------------- END TIME ----------------
            CustomInput(
              label: "End Time",
              controller: endController,
              readOnly: true,
              button: CustomButton(
                text: "Pick",
                icon: Icons.access_time,
                onPressed: pickEndTime,
              ),
            ),

            const SizedBox(height: 25),

            // ---------------- SUBMIT ----------------
            CustomButton(
              text: "Create Schedule",
              icon: Icons.check,
              onPressed: submit,
            ),
          ],
        ),
      ),
    );
  }
}