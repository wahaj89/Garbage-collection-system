import 'package:flutter/material.dart';
import 'package:garbage_collection_system/Api/userController.dart';
import 'package:garbage_collection_system/custom_widgets/button.dart';
import 'package:garbage_collection_system/custom_widgets/inputfield.dart';

class ExtraPickups extends StatefulWidget {
  const ExtraPickups({super.key});

  @override
  State<ExtraPickups> createState() => _ExtraPickupsState();
}

class _ExtraPickupsState extends State<ExtraPickups> with WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController bagsController = TextEditingController();

  static const Color appColor = Color(0xFF99C13D);
  static const Color fieldColor = Color(0xFFD0E5FF);

  final int costPerBag = 20;

  bool isLoading = true;
  bool isSubmitting = false;
  bool hasError = false;
  String errorMessage = "";

  List<Map<String, dynamic>> companies = [];
  List requests = [];

  int? selectedCompanyId;
  DateTime? selectedRequestedFor;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    bagsController.addListener(() {
      if (mounted) setState(() {});
    });

    loadData(showLoader: true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    bagsController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      loadData(showLoader: false);
    }
  }

  int get selectedBags {
    return int.tryParse(bagsController.text.trim()) ?? 0;
  }

  int get totalCost {
    return selectedBags * costPerBag;
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

  String dateToApiFormat(DateTime date) {
    return "${date.year}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.day.toString().padLeft(2, '0')}";
  }

  String dateToViewFormat(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.year}";
  }

  Future<void> pickRequestedForDate() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: selectedRequestedFor ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 1),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: appColor,
              onPrimary: Colors.black,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedRequestedFor = picked;
      });
    }
  }

  Future<void> loadData({bool showLoader = false}) async {
    if (showLoader && mounted) {
      setState(() {
        isLoading = true;
        hasError = false;
        errorMessage = "";
      });
    }

    try {
      List<Map<String, dynamic>> companyData = [];
      List requestData = [];

      try {
        companyData = await UserApi().getUserSubscribedCompanies();
      } catch (e) {
        debugPrint("Company loading error: $e");
      }

      try {
        requestData = await UserApi().getMyExtraPickupRequests();
      } catch (e) {
        debugPrint("Requests loading error: $e");
      }

      final validCompanies = companyData.where((company) {
        return getCompanyId(company) != null;
      }).toList();

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
        requests = requestData;
        selectedCompanyId = newSelectedCompanyId;

        isLoading = false;
        hasError = false;
        errorMessage = "";
      });
    } catch (e) {
      debugPrint("Extra pickup loading error: $e");

      if (!mounted) return;

      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = e.toString();
      });
    }
  }

  Future<void> submitRequest() async {
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

    if (selectedRequestedFor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select requested date"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isSubmitting = true);

    try {
      final success = await UserApi().requestExtraPickup(
        companyId: selectedCompanyId!,
        bags: int.parse(bagsController.text.trim()),
        requestedFor: dateToApiFormat(selectedRequestedFor!),
      );

      if (!mounted) return;

      setState(() => isSubmitting = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Request Submitted Successfully | Total: $totalCost PKR"),
            backgroundColor: Colors.green,
          ),
        );

        bagsController.clear();

        setState(() {
          selectedRequestedFor = null;
        });

        await loadData(showLoader: false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to submit request"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint("Submit extra pickup error: $e");

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

  Widget requestedForPicker() {
    return SizedBox(
      width: 370,
      child: InkWell(
        onTap: pickRequestedForDate,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          decoration: BoxDecoration(
            color: fieldColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  selectedRequestedFor == null
                      ? "Select Requested Date"
                      : dateToViewFormat(selectedRequestedFor!),
                  style: TextStyle(
                    color: selectedRequestedFor == null
                        ? Colors.grey
                        : Colors.black,
                    fontSize: 16,
                  ),
                ),
              ),
              const Icon(
                Icons.calendar_month,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget priceBox() {
    return SizedBox(
      width: 370,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: fieldColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black12),
        ),
        child: Column(
          children: [
            priceRow("Cost Per Bag", "$costPerBag PKR"),
            const SizedBox(height: 8),
            priceRow("Bags", selectedBags.toString()),
            const Divider(height: 22),
            priceRow("Total Cost", "$totalCost PKR", isBold: true),
          ],
        ),
      ),
    );
  }

  Widget priceRow(String title, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.black87,
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: Colors.black,
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
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

  int toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  String formatDate(dynamic value) {
    if (value == null) return "N/A";

    final date = DateTime.tryParse(value.toString());

    if (date == null) return value.toString();

    final local = date.toLocal();

    return "${local.day.toString().padLeft(2, '0')}-"
        "${local.month.toString().padLeft(2, '0')}-"
        "${local.year}";
  }

  Color statusColor(String status) {
    final s = status.toLowerCase();

    if (s == "approved") return Colors.green;
    if (s == "rejected") return Colors.red;
    if (s == "completed") return Colors.blue;

    return Colors.orange;
  }

  Widget requestCard(dynamic item) {
    final companyName = item["CompanyName"]?.toString() ?? "Company";
    final bags = toInt(item["BagsRequested"]);
    final charge = item["Charge"] != null ? toInt(item["Charge"]) : bags * costPerBag;
    final status = item["Status"]?.toString() ?? "Pending";
    final type = item["Type"]?.toString() ?? "Extra Pickup";
    final requestedFor = formatDate(item["Requestedfor"]);
    final color = statusColor(status);

    return SizedBox(
      width: 370,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.local_shipping, color: Colors.black87),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    companyName,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            detailRow("Type", type),
            detailRow("Bags", bags.toString()),
            detailRow("Charge", "$charge PKR"),
            detailRow("Requested For", requestedFor),
          ],
        ),
      ),
    );
  }

  Widget detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 13,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget requestsList() {
    if (requests.isEmpty) {
      return emptyMessage("No extra pickup requests yet");
    }

    return Column(
      children: requests.map((item) {
        return requestCard(item);
      }).toList(),
    );
  }

  Widget buildErrorView() {
    return RefreshIndicator(
      color: appColor,
      onRefresh: () async {
        await loadData(showLoader: false);
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
            "Failed to load extra pickup data",
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
              await loadData(showLoader: true);
            },
          ),
        ],
      ),
    );
  }

  Widget buildExtraPickupForm() {
    return RefreshIndicator(
      color: appColor,
      onRefresh: () async {
        await loadData(showLoader: false);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Center(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 35),

                  Image.asset(
                    'assets/app_icon.jpg',
                    width: 170,
                    height: 170,
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Request Extra Pickup",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    "Extra bag cost: 20 PKR per bag",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 28),

                  companies.isEmpty
                      ? emptyMessage("No active subscribed company found")
                      : companyDropdown(),

                  const SizedBox(height: 20),

                  requestedForPicker(),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: 370,
                    child: CustomInput(
                      label: "Number of Bags",
                      controller: bagsController,
                      keyboardType: TextInputType.number,
                      suffixIcon: const Icon(Icons.shopping_bag),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Enter number of bags";
                        }

                        final bags = int.tryParse(value.trim());

                        if (bags == null) {
                          return "Enter valid number";
                        }

                        if (bags <= 0) {
                          return "Bags must be greater than 0";
                        }

                        return null;
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  priceBox(),

                  const SizedBox(height: 25),

                  isSubmitting
                      ? const CircularProgressIndicator(
                          color: appColor,
                        )
                      : CustomButton(
                          text: "Submit Request",
                          icon: Icons.send,
                          onPressed: submitRequest,
                        ),

                  const SizedBox(height: 30),

                  const SizedBox(
                    width: 370,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "My Requests",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  requestsList(),

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
      body = buildExtraPickupForm();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Extra Pickup",
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