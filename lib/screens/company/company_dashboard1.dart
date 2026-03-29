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
  @override
void initState() {
  super.initState();
  loadCompanyName();
}

Future<void> loadCompanyName() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  setState(() {
    companyName = prefs.getString('CompanyName') ?? "Company Dashboard";
  });
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false,
         
        title: Center(child: Text("$companyName Dashboard")),
      backgroundColor: Color(0xFF99C13D),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: SingleChildScrollView(
          child: Column(
            
            children: [
          
              SizedBox(
                height: 200,
                width: double.infinity,
                child: CustomCard(
                  title: "Manage Plans",
                  subtitle: "Manage all Plans",
                  icon: Icons.subscriptions_outlined,
                  onTap: () {
                    Navigator.pushNamed(context, '/managePlans');
                  },
                ),
              ),
          
              const SizedBox(height: 15),
          
              SizedBox(
                height: 200,
                width: double.infinity,
                child: CustomCard(
                  title: "Manage Drivers & Vehicles",
                  subtitle: "Manage all Drivers",
                  icon: Icons.drive_eta_outlined,
                  onTap: () {
                    Navigator.pushNamed(context, '/manageDriverVehicles');
                  },
                ),
              ),
          
              const SizedBox(height: 15),
          
              SizedBox(
                height: 200,
                width: double.infinity,
                child: CustomCard(
                  title: "Manage  Complaints",
                  subtitle: "Manage all Complaints",
                  icon: Icons.report_problem_outlined,
                  onTap: () {},
                ),
              ),
          
              const SizedBox(height: 15),
          
              
              SizedBox(
                height: 200,
                width: double.infinity,
                child: CustomCard(
                  title: "Manage Schedules",
                  subtitle: "Manage all Schedules",
                  icon: Icons.schedule_outlined,
                  onTap: () {},
                ),
              ),
                 const SizedBox(height: 15),
          
              SizedBox(
                height: 200,
                width: double.infinity,
                child: CustomCard(
                  title: "Manage Zones",
                  subtitle: "Manage all Zones",
                  icon: Icons.map_outlined,
                  onTap: () {
                    Navigator.pushNamed(context, '/managezones');
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}