import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:garbage_collection_system/custom_widgets/card.dart';

class DriverDashboard extends StatefulWidget {
  const DriverDashboard({super.key});

  @override
  State<DriverDashboard> createState() => _DriverDashboardState();
}

class _DriverDashboardState extends State<DriverDashboard> {
  int _selectedIndex = 0;

  String driverName = "Driver";
  String phone = "";
  String license = "";

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      driverName = prefs.getString('UserName') ?? "Driver";
      phone = prefs.getString('UserPhone') ?? "N/A";
      license = prefs.getString('LicenseNo') ?? "N/A";
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      buildHomeTab(),
      buildProfileTab(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F3),

      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),

      // ================= BOTTOM NAV =================
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        backgroundColor: const Color(0xFF99C13D),
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }

  // ================= HOME TAB =================
  Widget buildHomeTab() {
    double cardHeight = 165;

    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 25),

              Text(
                "Welcome $driverName!",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Manage your assigned work",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: 320,
                height: cardHeight,
                child: CustomCard(
                  title: "Today's Schedule",
                  subtitle: "View today's routes & timing",
                  icon: Icons.schedule,
                  onTap: () {
                    Navigator.pushNamed(context, '/todaysSchedule');
                  },
                ),
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: 320,
                height: cardHeight,
                child: CustomCard(
                  title: "Pickup Points",
                  subtitle: "See all assigned locations",
                  icon: Icons.location_on,
                  onTap: () {
                    Navigator.pushNamed(context, '/pickupPoints');
                  },
                ),
              ),

              const SizedBox(height: 25),
                SizedBox(
                width: 320,
                height: cardHeight,
                child: CustomCard(
                  title: "Apply for Leave",
                  subtitle: "Apply for leave or time off",
                  icon: Icons.beach_access,
                  onTap: () {
                    Navigator.pushNamed(context, '/applyLeave');
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= PROFILE TAB =================
  Widget buildProfileTab() {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 25),

              const Text(
                "Driver Profile",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 25),

              // ================= SINGLE PROFILE CARD =================
              SizedBox(
                height: 260,
                width: 320,
                child: CustomCard(
                  title: driverName,
                  subtitle:
                      "Phone: $phone\n"
                      "License No: $license",
                  icon: Icons.person,
                  onTap: () {},
                ),
              ),

              const SizedBox(height: 30),

              // ================= LOGOUT BUTTON =================
              SizedBox(
                width: 320,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.clear();

                    if (!mounted) return;
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: const Text(
                    "Logout",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }
}