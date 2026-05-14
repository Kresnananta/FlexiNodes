import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../data/demo_delivery_store.dart';
import 'flexi_ui.dart';

class PartnerDashboardPage extends StatelessWidget {
  const PartnerDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: demoDeliveryStore,
      builder: (context, _) {
        final store = demoDeliveryStore;

        return Scaffold(
          backgroundColor: FlexiColors.bg,
          appBar: const FlexiAppBar(title: 'Partner Node'),
          body: SafeArea(
            top: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 26,
                      backgroundColor: FlexiColors.lightGreen,
                      child: Icon(Icons.storefront, color: FlexiColors.primary, size: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            store.nodeName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Mitra dashboard for secure QR handover.',
                            style: TextStyle(color: FlexiColors.muted, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                FlexiCard(
                  color: FlexiColors.lightGreen,
                  child: Column(
                    children: [
                      const StatusPill(
                        icon: Icons.qr_code_2,
                        label: 'MITRA NODE QR',
                        color: FlexiColors.primary,
                        background: Colors.white,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                        child: QrImageView(
                          data: store.mitraQrPayload,
                          version: QrVersions.auto,
                          size: 160,
                          backgroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'This QR identifies the partner node for secure package handover.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: FlexiColors.muted, fontSize: 12.5, height: 1.35),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                FlexiCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Current Package', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 12),
                      _InfoRow(label: 'Order ID', value: store.orderId),
                      _InfoRow(label: 'Driver', value: store.driverName),
                      _InfoRow(label: 'Receiver', value: store.receiverName),
                      _InfoRow(label: 'OTP', value: store.safeOtpCode),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          StatusPill(
                            icon: Icons.sync_alt,
                            label: store.statusText,
                            color: _statusColor(store.statusText),
                            background: _statusBackground(store.statusText),
                          ),
                          StatusPill(
                            icon: Icons.inventory_2_outlined,
                            label: store.dropoffConfirmed ? 'Stored at node' : 'Waiting handover',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(color: FlexiColors.orange, borderRadius: BorderRadius.circular(18)),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.qr_code_scanner, color: FlexiColors.orange, size: 30),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(text: 'Scan Package QR\n', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                              TextSpan(
                                text: store.dropoffConfirmed ? 'Scan receiver QR to release and complete the package.' : 'Scan driver QR to receive package into this node.',
                                style: const TextStyle(fontSize: 12.5, height: 1.35),
                              ),
                            ],
                          ),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: FlexiPrimaryButton(
                        label: 'Scan Driver QR',
                        icon: Icons.local_shipping_outlined,
                        backgroundColor: FlexiColors.orange,
                        onPressed: () => Navigator.pushNamed(
                          context,
                          '/qr-scanner',
                          arguments: {'expectedType': 'driver_dropoff', 'title': 'Scan Driver QR'},
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FlexiPrimaryButton(
                        label: 'Scan Receiver QR',
                        icon: Icons.person_outline,
                        onPressed: () => Navigator.pushNamed(
                          context,
                          '/qr-scanner',
                          arguments: {'expectedType': 'receiver_pickup', 'title': 'Scan Receiver QR'},
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: FlexiOutlineButton(
                        label: 'Show Driver QR',
                        icon: Icons.qr_code_2,
                        onPressed: () => Navigator.pushNamed(context, '/driver-qr'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FlexiOutlineButton(
                        label: 'Show Receiver QR',
                        icon: Icons.qr_code_2,
                        onPressed: () => Navigator.pushNamed(context, '/receiver-qr'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const Text('Handover Timeline', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                const SizedBox(height: 12),
                FlexiCard(
                  child: Column(
                    children: [
                      TimelineStep(title: 'Rerouted to partner node', subtitle: 'Receiver accepted Flexi Pickup offer', active: store.offerAccepted || store.shouldRouteToNode),
                      TimelineStep(
                        title: 'Driver QR scanned by mitra',
                        subtitle: 'Package stored at Indomaret Ahmad Yani',
                        active: store.dropoffConfirmed || store.statusText == 'delivered_to_node' || store.statusText == 'completed',
                      ),
                      TimelineStep(title: 'Receiver QR scanned by mitra', subtitle: 'OTP verified and package released', active: store.statusText == 'completed', last: true),
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

  static Color _statusColor(String status) {
    if (status == 'completed') return FlexiColors.primary;
    if (status == 'delivered_to_node') return FlexiColors.blue;
    if (status == 'rerouted_to_node') return FlexiColors.primary;
    return FlexiColors.orange;
  }

  static Color _statusBackground(String status) {
    if (status == 'completed') return FlexiColors.lightGreen;
    if (status == 'delivered_to_node') return FlexiColors.blueSoft;
    if (status == 'rerouted_to_node') return FlexiColors.lightGreen;
    return FlexiColors.orangeSoft;
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
          Expanded(child: Text(label, style: const TextStyle(color: FlexiColors.muted, fontSize: 12.5))),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: FlexiColors.text, fontSize: 13, fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}
