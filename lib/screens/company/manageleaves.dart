import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:garbage_collection_system/Api/driver_contoller.dart';
import 'package:garbage_collection_system/custom_widgets/button.dart';

class CompanyLeaveRequestsScreen extends StatefulWidget {
  const CompanyLeaveRequestsScreen({super.key});

  @override
  State<CompanyLeaveRequestsScreen> createState() =>
      _CompanyLeaveRequestsScreenState();
}

class _CompanyLeaveRequestsScreenState
    extends State<CompanyLeaveRequestsScreen> {
  List leaves = [];
  bool isLoading = true;
  bool isActionLoading = false;

  final Color mainGreen = const Color(0xFF99C13D);
  final Color cardColor = const Color(0xFFD0E5FF);

  @override
  void initState() {
    super.initState();
    fetchLeaves();
  }

  Future<void> fetchLeaves() async {
    try {
      setState(() {
        isLoading = true;
      });

      final prefs = await SharedPreferences.getInstance();

      final int companyId =
          prefs.getInt("CompanyID") ??
          prefs.getInt("CompanyId") ??
          prefs.getInt("UserID") ??
          prefs.getInt("UserId") ??
          0;

      if (companyId == 0) {
        throw Exception("Company ID not found in shared preferences");
      }

      final data = await DriverApi().getDriverLeaves(
        companyId: companyId,
      );

      setState(() {
        leaves = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      showMessage(e.toString().replaceAll("Exception:", "").trim());
    }
  }

  Future<void> acceptOrRejectLeave({
    required int leaveId,
    required String status,
  }) async {
    try {
      setState(() {
        isActionLoading = true;
      });

      final result = await DriverApi().reviewDriverLeave(
        leaveId: leaveId,
        status: status,
        remarks: status == "Approved"
            ? "Leave approved by company"
            : "Leave rejected by company",
      );

      showMessage(result["message"] ?? "Leave updated successfully");

      await fetchLeaves();
    } catch (e) {
      showMessage(e.toString().replaceAll("Exception:", "").trim());
    } finally {
      setState(() {
        isActionLoading = false;
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

  String formatDate(dynamic value) {
    if (value == null) return "N/A";

    final text = value.toString();

    if (text.contains("T")) {
      return text.split("T").first;
    }

    return text;
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "pending":
        return Colors.orange;
      case "approved":
        return Colors.green;
      case "rejected":
        return Colors.red;
      case "completed":
        return Colors.blueGrey;
      default:
        return Colors.black;
    }
  }

  Widget infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$title: ",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget leaveCard(dynamic item) {
    final int leaveId = item["LeaveID"] ?? 0;
    final String driverName = item["DriverName"] ?? "Driver";
    final String phone = item["Phone"] ?? "N/A";
    final String status = item["Status"] ?? "Pending";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // top row
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.black),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  driverName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: getStatusColor(status),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          infoRow("Phone", phone),
          infoRow("Start Date", formatDate(item["StartDate"])),
          infoRow("End Date", formatDate(item["EndDate"])),
          infoRow("Reason", item["Reason"] ?? "N/A"),

          const SizedBox(height: 14),

          if (status == "Pending")
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: "Accept",
                    icon: Icons.check,
                    backgroundColor: mainGreen,
                    onPressed: isActionLoading
                        ? () {}
                        : () {
                            acceptOrRejectLeave(
                              leaveId: leaveId,
                              status: "Approved",
                            );
                          },
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: CustomButton(
                    text: "Reject",
                    icon: Icons.close,
                    backgroundColor: Colors.red.shade300,
                    onPressed: isActionLoading
                        ? () {}
                        : () {
                            acceptOrRejectLeave(
                              leaveId: leaveId,
                              status: "Rejected",
                            );
                          },
                  ),
                ),
              ],
            ),

          if (status != "Pending")
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  "Leave is $status",
                  style: TextStyle(
                    color: getStatusColor(status),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget bodyContent() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (leaves.isEmpty) {
      return const Center(
        child: Text(
          "No leave requests found",
          style: TextStyle(
            fontSize: 16,
            color: Colors.black54,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: fetchLeaves,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: leaves.length,
        itemBuilder: (context, index) {
          return leaveCard(leaves[index]);
        },
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
          "Leave Requests",
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
            onPressed: fetchLeaves,
            icon: const Icon(Icons.refresh, color: Colors.black),
          ),
        ],
      ),

      body: Stack(
        children: [
          bodyContent(),

          if (isActionLoading)
            Container(
              color: Colors.black.withOpacity(0.15),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}