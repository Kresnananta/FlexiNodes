import 'package:flutter/material.dart';
import 'flexi_ui.dart';

class ConfirmationPage extends StatelessWidget {
  const ConfirmationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlexiColors.bg,
      appBar: const FlexiAppBar(title: 'Confirmed'),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 22, 16, 24),
          children: [
            const CircleAvatar(
              radius: 38,
              backgroundColor: FlexiColors.lightGreen,
              child: Icon(Icons.check_circle, color: FlexiColors.primary, size: 50),
            ),
            const SizedBox(height: 18),
            const Text(
              'Pickup Node Confirmed',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your package will be dropped at Indomaret Ahmad Yani.',
              textAlign: TextAlign.center,
              style: TextStyle(color: FlexiColors.muted, fontSize: 14, height: 1.35),
            ),
            const SizedBox(height: 22),
            FlexiCard(
              child: Column(
                children: const [
                  _InfoRow(label: 'Order ID', value: 'SD1440-Y'),
                  _InfoRow(label: 'Pickup location', value: 'Indomaret Ahmad Yani'),
                  _InfoRow(label: 'Cashback', value: 'Rp5.000'),
                  _InfoRow(label: 'Ready time', value: '14:25'),
                ],
              ),
            ),
            const SizedBox(height: 14),
            FlexiCard(
              color: FlexiColors.lightGreen,
              child: Column(
                children: [
                  const Text(
                    'OTP Pickup Code',
                    style: TextStyle(color: FlexiColors.muted, fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: FlexiColors.border),
                    ),
                    child: const Text(
                      '8421',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: FlexiColors.primary,
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Show this code to the cashier when picking up your package.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: FlexiColors.muted, fontSize: 12.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            FlexiPrimaryButton(
              label: 'Open Map',
              icon: Icons.map_outlined,
              onPressed: () => Navigator.pushNamed(context, '/tracking'),
            ),
            const SizedBox(height: 10),
            FlexiOutlineButton(
              label: 'Share Pickup Code',
              icon: Icons.share_outlined,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(color: FlexiColors.muted, fontSize: 13)),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: FlexiColors.text, fontSize: 13.5, fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}
