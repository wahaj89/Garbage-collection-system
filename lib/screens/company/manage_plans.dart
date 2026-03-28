import 'package:flutter/material.dart';
import 'package:garbage_collection_system/custom_widgets/card.dart';

class Companydashboard extends StatefulWidget {
  const Companydashboard({super.key});

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
        title: const Center(child: Text("Manage Plans")),
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
                  title: "Add New Plan",
                  subtitle: '',
                  icon: Icons.subscriptions,
                  onTap: () {
                    Navigator.pushNamed(context, '/addPlan');
                  },
                ),
                CustomCard(
                  title: "View All Plans",
                  subtitle: '',
                  icon: Icons.list_alt,
                  onTap: () {
                    Navigator.pushNamed(context, '/viewPlans');
                  },
                ),
              ),

              SizedBox(height: columnSpacing),

              // Row 2
              buildRow(
                context,
                CustomCard(
                  title: "Generate QR Code",
                  subtitle: '',
                  icon: Icons.qr_code,
                  onTap: () {
                    Navigator.pushNamed(context, '/generateQRCode');
                  },
                ),
                CustomCard(
                  title: "View Subscribers",
                  subtitle: '',
                  icon: Icons.people,
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