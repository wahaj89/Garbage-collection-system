import 'package:flutter/material.dart';
import 'package:garbage_collection_system/Api/companyController.dart';
import 'package:garbage_collection_system/custom_widgets/inputfield.dart';
import 'package:garbage_collection_system/custom_widgets/button.dart';
import 'package:qr_flutter/qr_flutter.dart';

class GenerateBagsScreen extends StatefulWidget {
  const GenerateBagsScreen({super.key});

  @override
  State<GenerateBagsScreen> createState() => _GenerateBagsScreenState();
}

class _GenerateBagsScreenState extends State<GenerateBagsScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController userIdController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  String bagType = "Recyclable";

  List<String> generatedQRs = [];
  bool isLoading = false;

  void generateBags() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      generatedQRs.clear();
    });

    final userId = int.parse(userIdController.text.trim());
    final quantity = int.parse(quantityController.text.trim());
    final weight = double.parse(weightController.text.trim());

    final result = await CompanyApi.generateBags(
      userId: userId,
      quantity: quantity,
      bagType: bagType,
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
            Form(
              key: _formKey,
              child: Column(
                children: [
                  CustomInput(
                    label: "User ID",
                    controller: userIdController,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Enter User ID";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  CustomInput(
                    label: "Quantity of Bags",
                    controller: quantityController,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Enter Quantity";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  DropdownButtonFormField(
                    value: bagType,
                    items: const [
                      DropdownMenuItem(
                        value: "Recyclable",
                        child: Text("Recyclable"),
                      ),
                      DropdownMenuItem(
                        value: "Non-Recyclable",
                        child: Text("Non-Recyclable"),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        bagType = value!;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: "Bag Type",
                      filled: true,
                      fillColor: const Color(0xFFD0E5FF),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
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
                              crossAxisAlignment: CrossAxisAlignment.center,
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
                                  gapless: false,
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