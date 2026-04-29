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
  String phone = "";
  int id = 0;
  int companyId = 0;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
 
    setState(() {
     
         name = prefs.getString('UserName') ?? 'Collector';
         phone = prefs.getString('UserPhone') ?? 'N/A';
         id = prefs.getInt('UserId') ?? 0;
        companyId = prefs.getInt('CompanyID') ?? 0;
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
    return Center(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),

            Text(
              "Welcome $name!",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

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
    );
  }

Widget buildProfileTab() {
  return FutureBuilder(
    future: SharedPreferences.getInstance(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }

      final prefs = snapshot.data!;

      final name = prefs.getString('UserName') ?? 'Collector';
      final phone = prefs.getString('UserPhone') ?? 'N/A';
      final id = prefs.getInt('UserId') ?? 0;
      final companyId = prefs.getInt('CompanyID') ?? 0;

      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // ================= PROFILE CARD =================
            SizedBox(
              width: 320,
              child: CustomCard(
                title: name,
                subtitle:
                    " Phone: $phone\n"
                    " Collector ID: $id\n"
                    " Company ID: $companyId",
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
               
                
                
                onPressed: () async {
                  await prefs.clear();
                  Navigator.pushReplacementNamed(context, '/login');
                },
                text: "Logout",
              ),
            ),
          ],
        ),
      );
    },
  );
}}