import 'package:flutter/material.dart';
import 'package:garbage_collection_system/Api/userController.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool isLoading = true;
  bool actionLoading = false;

  List companies = [];

  String adminEmail = "Admin";

  @override
  void initState() {
    super.initState();
    loadAdminData();
    fetchPendingCompanies();
  }

  Future<void> loadAdminData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      adminEmail = prefs.getString('AdminEmail') ?? "Admin";
    });
  }

  Future<void> fetchPendingCompanies() async {
    try {
      setState(() => isLoading = true);

      final data = await UserApi().getPendingCompanies();

      setState(() {
        companies = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll("Exception:", "")),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> approveCompany(int companyId) async {
    try {
      setState(() => actionLoading = true);

      final message = await UserApi().approveCompany(companyId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
        ),
      );

      fetchPendingCompanies();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll("Exception:", "")),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => actionLoading = false);
    }
  }

  Future<void> rejectCompany(int companyId) async {
    try {
      setState(() => actionLoading = true);

      final message = await UserApi().rejectCompany(companyId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.orange,
        ),
      );

      fetchPendingCompanies();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll("Exception:", "")),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => actionLoading = false);
    }
  }

  Future<void> logoutAdmin() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('AdminID');
    await prefs.remove('AdminEmail');
    await prefs.remove('role');
    await prefs.remove('isAdminLoggedIn');

    if (!mounted) return;

    Navigator.pushReplacementNamed(context, '/adminLogin');
  }

  Widget buildCompanyCard(dynamic company) {
    final int companyId = company['CompanyID'] ?? 0;
    final String companyName = company['CompanyName'] ?? "Company Name";
    final String email = company['Email'] ?? "No Email";
    final String phone = company['Phone'] ?? "No Phone";
    final String address =
        company['Address'] ?? company['Location'] ?? "No Address";

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              companyName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(Icons.email, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(email),
                ),
              ],
            ),

            const SizedBox(height: 6),

            Row(
              children: [
                const Icon(Icons.phone, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(phone),
                ),
              ],
            ),

            const SizedBox(height: 6),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(address),
                ),
              ],
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: actionLoading
                        ? null
                        : () {
                            approveCompany(companyId);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text("Approve"),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: ElevatedButton(
                    onPressed: actionLoading
                        ? null
                        : () {
                            rejectCompany(companyId);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text("Reject"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildEmptyView() {
    return const Center(
      child: Text(
        "No pending companies",
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget buildLoadingView() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: const Color(0xFF99C13D),
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            onPressed: fetchPendingCompanies,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: logoutAdmin,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFD0E5FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Welcome Admin",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  adminEmail,
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  "Pending Companies: ${companies.length}",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              "Pending Companies",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 8),

          Expanded(
            child: isLoading
                ? buildLoadingView()
                : companies.isEmpty
                    ? buildEmptyView()
                    : ListView.builder(
                        itemCount: companies.length,
                        itemBuilder: (context, index) {
                          return buildCompanyCard(companies[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}