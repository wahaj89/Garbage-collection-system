import 'package:flutter/material.dart';
import 'package:garbage_collection_system/Api/CompanyController.dart';
import 'package:garbage_collection_system/custom_widgets/card.dart';

class ViewPlans extends StatefulWidget {
  const ViewPlans({super.key});

  @override
  State<ViewPlans> createState() => _ViewPlansState();
}

class _ViewPlansState extends State<ViewPlans> {
  List plans = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPlans();
  }

  Future<void> fetchPlans() async {
    try {
      final data = await CompanyApi().viewPlans();

      print("API DATA: $data"); // 👈 debug

      setState(() {
        plans = data;
        isLoading = false;
      });
    } catch (e) {
      print("Failed to fetch plans: $e");
      setState(() {
        isLoading = false;
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription Plans'),
        backgroundColor: const Color(0xFF99C13D),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : plans.isEmpty
                ? const Center(child: Text("No Plans Available"))
                : ListView.builder(
                    itemCount: plans.length,
                    itemBuilder: (context, index) {
                      final plan = plans[index];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: CustomCard(
                          title: plan["Name"] ?? "Plan",
                          subtitle: "Rs ${plan["MonthlyPrice"]}",
                          icon: Icons.recycling,
                          onTap: (){
                            
                          },
                          extraWidget: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),

                              Text(
                                "📦 Bags/Day: ${plan["BagsPerDay"]}",
                                style: const TextStyle(fontSize: 13),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                "📝 ${plan["Description"] ?? ""}",
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