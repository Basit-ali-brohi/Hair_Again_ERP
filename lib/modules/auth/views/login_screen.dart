import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/core.dart';
import '../models/auth_models.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _remember = false;
  bool _loading = false;
  String? _error;
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _login() async {
    final email = _emailCtrl.text.trim().toLowerCase();
    final pass = _passCtrl.text;
    if (email.isEmpty || pass.isEmpty) {
      setState(() => _error = 'Please enter your email and password.');
      return;
    }
    setState(() { _loading = true; _error = null; });
    await Future.delayed(const Duration(milliseconds: 800));
    final user = demoUsers.where((u) => u.email.toLowerCase() == email && u.password == pass && u.isActive).firstOrNull;
    if (user == null) {
      setState(() { _loading = false; _error = 'Invalid credentials. Please check your email and password.'; });
      return;
    }
    setState(() => _loading = false);
    appState.login(user);
  }

  void _showDemoAccounts() {
    final p = appState.palette;
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 520,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: p.border)),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text('DEMO ACCOUNTS', style: p.display(22, spacing: 1.2)),
              const Spacer(),
              GestureDetector(onTap: () => Navigator.pop(context), child: Icon(Icons.close, color: p.textMuted, size: 20)),
            ]),
            const SizedBox(height: 6),
            Text('Click any account to auto-fill credentials', style: p.body(12.5, color: p.textMuted)),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.65),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: demoUsers.map((u) => _DemoUserRow(user: u, palette: p, onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _emailCtrl.text = u.email;
                      _passCtrl.text = u.password;
                      _error = null;
                    });
                  })).toList(),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  // ── Forgot password flow ──────────────────────────────────────────────────

  void _showForgotPassword() => showDialog(
    context: context, barrierDismissible: false,
    builder: (_) => _ForgotPasswordDialog(onSuccess: _showOtpVerification),
  );

  void _showOtpVerification(String email) => showDialog(
    context: context, barrierDismissible: false,
    builder: (_) => _OtpDialog(email: email, onBack: _showForgotPassword, onSuccess: _showResetPassword),
  );

  void _showResetPassword(String email) => showDialog(
    context: context, barrierDismissible: false,
    builder: (ctx) => _ResetPasswordDialog(email: email, onSuccess: () => toast(context, 'Password reset successfully. Please sign in.')),
  );

  @override
  Widget build(BuildContext context) {
    final p = appState.palette;
    return Scaffold(
      backgroundColor: p.bg,
      body: FadeTransition(
        opacity: _fade,
        child: Row(
          children: [
            // ── Left hero panel ──────────────────────────────────────────────
            Expanded(
              flex: 5,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [const Color(0xFF0E0E12), const Color(0xFF1A1500), const Color(0xFF0E0E12)],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
                child: Stack(
                  children: [
                    // Grid pattern
                    CustomPaint(painter: _GridPainter(), child: const SizedBox.expand()),
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(52),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Logo
                          Row(children: [
                            Container(
                              width: 56, height: 56,
                              decoration: BoxDecoration(gradient: p.goldGradient, borderRadius: BorderRadius.circular(14)),
                              child: const Icon(Icons.spa_outlined, color: Colors.black87, size: 28),
                            ),
                            const SizedBox(width: 16),
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text('HAIR AGAIN', style: p.display(32, spacing: 2.0, color: const Color(0xFFC9A24B))),
                              Text('CLINIC ERP • KARACHI', style: p.body(11, color: const Color(0xFF9A9AA6), weight: FontWeight.w600, spacing: 2.0)),
                            ]),
                          ]),
                          const SizedBox(height: 48),
                          // Headline
                          Text('Premium\nHair Care\nManagement', style: GoogleFonts.bebasNeue(fontSize: 68, color: Colors.white, letterSpacing: 1.5, height: 1.05)),
                          const SizedBox(height: 18),
                          Text('The complete ERP solution for modern\nhair transplant & care clinics.', style: p.body(15, color: const Color(0xFF9A9AA6))),
                          const SizedBox(height: 36),
                          // Stats
                          Row(children: [
                            _StatBubble(value: '165+', label: 'Screens', palette: p),
                            const SizedBox(width: 24),
                            _StatBubble(value: '22', label: 'Modules', palette: p),
                            const SizedBox(width: 24),
                            _StatBubble(value: '100%', label: 'Secure', palette: p),
                          ]),
                          const SizedBox(height: 36),
                          // Feature bullets
                          ...[
                            (Icons.group_outlined, 'Full CRM & Patient Journey Tracking'),
                            (Icons.point_of_sale_outlined, 'POS, Inventory & Billing'),
                            (Icons.people_outlined, 'HR, Payroll & Recruitment'),
                            (Icons.trending_up_outlined, 'Finance, Reports & Analytics'),
                          ].map((f) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(children: [
                              Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFFC9A24B).withValues(alpha: 0.14), borderRadius: BorderRadius.circular(8)), child: Icon(f.$1, size: 17, color: const Color(0xFFC9A24B))),
                              const SizedBox(width: 14),
                              Text(f.$2, style: p.body(14, color: Colors.white70, weight: FontWeight.w500)),
                            ]),
                          )),
                          const SizedBox(height: 32),
                          Text('© 2026 Hair Again Clinic ERP. All rights reserved.', style: p.body(11, color: const Color(0xFF9A9AA6))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Right form panel ─────────────────────────────────────────────
            Expanded(
              flex: 4,
              child: Container(
                color: p.sidebar,
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(56),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Welcome Back', style: p.display(42, spacing: 0.5)),
                          const SizedBox(height: 8),
                          Text('Sign in to your account to continue', style: p.body(14, color: p.textMuted)),
                          const SizedBox(height: 40),

                          // Error
                          if (_error != null) ...[
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(color: p.danger.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10), border: Border.all(color: p.danger.withValues(alpha: 0.35))),
                              child: Row(children: [
                                Icon(Icons.error_outline, color: p.danger, size: 18),
                                const SizedBox(width: 10),
                                Expanded(child: Text(_error!, style: p.body(13, color: p.danger))),
                              ]),
                            ),
                            const SizedBox(height: 20),
                          ],

                          // Email
                          _FieldLabel('Email Address', p),
                          const SizedBox(height: 8),
                          _LoginField(
                            controller: _emailCtrl, palette: p,
                            hint: 'admin@hairagain.pk',
                            prefix: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            onSubmit: (_) {},
                          ),
                          const SizedBox(height: 20),

                          // Password
                          _FieldLabel('Password', p),
                          const SizedBox(height: 8),
                          _LoginField(
                            controller: _passCtrl, palette: p,
                            hint: '••••••••',
                            prefix: Icons.lock_outline,
                            obscure: _obscure,
                            suffixIcon: GestureDetector(
                              onTap: () => setState(() => _obscure = !_obscure),
                              child: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 18, color: p.textMuted),
                            ),
                            onSubmit: (_) => _login(),
                          ),
                          const SizedBox(height: 16),

                          // Remember + Forgot
                          Row(children: [
                            GestureDetector(
                              onTap: () => setState(() => _remember = !_remember),
                              child: Row(children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  width: 18, height: 18,
                                  decoration: BoxDecoration(
                                    color: _remember ? p.gold : Colors.transparent,
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(color: _remember ? p.gold : p.border, width: 1.5),
                                  ),
                                  child: _remember ? const Icon(Icons.check, size: 12, color: Colors.black87) : null,
                                ),
                                const SizedBox(width: 8),
                                Text('Remember me', style: p.body(13.5, weight: FontWeight.w500)),
                              ]),
                            ),
                            const Spacer(),
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: _showForgotPassword,
                                child: Text('Forgot Password?', style: p.body(13.5, color: p.gold, weight: FontWeight.w600)),
                              ),
                            ),
                          ]),
                          const SizedBox(height: 32),

                          // Login Button
                          SizedBox(
                            width: double.infinity,
                            child: _loading
                                ? Container(
                                    height: 52,
                                    decoration: BoxDecoration(gradient: p.goldGradient, borderRadius: BorderRadius.circular(10)),
                                    child: const Center(child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.black87, strokeWidth: 2.5))),
                                  )
                                : _LoginButton(label: 'SIGN IN', palette: p, onTap: _login),
                          ),
                          const SizedBox(height: 24),

                          // Demo accounts
                          Center(
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: _showDemoAccounts,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(10), border: Border.all(color: p.border)),
                                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                                    Icon(Icons.manage_accounts_outlined, size: 17, color: p.gold),
                                    const SizedBox(width: 8),
                                    Text('View Demo Accounts', style: p.body(13.5, color: p.gold, weight: FontWeight.w600)),
                                  ]),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),

                          // Role pill list
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: p.border)),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text('AVAILABLE ROLES', style: p.body(10.5, color: p.textMuted, weight: FontWeight.w700, spacing: 1.2)),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8, runSpacing: 8,
                                children: [
                                  UserRole.superAdmin, UserRole.owner, UserRole.branchManager,
                                  UserRole.hr, UserRole.accountant, UserRole.inventoryManager,
                                  UserRole.salesManager, UserRole.marketingManager,
                                  UserRole.receptionist, UserRole.doctor, UserRole.nurse,
                                ].map((r) => Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(8), border: Border.all(color: p.border)),
                                  child: Text(r.label, style: p.body(11.5, color: p.text, weight: FontWeight.w500)),
                                )).toList(),
                              ),
                            ]),
                          ),
                        ],
                      ),
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
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;
  final AppPalette p;
  const _FieldLabel(this.text, this.p);
  @override
  Widget build(BuildContext context) => Text(text, style: p.body(12.5, color: p.textMuted, weight: FontWeight.w600));
}

class _LoginField extends StatefulWidget {
  final TextEditingController controller;
  final AppPalette palette;
  final String hint;
  final IconData prefix;
  final bool obscure;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final ValueChanged<String> onSubmit;
  const _LoginField({required this.controller, required this.palette, required this.hint, required this.prefix, this.obscure = false, this.suffixIcon, this.keyboardType, required this.onSubmit});
  @override
  State<_LoginField> createState() => _LoginFieldState();
}

class _LoginFieldState extends State<_LoginField> {
  bool _focus = false;
  @override
  Widget build(BuildContext context) {
    final p = widget.palette;
    return Focus(
      onFocusChange: (v) => setState(() => _focus = v),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: p.surfaceAlt,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _focus ? p.gold : p.border, width: _focus ? 1.5 : 1),
          boxShadow: _focus ? [BoxShadow(color: p.gold.withValues(alpha: 0.15), blurRadius: 10)] : [],
        ),
        child: Row(children: [
          Padding(padding: const EdgeInsets.only(left: 14), child: Icon(widget.prefix, size: 18, color: _focus ? p.gold : p.textMuted)),
          Expanded(
            child: TextField(
              controller: widget.controller, obscureText: widget.obscure,
              keyboardType: widget.keyboardType, style: p.body(14),
              cursorColor: p.gold,
              onSubmitted: widget.onSubmit,
              decoration: InputDecoration(
                isCollapsed: true, border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                hintText: widget.hint, hintStyle: p.body(14, color: p.textMuted.withValues(alpha: 0.6)),
              ),
            ),
          ),
          if (widget.suffixIcon != null) Padding(padding: const EdgeInsets.only(right: 12), child: widget.suffixIcon!),
        ]),
      ),
    );
  }
}

class _LoginButton extends StatefulWidget {
  final String label;
  final AppPalette palette;
  final VoidCallback onTap;
  const _LoginButton({required this.label, required this.palette, required this.onTap});
  @override
  State<_LoginButton> createState() => _LoginButtonState();
}

class _LoginButtonState extends State<_LoginButton> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    final p = widget.palette;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 52,
          decoration: BoxDecoration(
            gradient: p.goldGradient,
            borderRadius: BorderRadius.circular(10),
            boxShadow: _hover ? [BoxShadow(color: p.gold.withValues(alpha: 0.45), blurRadius: 20, offset: const Offset(0, 6))] : [],
          ),
          child: Center(child: Text(widget.label, style: p.body(15, color: Colors.black87, weight: FontWeight.w700, spacing: 1.5))),
        ),
      ),
    );
  }
}

class _StatBubble extends StatelessWidget {
  final String value;
  final String label;
  final AppPalette palette;
  const _StatBubble({required this.value, required this.label, required this.palette});
  @override
  Widget build(BuildContext context) {
    final p = palette;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(value, style: p.display(34, color: const Color(0xFFC9A24B))),
      Text(label, style: p.body(12, color: Colors.white54, weight: FontWeight.w500)),
    ]);
  }
}

class _DemoUserRow extends StatefulWidget {
  final AppUser user;
  final AppPalette palette;
  final VoidCallback onTap;
  const _DemoUserRow({required this.user, required this.palette, required this.onTap});
  @override
  State<_DemoUserRow> createState() => _DemoUserRowState();
}

class _DemoUserRowState extends State<_DemoUserRow> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    final p = widget.palette;
    final u = widget.user;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: _hover ? p.surfaceAlt : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _hover ? p.gold.withValues(alpha: 0.4) : p.border),
          ),
          child: Row(children: [
            CircleAvatar(radius: 18, backgroundColor: p.gold.withValues(alpha: 0.18), child: Text(u.initials, style: p.body(12, color: p.gold, weight: FontWeight.w700))),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(u.name, style: p.body(13.5, weight: FontWeight.w600)),
              Text(u.role.label, style: p.body(11.5, color: p.textMuted)),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(u.email, style: p.body(12, color: p.textMuted)),
              Text(u.password, style: p.body(12, color: p.gold, weight: FontWeight.w600)),
            ]),
          ]),
        ),
      ),
    );
  }
}

// ── Forgot Password dialog ────────────────────────────────────────────────────

class _ForgotPasswordDialog extends StatefulWidget {
  final ValueChanged<String> onSuccess;
  const _ForgotPasswordDialog({required this.onSuccess});
  @override
  State<_ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<_ForgotPasswordDialog> {
  final _ctrl = TextEditingController();
  bool _loading = false;
  String? _err;

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  Future<void> _submit() async {
    final email = _ctrl.text.trim().toLowerCase();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _err = 'Please enter a valid email address.');
      return;
    }
    setState(() { _loading = true; _err = null; });
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    Navigator.pop(context);
    widget.onSuccess(email);
  }

  @override
  Widget build(BuildContext context) {
    final p = appState.palette;
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 460, padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: p.border)),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          _AuthDialogHeader(p: p, icon: Icons.lock_reset_outlined, title: 'FORGOT PASSWORD', subtitle: 'Enter your registered email to receive a one-time code.', onClose: () => Navigator.pop(context)),
          const SizedBox(height: 24),
          _LoginField(controller: _ctrl, palette: p, hint: 'admin@hairagain.pk', prefix: Icons.email_outlined, keyboardType: TextInputType.emailAddress, onSubmit: (_) => _submit()),
          if (_err != null) ...[const SizedBox(height: 10), _AuthError(p: p, message: _err!)],
          const SizedBox(height: 24),
          Row(children: [
            Expanded(child: _AuthOutlineBtn(label: 'Cancel', p: p, onTap: () => Navigator.pop(context))),
            const SizedBox(width: 12),
            Expanded(child: _loading ? _AuthLoadingBtn(p: p) : _AuthSolidBtn(label: 'Send OTP', p: p, onTap: _submit)),
          ]),
        ]),
      ),
    );
  }
}

// ── OTP Verification dialog ────────────────────────────────────────────────────

class _OtpDialog extends StatefulWidget {
  final String email;
  final VoidCallback onBack;
  final ValueChanged<String> onSuccess;
  const _OtpDialog({required this.email, required this.onBack, required this.onSuccess});
  @override
  State<_OtpDialog> createState() => _OtpDialogState();
}

class _OtpDialogState extends State<_OtpDialog> {
  final _digits = List.generate(6, (_) => TextEditingController());
  final _foci   = List.generate(6, (_) => FocusNode());
  bool _loading = false;
  String? _err;

  @override
  void dispose() {
    for (final c in _digits) c.dispose();
    for (final f in _foci) f.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final code = _digits.map((c) => c.text).join();
    if (code.length < 6) { setState(() => _err = 'Please enter all 6 digits.'); return; }
    setState(() { _loading = true; _err = null; });
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    Navigator.pop(context);
    widget.onSuccess(widget.email);
  }

  @override
  Widget build(BuildContext context) {
    final p = appState.palette;
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 460, padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: p.border)),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          _AuthDialogHeader(p: p, icon: Icons.verified_outlined, title: 'ENTER OTP', subtitle: 'A 6-digit code was sent to ${widget.email}', onClose: () => Navigator.pop(context)),
          const SizedBox(height: 28),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(6, (i) => Container(
            width: 52, height: 60, margin: const EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(10), border: Border.all(color: p.border)),
            child: TextField(
              controller: _digits[i], focusNode: _foci[i],
              textAlign: TextAlign.center, maxLength: 1,
              keyboardType: TextInputType.number,
              style: p.body(22, weight: FontWeight.w700), cursorColor: p.gold,
              decoration: const InputDecoration(border: InputBorder.none, counterText: '', isCollapsed: true, contentPadding: EdgeInsets.symmetric(vertical: 16)),
              onChanged: (v) {
                if (v.length == 1 && i < 5) FocusScope.of(context).requestFocus(_foci[i + 1]);
                if (v.isEmpty && i > 0) FocusScope.of(context).requestFocus(_foci[i - 1]);
                setState(() => _err = null);
              },
            ),
          ))),
          if (_err != null) ...[const SizedBox(height: 10), _AuthError(p: p, message: _err!)],
          const SizedBox(height: 8),
          Center(child: TextButton(
            onPressed: () => toast(context, 'OTP resent to ${widget.email}'),
            child: Text("Didn't receive it? Resend OTP", style: p.body(12.5, color: p.gold, weight: FontWeight.w600)),
          )),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: _AuthOutlineBtn(label: 'Back', p: p, onTap: () { Navigator.pop(context); widget.onBack(); })),
            const SizedBox(width: 12),
            Expanded(child: _loading ? _AuthLoadingBtn(p: p) : _AuthSolidBtn(label: 'Verify', p: p, onTap: _verify)),
          ]),
        ]),
      ),
    );
  }
}

// ── Reset Password dialog ─────────────────────────────────────────────────────

class _ResetPasswordDialog extends StatefulWidget {
  final String email;
  final VoidCallback onSuccess;
  const _ResetPasswordDialog({required this.email, required this.onSuccess});
  @override
  State<_ResetPasswordDialog> createState() => _ResetPasswordDialogState();
}

class _ResetPasswordDialogState extends State<_ResetPasswordDialog> {
  final _newCtrl     = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscureN = true, _obscureC = true;
  bool _loading = false;
  String? _err;

  @override
  void dispose() { _newCtrl.dispose(); _confirmCtrl.dispose(); super.dispose(); }

  Future<void> _reset() async {
    final np = _newCtrl.text;
    final cp = _confirmCtrl.text;
    if (np.length < 6) { setState(() => _err = 'Password must be at least 6 characters.'); return; }
    if (np != cp) { setState(() => _err = 'Passwords do not match.'); return; }
    setState(() { _loading = true; _err = null; });
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    Navigator.pop(context);
    widget.onSuccess();
  }

  @override
  Widget build(BuildContext context) {
    final p = appState.palette;
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 460, padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: p.border)),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          _AuthDialogHeader(p: p, icon: Icons.key_outlined, title: 'RESET PASSWORD', subtitle: 'Choose a strong new password for ${widget.email}', onClose: () => Navigator.pop(context)),
          const SizedBox(height: 24),
          Text('New Password', style: p.body(12.5, color: p.textMuted, weight: FontWeight.w600)),
          const SizedBox(height: 8),
          _LoginField(controller: _newCtrl, palette: p, hint: '••••••••', prefix: Icons.lock_outline, obscure: _obscureN,
            suffixIcon: GestureDetector(onTap: () => setState(() => _obscureN = !_obscureN), child: Icon(_obscureN ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 17, color: p.textMuted)),
            onSubmit: (_) {}),
          const SizedBox(height: 16),
          Text('Confirm New Password', style: p.body(12.5, color: p.textMuted, weight: FontWeight.w600)),
          const SizedBox(height: 8),
          _LoginField(controller: _confirmCtrl, palette: p, hint: '••••••••', prefix: Icons.lock_outline, obscure: _obscureC,
            suffixIcon: GestureDetector(onTap: () => setState(() => _obscureC = !_obscureC), child: Icon(_obscureC ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 17, color: p.textMuted)),
            onSubmit: (_) => _reset()),
          const SizedBox(height: 10),
          _PasswordStrengthBar(p: p, ctrl: _newCtrl),
          if (_err != null) ...[const SizedBox(height: 8), _AuthError(p: p, message: _err!)],
          const SizedBox(height: 24),
          Row(children: [
            Expanded(child: _AuthOutlineBtn(label: 'Cancel', p: p, onTap: () => Navigator.pop(context))),
            const SizedBox(width: 12),
            Expanded(child: _loading ? _AuthLoadingBtn(p: p) : _AuthSolidBtn(label: 'Reset Password', p: p, onTap: _reset)),
          ]),
        ]),
      ),
    );
  }
}

// ── Auth dialog helpers ───────────────────────────────────────────────────────

class _AuthDialogHeader extends StatelessWidget {
  final AppPalette p;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onClose;
  const _AuthDialogHeader({required this.p, required this.icon, required this.title, required this.subtitle, required this.onClose});

  @override
  Widget build(BuildContext context) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Container(padding: const EdgeInsets.all(11), decoration: BoxDecoration(gradient: p.goldGradient, borderRadius: BorderRadius.circular(11)), child: Icon(icon, color: Colors.black87, size: 20)),
    const SizedBox(width: 14),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: p.display(20, spacing: 0.6)),
      const SizedBox(height: 3),
      Text(subtitle, style: p.body(12.5, color: p.textMuted)),
    ])),
    GestureDetector(onTap: onClose, child: MouseRegion(cursor: SystemMouseCursors.click, child: Icon(Icons.close, size: 18, color: p.textMuted))),
  ]);
}

class _AuthError extends StatelessWidget {
  final AppPalette p;
  final String message;
  const _AuthError({required this.p, required this.message});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(color: p.danger.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(8), border: Border.all(color: p.danger.withValues(alpha: 0.3))),
    child: Row(children: [Icon(Icons.error_outline, size: 15, color: p.danger), const SizedBox(width: 8), Expanded(child: Text(message, style: p.body(12.5, color: p.danger)))]),
  );
}

class _AuthOutlineBtn extends StatelessWidget {
  final String label;
  final AppPalette p;
  final VoidCallback onTap;
  const _AuthOutlineBtn({required this.label, required this.p, required this.onTap});
  @override
  Widget build(BuildContext context) => MouseRegion(cursor: SystemMouseCursors.click, child: GestureDetector(onTap: onTap, child: Container(
    height: 46, alignment: Alignment.center,
    decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(10), border: Border.all(color: p.border)),
    child: Text(label, style: p.body(13.5, weight: FontWeight.w600, color: p.textMuted)),
  )));
}

class _AuthSolidBtn extends StatelessWidget {
  final String label;
  final AppPalette p;
  final VoidCallback onTap;
  const _AuthSolidBtn({required this.label, required this.p, required this.onTap});
  @override
  Widget build(BuildContext context) => MouseRegion(cursor: SystemMouseCursors.click, child: GestureDetector(onTap: onTap, child: Container(
    height: 46, alignment: Alignment.center,
    decoration: BoxDecoration(gradient: p.goldGradient, borderRadius: BorderRadius.circular(10)),
    child: Text(label, style: p.body(13.5, weight: FontWeight.w700, color: Colors.black87)),
  )));
}

class _AuthLoadingBtn extends StatelessWidget {
  final AppPalette p;
  const _AuthLoadingBtn({required this.p});
  @override
  Widget build(BuildContext context) => Container(
    height: 46, alignment: Alignment.center,
    decoration: BoxDecoration(gradient: p.goldGradient, borderRadius: BorderRadius.circular(10)),
    child: const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black87, strokeWidth: 2.5)),
  );
}

class _PasswordStrengthBar extends StatefulWidget {
  final AppPalette p;
  final TextEditingController ctrl;
  const _PasswordStrengthBar({required this.p, required this.ctrl});
  @override
  State<_PasswordStrengthBar> createState() => _PasswordStrengthBarState();
}

class _PasswordStrengthBarState extends State<_PasswordStrengthBar> {
  @override
  void initState() { super.initState(); widget.ctrl.addListener(() => setState(() {})); }

  int get _score {
    final pw = widget.ctrl.text;
    if (pw.isEmpty) return 0;
    int s = 0;
    if (pw.length >= 8) s++;
    if (pw.contains(RegExp(r'[A-Z]'))) s++;
    if (pw.contains(RegExp(r'[0-9]'))) s++;
    if (pw.contains(RegExp(r'[!@#\$%^&*]'))) s++;
    return s;
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final s = _score;
    final label = ['', 'Weak', 'Fair', 'Good', 'Strong'][s];
    final color = [Colors.transparent, Colors.red.shade400, Colors.orange.shade400, Colors.amber.shade400, Colors.green.shade400][s];
    return Row(children: [
      Expanded(child: Row(children: List.generate(4, (i) => Expanded(child: Container(
        height: 4, margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
        decoration: BoxDecoration(color: i < s ? color : p.border, borderRadius: BorderRadius.circular(4)),
      ))))),
      const SizedBox(width: 10),
      Text(label, style: p.body(11.5, color: color, weight: FontWeight.w600)),
    ]);
  }
}

// ── Background grid pattern ───────────────────────────────────────────────────
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFC9A24B).withValues(alpha: 0.04)
      ..strokeWidth = 1;
    const spacing = 52.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }
  @override
  bool shouldRepaint(_) => false;
}
