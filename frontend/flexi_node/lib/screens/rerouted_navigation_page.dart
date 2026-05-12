import 'package:flutter/material.dart';
import 'flexi_ui.dart';

class ReroutedNavigationPage extends StatelessWidget {
  const ReroutedNavigationPage({super.key});

  @override
  Widget build(BuildContext context) {
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
                const MiniMap(height: 300, showNode: true, showCustomer: false, routeToNode: true),
                Positioned(
                  top: 12,
                  left: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: FlexiColors.blueSoft,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFB7E3FF)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.auto_awesome, color: FlexiColors.blue, size: 22),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Route updated by Flexi AI. Customer accepted pickup at Indomaret Ahmad Yani.',
                            style: TextStyle(
                              color: FlexiColors.blue,
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
                    'New Destination',
                    style: TextStyle(color: FlexiColors.muted, fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Indomaret Ahmad Yani',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: const [
                      StatusPill(icon: Icons.inventory_2_outlined, label: 'SD1440-Y'),
                      StatusPill(icon: Icons.person_outline, label: 'Andika'),
                      StatusPill(icon: Icons.timer_outlined, label: '8 mins'),
                      StatusPill(icon: Icons.route, label: '1.2 km'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: FlexiPrimaryButton(
                          label: 'Navigate',
                          icon: Icons.navigation,
                          onPressed: () {},
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FlexiOutlineButton(
                          label: 'Contact',
                          icon: Icons.chat_outlined,
                          onPressed: () {},
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
                    label: 'Confirm Drop-off',
                    icon: Icons.check_circle_outline,
                    onPressed: () => _showCompletedSheet(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
                label: 'Back to Home',
                onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/driver-home', (_) => false),
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
