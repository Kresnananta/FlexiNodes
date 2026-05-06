import 'package:flutter/material.dart';

class ReceiverHomePage extends StatelessWidget {
  const ReceiverHomePage({super.key});

  static const bg = Color(0xFFF3FCEF);
  static const surface = Colors.white;
  static const primary = Color(0xFF006E2F);
  static const green = Color(0xFF22C55E);
  static const text = Color(0xFF161D16);
  static const muted = Color(0xFF3D4A3D);
  static const border = Color(0xFFDCE5D9);
  static const lightGreen = Color(0xFFE8F7ED);
  static const blue = Color(0xFF006591);
  static const orange = Color(0xFFEF9900);

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
              titleSpacing: 16,
              toolbarHeight: 62,
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
                      'Hi, Andika',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: text,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pushNamed(context, '/notifications'),
                    icon: const Icon(Icons.notifications_none, color: muted),
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
                    const _SearchCard(),
                    const SizedBox(height: 20),
                    const _QuickActions(),
                    const SizedBox(height: 24),
                    _SectionHeader(
                      title: 'Active Delivery',
                      action: 'See all',
                      onTap: () => Navigator.pushNamed(context, '/orders'),
                    ),
                    const SizedBox(height: 12),
                    const _ActiveDeliveryCard(),
                    const SizedBox(height: 22),
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

class _SearchCard extends StatelessWidget {
  const _SearchCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      padding: const EdgeInsets.only(left: 16, right: 8),
      decoration: BoxDecoration(
        color: ReceiverHomePage.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: ReceiverHomePage.muted, size: 22),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Track order or package ID',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: ReceiverHomePage.muted, fontSize: 14),
            ),
          ),
          Material(
            color: ReceiverHomePage.primary,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(12),
              child: const SizedBox(
                width: 42,
                height: 42,
                child: Icon(Icons.qr_code_scanner, color: Colors.white, size: 22),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    final items = [
      _ActionItem(Icons.local_shipping_outlined, 'Track\nPackage', ReceiverHomePage.green, const Color(0xFFE8F7ED), '/tracking'),
      _ActionItem(Icons.add_business_outlined, 'Flexi\nPickup', ReceiverHomePage.blue, const Color(0xFFE5F4FF), '/nearby-nodes'),
      _ActionItem(Icons.sell_outlined, 'Vouchers', ReceiverHomePage.orange, const Color(0xFFFFF4E1), '/vouchers'),
      _ActionItem(Icons.support_agent_outlined, 'Help', ReceiverHomePage.muted, const Color(0xFFE8F0E4), null),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        mainAxisExtent: 88,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return Material(
          color: ReceiverHomePage.surface,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: () {
              if (item.route != null) Navigator.pushNamed(context, item.route!);
            },
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: item.bgColor,
                    child: Icon(item.icon, color: item.iconColor, size: 21),
                  ),
                  const SizedBox(height: 7),
                  Flexible(
                    child: Text(
                      item.label,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: ReceiverHomePage.text,
                        fontSize: 11,
                        height: 1.1,
                        fontWeight: FontWeight.w700,
                      ),
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

class _ActionItem {
  const _ActionItem(this.icon, this.label, this.iconColor, this.bgColor, this.route);

  final IconData icon;
  final String label;
  final Color iconColor;
  final Color bgColor;
  final String? route;
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
              color: ReceiverHomePage.text,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        TextButton(
          onPressed: onTap,
          child: Text(
            action,
            style: const TextStyle(
              color: ReceiverHomePage.green,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
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
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: ReceiverHomePage.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _Chip(
                    icon: Icons.directions_bike,
                    label: 'COURIER ON THE WAY',
                    color: ReceiverHomePage.blue,
                    background: Color(0xFFE5F4FF),
                  ),
                  const Text(
                    'SD1440-Y',
                    style: TextStyle(
                      color: ReceiverHomePage.text,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7E8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFFDDA8)),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.warning_amber_outlined, color: ReceiverHomePage.orange, size: 22),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Traffic Delay\n',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                            ),
                            TextSpan(
                              text: 'Estimated arrival delayed by ~20 mins.',
                              style: TextStyle(fontSize: 13, height: 1.35),
                            ),
                          ],
                        ),
                        style: TextStyle(color: Color(0xFF5C3800)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const _ProgressLine(),
              const SizedBox(height: 18),
              Row(
                children: [
                  const Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Est. Arrival\n',
                            style: TextStyle(
                              color: ReceiverHomePage.muted,
                              fontSize: 12,
                              height: 1.2,
                            ),
                          ),
                          TextSpan(
                            text: '14:45',
                            style: TextStyle(
                              color: ReceiverHomePage.text,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 42,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, '/tracking'),
                      icon: const Icon(Icons.my_location, size: 18),
                      label: const Text('Track'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ReceiverHomePage.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
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

class _Chip extends StatelessWidget {
  const _Chip({
    required this.icon,
    required this.label,
    required this.color,
    required this.background,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressLine extends StatelessWidget {
  const _ProgressLine();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(left: 20, right: 20, child: Container(height: 4, color: ReceiverHomePage.border)),
          Positioned(left: 20, right: 140, child: Container(height: 4, color: ReceiverHomePage.green)),
          const Align(
            alignment: Alignment.centerLeft,
            child: _StepDot(icon: Icons.storefront, color: ReceiverHomePage.green),
          ),
          const Align(
            alignment: Alignment.center,
            child: _StepDot(icon: Icons.local_shipping_outlined, color: ReceiverHomePage.blue),
          ),
          const Align(
            alignment: Alignment.centerRight,
            child: _StepDot(icon: Icons.home_outlined, color: ReceiverHomePage.border, darkIcon: true),
          ),
        ],
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({
    required this.icon,
    required this.color,
    this.darkIcon = false,
  });

  final IconData icon;
  final Color color;
  final bool darkIcon;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 14,
      backgroundColor: color,
      child: Icon(icon, size: 15, color: darkIcon ? ReceiverHomePage.muted : Colors.white),
    );
  }
}

class _PromoCard extends StatelessWidget {
  const _PromoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 168),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF18B850), Color(0xFF00732F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -12,
            bottom: -12,
            child: Icon(Icons.card_giftcard, size: 96, color: Colors.white.withOpacity(0.18)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _WhiteBadge(text: 'PROMO'),
              const SizedBox(height: 14),
              const Text(
                'Get 15% Cashback\non Flexi Pickup',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  height: 1.2,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Use code: FLEXINOW',
                style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 40,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/vouchers'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: ReceiverHomePage.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
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

class _WhiteBadge extends StatelessWidget {
  const _WhiteBadge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav();

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: ReceiverHomePage.primary,
      unselectedItemColor: const Color(0xFF8FA0B2),
      selectedFontSize: 11,
      unselectedFontSize: 10,
      iconSize: 22,
      onTap: (index) {
        final routes = ['/receiver-home', '/orders', '/tracking', '/vouchers', '/profile'];
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
