import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:garbage_collection_system/Api/userController.dart';
import 'package:garbage_collection_system/custom_widgets/card.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Map<String, dynamic>? userData;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: const Text("Profile")),
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF99C13D),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : userData == null
              ? const Center(child: Text("No user data found"))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 350, 
                    child: CustomCard(
                      title: " ${userData!['FullName'] ?? "N/A"}",
                      subtitle: 
                          "Email: ${userData!['Email'] ?? "N/A"}\n\n"
                          "Phone: ${userData!['Phone'] ?? "N/A"}\n\n"
                          "Subscription: ${userData!['isSubscribed'] == true ? "Active" : "Not Subscribed"}",
                      icon: Icons.person,
                      onTap: () {
                        Navigator.pushNamed(context, '/editProfile');
                      },
                    ),
                  ),
                ),
    );
  }
}