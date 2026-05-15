import 'package:flutter/material.dart';

import '../data/demo_delivery_store.dart';
import 'flexi_ui.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: demoDeliveryStore,
      builder: (context, _) {
        final store = demoDeliveryStore;
        final notifications = _buildNotifications(store);

        return Scaffold(
          backgroundColor: FlexiColors.bg,
          appBar: const FlexiAppBar(title: 'Notifications'),
          body: SafeArea(
            top: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                ...notifications.map(
                  (notif) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: FlexiCard(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            backgroundColor: notif.bg,
                            child: Icon(
                              notif.icon,
                              color: notif.color,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  notif.title,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  notif.body,
                                  style: const TextStyle(
                                    color: FlexiColors.muted,
                                    fontSize: 12.5,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            notif.time,
                            style: const TextStyle(
                              color: FlexiColors.muted,
                              fontSize: 11,
                            ),
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

  static List<_Notif> _buildNotifications(DemoDeliveryStore store) {
    final notifications = <_Notif>[];

    if (store.canShowOffer) {
      notifications.add(
        _Notif(
          Icons.notifications_active_outlined,
          'Flexi Pickup Offer',
          'Pick up at ${store.nodeName} and get ${store.formattedVoucher}.',
          'Now',
          FlexiColors.orange,
          FlexiColors.orangeSoft,
        ),
      );
    }

    if (store.shouldRouteToNode) {
      notifications.add(
        _Notif(
          Icons.alt_route,
          'Route changed by AI',
          'Your package is now routed to ${store.nodeName}.',
          'Now',
          FlexiColors.blue,
          FlexiColors.blueSoft,
        ),
      );
    }

    if (store.status == DemoDeliveryStatus.deliveredToNode) {
      notifications.add(
        _Notif(
          Icons.storefront,
          'Package ready for pickup',
          'Your package is waiting at ${store.nodeName}.',
          'Now',
          FlexiColors.primary,
          FlexiColors.lightGreen,
        ),
      );
    }

    if (store.voucherEligible) {
      notifications.add(
        _Notif(
          Icons.payments_outlined,
          'Voucher received',
          '${store.formattedVoucher} voucher added for order ${store.orderId}.',
          'Now',
          FlexiColors.primary,
          FlexiColors.lightGreen,
        ),
      );
    }

    for (final message in store.aiMessages.reversed.take(3)) {
      if (message.type == 'user') continue;
      notifications.add(
        _Notif(
          Icons.auto_awesome,
          message.sender,
          message.message,
          'AI',
          FlexiColors.blue,
          FlexiColors.blueSoft,
        ),
      );
    }

    if (notifications.isEmpty) {
      notifications.add(
        _Notif(
          Icons.local_shipping_outlined,
          'Delivery active',
          store.activeDeliverySubtitle,
          'Now',
          FlexiColors.blue,
          FlexiColors.blueSoft,
        ),
      );
    }

    return notifications;
  }
}

class _Notif {
  const _Notif(
    this.icon,
    this.title,
    this.body,
    this.time,
    this.color,
    this.bg,
  );

  final IconData icon;
  final String title;
  final String body;
  final String time;
  final Color color;
  final Color bg;
}
