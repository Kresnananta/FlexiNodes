import 'package:flutter/material.dart';

class DriverHomePage extends StatelessWidget {
  const DriverHomePage({super.key});

  static const bg = Color(0xFFF3FCEF);
  static const surface = Colors.white;
  static const primary = Color(0xFF006E2F);
  static const green = Color(0xFF22C55E);
  static const text = Color(0xFF161D16);
  static const muted = Color(0xFF3D4A3D);
  static const border = Color(0xFFDCE5D9);
  static const blue = Color(0xFF006591);
  static const orange = Color(0xFFEF9900);
  static const red = Color(0xFFBA1A1A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      bottomNavigationBar: const _BottomNav(),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              automaticallyImplyLeading: false,
              backgroundColor: surface,
              surfaceTintColor: Colors.transparent,
              elevation: 0.5,
              toolbarHeight: 62,
              titleSpacing: 16,
              title: Row(
                children: [
                  const CircleAvatar(
                    radius: 21,
                    backgroundColor: primary,
                    child: Icon(Icons.person, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Flexi Nodes',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: green,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pushNamed(context, '/notifications'),
                    icon: const Icon(Icons.notifications_none, color: green),
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
                    const _DriverHeader(),
                    const SizedBox(height: 18),
                    const _StatsGrid(),
                    const SizedBox(height: 24),
                    _SectionHeader(
                      title: 'Active Route',
                      action: 'View Map',
                      onTap: () => Navigator.pushNamed(context, '/rerouted-navigation'),
                    ),
                    const SizedBox(height: 12),
                    const _ActiveRouteCard(),
                    const SizedBox(height: 24),
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        color: text,
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
  }
}

class _DriverHeader extends StatelessWidget {
  const _DriverHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, Rizky',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: DriverHomePage.text,
                  fontSize: 27,
                  height: 1.1,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 6),
              Text(
                "Ready for today's deliveries?",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: DriverHomePage.muted,
                  fontSize: 14,
                ),
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
                  color: DriverHomePage.primary,
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
            iconColor: DriverHomePage.blue,
            iconBg: Color(0xFFE5F4FF),
            badge: '70%',
            badgeColor: Color(0xFFE5F4FF),
            badgeTextColor: DriverHomePage.blue,
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
            iconColor: DriverHomePage.red,
            iconBg: Color(0xFFFFECEA),
            badge: 'Action',
            badgeColor: Color(0xFFFFECEA),
            badgeTextColor: DriverHomePage.red,
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
    required this.badgeColor,
    required this.badgeTextColor,
    required this.value,
    required this.total,
    required this.label,
    required this.progress,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String badge;
  final Color badgeColor;
  final Color badgeTextColor;
  final String value;
  final String? total;
  final String label;
  final double? progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 136),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: DriverHomePage.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DriverHomePage.border),
      ),
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
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: FittedBox(
                    child: Text(
                      badge,
                      style: TextStyle(
                        color: badgeTextColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 17),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    color: DriverHomePage.text,
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (total != null)
                  TextSpan(
                    text: total!,
                    style: const TextStyle(
                      color: DriverHomePage.muted,
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
              color: DriverHomePage.muted,
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
                backgroundColor: DriverHomePage.border,
                valueColor: const AlwaysStoppedAnimation<Color>(DriverHomePage.primary),
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
              color: DriverHomePage.text,
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
              color: DriverHomePage.primary,
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
  const _ActiveRouteCard();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: DriverHomePage.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, '/rerouted-navigation'),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: DriverHomePage.border),
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              SizedBox(
                height: 150,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    const _MiniMap(),
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 220),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        decoration: BoxDecoration(
                          color: DriverHomePage.orange,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.warning_amber, size: 16, color: Color(0xFF5C3800)),
                            SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                'Heavy traffic detected',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Color(0xFF5C3800),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _RouteText(),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: 58,
                          height: 62,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F0E4),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: '12\n',
                                    style: TextStyle(
                                      color: DriverHomePage.text,
                                      fontSize: 21,
                                      fontWeight: FontWeight.w900,
                                      height: 1.0,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'mins',
                                    style: TextStyle(
                                      color: DriverHomePage.muted,
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
                          child: SizedBox(
                            height: 42,
                            child: ElevatedButton.icon(
                              onPressed: () => Navigator.pushNamed(context, '/rerouted-navigation'),
                              icon: const Icon(Icons.navigation, size: 17),
                              label: const Text('Start Route'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: DriverHomePage.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                textStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: SizedBox(
                            height: 42,
                            child: OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.phone_outlined, size: 17),
                              label: const Text('Call'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: DriverHomePage.text,
                                side: BorderSide(color: DriverHomePage.muted.withOpacity(0.3)),
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                textStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900),
                              ),
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
        ),
      ),
    );
  }
}

class _RouteText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SmallTag(text: 'Package SD1440-Y'),
        SizedBox(height: 10),
        Text(
          'Andika Sujanto',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: DriverHomePage.text,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Jl. Sudirman Kav 52-53, Senayan,...',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: DriverHomePage.muted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _SmallTag extends StatelessWidget {
  const _SmallTag({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F0E4),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: DriverHomePage.muted,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _MiniMap extends StatelessWidget {
  const _MiniMap();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _MiniMapPainter());
  }
}

class _MiniMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF22303A));

    final road = Paint()
      ..color = Colors.white.withOpacity(0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    for (double x = -20; x < size.width; x += 46) {
      canvas.drawLine(Offset(x, 0), Offset(x + 40, size.height), road);
    }
    for (double y = 10; y < size.height; y += 34) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y + 32), road);
    }

    final route = Path()
      ..moveTo(size.width * 0.62, -5)
      ..cubicTo(size.width * 0.55, 40, size.width * 0.45, 50, size.width * 0.50, 80)
      ..cubicTo(size.width * 0.56, 112, size.width * 0.40, 118, size.width * 0.42, size.height + 5);

    canvas.drawPath(
      route,
      Paint()
        ..color = const Color(0xFF52FF3E)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawCircle(Offset(size.width * 0.62, 16), 11, Paint()..color = DriverHomePage.blue);
    canvas.drawCircle(Offset(size.width * 0.62, 16), 5, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    final items = [
      _Action(Icons.archive_outlined, 'Deliveries', DriverHomePage.blue, const Color(0xFFE5F4FF), '/delivery-details'),
      _Action(Icons.explore_outlined, 'Navigation', DriverHomePage.primary, const Color(0xFFDDF6DF), '/rerouted-navigation'),
      _Action(Icons.account_balance_wallet_outlined, 'Earnings', const Color(0xFF855300), const Color(0xFFFFF1D8), null),
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
          color: DriverHomePage.surface,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: () {
              if (item.route != null) Navigator.pushNamed(context, item.route!);
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color: DriverHomePage.border),
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
                      color: DriverHomePage.text,
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
  final String? route;
}

class _BottomNav extends StatelessWidget {
  const _BottomNav();

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: DriverHomePage.primary,
      unselectedItemColor: const Color(0xFF8FA0B2),
      selectedFontSize: 11,
      unselectedFontSize: 10,
      iconSize: 22,
      onTap: (index) {
        final routes = ['/driver-home', '/delivery-details', '/rerouted-navigation', '/vouchers', '/profile'];
        if (index != 0) Navigator.pushNamed(context, routes[index]);
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), label: 'Orders'),
        BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: 'Map'),
        BottomNavigationBarItem(icon: Icon(Icons.confirmation_num_outlined), label: 'Voucher'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
      ],
    );
  }
}
