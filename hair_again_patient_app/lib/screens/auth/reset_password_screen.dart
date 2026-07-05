import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../../../core/widgets.dart';
import '../../../core/router.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});
  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _newCtrl  = TextEditingController();
  final _confCtrl = TextEditingController();
  bool _obscNew  = true;
  bool _obscConf = true;
  bool _loading  = false;
  bool _done     = false;
  String? _error;

  @override
  void dispose() { _newCtrl.dispose(); _confCtrl.dispose(); super.dispose(); }

  Future<void> _submit() async {
    final pw = _newCtrl.text;
    final conf = _confCtrl.text;
    if (pw.isEmpty || conf.isEmpty) { setState(() => _error = 'Please fill in both fields.'); return; }
    if (pw.length < 8)               { setState(() => _error = 'Password must be at least 8 characters.'); return; }
    if (pw != conf)                  { setState(() => _error = 'Passwords do not match.'); return; }
    setState(() { _loading = true; _error = null; });
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;
    setState(() { _loading = false; _done = true; });
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;
    markLoggedIn();
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: KAppBar(title: 'New Password', showBack: !_done),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
        child: _done ? _SuccessState() : _FormState(
          newCtrl: _newCtrl, confCtrl: _confCtrl,
          obscNew: _obscNew, obscConf: _obscConf,
          error: _error, loading: _loading,
          onToggleNew:  () => setState(() => _obscNew  = !_obscNew),
          onToggleConf: () => setState(() => _obscConf = !_obscConf),
          onSubmit: _submit,
        ),
      ),
    );
  }
}

class _FormState extends StatelessWidget {
  final TextEditingController newCtrl, confCtrl;
  final bool obscNew, obscConf, loading;
  final String? error;
  final VoidCallback onToggleNew, onToggleConf, onSubmit;
  const _FormState({required this.newCtrl, required this.confCtrl, required this.obscNew, required this.obscConf, this.error, required this.loading, required this.onToggleNew, required this.onToggleConf, required this.onSubmit});

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Center(child: Container(
      width: 88, height: 88,
      decoration: BoxDecoration(gradient: kGoldGradient, shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: kGold.withValues(alpha: 0.25), blurRadius: 20)]),
      child: const Icon(Icons.lock_outlined, size: 38, color: Colors.black87),
    )),
    const SizedBox(height: 28),
    Text('Set New Password', style: kDisplay(28), textAlign: TextAlign.center),
    const SizedBox(height: 8),
    Text('Choose a strong password with at least 8 characters.', style: kBody(14, color: kTextMuted), textAlign: TextAlign.center),
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

    Text('New Password', style: kLabel(12)),
    const SizedBox(height: 8),
    TextField(
      controller: newCtrl, obscureText: obscNew, style: kBody(15),
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.lock_outline, size: 20, color: kTextMuted),
        hintText: 'Min. 8 characters',
        suffixIcon: IconButton(
          icon: Icon(obscNew ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20, color: kTextMuted),
          onPressed: onToggleNew,
        ),
      ),
    ),
    const SizedBox(height: 20),

    Text('Confirm Password', style: kLabel(12)),
    const SizedBox(height: 8),
    TextField(
      controller: confCtrl, obscureText: obscConf, style: kBody(15),
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.lock_outline, size: 20, color: kTextMuted),
        hintText: 'Re-enter new password',
        suffixIcon: IconButton(
          icon: Icon(obscConf ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20, color: kTextMuted),
          onPressed: onToggleConf,
        ),
      ),
    ),
    const SizedBox(height: 36),

    // Password strength hint
    Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 28),
      decoration: BoxDecoration(
        color: kInfo.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kInfo.withValues(alpha: 0.18)),
      ),
      child: Row(children: [
        const Icon(Icons.tips_and_updates_outlined, size: 16, color: kInfo),
        const SizedBox(width: 10),
        Expanded(child: Text('Use uppercase, lowercase, numbers and symbols for a strong password.', style: kBody(12, color: kTextMuted))),
      ]),
    ),

    GoldButton(label: 'UPDATE PASSWORD', onTap: onSubmit, loading: loading, icon: Icons.check_circle_outline_rounded),
  ]);
}

class _SuccessState extends StatelessWidget {
  const _SuccessState();

  @override
  Widget build(BuildContext context) => Column(children: [
    const SizedBox(height: 40),
    Container(
      width: 100, height: 100,
      decoration: BoxDecoration(color: kSuccess.withValues(alpha: 0.12), shape: BoxShape.circle,
        border: Border.all(color: kSuccess.withValues(alpha: 0.3), width: 2)),
      child: const Icon(Icons.check_rounded, size: 52, color: kSuccess),
    ),
    const SizedBox(height: 28),
    Text('Password Updated!', style: kDisplay(26), textAlign: TextAlign.center),
    const SizedBox(height: 12),
    Text('Your password has been changed successfully.\nLogging you in...', style: kBody(14, color: kTextMuted), textAlign: TextAlign.center),
    const SizedBox(height: 28),
    const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: kGold, strokeWidth: 2.5)),
  ]);
}
