import 'package:flutter/material.dart';
import 'flexi_ui.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  bool isDriver = false;
  bool hidePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlexiColors.bg,
      appBar: const FlexiAppBar(title: 'Sign In'),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
          children: [
            const Text(
              'Welcome Back',
              style: TextStyle(
                color: FlexiColors.text,
                fontSize: 30,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Sign in to continue your adaptive delivery experience.',
              style: TextStyle(color: FlexiColors.muted, fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 22),
            FlexiCard(
              child: Column(
                children: [
                  _RoleTabs(
                    isDriver: isDriver,
                    onChanged: (value) => setState(() => isDriver = value),
                  ),
                  const SizedBox(height: 18),
                  const _InputField(
                    label: 'Email or phone number',
                    icon: Icons.alternate_email,
                    hint: 'receiver@test.com',
                  ),
                  const SizedBox(height: 14),
                  _InputField(
                    label: 'Password',
                    icon: Icons.lock_outline,
                    hint: '••••••••',
                    obscureText: hidePassword,
                    suffix: IconButton(
                      icon: Icon(
                        hidePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        size: 20,
                      ),
                      onPressed: () => setState(() => hidePassword = !hidePassword),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: FlexiColors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FlexiPrimaryButton(
                    label: 'Sign In',
                    icon: Icons.login,
                    onPressed: () => Navigator.pushReplacementNamed(
                      context,
                      isDriver ? '/driver-home' : '/receiver-home',
                    ),
                  ),
                  const SizedBox(height: 12),
                  FlexiOutlineButton(
                    label: 'Continue with Google',
                    icon: Icons.g_mobiledata,
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pushNamed(context, '/register'),
                child: const Text(
                  "Don't have an account? Register",
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

class _RoleTabs extends StatelessWidget {
  const _RoleTabs({
    required this.isDriver,
    required this.onChanged,
  });

  final bool isDriver;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: FlexiColors.bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          _TabButton(
            label: 'Receiver',
            selected: !isDriver,
            onTap: () => onChanged(false),
          ),
          _TabButton(
            label: 'Driver',
            selected: isDriver,
            onTap: () => onChanged(true),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: selected ? FlexiColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : FlexiColors.muted,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
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
    this.suffix,
  });

  final String label;
  final IconData icon;
  final String hint;
  final bool obscureText;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        suffixIcon: suffix,
        filled: true,
        fillColor: FlexiColors.bg,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: FlexiColors.primary, width: 1.4),
        ),
      ),
    );
  }
}
