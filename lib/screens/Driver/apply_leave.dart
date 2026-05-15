import 'package:flutter/material.dart';
import 'package:garbage_collection_system/Api/driver_contoller.dart';
import 'package:garbage_collection_system/custom_widgets/button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DriverLeaveApplicationScreen extends StatefulWidget {
  const DriverLeaveApplicationScreen({super.key});

  @override
  State<DriverLeaveApplicationScreen> createState() =>
      _DriverLeaveApplicationScreenState();
}

class _DriverLeaveApplicationScreenState
    extends State<DriverLeaveApplicationScreen> {
  final TextEditingController reasonController = TextEditingController();

  DateTime? startDate;
  DateTime? endDate;

  bool isLoading = false;

  final Color appColor = const Color(0xFFD0E5FF);
  final Color mainGreen = const Color(0xFF99C13D);

  @override
  void dispose() {
    reasonController.dispose();
    super.dispose();
  }

  Future<void> pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        startDate = picked;

        if (endDate != null && endDate!.isBefore(startDate!)) {
          endDate = null;
        }
      });
    }
  }

  Future<void> pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: endDate ?? startDate ?? DateTime.now(),
      firstDate: startDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        endDate = picked;
      });
    }
  }

  String showDate(DateTime? date) {
    if (date == null) return "Select Date";

    return "${date.day.toString().padLeft(2, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.year}";
  }

  Future<void> submitLeave() async {
    if (startDate == null) {
      showMessage("Please select start date");
      return;
    }

    if (endDate == null) {
      showMessage("Please select end date");
      return;
    }

    if (reasonController.text.trim().isEmpty) {
      showMessage("Please enter reason");
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      final prefs = await SharedPreferences.getInstance();

      final int driverId =
          prefs.getInt("DriverID") ??
          prefs.getInt("UserID") ??
          prefs.getInt("UserId") ??
          0;

      if (driverId == 0) {
        throw Exception("Driver ID not found in shared preferences");
      }

      final result = await DriverApi().applyDriverLeave(
        driverId: driverId,
        startDate: startDate!,
        endDate: endDate!,
        reason: reasonController.text.trim(),
      );

      showMessage(result["message"] ?? "Leave submitted successfully");

      setState(() {
        startDate = null;
        endDate = null;
        reasonController.clear();
      });
    } catch (e) {
      showMessage(e.toString().replaceAll("Exception:", "").trim());
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget dateBox({
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: appColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black12),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_month, color: Colors.black87),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "$title: $value",
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget reasonField() {
    return TextField(
      controller: reasonController,
      maxLines: 5,
      decoration: InputDecoration(
        hintText: "Enter leave reason",
        filled: true,
        fillColor: appColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black),
        ),
      ),
    );
  }

  Widget submitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: AbsorbPointer(
        absorbing: isLoading,
        child: Opacity(
          opacity: isLoading ? 0.7 : 1,
          child: CustomButton(
            text: isLoading ? "Submitting..." : "Submit Leave",
            icon: isLoading ? null : Icons.send,
            backgroundColor: mainGreen,
            onPressed: submitLeave,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: mainGreen,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Leave Application",
          style: TextStyle(color: Colors.black),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            dateBox(
              title: "Start Date",
              value: showDate(startDate),
              onTap: pickStartDate,
            ),

            const SizedBox(height: 12),

            dateBox(
              title: "End Date",
              value: showDate(endDate),
              onTap: pickEndDate,
            ),

            const SizedBox(height: 12),

            reasonField(),

            const SizedBox(height: 22),

            submitButton(),
          ],
        ),
      ),
    );
  }
}