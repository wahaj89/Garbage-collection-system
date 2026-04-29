import 'package:flutter/material.dart';
import 'package:garbage_collection_system/Api/companyController.dart';
import 'generatebag_screen.dart';

class ExtraRequestsScreen extends StatefulWidget {
  const ExtraRequestsScreen({super.key});

  @override
  State<ExtraRequestsScreen> createState() => _ExtraRequestsScreenState();
}

class _ExtraRequestsScreenState extends State<ExtraRequestsScreen> {
  List requests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadRequests();
  }

  void loadRequests() async {
    final result = await CompanyApi.viewExtraPickupRequests();

    setState(() {
      isLoading = false;
    });

    if (result.containsKey("error")) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result["error"])));
    } else {
      setState(() {
        requests = result["requests"];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Extra Pickup Requests"),
        backgroundColor: const Color(0xFF99C13D),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : requests.isEmpty
          ? const Center(child: Text("No requests found"))
          : ListView.builder(
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final req = requests[index];

                return Card(
                  margin: const EdgeInsets.all(10),
                  color:  const Color(0xFFD0E5FF),
                  child: ListTile(
                    leading: const Icon(Icons.delete),
                    title: Text("User ID: ${req["UserID"]}"),
                    subtitle: Text("Bags Requested: ${req["BagsRequested"]}"),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GeneratebagScreen(
                            userId: req["UserID"],
                            bags: req["BagsRequested"],
                            bagType: req["Type"],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
