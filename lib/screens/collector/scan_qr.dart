import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:garbage_collection_system/custom_widgets/getloctaion.dart';
import 'package:geolocator/geolocator.dart';
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

  // 🔥 API CALL FUNCTION
 Future<void> sendToAPI(String qr) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final collectorId = prefs.getInt('UserId') ?? 0;

    // 🔥 GET LIVE LOCATION
    Position position = await LocationService.getCurrentLocation();

    double latitude = position.latitude;
    double longitude = position.longitude;

    print("LIVE LOCATION: $latitude , $longitude");

    final result = await CollectorApi.scanBagAndPickup(
      qrCode: qr,
      collectorId: collectorId,
      latitude: latitude,
      longitude: longitude,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result["message"]),
        backgroundColor: result["success"] ? Colors.green : Colors.red,
      ),
    );

  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.toString()),
        backgroundColor: Colors.red,
      ),
    );
  }

  await Future.delayed(const Duration(seconds: 2));

  setState(() {
    isProcessing = false;
    scannedCode = "";
  });

  cameraController.start();
}
  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  // 🎯 UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan QR Code"),
        centerTitle: true,
        backgroundColor: const Color(0xFF99C13D),
      ),
      body: Column(
        children: [
          // 📷 Scanner View
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                MobileScanner(
                  controller: cameraController,
                  onDetect: (capture) async {
                    if (isProcessing) return;

                    final barcode = capture.barcodes.first;
                    final code = barcode.rawValue;

                    if (code == null || code.isEmpty) return;

                    log("QR SCANNED: $code");

                    setState(() {
                      scannedCode = code;
                      isProcessing = true;
                    });

                    cameraController.stop();

                    await sendToAPI(code);
                  },
                ),

                // 🔴 Overlay loader when processing
                if (isProcessing)
                  Container(
                    color: Colors.black.withOpacity(0.6),
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),

          // 📄 Bottom Info Panel
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 5,
                    color: Colors.black12,
                  )
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Scan Result",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Text(
                    scannedCode.isEmpty
                        ? "Waiting for scan..."
                        : scannedCode,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: scannedCode.isEmpty
                          ? Colors.grey
                          : Colors.black,
                    ),
                  ),

                  const SizedBox(height: 15),

                  // 🔁 Manual restart button (optional)
                  ElevatedButton.icon(
                    onPressed: () {
                      cameraController.start();
                      setState(() {
                        scannedCode = "";
                        isProcessing = false;
                      });
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text("Scan Again"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF99C13D),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}