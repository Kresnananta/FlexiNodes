import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../data/demo_delivery_store.dart';
import 'flexi_ui.dart';

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key, this.expectedType, this.title = 'Scan QR'});

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
  final PageController pageController = PageController();

  bool isProcessing = false;
  int currentPage = 0;
  String? lastValue;

  bool get isDriverScan => widget.expectedType == 'driver_dropoff';
  bool get isReceiverScan => widget.expectedType == 'receiver_pickup';
  bool get isMitraScan => widget.expectedType == 'mitra_node';
  bool get isUnifiedScan => widget.expectedType == null;

  @override
  void dispose() {
    pageController.dispose();
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

      if (!mounted) return;

      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            title: const Text('QR Scan Success'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('Back'),
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

  Future<void> _handlePageChanged(int index) async {
    setState(() => currentPage = index);

    try {
      if (index == 0) {
        await controller.start();
      } else {
        await controller.stop();
      }
    } catch (_) {
      // Camera lifecycle can race while the web/mobile view is settling.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlexiColors.bg,
      appBar: FlexiAppBar(
        title: widget.title,
        actions: currentPage == 0
            ? [
                IconButton(
                  onPressed: () => controller.toggleTorch(),
                  icon: const Icon(Icons.flash_on, color: FlexiColors.primary),
                ),
                IconButton(
                  onPressed: () => controller.switchCamera(),
                  icon: const Icon(
                    Icons.cameraswitch,
                    color: FlexiColors.primary,
                  ),
                ),
              ]
            : null,
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: isUnifiedScan
                  ? PageView(
                      controller: pageController,
                      onPageChanged: _handlePageChanged,
                      children: [
                        _buildScannerPage(),
                        _ShowMitraQrPage(store: demoDeliveryStore),
                      ],
                    )
                  : _buildScannerPage(),
            ),
            _QrModeFooter(
              currentPage: currentPage,
              isUnifiedScan: isUnifiedScan,
              isDriverScan: isDriverScan,
              isMitraScan: isMitraScan,
              onScanTap: () => pageController.animateToPage(
                0,
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOut,
              ),
              onShowTap: () => pageController.animateToPage(
                1,
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOut,
              ),
              onDemoDriverTap: () =>
                  _handleDetected(demoDeliveryStore.driverQrPayload),
              onDemoReceiverTap: () =>
                  _handleDetected(demoDeliveryStore.receiverQrPayload),
              onDemoMitraTap: () =>
                  _handleDetected(demoDeliveryStore.mitraQrPayload),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScannerPage() {
    final instructionTitle = isUnifiedScan
        ? 'Scan Driver atau Customer QR'
        : isDriverScan
        ? 'Scan Driver Package QR'
        : isReceiverScan
        ? 'Scan Customer Pickup QR'
        : isMitraScan
        ? 'Scan Mitra Node QR'
        : 'Scan Flexi QR';

    final instructionBody = isUnifiedScan
        ? 'Scan QR driver untuk menerima paket, atau QR customer untuk mencocokkan order ID dan OTP sebelum paket dilepas.'
        : isDriverScan
        ? 'Ask the driver to show the package QR. Scanning it will mark the package as stored at the mitra node.'
        : isReceiverScan
        ? 'Ask the customer to show their pickup QR. Scanning it will verify OTP and complete the pickup.'
        : isMitraScan
        ? 'Scan QR mitra untuk memindahkan paket ke node dan mengubah status menjadi tiba di mitra.'
        : 'Point the camera at a valid Flexi Nodes QR code.';

    final instructionIcon = isDriverScan
        ? Icons.local_shipping_outlined
        : isReceiverScan
        ? Icons.person_outline
        : isMitraScan
        ? Icons.storefront
        : Icons.qr_code_scanner;

    final instructionColor = isDriverScan || isUnifiedScan || isMitraScan
        ? FlexiColors.orange
        : FlexiColors.primary;
    final instructionBackground = isDriverScan || isUnifiedScan || isMitraScan
        ? FlexiColors.orangeSoft
        : FlexiColors.lightGreen;

    return Stack(
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
          top: 16,
          child: FlexiCard(
            color: Colors.white.withValues(alpha: 0.95),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: instructionBackground,
                  child: Icon(instructionIcon, color: instructionColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        instructionTitle,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        instructionBody,
                        style: const TextStyle(
                          color: FlexiColors.muted,
                          fontSize: 12.5,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 18,
          child: FlexiCard(
            color: Colors.white.withValues(alpha: 0.95),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isProcessing
                      ? 'Processing QR...'
                      : 'Point the camera at the package QR code.',
                  style: const TextStyle(
                    color: FlexiColors.text,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (lastValue != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    lastValue!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: FlexiColors.muted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ShowMitraQrPage extends StatelessWidget {
  const _ShowMitraQrPage({required this.store});

  final DemoDeliveryStore store;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 28),
      children: [
        FlexiCard(
          color: FlexiColors.lightGreen,
          child: Column(
            children: [
              const StatusPill(
                icon: Icons.storefront,
                label: 'MITRA NODE QR',
                color: FlexiColors.primary,
                background: Colors.white,
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: QrImageView(
                  data: store.mitraQrPayload,
                  version: QrVersions.auto,
                  size: 230,
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                store.nodeName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Driver dapat scan QR ini untuk memindahkan paket ${store.orderId} ke mitra.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: FlexiColors.muted,
                  fontSize: 12.5,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        FlexiCard(
          child: Column(
            children: [
              _InfoRow(label: 'Order ID', value: store.orderId),
              _InfoRow(label: 'Mitra', value: store.nodeName),
              _InfoRow(label: 'Customer', value: store.receiverName),
              _InfoRow(label: 'Status', value: store.statusText),
            ],
          ),
        ),
      ],
    );
  }
}

class _QrModeFooter extends StatelessWidget {
  const _QrModeFooter({
    required this.currentPage,
    required this.isUnifiedScan,
    required this.isDriverScan,
    required this.isMitraScan,
    required this.onScanTap,
    required this.onShowTap,
    required this.onDemoDriverTap,
    required this.onDemoReceiverTap,
    required this.onDemoMitraTap,
  });

  final int currentPage;
  final bool isUnifiedScan;
  final bool isDriverScan;
  final bool isMitraScan;
  final VoidCallback onScanTap;
  final VoidCallback onShowTap;
  final VoidCallback onDemoDriverTap;
  final VoidCallback onDemoReceiverTap;
  final VoidCallback onDemoMitraTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isUnifiedScan) ...[
            Row(
              children: [
                Expanded(
                  child: _ModeButton(
                    label: 'Scan',
                    icon: Icons.qr_code_scanner,
                    selected: currentPage == 0,
                    onTap: onScanTap,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ModeButton(
                    label: 'Show QR',
                    icon: Icons.qr_code_2,
                    selected: currentPage == 1,
                    onTap: onShowTap,
                  ),
                ),
              ],
            ),
          ],
          if (currentPage == 0) ...[
            if (isUnifiedScan) const SizedBox(height: 10),
            if (isUnifiedScan)
              Row(
                children: [
                  Expanded(
                    child: FlexiOutlineButton(
                      label: 'Demo Driver',
                      icon: Icons.local_shipping_outlined,
                      onPressed: onDemoDriverTap,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FlexiOutlineButton(
                      label: 'Demo Customer',
                      icon: Icons.person_outline,
                      onPressed: onDemoReceiverTap,
                    ),
                  ),
                ],
              )
            else
              FlexiOutlineButton(
                label: isMitraScan
                    ? 'Use Demo Mitra QR'
                    : isDriverScan
                    ? 'Use Demo Driver QR'
                    : 'Use Demo Customer QR',
                icon: isMitraScan
                    ? Icons.storefront
                    : isDriverScan
                    ? Icons.local_shipping_outlined
                    : Icons.person_outline,
                onPressed: isMitraScan
                    ? onDemoMitraTap
                    : isDriverScan
                    ? onDemoDriverTap
                    : onDemoReceiverTap,
              ),
          ],
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final background = selected ? FlexiColors.primary : FlexiColors.lightGreen;
    final foreground = selected ? Colors.white : FlexiColors.primary;

    return SizedBox(
      height: 42,
      child: TextButton.icon(
        onPressed: onTap,
        style: TextButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: Icon(icon, size: 18),
        label: Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: FlexiColors.muted, fontSize: 12.5),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: FlexiColors.text,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
