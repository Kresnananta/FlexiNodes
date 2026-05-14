import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../data/demo_delivery_store.dart';
import 'flexi_ui.dart';

class DriverQrPage extends StatelessWidget {
  const DriverQrPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: demoDeliveryStore,
      builder: (context, _) {
        final store = demoDeliveryStore;

        return Scaffold(
          backgroundColor: FlexiColors.bg,
          appBar: const FlexiAppBar(title: 'Driver Package QR'),
          body: SafeArea(
            top: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 22, 16, 24),
              children: [
                FlexiCard(
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 34,
                        backgroundColor: FlexiColors.orangeSoft,
                        child: Icon(Icons.local_shipping_outlined, color: FlexiColors.orange, size: 36),
                      ),
                      const SizedBox(height: 14),
                      const Text('Driver Drop-off QR', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 6),
                      Text('Show this QR to the mitra when dropping off package ${store.orderId}.', textAlign: TextAlign.center, style: const TextStyle(color: FlexiColors.muted, fontSize: 13, height: 1.35)),
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: FlexiColors.border)),
                        child: QrImageView(data: store.driverQrPayload, version: QrVersions.auto, size: 230, backgroundColor: Colors.white),
                      ),
                      const SizedBox(height: 18),
                      _InfoRow(label: 'Order ID', value: store.orderId),
                      _InfoRow(label: 'Driver', value: store.driverName),
                      _InfoRow(label: 'Node', value: store.nodeName),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
      padding: const EdgeInsets.only(top: 9),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(color: FlexiColors.muted, fontSize: 12.5))),
          Flexible(child: Text(value, textAlign: TextAlign.right, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900))),
        ],
      ),
    );
  }
}
