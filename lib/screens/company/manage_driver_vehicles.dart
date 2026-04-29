import 'package:flutter/material.dart';
import 'package:garbage_collection_system/custom_widgets/card.dart';
import 'package:garbage_collection_system/screens/company/addcollector.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ManageDriverVehicles extends StatefulWidget {
  const ManageDriverVehicles({super.key});

  @override
  State<ManageDriverVehicles> createState() => _ManageDriverVehiclesState();
}

class _ManageDriverVehiclesState extends State<ManageDriverVehicles> {
  final double columnSpacing = 20;
  int companyId = 1;

  @override
  void initState() {
    super.initState();
    _loadCompanyId();
  }

  Future<void> _loadCompanyId() async {
    final pref = await SharedPreferences.getInstance();
    setState(() {
      companyId = pref.getInt('CompanyID') ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
     return Scaffold(
      appBar: AppBar(
       
        title: const Center(child: Text("Manage Driver & Vehicles")),
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
                  title: "Add New Driver",
                  subtitle: '',
                  icon: Icons.person_add,
                  onTap: () {
                    Navigator.pushNamed(context, '/addDriver');
                  },
                ),
                CustomCard(
                  title: "View All Drivers",
                  subtitle: '',
                  icon: Icons.list_alt,
                  onTap: () {
                    Navigator.pushNamed(context, '/viewdrivers');
                  },
                ),
              ),

              SizedBox(height: columnSpacing),

              // Row 2
              buildRow(
                context,
                CustomCard(
                  title: "Add New Vehicle",
                  subtitle: '',
                  icon: Icons.local_shipping,
                  onTap: () {
                    Navigator.pushNamed(context, '/addvehicle');
                  },
                ),
                CustomCard(
                  title: "View All Vehicles",
                  subtitle: '',
                  icon: Icons.local_shipping,
                  onTap: () {
                    Navigator.pushNamed(context, '/viewvehicles');
                  },
                ),
              ),

              SizedBox(height: columnSpacing),
               buildRow(
                context,
                CustomCard(
                  title: "Add New Collector ",
                  subtitle: '',
                  icon: Icons.person_add,
                  onTap: () {
                   Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => AddCollectorScreen(companyId: companyId),
  ),
);
                  },
                ),
                CustomCard(
                  title: "View All Collectors",
                  subtitle: '',
                  icon: Icons.person,
                  onTap: () {
                    Navigator.pushNamed(context, '/viewCollectors');
                  },
                ),
              ),
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
 