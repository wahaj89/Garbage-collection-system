import 'package:flutter/material.dart';
import 'package:garbage_collection_system/Api/userController.dart';
import 'package:garbage_collection_system/custom_widgets/button.dart';
import 'package:garbage_collection_system/custom_widgets/inputfield.dart';

class Fileacomplaint extends StatefulWidget {
  const Fileacomplaint({super.key});

  @override
  State<Fileacomplaint> createState() => _FileacomplaintState();
}

class _FileacomplaintState extends State<Fileacomplaint>
    with WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController descriptionController = TextEditingController();

  bool isLoading = true;
  bool isSubmitting = false;
  bool hasError = false;
  String errorMessage = "";

  List<Map<String, dynamic>> companies = [];
  List<Map<String, dynamic>> pickups = [];

  int? selectedCompanyId;
  Map<String, dynamic>? selectedPickup;
  String? selectedAgainst;

  static const Color appColor = Color(0xFF99C13D);
  static const Color fieldColor = Color(0xFFD0E5FF);

  final List<String> complaintSubjects = [
    "Late Arrival",
    "Garbage Not Collected",
    "Collector Did Not Visit",
    "Rude Behavior",
    "Incomplete Pickup",
    "Wrong Pickup Time",
    "Vehicle Did Not Arrive",
    "Other Service Issue",
  ];

  String? selectedSubject;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    selectedSubject = complaintSubjects.first;
    loadDropdownData(showLoader: true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    descriptionController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      loadDropdownData(showLoader: false);
    }
  }

  int? getCompanyId(Map<String, dynamic> data) {
    final id = data["CompanyID"] ??
        data["companyID"] ??
        data["companyId"] ??
        data["CompanyId"] ??
        data["id"] ??
        data["ID"];

    if (id == null) return null;
    return int.tryParse(id.toString());
  }

  String getCompanyName(Map<String, dynamic> company) {
    final name = company["CompanyName"] ??
        company["companyName"] ??
        company["Name"] ??
        company["name"] ??
        company["Company"] ??
        company["company"];

    return name?.toString() ?? "Unknown Company";
  }

  String getDriverName(Map<String, dynamic>? pickup) {
    if (pickup == null) return "";

    final name = pickup["DriverName"] ??
        pickup["driverName"] ??
        pickup["FullName"] ??
        pickup["fullName"] ??
        pickup["CollectorName"] ??
        pickup["collectorName"];

    if (name != null && name.toString().trim().isNotEmpty) {
      return name.toString();
    }

    final id = pickup["DriverID"] ??
        pickup["driverID"] ??
        pickup["DriverId"] ??
        pickup["driverId"];

    if (id != null) {
      return "Driver ID: $id";
    }

    return "";
  }

  List<Map<String, dynamic>> normalizePickups(dynamic data) {
    if (data == null) return [];

    if (data is List) {
      return data
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    if (data is Map) {
      final map = Map<String, dynamic>.from(data);

      final possibleList = map["pickups"] ??
          map["pickupList"] ??
          map["schedules"] ??
          map["data"] ??
          map["result"];

      if (possibleList is List) {
        return possibleList
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }

      final possibleSingle = map["pickup"] ?? map["schedule"];

      if (possibleSingle is Map) {
        return [Map<String, dynamic>.from(possibleSingle)];
      }

      if (map.containsKey("CompanyID") ||
          map.containsKey("companyId") ||
          map.containsKey("DriverID") ||
          map.containsKey("DriverName")) {
        return [map];
      }
    }

    return [];
  }

  void updateSelectedPickupByCompany(int? companyId) {
    if (companyId == null) {
      selectedPickup = null;
      selectedAgainst = null;
      return;
    }

    Map<String, dynamic>? matchedPickup;

    for (final pickup in pickups) {
      final pickupCompanyId = getCompanyId(pickup);

      if (pickupCompanyId == companyId) {
        matchedPickup = pickup;
        break;
      }
    }

    if (matchedPickup == null && companies.length == 1 && pickups.length == 1) {
      matchedPickup = pickups.first;
    }

    selectedPickup = matchedPickup;

    final driverName = getDriverName(matchedPickup);
    selectedAgainst = driverName.isNotEmpty ? driverName : null;

    debugPrint("SELECTED COMPANY ID: $companyId");
    debugPrint("ALL PICKUPS: $pickups");
    debugPrint("MATCHED PICKUP: $matchedPickup");
    debugPrint("SELECTED AGAINST: $selectedAgainst");
  }

  Future<void> loadDropdownData({bool showLoader = false}) async {
    if (showLoader && mounted) {
      setState(() {
        isLoading = true;
        hasError = false;
        errorMessage = "";
      });
    }

    try {
      List<Map<String, dynamic>> companyData = [];
      dynamic pickupResponse;

      try {
        companyData = await UserApi().getUserSubscribedCompanies();
      } catch (e) {
        debugPrint("Company loading error: $e");
      }

      try {
        pickupResponse = await UserApi().getScheduledPickup();
      } catch (e) {
        debugPrint("Pickup loading error: $e");
      }

      debugPrint("COMPANY DATA: $companyData");
      debugPrint("PICKUP RESPONSE: $pickupResponse");

      final validCompanies = companyData.where((company) {
        return getCompanyId(company) != null;
      }).toList();

      final pickupList = normalizePickups(pickupResponse);

      int? newSelectedCompanyId = selectedCompanyId;

      if (validCompanies.isNotEmpty) {
        final exists = validCompanies.any(
          (company) => getCompanyId(company) == selectedCompanyId,
        );

        if (!exists) {
          newSelectedCompanyId = getCompanyId(validCompanies.first);
        }
      } else {
        newSelectedCompanyId = null;
      }

      if (!mounted) return;

      setState(() {
        companies = validCompanies;
        pickups = pickupList;
        selectedCompanyId = newSelectedCompanyId;

        updateSelectedPickupByCompany(selectedCompanyId);

        isLoading = false;
        hasError = false;
        errorMessage = "";
      });
    } catch (e) {
      debugPrint("Dropdown loading error: $e");

      if (!mounted) return;

      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = e.toString();
      });
    }
  }

  Future<void> submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedCompanyId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select company"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (selectedPickup == null || selectedAgainst == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No assigned driver found for selected company"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (selectedSubject == null || selectedSubject!.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select subject"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isSubmitting = true);

    try {
      final success = await UserApi().submitComplaint1(
        companyId: selectedCompanyId!,
        subject: selectedSubject!,
        description: descriptionController.text.trim(),
        against: selectedAgainst!,
      );

      if (!mounted) return;

      setState(() => isSubmitting = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Complaint Submitted Successfully"),
            backgroundColor: Colors.green,
          ),
        );

        setState(() {
          selectedSubject = complaintSubjects.first;
        });

        descriptionController.clear();

        await loadDropdownData(showLoader: false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to submit complaint"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint("Submit complaint error: $e");

      if (!mounted) return;

      setState(() => isSubmitting = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  InputDecoration dropdownDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      suffixIcon: Icon(icon, color: Colors.grey),
      filled: true,
      fillColor: fieldColor,
      labelStyle: const TextStyle(
        color: Colors.grey,
        fontSize: 15,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 18,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: appColor,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 1,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 1.5,
        ),
      ),
    );
  }

  Widget companyDropdown() {
    return SizedBox(
      width: 370,
      child: DropdownButtonFormField<int>(
        value: selectedCompanyId,
        isExpanded: true,
        dropdownColor: const Color(0xFFF3F3F3),
        icon: const Icon(
          Icons.keyboard_arrow_down,
          color: Colors.grey,
        ),
        decoration: dropdownDecoration(
          label: "Select Company",
          icon: Icons.business,
        ),
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16,
        ),
        items: companies
            .map((company) {
              final companyId = getCompanyId(company);
              final companyName = getCompanyName(company);

              if (companyId == null) return null;

              return DropdownMenuItem<int>(
                value: companyId,
                child: Text(
                  companyName,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
              );
            })
            .whereType<DropdownMenuItem<int>>()
            .toList(),
        onChanged: (value) {
          setState(() {
            selectedCompanyId = value;
            updateSelectedPickupByCompany(value);
          });
        },
        validator: (value) {
          if (value == null) {
            return "Please select company";
          }
          return null;
        },
      ),
    );
  }

  Widget assignedDriverCard() {
    final driverName = selectedAgainst ?? "No assigned driver";

    return SizedBox(
      width: 370,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: fieldColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selectedPickup == null ? Colors.red.shade200 : Colors.black12,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.person,
              color: Colors.black87,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: selectedPickup == null
                  ? const Text(
                      "No assigned driver found for selected company",
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Assigned Driver",
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          "Name: $driverName",
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget subjectDropdown() {
    return SizedBox(
      width: 370,
      child: DropdownButtonFormField<String>(
        value: selectedSubject,
        isExpanded: true,
        dropdownColor: const Color(0xFFF3F3F3),
        icon: const Icon(
          Icons.keyboard_arrow_down,
          color: Colors.grey,
        ),
        decoration: dropdownDecoration(
          label: "Subject",
          icon: Icons.subject,
        ),
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16,
        ),
        items: complaintSubjects.map((subject) {
          return DropdownMenuItem<String>(
            value: subject,
            child: Text(
              subject,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            selectedSubject = value;
          });
        },
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return "Please select subject";
          }
          return null;
        },
      ),
    );
  }

  Widget emptyMessage(String text) {
    return SizedBox(
      width: 370,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.red,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget buildErrorView() {
    return RefreshIndicator(
      color: appColor,
      onRefresh: () async {
        await loadDropdownData(showLoader: false);
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 120),
          const Icon(
            Icons.wifi_off,
            color: Colors.red,
            size: 70,
          ),
          const SizedBox(height: 15),
          const Text(
            "Failed to load complaint data",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),
          CustomButton(
            text: "Retry",
            icon: Icons.refresh,
            backgroundColor: appColor,
            onPressed: () async {
              await loadDropdownData(showLoader: true);
            },
          ),
        ],
      ),
    );
  }

  Widget buildComplaintForm() {
    return RefreshIndicator(
      color: appColor,
      onRefresh: () async {
        await loadDropdownData(showLoader: false);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  Image.asset(
                    'assets/app_icon.jpg',
                    width: 200,
                    height: 200,
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "File a Complaint",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 30),

                  companies.isEmpty
                      ? emptyMessage("No active subscribed company found")
                      : companyDropdown(),

                  const SizedBox(height: 20),

                  assignedDriverCard(),

                  const SizedBox(height: 20),

                  subjectDropdown(),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: 370,
                    child: CustomInput(
                      label: "Description",
                      controller: descriptionController,
                      suffixIcon: const Icon(Icons.description),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Description is required";
                        }
                        if (value.trim().length < 10) {
                          return "Minimum 10 characters required";
                        }
                        return null;
                      },
                    ),
                  ),

                  const SizedBox(height: 25),

                  isSubmitting
                      ? const CircularProgressIndicator(
                          color: appColor,
                        )
                      : CustomButton(
                          text: "Submit Complaint",
                          icon: Icons.report_problem,
                          onPressed: submitForm,
                        ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget body;

    if (isLoading) {
      body = const Center(
        child: CircularProgressIndicator(
          color: appColor,
        ),
      );
    } else if (hasError) {
      body = buildErrorView();
    } else {
      body = buildComplaintForm();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "File Complaint",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: appColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: body,
    );
  }
}