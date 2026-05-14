import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../data/demo_delivery_store.dart';
import 'flexi_ui.dart';

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({
    super.key,
    this.expectedType,
    this.title = 'Scan QR',
  });

  final String? expectedType;
  final String title;

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  final MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
  );

  bool isProcessing = false;
  String? lastValue;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _handleDetected(String rawValue) async {
    if (isProcessing) return;

    setState(() {
      isProcessing = true;
      lastValue = rawValue;
    });

    try {
      final message = await demoDeliveryStore.processScannedQr(
        rawValue,
        expectedType: widget.expectedType,
      );

      if (!mounted) return;

      await controller.stop();

      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            title: const Text('QR Scan Success'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('Back to Mitra'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => isProcessing = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: FlexiColors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlexiColors.bg,
      appBar: FlexiAppBar(
        title: widget.title,
        actions: [
          IconButton(
            onPressed: () => controller.toggleTorch(),
            icon: const Icon(Icons.flash_on, color: FlexiColors.primary),
          ),
          IconButton(
            onPressed: () => controller.switchCamera(),
            icon: const Icon(Icons.cameraswitch, color: FlexiColors.primary),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  MobileScanner(
                    controller: controller,
                    onDetect: (capture) {
                      final barcodes = capture.barcodes;
                      if (barcodes.isEmpty) return;

                      final rawValue = barcodes.first.rawValue;
                      if (rawValue == null || rawValue.isEmpty) return;

                      _handleDetected(rawValue);
                    },
                  ),
                  Center(
                    child: Container(
                      width: 240,
                      height: 240,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 3),
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 18,
                    child: FlexiCard(
                      color: Colors.white.withOpacity(0.95),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.expectedType == 'driver_dropoff'
                                ? 'Scan driver QR to receive package'
                                : widget.expectedType == 'receiver_pickup'
                                    ? 'Scan receiver QR to complete pickup'
                                    : 'Scan a Flexi Nodes QR',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            isProcessing ? 'Processing QR...' : 'Point the camera at the QR code.',
                            style: const TextStyle(color: FlexiColors.muted, fontSize: 12.5),
                          ),
                          if (lastValue != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              lastValue!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: FlexiColors.muted, fontSize: 11),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: FlexiOutlineButton(
                      label: 'Demo Driver Scan',
                      icon: Icons.local_shipping_outlined,
                      onPressed: () => _handleDetected(demoDeliveryStore.driverQrPayload),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FlexiOutlineButton(
                      label: 'Demo Receiver Scan',
                      icon: Icons.person_outline,
                      onPressed: () => _handleDetected(demoDeliveryStore.receiverQrPayload),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
