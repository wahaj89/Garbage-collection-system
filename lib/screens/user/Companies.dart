import 'package:flutter/material.dart';
import 'package:garbage_collection_system/Api/userController.dart';
import 'package:garbage_collection_system/custom_widgets/card.dart';
import 'package:garbage_collection_system/screens/user/viewPlans.dart';

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
    fetchCompanyByLocation();
  }

  Future<void> fetchCompanyByLocation() async {
    try {
      setState(() {
        isLoading = true;
        error = '';
      });

      final result = await UserApi().getCompaniesByLocation();

      // ✅ Safety sorting in Flutter too
      result.sort((a, b) {
        final ratingA = getRating(a['AverageRating']);
        final ratingB = getRating(b['AverageRating']);

        final reviewA = getReviewCount(a['TotalReviews']);
        final reviewB = getReviewCount(b['TotalReviews']);

        if (ratingB.compareTo(ratingA) != 0) {
          return ratingB.compareTo(ratingA);
        }

        return reviewB.compareTo(reviewA);
      });

      setState(() {
        companies = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString().replaceAll('Exception:', '').trim();
        isLoading = false;
      });
    }
  }

  double getRating(dynamic value) {
    if (value == null) return 0.0;

    if (value is int) return value.toDouble();
    if (value is double) return value;

    return double.tryParse(value.toString()) ?? 0.0;
  }

  int getReviewCount(dynamic value) {
    if (value == null) return 0;

    if (value is int) return value;

    return int.tryParse(value.toString()) ?? 0;
  }

  String getCompanySubtitle(dynamic company) {
    final description = company['Description'] ?? 'No Description';

    final rating = getRating(company['AverageRating']);
    final totalReviews = getReviewCount(company['TotalReviews']);

    if (totalReviews == 0) {
      return '$description\n⭐ No rating yet';
    }

    return '$description\n⭐ ${rating.toStringAsFixed(1)} ($totalReviews reviews)';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Companies'),
        backgroundColor: const Color(0xFF99C13D),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      error,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                )
              : companies.isEmpty
                  ? const Center(
                      child: Text(
                        'No companies available in your area 😔',
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: fetchCompanyByLocation,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: companies.length,
                        itemBuilder: (context, index) {
                          final company = companies[index];

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: CustomCard(
                              title: company['Name'] ?? 'No Name',
                              subtitle: getCompanySubtitle(company),
                              icon: Icons.business,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ViewPlans(
                                      companyId: company['CompanyID'],
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}