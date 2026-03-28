import 'package:flutter/material.dart';
import 'package:garbage_collection_system/custom_widgets/card.dart';
import 'package:garbage_collection_system/screens/company/add_driver.dart';

class Companydashboard extends StatefulWidget {
  const Companydashboard({super.key, required companyId});

  @override
  State<Companydashboard> createState() => _CompanydashboardState();
}

class _CompanydashboardState extends State<Companydashboard> {
  final double columnSpacing = 20;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Center(child: Text("Company Dashboard")),
        backgroundColor: const Color(0xFF99C13D),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [

              SizedBox(height: columnSpacing),

              // Row 1
              buildRow(
                context,
                CustomCard(
                  title: "View All Drivers",
                  subtitle: '',
                  icon: Icons.fire_truck,
                  onTap: () {
                    Navigator.pushNamed(context, '/viewdrivers');
                  },
                ),
                CustomCard(
                  title: "Add New Driver",
                  subtitle: '',
                  icon: Icons.add,
                  onTap: () {
                    Navigator.pushNamed(context, '/addDriver');
                  },
                ),
              ),

              SizedBox(height: columnSpacing),

              // Row 2
              buildRow(
                context,
                CustomCard(
                  title: "View All Users",
                  subtitle: '',
                  icon: Icons.supervised_user_circle,
                  onTap: () {
                    Navigator.pushNamed(context, '/viewusers');
                  },
                ),
                CustomCard(
                  title: "Add New Plan",
                  subtitle: '',
                  icon: Icons.subscriptions,
                  onTap: () {
                    Navigator.pushNamed(context, '/addPlan');
                  },
                ),
              ),

              SizedBox(height: columnSpacing),

              // Row 3
              buildRow(
                context,
                CustomCard(
                  title: "Add new Schedule",
                  subtitle: '',
                  icon: Icons.date_range_outlined,
                  onTap: () {},
                ),
                CustomCard(
                  title: "Add New Vehicle",
                  subtitle: '',
                  icon: Icons.fire_truck_rounded,
                  onTap: () {},
                ),
              ),

              SizedBox(height: columnSpacing),

              // Row 4
              buildRow(
                context,
                CustomCard(
                  title: "View all Zones",
                  subtitle: '',
                  icon: Icons.area_chart,
                  onTap: () {},
                ),
                CustomCard(
                  title: "Track all Drivers",
                  subtitle: '',
                  icon: Icons.location_pin,
                  onTap: () {},
                ),
              ),

              SizedBox(height: columnSpacing),

              // Row 5
              buildRow(
                context,
                CustomCard(
                  title: "Add new Zones",
                  subtitle: '',
                  icon: Icons.add,
                  onTap: () {},
                ),
                CustomCard(
                  title: "Add new Collector",
                  subtitle: '',
                  icon: Icons.add,
                  onTap: () {},
                ),
              ),

              SizedBox(height: columnSpacing),

              // Row 6
              buildRow(
                context,
                CustomCard(
                  title: "View all Complaints",
                  subtitle: '',
                  icon: Icons.sync_problem,
                  onTap: () {},
                ),
                CustomCard(
                  title: "Generate Qr Code",
                  subtitle: '',
                  icon: Icons.qr_code_sharp,
                  onTap: () {},
                ),
              ),

              SizedBox(height: columnSpacing),
            ],
          ),
        ),
      ),
    );
  }

  
  Widget buildRow(BuildContext context, Widget card1, Widget card2) {
    return Row(
      children: [
        Expanded(child: card1),
        const SizedBox(width: 20),
        Expanded(child: card2),
      ],
    );
  }
}