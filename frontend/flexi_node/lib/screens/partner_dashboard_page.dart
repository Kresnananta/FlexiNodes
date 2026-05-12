import 'package:flutter/material.dart';
import 'flexi_ui.dart';

class PartnerDashboardPage extends StatelessWidget {
  const PartnerDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final packages = [
      _Package('SD1440-Y', 'Andika Sujanto', 'Waiting pickup', FlexiColors.orange, FlexiColors.orangeSoft),
      _Package('SD2814-H', 'Budi Utama', 'Waiting pickup', FlexiColors.orange, FlexiColors.orangeSoft),
      _Package('JX1134-K', 'Kresna Ananta', 'Picked up', FlexiColors.primary, FlexiColors.lightGreen),
      _Package('HW1108-Y', 'Darren Dexter', 'Not picked up', FlexiColors.red, FlexiColors.redSoft),
    ];

    return Scaffold(
      backgroundColor: FlexiColors.bg,
      appBar: const FlexiAppBar(title: 'Partner Node'),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
          children: [
            const Text(
              'Indomaret Ahmad Yani',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 5),
            const Text(
              'Mitra dashboard for package handover.',
              style: TextStyle(color: FlexiColors.muted, fontSize: 13),
            ),
            const SizedBox(height: 14),
            Container(
              height: 54,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: FlexiColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: FlexiColors.border),
              ),
              child: const Row(
                children: [
                  Icon(Icons.search, color: FlexiColors.muted, size: 21),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Search customer or package ID',
                      style: TextStyle(color: FlexiColors.muted, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: FlexiColors.orange,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.qr_code_scanner, color: FlexiColors.orange, size: 30),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Scan QR\n',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                          ),
                          TextSpan(
                            text: 'Use this to receive or release packages.',
                            style: TextStyle(fontSize: 12.5, height: 1.35),
                          ),
                        ],
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const Row(
              children: [
                Expanded(child: _PartnerStat(label: 'Stored', value: '12')),
                SizedBox(width: 8),
                Expanded(child: _PartnerStat(label: 'Waiting', value: '8')),
                SizedBox(width: 8),
                Expanded(child: _PartnerStat(label: 'Delivered', value: '16')),
              ],
            ),
            const SizedBox(height: 18),
            const Text('Packages', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            ...packages.map(
              (package) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: FlexiCard(
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: FlexiColors.lightGreen,
                        child: Icon(Icons.inventory_2_outlined, color: FlexiColors.primary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(package.id, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
                            Text(
                              package.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: FlexiColors.muted, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      StatusPill(
                        label: package.status,
                        color: package.color,
                        background: package.bg,
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
  }
}

class _PartnerStat extends StatelessWidget {
  const _PartnerStat({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return FlexiCard(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 3),
          Text(label, style: const TextStyle(color: FlexiColors.muted, fontSize: 11)),
        ],
      ),
    );
  }
}

class _Package {
  const _Package(this.id, this.name, this.status, this.color, this.bg);

  final String id;
  final String name;
  final String status;
  final Color color;
  final Color bg;
}
