import 'package:flutter/material.dart';

import '../data/demo_delivery_store.dart';
import 'flexi_ui.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: demoDeliveryStore,
      builder: (context, _) {
        final store = demoDeliveryStore;
        final orders = store.orders.isEmpty
            ? [
                DemoOrderSummary(
                  id: store.orderId,
                  status: store.status,
                  subtitle: store.activeDeliverySubtitle,
                  statusText: store.activeDeliveryStatusLabel,
                  delayMinutes: store.delayMinutes,
                  isActive: true,
                ),
              ]
            : store.orders;

        return Scaffold(
          backgroundColor: FlexiColors.bg,
          appBar: const FlexiAppBar(title: 'Orders'),
          bottomNavigationBar: const CompactBottomNav(
            currentIndex: 1,
            routes: [
              '/receiver-home',
              '/orders',
              '/tracking',
              '/vouchers',
              '/profile',
            ],
          ),
          body: SafeArea(
            top: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                ...orders.map(
                  (order) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: FlexiCard(
                      onTap: () => Navigator.pushNamed(context, '/tracking'),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: _statusBackground(order.status),
                            child: Icon(
                              Icons.inventory_2_outlined,
                              color: _statusColor(order.status),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  order.id,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  order.subtitle,
                                  style: const TextStyle(
                                    color: FlexiColors.muted,
                                    fontSize: 12.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          StatusPill(
                            label: order.statusText,
                            color: _statusColor(order.status),
                            background: _statusBackground(order.status),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Color _statusColor(DemoDeliveryStatus status) {
    if (status == DemoDeliveryStatus.completed ||
        status == DemoDeliveryStatus.reroutedToNode ||
        status == DemoDeliveryStatus.deliveredToNode) {
      return FlexiColors.primary;
    }
    if (status == DemoDeliveryStatus.offerPending ||
        status == DemoDeliveryStatus.trafficDetected) {
      return FlexiColors.orange;
    }
    return FlexiColors.blue;
  }

  static Color _statusBackground(DemoDeliveryStatus status) {
    if (status == DemoDeliveryStatus.completed ||
        status == DemoDeliveryStatus.reroutedToNode ||
        status == DemoDeliveryStatus.deliveredToNode) {
      return FlexiColors.lightGreen;
    }
    if (status == DemoDeliveryStatus.offerPending ||
        status == DemoDeliveryStatus.trafficDetected) {
      return FlexiColors.orangeSoft;
    }
    return FlexiColors.blueSoft;
  }
}
