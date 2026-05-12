import 'package:flutter/material.dart';
import 'flexi_ui.dart';

class FlexiPickupOfferPage extends StatelessWidget {
  const FlexiPickupOfferPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlexiColors.bg,
      appBar: const FlexiAppBar(title: 'Flexi Offer'),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: FlexiColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: FlexiColors.border),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  CircleAvatar(
                    backgroundColor: FlexiColors.lightGreen,
                    child: Icon(Icons.notifications_active_outlined, color: FlexiColors.primary),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Flexi Pickup Offer\n',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                          ),
                          TextSpan(
                            text:
                                'Your courier is delayed by traffic. Pick up at Indomaret Ahmad Yani, 75m away, and get Rp5.000 cashback.',
                            style: TextStyle(fontSize: 12.5, color: FlexiColors.muted, height: 1.35),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const MiniMap(height: 180, showNode: true, showCustomer: true, routeToNode: true),
            const SizedBox(height: 18),
            FlexiCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const StatusPill(
                    icon: Icons.auto_awesome,
                    label: 'AI Recommended',
                    color: FlexiColors.blue,
                    background: FlexiColors.blueSoft,
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Indomaret Ahmad Yani',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'A nearby partner node selected by Flexi AI.',
                    style: TextStyle(color: FlexiColors.muted, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  const _OfferStats(),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: FlexiColors.lightGreen,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.verified_user_outlined, color: FlexiColors.primary, size: 22),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'OTP handover protected. Your package can only be released using your pickup code.',
                            style: TextStyle(color: FlexiColors.primary, fontSize: 12.5, height: 1.35),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  FlexiPrimaryButton(
                    label: 'Accept & Pick Up',
                    icon: Icons.check_circle_outline,
                    onPressed: () => Navigator.pushNamed(context, '/confirmation'),
                  ),
                  const SizedBox(height: 10),
                  FlexiOutlineButton(
                    label: 'Keep Door-to-Door Delivery',
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OfferStats extends StatelessWidget {
  const _OfferStats();

  @override
  Widget build(BuildContext context) {
    final items = [
      _Stat(Icons.place_outlined, '75m', 'Distance'),
      _Stat(Icons.directions_walk, '2 min', 'Walk'),
      _Stat(Icons.payments_outlined, 'Rp5k', 'Cashback'),
    ];

    return Row(
      children: items
          .map(
            (item) => Expanded(
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                decoration: BoxDecoration(
                  color: FlexiColors.bg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(item.icon, color: FlexiColors.primary, size: 20),
                    const SizedBox(height: 6),
                    Text(
                      item.value,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.label,
                      style: const TextStyle(fontSize: 10.5, color: FlexiColors.muted),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _Stat {
  const _Stat(this.icon, this.value, this.label);

  final IconData icon;
  final String value;
  final String label;
}
