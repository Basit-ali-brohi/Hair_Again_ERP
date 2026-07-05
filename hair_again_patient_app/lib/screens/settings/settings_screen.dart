import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../../../core/widgets.dart';
import '../../../core/router.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifs    = true;
  bool _apptReminders = true;
  bool _promoNotifs   = false;
  bool _biometric     = false;

  @override
  Widget build(BuildContext context) {
    final p = HaTheme.of(context);
    return Scaffold(
      backgroundColor: p.bg,
      appBar: AppBar(
        backgroundColor: p.surface,
        elevation: 0,
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height: 1, color: p.border)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 18, color: p.text),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text('Settings', style: p.display(20)),
        centerTitle: false,
      ),
      body: ListView(padding: const EdgeInsets.fromLTRB(0, 12, 0, 60), children: [

        _SectionLabel('Appearance', p),

        // Theme toggle — wired to appNotifier
        ListenableBuilder(
          listenable: appNotifier,
          builder: (_, __) => _ToggleTile(
            p: p,
            icon: appNotifier.isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
            title: 'Dark Mode',
            subtitle: appNotifier.isDark ? 'Switch to light theme' : 'Switch to dark theme',
            value: appNotifier.isDark,
            onChanged: (_) => appNotifier.toggleTheme(),
          ),
        ),

        const SizedBox(height: 4),
        _SectionLabel('Notifications', p),
        _ToggleTile(p: p, icon: Icons.notifications_outlined, title: 'Push Notifications', subtitle: 'Receive app notifications', value: _pushNotifs, onChanged: (v) => setState(() => _pushNotifs = v)),
        _ToggleTile(p: p, icon: Icons.calendar_today_outlined, title: 'Appointment Reminders', subtitle: 'Get reminded before appointments', value: _apptReminders, onChanged: (v) => setState(() => _apptReminders = v)),
        _ToggleTile(p: p, icon: Icons.local_offer_outlined, title: 'Promotions & Offers', subtitle: 'Receive discount notifications', value: _promoNotifs, onChanged: (v) => setState(() => _promoNotifs = v)),

        const SizedBox(height: 4),
        _SectionLabel('Security', p),
        _ToggleTile(p: p, icon: Icons.fingerprint_outlined, title: 'Biometric Login', subtitle: 'Use fingerprint or Face ID', value: _biometric, onChanged: (v) => setState(() => _biometric = v)),
        _NavTile(p: p, icon: Icons.lock_outline, title: 'Change Password', subtitle: 'Update your login password', onTap: () => _changePasswordSheet(context, p)),
        _NavTile(p: p, icon: Icons.devices_outlined, title: 'Active Sessions', subtitle: 'Manage logged-in devices', onTap: () {}),

        const SizedBox(height: 4),
        _SectionLabel('Account', p),
        _NavTile(p: p, icon: Icons.language_outlined, title: 'Language', subtitle: 'English', onTap: () {}),
        _NavTile(p: p, icon: Icons.info_outline, title: 'About Hair Again', subtitle: 'Version 1.0.0', onTap: () => _showAbout(context, p)),
        _NavTile(p: p, icon: Icons.description_outlined, title: 'Terms & Conditions', subtitle: 'Read our terms', onTap: () {}),
        _NavTile(p: p, icon: Icons.privacy_tip_outlined, title: 'Privacy Policy', subtitle: 'How we use your data', onTap: () {}),
        _NavTile(p: p, icon: Icons.help_outline, title: 'Help & Support', subtitle: 'FAQs and contact support', onTap: () => context.push('/chat')),

        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: OutlineBtn(label: 'Log Out', onTap: () => _confirmLogout(context, p), color: kDanger),
        ),
        const SizedBox(height: 14),
        Center(child: Text('Hair Again Patient App  v1.0.0', style: p.body(12, color: p.textMuted))),
      ]),
    );
  }

  void _confirmLogout(BuildContext context, AppPalette p) {
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: p.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Text('Log Out', style: p.body(18, weight: FontWeight.w700)),
      content: Text('Are you sure you want to log out?', style: p.body(14, color: p.textMuted)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: p.body(14, color: p.textMuted))),
        TextButton(onPressed: () { Navigator.pop(context); markLoggedOut(); context.go('/login'); },
            child: Text('Log Out', style: p.body(14, color: kDanger, weight: FontWeight.w700))),
      ],
    ));
  }

  void _changePasswordSheet(BuildContext context, AppPalette p) {
    final cur = TextEditingController(), nw = TextEditingController(), conf = TextEditingController();
    showModalBottomSheet(
      context: context, backgroundColor: p.surface, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(20, 24, 20, MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20, left: 0), decoration: BoxDecoration(color: p.border, borderRadius: BorderRadius.circular(2))),
          Text('Change Password', style: p.display(22)),
          const SizedBox(height: 20),
          _PasswordField(p: p, hint: 'Current Password', ctrl: cur),
          const SizedBox(height: 12),
          _PasswordField(p: p, hint: 'New Password', ctrl: nw),
          const SizedBox(height: 12),
          _PasswordField(p: p, hint: 'Confirm New Password', ctrl: conf),
          const SizedBox(height: 24),
          GoldButton(label: 'Update Password', onTap: () => Navigator.pop(context)),
        ]),
      ),
    );
  }

  void _showAbout(BuildContext context, AppPalette p) {
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: p.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 72, height: 72, decoration: BoxDecoration(gradient: kGoldGradient, borderRadius: BorderRadius.circular(20)), child: const Icon(Icons.spa_outlined, color: Colors.black87, size: 36)),
        const SizedBox(height: 16),
        Text('Hair Again', style: p.display(24, color: kGold)),
        const SizedBox(height: 4),
        Text('Patient Mobile App', style: p.body(13, color: p.textMuted)),
        const SizedBox(height: 2),
        Text('Version 1.0.0', style: p.body(12, color: p.textMuted)),
        const SizedBox(height: 16),
        Text('Karachi\'s premier hair restoration clinic.\nAdvanced treatments, exceptional results.', style: p.body(13, color: p.textMuted), textAlign: TextAlign.center),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('Close', style: p.body(14, color: kGold, weight: FontWeight.w600)))],
    ));
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final AppPalette p;
  const _SectionLabel(this.label, this.p);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
    child: Text(label.toUpperCase(), style: p.label(11)),
  );
}

class _ToggleTile extends StatelessWidget {
  final AppPalette p;
  final IconData icon;
  final String title, subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _ToggleTile({required this.p, required this.icon, required this.title, required this.subtitle, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    decoration: BoxDecoration(border: Border(bottom: BorderSide(color: p.border, width: 0.5))),
    child: Row(children: [
      Container(width: 38, height: 38, decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(10), border: Border.all(color: p.border)), child: Icon(icon, size: 18, color: p.textMuted)),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: p.body(14, weight: FontWeight.w600)),
        Text(subtitle, style: p.body(12, color: p.textMuted)),
      ])),
      Switch.adaptive(
        value: value, onChanged: onChanged,
        activeTrackColor: kGold.withValues(alpha: 0.6),
        activeThumbColor: kGold,
        inactiveTrackColor: p.border,
        inactiveThumbColor: p.textMuted,
      ),
    ]),
  );
}

class _NavTile extends StatelessWidget {
  final AppPalette p;
  final IconData icon;
  final String title, subtitle;
  final VoidCallback onTap;
  const _NavTile({required this.p, required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(color: Colors.transparent, border: Border(bottom: BorderSide(color: p.border, width: 0.5))),
      child: Row(children: [
        Container(width: 38, height: 38, decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(10), border: Border.all(color: p.border)), child: Icon(icon, size: 18, color: p.textMuted)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: p.body(14, weight: FontWeight.w600)),
          Text(subtitle, style: p.body(12, color: p.textMuted)),
        ])),
        Icon(Icons.chevron_right, size: 18, color: p.textMuted),
      ]),
    ),
  );
}

class _PasswordField extends StatefulWidget {
  final String hint;
  final TextEditingController ctrl;
  final AppPalette p;
  const _PasswordField({required this.hint, required this.ctrl, required this.p});
  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _obs = true;
  @override
  Widget build(BuildContext context) => TextField(
    controller: widget.ctrl, obscureText: _obs,
    style: widget.p.body(14),
    decoration: InputDecoration(
      hintText: widget.hint, hintStyle: widget.p.body(14, color: widget.p.textMuted),
      filled: true, fillColor: widget.p.surfaceAlt,
      suffixIcon: IconButton(icon: Icon(_obs ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: widget.p.textMuted, size: 18), onPressed: () => setState(() => _obs = !_obs)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: widget.p.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: widget.p.border)),
      focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide(color: kGold, width: 1.5)),
    ),
  );
}
