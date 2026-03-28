import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:garbage_collection_system/Api/userController.dart';
import 'package:garbage_collection_system/custom_widgets/card.dart';

class ViewAllUser extends StatefulWidget {
  const ViewAllUser({super.key});

  @override
  State<ViewAllUser> createState() => _ViewAllUserState();
}

class _ViewAllUserState extends State<ViewAllUser> {
  List users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      final response = await UserApi().fetchSubscribedUsers();

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          users = data;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Error: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Subscribed Users"),
        backgroundColor: const Color(0xFF99C13D),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : users.isEmpty
                ? const Center(child: Text("No Subscribed Users"))
                : ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: CustomCard(
                          title: user["FullName"] ?? "No Name",
                          subtitle: user["Email"] ?? "",
                          icon: Icons.person,
                          onTap: () {
                            print("User tapped: ${user["UserID"]}");
                          },

                          extraWidget: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              Text(
                                "Phone: ${user["Phone"] ?? ""}",
                                style: const TextStyle(fontSize: 13),
                              ),
                              Text(
                                "Address: ${user["Address"] ?? ""}",
                                style: const TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}