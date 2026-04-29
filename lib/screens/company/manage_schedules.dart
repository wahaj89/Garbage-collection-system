import 'package:flutter/material.dart';
import 'package:garbage_collection_system/custom_widgets/card.dart';

class ManageSchedules extends StatefulWidget {
  const ManageSchedules({super.key});

  @override
  State<ManageSchedules> createState() => _ManageSchedulesState();
}

class _ManageSchedulesState extends State<ManageSchedules> {
  final double columnSpacing = 20;
  @override
  Widget build(BuildContext context) {
   return Scaffold(
      appBar: AppBar(
       
        title: const Center(child: Text("Manage Schedules")),
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
                  title: "Add New Schedule",
                  subtitle: '',
                  icon: Icons.person_add,
                  onTap: () {
                    Navigator.pushNamed(context, '/addSchedule');
                  },
                ),
                CustomCard(
                  title: "View Schedules",
                  subtitle: '',
                  icon: Icons.list_alt,
                  onTap: () {
                    Navigator.pushNamed(context, '/viewSchedules');
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