import 'package:flutter/material.dart';
import 'package:garbage_collection_system/Api/companyController.dart';
import 'package:garbage_collection_system/custom_widgets/button.dart';
import 'package:garbage_collection_system/custom_widgets/card.dart';

class ViewPlans extends StatefulWidget {
  final int companyId;

  const ViewPlans({super.key, required this.companyId});

  @override
  State<ViewPlans> createState() => _ViewPlansState();
}

class _ViewPlansState extends State<ViewPlans> {
  List plans = [];
  bool isLoading = false;
  int? expandedIndex;

  @override
  void initState() {
    super.initState();
    fetchPlans();
  }

  /// Fetch plans from API
  Future<void> fetchPlans() async {
    setState(() => isLoading = true);
    try {
      final result = await CompanyApi().fetchPlans(widget.companyId);
      setState(() {
        plans = result;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to load plans: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// Subscribe to plan using API
  Future<void> subscribePlan(int planId) async {
    setState(() => isLoading = true);
    try {
      final response = await CompanyApi().subscribePlan(
        planId,
        widget.companyId,
      );

      print("Status code: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Subscribed Successfully"),
            backgroundColor: Colors.green,
          ),
        );
      
        setState(() => expandedIndex = null);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Subscription Failed: ${response.body}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error subscribing: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Plans'),
        backgroundColor: const Color(0xFF99C13D),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : plans.isEmpty
          ? const Center(child: Text('No plans found'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: plans.length,
              itemBuilder: (context, index) {
                final plan = plans[index];
                final isExpanded = expandedIndex == index;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: CustomCard(
                    title: plan['Name'],
                    subtitle:
                        "Rs ${plan['MonthlyPrice']}${isExpanded ? '\n\n${plan['Description'] ?? ''}' : ''}",
                    icon: Icons.local_offer,
                    extraWidget: isExpanded
                        ? Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: CustomButton(
                              text: 'Subscribe',
                              onPressed: ()async {
                              await  subscribePlan(plan['PlanID']);
                                if (!mounted) return;
                                 Navigator.pushReplacementNamed(
                                  context,
                                  '/newUserDashboard',
                                );
                              },
                            ),
                          )
                        : null,
                    onTap: () {
                      setState(() {
                        if (isExpanded) {
                          expandedIndex = null;
                        } else {
                          expandedIndex = index;
                        }
                      });
                    },
                  ),
                );
              },
            ),
    );
  }
}
