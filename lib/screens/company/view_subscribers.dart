import 'package:flutter/material.dart';
import 'package:garbage_collection_system/Api/CompanyController.dart';
import 'package:garbage_collection_system/custom_widgets/card.dart'; // your custom card

class ViewSubscribers extends StatefulWidget {
  const ViewSubscribers({super.key});

  @override
  State<ViewSubscribers> createState() => _ViewSubscribersState();
}

class _ViewSubscribersState extends State<ViewSubscribers> {
  List<dynamic> subscribers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSubscribers();
  }

  Future<void> fetchSubscribers() async {
    try {
      final result = await CompanyApi().fetchSubscribers();
      setState(() {
        subscribers = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching subscribers: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Subscribers"),
        backgroundColor: const Color(0xFF99C13D),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : subscribers.isEmpty
              ? const Center(child: Text("No subscribers found."))
              : Padding(
                  padding: const EdgeInsets.all(12),
                  child: ListView.builder(
                    itemCount: subscribers.length,
                    itemBuilder: (context, index) {
                      final sub = subscribers[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: CustomCard(
                          title: sub['UserName'] ?? "Unknown",
                          subtitle:
                              "Email: ${sub['UserEmail']}\nPlan: ${sub['PlanName']}\nStart: ${sub['StartDate']}\nEnd: ${sub['EndDate']}\nStatus: ${sub['Status']}",
                          icon: Icons.person_outline,
                          onTap: () {
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}