import 'package:flutter/material.dart';
import 'package:garbage_collection_system/Api/userController.dart';
import 'package:garbage_collection_system/custom_widgets/button.dart';

class SubscriptionStatus extends StatefulWidget {
  const SubscriptionStatus({super.key});

  @override
  State<SubscriptionStatus> createState() => _SubscriptionStatusState();
}

class _SubscriptionStatusState extends State<SubscriptionStatus>
    with WidgetsBindingObserver {
  List<Map<String, dynamic>> subscriptions = [];

  bool isLoading = true;
  bool hasError = false;
  String errorMessage = "";
  final Set<int> cancellingIds = {};

  static const Color appColor = Color(0xFF99C13D);
  static const Color backgroundColor = Color(0xFFF7F9F5);
  static const Color cardColor = Color(0xFFD0E5FF);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    fetchSubscriptionDetails(showLoader: true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// App background se wapas aaye to reload
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      fetchSubscriptionDetails(showLoader: false);
    }
  }

  Future<void> fetchSubscriptionDetails({bool showLoader = false}) async {
    try {
      if (showLoader && mounted) {
        setState(() {
          isLoading = true;
          hasError = false;
          errorMessage = "";
        });
      }

      final data = await UserApi().fetchSubscriptionDetails();

      if (!mounted) return;

      setState(() {
        subscriptions = data;
        isLoading = false;
        hasError = false;
        errorMessage = "";
      });
    } catch (e) {
      print("Subscription fetch error: $e");

      if (!mounted) return;

      setState(() {
        subscriptions = [];
        isLoading = false;
        hasError = true;
        errorMessage = e.toString();
      });
    }
  }

  Future<void> cancelSubscription(Map<String, dynamic> subscription) async {
    final subscriptionId = subscription['SubscriptionID'];
    final companyId = subscription['CompanyID'];

    if (subscriptionId == null || companyId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("SubscriptionID or CompanyID is missing"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      cancellingIds.add(subscriptionId);
    });

    try {
      final response = await UserApi().cancelSubscription(
        SubscriptionID: subscriptionId,
        CompanyID: companyId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message'] ?? "Subscription cancelled"),
          backgroundColor: Colors.green,
        ),
      );

      await fetchSubscriptionDetails(showLoader: false);
    } catch (e) {
      print("Cancel subscription error: $e");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        cancellingIds.remove(subscriptionId);
      });
    }
  }

  void showCancelDialog(Map<String, dynamic> subscription) {
    final companyName = getCompanyName(subscription);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cancel Subscription"),
        content: Text(
          "Are you sure you want to cancel subscription of $companyName?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await cancelSubscription(subscription);
            },
            child: const Text(
              "Yes",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  String getCompanyName(Map<String, dynamic> subscription) {
    return subscription['CompanyName']?.toString() ??
        subscription['companyName']?.toString() ??
        subscription['Name']?.toString() ??
        subscription['name']?.toString() ??
        "N/A";
  }

  String formatDate(dynamic rawDate) {
    if (rawDate == null) return "N/A";

    try {
      final date = DateTime.parse(rawDate.toString()).toLocal();

      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final year = date.year.toString();

      return "$day-$month-$year";
    } catch (e) {
      return rawDate.toString();
    }
  }

  Widget buildSubscriptionCard(Map<String, dynamic> subscription) {
    final int subscriptionId = subscription['SubscriptionID'] ?? 0;
    final bool isCancelling = cancellingIds.contains(subscriptionId);
    final String companyName = getCompanyName(subscription);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: appColor.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.business,
                  color: Colors.black,
                  size: 28,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  companyName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  subscription['Status']?.toString() ?? "Active",
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          buildInfoRow(
            icon: Icons.business,
            title: "Company Name",
            value: companyName,
          ),

          buildInfoRow(
            icon: Icons.card_membership,
            title: "Plan ID",
            value: subscription['PlanID']?.toString() ?? "N/A",
          ),

          buildInfoRow(
            icon: Icons.calendar_today,
            title: "Start Date",
            value: formatDate(subscription['StartDate']),
          ),

          buildInfoRow(
            icon: Icons.event,
            title: "End Date",
            value: formatDate(subscription['EndDate']),
          ),

          const SizedBox(height: 14),

          isCancelling
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Colors.red,
                  ),
                )
              : CustomButton(
                  text: "Cancel Subscription",
                  backgroundColor: Colors.red,
                  icon: Icons.cancel,
                  onPressed: () {
                    showCancelDialog(subscription);
                  },
                ),
        ],
      ),
    );
  }

  Widget buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.black87,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          const SizedBox(width: 10),

          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildEmptyView() {
    return RefreshIndicator(
      color: appColor,
      onRefresh: () async {
        await fetchSubscriptionDetails(showLoader: false);
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 100),

          Icon(
            Icons.subscriptions_outlined,
            size: 70,
            color: Colors.black.withOpacity(0.35),
          ),

          const SizedBox(height: 14),

          const Text(
            "No Active Subscription",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            "You currently have no active subscription.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),

          const SizedBox(height: 18),

          CustomButton(
            text: "View Companies",
            backgroundColor: appColor,
            icon: Icons.business,
            onPressed: () async {
              await Navigator.pushNamed(context, '/viewcompanies');

              if (!mounted) return;

              await fetchSubscriptionDetails(showLoader: true);
            },
          ),
        ],
      ),
    );
  }

  Widget buildErrorView() {
    return RefreshIndicator(
      color: appColor,
      onRefresh: () async {
        await fetchSubscriptionDetails(showLoader: false);
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 100),

          const Icon(
            Icons.wifi_off,
            size: 70,
            color: Colors.red,
          ),

          const SizedBox(height: 14),

          const Text(
            "Failed to load subscriptions",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            errorMessage,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
            ),
          ),

          const SizedBox(height: 18),

          CustomButton(
            text: "Retry",
            backgroundColor: appColor,
            icon: Icons.refresh,
            onPressed: () async {
              await fetchSubscriptionDetails(showLoader: true);
            },
          ),
        ],
      ),
    );
  }

  Widget buildSubscriptionList() {
    return RefreshIndicator(
      color: appColor,
      onRefresh: () async {
        await fetchSubscriptionDetails(showLoader: false);
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            "Active Subscriptions (${subscriptions.length})",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            "All your active company subscriptions are shown below.",
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),

          const SizedBox(height: 18),

          ...subscriptions.map(buildSubscriptionCard),

          const SizedBox(height: 10),

          CustomButton(
            text: "Change / Add Subscription",
            backgroundColor: appColor,
            icon: Icons.swap_horiz,
            onPressed: () async {
              await Navigator.pushNamed(context, '/viewcompanies');

              if (!mounted) return;

              await fetchSubscriptionDetails(showLoader: true);
            },
          ),

          const SizedBox(height: 20),
        ],
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
    } else if (subscriptions.isEmpty) {
      body = buildEmptyView();
    } else {
      body = buildSubscriptionList();
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          "Subscription Status",
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