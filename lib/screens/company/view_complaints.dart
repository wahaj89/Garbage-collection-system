import 'package:flutter/material.dart';
import 'package:garbage_collection_system/Api/CompanyController.dart';
import 'package:garbage_collection_system/custom_widgets/button.dart';
import 'package:garbage_collection_system/custom_widgets/card.dart';

class ViewComplaints extends StatefulWidget {
  const ViewComplaints({super.key});

  @override
  State<ViewComplaints> createState() => _ViewComplaintsState();
}

class _ViewComplaintsState extends State<ViewComplaints> {
  int currentIndex = 0;

  List resolved = [];
  List pending = [];

  bool isLoading = true;
  bool isResolving = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final data = await CompanyApi.getComplaints();

      setState(() {
        resolved = data['resolved'] ?? [];
        pending = data['pending'] ?? [];
        isLoading = false;
      });
    } catch (e) {
      print(e);

      setState(() {
        isLoading = false;
      });
    }
  }

  // Resolve complaint from DB + UI
  Future<void> resolveComplaint(Map complaint) async {
    try {
      setState(() {
        isResolving = true;
      });

      final success = await CompanyApi.resolveComplaint(
        complaint['ComplaintID'],
      );

      if (success) {
        setState(() {
          pending.removeWhere(
            (item) => item['ComplaintID'] == complaint['ComplaintID'],
          );

          complaint['Status'] = 'Resolved';

          resolved.insert(0, complaint);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Complaint marked as resolved")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to resolve complaint")),
        );
      }
    } catch (e) {
      print(e);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Something went wrong")));
    } finally {
      setState(() {
        isResolving = false;
      });
    }
  }

  Widget buildCard(Map complaint, {bool isPending = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: CustomCard(
        title: complaint['Subject'] ?? '',
        subtitle: complaint['Description'] ?? '',
        icon: complaint['Status'] == 'Resolved'
            ? Icons.check_circle
            : Icons.pending_actions,
        onTap: () {},

        extraWidget: Column(
          children: [
            const SizedBox(height: 8),

            Text(
              complaint['Status'],
              style: TextStyle(
                color: complaint['Status'] == 'Resolved'
                    ? Colors.green
                    : Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              complaint['CreatedAt'].toString().substring(0, 10),
              style: const TextStyle(fontSize: 12),
            ),

            // Button only for pending complaints
            if (isPending) ...[
              const SizedBox(height: 12),

              CustomButton(
                text: isResolving ? "Please Wait..." : "Mark as Resolved",

                onPressed: () async {
                  if (isResolving) return;

                  await resolveComplaint(complaint);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget buildList(List list, {bool isPending = false}) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (list.isEmpty) {
      return const Center(child: Text("No Complaints"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: list.length,
      itemBuilder: (context, index) {
        return buildCard(list[index], isPending: isPending);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          currentIndex == 0 ? "Resolved Complaints" : "Pending Complaints",
        ),
        backgroundColor: const Color(0xFF99C13D),
      ),

      body: currentIndex == 0
          ? buildList(resolved)
          : buildList(pending, isPending: true),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: const Color(0xFF99C13D),

        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle),
            label: "Resolved",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pending_actions),
            label: "Pending",
          ),
        ],
      ),
    );
  }
}
