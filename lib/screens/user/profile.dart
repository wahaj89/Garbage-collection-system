import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:garbage_collection_system/Api/userController.dart';
import 'package:garbage_collection_system/custom_widgets/card.dart';
import 'package:garbage_collection_system/custom_widgets/button.dart'; // update path as needed

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
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          userData = data;
          subscriptionData = data['Subscription'];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
      print("Error fetching profile: $e");
    }
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isActive = subscriptionData != null;
    final String subscriptionText = isActive
        ? "Active (Plan #${subscriptionData!['PlanID']})\n"
            "From: ${subscriptionData!['StartDate'].toString().split('T')[0]}\n"
            "To:     ${subscriptionData!['EndDate'].toString().split('T')[0]}"
        : "Not Subscribed";

    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text("Profile")),
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF99C13D),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : userData == null
              ? const Center(child: Text("No user data found"))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Profile Card
                      SizedBox(
                        width: double.infinity,
                        height: 350,
                        child: CustomCard(
                          title: "${userData!['FullName'] ?? 'N/A'}",
                          subtitle: "Email: ${userData!['Email'] ?? 'N/A'}\n\n"
                              "Phone: ${userData!['Phone'] ?? 'N/A'}\n\n"
                              "Subscription: $subscriptionText",
                          icon: Icons.person,
                          onTap: () {
                            Navigator.pushNamed(context, '/editProfile');
                          },
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Logout Button
                      SizedBox(
                        width: double.infinity,
                        child: CustomButton(
                          text: "Logout",
                          icon: Icons.logout,
                          backgroundColor: Colors.red,
                          onPressed: _handleLogout,
                        ),
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
    );
  }
}