import 'package:flutter/material.dart';
import 'flexi_ui.dart';

class NearbyNodesPage extends StatelessWidget {
  const NearbyNodesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final nodes = [
      _Node('Indomaret Ahmad Yani', '75m', '2 min', 'Available', '6 slots', 'Rp5.000', true),
      _Node('Warung Bu Sari', '90m', '3 min', 'Available', '3 slots', 'Rp4.000', false),
      _Node('Alfamart Kertajaya', '100m', '4 min', 'Almost full', '1 slot', 'Rp6.000', false),
    ];

    return Scaffold(
      backgroundColor: FlexiColors.bg,
      appBar: const FlexiAppBar(title: 'Nearby Nodes'),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            const MiniMap(height: 190, showNode: true, showCustomer: true, routeToNode: true),
            const SizedBox(height: 16),
            const Text(
              'Pickup nodes under 100m',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            const Text(
              'Choose one nearby partner node to receive cashback.',
              style: TextStyle(color: FlexiColors.muted, fontSize: 13),
            ),
            const SizedBox(height: 14),
            ...nodes.map(
              (node) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _NodeCard(node: node),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NodeCard extends StatelessWidget {
  const _NodeCard({required this.node});

  final _Node node;

  @override
  Widget build(BuildContext context) {
    return FlexiCard(
      color: node.recommended ? FlexiColors.lightGreen : FlexiColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: node.recommended ? FlexiColors.green : FlexiColors.bg,
                child: Icon(
                  Icons.storefront,
                  color: node.recommended ? Colors.white : FlexiColors.primary,
                  size: 21,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  node.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                ),
              ),
              if (node.recommended)
                const StatusPill(
                  label: 'Best',
                  color: FlexiColors.primary,
                  background: Colors.white,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              StatusPill(icon: Icons.place_outlined, label: node.distance),
              StatusPill(icon: Icons.directions_walk, label: node.walkTime),
              StatusPill(icon: Icons.inventory_2_outlined, label: node.capacity),
              StatusPill(
                icon: Icons.check_circle_outline,
                label: node.status,
                color: node.status == 'Almost full' ? FlexiColors.orange : FlexiColors.primary,
                background: node.status == 'Almost full' ? FlexiColors.orangeSoft : FlexiColors.lightGreen,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Cashback ${node.cashback}',
                  style: const TextStyle(
                    color: FlexiColors.primary,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              SizedBox(
                height: 40,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/flexi-offer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FlexiColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    textStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900),
                  ),
                  child: const Text('Choose Node'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Node {
  const _Node(
    this.name,
    this.distance,
    this.walkTime,
    this.status,
    this.capacity,
    this.cashback,
    this.recommended,
  );

  final String name;
  final String distance;
  final String walkTime;
  final String status;
  final String capacity;
  final String cashback;
  final bool recommended;
}
