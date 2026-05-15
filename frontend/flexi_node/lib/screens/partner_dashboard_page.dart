import 'package:flutter/material.dart';

import '../data/demo_delivery_store.dart';
import 'flexi_ui.dart';

class PartnerDashboardPage extends StatelessWidget {
  const PartnerDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: demoDeliveryStore,
      builder: (context, _) {
        final store = demoDeliveryStore;
        final packages = _partnerPackages(store);
        final storedCount = packages
            .where(
              (package) => package.status == DemoDeliveryStatus.deliveredToNode,
            )
            .length;
        final deliveringCount = packages
            .where(
              (package) => package.status == DemoDeliveryStatus.reroutedToNode,
            )
            .length;
        final activeCount = packages
            .where((package) => package.status != DemoDeliveryStatus.completed)
            .length;

        return Scaffold(
          backgroundColor: FlexiColors.bg,
          appBar: const FlexiAppBar(title: 'Partner Node'),
          body: SafeArea(
            top: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 26,
                      backgroundColor: FlexiColors.lightGreen,
                      child: Icon(
                        Icons.storefront,
                        color: FlexiColors.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            store.nodeName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Dashboard penitipan paket mitra.',
                            style: TextStyle(
                              color: FlexiColors.muted,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Dashboard',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 10),
                _DashboardStatsCard(
                  activeCount: activeCount,
                  storedCount: storedCount,
                  deliveringCount: deliveringCount,
                ),
                const SizedBox(height: 20),
                FlexiPrimaryButton(
                  label: 'Scan / Show QR',
                  icon: Icons.qr_code_scanner,
                  backgroundColor: FlexiColors.orange,
                  onPressed: () => Navigator.pushNamed(
                    context,
                    '/qr-scanner',
                    arguments: {'title': 'Scan / Show QR'},
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  'Daftar Penitipan',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 10),
                _PackageListCard(packages: packages, store: store),
                const SizedBox(height: 18),
                const Text(
                  'Handover Timeline',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 12),
                FlexiCard(
                  child: Column(
                    children: [
                      TimelineStep(
                        title: 'Rerouted to partner node',
                        subtitle: 'Receiver accepted Flexi Pickup offer',
                        active: store.offerAccepted || store.shouldRouteToNode,
                      ),
                      TimelineStep(
                        title: 'Package stored at mitra',
                        subtitle:
                            'Driver handover confirmed at ${store.nodeName}',
                        active:
                            store.dropoffConfirmed ||
                            store.statusText == 'delivered_to_node' ||
                            store.statusText == 'completed',
                      ),
                      TimelineStep(
                        title: 'Customer QR verified',
                        subtitle: 'Order ID and OTP matched before release',
                        active: store.statusText == 'completed',
                        last: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static List<_PartnerPackage> _partnerPackages(DemoDeliveryStore store) {
    final packages = store.orders
        .where((order) {
          final isPartnerStatus =
              order.status == DemoDeliveryStatus.reroutedToNode ||
              order.status == DemoDeliveryStatus.deliveredToNode ||
              order.status == DemoDeliveryStatus.completed;
          final belongsToNode =
              order.selectedNodeId == null ||
              order.selectedNodeId == store.nodeId ||
              order.isActive;

          return isPartnerStatus && belongsToNode;
        })
        .map(
          (order) => _PartnerPackage(
            orderId: order.id,
            receiverName: order.receiverName,
            status: order.status,
          ),
        )
        .toList();

    final hasActiveOrder = packages.any(
      (package) => package.orderId == store.orderId,
    );
    if (!hasActiveOrder && store.shouldRouteToNode) {
      packages.insert(
        0,
        _PartnerPackage(
          orderId: store.orderId,
          receiverName: store.receiverName,
          status: store.status,
        ),
      );
    }

    return packages;
  }
}

class _DashboardStatsCard extends StatelessWidget {
  const _DashboardStatsCard({
    required this.activeCount,
    required this.storedCount,
    required this.deliveringCount,
  });

  final int activeCount;
  final int storedCount;
  final int deliveringCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.13),
            blurRadius: 18,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatItem(
              icon: Icons.inventory_2_outlined,
              value: activeCount,
              label: 'Paket di Toko',
            ),
          ),
          const _StatDivider(),
          Expanded(
            child: _StatItem(
              icon: Icons.schedule,
              value: storedCount,
              label: 'Menunggu Diambil',
            ),
          ),
          const _StatDivider(),
          Expanded(
            child: _StatItem(
              icon: Icons.delivery_dining,
              value: deliveringCount,
              label: 'Sedang Diantar',
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: FlexiColors.orange, size: 25),
        const SizedBox(height: 6),
        Text(
          value.toString(),
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: FlexiColors.muted, fontSize: 12.5),
        ),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1.5, height: 64, color: const Color(0xFFD9D9D9));
  }
}

class _PackageListCard extends StatelessWidget {
  const _PackageListCard({required this.packages, required this.store});

  final List<_PartnerPackage> packages;
  final DemoDeliveryStore store;

  @override
  Widget build(BuildContext context) {
    if (packages.isEmpty) {
      return FlexiCard(
        child: Column(
          children: [
            const Icon(
              Icons.inventory_2_outlined,
              color: FlexiColors.muted,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              'Belum ada paket penitipan di ${store.nodeName}.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: FlexiColors.muted,
                fontSize: 13,
                height: 1.35,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        children: [
          for (int index = 0; index < packages.length; index++)
            _PackageListTile(
              package: packages[index],
              showDivider: index != packages.length - 1,
            ),
        ],
      ),
    );
  }
}

class _PackageListTile extends StatelessWidget {
  const _PackageListTile({required this.package, required this.showDivider});

  final _PartnerPackage package;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final label = _statusLabel(package.status);
    final color = _statusColor(package.status);
    final background = _statusBackground(package.status);

    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 16, 22, 0),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      package.orderId,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Nama Pelanggan: ${package.receiverName}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: FlexiColors.text,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              StatusPill(label: label, color: color, background: background),
            ],
          ),
          if (showDivider) ...[
            const SizedBox(height: 14),
            const Divider(height: 1.2, thickness: 1.2),
          ] else
            const SizedBox(height: 18),
        ],
      ),
    );
  }

  static String _statusLabel(DemoDeliveryStatus status) {
    switch (status) {
      case DemoDeliveryStatus.deliveredToNode:
        return 'Menunggu Diambil';
      case DemoDeliveryStatus.completed:
        return 'Sudah Diambil';
      case DemoDeliveryStatus.reroutedToNode:
        return 'Sedang Diantar';
      case DemoDeliveryStatus.offerPending:
        return 'Menunggu Konfirmasi';
      case DemoDeliveryStatus.trafficDetected:
      case DemoDeliveryStatus.onDelivery:
        return 'Sedang Diantar';
    }
  }

  static Color _statusColor(DemoDeliveryStatus status) {
    switch (status) {
      case DemoDeliveryStatus.deliveredToNode:
        return FlexiColors.green;
      case DemoDeliveryStatus.completed:
        return FlexiColors.blue;
      case DemoDeliveryStatus.reroutedToNode:
      case DemoDeliveryStatus.onDelivery:
      case DemoDeliveryStatus.trafficDetected:
        return FlexiColors.orange;
      case DemoDeliveryStatus.offerPending:
        return FlexiColors.red;
    }
  }

  static Color _statusBackground(DemoDeliveryStatus status) {
    switch (status) {
      case DemoDeliveryStatus.deliveredToNode:
        return FlexiColors.lightGreen;
      case DemoDeliveryStatus.completed:
        return FlexiColors.blueSoft;
      case DemoDeliveryStatus.reroutedToNode:
      case DemoDeliveryStatus.onDelivery:
      case DemoDeliveryStatus.trafficDetected:
        return FlexiColors.orangeSoft;
      case DemoDeliveryStatus.offerPending:
        return FlexiColors.redSoft;
    }
  }
}

class _PartnerPackage {
  const _PartnerPackage({
    required this.orderId,
    required this.receiverName,
    required this.status,
  });

  final String orderId;
  final String receiverName;
  final DemoDeliveryStatus status;
}
