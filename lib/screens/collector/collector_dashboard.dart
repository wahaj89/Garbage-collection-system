import 'package:flutter/material.dart';
import 'package:garbage_collection_system/custom_widgets/button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:garbage_collection_system/custom_widgets/card.dart';

class CollectorDashboard extends StatefulWidget {
  const CollectorDashboard({super.key});

  @override
  State<CollectorDashboard> createState() => _CollectorDashboardState();
}

class _CollectorDashboardState extends State<CollectorDashboard> {
  int _selectedIndex = 0;

  String name = "Collector";
  String phone = "N/A";
  int id = 0;
  int companyId = 0;

  final Color mainColor = const Color(0xFF99C13D);

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (!mounted) return;

      setState(() {
        name = prefs.getString('UserName') ?? 'Collector';
        phone = prefs.getString('UserPhone') ?? 'N/A';
        id = prefs.getInt('UserId') ?? 0;
        companyId = prefs.getInt('CompanyID') ?? 0;
      });
    } catch (e) {
      debugPrint("SharedPreferences error: $e");
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      buildHomeTab(),
      buildProfileTab(),
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),

      // ================= BOTTOM NAV =================
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        backgroundColor: mainColor,
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
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),

              Text(
                "Welcome $name!",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Collector Dashboard",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 35),

              // ================= SCAN QR ONLY CARD =================
              SizedBox(
                width: 320,
                height: 200,
                child: CustomCard(
                  title: "Scan QR Code",
                  subtitle: "Scan garbage bag QR to verify pickup",
                  icon: Icons.qr_code_scanner,
                  onTap: () {
                    Navigator.pushNamed(context, '/scanQR');
                  },
                ),
              ),

              const SizedBox(height: 20),
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
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.person,
                size: 75,
                color: Colors.black,
              ),

              const SizedBox(height: 12),

              Text(
                name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                "Collector Profile",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 30),

              // ================= PROFILE CARD =================
              SizedBox(
                width: 320,
                child: CustomCard(
                  title: name,
                  subtitle:
                      "Phone: $phone\n"
                      "Collector ID: $id\n"
                      "Company ID: $companyId",
                  icon: Icons.person,
                  onTap: () {},
                ),
              ),

              const SizedBox(height: 30),

              // ================= LOGOUT BUTTON =================
              SizedBox(
                width: 320,
                child: CustomButton(
                  backgroundColor: Colors.red,
                  onPressed: logout,
                  text: "Logout",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}