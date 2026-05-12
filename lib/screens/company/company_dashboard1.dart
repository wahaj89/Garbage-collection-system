import 'package:flutter/material.dart';
import 'package:garbage_collection_system/custom_widgets/card.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CompanyDashboard1 extends StatefulWidget {
  const CompanyDashboard1({super.key});

  @override
  State<CompanyDashboard1> createState() => _CompanyDashboard1State();
}

class _CompanyDashboard1State extends State<CompanyDashboard1> {
  String companyName = "Company Dashboard";

  static const Color appBarColor = Color(0xFF99C13D);
  static const Color backgroundColor = Color(0xFFF7F9F5);

  @override
  void initState() {
    super.initState();
    loadCompanyName();
  }

  Future<void> loadCompanyName() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      companyName = prefs.getString('CompanyName') ?? "Company Dashboard";
    });
  }

  Widget dashboardCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 185,
      width: double.infinity,
      child: CustomCard(
        title: title,
        subtitle: subtitle,
        icon: icon,
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: appBarColor,
        elevation: 1,
        centerTitle: true,
        title: Text(
          "$companyName Dashboard",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 19,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            const SizedBox(height: 5),

            dashboardCard(
              title: "Manage Plans",
              subtitle: "Manage all Plans",
              icon: Icons.subscriptions_outlined,
              onTap: () {
                Navigator.pushNamed(context, '/managePlans');
              },
            ),

            const SizedBox(height: 15),

            dashboardCard(
              title: "Manage Drivers & Vehicles",
              subtitle: "Manage all Drivers and Vehicles",
              icon: Icons.drive_eta_outlined,
              onTap: () {
                Navigator.pushNamed(context, '/manageDriverVehicles');
              },
            ),

            const SizedBox(height: 15),

            dashboardCard(
              title: "Manage Complaints",
              subtitle: "Manage all Complaints",
              icon: Icons.report_problem_outlined,
              onTap: () {
                Navigator.pushNamed(context, '/viewComplaints');
              },
            ),

            const SizedBox(height: 15),

            dashboardCard(
              title: "Manage Schedules",
              subtitle: "Manage all Schedules",
              icon: Icons.schedule_outlined,
              onTap: () {
                Navigator.pushNamed(context, '/manageSchedules');
              },
            ),

            const SizedBox(height: 15),

            dashboardCard(
              title: "Manage Zones",
              subtitle: "Manage all Zones",
              icon: Icons.map_outlined,
              onTap: () {
                Navigator.pushNamed(context, '/managezones');
              },
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}