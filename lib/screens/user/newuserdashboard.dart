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

  static const Color appColor = Color(0xFF99C13D);
  static const Color backgroundColor = Color(0xFFF7F9F5);

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
        const SnackBar(
          content: Text("Something went wrong"),
        ),
      );
    }
  }

  String formatTime(dynamic raw) {
    if (raw == null) return 'N/A';

    try {
      String value = raw.toString();

      int hour = 0;
      int minute = 0;

      if (value.contains('T')) {
        final dt = DateTime.parse(value).toLocal();
        hour = dt.hour;
        minute = dt.minute;
      } else {
        final cleaned = value.split('.')[0];
        final parts = cleaned.split(':');

        if (parts.length < 2) return value;

        hour = int.tryParse(parts[0]) ?? 0;
        minute = int.tryParse(parts[1]) ?? 0;
      }

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
    if (isLoadingPickup) {
      return Container(
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black12),
        ),
        child: const Row(
          children: [
            SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: appColor,
              ),
            ),
            SizedBox(width: 12),
            Text(
              "Checking your schedule...",
              style: TextStyle(
                color: Colors.black87,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    if (scheduledPickup == null) {
      return Container(
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black12),
        ),
        child: const Row(
          children: [
            Icon(
              Icons.info_outline,
              color: Colors.black54,
              size: 22,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                "No pickup scheduled for today",
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final String day = scheduledPickup!['DayOfWeek'] ?? 'N/A';
    final String startTime = formatTime(scheduledPickup!['StartTime']);
    final String endTime = formatTime(scheduledPickup!['EndTime']);

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: appColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Container(
            height: 45,
            width: 45,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.35),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.local_shipping_outlined,
              color: Colors.black,
              size: 27,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Today's Pickup Schedule",
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  day,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  "$startTime - $endTime",
                  style: const TextStyle(
                    color: Colors.black,
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

  Widget dashboardCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 185,
      child: CustomCard(
        title: title,
        subtitle: subtitle,
        icon: icon,
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      buildHomeTab(),
      const Profile(),
    ];

    return Scaffold(
      backgroundColor: backgroundColor,

      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: appColor,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
        currentIndex: _selectedIndex,
        onTap: (idx) {
          setState(() {
            _selectedIndex = idx;
          });
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

  Widget buildHomeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 45),

          Text(
            'Welcome $userName!',
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            "Manage your services easily",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),

          const SizedBox(height: 20),

          buildScheduledPickupBanner(),

          Row(
            children: [
              Expanded(
                child: dashboardCard(
                  title: "Subscription",
                  subtitle: "Subscribe or view your current plan",
                  icon: Icons.subscriptions,
                  onTap: () => isSubscribed(),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: dashboardCard(
                  title: "History",
                  subtitle: "Check past collections",
                  icon: Icons.history,
                  onTap: () {
                    Navigator.pushNamed(context, '/viewHistory');
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          Row(
            children: [
              Expanded(
                child: dashboardCard(
                  title: "Track Pickup",
                  subtitle: "Track your current pickup request",
                  icon: Icons.location_on,
                  onTap: () {
                    Navigator.pushNamed(context, '/trackPickup');
                  },
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: dashboardCard(
                  title: "Extra Pickups",
                  subtitle: "Request additional pickups",
                  icon: Icons.add_circle_outline,
                  onTap: () {
                    Navigator.pushNamed(context, '/extrapickup');
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          dashboardCard(
            title: "File a Complaint",
            subtitle: "Report an issue with service",
            icon: Icons.report_problem,
            onTap: () {
              Navigator.pushNamed(context, '/filecomplaint');
            },
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}