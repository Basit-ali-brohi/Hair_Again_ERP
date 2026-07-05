import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../../../core/widgets.dart';
import '../../../core/router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() { _emailCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }

  Future<void> _login() async {
    if (_emailCtrl.text.trim().isEmpty || _passCtrl.text.isEmpty) {
      setState(() => _error = 'Please fill in all fields.');
      return;
    }
    setState(() { _loading = true; _error = null; });
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    markLoggedIn();
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 16),
            // Logo
            Row(children: [
              Container(width: 44, height: 44, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFD4AF5B), Color(0xFF9A7A35)]), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.spa_outlined, color: Colors.black87, size: 22)),
              const SizedBox(width: 12),
              Text('HAIR AGAIN', style: kDisplay(22, color: kGold, spacing: 1.5)),
            ]),
            const SizedBox(height: 40),
            Text('Welcome Back', style: kDisplay(32)),
            const SizedBox(height: 6),
            Text('Sign in to your account', style: kBody(15, color: kTextMuted)),
            const SizedBox(height: 32),

            // Error
            if (_error != null) ...[
              Container(
                padding: const EdgeInsets.all(14),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(color: kDanger.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: kDanger.withValues(alpha: 0.3))),
                child: Row(children: [
                  const Icon(Icons.error_outline, color: kDanger, size: 18),
                  const SizedBox(width: 10),
                  Expanded(child: Text(_error!, style: kBody(13, color: kDanger))),
                ]),
              ),
            ],

            // Email
            Text('Email / Phone', style: kLabel(12)),
            const SizedBox(height: 8),
            TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              style: kBody(15),
              decoration: InputDecoration(prefixIcon: const Icon(Icons.email_outlined, size: 20, color: kTextMuted), hintText: 'you@example.com'),
            ),
            const SizedBox(height: 18),

            // Password
            Text('Password', style: kLabel(12)),
            const SizedBox(height: 8),
            TextField(
              controller: _passCtrl,
              obscureText: _obscure,
              style: kBody(15),
              onSubmitted: (_) => _login(),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock_outline, size: 20, color: kTextMuted),
                hintText: '••••••••',
                suffixIcon: IconButton(icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20, color: kTextMuted), onPressed: () => setState(() => _obscure = !_obscure)),
              ),
            ),
            const SizedBox(height: 12),

            // Forgot password
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(onPressed: () {}, child: Text('Forgot Password?', style: kBody(13, color: kGold, weight: FontWeight.w600))),
            ),
            const SizedBox(height: 8),

            GoldButton(label: 'SIGN IN', onTap: _login, loading: _loading),
            const SizedBox(height: 24),

            const DividerLabel(text: 'or'),
            const SizedBox(height: 24),

            // Register
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text("Don't have an account? ", style: kBody(14, color: kTextMuted)),
              GestureDetector(onTap: () => context.go('/register'), child: Text('Register', style: kBody(14, color: kGold, weight: FontWeight.w700))),
            ]),
          ]),
        ),
      ),
    );
  }
}
