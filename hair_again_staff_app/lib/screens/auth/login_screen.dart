import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../core/staff_data.dart';

class StaffLoginScreen extends StatefulWidget {
  const StaffLoginScreen({super.key});
  @override
  State<StaffLoginScreen> createState() => _StaffLoginScreenState();
}

class _StaffLoginScreenState extends State<StaffLoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  StaffRole _role  = StaffRole.receptionist;
  bool _obscure    = true;
  bool _loading    = false;
  String? _error;

  @override
  void dispose() { _emailCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }

  Future<void> _login() async {
    if (_emailCtrl.text.trim().isEmpty || _passCtrl.text.isEmpty) {
      setState(() => _error = 'Please fill in all fields.'); return;
    }
    setState(() { _loading = true; _error = null; });
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;
    // Use display name from email prefix
    final name = _emailCtrl.text.trim().split('@')[0].replaceAll('.', ' ').split(' ')
        .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}').join(' ');
    staffData.login(name.isNotEmpty ? name : 'Staff Member', _role);
    context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final p = HaTheme.of(context);
    return Scaffold(
      backgroundColor: p.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 20),
            // Logo
            Row(children: [
              Container(width: 48, height: 48,
                decoration: BoxDecoration(gradient: kGoldGradient, borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: kGold.withValues(alpha: 0.3), blurRadius: 12)]),
                child: const Icon(Icons.spa_outlined, color: Colors.black87, size: 24)),
              const SizedBox(width: 14),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('HAIR AGAIN', style: p.display(20, color: kGold, spacing: 1.5)),
                Text('Staff Portal', style: p.body(12, color: p.textMuted)),
              ]),
            ]),
            const SizedBox(height: 44),
            Text('Welcome Back', style: p.display(30)),
            const SizedBox(height: 6),
            Text('Sign in to access your staff dashboard', style: p.body(14, color: p.textMuted)),
            const SizedBox(height: 32),

            if (_error != null) ...[
              Container(
                padding: const EdgeInsets.all(14),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(color: kDanger.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: kDanger.withValues(alpha: 0.3))),
                child: Row(children: [
                  const Icon(Icons.error_outline, color: kDanger, size: 18), const SizedBox(width: 10),
                  Expanded(child: Text(_error!, style: p.body(13, color: kDanger))),
                ]),
              ),
            ],

            // Role selector
            Text('Your Role', style: p.label(12)),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 3.2,
              children: StaffRole.values.map((r) {
                final sel = r == _role;
                return GestureDetector(
                  onTap: () => setState(() => _role = r),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: sel ? kGold.withValues(alpha: 0.12) : p.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: sel ? kGold : p.border, width: sel ? 1.5 : 1),
                    ),
                    child: Row(children: [
                      Icon(r.icon, size: 18, color: sel ? kGold : p.textMuted),
                      const SizedBox(width: 8),
                      Expanded(child: Text(r.label, style: p.body(12, color: sel ? kGold : p.textMuted, weight: sel ? FontWeight.w700 : FontWeight.w400), overflow: TextOverflow.ellipsis)),
                      if (sel) const Icon(Icons.check_circle_rounded, size: 14, color: kGold),
                    ]),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            Text('Email Address', style: p.label(12)),
            const SizedBox(height: 8),
            TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              style: p.body(15),
              decoration: InputDecoration(prefixIcon: Icon(Icons.email_outlined, size: 20, color: p.textMuted), hintText: 'you@hairagain.pk'),
            ),
            const SizedBox(height: 18),

            Text('Password', style: p.label(12)),
            const SizedBox(height: 8),
            TextField(
              controller: _passCtrl, obscureText: _obscure,
              style: p.body(15),
              onSubmitted: (_) => _login(),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.lock_outline, size: 20, color: p.textMuted),
                hintText: '••••••••',
                suffixIcon: IconButton(icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20, color: p.textMuted), onPressed: () => setState(() => _obscure = !_obscure)),
              ),
            ),
            const SizedBox(height: 32),

            GoldButton(label: 'SIGN IN', onTap: _login, loading: _loading, icon: Icons.login_rounded),
            const SizedBox(height: 24),
            Center(child: Text('Hair Again Clinic  •  Staff Only', style: p.body(12, color: p.textMuted))),
          ]),
        ),
      ),
    );
  }
}
