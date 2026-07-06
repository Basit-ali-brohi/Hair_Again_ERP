import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../../../core/widgets.dart';
import '../../../core/router.dart';

class OtpScreen extends StatefulWidget {
  final String email;
  final String mode; // 'register' | 'reset'
  const OtpScreen({super.key, required this.email, this.mode = 'register'});
  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _digits = List.generate(6, (_) => TextEditingController());
  final _foci   = List.generate(6, (_) => FocusNode());
  bool _loading = false;
  String? _error;
  int _resendSeconds = 30;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() async {
    for (int i = _resendSeconds; i > 0; i--) {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      setState(() => _resendSeconds = i - 1);
    }
  }

  Future<void> _verify() async {
    final code = _digits.map((c) => c.text).join();
    if (code.length < 6) { setState(() => _error = 'Please enter all 6 digits.'); return; }
    setState(() { _loading = true; _error = null; });
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    if (widget.mode == 'reset') {
      context.pushReplacement('/reset-password');
    } else {
      markLoggedIn();
      context.go('/home');
    }
  }

  @override
  void dispose() {
    for (final c in _digits) c.dispose();
    for (final f in _foci) f.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = HaTheme.of(context);
    return Scaffold(
      backgroundColor: p.bg,
      appBar: KAppBar(title: 'OTP Verification'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
        child: Column(children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(color: kGold.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: const Icon(Icons.verified_outlined, size: 38, color: kGold),
          ),
          const SizedBox(height: 24),
          Text('Verify Your Identity', style: p.display(26), textAlign: TextAlign.center),
          const SizedBox(height: 10),
          Text('We sent a 6-digit code to', style: p.body(14, color: p.textMuted), textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(widget.email, style: p.body(14, color: kGold, weight: FontWeight.w600), textAlign: TextAlign.center),
          const SizedBox(height: 36),

          if (_error != null) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: kDanger.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: Text(_error!, style: p.body(13, color: kDanger), textAlign: TextAlign.center),
            ),
          ],

          // OTP inputs
          Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(6, (i) => Container(
            width: 48, height: 58,
            margin: const EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(12), border: Border.all(color: p.border)),
            child: TextField(
              controller: _digits[i], focusNode: _foci[i],
              textAlign: TextAlign.center, maxLength: 1,
              keyboardType: TextInputType.number,
              style: p.display(22),
              cursorColor: kGold,
              decoration: const InputDecoration(
                border: InputBorder.none, counterText: '',
                isCollapsed: true, contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
              onChanged: (v) {
                setState(() => _error = null);
                if (v.length == 1 && i < 5) FocusScope.of(context).requestFocus(_foci[i + 1]);
                if (v.isEmpty && i > 0) FocusScope.of(context).requestFocus(_foci[i - 1]);
              },
            ),
          ))),
          const SizedBox(height: 32),

          GoldButton(label: 'VERIFY CODE', onTap: _verify, loading: _loading),
          const SizedBox(height: 24),

          _resendSeconds > 0
              ? Text('Resend code in $_resendSeconds s', style: p.body(13, color: p.textMuted))
              : TextButton(
                  onPressed: () { setState(() => _resendSeconds = 30); _startResendTimer(); },
                  child: Text('Resend OTP', style: p.body(14, color: kGold, weight: FontWeight.w600)),
                ),
        ]),
      ),
    );
  }
}
