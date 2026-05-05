import 'package:flutter/material.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  static const Color background = Color(0xFFF3FCEF);
  static const Color primary = Color(0xFF006E2F);
  static const Color primaryContainer = Color(0xFF22C55E);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceLow = Color(0xFFEDF6EA);
  static const Color surfaceVariant = Color(0xFFDCE5D9);
  static const Color textMain = Color(0xFF161D16);
  static const Color textMuted = Color(0xFF3D4A3D);
  static const Color blue = Color(0xFF006591);
  static const Color blueSoft = Color(0xFFE5F4FF);
  static const Color orange = Color(0xFFEF9900);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: surface.withOpacity(0.96),
              elevation: 0.5,
              automaticallyImplyLeading: false,
              titleSpacing: 20,
              title: const Row(
                children: [
                  Icon(Icons.inventory_2_outlined, color: primary, size: 28),
                  SizedBox(width: 8),
                  Text(
                    'Flexi Nodes',
                    style: TextStyle(
                      color: primary,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 32, 22, 36),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _aiBadge(),
                    const SizedBox(height: 22),
                    const Text(
                      'Delivery that adapts to traffic',
                      style: TextStyle(
                        color: textMain,
                        fontSize: 30,
                        height: 1.25,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.6,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Experience the future of urban delivery. Flexi Nodes dynamically reroutes your package in real-time, ensuring lightning-fast arrivals while maximizing cashback rewards.',
                      style: TextStyle(
                        color: textMuted,
                        fontSize: 16,
                        height: 1.55,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 32),
                    _primaryButton(
                      label: 'Sign In',
                      icon: Icons.login,
                      onTap: () => Navigator.pushNamed(context, '/sign-in'),
                    ),
                    const SizedBox(height: 10),
                    _outlineButton(
                      label: 'Register',
                      onTap: () => Navigator.pushNamed(context, '/register'),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: TextButton.icon(
                        onPressed: () => Navigator.pushNamed(context, '/choose-role'),
                        iconAlignment: IconAlignment.end,
                        icon: const Icon(Icons.arrow_forward, size: 18),
                        label: const Text('Continue as Demo'),
                        style: TextButton.styleFrom(
                          foregroundColor: textMuted,
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const _HeroDeliveryCard(),
                    const SizedBox(height: 36),
                    const _ValueCard(
                      icon: Icons.update,
                      iconBg: Color(0xFFE8F0E4),
                      iconColor: primary,
                      title: 'Fast Updates',
                      description:
                          'Real-time tracking with millisecond precision across our entire node network.',
                    ),
                    const SizedBox(height: 18),
                    const _ValueCard(
                      icon: Icons.auto_awesome,
                      iconBg: blueSoft,
                      iconColor: blue,
                      title: 'AI Optimization',
                      description:
                          'Smart routing algorithms adapt instantly to traffic conditions and weather.',
                    ),
                    const SizedBox(height: 18),
                    const _ValueCard(
                      icon: Icons.payments_outlined,
                      iconBg: Color(0xFFFFF4E1),
                      iconColor: orange,
                      title: 'Earn as you send',
                      description:
                          'Get instant cashback vouchers for utilizing nearby drop-off nodes.',
                      chipLabel: 'Cashback',
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

  Widget _aiBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: blueSoft,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFB9E2FF)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.smart_toy_outlined, size: 16, color: blue),
          SizedBox(width: 8),
          Text(
            'AI-Powered Logistics',
            style: TextStyle(
              color: blue,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _primaryButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 20),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryContainer,
          foregroundColor: const Color(0xFF004B1E),
          elevation: 5,
          shadowColor: primaryContainer.withOpacity(0.25),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _outlineButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primaryContainer, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        child: Text(label),
      ),
    );
  }
}

class _HeroDeliveryCard extends StatelessWidget {
  const _HeroDeliveryCard();

  static const Color primary = LandingPage.primary;
  static const Color primaryContainer = LandingPage.primaryContainer;
  static const Color surface = LandingPage.surface;
  static const Color textMain = LandingPage.textMain;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 360,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFFB9DDD0), Color(0xFF8FBFAC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.12),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _MapIllustrationPainter(),
            ),
          ),
          const Positioned(
            top: 62,
            left: 70,
            child: _FloatingCube(size: 48, opacity: 0.72),
          ),
          const Positioned(
            top: 112,
            right: 102,
            child: _MapPin(),
          ),
          const Positioned(
            top: 164,
            left: 132,
            child: _PackageBox(),
          ),
          Positioned(
            left: 18,
            right: 18,
            bottom: 18,
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: surface.withOpacity(0.96),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: primaryContainer,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: [
                        BoxShadow(
                          color: primaryContainer.withOpacity(0.35),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.local_shipping_outlined,
                      color: Color(0xFF004B1E),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Package Rerouted',
                          style: TextStyle(
                            color: textMain,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 3),
                        Row(
                          children: [
                            Icon(Icons.bolt, size: 14, color: primary),
                            SizedBox(width: 4),
                            Text(
                              'Saved 14 mins',
                              style: TextStyle(
                                color: primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ValueCard extends StatelessWidget {
  const _ValueCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.description,
    this.chipLabel,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String description;
  final String? chipLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      decoration: BoxDecoration(
        color: LandingPage.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: LandingPage.surfaceVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (chipLabel != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 14, color: iconColor),
                  const SizedBox(width: 4),
                  Text(
                    chipLabel!,
                    style: TextStyle(
                      color: iconColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
          const SizedBox(height: 22),
          Text(
            title,
            style: const TextStyle(
              color: LandingPage.textMain,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              color: LandingPage.textMuted,
              fontSize: 15,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingCube extends StatelessWidget {
  const _FloatingCube({required this.size, this.opacity = 1});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Transform.rotate(
        angle: -0.35,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFEAC17B), Color(0xFFC79245)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.16),
                blurRadius: 18,
                offset: const Offset(0, 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapPin extends StatelessWidget {
  const _MapPin();

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.28,
      child: Container(
        width: 36,
        height: 52,
        decoration: BoxDecoration(
          color: const Color(0xFFD58E3B),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.16),
              blurRadius: 12,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Container(
            width: 15,
            height: 15,
            decoration: const BoxDecoration(
              color: Color(0xFF8FBFAC),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

class _PackageBox extends StatelessWidget {
  const _PackageBox();

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 0.02,
      child: Container(
        width: 108,
        height: 94,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFD8A55E), Color(0xFFBF8840)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.22),
              blurRadius: 22,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 48,
              bottom: 0,
              child: Container(width: 10, color: Colors.black.withOpacity(0.08)),
            ),
            const Positioned(
              bottom: 18,
              right: 14,
              child: Icon(Icons.qr_code_2, size: 22, color: Color(0xFF5B431F)),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final mapPaint = Paint()
      ..color = Colors.white.withOpacity(0.82)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round;

    final routePaint = Paint()
      ..color = const Color(0xFF22C55E).withOpacity(0.72)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    final base = Path()
      ..moveTo(size.width * 0.16, size.height * 0.52)
      ..lineTo(size.width * 0.45, size.height * 0.42)
      ..lineTo(size.width * 0.80, size.height * 0.51)
      ..lineTo(size.width * 0.61, size.height * 0.66)
      ..lineTo(size.width * 0.23, size.height * 0.65)
      ..close();

    canvas.drawPath(base, mapPaint);

    final road1 = Path()
      ..moveTo(size.width * 0.18, size.height * 0.56)
      ..lineTo(size.width * 0.42, size.height * 0.56)
      ..lineTo(size.width * 0.62, size.height * 0.45)
      ..lineTo(size.width * 0.76, size.height * 0.50);
    canvas.drawPath(road1, mapPaint);

    final road2 = Path()
      ..moveTo(size.width * 0.28, size.height * 0.65)
      ..lineTo(size.width * 0.36, size.height * 0.51)
      ..lineTo(size.width * 0.58, size.height * 0.61);
    canvas.drawPath(road2, mapPaint);

    final route = Path()
      ..moveTo(size.width * 0.24, size.height * 0.62)
      ..cubicTo(
        size.width * 0.36,
        size.height * 0.58,
        size.width * 0.39,
        size.height * 0.49,
        size.width * 0.49,
        size.height * 0.51,
      )
      ..cubicTo(
        size.width * 0.57,
        size.height * 0.53,
        size.width * 0.61,
        size.height * 0.47,
        size.width * 0.68,
        size.height * 0.48,
      );
    canvas.drawPath(route, routePaint);

    final dotPaint = Paint()
      ..color = const Color(0xFF22C55E).withOpacity(0.25)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width * 0.38, size.height * 0.38), 13, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.72, size.height * 0.62), 15, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
