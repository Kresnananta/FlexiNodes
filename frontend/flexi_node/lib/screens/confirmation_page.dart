import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../data/demo_delivery_store.dart';
import 'flexi_ui.dart';

class ConfirmationPage extends StatelessWidget {
  const ConfirmationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: demoDeliveryStore,
      builder: (context, _) {
        final store = demoDeliveryStore;

        return Scaffold(
          backgroundColor: FlexiColors.bg,
          appBar: const FlexiAppBar(title: 'Confirmed'),
          body: SafeArea(
            top: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 22, 16, 24),
              children: [
                CircleAvatar(
                  radius: 38,
                  backgroundColor: store.dropoffConfirmed
                      ? FlexiColors.lightGreen
                      : FlexiColors.blueSoft,
                  child: Icon(
                    store.dropoffConfirmed
                        ? Icons.inventory_2
                        : Icons.check_circle,
                    color: store.dropoffConfirmed
                        ? FlexiColors.primary
                        : FlexiColors.blue,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  store.dropoffConfirmed
                      ? 'Package Ready for Pickup'
                      : 'Pickup Node Confirmed',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  store.dropoffConfirmed
                      ? 'Your package has been dropped at ${store.nodeName}. Show this QR to the mitra cashier.'
                      : 'Your package will be dropped at ${store.nodeName}.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: FlexiColors.muted,
                    fontSize: 14,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 22),
                FlexiCard(
                  child: Column(
                    children: [
                      _InfoRow(label: 'Order ID', value: store.orderId),
                      _InfoRow(label: 'Pickup location', value: store.nodeName),
                      _InfoRow(
                        label: 'Voucher',
                        value: store.voucherEligible
                            ? store.formattedVoucher
                            : 'Not issued',
                      ),
                      _InfoRow(
                        label: 'Ready time',
                        value: store.dropoffConfirmed
                            ? 'Ready now'
                            : store.estimatedArrivalText,
                      ),
                      _InfoRow(
                        label: 'Status',
                        value: store.activeDeliveryStatusLabel,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                FlexiCard(
                  color: FlexiColors.lightGreen,
                  child: Column(
                    children: [
                      const StatusPill(
                        icon: Icons.qr_code_2,
                        label: 'RECEIVER PICKUP QR',
                        color: FlexiColors.primary,
                        background: Colors.white,
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: FlexiColors.border),
                        ),
                        child: QrImageView(
                          data: store.receiverQrPayload,
                          version: QrVersions.auto,
                          size: 220,
                          backgroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'OTP: ${store.safeOtpCode}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: FlexiColors.primary,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Show this QR to the mitra cashier. The QR contains your package ID and OTP, so the mitra can verify and complete the pickup.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: FlexiColors.muted,
                          fontSize: 12.5,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                FlexiPrimaryButton(
                  label: 'Open AI Chat',
                  icon: Icons.auto_awesome,
                  onPressed: () => Navigator.pushNamed(context, '/ai-chat'),
                ),
                const SizedBox(height: 10),
                FlexiOutlineButton(
                  label: 'Open Nearby Nodes',
                  icon: Icons.storefront,
                  onPressed: () =>
                      Navigator.pushNamed(context, '/nearby-nodes'),
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
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: FlexiColors.muted, fontSize: 13),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: FlexiColors.text,
                fontSize: 13.5,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
