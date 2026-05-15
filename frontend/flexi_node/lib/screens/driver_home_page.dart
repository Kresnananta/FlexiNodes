import 'package:flutter/material.dart';
import 'live_route_preview.dart';
import '../data/demo_delivery_store.dart';
import 'flexi_ui.dart';

class DriverHomePage extends StatelessWidget {
  const DriverHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: demoDeliveryStore,
      builder: (context, _) {
        final store = demoDeliveryStore;

        return Scaffold(
          backgroundColor: FlexiColors.bg,
          bottomNavigationBar: const CompactBottomNav(
            currentIndex: 0,
            routes: [
              '/driver-home',
              '/delivery-details',
              '/rerouted-navigation',
              '/vouchers',
              '/profile',
            ],
          ),
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  automaticallyImplyLeading: false,
                  backgroundColor: FlexiColors.surface,
                  surfaceTintColor: Colors.transparent,
                  elevation: 0.5,
                  toolbarHeight: 62,
                  titleSpacing: 16,
                  title: Row(
                    children: [
                      const CircleAvatar(
                        radius: 21,
                        backgroundColor: FlexiColors.primary,
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Flexi Nodes',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: FlexiColors.green,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/notifications'),
                        icon: const Icon(
                          Icons.notifications_none,
                          color: FlexiColors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _DriverHeader(store: store),
                        const SizedBox(height: 14),
                        _DemoControl(store: store),
                        const SizedBox(height: 18),
                        const _StatsGrid(),
                        const SizedBox(height: 24),
                        _SectionHeader(
                          title: 'Active Route',
                          action: 'AI Chat',
                          onTap: () => Navigator.pushNamed(context, '/ai-chat'),
                        ),
                        const SizedBox(height: 12),
                        _ActiveRouteCard(store: store),
                        const SizedBox(height: 24),
                        const Text(
                          'Quick Actions',
                          style: TextStyle(
                            color: FlexiColors.text,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const _QuickActions(),
                      ],
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

class _DemoControl extends StatelessWidget {
  const _DemoControl({required this.store});

  final DemoDeliveryStore store;

  @override
  Widget build(BuildContext context) {
    if (!store.offerCreated) {
      return FlexiPrimaryButton(
        label: 'Simulate Heavy Traffic',
        icon: Icons.traffic_outlined,
        backgroundColor: FlexiColors.orange,
        onPressed: store.simulateHeavyTraffic,
      );
    }

    return FlexiCard(
      color: store.shouldRouteToNode
          ? FlexiColors.lightGreen
          : FlexiColors.orangeSoft,
      child: Row(
        children: [
          Icon(
            store.shouldRouteToNode ? Icons.alt_route : Icons.warning_amber,
            color: store.shouldRouteToNode
                ? FlexiColors.primary
                : FlexiColors.orange,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              store.shouldRouteToNode
                  ? 'Receiver accepted. Route now goes to ${store.nodeName}.'
                  : 'Traffic detected. Waiting for receiver approval.',
              style: TextStyle(
                color: store.shouldRouteToNode
                    ? FlexiColors.primary
                    : FlexiColors.orange,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DriverHeader extends StatelessWidget {
  const _DriverHeader({required this.store});

  final DemoDeliveryStore store;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, ${store.driverName.split(' ').first}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: FlexiColors.text,
                  fontSize: 27,
                  height: 1.1,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Ready for today's deliveries?",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: FlexiColors.muted, fontSize: 14),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFFDDF6DF),
            borderRadius: BorderRadius.circular(999),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.circle, color: Color(0xFF67B56B), size: 9),
              SizedBox(width: 6),
              Text(
                'Online',
                style: TextStyle(
                  color: FlexiColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.inventory_2_outlined,
            iconColor: FlexiColors.blue,
            iconBg: FlexiColors.blueSoft,
            badge: '70%',
            value: '14',
            total: '/20',
            label: 'Deliveries Today',
            progress: 0.7,
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            icon: Icons.access_time,
            iconColor: FlexiColors.red,
            iconBg: FlexiColors.redSoft,
            badge: 'Action',
            value: '2',
            total: null,
            label: 'Delayed Parcels',
            progress: null,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.badge,
    required this.value,
    required this.total,
    required this.label,
    required this.progress,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String badge;
  final String value;
  final String? total;
  final String label;
  final double? progress;

  @override
  Widget build(BuildContext context) {
    return FlexiCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: iconBg,
                child: Icon(icon, color: iconColor, size: 19),
              ),
              const Spacer(),
              StatusPill(label: badge, color: iconColor, background: iconBg),
            ],
          ),
          const SizedBox(height: 17),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    color: FlexiColors.text,
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (total != null)
                  TextSpan(
                    text: total!,
                    style: const TextStyle(
                      color: FlexiColors.muted,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: FlexiColors.muted,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (progress != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: FlexiColors.border,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  FlexiColors.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.action,
    required this.onTap,
  });

  final String title;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: FlexiColors.text,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        TextButton(
          onPressed: onTap,
          child: Text(
            action,
            style: const TextStyle(
              color: FlexiColors.primary,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _ActiveRouteCard extends StatelessWidget {
  const _ActiveRouteCard({required this.store});

  final DemoDeliveryStore store;

  @override
  Widget build(BuildContext context) {
    return FlexiCard(
      padding: EdgeInsets.zero,
      onTap: () => Navigator.pushNamed(context, '/rerouted-navigation'),
      child: Column(
        children: [
          const LiveRoutePreview(
            height: 150,
            mode: 'driver',
            showOpenButton: false,
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _RouteText(store: store)),
                    const SizedBox(width: 10),
                    Container(
                      width: 58,
                      height: 62,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F0E4),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: store.shouldRouteToNode ? '8\n' : '20\n',
                                style: const TextStyle(
                                  color: FlexiColors.text,
                                  fontSize: 21,
                                  fontWeight: FontWeight.w900,
                                  height: 1.0,
                                ),
                              ),
                              const TextSpan(
                                text: 'mins',
                                style: TextStyle(
                                  color: FlexiColors.muted,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: FlexiPrimaryButton(
                        label: 'Start Route',
                        icon: Icons.navigation,
                        onPressed: () => Navigator.pushNamed(
                          context,
                          '/real-map',
                          arguments: {'mode': 'driver', 'usePhoneGps': true},
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: store.statusText == 'rerouted_to_node'
                          ? FlexiOutlineButton(
                              label: 'Scan Mitra QR',
                              icon: Icons.qr_code_scanner,
                              onPressed: () => Navigator.pushNamed(
                                context,
                                '/qr-scanner',
                                arguments: {
                                  'expectedType': 'mitra_node',
                                  'title': 'Scan Mitra QR',
                                },
                              ),
                            )
                          : FlexiOutlineButton(
                              label: 'Details',
                              icon: Icons.info_outline,
                              onPressed: () => Navigator.pushNamed(
                                context,
                                '/delivery-details',
                              ),
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteText extends StatelessWidget {
  const _RouteText({required this.store});

  final DemoDeliveryStore store;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StatusPill(
          label: 'Package ${store.orderId}',
          icon: Icons.inventory_2_outlined,
        ),
        const SizedBox(height: 10),
        Text(
          store.shouldRouteToNode ? store.nodeName : store.receiverName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: FlexiColors.text,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          store.shouldRouteToNode
              ? 'New destination after receiver accepted.'
              : store.receiverLocationText,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: FlexiColors.muted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    final items = [
      _Action(
        Icons.archive_outlined,
        'Deliveries',
        FlexiColors.blue,
        FlexiColors.blueSoft,
        '/delivery-details',
      ),
      _Action(
        Icons.explore_outlined,
        'Navigation',
        FlexiColors.primary,
        FlexiColors.lightGreen,
        '/rerouted-navigation',
      ),
      _Action(
        Icons.auto_awesome,
        'AI Chat',
        FlexiColors.orange,
        FlexiColors.orangeSoft,
        '/ai-chat',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisExtent: 94,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return Material(
          color: FlexiColors.surface,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: () => Navigator.pushNamed(context, item.route),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color: FlexiColors.border),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 21,
                    backgroundColor: item.bg,
                    child: Icon(item.icon, color: item.color, size: 21),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: FlexiColors.text,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Action {
  const _Action(this.icon, this.label, this.color, this.bg, this.route);

  final IconData icon;
  final String label;
  final Color color;
  final Color bg;
  final String route;
}
