import 'package:flutter/material.dart';
import 'flexi_ui.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = [
      _Order('SD1440-Y', 'Courier on the way', 'Delayed by traffic', FlexiColors.orange, FlexiColors.orangeSoft),
      _Order('SD2910-P', 'Delivered', 'Completed yesterday', FlexiColors.primary, FlexiColors.lightGreen),
      _Order('SD1742-K', 'Preparing', 'Waiting for courier pickup', FlexiColors.blue, FlexiColors.blueSoft),
    ];

    return Scaffold(
      backgroundColor: FlexiColors.bg,
      appBar: const FlexiAppBar(title: 'Orders'),
      bottomNavigationBar: const CompactBottomNav(
        currentIndex: 1,
        routes: ['/receiver-home', '/orders', '/tracking', '/vouchers', '/profile'],
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
                      const CircleAvatar(
                        backgroundColor: FlexiColors.lightGreen,
                        child: Icon(Icons.inventory_2_outlined, color: FlexiColors.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(order.id, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
                            const SizedBox(height: 3),
                            Text(order.subtitle, style: const TextStyle(color: FlexiColors.muted, fontSize: 12.5)),
                          ],
                        ),
                      ),
                      StatusPill(label: order.status, color: order.color, background: order.bg),
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

class _Order {
  const _Order(this.id, this.status, this.subtitle, this.color, this.bg);

  final String id;
  final String status;
  final String subtitle;
  final Color color;
  final Color bg;
}
