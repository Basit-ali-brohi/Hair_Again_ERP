import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../../../core/widgets.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  bool _loading = false;
  bool _sent = false;
  String? _error;

  @override
  void dispose() { _emailCtrl.dispose(); super.dispose(); }

  Future<void> _send() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      setState(() => _error = 'Please enter your email address.');
      return;
    }
    if (!email.contains('@')) {
      setState(() => _error = 'Please enter a valid email address.');
      return;
    }
    setState(() { _loading = true; _error = null; });
    await Future.delayed(const Duration(milliseconds: 1100));
    if (!mounted) return;
    setState(() { _loading = false; _sent = true; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: KAppBar(title: 'Forgot Password', showBack: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
        child: _sent ? _SentState(email: _emailCtrl.text.trim(), onContinue: () {
          context.push('/otp', extra: {'email': _emailCtrl.text.trim(), 'mode': 'reset'});
        }) : _InputState(
          emailCtrl: _emailCtrl,
          loading: _loading,
          error: _error,
          onSend: _send,
          onBack: () => context.pop(),
        ),
      ),
    );
  }
}

class _InputState extends StatelessWidget {
  final TextEditingController emailCtrl;
  final bool loading;
  final String? error;
  final VoidCallback onSend, onBack;
  const _InputState({required this.emailCtrl, required this.loading, this.error, required this.onSend, required this.onBack});

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Center(child: Container(
      width: 88, height: 88,
      decoration: BoxDecoration(
        gradient: RadialGradient(colors: [kGold.withValues(alpha: 0.18), kGold.withValues(alpha: 0.04)]),
        shape: BoxShape.circle,
        border: Border.all(color: kGold.withValues(alpha: 0.25), width: 1.5),
      ),
      child: const Icon(Icons.lock_reset_rounded, size: 40, color: kGold),
    )),
    const SizedBox(height: 28),
    Text('Reset Your Password', style: kDisplay(28), textAlign: TextAlign.center),
    const SizedBox(height: 8),
    Text('Enter the email linked to your account. We\'ll send you a 6-digit code to verify your identity.', style: kBody(14, color: kTextMuted), textAlign: TextAlign.center),
    const SizedBox(height: 36),

    if (error != null) ...[
      Container(
        padding: const EdgeInsets.all(14),
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(color: kDanger.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: kDanger.withValues(alpha: 0.3))),
        child: Row(children: [
          const Icon(Icons.error_outline, color: kDanger, size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(error!, style: kBody(13, color: kDanger))),
        ]),
      ),
    ],

    Text('Email Address', style: kLabel(12)),
    const SizedBox(height: 8),
    TextField(
      controller: emailCtrl,
      keyboardType: TextInputType.emailAddress,
      style: kBody(15),
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.email_outlined, size: 20, color: kTextMuted),
        hintText: 'you@example.com',
      ),
    ),
    const SizedBox(height: 32),
    GoldButton(label: 'SEND CODE', onTap: onSend, loading: loading, icon: Icons.send_rounded),
    const SizedBox(height: 16),
    OutlineBtn(label: 'Back to Login', onTap: onBack),
  ]);
}

class _SentState extends StatelessWidget {
  final String email;
  final VoidCallback onContinue;
  const _SentState({required this.email, required this.onContinue});

  @override
  Widget build(BuildContext context) => Column(children: [
    const SizedBox(height: 24),
    Container(
      width: 88, height: 88,
      decoration: BoxDecoration(
        color: kSuccess.withValues(alpha: 0.12),
        shape: BoxShape.circle,
        border: Border.all(color: kSuccess.withValues(alpha: 0.3), width: 1.5),
      ),
      child: const Icon(Icons.mark_email_read_outlined, size: 40, color: kSuccess),
    ),
    const SizedBox(height: 24),
    Text('Code Sent!', style: kDisplay(26), textAlign: TextAlign.center),
    const SizedBox(height: 12),
    Text('We\'ve sent a 6-digit OTP to', style: kBody(14, color: kTextMuted), textAlign: TextAlign.center),
    const SizedBox(height: 4),
    Text(email, style: kBody(14, color: kGold, weight: FontWeight.w700), textAlign: TextAlign.center),
    const SizedBox(height: 8),
    Text('Check your inbox and enter the code on the next screen.', style: kBody(13, color: kTextMuted), textAlign: TextAlign.center),
    const SizedBox(height: 40),
    GoldButton(label: 'ENTER OTP', onTap: onContinue, icon: Icons.arrow_forward_rounded),
  ]);
}
