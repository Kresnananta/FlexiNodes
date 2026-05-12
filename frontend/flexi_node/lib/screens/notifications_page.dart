import 'package:flutter/material.dart';
import 'flexi_ui.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      _Notif(Icons.notifications_active_outlined, 'Flexi Pickup Offer', 'Pick up at Indomaret Ahmad Yani and get Rp5.000 cashback.', 'Now', FlexiColors.orange, FlexiColors.orangeSoft),
      _Notif(Icons.alt_route, 'Route changed by AI', 'Customer accepted reroute to partner node.', '2m', FlexiColors.blue, FlexiColors.blueSoft),
      _Notif(Icons.storefront, 'Package ready for pickup', 'Your package is waiting at Indomaret Ahmad Yani.', '8m', FlexiColors.primary, FlexiColors.lightGreen),
      _Notif(Icons.payments_outlined, 'Cashback received', 'Rp5.000 voucher added to your account.', '10m', FlexiColors.primary, FlexiColors.lightGreen),
    ];

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
                        child: Icon(notif.icon, color: notif.color, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(notif.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
                            const SizedBox(height: 4),
                            Text(
                              notif.body,
                              style: const TextStyle(color: FlexiColors.muted, fontSize: 12.5, height: 1.35),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(notif.time, style: const TextStyle(color: FlexiColors.muted, fontSize: 11)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Notif {
  const _Notif(this.icon, this.title, this.body, this.time, this.color, this.bg);

  final IconData icon;
  final String title;
  final String body;
  final String time;
  final Color color;
  final Color bg;
}
