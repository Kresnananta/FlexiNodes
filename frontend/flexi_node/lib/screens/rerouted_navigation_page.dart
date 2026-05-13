import 'package:flutter/material.dart';

import '../data/demo_delivery_store.dart';
import 'flexi_ui.dart';

class ReroutedNavigationPage extends StatelessWidget {
  const ReroutedNavigationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: demoDeliveryStore,
      builder: (context, _) {
        final store = demoDeliveryStore;

        return Scaffold(
          backgroundColor: FlexiColors.bg,
          appBar: const FlexiAppBar(title: 'Navigation'),
          body: SafeArea(
            top: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                Stack(
                  children: [
                    MiniMap(
                      height: 300,
                      showNode: true,
                      showCustomer: !store.shouldRouteToNode,
                      routeToNode: store.shouldRouteToNode,
                    ),
                    Positioned(
                      top: 12,
                      left: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: store.shouldRouteToNode ? FlexiColors.blueSoft : FlexiColors.orangeSoft,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: FlexiColors.border),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              store.shouldRouteToNode ? Icons.auto_awesome : Icons.warning_amber,
                              color: store.shouldRouteToNode ? FlexiColors.blue : FlexiColors.orange,
                              size: 22,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                store.shouldRouteToNode
                                    ? 'Route updated by Flexi AI. Customer accepted pickup at ${store.nodeName}.'
                                    : 'Original route to receiver address. Traffic is increasing near destination.',
                                style: TextStyle(
                                  color: store.shouldRouteToNode ? FlexiColors.blue : FlexiColors.orange,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                FlexiCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current Destination',
                        style: TextStyle(
                          color: FlexiColors.muted,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        store.shouldRouteToNode ? store.nodeName : 'Receiver Address',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          StatusPill(icon: Icons.inventory_2_outlined, label: store.orderId),
                          StatusPill(icon: Icons.person_outline, label: store.receiverName.split(' ').first),
                          StatusPill(icon: Icons.timer_outlined, label: store.shouldRouteToNode ? '8 mins' : '20 mins delay'),
                          StatusPill(icon: Icons.route, label: store.shouldRouteToNode ? '1.2 km' : '2.7 km'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: FlexiPrimaryButton(
                              label: 'Navigate',
                              icon: Icons.navigation,
                              onPressed: () => Navigator.pushNamed(context, '/real-delivery-map'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: FlexiOutlineButton(
                              label: 'AI Chat',
                              icon: Icons.auto_awesome,
                              onPressed: () => Navigator.pushNamed(context, '/ai-chat'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                FlexiCard(
                  color: FlexiColors.lightGreen,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Drop-off checklist',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 10),
                      const _Checklist(label: 'Verify partner node name'),
                      const _Checklist(label: 'Scan package QR'),
                      const _Checklist(label: 'Confirm OTP handover code'),
                      const SizedBox(height: 14),
                      FlexiPrimaryButton(
                        label: store.dropoffConfirmed ? 'Drop-off Completed' : 'Confirm Drop-off',
                        icon: Icons.check_circle_outline,
                        onPressed: () {
                          store.confirmDropoff();
                          _showCompletedSheet(context);
                        },
                      ),
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

  static void _showCompletedSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 26),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 32,
                backgroundColor: FlexiColors.lightGreen,
                child: Icon(Icons.check_circle, color: FlexiColors.primary, size: 42),
              ),
              const SizedBox(height: 14),
              const Text(
                'Drop-off Completed',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              const Text(
                'Package SD1440-Y is now waiting for customer pickup.',
                textAlign: TextAlign.center,
                style: TextStyle(color: FlexiColors.muted, fontSize: 13),
              ),
              const SizedBox(height: 18),
              FlexiPrimaryButton(
                label: 'View Confirmation',
                onPressed: () => Navigator.pushNamed(context, '/confirmation'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Checklist extends StatelessWidget {
  const _Checklist({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: FlexiColors.primary, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
