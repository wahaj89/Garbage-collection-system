import 'package:flutter/material.dart';
import 'package:garbage_collection_system/custom_widgets/card.dart';

class ManageZones extends StatefulWidget {
  const ManageZones({super.key});

  @override
  State<ManageZones> createState() => _ManageZonesState();
}

class _ManageZonesState extends State<ManageZones> {
   final double columnSpacing = 20;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text("Manage zones")),
        backgroundColor: const Color(0xFF99C13D),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [

              SizedBox(height: columnSpacing),

              buildRow(
                context,
                CustomCard(
                  title: "Add New Zone",
                  subtitle: '',
                  icon: Icons.subscriptions,
                  onTap: () {
                    Navigator.pushNamed(context, '/addzone');
                  },
                ),
                CustomCard(
                  title: "View All Zones",
                  subtitle: '',
                  icon: Icons.list_alt,
                  onTap: () {
                    Navigator.pushNamed(context, '/viewzones');
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
  