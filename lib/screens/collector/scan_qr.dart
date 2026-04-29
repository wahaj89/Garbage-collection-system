import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:garbage_collection_system/Api/collectorcontroller.dart';

class ScanQr extends StatefulWidget {
  const ScanQr({super.key});

  @override
  State<ScanQr> createState() => _ScanQrState();
}

class _ScanQrState extends State<ScanQr> {
  bool isProcessing = false;
  String scannedCode = "";

  final MobileScannerController cameraController = MobileScannerController();

  Future<void> sendToAPI(String qr) async {
    final prefs = await SharedPreferences.getInstance();

    final driverId = prefs.getInt('UserId') ?? 0;
    final collectorId = prefs.getInt('CollectorID') ?? 0;

    final result = await CollectorApi.scanBagAndPickup(
      qrCode: qr,
      driverId: driverId,
      collectorId: collectorId,
      vehicleId: 1,
      latitude: 33.6844,
      longitude: 73.0479,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result["message"]),
        backgroundColor: result["success"] ? Colors.green : Colors.red,
      ),
    );

    await Future.delayed(const Duration(seconds: 2));
    isProcessing = false;
    cameraController.start();
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan QR Code"),
        backgroundColor: const Color(0xFF99C13D),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: MobileScanner(
              controller: cameraController,
              onDetect: (capture) async {
                if (isProcessing) return;

                final barcode = capture.barcodes.first;
                final code = barcode.rawValue;

                if (code == null || code.isEmpty) return;

                setState(() {
                  scannedCode = code;
                });

                log("QR SCANNED: $scannedCode");

                isProcessing = true;
                cameraController.stop();

                await sendToAPI(scannedCode);
              },
            ),
          ),

          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                scannedCode.isEmpty
                    ? "Scan a QR Code"
                    : "Scanned: $scannedCode",
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}