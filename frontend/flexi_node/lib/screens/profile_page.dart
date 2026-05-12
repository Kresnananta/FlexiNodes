import 'package:flutter/material.dart';
import 'flexi_ui.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlexiColors.bg,
      appBar: const FlexiAppBar(title: 'Profile'),
      bottomNavigationBar: const CompactBottomNav(
        currentIndex: 4,
        routes: ['/receiver-home', '/orders', '/tracking', '/vouchers', '/profile'],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
          children: [
            FlexiCard(
              child: Row(
                children: const [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: FlexiColors.primary,
                    child: Icon(Icons.person, color: Colors.white, size: 34),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Andika Sujanto', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                        SizedBox(height: 4),
                        Text('Receiver / Customer', style: TextStyle(color: FlexiColors.muted, fontSize: 13)),
                        SizedBox(height: 7),
                        StatusPill(label: 'Demo Account'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            FlexiCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _MenuTile(icon: Icons.person_outline, title: 'Personal Information', onTap: () {}),
                  _MenuTile(icon: Icons.location_on_outlined, title: 'Saved Addresses / Vehicle Info', onTap: () {}),
                  _MenuTile(icon: Icons.notifications_none, title: 'Notifications', onTap: () => Navigator.pushNamed(context, '/notifications')),
                  _MenuTile(icon: Icons.lock_outline, title: 'Security', onTap: () {}),
                  _MenuTile(icon: Icons.help_outline, title: 'Help Center', onTap: () {}),
                  _MenuTile(icon: Icons.privacy_tip_outlined, title: 'Terms & Privacy', onTap: () {}),
                ],
              ),
            ),
            const SizedBox(height: 14),
            FlexiOutlineButton(
              label: 'Switch Role',
              icon: Icons.swap_horiz,
              onPressed: () => Navigator.pushNamed(context, '/choose-role'),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 46,
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showSignOutDialog(context),
                icon: const Icon(Icons.logout, size: 18),
                label: const Text('Sign Out'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: FlexiColors.red,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void _showSignOutDialog(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 26),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 32,
                backgroundColor: FlexiColors.redSoft,
                child: Icon(Icons.logout, color: FlexiColors.red, size: 34),
              ),
              const SizedBox(height: 14),
              const Text('Sign Out?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              const Text(
                'Are you sure you want to sign out from Flexi Nodes?',
                textAlign: TextAlign.center,
                style: TextStyle(color: FlexiColors.muted, fontSize: 13),
              ),
              const SizedBox(height: 18),
              FlexiPrimaryButton(
                label: 'Cancel',
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 10),
              FlexiOutlineButton(
                label: 'Sign Out',
                onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      minLeadingWidth: 24,
      leading: Icon(icon, color: FlexiColors.primary, size: 22),
      title: Text(title, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800)),
      trailing: const Icon(Icons.chevron_right, size: 20, color: FlexiColors.muted),
      onTap: onTap,
    );
  }
}
