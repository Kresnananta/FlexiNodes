import 'package:flutter/material.dart';
import 'flexi_ui.dart';

class VouchersPage extends StatelessWidget {
  const VouchersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlexiColors.bg,
      appBar: const FlexiAppBar(title: 'My Vouchers'),
      bottomNavigationBar: const CompactBottomNav(
        currentIndex: 3,
        routes: ['/receiver-home', '/orders', '/tracking', '/vouchers', '/profile'],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [Color(0xFF18B850), Color(0xFF00732F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -12,
                    bottom: -10,
                    child: Icon(Icons.confirmation_num, size: 96, color: Colors.white.withOpacity(0.14)),
                  ),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      StatusPill(
                        label: 'ACTIVE REWARD',
                        color: Colors.white,
                        background: Color(0x3322C55E),
                      ),
                      SizedBox(height: 18),
                      Text(
                        'Rp5.000 Pickup Voucher',
                        style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'From Flexi Pickup • Order SD1440-Y',
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                      SizedBox(height: 18),
                      Text(
                        'Code: FLEXI5000',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            FlexiPrimaryButton(
              label: 'Use Voucher',
              icon: Icons.shopping_bag_outlined,
              onPressed: () {},
            ),
            const SizedBox(height: 24),
            const Text(
              'Reward History',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            const _HistoryTile(
              icon: Icons.confirmation_num_outlined,
              title: 'Voucher received',
              subtitle: 'Rp5.000 pickup voucher added from Flexi Pickup',
              time: 'Today',
            ),
            const _HistoryTile(
              icon: Icons.storefront,
              title: 'Pickup completed',
              subtitle: 'Indomaret Ahmad Yani',
              time: 'Today',
            ),
            const _HistoryTile(
              icon: Icons.alt_route,
              title: 'Package rerouted',
              subtitle: 'AI optimized route due to heavy traffic',
              time: 'Today',
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: FlexiCard(
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: FlexiColors.lightGreen,
              child: Icon(icon, color: FlexiColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: FlexiColors.muted, fontSize: 12.5),
                  ),
                ],
              ),
            ),
            Text(time, style: const TextStyle(color: FlexiColors.muted, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
