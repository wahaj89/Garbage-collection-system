import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:garbage_collection_system/Api/userController.dart';
import 'package:garbage_collection_system/custom_widgets/card.dart';
import 'package:garbage_collection_system/screens/company/Companies.dart';
import 'package:garbage_collection_system/screens/user/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Newuserdashboard extends StatefulWidget {
  final String? UserId;
  const Newuserdashboard({super.key, this.UserId});

  @override
  State<Newuserdashboard> createState() => _NewuserdashboardState();
}

class _NewuserdashboardState extends State<Newuserdashboard> {
  int _selectedIndex = 0; // Bottom Nav Index
  String userName = "User Dashboard"; 

  @override
  void initState() {
    super.initState();
    loadUserName();
  }

  Future<void> loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('UserName') ?? "User Dashboard";
    });
  }

  // Check if user is subscribed
  Future<void> isSubscribed() async {
  try {
    final response = await UserApi().checkSubscriptionStatus();

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final bool subscribed = data['isSubscribed'];

      if (subscribed) {
        Navigator.pushNamed(context, '/subscriptionStatus');
      } else {
        // 🔥 NEW: Check companies by location
        final companies = await UserApi().getCompaniesByLocation();

        if (companies.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("No companies available in your area"),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const Viewcompanyservices(),
            ),
          );
        }
      }
    }
  } catch (e) {
    print("Error: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Something went wrong")),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    // Define the pages for the tabs
    final List<Widget> _pages = [
      buildHomeTab(),
      const Profile(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF99C13D),
        selectedItemColor: Colors.black,
        currentIndex: _selectedIndex,
        onTap: (idx) {
          setState(() => _selectedIndex = idx); // Just switch the tab
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  // Home tab with all the dashboard cards
  Widget buildHomeTab() {
    double cardHeight = 200;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            Text(
              'Welcome $userName!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 25),

            // First Row
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: cardHeight,
                    child: CustomCard(
                      title: "Subscription",
                      subtitle:
                          "Subscribe to a company or View your current subscription",
                      icon: Icons.subscriptions,
                      onTap: () {
                        isSubscribed();
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: cardHeight,
                    child: CustomCard(
                      title: "History",
                      subtitle: "Check past collections",
                      icon: Icons.history,
                      onTap: () {
                        Navigator.pushNamed(context, '/viewHistory');
                      },
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Second Row
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: cardHeight,
                    child: CustomCard(
                      title: "Track Pickup",
                      subtitle: "Track your current pickup request",
                      icon: Icons.location_on,
                      onTap: () {
                        Navigator.pushNamed(context, '/trackPickup');
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: cardHeight,
                    child: CustomCard(
                      title: "Extra Pickups",
                      subtitle: "Request additional pickups",
                      icon: Icons.add_circle_outline,
                      onTap: () {
                        Navigator.pushNamed(context, '/extrapickup');
                      },
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Single Card
            SizedBox(
              height: cardHeight,
              child: CustomCard(
                title: "File a Complaint",
                subtitle: "Report an issue with service",
                icon: Icons.report_problem,
                onTap: () {
                  Navigator.pushNamed(context, '/filecomplaint');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}