// modules/settings/views — system status, editable clinic profile, per-surgeon
// day schedules, treatment master pricing (feeds POS & booking), and global UI
// customization (theme mode + accent colors).
import 'package:flutter/material.dart';

import '../../../core/core.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _name, _addr, _phone, _email;
  final Map<String, Set<int>> _schedule = {
    'Dr. Rehman': {1, 2, 3, 4, 5},
    'Dr. Sara Iqbal': {1, 3, 5},
    'Dr. Bilal Khan': {2, 4, 6},
  };

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: appState.clinicName);
    _addr = TextEditingController(text: appState.clinicAddress);
    _phone = TextEditingController(text: appState.clinicPhone);
    _email = TextEditingController(text: appState.clinicEmail);
  }

  @override
  void dispose() {
    for (final c in [_name, _addr, _phone, _email]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    return ScreenScaffold(
      title: 'SYSTEM SETTINGS',
      subtitle: 'Configure the clinic profile, schedules, pricing and UI.',
      actions: [GoldButton(label: 'Save Changes', icon: Icons.save_outlined, onTap: () { appState.clinicName = _name.text; appState.clinicAddress = _addr.text; appState.clinicPhone = _phone.text; appState.clinicEmail = _email.text; appState.saveClinicProfile(); appState.touch(); toast(context, 'Settings saved'); })],
      child: ScrollArea(builder: (sc) => SingleChildScrollView(
        controller: sc,
        padding: const EdgeInsets.only(right: 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          MetricRow([
            MetricCard(title: 'System Version', value: '2026.1', delta: 'Stable', icon: Icons.verified_outlined),
            MetricCard(title: 'Database', value: 'Connected', delta: 'Local Mock', icon: Icons.storage_outlined),
            MetricCard(title: 'Active Users', value: '4', delta: 'Online', icon: Icons.people_alt_outlined),
            MetricCard(title: 'Backup Status', value: 'Safe', delta: 'Synced', icon: Icons.cloud_done_outlined),
          ]),
          const SizedBox(height: 18),
          LayoutBuilder(builder: (context, c) {
            final wide = c.maxWidth > 900;
            final profile = _profile(p);
            final schedule = _scheduleCard(p);
            if (wide) return IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Expanded(child: profile), const SizedBox(width: 18), Expanded(child: schedule)]));
            return Column(children: [profile, const SizedBox(height: 18), schedule]);
          }),
          const SizedBox(height: 18),
          _pricing(p),
          const SizedBox(height: 18),
          _accent(p),
          const SizedBox(height: 18),
          _security(p),
          const SizedBox(height: 18),
          _notifications(p),
          const SizedBox(height: 28),
        ]),
      )),
    );
  }

  Widget _profile(AppPalette p) => Panel(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SectionTitle('CLINIC PROFILE'),
          const SizedBox(height: 16),
          FormField2(label: 'Clinic Name', controller: _name),
          const SizedBox(height: 14),
          FormField2(label: 'Address', controller: _addr, maxLines: 2),
          const SizedBox(height: 14),
          Row(children: [Expanded(child: FormField2(label: 'Phone', controller: _phone)), const SizedBox(width: 14), Expanded(child: FormField2(label: 'Email', controller: _email))]),
        ]),
      );

  Widget _scheduleCard(AppPalette p) {
    const dows = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return Panel(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SectionTitle('DOCTOR ASSIGNMENT SCHEDULES', sub: 'Toggle working days per surgeon'),
        const SizedBox(height: 16),
        ...appState.surgeons.map((s) {
          final days = _schedule[s] ?? <int>{};
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(s, style: p.body(13, weight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(spacing: 6, runSpacing: 6, children: List.generate(7, (i) {
                final on = days.contains(i);
                return GestureDetector(
                  onTap: () => setState(() { on ? days.remove(i) : days.add(i); _schedule[s] = days; }),
                  child: Container(width: 42, padding: const EdgeInsets.symmetric(vertical: 8), alignment: Alignment.center, decoration: BoxDecoration(color: on ? p.gold.withValues(alpha: 0.16) : p.surfaceAlt, borderRadius: BorderRadius.circular(8), border: Border.all(color: on ? p.gold : p.border)), child: Text(dows[i], style: p.body(11, color: on ? p.gold : p.textMuted, weight: FontWeight.w600))),
                );
              })),
            ]),
          );
        }),
      ]),
    );
  }

  Widget _pricing(AppPalette p) => Panel(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SectionTitle('TREATMENT MASTER PRICING', sub: 'Adjust prices used across POS & booking'),
          const SizedBox(height: 16),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Row(children: [Expanded(flex: 5, child: _th(p, 'TREATMENT')), Expanded(flex: 2, child: _th(p, 'CATEGORY')), Expanded(flex: 3, child: _th(p, 'PRICE (PKR)'))])),
          const SizedBox(height: 6),
          Divider(height: 1, color: p.border),
          ...appState.treatments.map((t) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                child: Row(children: [
                  Expanded(flex: 5, child: Text(t.name, style: p.body(13, weight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
                  Expanded(flex: 2, child: Text(t.category, style: p.body(12.5, color: p.textMuted))),
                  Expanded(flex: 3, child: Row(children: [QtyButton(Icons.remove, () => appState.setTreatmentPrice(t, (t.price - 1000).clamp(0, double.infinity))), Expanded(child: Container(alignment: Alignment.center, child: Text(money(t.price), style: p.body(13, weight: FontWeight.w700)))), QtyButton(Icons.add, () => appState.setTreatmentPrice(t, t.price + 1000))])),
                ]),
              )),
        ]),
      );

  Widget _accent(AppPalette p) => Panel(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SectionTitle('GENERAL UI CUSTOMIZATION', sub: 'Theme mode & accent color'),
          const SizedBox(height: 16),
          Row(children: [Text('Appearance', style: p.body(13, weight: FontWeight.w600)), const SizedBox(width: 16), const ThemeToggle(), const SizedBox(width: 12), Text(appState.isDark ? 'Obsidian & Gold (Dark)' : 'Clinical Minimalist (Light)', style: p.body(12.5, color: p.textMuted))]),
          const SizedBox(height: 20),
          Text('Accent Color', style: p.body(13, weight: FontWeight.w600)),
          const SizedBox(height: 12),
          Wrap(spacing: 12, runSpacing: 12, children: List.generate(AppState.accents.length, (i) {
            final a = AppState.accents[i];
            final sel = appState.accentIndex == i;
            return GestureDetector(
              onTap: () => appState.setAccent(i),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(8), border: Border.all(color: sel ? a.color : p.border, width: sel ? 1.6 : 1)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [Container(width: 18, height: 18, decoration: BoxDecoration(color: a.color, borderRadius: BorderRadius.circular(6))), const SizedBox(width: 10), Text(a.name, style: p.body(12.5, weight: FontWeight.w600, color: sel ? p.text : p.textMuted)), if (sel) ...[const SizedBox(width: 8), Icon(Icons.check_circle, size: 15, color: a.color)]]),
              ),
            );
          })),
        ]),
      );

  Widget _th(AppPalette p, String t) => Text(t, style: p.body(11, color: p.textMuted, weight: FontWeight.w700, spacing: 0.8));

  Widget _security(AppPalette p) => Panel(
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SectionTitle('SECURITY & ACCESS', sub: 'Password management and session control'),
      const SizedBox(height: 20),
      LayoutBuilder(builder: (_, c) {
        final wide = c.maxWidth > 720;
        final changePass = _changePasswordCard(p);
        final session = _sessionCard(p);
        if (wide) return IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Expanded(child: changePass), const SizedBox(width: 16), Expanded(child: session)]));
        return Column(children: [changePass, const SizedBox(height: 16), session]);
      }),
    ]),
  );

  Widget _changePasswordCard(AppPalette p) {
    final current = TextEditingController();
    final newPass = TextEditingController();
    final confirm = TextEditingController();
    bool obsC = true, obsN = true, obsF = true;
    return StatefulBuilder(builder: (ctx, ss) => Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(10), border: Border.all(color: p.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: p.gold.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)), child: Icon(Icons.key_outlined, color: p.gold, size: 18)),
          const SizedBox(width: 10),
          Text('Change Password', style: p.body(14, weight: FontWeight.w700)),
        ]),
        const SizedBox(height: 16),
        _PassRow(label: 'Current Password', ctrl: current, obscure: obsC, p: p, onToggle: () => ss(() => obsC = !obsC)),
        const SizedBox(height: 12),
        _PassRow(label: 'New Password', ctrl: newPass, obscure: obsN, p: p, onToggle: () => ss(() => obsN = !obsN)),
        const SizedBox(height: 12),
        _PassRow(label: 'Confirm New Password', ctrl: confirm, obscure: obsF, p: p, onToggle: () => ss(() => obsF = !obsF)),
        const SizedBox(height: 16),
        GoldButton(label: 'Update Password', icon: Icons.lock_reset_outlined, onTap: () {
          if (current.text.isEmpty) { toast(ctx, 'Enter your current password'); return; }
          if (newPass.text.length < 6) { toast(ctx, 'New password must be at least 6 characters'); return; }
          if (newPass.text != confirm.text) { toast(ctx, 'Passwords do not match'); return; }
          current.clear(); newPass.clear(); confirm.clear();
          toast(ctx, 'Password updated successfully');
        }),
      ]),
    ));
  }

  Widget _sessionCard(AppPalette p) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(10), border: Border.all(color: p.border)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: p.gold.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)), child: Icon(Icons.shield_outlined, color: p.gold, size: 18)),
        const SizedBox(width: 10),
        Text('Session & Security', style: p.body(14, weight: FontWeight.w700)),
      ]),
      const SizedBox(height: 16),
      _SecRow(p: p, label: 'Auto Logout', sub: 'After 30 min inactivity', value: true, onChanged: (_) {}),
      _SecRow(p: p, label: 'Multi-Factor Authentication', sub: 'Require OTP at login', value: false, onChanged: (_) {}),
      _SecRow(p: p, label: 'Login Notifications', sub: 'Email on new device login', value: true, onChanged: (_) {}),
      _SecRow(p: p, label: 'Audit Trail Logging', sub: 'Track all system changes', value: true, onChanged: (_) {}),
      const SizedBox(height: 12),
      const Divider(height: 1),
      const SizedBox(height: 12),
      Row(children: [
        Icon(Icons.info_outline, size: 14, color: p.textMuted),
        const SizedBox(width: 8),
        Expanded(child: Text('Last login: Today, 09:14 AM — Windows 10 • Internal Network', style: p.body(11.5, color: p.textMuted))),
      ]),
    ]),
  );

  Widget _notifications(AppPalette p) => Panel(
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SectionTitle('NOTIFICATION PREFERENCES', sub: 'Control which alerts appear in the system'),
      const SizedBox(height: 16),
      Wrap(spacing: 16, runSpacing: 12, children: const [
        _NotifChip(label: 'Appointment Reminders', enabled: true),
        _NotifChip(label: 'Low Stock Alerts', enabled: true),
        _NotifChip(label: 'Payment Received', enabled: true),
        _NotifChip(label: 'New Lead Assigned', enabled: true),
        _NotifChip(label: 'Leave Approvals', enabled: false),
        _NotifChip(label: 'Daily Summary', enabled: true),
        _NotifChip(label: 'Staff Attendance', enabled: false),
        _NotifChip(label: 'Campaign Reports', enabled: true),
      ]),
    ]),
  );
}

class _PassRow extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final bool obscure;
  final AppPalette p;
  final VoidCallback onToggle;
  const _PassRow({required this.label, required this.ctrl, required this.obscure, required this.p, required this.onToggle});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: p.body(12, color: p.textMuted, weight: FontWeight.w600)),
    const SizedBox(height: 6),
    Container(
      height: 42,
      decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: p.border)),
      child: Row(children: [
        const SizedBox(width: 12),
        Icon(Icons.lock_outline, size: 16, color: p.textMuted),
        const SizedBox(width: 8),
        Expanded(child: TextField(controller: ctrl, obscureText: obscure, style: p.body(13), cursorColor: p.gold, decoration: InputDecoration(border: InputBorder.none, isCollapsed: true, hintText: '••••••••', hintStyle: p.body(13, color: p.textMuted.withValues(alpha: 0.5))))),
        GestureDetector(onTap: onToggle, child: Padding(padding: const EdgeInsets.only(right: 10), child: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 16, color: p.textMuted))),
      ]),
    ),
  ]);
}

class _SecRow extends StatefulWidget {
  final AppPalette p;
  final String label, sub;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SecRow({required this.p, required this.label, required this.sub, required this.value, required this.onChanged});
  @override
  State<_SecRow> createState() => _SecRowState();
}
class _SecRowState extends State<_SecRow> {
  late bool _val = widget.value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(widget.label, style: widget.p.body(13, weight: FontWeight.w600)),
        Text(widget.sub, style: widget.p.body(11.5, color: widget.p.textMuted)),
      ])),
      Switch(value: _val, onChanged: (v) { setState(() => _val = v); widget.onChanged(v); }, activeThumbColor: widget.p.gold, activeTrackColor: widget.p.gold.withValues(alpha: 0.3)),
    ]),
  );
}

class _NotifChip extends StatefulWidget {
  final String label;
  final bool enabled;
  const _NotifChip({required this.label, required this.enabled});
  @override
  State<_NotifChip> createState() => _NotifChipState();
}
class _NotifChipState extends State<_NotifChip> {
  late bool _on = widget.enabled;
  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    return GestureDetector(
      onTap: () => setState(() => _on = !_on),
      child: MouseRegion(cursor: SystemMouseCursors.click, child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: _on ? p.gold.withValues(alpha: 0.10) : p.surfaceAlt,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _on ? p.gold : p.border),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(_on ? Icons.notifications_active_outlined : Icons.notifications_off_outlined, size: 15, color: _on ? p.gold : p.textMuted),
          const SizedBox(width: 7),
          Text(widget.label, style: p.body(12.5, color: _on ? p.text : p.textMuted, weight: _on ? FontWeight.w600 : FontWeight.w500)),
        ]),
      )),
    );
  }
}
