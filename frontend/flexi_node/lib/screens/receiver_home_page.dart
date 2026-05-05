import 'package:flutter/material.dart';

class ReceiverHomePage extends StatelessWidget {
  const ReceiverHomePage({super.key});

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      bottomNavigationBar: const _FlexiBottomNav(selectedIndex: 0),
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
                  const _Avatar(),
                  const SizedBox(width: 18),
                  const Expanded(
                    child: Text(
                      'Hi, Andika',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: textMain,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/notifications'),
                    icon: const Icon(
                      Icons.notifications_none_outlined,
                      color: textMuted,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 26, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SearchBox(onQrTap: () {}),
                    const SizedBox(height: 34),
                    Row(
                      children: [
                        Expanded(
                          child: _QuickActionCard(
                            icon: Icons.local_shipping_outlined,
                            iconColor: primaryContainer,
                            iconBg: Color(0xFFE8F7ED),
                            label: 'Track\nPackage',
                            onTap: () =>
                                Navigator.pushNamed(context, '/tracking'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickActionCard(
                            icon: Icons.add_business_outlined,
                            iconColor: blue,
                            iconBg: Color(0xFFE7F6FF),
                            label: 'Flexi\nPickup',
                            onTap: () =>
                                Navigator.pushNamed(context, '/nearby-nodes'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickActionCard(
                            icon: Icons.sell_outlined,
                            iconColor: orange,
                            iconBg: Color(0xFFFFF4E1),
                            label: 'Vouchers',
                            onTap: () =>
                                Navigator.pushNamed(context, '/vouchers'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickActionCard(
                            icon: Icons.support_agent_outlined,
                            iconColor: textMuted,
                            iconBg: surfaceContainer,
                            label: 'Help',
                            onTap: () {},
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 34),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Active Delivery',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: textMain,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/orders'),
                          child: const Text(
                            'See all',
                            style: TextStyle(
                              color: primaryContainer,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const _ActiveDeliveryCard(),
                    const SizedBox(height: 32),
                    const _PromoCard(),
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

class _Avatar extends StatelessWidget {
  const _Avatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: ReceiverHomePage.surfaceContainerHigh,
          width: 2,
        ),
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

class _SearchBox extends StatelessWidget {
  const _SearchBox({required this.onQrTap});

  final VoidCallback onQrTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 86,
      padding: const EdgeInsets.only(left: 26, right: 14),
      decoration: BoxDecoration(
        color: ReceiverHomePage.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: ReceiverHomePage.textMuted, size: 32),
          const SizedBox(width: 18),
          const Expanded(
            child: Text(
              'Track order or package ID',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: ReceiverHomePage.textMuted,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Material(
            color: ReceiverHomePage.primary,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: onQrTap,
              borderRadius: BorderRadius.circular(12),
              child: const SizedBox(
                width: 56,
                height: 56,
                child: Icon(
                  Icons.qr_code_scanner,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
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
      color: ReceiverHomePage.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          height: 116,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.025),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 30),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: ReceiverHomePage.textMain,
                  fontSize: 15,
                  height: 1.16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActiveDeliveryCard extends StatelessWidget {
  const _ActiveDeliveryCard();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ReceiverHomePage.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, '/tracking'),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: ReceiverHomePage.surfaceContainerHigh.withOpacity(0.6),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5F4FF),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFB7E3FF)),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.directions_bike,
                          size: 18,
                          color: ReceiverHomePage.blueDark,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'COURIER ON THE WAY',
                          style: TextStyle(
                            color: ReceiverHomePage.blueDark,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'SD1440-Y',
                    style: TextStyle(
                      color: ReceiverHomePage.textMain,
                      fontSize: 23,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7E8),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFFDDA8)),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.warning_amber_outlined,
                      color: ReceiverHomePage.orange,
                      size: 28,
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Traffic Delay\n',
                              style: TextStyle(
                                fontSize: 21,
                                color: Color(0xFF5C3800),
                                fontWeight: FontWeight.w600,
                                height: 1.25,
                              ),
                            ),
                            TextSpan(
                              text: 'Estimated arrival delayed by ~20 mins.',
                              style: TextStyle(
                                fontSize: 20,
                                color: Color(0xFF5C3800),
                                height: 1.55,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 34),
              const _DeliveryProgress(),
              const SizedBox(height: 32),
              Row(
                children: [
                  const Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Est. Arrival\n',
                            style: TextStyle(
                              color: ReceiverHomePage.textMuted,
                              fontSize: 21,
                              height: 1.2,
                            ),
                          ),
                          TextSpan(
                            text: '14:45',
                            style: TextStyle(
                              color: ReceiverHomePage.textMain,
                              fontSize: 21,
                              height: 1.3,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 58,
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/tracking'),
                      icon: const Icon(Icons.my_location, size: 24),
                      label: const Text('Track on Map'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ReceiverHomePage.primaryContainer,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeliveryProgress extends StatelessWidget {
  const _DeliveryProgress();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 20,
            right: 20,
            top: 16,
            child: Container(
              height: 5,
              color: ReceiverHomePage.surfaceContainerHigh,
            ),
          ),
          Positioned(
            left: 20,
            right: 160,
            top: 16,
            child: Container(
              height: 5,
              color: ReceiverHomePage.primaryContainer,
            ),
          ),
          const Positioned(
            left: 0,
            child: _ProgressDot(
              icon: Icons.storefront,
              color: ReceiverHomePage.primaryContainer,
            ),
          ),
          const Positioned(
            left: 0,
            right: 0,
            child: Center(
              child: _ProgressDot(
                icon: Icons.local_shipping_outlined,
                color: ReceiverHomePage.blue,
              ),
            ),
          ),
          const Positioned(
            right: 0,
            child: _ProgressDot(
              icon: Icons.home_outlined,
              color: ReceiverHomePage.surfaceContainer,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressDot extends StatelessWidget {
  const _ProgressDot({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final bool lightIcon = color != ReceiverHomePage.surfaceContainer;
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: ReceiverHomePage.surface, width: 3),
      ),
      child: Icon(
        icon,
        size: 18,
        color: lightIcon ? Colors.white : ReceiverHomePage.textMuted,
      ),
    );
  }
}

class _PromoCard extends StatelessWidget {
  const _PromoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 240,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF18B850), Color(0xFF00732F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: ReceiverHomePage.primary.withOpacity(0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -12,
            bottom: -4,
            child: Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 5,
                ),
              ),
              child: Icon(
                Icons.card_giftcard,
                color: Colors.white.withOpacity(0.95),
                size: 64,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(color: Colors.white.withOpacity(0.14)),
                ),
                child: const Text(
                  'PROMO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'Get 15% Cashback\non Flexi Pickup',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  height: 1.25,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(text: 'Use code: '),
                    TextSpan(
                      text: 'FLEXINOW',
                      style: TextStyle(
                        backgroundColor: Colors.black.withOpacity(0.22),
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  height: 1.3,
                ),
              ),
              const Spacer(),
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/vouchers'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: ReceiverHomePage.primary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Text('Claim Now'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FlexiBottomNav extends StatelessWidget {
  const _FlexiBottomNav({required this.selectedIndex});

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
        color: ReceiverHomePage.surface,
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
                final routes = [
                  '/receiver-home',
                  '/orders',
                  '/tracking',
                  '/vouchers',
                  '/profile',
                ];
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
                      color: active
                          ? const Color(0xFFE8F7ED)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Icon(
                      item.$1,
                      color: active
                          ? ReceiverHomePage.primaryContainer
                          : const Color(0xFF9AA7B8),
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.$2,
                    style: TextStyle(
                      color: active
                          ? ReceiverHomePage.primary
                          : const Color(0xFF8FA0B2),
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
