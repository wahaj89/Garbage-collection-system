import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:garbage_collection_system/Api/userController.dart';
import 'package:garbage_collection_system/custom_widgets/card.dart';
import 'package:garbage_collection_system/custom_widgets/button.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Map<String, dynamic>? userData;
  Map<String, dynamic>? subscriptionData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    try {
      final response = await UserApi().fetchUserDetails();

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          userData = data;
          subscriptionData = data['Subscription'];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      debugPrint("Error fetching profile: $e");
    }
  }

  String formatDate(dynamic date) {
    if (date == null) return "N/A";

    try {
      return date.toString().split('T')[0];
    } catch (e) {
      return "N/A";
    }
  }

  String getSubscriptionText() {
    if (subscriptionData == null) {
      return "Not Subscribed";
    }

    return "Active Plan #${subscriptionData!['PlanID'] ?? 'N/A'}\n"
        "From: ${formatDate(subscriptionData!['StartDate'])}\n"
        "To: ${formatDate(subscriptionData!['EndDate'])}";
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);

                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              },
              child: const Text(
                "Logout",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String fullName = userData?['FullName'] ?? 'N/A';
    final String email = userData?['Email'] ?? 'N/A';
    final String phone = userData?['Phone'] ?? 'N/A';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
        automaticallyImplyLeading: false,
       
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF99C13D),
              ),
            )
          : userData == null
              ? const Center(
                  child: Text(
                    "No user data found",
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: CustomCard(
                          title: fullName,
                          subtitle: "Email: $email\n\n"
                              "Phone: $phone\n\n"
                              "Subscription: ${getSubscriptionText()}",
                          icon: Icons.person,
                          onTap: () {
                            Navigator.pushNamed(context, '/editProfile');
                          },
                        ),
                      ),

                      const SizedBox(height: 22),

                      SizedBox(
                        width: double.infinity,
                        child: CustomButton(
                          text: "Logout",
                          icon: Icons.logout,
                          backgroundColor: Colors.red,
                          onPressed: _handleLogout,
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}