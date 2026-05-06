import 'package:flutter/material.dart';

enum FlexiRole { receiver, driver, partner }

class ChooseRolePage extends StatefulWidget {
  const ChooseRolePage({super.key});

  @override
  State<ChooseRolePage> createState() => _ChooseRolePageState();
}

class _ChooseRolePageState extends State<ChooseRolePage> {
  FlexiRole selectedRole = FlexiRole.receiver;

  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceLow = Color(0xFFF3FCEF);
  static const Color surfaceContainer = Color(0xFFE8F0E4);
  static const Color surfaceContainerHigh = Color(0xFFDCE5D9);
  static const Color primary = Color(0xFF006E2F);
  static const Color primaryContainer = Color(0xFF22C55E);
  static const Color textMain = Color(0xFF161D16);
  static const Color textMuted = Color(0xFF3D4A3D);
  // static const Color outline = Color(0xFFBCCBB9);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: surface,
        elevation: 0.6,
        shadowColor: Colors.black.withOpacity(0.12),
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textMain, size: 30),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'Flexi Nodes',
          style: TextStyle(
            color: primary,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 34, 20, 24),
                children: [
                  const Text(
                    'Choose Your Role',
                    style: TextStyle(
                      color: textMain,
                      fontSize: 34,
                      height: 1.1,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.9,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Select how you want to use Flexi Nodes today to customize your experience.',
                    style: TextStyle(
                      color: textMuted,
                      fontSize: 14,
                      height: 1.55,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _RoleCard(
                    isSelected: selectedRole == FlexiRole.receiver,
                    icon: Icons.inventory_2_outlined,
                    title: 'Receiver /\nCustomer',
                    description:
                        'Track incoming packages, manage delivery addresses, and coordinate drop-offs seamlessly.',
                    onTap: () => setState(() => selectedRole = FlexiRole.receiver),
                  ),
                  const SizedBox(height: 18),
                  _RoleCard(
                    isSelected: selectedRole == FlexiRole.driver,
                    icon: Icons.local_shipping_outlined,
                    title: 'Driver / Courier',
                    description:
                        'Access optimized routes, manage multiple deliveries, and scan packages at node locations.',
                    onTap: () => setState(() => selectedRole = FlexiRole.driver),
                  ),
                  const SizedBox(height: 24),
                  const Row(
                    children: [
                      Expanded(child: Divider(color: surfaceContainerHigh)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'OR',
                          style: TextStyle(
                            color: Color(0xFF8B9488),
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: surfaceContainerHigh)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _PartnerCard(
                    isSelected: selectedRole == FlexiRole.partner,
                    onTap: () => setState(() => selectedRole = FlexiRole.partner),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
              decoration: BoxDecoration(
                color: surface.withOpacity(0.96),
                border: const Border(top: BorderSide(color: surfaceContainer, width: 1)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 18,
                    offset: const Offset(0, -8),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton.icon(
                  onPressed: _continueToSelectedRole,
                  icon: const Icon(Icons.arrow_forward, size: 22),
                  label: const Text('Continue'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: primary.withOpacity(0.24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _continueToSelectedRole() {
    switch (selectedRole) {
      case FlexiRole.receiver:
        Navigator.pushNamed(context, '/receiver-home');
        break;
      case FlexiRole.driver:
        Navigator.pushNamed(context, '/driver-home');
        break;
      case FlexiRole.partner:
        Navigator.pushNamed(context, '/partner-dashboard');
        break;
    }
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.isSelected,
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final bool isSelected;
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  static const Color surface = _ChooseRolePageState.surface;
  static const Color surfaceLow = _ChooseRolePageState.surfaceLow;
  static const Color surfaceContainerHigh = _ChooseRolePageState.surfaceContainerHigh;
  static const Color primary = _ChooseRolePageState.primary;
  static const Color primaryContainer = _ChooseRolePageState.primaryContainer;
  static const Color textMain = _ChooseRolePageState.textMain;
  static const Color textMuted = _ChooseRolePageState.textMuted;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? surfaceLow : surface,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isSelected ? primary : surfaceContainerHigh,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isSelected ? 0.06 : 0.035),
                blurRadius: 12,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: isSelected ? primaryContainer : surfaceContainerHigh.withOpacity(0.65),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isSelected ? Colors.white : textMuted,
                  size: 32,
                ),
              ),
              const SizedBox(width: 22),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: textMain,
                        fontSize: 20,
                        height: 1.35,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      description,
                      style: const TextStyle(
                        color: textMuted,
                        fontSize: 14,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                isSelected ? Icons.check_circle_outline : Icons.radio_button_unchecked,
                color: isSelected ? primary : Colors.transparent,
                size: 34,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PartnerCard extends StatelessWidget {
  const _PartnerCard({
    required this.isSelected,
    required this.onTap,
  });

  final bool isSelected;
  final VoidCallback onTap;

  static const Color surface = _ChooseRolePageState.surface;
  static const Color surfaceLow = _ChooseRolePageState.surfaceLow;
  static const Color surfaceContainerHigh = _ChooseRolePageState.surfaceContainerHigh;
  static const Color primary = _ChooseRolePageState.primary;
  static const Color textMain = _ChooseRolePageState.textMain;
  static const Color textMuted = _ChooseRolePageState.textMuted;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? surfaceLow : surface,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isSelected ? primary : surfaceContainerHigh,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.035),
                blurRadius: 10,
                offset: const Offset(0, 3),
              )
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: surfaceContainerHigh.withOpacity(0.65),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.storefront_outlined, color: textMuted, size: 30),
              ),
              const SizedBox(width: 18),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Partner Node',
                      style: TextStyle(
                        color: textMain,
                        fontSize: 24,
                        height: 1.1,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Manage a local staging area for neighborhood drop-offs.',
                      style: TextStyle(
                        color: textMuted,
                        fontSize: 16,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                isSelected ? Icons.check_circle_outline : Icons.chevron_right,
                color: isSelected ? primary : surfaceContainerHigh,
                size: 32,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
