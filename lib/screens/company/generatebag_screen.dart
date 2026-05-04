import 'package:flutter/material.dart';
import 'package:garbage_collection_system/Api/companyController.dart';
import 'package:qr_flutter/qr_flutter.dart';

class GeneratebagScreen extends StatefulWidget {
  final int userId;
  final int bags;
  final String bagType; // 👈 passed from previous screen

  const GeneratebagScreen({
    super.key,
    required this.userId,
    required this.bags,
    required this.bagType,
  });

  @override
  State<GeneratebagScreen> createState() => _GeneratebagScreenState();
}

class _GeneratebagScreenState extends State<GeneratebagScreen> {
  late String bagType;
  List<String> generatedQRs = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    bagType = widget.bagType; // 🔥 auto set
  }

  Future<void> generateBags() async {
    setState(() {
      isLoading = true;
      generatedQRs.clear();
    });

    try {
      final result = await CompanyApi.generateBags1(
        userId: widget.userId,
        quantity: widget.bags,
        bagType: bagType,
        weightLimit: 5, // 🔥 default (future: dynamic kar sakte ho)
      );

      setState(() {
        isLoading = false;
      });

      if (result.containsKey("error")) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result["error"])),
        );
      } else {
        setState(() {
          generatedQRs = List<String>.from(result["qrCodes"]);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("QR Codes Generated Successfully")),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Something went wrong: $e")),
      );
    }
  }

  Widget buildUserInfoCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 3,
      child: ListTile(
        leading: const Icon(Icons.person, color: Color(0xFF99C13D)),
        title: Text("User ID: ${widget.userId}"),
        subtitle: Text(
          "Total Bags: ${widget.bags}\nBag Type: $bagType",
        ),
      ),
    );
  }

  Widget buildGenerateButton() {
    return isLoading
        ? const CircularProgressIndicator()
        : SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: generateBags,
              icon: const Icon(Icons.qr_code),
              label: const Text("Generate QR Codes"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF99C13D),
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                ),
              ),
            ),
          );
  }

  Widget buildQRList() {
    if (generatedQRs.isEmpty) {
      return const Center(child: Text("No QR generated yet"));
    }

    return ListView.builder(
      itemCount: generatedQRs.length,
      itemBuilder: (context, index) {
        final qr = generatedQRs[index];

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Text(
                  "QR Code ${index + 1}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                QrImageView(
                  data: qr,
                  size: 180,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Generate QR Bags"),
        backgroundColor: const Color(0xFF99C13D),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            buildUserInfoCard(),

            const SizedBox(height: 20),

            buildGenerateButton(),

            const SizedBox(height: 20),

            Expanded(child: buildQRList()),
          ],
        ),
      ),
    );
  }
}