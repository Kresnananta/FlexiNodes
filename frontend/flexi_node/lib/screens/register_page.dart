import 'package:flutter/material.dart';
import 'flexi_ui.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool isDriver = false;
  bool agreed = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlexiColors.bg,
      appBar: const FlexiAppBar(title: 'Register'),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
          children: [
            const Text(
              'Create Account',
              style: TextStyle(
                color: FlexiColors.text,
                fontSize: 30,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Choose your role and create an account for the demo.',
              style: TextStyle(color: FlexiColors.muted, fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 22),
            FlexiCard(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _RoleChoice(
                          label: 'Receiver',
                          icon: Icons.inventory_2_outlined,
                          selected: !isDriver,
                          onTap: () => setState(() => isDriver = false),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _RoleChoice(
                          label: 'Driver',
                          icon: Icons.local_shipping_outlined,
                          selected: isDriver,
                          onTap: () => setState(() => isDriver = true),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const _InputField(label: 'Full name', icon: Icons.person_outline, hint: 'Andika Sujanto'),
                  const SizedBox(height: 12),
                  const _InputField(label: 'Email', icon: Icons.alternate_email, hint: 'andikasu@gmail.com'),
                  const SizedBox(height: 12),
                  const _InputField(label: 'Phone number', icon: Icons.phone_outlined, hint: '+62 812 0000 0000'),
                  const SizedBox(height: 12),
                  const _InputField(label: 'Password', icon: Icons.lock_outline, hint: '••••••••', obscureText: true),
                  const SizedBox(height: 12),
                  const _InputField(label: 'Confirm password', icon: Icons.lock_outline, hint: '••••••••', obscureText: true),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    value: agreed,
                    contentPadding: EdgeInsets.zero,
                    activeColor: FlexiColors.primary,
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (value) => setState(() => agreed = value ?? false),
                    title: const Text(
                      'I agree to the Terms & Privacy Policy',
                      style: TextStyle(fontSize: 12.5, color: FlexiColors.muted),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FlexiPrimaryButton(
                    label: 'Create Account',
                    icon: Icons.person_add_alt_1,
                    onPressed: () => Navigator.pushReplacementNamed(
                      context,
                      isDriver ? '/driver-home' : '/receiver-home',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pushNamed(context, '/sign-in'),
                child: const Text(
                  'Already have an account? Sign In',
                  style: TextStyle(
                    color: FlexiColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleChoice extends StatelessWidget {
  const _RoleChoice({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? FlexiColors.lightGreen : FlexiColors.bg,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 82,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: selected ? FlexiColors.primary : FlexiColors.border, width: 1.4),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: selected ? FlexiColors.primary : FlexiColors.muted, size: 24),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: selected ? FlexiColors.primary : FlexiColors.muted,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.label,
    required this.icon,
    required this.hint,
    this.obscureText = false,
  });

  final String label;
  final IconData icon;
  final String hint;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: FlexiColors.bg,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: FlexiColors.primary, width: 1.4),
        ),
      ),
    );
  }
}
