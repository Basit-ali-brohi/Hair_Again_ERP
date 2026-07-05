import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../../../core/widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl  = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  bool _googleLoading = false;
  String? _error;
  bool _agreed = false;

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose(); _phoneCtrl.dispose(); _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _signUpWithGoogle() async {
    setState(() { _googleLoading = true; _error = null; });
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    context.go('/otp', extra: 'google@gmail.com');
  }

  Future<void> _register() async {
    if (_nameCtrl.text.trim().isEmpty || _emailCtrl.text.trim().isEmpty || _phoneCtrl.text.trim().isEmpty || _passCtrl.text.isEmpty) {
      setState(() => _error = 'Please fill in all fields.'); return;
    }
    if (!_agreed) { setState(() => _error = 'Please accept the terms & conditions.'); return; }
    setState(() { _loading = true; _error = null; });
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    context.go('/otp', extra: _emailCtrl.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: KAppBar(title: 'Create Account', actions: [TextButton(onPressed: () => context.go('/login'), child: Text('Sign In', style: kBody(14, color: kGold, weight: FontWeight.w600)))]),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Join Hair Again', style: kDisplay(28)),
          const SizedBox(height: 6),
          Text('Create your patient account', style: kBody(14, color: kTextMuted)),
          const SizedBox(height: 28),

          if (_error != null) ...[
            Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(color: kDanger.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: kDanger.withValues(alpha: 0.3))),
              child: Row(children: [
                const Icon(Icons.error_outline, color: kDanger, size: 18), const SizedBox(width: 10),
                Expanded(child: Text(_error!, style: kBody(13, color: kDanger))),
              ]),
            ),
          ],

          Text('Full Name', style: kLabel(12)),
          const SizedBox(height: 8),
          TextField(controller: _nameCtrl, textCapitalization: TextCapitalization.words, style: kBody(15),
            decoration: const InputDecoration(prefixIcon: Icon(Icons.person_outline, size: 20, color: kTextMuted), hintText: 'Ahmad Ali')),
          const SizedBox(height: 18),

          Text('Email Address', style: kLabel(12)),
          const SizedBox(height: 8),
          TextField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress, style: kBody(15),
            decoration: const InputDecoration(prefixIcon: Icon(Icons.email_outlined, size: 20, color: kTextMuted), hintText: 'ahmad@gmail.com')),
          const SizedBox(height: 18),

          Text('Phone Number', style: kLabel(12)),
          const SizedBox(height: 8),
          TextField(controller: _phoneCtrl, keyboardType: TextInputType.phone, style: kBody(15),
            decoration: const InputDecoration(prefixIcon: Icon(Icons.phone_outlined, size: 20, color: kTextMuted), hintText: '+92 300 1234567')),
          const SizedBox(height: 18),

          Text('Password', style: kLabel(12)),
          const SizedBox(height: 8),
          TextField(
            controller: _passCtrl, obscureText: _obscure, style: kBody(15),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.lock_outline, size: 20, color: kTextMuted),
              hintText: 'Min. 8 characters',
              suffixIcon: IconButton(icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20, color: kTextMuted), onPressed: () => setState(() => _obscure = !_obscure)),
            ),
          ),
          const SizedBox(height: 20),

          // Terms
          GestureDetector(
            onTap: () => setState(() => _agreed = !_agreed),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 20, height: 20, margin: const EdgeInsets.only(top: 1),
                decoration: BoxDecoration(color: _agreed ? kGold : Colors.transparent, borderRadius: BorderRadius.circular(5), border: Border.all(color: _agreed ? kGold : kBorder, width: 1.5)),
                child: _agreed ? const Icon(Icons.check, size: 13, color: Colors.black87) : null,
              ),
              const SizedBox(width: 12),
              Expanded(child: Text.rich(TextSpan(style: kBody(13, color: kTextMuted), children: [
                const TextSpan(text: 'I agree to the '),
                TextSpan(text: 'Terms & Conditions', style: kBody(13, color: kGold, weight: FontWeight.w600)),
                const TextSpan(text: ' and '),
                TextSpan(text: 'Privacy Policy', style: kBody(13, color: kGold, weight: FontWeight.w600)),
              ]))),
            ]),
          ),
          const SizedBox(height: 28),

          GoldButton(label: 'CREATE ACCOUNT', onTap: _register, loading: _loading),
          const SizedBox(height: 20),

          const DividerLabel(text: 'or'),
          const SizedBox(height: 20),

          GoogleButton(onTap: _signUpWithGoogle, loading: _googleLoading),
          const SizedBox(height: 28),

          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('Already have an account? ', style: kBody(14, color: kTextMuted)),
            GestureDetector(onTap: () => context.go('/login'), child: Text('Sign In', style: kBody(14, color: kGold, weight: FontWeight.w700))),
          ]),
        ]),
      ),
    );
  }
}
