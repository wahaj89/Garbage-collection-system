import 'package:flutter/material.dart';
import 'package:garbage_collection_system/Api/CompanyController.dart';
import 'package:garbage_collection_system/custom_widgets/card.dart';
import 'package:garbage_collection_system/screens/company/generatebag_screen.dart';

class ViewSubscribers extends StatefulWidget {
  const ViewSubscribers({super.key});

  @override
  State<ViewSubscribers> createState() => _ViewSubscribersState();
}

class _ViewSubscribersState extends State<ViewSubscribers> {
  List<dynamic> activeSubscribers = [];
  List<dynamic> inactiveSubscribers = [];

  bool isLoading = true;
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchSubscribers();
  }

  Future<void> fetchSubscribers() async {
    try {
      final result = await CompanyApi().fetchSubscribers();

      setState(() {
        activeSubscribers = result["active"];
        inactiveSubscribers = result["inactive"];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error fetching subscribers: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> currentList = selectedIndex == 0
        ? activeSubscribers
        : inactiveSubscribers;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          selectedIndex == 0 ? "Active Subscribers" : "Inactive Subscribers",
        ),
        backgroundColor: const Color(0xFF99C13D),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : currentList.isEmpty
          ? const Center(child: Text("No subscribers found."))
          : Padding(
              padding: const EdgeInsets.all(12),
              child: ListView.builder(
                itemCount: currentList.length,
                itemBuilder: (context, index) {
                  final sub = currentList[index];
                  print(sub);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: CustomCard(
                      title: sub['UserName'] ?? "Unknown",
                      subtitle:
                          "Email: ${sub['UserEmail']}\n"
                          "Plan: ${sub['PlanName']}\n"
                          "Start: ${sub['StartDate']}\n"
                          "End: ${sub['EndDate']}\n"
                          "Status: ${sub['Status']}\n"
                          "Type: ${sub['Type']}",
                      icon: selectedIndex == 0
                          ? Icons.verified_user
                          : Icons.cancel,

               onTap: () {
  final userIdRaw = sub['UserID'];
  final bagsRaw = sub['BagsPerDay'];
  final bagTypeRaw = sub['Type']; // 👈 ADD THIS

  final int userId = userIdRaw is int
      ? userIdRaw
      : int.tryParse(userIdRaw.toString()) ?? 0;

  final int bags = bagsRaw is int
      ? bagsRaw
      : int.tryParse(bagsRaw.toString()) ?? 1;

  final String bagType = bagTypeRaw ?? "Recyclable"; // 👈 default fallback

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => GeneratebagScreen(
        userId: userId,
        bags: bags,
        bagType: bagType, // 👈 PASS HERE
      ),
    ),
  );
}
                    ),
                  );
                },
              ),
            ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        backgroundColor: const Color(0xFF99C13D),
        selectedItemColor: const Color(0xFF000000),
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle),
            label: "Active",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.cancel), label: "Inactive"),
        ],
      ),
    );
  }
}
