import 'package:flutter/material.dart';
import 'package:garbage_collection_system/Api/collectorcontroller.dart';
import 'package:garbage_collection_system/custom_widgets/card.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ViewCollectorsScreen extends StatefulWidget {
  const ViewCollectorsScreen({super.key});

  @override
  State<ViewCollectorsScreen> createState() => _ViewCollectorsScreenState();
}

class _ViewCollectorsScreenState extends State<ViewCollectorsScreen> {
  List collectors = [];
  bool isLoading = true;
  int companyId = 0;

  @override
  void initState() {
    super.initState();
    initLoad();
  }

  Future<void> initLoad() async {
    final pref = await SharedPreferences.getInstance();
    companyId = pref.getInt('CompanyID') ?? 0;

    await loadCollectors();
  }

  Future<void> loadCollectors() async {
    try {
      final data = await CollectorApi().viewCollectors();

      setState(() {
        collectors = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Collectors"),
        backgroundColor: const Color(0xFF99C13D),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : collectors.isEmpty
              ? const Center(child: Text("No Collectors Found"))
              : Padding(
                  padding: const EdgeInsets.all(12),
                  child: ListView.builder(
                    itemCount: collectors.length,
                    itemBuilder: (context, index) {
                      final c = collectors[index];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: CustomCard(
                          title: c['FullName'] ?? "No Name",
                          subtitle:
                              "Phone: ${c['Phone'] ?? "N/A"}\nID: ${c['CollectorID']}",
                          icon: Icons.person,
                          onTap: () {},
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}