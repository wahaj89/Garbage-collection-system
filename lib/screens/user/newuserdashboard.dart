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

class _NewuserdashboardState extends State<Newuserdashboard>
    with WidgetsBindingObserver {
  int _selectedIndex = 0;

  String userName = "User Dashboard";

  List<Map<String, dynamic>> scheduledPickups = [];

  bool isLoadingPickup = true;
  bool isRefreshing = false;

  String pickupMessage = "";

  static const Color appColor = Color(0xFF99C13D);
  static const Color backgroundColor = Color(0xFFF7F9F5);
  static const Color cardColor = Color(0xFFD0E5FF);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    refreshDashboardData(showLoader: true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// App background se wapas aaye to dashboard reload
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      refreshDashboardData(showLoader: true);
    }
  }

  Future<void> refreshDashboardData({bool showLoader = false}) async {
    if (isRefreshing) return;

    isRefreshing = true;

    try {
      if (showLoader && mounted) {
        setState(() {
          isLoadingPickup = true;
          pickupMessage = "";
        });
      }

      await loadUserName();
      await loadScheduledPickup();
    } finally {
      isRefreshing = false;
    }
  }

  Future<void> loadUserName() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      userName = prefs.getString('UserName') ?? "User Dashboard";
    });
  }

  /// Ye function har type ka response handle karega:
  /// { pickups: [] }
  /// { pickup: {} }
  /// [ {}, {} ]
  /// { single schedule object }
  List<Map<String, dynamic>> normalizePickupData(dynamic data) {
    if (data == null) return [];

    if (data is List) {
      return data
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    if (data is Map) {
      final map = Map<String, dynamic>.from(data);

      final possibleMessage = map['message'];
      if (possibleMessage != null) {
        pickupMessage = possibleMessage.toString();
      }

      final possibleList =
          map['pickups'] ?? map['schedules'] ?? map['data'] ?? map['result'];

      if (possibleList is List) {
        return possibleList
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }

      final possibleSingle = map['pickup'] ?? map['schedule'];

      if (possibleSingle is Map) {
        return [Map<String, dynamic>.from(possibleSingle)];
      }

      if (map.containsKey('ScheduleID') ||
          map.containsKey('DayOfWeek') ||
          map.containsKey('StartTime') ||
          map.containsKey('EndTime') ||
          map.containsKey('CompanyName')) {
        return [map];
      }
    }

    return [];
  }

  Future<void> loadScheduledPickup() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      if (token.isEmpty) {
        if (!mounted) return;

        setState(() {
          scheduledPickups = [];
          pickupMessage = "Login token not found";
          isLoadingPickup = false;
        });

        return;
      }

      final data = await UserApi().getScheduledPickup();

      pickupMessage = "";

      final normalizedData = normalizePickupData(data);

      if (!mounted) return;

      setState(() {
        scheduledPickups = normalizedData;
        isLoadingPickup = false;
      });
    } catch (e) {
      print("Pickup fetch error: $e");

      if (!mounted) return;

      setState(() {
        scheduledPickups = [];
        pickupMessage = "Failed to load pickup schedule. Pull down to retry.";
        isLoadingPickup = false;
      });
    }
  }

  Future<void> openNamedRoute(String routeName) async {
    await Navigator.pushNamed(context, routeName);

    if (!mounted) return;

    await refreshDashboardData(showLoader: true);
  }

  Future<void> isSubscribed() async {
    try {
      List<Map<String, dynamic>> subscriptions = [];

      try {
        subscriptions = await UserApi().fetchSubscriptionDetails();
      } catch (e) {
        print("Subscription details error: $e");
        subscriptions = [];
      }

      if (!mounted) return;

      if (subscriptions.isNotEmpty) {
        await Navigator.pushNamed(context, '/subscriptionStatus');

        if (!mounted) return;

        await refreshDashboardData(showLoader: true);
      } else {
        final companies = await UserApi().getCompaniesByLocation();

        if (!mounted) return;

        if (companies.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("No companies available in your area"),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const Viewcompanyservices(),
            ),
          );

          if (!mounted) return;

          await refreshDashboardData(showLoader: true);
        }
      }
    } catch (e) {
      print("Subscription button error: $e");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String getText(
    Map<String, dynamic> item,
    List<String> keys,
    String fallback,
  ) {
    for (final key in keys) {
      final value = item[key];

      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }

    return fallback;
  }

  String getCompanyName(Map<String, dynamic> item) {
    return getText(
      item,
      [
        'CompanyName',
        'companyName',
        'Name',
        'name',
        'Company',
        'company',
      ],
      'Company',
    );
  }

  String getDriverName(Map<String, dynamic> item) {
    return getText(
      item,
      [
        'DriverName',
        'driverName',
        'FullName',
        'fullName',
        'CollectorName',
        'collectorName',
      ],
      '',
    );
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

  Widget buildAppDrawer() {
    return Drawer(
      backgroundColor: backgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 22),
              decoration: const BoxDecoration(
                color: appColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(22),
                  bottomRight: Radius.circular(22),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 58,
                    width: 58,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.45),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 34,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    userName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Welcome to your service panel",
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            drawerItem(
              icon: Icons.home_outlined,
              title: "Home",
              subtitle: "Go back to dashboard",
              onTap: () async {
                Navigator.pop(context);

                setState(() {
                  _selectedIndex = 0;
                });

                await refreshDashboardData(showLoader: true);
              },
            ),

            drawerItem(
              icon: Icons.star_rate_rounded,
              title: "Rate Your Company",
              subtitle: "Share your experience with your service provider",
              onTap: () async {
                Navigator.pop(context);
                await openNamedRoute('/rateCompany');
              },
            ),

            drawerItem(
              icon: Icons.report_problem_outlined,
              title: "File a Complaint",
              subtitle: "Report a service issue",
              onTap: () async {
                Navigator.pop(context);
                await openNamedRoute('/filecomplaint');
              },
            ),

            drawerItem(
              icon: Icons.history,
              title: "Pickup History",
              subtitle: "View your previous collections",
              onTap: () async {
                Navigator.pop(context);
                await openNamedRoute('/viewHistory');
              },
            ),

            const Spacer(),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.black12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.eco_outlined,
                      color: Colors.black87,
                      size: 24,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Cleaner city starts with your feedback.",
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget drawerItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.black.withOpacity(0.06),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: appColor.withOpacity(0.22),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Colors.black,
                  size: 24,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Colors.black45,
              ),
            ],
          ),
        ),
      ),
    );
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

    if (scheduledPickups.isEmpty) {
      return Container(
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black12),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.info_outline,
              color: Colors.black54,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                pickupMessage.isNotEmpty
                    ? pickupMessage
                    : "No pickup scheduled for today",
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                ),
              ),
            ),
            IconButton(
              onPressed: () async {
                await refreshDashboardData(showLoader: true);
              },
              icon: const Icon(
                Icons.refresh,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: appColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                child: Text(
                  scheduledPickups.length == 1
                      ? "Today's Pickup Schedule"
                      : "Today's Pickup Schedules (${scheduledPickups.length})",
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              IconButton(
                onPressed: () async {
                  await refreshDashboardData(showLoader: true);
                },
                icon: const Icon(
                  Icons.refresh,
                  color: Colors.black,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          ...scheduledPickups.map((pickup) {
            final String companyName = getCompanyName(pickup);

            final String driverName = getDriverName(pickup);

            final String day = getText(
              pickup,
              ['DayOfWeek', 'dayOfWeek', 'day'],
              'N/A',
            );

            final String startTime = formatTime(
              pickup['StartTime'] ?? pickup['startTime'],
            );

            final String endTime = formatTime(
              pickup['EndTime'] ?? pickup['endTime'],
            );

            return Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.35),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.business,
                    color: Colors.black,
                    size: 20,
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          companyName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          "$day • $startTime - $endTime",
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 13,
                          ),
                        ),

                        if (driverName.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            "Driver: $driverName",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
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
      drawer: buildAppDrawer(),

      appBar: AppBar(
        backgroundColor: appColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        title: _selectedIndex == 0
            ? const Text(
                "User Dashboard",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              )
            : const SizedBox.shrink(),
      ),

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
        onTap: (idx) async {
          setState(() {
            _selectedIndex = idx;
          });

          if (idx == 0) {
            await refreshDashboardData(showLoader: true);
          }
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
    return RefreshIndicator(
      color: appColor,
      onRefresh: () async {
        await refreshDashboardData(showLoader: true);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),

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
                    onTap: () async {
                      await isSubscribed();
                    },
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: dashboardCard(
                    title: "History",
                    subtitle: "Check past collections",
                    icon: Icons.history,
                    onTap: () async {
                      await openNamedRoute('/viewHistory');
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
                    onTap: () async {
                      await openNamedRoute('/trackPickup');
                    },
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: dashboardCard(
                    title: "Extra Pickups",
                    subtitle: "Request additional pickups",
                    icon: Icons.add_circle_outline,
                    onTap: () async {
                      await openNamedRoute('/extrapickup');
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
              onTap: () async {
                await openNamedRoute('/filecomplaint');
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}