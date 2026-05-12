import 'package:flutter/material.dart';
import 'package:garbage_collection_system/Api/userController.dart';
import 'package:garbage_collection_system/custom_widgets/card.dart';

class ViewHistory extends StatefulWidget {
  const ViewHistory({super.key});

  @override
  State<ViewHistory> createState() => _ViewHistoryState();
}

class _ViewHistoryState extends State<ViewHistory> {
  List pickups = [];
  bool isLoading = true;

  static const Color appColor = Color(0xFF99C13D);
  static const Color backgroundColor = Color(0xFFF7F9F5);

  @override
  void initState() {
    super.initState();
    loadPickups();
  }

  Future<void> loadPickups() async {
    try {
      final data = await UserApi().getPastPickups();

      setState(() {
        pickups = data;
        isLoading = false;
      });
    } catch (e) {
      print("Pickup history error: $e");

      setState(() {
        isLoading = false;
      });
    }
  }

  String formatDate(dynamic value) {
    if (value == null) return "N/A";

    try {
      final date = DateTime.parse(value.toString()).toLocal();

      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final year = date.year.toString();

      return "$day-$month-$year";
    } catch (e) {
      return value.toString().split('T').first;
    }
  }

  Color getStatusColor(String status) {
    final value = status.toLowerCase();

    if (value == "completed") {
      return appColor;
    } else if (value == "pending") {
      return const Color(0xFFE0A800);
    } else if (value == "cancelled" || value == "failed") {
      return Colors.redAccent;
    } else {
      return Colors.grey;
    }
  }

  Widget _infoRow({
    required IconData icon,
    required String text,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.black45,
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPickupCard(dynamic item) {
    final String status = item['Status']?.toString() ?? 'Unknown';
    final Color statusColor = getStatusColor(status);

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 7,
        horizontal: 12,
      ),
      child: CustomCard(
        icon: Icons.delete_outline,
        title: item['CollectorName'] ?? 'N/A',
        subtitle: item['BagType'] ?? 'N/A',
        onTap: () {},
        extraWidget: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(
              height: 20,
              color: Colors.black12,
            ),

            Row(
              children: [
                const Text(
                  "Pickup Details",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),

                const Spacer(),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            _infoRow(
              icon: Icons.tag,
              text: "Bag ID: ${item['BagID'] ?? 'N/A'}",
            ),

            const SizedBox(height: 7),

            _infoRow(
              icon: Icons.phone_outlined,
              text: item['CollectorPhone'] ?? 'N/A',
            ),

            const SizedBox(height: 7),

            _infoRow(
              icon: Icons.calendar_today_outlined,
              text: formatDate(item['ScannedAt']),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 55,
            color: Colors.black38,
          ),
          SizedBox(height: 12),
          Text(
            "No pickups found",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 5),
          Text(
            "Your pickup history will appear here",
            style: TextStyle(
              fontSize: 13,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        title: const Text(
          "Pickup History",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: appColor,
        elevation: 1,
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: appColor,
              ),
            )
          : pickups.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  color: appColor,
                  onRefresh: loadPickups,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    itemCount: pickups.length,
                    itemBuilder: (context, index) {
                      return _buildPickupCard(pickups[index]);
                    },
                  ),
                ),
    );
  }
}