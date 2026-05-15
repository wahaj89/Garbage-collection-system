import 'package:flutter/material.dart';
import 'package:garbage_collection_system/Api/companyController.dart';
import 'package:garbage_collection_system/custom_widgets/inputfield.dart';
import 'package:garbage_collection_system/custom_widgets/button.dart';
import 'package:qr_flutter/qr_flutter.dart';

// ✅ PDF imports
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

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
  bool isPdfDownloading = false;

  void generateBags() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      generatedQRs.clear();
    });

    final weight = double.parse(weightController.text.trim());

    final result = await CompanyApi.generateBags(
      userId: widget.userId,
      quantity: widget.bags,
      bagType: widget.bagType,
      weightLimit: weight,
    );

    setState(() {
      isLoading = false;
    });

    if (result.containsKey("error")) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result["error"].toString())),
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

  // ✅ Download all QR codes as PDF
  Future<void> downloadAllQRCodesPdf() async {
    if (generatedQRs.isEmpty) return;

    try {
      setState(() {
        isPdfDownloading = true;
      });

      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(24),
          build: (pw.Context context) {
            return [
              pw.Text(
                "Generated QR Bags",
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(height: 8),

              pw.Text("User ID: ${widget.userId}"),
              pw.Text("Total Bags: ${widget.bags}"),
              pw.Text("Bag Type: ${widget.bagType}"),
              pw.Text("Weight Limit: ${weightController.text.trim()}"),

              pw.SizedBox(height: 20),

              pw.Wrap(
                spacing: 16,
                runSpacing: 16,
                children: List.generate(generatedQRs.length, (index) {
                  final qrData = generatedQRs[index];

                  return pw.Container(
                    width: 240,
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey400),
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Column(
                      mainAxisSize: pw.MainAxisSize.min,
                      children: [
                        pw.Text(
                          "QR Code ${index + 1}",
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),

                        pw.SizedBox(height: 10),

                        pw.BarcodeWidget(
                          barcode: pw.Barcode.qrCode(),
                          data: qrData,
                          width: 150,
                          height: 150,
                        ),

                        pw.SizedBox(height: 10),

                        pw.Text(
                          qrData,
                          textAlign: pw.TextAlign.center,
                          style: const pw.TextStyle(fontSize: 8),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ];
          },
        ),
      );

      final pdfBytes = await pdf.save();

      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: "qr_codes_user_${widget.userId}.pdf",
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("QR Codes PDF Ready")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("PDF download failed: $e")),
      );
    } finally {
      setState(() {
        isPdfDownloading = false;
      });
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
            // ✅ Info Card
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

            // ✅ Weight Input
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

                      final weight = double.tryParse(value);
                      if (weight == null || weight <= 0) {
                        return "Enter valid weight";
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

            // ✅ Download button only after QR generated
            if (generatedQRs.isNotEmpty) ...[
              const SizedBox(height: 15),

              isPdfDownloading
                  ? const CircularProgressIndicator()
                  : CustomButton(
                      text: "Download All QR PDF",
                      onPressed: downloadAllQRCodesPdf,
                    ),
            ],

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
                                    fontWeight: FontWeight.bold,
                                  ),
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