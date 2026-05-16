import 'package:flutter/material.dart';

import '../data/demo_delivery_store.dart';
import 'flexi_ui.dart';
import 'live_route_preview.dart';

class NearbyNodesPage extends StatelessWidget {
  const NearbyNodesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: demoDeliveryStore,
      builder: (context, _) {
        final store = demoDeliveryStore;
        final selectedNodeId = store.nodeId;
        final nodes = store.pickupNodes;

        return Scaffold(
          backgroundColor: FlexiColors.bg,
          appBar: const FlexiAppBar(title: 'Nearby Nodes'),
          body: SafeArea(
            top: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                const LiveRoutePreview(
                  height: 210,
                  mode: 'receiver',
                  forceDestinationToSelectedNode: true,
                  showOpenButton: false,
                ),
                const SizedBox(height: 12),
                FlexiCard(
                  color: FlexiColors.lightGreen,
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: FlexiColors.primary,
                        child: Icon(Icons.storefront, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(
                                text: 'Selected node\n',
                                style: TextStyle(
                                  color: FlexiColors.muted,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextSpan(
                                text:
                                    '${store.nodeName} - ${store.nodeDistance}',
                                style: const TextStyle(
                                  color: FlexiColors.text,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      StatusPill(
                        label: store.formattedVoucher,
                        color: FlexiColors.primary,
                        background: Colors.white,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Pickup nodes under 100m',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Tap a node to preview the route. Choose it to update the voucher offer.',
                  style: TextStyle(color: FlexiColors.muted, fontSize: 13),
                ),
                const SizedBox(height: 14),
                if (nodes.isEmpty)
                  const FlexiCard(
                    child: Text(
                      'No pickup nodes are available from Firestore yet.',
                      style: TextStyle(
                        color: FlexiColors.muted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                else
                  ...nodes.map(
                    (node) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _NodeCard(
                        node: node,
                        isSelected: selectedNodeId == node.id,
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
}

class _NodeCard extends StatelessWidget {
  const _NodeCard({required this.node, required this.isSelected});

  final DemoPickupNode node;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return FlexiCard(
      color: isSelected ? FlexiColors.lightGreen : FlexiColors.surface,
      onTap: () => demoDeliveryStore.selectPickupNode(node),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: isSelected
                    ? FlexiColors.green
                    : FlexiColors.bg,
                child: Icon(
                  Icons.storefront,
                  color: isSelected ? Colors.white : FlexiColors.primary,
                  size: 21,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  node.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (isSelected)
                const StatusPill(
                  icon: Icons.check_circle,
                  label: 'Selected',
                  color: FlexiColors.primary,
                  background: Colors.white,
                )
              else if (node.recommended)
                const StatusPill(
                  label: 'Best',
                  color: FlexiColors.primary,
                  background: FlexiColors.lightGreen,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              StatusPill(icon: Icons.place_outlined, label: node.distance),
              StatusPill(icon: Icons.directions_walk, label: node.walkingTime),
              StatusPill(
                icon: Icons.inventory_2_outlined,
                label: node.capacity,
              ),
              StatusPill(
                icon: Icons.check_circle_outline,
                label: node.status,
                color: node.status == 'Almost full'
                    ? FlexiColors.orange
                    : FlexiColors.primary,
                background: node.status == 'Almost full'
                    ? FlexiColors.orangeSoft
                    : FlexiColors.lightGreen,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Voucher ${node.voucherText}',
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
                  onPressed: () {
                    demoDeliveryStore.selectPickupNode(node);
                    Navigator.pushNamed(context, '/flexi-offer');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSelected
                        ? FlexiColors.primary
                        : FlexiColors.green,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  child: Text(isSelected ? 'Choose Node' : 'Select & Choose'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
