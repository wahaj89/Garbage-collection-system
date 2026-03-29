import 'package:flutter/material.dart';
import 'package:garbage_collection_system/custom_widgets/card.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Newuserdashboard extends StatefulWidget {
  final String? UserId;
  const Newuserdashboard({super.key, this.UserId});

  @override
  State<Newuserdashboard> createState() => _NewuserdashboardState();
}

class _NewuserdashboardState extends State<Newuserdashboard> {
  int _selectedIndex = 0;
  String userName = "User Dashboard"; // default before loading

  @override
  void initState() {
    super.initState();
    loadUserName();
  }

  Future<void> loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // Try SharedPreferences first, fallback to widget param
      userName = prefs.getString('UserName') ?? "User Dashboard";
    });
  }

  @override
  Widget build(BuildContext context) {
    double cardHeight = 200;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Center(child: Text('User Dashboard')),
        backgroundColor: const Color(0xFF99C13D),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              Text(
                'Welcome $userName!',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 25),

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
                          Navigator.pushNamed(context, '/viewcompanies');
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
                          Navigator.pushNamed(context, '/subscribe');
                        },
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

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
                          Navigator.pushNamed(context, '/extraPickups');
                        },
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

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
      ),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF99C13D),
        selectedItemColor: Colors.black,
        currentIndex: _selectedIndex,
        onTap: (idx) {
          setState(() => _selectedIndex = idx); // switch pages
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
}