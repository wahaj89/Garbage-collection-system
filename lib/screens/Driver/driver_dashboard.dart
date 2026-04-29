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
 int vehicle =0;

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
      vehicle = prefs.getInt('VehicleID')!;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      buildHomeTab(),
      buildProfileTab(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),

      // ================= BOTTOM NAV =================
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        backgroundColor: const Color(0xFF99C13D),
        selectedItemColor: Colors.black,
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
    double cardHeight = 180;

    return Center(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),

            Text(
              "Welcome $driverName!",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
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

            const SizedBox(height: 20),

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

            const SizedBox(height: 20),

            SizedBox(
              width: 320,
              height: cardHeight,
              child: CustomCard(
                title: "Start Navigation",
                subtitle: "Navigate to next point",
                icon: Icons.navigation,
                onTap: () {
                  Navigator.pushNamed(context, '/navigation');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= PROFILE TAB =================
Widget buildProfileTab() {
  return Center(
    child: SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 40),

          // ================= SINGLE PROFILE CARD =================
          SizedBox(
            height: 320
            ,
            width: 320,
            child: CustomCard(
              
              title: driverName,
              subtitle:
                  "Phone: $phone\n"
                  "LicenseNO: $license\n"
                  "VehicleID: $vehicle",
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
              ),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();

                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text(
                "Logout",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    ),
  );
}
}