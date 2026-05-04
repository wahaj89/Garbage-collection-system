import 'package:flutter/material.dart';
import 'package:garbage_collection_system/Api/userController.dart';
import 'package:garbage_collection_system/custom_widgets/card.dart';
// update path as needed

class ViewHistory extends StatefulWidget {
  const ViewHistory({super.key});

  @override
  State<ViewHistory> createState() => _ViewHistoryState();
}

class _ViewHistoryState extends State<ViewHistory> {
  List pickups = [];
  bool isLoading = true;

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
      print(e);
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildPickupCard(item) {
    final status = item['Status'] ?? 'Unknown';
    final isCompleted = status.toString().toLowerCase() == 'completed';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: CustomCard(
        icon: Icons.delete_outline,
        title: item['CollectorName'] ?? 'N/A',
        subtitle: item['BagType'] ?? 'N/A',
        onTap: () {},
        extraWidget: Column(
          children: [
            const Divider(height: 20, color: Colors.black12),

            // Status badge
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? const Color(0xFF99C13D)
                      : const Color(0xFFE0A800),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Bag ID
            Row(
              children: [
                const Icon(Icons.tag, size: 16, color: Colors.black45),
                const SizedBox(width: 6),
                Text(
                  "Bag ID: ${item['BagID']}",
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),

            const SizedBox(height: 6),

            // Phone
            Row(
              children: [
                const Icon(Icons.phone_outlined, size: 16, color: Colors.black45),
                const SizedBox(width: 6),
                Text(
                  item['CollectorPhone'] ?? 'N/A',
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),

            const SizedBox(height: 6),

            // Date
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 16, color: Colors.black45),
                const SizedBox(width: 6),
                Text(
                  item['ScannedAt'] != null
                      ? item['ScannedAt'].toString().split('T').first
                      : 'N/A',
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pickup History"),
        backgroundColor: const Color(0xFF99C13D),
        
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : pickups.isEmpty
              ? const Center(
                  child: Text(
                    "No pickups found",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  itemCount: pickups.length,
                  itemBuilder: (context, index) {
                    return _buildPickupCard(pickups[index]);
                  },
                ),
    );
  }
}