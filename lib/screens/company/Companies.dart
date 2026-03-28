import 'package:flutter/material.dart';
import 'package:garbage_collection_system/Api/companyController.dart';
import 'package:garbage_collection_system/Api/userController.dart';
import 'package:garbage_collection_system/custom_widgets/card.dart';
import 'package:garbage_collection_system/screens/company/company_services.dart';

import 'package:garbage_collection_system/screens/company/viewPlans.dart';

class Viewcompanyservices extends StatefulWidget {
  const Viewcompanyservices({super.key});

  @override
  State<Viewcompanyservices> createState() => _ViewcompanyservicesState();
}

class _ViewcompanyservicesState extends State<Viewcompanyservices> {
  List companies = [];
  bool isLoading = false;
  String error = '';

  @override
  void initState() {
    super.initState();
    fetchCompany();
  }

  Future<void> fetchCompany() async {
    try {
      setState(() {
        isLoading = true;
        error = '';
      });

      final result = await CompanyApi().fetchCompanies();

      setState(() {
        companies = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Companies'),
        backgroundColor: const Color(0xFF99C13D),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error.isNotEmpty
              ? Center(child: Text(error))
              : companies.isEmpty
                  ? const Center(child: Text('No companies found'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: companies.length,
                      itemBuilder: (context, index) {
                        final company = companies[index];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: CustomCard(
                            title: company['Name'],
                            subtitle: company['Email'],
                            icon: Icons.business,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CompanyServices(
  
                                    companyId: company['CompanyID'],
                                    companyName:company['CompanyName'],
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