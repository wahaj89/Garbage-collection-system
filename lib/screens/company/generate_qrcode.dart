import 'package:flutter/material.dart';
import 'package:garbage_collection_system/Api/companyController.dart';
import 'package:garbage_collection_system/custom_widgets/inputfield.dart';
import 'package:garbage_collection_system/custom_widgets/button.dart';
import 'package:qr_flutter/qr_flutter.dart';

class GenerateQrcode extends StatefulWidget {
  final int userId;
  final int bags;
  final String bagType;

  const GenerateQrcode({
    super.key,
    required this.userId,
    required this.bags,
    required this.bagType,
  });

  @override
  State<GenerateQrcode> createState() => _GenerateQrcodeState();
}

class _GenerateQrcodeState extends State<GenerateQrcode> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController weightController = TextEditingController();

  List<String> generatedQRs = [];
  bool isLoading = false;

  void generateBags() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      generatedQRs.clear();
    });

    final weight = double.parse(weightController.text.trim());

    final result = await CompanyApi.generateBags(
      userId: widget.userId,      // ✅ auto
      quantity: widget.bags,      // ✅ auto
      bagType: widget.bagType,   // ✅ auto
      weightLimit: weight,
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
        const SnackBar(content: Text("Bags Generated Successfully")),
      );
    }
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
            // ✅ Info Card (auto values show karne ke liye)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFD0E5FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text("User ID: ${widget.userId}"),
                  Text("Bags: ${widget.bags}"),
                  Text("Type: ${widget.bagType}"),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ✅ Only Weight Input
            Form(
              key: _formKey,
              child: Column(
                children: [
                  CustomInput(
                    label: "Weight Limit",
                    controller: weightController,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Enter Weight Limit";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 25),

                  isLoading
                      ? const CircularProgressIndicator()
                      : CustomButton(
                          text: "Generate Bags",
                          onPressed: generateBags,
                        ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ✅ QR LIST
            Expanded(
              child: generatedQRs.isEmpty
                  ? const Center(child: Text("No QR codes generated yet"))
                  : ListView.builder(
                      itemCount: generatedQRs.length,
                      itemBuilder: (context, index) {
                        final qrData = generatedQRs[index];

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              children: [
                                Text(
                                  "QR Code ${index + 1}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 10),

                                QrImageView(
                                  data: qrData,
                                  version: QrVersions.auto,
                                  size: 200,
                                  backgroundColor: const Color(0xFFD0E5FF),
                                ),

                                const SizedBox(height: 10),
                                SelectableText(qrData),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}