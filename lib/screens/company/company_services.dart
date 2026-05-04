import 'package:flutter/material.dart';
import 'package:garbage_collection_system/Api/companyController.dart';
import 'package:garbage_collection_system/custom_widgets/card.dart';
import 'package:garbage_collection_system/screens/user/viewPlans.dart';

class CompanyServices extends StatefulWidget {
  final int companyId;
  final String? companyName;

  const CompanyServices({super.key, required this.companyId,  this.companyName});

  @override
  State<CompanyServices> createState() => _CompanyServicesState();
}

class _CompanyServicesState extends State<CompanyServices> {
  List services = [];
  bool isLoading = false;
  String error = '';
  int? expandedIndex; // <-- track which card is expanded

  @override
  void initState() {
    super.initState();
    fetchCompanyServices();
  }

  Future<void> fetchCompanyServices() async {
    try {
      setState(() {
        isLoading = true;
        error = '';
      });

      final result = await CompanyApi().fetchCompanyServices(widget.companyId);

      setState(() {
        services = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
      print("Error fetching services: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.companyName ?? ''),
        backgroundColor: const Color(0xFF99C13D),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error.isNotEmpty
              ? Center(child: Text(error))
              : services.isEmpty
                  ? const Center(child: Text("No services found"))
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: services.length,
                      itemBuilder: (context, index) {
                        final service = services[index];
                        final isExpanded = expandedIndex == index;

                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          margin: const EdgeInsets.only(bottom: 12),
                          child: CustomCard(
                            title: service['Name'] ?? 'No Name',
                            subtitle: service['Description'] ?? '',
                            icon: Icons.miscellaneous_services,
                            extraWidget: isExpanded
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 12),
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => ViewPlans(
                                                companyId: widget.companyId,
                                              ),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF99C13D),
                                        ),
                                        child: const Text("View Plans"),
                                      ),
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