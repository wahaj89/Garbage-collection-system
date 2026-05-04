import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:garbage_collection_system/Api/userController.dart';
import 'package:garbage_collection_system/custom_widgets/button.dart';
import 'package:garbage_collection_system/custom_widgets/card.dart';
import 'package:garbage_collection_system/screens/user/viewPlans.dart';

class SubscriptionStatus extends StatefulWidget {
  const SubscriptionStatus({super.key});

  @override
  State<SubscriptionStatus> createState() => _SubscriptionStatusState();
}

class _SubscriptionStatusState extends State<SubscriptionStatus> {
  Map<String, dynamic>? subscriptionData;
  bool isLoading = true;
  bool isCancelling = false;

  @override
  void initState() {
    super.initState();
    fetchSubscriptionDetails();
  }

  // 🔹 Fetch Subscription
  Future<void> fetchSubscriptionDetails() async {
    try {
      final response = await UserApi().fetchSubscriptionDetails();
      final data = jsonDecode(response.body);

      setState(() {
        subscriptionData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  // 🔹 Cancel Subscription API
  Future<void> cancelSubscription() async {
  setState(() => isCancelling = true);

  try {
    final subscriptionId = subscriptionData?['SubscriptionID'];
    final companyId = subscriptionData?['CompanyID'];

    if (subscriptionId == null || companyId == null) {
      throw Exception("SubscriptionID or CompanyID is null");
    }

    final response = await UserApi().cancelSubscription(
      SubscriptionID: subscriptionId,
      CompanyID: companyId,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(response['message'] ?? "Subscription cancelled"),
        backgroundColor: Colors.green,
      ),
    );

    setState(() {
      subscriptionData = null;
    });

  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Error: $e"),
        backgroundColor: Colors.red,
      ),
    );
  } finally {
    setState(() => isCancelling = false);
  }
}

  void showCancelDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cancel Subscription"),
        content: const Text("Are you sure you want to cancel your subscription?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await cancelSubscription();
            },
            child: const Text("Yes"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Subscription Status"),
        backgroundColor: const Color(0xFF99C13D),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())

          : subscriptionData == null
              ? const Center(
                  child: Text(
                    "No Active Subscription",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                )

              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [

                      // 📄 Subscription Card
                      CustomCard(
                        title: "Subscription Details",
                        subtitle:
                            "Company ID: ${subscriptionData!['CompanyID']}\n\n"
                            "Plan ID: ${subscriptionData!['PlanID']}\n\n"
                            "Start Date: ${subscriptionData!['StartDate']}\n\n"
                            "End Date: ${subscriptionData!['EndDate']}\n\n"
                            "Status: ${subscriptionData!['Status']}",
                        icon: Icons.assignment,
                        onTap: () {},
                      ),

                      const SizedBox(height: 20),

                      // 🔴 Cancel Button
                      isCancelling
                          ? const Center(child: CircularProgressIndicator())
                          : CustomButton(
                              text: "Cancel Subscription",
                              backgroundColor: Colors.red,
                              icon: Icons.cancel,
                              onPressed: showCancelDialog,
                            ),

                      const SizedBox(height: 10),

                      // 🔵 Change Subscription Button
                      CustomButton(
                        text: "Change Subscription",
                        backgroundColor: const Color(0xFF99C13D),
                        icon: Icons.swap_horiz,
                        onPressed: () {
                          // 👉 Navigate to plans screen
                            Navigator.pushNamed(context, '/viewcompanies');
                      
                        },
                      ),
                    ],
                  ),
                ),
    );
  }
}