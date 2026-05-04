import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:garbage_collection_system/Api/userController.dart';
import 'package:garbage_collection_system/custom_widgets/card.dart';
import 'package:garbage_collection_system/screens/user/Companies.dart';
import 'package:garbage_collection_system/screens/user/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Newuserdashboard extends StatefulWidget {
  final String? UserId;
  const Newuserdashboard({super.key, this.UserId});

  @override
  State<Newuserdashboard> createState() => _NewuserdashboardState();
}

class _NewuserdashboardState extends State<Newuserdashboard> {
  int _selectedIndex = 0;
  String userName = "User Dashboard";
  Map<String, dynamic>? scheduledPickup;
  bool isLoadingPickup = true;

  @override
  void initState() {
    super.initState();
    loadUserName();
    loadScheduledPickup();
  }

  Future<void> loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('UserName') ?? "User Dashboard";
    });
  }

  Future<void> loadScheduledPickup() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      if (token.isEmpty) {
        setState(() => isLoadingPickup = false);
        return;
      }
      final data = await UserApi().getScheduledPickup();
      setState(() {
        scheduledPickup = data;
        isLoadingPickup = false;
      });
    } catch (e) {
      print("Pickup fetch error: $e");
      setState(() {
        scheduledPickup = null;
        isLoadingPickup = false;
      });
    }
  }

  Future<void> isSubscribed() async {
    try {
      final response = await UserApi().checkSubscriptionStatus();
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final bool subscribed = data['isSubscribed'];
        if (subscribed) {
          Navigator.pushNamed(context, '/subscriptionStatus');
        } else {
          final companies = await UserApi().getCompaniesByLocation();
          if (companies.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text("No companies available in your area")),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const Viewcompanyservices()),
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

  // ✅ Fixed time formatter — handles "06:00:00.0000000" format
 String formatTime(dynamic raw) {
  if (raw == null) return 'N/A';

  try {
    String value = raw.toString();

    int hour = 0;
    int minute = 0;

    // ✅ Case 1: ISO format (1970-01-01T06:00:00.000Z)
    if (value.contains('T')) {
      final dt = DateTime.parse(value).toLocal();
      hour = dt.hour;
      minute = dt.minute;
    } 
    // ✅ Case 2: Normal time (06:00:00.0000000)
    else {
      final cleaned = value.split('.')[0]; // remove nanoseconds
      final parts = cleaned.split(':');

      if (parts.length < 2) return value;

      hour = int.tryParse(parts[0]) ?? 0;
      minute = int.tryParse(parts[1]) ?? 0;
    }

    // ✅ Convert to 12-hour format
    final period = hour >= 12 ? 'PM' : 'AM';

    if (hour == 0) {
      hour = 12;
    } else if (hour > 12) {
      hour -= 12;
    }

    final minStr = minute.toString().padLeft(2, '0');

    return '$hour:$minStr $period';
  } catch (e) {
    print("Time error: $e");
    return raw.toString();
  }
}
  Widget buildScheduledPickupBanner() {
    // ── Loading state ──
    if (isLoadingPickup) {
      return Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFEAF4FF),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Row(
          children: [
            SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text("Checking your schedule..."),
          ],
        ),
      );
    }

    // ── No pickup state ──
    if (scheduledPickup == null) {
      return Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black12),
        ),
        child: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.black45, size: 22),
            SizedBox(width: 12),
            Text(
              "No pickup scheduled for today",
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      );
    }

    // ── Parse fields ──
    final String day       = scheduledPickup!['DayOfWeek'] ?? 'N/A';
    final String startTime = formatTime(scheduledPickup!['StartTime']);
    final String endTime   = formatTime(scheduledPickup!['EndTime']);
    final bool   isActive  = scheduledPickup!['Active'] == true || scheduledPickup!['Active'] == 1;
    final String status    = isActive ? 'Active' : 'Inactive';

    // ── Pickup banner ──
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF99C13D), Color(0xFF99C13D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF99C13D).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon box
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.local_shipping_outlined,
              size: 28,
            ),
          ),

          const SizedBox(width: 14),

          // Day + time info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Today's Pickup Schedule",
                  style: TextStyle(
                  
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  day,
                  style: const TextStyle(
                    
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "$startTime – $endTime",
                  style: const TextStyle(
                  
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),        
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
        onTap: (idx) => setState(() => _selectedIndex = idx),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

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
            const SizedBox(height: 20),

            // Scheduled pickup banner
            buildScheduledPickupBanner(),

            // First Row
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: cardHeight,
                    child: CustomCard(
                      title: "Subscription",
                      subtitle: "Subscribe to a company or View your current subscription",
                      icon: Icons.subscriptions,
                      onTap: () => isSubscribed(),
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
                      onTap: () => Navigator.pushNamed(context, '/viewHistory'),
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
                      onTap: () => Navigator.pushNamed(context, '/trackPickup'),
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
                      onTap: () => Navigator.pushNamed(context, '/extrapickup'),
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
                onTap: () => Navigator.pushNamed(context, '/filecomplaint'),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}