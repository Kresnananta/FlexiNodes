import 'package:flutter/material.dart';

class FlexiColors {
  static const bg = Color(0xFFF3FCEF);
  static const surface = Colors.white;
  static const primary = Color(0xFF006E2F);
  static const green = Color(0xFF22C55E);
  static const text = Color(0xFF161D16);
  static const muted = Color(0xFF3D4A3D);
  static const border = Color(0xFFDCE5D9);
  static const lightGreen = Color(0xFFE8F7ED);
  static const blue = Color(0xFF006591);
  static const blueSoft = Color(0xFFE5F4FF);
  static const orange = Color(0xFFEF9900);
  static const orangeSoft = Color(0xFFFFF4E1);
  static const red = Color(0xFFBA1A1A);
  static const redSoft = Color(0xFFFFECEA);
}

class FlexiAppBar extends StatelessWidget implements PreferredSizeWidget {
  const FlexiAppBar({
    super.key,
    required this.title,
    this.showBack = true,
    this.actions,
  });

  final String title;
  final bool showBack;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(58);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: FlexiColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0.5,
      centerTitle: true,
      leading: showBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: FlexiColors.text),
              onPressed: () => Navigator.maybePop(context),
            )
          : null,
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: FlexiColors.text,
          fontSize: 18,
          fontWeight: FontWeight.w900,
        ),
      ),
      actions: actions,
    );
  }
}

class FlexiCard extends StatelessWidget {
  const FlexiCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color = FlexiColors.surface,
    this.onTap,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: FlexiColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );

    if (onTap == null) return card;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: card,
      ),
    );
  }
}

class FlexiPrimaryButton extends StatelessWidget {
  const FlexiPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.backgroundColor = FlexiColors.primary,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final style = ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
      padding: const EdgeInsets.symmetric(horizontal: 14),
    );

    if (icon == null) {
      return SizedBox(
        height: 46,
        width: double.infinity,
        child: ElevatedButton(onPressed: onPressed, style: style, child: Text(label)),
      );
    }

    return SizedBox(
      height: 46,
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: style,
        icon: Icon(icon, size: 18),
        label: Text(label),
      ),
    );
  }
}

class FlexiOutlineButton extends StatelessWidget {
  const FlexiOutlineButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final style = OutlinedButton.styleFrom(
      foregroundColor: FlexiColors.text,
      side: BorderSide(color: FlexiColors.muted.withOpacity(0.30)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
      padding: const EdgeInsets.symmetric(horizontal: 14),
    );

    if (icon == null) {
      return SizedBox(
        height: 46,
        width: double.infinity,
        child: OutlinedButton(onPressed: onPressed, style: style, child: Text(label)),
      );
    }

    return SizedBox(
      height: 46,
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: style,
        icon: Icon(icon, size: 18),
        label: Text(label),
      ),
    );
  }
}

class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.label,
    this.icon,
    this.color = FlexiColors.green,
    this.background = FlexiColors.lightGreen,
  });

  final String label;
  final IconData? icon;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class MiniMap extends StatelessWidget {
  const MiniMap({
    super.key,
    this.height = 180,
    this.showNode = true,
    this.showCustomer = true,
    this.routeToNode = false,
  });

  final double height;
  final bool showNode;
  final bool showCustomer;
  final bool routeToNode;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: CustomPaint(
          painter: _MiniMapPainter(
            showNode: showNode,
            showCustomer: showCustomer,
            routeToNode: routeToNode,
          ),
          child: Stack(
            children: [
              Positioned(
                top: 18,
                left: 18,
                child: _MapChip(
                  icon: Icons.local_shipping_outlined,
                  text: 'Driver',
                  color: FlexiColors.blue,
                ),
              ),
              if (showNode)
                Positioned(
                  right: 20,
                  top: 80,
                  child: _MapPin(
                    icon: Icons.storefront,
                    color: FlexiColors.green,
                  ),
                ),
              if (showCustomer)
                Positioned(
                  right: 54,
                  bottom: 26,
                  child: _MapPin(
                    icon: Icons.home_outlined,
                    color: FlexiColors.orange,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapChip extends StatelessWidget {
  const _MapChip({
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _MapPin extends StatelessWidget {
  const _MapPin({
    required this.icon,
    required this.color,
  });

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 17,
      backgroundColor: Colors.white,
      child: CircleAvatar(
        radius: 14,
        backgroundColor: color,
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }
}

class _MiniMapPainter extends CustomPainter {
  const _MiniMapPainter({
    required this.showNode,
    required this.showCustomer,
    required this.routeToNode,
  });

  final bool showNode;
  final bool showCustomer;
  final bool routeToNode;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF22303A));

    final road = Paint()
      ..color = Colors.white.withOpacity(0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.7;

    for (double x = -20; x < size.width; x += 48) {
      canvas.drawLine(Offset(x, 0), Offset(x + 42, size.height), road);
    }
    for (double y = 10; y < size.height; y += 36) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y + 32), road);
    }

    final route = Path()
      ..moveTo(size.width * 0.22, 28)
      ..cubicTo(size.width * 0.40, 40, size.width * 0.35, 86, size.width * 0.55, 94)
      ..cubicTo(
        size.width * 0.70,
        104,
        routeToNode ? size.width * 0.72 : size.width * 0.82,
        routeToNode ? 96 : size.height * 0.78,
        routeToNode ? size.width * 0.80 : size.width * 0.78,
        routeToNode ? 100 : size.height - 34,
      );

    canvas.drawPath(
      route,
      Paint()
        ..color = const Color(0xFF52FF3E)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawCircle(Offset(size.width * 0.22, 28), 10, Paint()..color = FlexiColors.blue);
    canvas.drawCircle(Offset(size.width * 0.22, 28), 4, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class TimelineStep extends StatelessWidget {
  const TimelineStep({
    super.key,
    required this.title,
    required this.subtitle,
    required this.active,
    this.last = false,
  });

  final String title;
  final String subtitle;
  final bool active;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            CircleAvatar(
              radius: 11,
              backgroundColor: active ? FlexiColors.green : FlexiColors.border,
              child: active ? const Icon(Icons.check, color: Colors.white, size: 13) : null,
            ),
            if (!last) Container(width: 2, height: 34, color: FlexiColors.border),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: last ? 0 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(color: FlexiColors.muted, fontSize: 12, height: 1.3),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class CompactBottomNav extends StatelessWidget {
  const CompactBottomNav({
    super.key,
    required this.currentIndex,
    required this.routes,
  });

  final int currentIndex;
  final List<String> routes;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: FlexiColors.primary,
      unselectedItemColor: const Color(0xFF8FA0B2),
      selectedFontSize: 11,
      unselectedFontSize: 10,
      iconSize: 22,
      onTap: (index) {
        if (index != currentIndex && index < routes.length) {
          Navigator.pushNamed(context, routes[index]);
        }
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
