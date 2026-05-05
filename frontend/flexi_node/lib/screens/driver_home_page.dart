import 'package:flutter/material.dart';

class DriverHomePage extends StatelessWidget {
  const DriverHomePage({super.key});

  static const Color background = Color(0xFFF3FCEF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color primary = Color(0xFF006E2F);
  static const Color primaryContainer = Color(0xFF22C55E);
  static const Color textMain = Color(0xFF161D16);
  static const Color textMuted = Color(0xFF3D4A3D);
  static const Color surfaceContainer = Color(0xFFE8F0E4);
  static const Color surfaceContainerHigh = Color(0xFFDCE5D9);
  static const Color blue = Color(0xFF39B8FD);
  static const Color blueDark = Color(0xFF006591);
  static const Color orange = Color(0xFFEF9900);
  static const Color red = Color(0xFFBA1A1A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      bottomNavigationBar: const _DriverBottomNav(selectedIndex: 0),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              automaticallyImplyLeading: false,
              backgroundColor: surface,
              surfaceTintColor: Colors.transparent,
              elevation: 1,
              shadowColor: Colors.black.withOpacity(0.16),
              toolbarHeight: 76,
              titleSpacing: 20,
              title: Row(
                children: [
                  const _DriverAvatar(),
                  const Expanded(
                    child: Text(
                      'Flexi Nodes',
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: primaryContainer,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pushNamed(context, '/notifications'),
                    icon: const Icon(Icons.notifications_none_outlined, color: primaryContainer, size: 30),
                  )
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 34, 20, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hello, Rizky',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: textMain,
                                  fontSize: 22,
                                  height: 1.1,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.7,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Ready for today's deliveries?",
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: textMuted,
                                  fontSize: 15,
                                  height: 1.25,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDDF6DF),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: const Color(0xFF9AD9A1)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.circle, size: 12, color: Color(0xFF67B56B)),
                              SizedBox(width: 8),
                              Text(
                                'Online',
                                style: TextStyle(
                                  color: primary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    const Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: Icons.inventory_2_outlined,
                            iconColor: blueDark,
                            iconBg: Color(0xFFE5F4FF),
                            badge: '70%',
                            value: '14',
                            total: '/20',
                            label: 'Deliveries Today',
                            progress: 0.70,
                            progressColor: primary,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.access_time,
                            iconColor: red,
                            iconBg: Color(0xFFFFECEA),
                            badge: 'Action Req.',
                            badgeColor: Color(0xFFFFECEA),
                            badgeTextColor: red,
                            value: '2',
                            label: 'Delayed Parcels',
                            progress: null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 38),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Active Route',
                            style: TextStyle(
                              color: textMain,
                              fontSize: 30,
                              height: 1.1,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pushNamed(context, '/rerouted-navigation'),
                          child: const Text(
                            'View Map',
                            style: TextStyle(
                              color: primary,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 16),
                    const _ActiveRouteCard(),
                    const SizedBox(height: 38),
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        color: textMain,
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: _ActionTile(
                            icon: Icons.archive_outlined,
                            iconColor: blueDark,
                            iconBg: Color(0xFFE5F4FF),
                            label: 'Deliveries',
                            onTap: () => Navigator.pushNamed(context, '/delivery-details'),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _ActionTile(
                            icon: Icons.explore_outlined,
                            iconColor: primary,
                            iconBg: Color(0xFFDDF6DF),
                            label: 'Navigation',
                            onTap: () => Navigator.pushNamed(context, '/rerouted-navigation'),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _ActionTile(
                            icon: Icons.account_balance_wallet_outlined,
                            iconColor: Color(0xFF855300),
                            iconBg: Color(0xFFFFF1D8),
                            label: 'Earnings',
                            onTap: () {},
                          ),
                        ),
                      ],
                    ),
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

class _DriverAvatar extends StatelessWidget {
  const _DriverAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: DriverHomePage.primary.withOpacity(0.4), width: 2),
        gradient: const LinearGradient(
          colors: [Color(0xFFB9DDD0), Color(0xFF006E2F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Icon(Icons.person, color: Colors.white, size: 30),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.badge,
    this.badgeColor,
    this.badgeTextColor,
    required this.value,
    this.total,
    required this.label,
    required this.progress,
    this.progressColor,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String badge;
  final Color? badgeColor;
  final Color? badgeTextColor;
  final String value;
  final String? total;
  final String label;
  final double? progress;
  final Color? progressColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 188,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: DriverHomePage.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DriverHomePage.surfaceContainerHigh),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: iconBg,
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
                decoration: BoxDecoration(
                  color: badgeColor ?? const Color(0xFFE5F4FF),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    color: badgeTextColor ?? DriverHomePage.blueDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            ],
          ),
          const Spacer(),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    color: DriverHomePage.textMain,
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (total != null)
                  TextSpan(
                    text: total!,
                    style: const TextStyle(
                      color: DriverHomePage.textMuted,
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: DriverHomePage.textMuted,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (progress != null) ...[
            const SizedBox(height: 18),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: DriverHomePage.surfaceContainerHigh,
                valueColor: AlwaysStoppedAnimation<Color>(progressColor ?? DriverHomePage.primary),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ActiveRouteCard extends StatelessWidget {
  const _ActiveRouteCard();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: DriverHomePage.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, '/rerouted-navigation'),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: DriverHomePage.textMuted.withOpacity(0.3)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 228,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    const _RouteMapPreview(),
                    Positioned(
                      top: 14,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: DriverHomePage.orange,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.warning_amber, size: 20, color: Color(0xFF5C3800)),
                            SizedBox(width: 8),
                            Text(
                              'Heavy traffic detected',
                              style: TextStyle(
                                color: Color(0xFF5C3800),
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
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
                padding: const EdgeInsets.fromLTRB(26, 26, 26, 26),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: DriverHomePage.surfaceContainer,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'Package SD1440-Y',
                                  style: TextStyle(
                                    color: DriverHomePage.textMuted,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),
                              const Text(
                                'Andika Sujanto',
                                style: TextStyle(
                                  color: DriverHomePage.textMain,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Jl. Sudirman Kav 52-53, Senayan,...',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: DriverHomePage.textMuted,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 74,
                          height: 78,
                          decoration: BoxDecoration(
                            color: DriverHomePage.surfaceContainer.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: DriverHomePage.surfaceContainerHigh),
                          ),
                          child: const Center(
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: '12\n',
                                    style: TextStyle(
                                      color: DriverHomePage.textMain,
                                      fontSize: 26,
                                      fontWeight: FontWeight.w700,
                                      height: 1.1,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'mins',
                                    style: TextStyle(
                                      color: DriverHomePage.textMuted,
                                      fontSize: 16,
                                      height: 1.25,
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
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 60,
                            child: ElevatedButton.icon(
                              onPressed: () => Navigator.pushNamed(context, '/rerouted-navigation'),
                              icon: const Icon(Icons.navigation, size: 25),
                              label: const Text('Start Route'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: DriverHomePage.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                textStyle: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 60,
                            child: OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.phone_outlined, size: 25),
                              label: const Text('Call'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: DriverHomePage.textMain,
                                side: BorderSide(color: DriverHomePage.textMuted.withOpacity(0.35)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                textStyle: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
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

class _RouteMapPreview extends StatelessWidget {
  const _RouteMapPreview();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _RouteMapPainter(),
      child: Container(),
    );
  }
}

class _RouteMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF22303A));

    final blockPaint = Paint()..color = Colors.white.withOpacity(0.09);
    for (double x = -40; x < size.width; x += 70) {
      canvas.drawRect(Rect.fromLTWH(x, 0, 38, size.height), blockPaint);
    }

    final roadPaint = Paint()
      ..color = Colors.white.withOpacity(0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (double y = 20; y < size.height; y += 38) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y + 60), roadPaint);
    }
    for (double x = 15; x < size.width; x += 52) {
      canvas.drawLine(Offset(x, 0), Offset(x + 42, size.height), roadPaint);
    }

    final route = Path()
      ..moveTo(size.width * 0.58, 0)
      ..cubicTo(size.width * 0.58, 45, size.width * 0.47, 50, size.width * 0.52, 86)
      ..cubicTo(size.width * 0.57, 124, size.width * 0.45, 130, size.width * 0.42, 160)
      ..cubicTo(size.width * 0.38, 198, size.width * 0.48, 205, size.width * 0.45, size.height);

    canvas.drawPath(
      route,
      Paint()
        ..color = const Color(0xFF52FF3E).withOpacity(0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawCircle(
      Offset(size.width * 0.58, 18),
      14,
      Paint()..color = DriverHomePage.blue,
    );
    canvas.drawCircle(
      Offset(size.width * 0.58, 18),
      6,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: DriverHomePage.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 138,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: DriverHomePage.surfaceContainerHigh),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: iconBg,
                child: Icon(icon, color: iconColor, size: 30),
              ),
              const SizedBox(height: 18),
              Text(
                label,
                style: const TextStyle(
                  color: DriverHomePage.textMain,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DriverBottomNav extends StatelessWidget {
  const _DriverBottomNav({required this.selectedIndex});

  final int selectedIndex;

  static const items = [
    (Icons.home_outlined, 'Home'),
    (Icons.inventory_2_outlined, 'Orders'),
    (Icons.map_outlined, 'Map'),
    (Icons.confirmation_num_outlined, 'Vouchers'),
    (Icons.person_outline, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      decoration: BoxDecoration(
        color: DriverHomePage.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: List.generate(items.length, (index) {
          final bool active = index == selectedIndex;
          final item = items[index];
          return Expanded(
            child: InkWell(
              onTap: () {
                if (index == 0) return;
                final routes = ['/driver-home', '/delivery-details', '/rerouted-navigation', '/vouchers', '/profile'];
                Navigator.pushNamed(context, routes[index]);
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 54,
                    height: 42,
                    decoration: BoxDecoration(
                      color: active ? const Color(0xFFE8F7ED) : Colors.transparent,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Icon(
                      item.$1,
                      color: active ? DriverHomePage.primaryContainer : const Color(0xFF9AA7B8),
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.$2,
                    style: TextStyle(
                      color: active ? DriverHomePage.primary : const Color(0xFF8FA0B2),
                      fontSize: 14,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
