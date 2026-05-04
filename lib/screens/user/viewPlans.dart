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
  List recyclablePlans = [];
  List nonRecyclablePlans = [];

  bool isLoading = false;
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchPlans();
  }

  // ✅ Fetch Plans
  Future<void> fetchPlans() async {
    setState(() => isLoading = true);

    try {
      final result = await CompanyApi().fetchPlans(widget.companyId);

      setState(() {
        plans = result;

        // ✅ Separate plans safely (case-insensitive)
        recyclablePlans = plans.where((p) {
          return (p['Type'] ?? '')
                  .toString()
                  .toLowerCase()
                  .contains('recyclable') &&
              !(p['Type'] ?? '')
                  .toString()
                  .toLowerCase()
                  .contains('non');
        }).toList();

        nonRecyclablePlans = plans.where((p) {
          return (p['Type'] ?? '')
              .toString()
              .toLowerCase()
              .contains('non');
        }).toList();
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

  // ✅ Subscribe
  Future<void> subscribePlan(int planId) async {
    setState(() => isLoading = true);

    try {
      final response = await CompanyApi().subscribePlan(
        planId,
        widget.companyId,
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Subscribed Successfully"),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacementNamed(context, '/newUserDashboard');
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

  // ✅ Current tab plans
  List get currentPlans {
    return selectedIndex == 0 ? recyclablePlans : nonRecyclablePlans;
  }

  // ✅ UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          selectedIndex == 0
              ? 'Recyclable Plans'
              : 'Non-Recyclable Plans',
        ),
        backgroundColor: const Color(0xFF99C13D),
      ),

      // ✅ BODY
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : currentPlans.isEmpty
              ? const Center(child: Text('No plans found'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: currentPlans.length,
                  itemBuilder: (context, index) {
                    final plan = currentPlans[index];

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: CustomCard(
                        title: plan['Name'] ?? 'No Name',
                        subtitle:
                            " Price: Rs ${plan['MonthlyPrice']}\n"
                            " Bags Per Day: ${plan['BagsPerDay'] ?? 'N/A'}\n\n"
                            " Description:\n${plan['Description'] ?? 'No description available'}",
                        icon: selectedIndex == 0
                            ? Icons.recycling
                            : Icons.delete,
                        extraWidget: Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: CustomButton(
                            text: 'Subscribe',
                            onPressed: () async {
                              await subscribePlan(plan['PlanID']);
                            },
                          ),
                        ),
                        onTap: () {},
                      ),
                    );
                  },
                ),

      // ✅ BOTTOM NAVIGATION
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        selectedItemColor: Colors.black,
        backgroundColor:const Color(0xFF99C13D) ,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.recycling),
            label: 'Recyclable',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.delete),
            label: 'Non-Recyclable',
          ),
        ],
      ),
    );
  }
}