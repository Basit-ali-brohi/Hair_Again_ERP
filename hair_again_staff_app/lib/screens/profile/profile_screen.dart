import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../core/staff_data.dart';

class StaffProfileScreen extends StatefulWidget {
  const StaffProfileScreen({super.key});
  @override
  State<StaffProfileScreen> createState() => _StaffProfileScreenState();
}

class _StaffProfileScreenState extends State<StaffProfileScreen> {
  @override
  void initState() { super.initState(); staffData.addListener(_onData); }
  void _onData() { if (mounted) setState(() {}); }
  @override
  void dispose() { staffData.removeListener(_onData); super.dispose(); }

  void _logout() {
    final p = HaTheme.of(context);
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: p.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Text('Sign Out', style: p.body(17, weight: FontWeight.w700)),
      content: Text('Are you sure you want to sign out?', style: p.body(14, color: p.textMuted)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: p.body(14, color: p.textMuted))),
        TextButton(onPressed: () { Navigator.pop(context); staffData.logout(); context.go('/login'); },
            child: Text('Sign Out', style: p.body(14, color: kDanger, weight: FontWeight.w700))),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    final p = HaTheme.of(context);
    final isDark = appNotifier.isDark;

    return Scaffold(
      backgroundColor: p.bg,
      appBar: const StaffAppBar(title: 'Profile', showBack: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
        child: Column(children: [

          // Avatar + info
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: p.isDark
                    ? [const Color(0xFF0E0E12), const Color(0xFF1A1500)]
                    : [const Color(0xFFFBF9F5), const Color(0xFFF5EDD8)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: kGold.withValues(alpha: 0.2)),
            ),
            child: Row(children: [
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(gradient: kGoldGradient, shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: kGold.withValues(alpha: 0.3), blurRadius: 16)]),
                child: Center(child: Text(staffData.staffInitials, style: p.display(24, color: Colors.black87))),
              ),
              const SizedBox(width: 18),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(staffData.staffName, style: p.display(20)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: kGold.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20), border: Border.all(color: kGold.withValues(alpha: 0.3))),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(staffData.role.icon, size: 13, color: kGold),
                    const SizedBox(width: 5),
                    Text(staffData.role.label, style: p.body(11, color: kGold, weight: FontWeight.w600)),
                  ]),
                ),
                const SizedBox(height: 6),
                Text('Hair Again Clinic — Karachi', style: p.body(12, color: p.textMuted)),
              ])),
            ]),
          ),
          const SizedBox(height: 28),

          // Today's summary
          Text('Today', style: p.body(15, weight: FontWeight.w700), textAlign: TextAlign.left),
          const Align(alignment: Alignment.centerLeft, child: SizedBox()),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _MiniStat('Appointments', '${staffData.todayCount}', Icons.calendar_today_rounded, kGold, p)),
            const SizedBox(width: 10),
            Expanded(child: _MiniStat('Completed', '${staffData.completedTodayCount}', Icons.check_circle_rounded, kSuccess, p)),
            const SizedBox(width: 10),
            Expanded(child: _MiniStat('Clocked', staffData.clockedIn ? 'Yes' : 'No', Icons.timer_rounded, staffData.clockedIn ? kSuccess : p.textMuted, p)),
          ]),
          const SizedBox(height: 28),

          // Settings tiles
          _SettingsGroup(p: p, children: [
            _Tile(Icons.dark_mode_rounded, isDark ? 'Dark Mode' : 'Light Mode', 'Appearance',
                trailing: Switch(value: isDark, onChanged: (_) => setState(() => appNotifier.toggleTheme()), activeThumbColor: kGold, activeTrackColor: kGold.withValues(alpha: 0.3)),
                onTap: () => setState(() => appNotifier.toggleTheme()), p: p),
            _Tile(Icons.notifications_rounded, 'Notifications', 'Alerts & reminders',
                onTap: () => context.push('/notifications'), p: p),
            _Tile(Icons.fingerprint_rounded, 'Attendance', 'Clock in / out & history',
                onTap: () => context.push('/attendance'), p: p),
          ]),
          const SizedBox(height: 16),

          _SettingsGroup(p: p, children: [
            _Tile(Icons.lock_outline_rounded, 'Change Password', 'Update your password', onTap: () {}, p: p),
            _Tile(Icons.devices_rounded, 'Active Sessions', 'Manage logged-in devices', onTap: () {}, p: p),
            _Tile(Icons.help_outline_rounded, 'Help & Support', 'Contact HR or IT', onTap: () {}, p: p),
          ]),
          const SizedBox(height: 24),

          OutlineBtn(label: 'Sign Out', onTap: _logout, color: kDanger, icon: Icons.logout_rounded),
          const SizedBox(height: 12),
          Text('Hair Again Staff Portal v1.0', style: p.body(11, color: p.textMuted)),
        ]),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  final AppPalette p;
  const _MiniStat(this.label, this.value, this.icon, this.color, this.p);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
    decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: p.border)),
    child: Column(children: [
      Icon(icon, color: color, size: 22),
      const SizedBox(height: 6),
      Text(value, style: p.body(16, color: color, weight: FontWeight.w800)),
      const SizedBox(height: 2),
      Text(label, style: p.body(10, color: p.textMuted), textAlign: TextAlign.center),
    ]),
  );
}

class _SettingsGroup extends StatelessWidget {
  final AppPalette p;
  final List<Widget> children;
  const _SettingsGroup({required this.p, required this.children});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: p.border)),
    child: Column(children: children.asMap().entries.map((e) {
      final last = e.key == children.length - 1;
      return Column(children: [
        e.value,
        if (!last) Divider(height: 1, color: p.border, indent: 54),
      ]);
    }).toList()),
  );
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final VoidCallback onTap;
  final Widget? trailing;
  final AppPalette p;
  const _Tile(this.icon, this.title, this.subtitle, {required this.onTap, this.trailing, required this.p});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(children: [
        Container(width: 38, height: 38,
          decoration: BoxDecoration(color: kGold.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(11)),
          child: Icon(icon, size: 18, color: kGold)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: p.body(14, weight: FontWeight.w600)),
          Text(subtitle, style: p.body(11, color: p.textMuted)),
        ])),
        trailing ?? Icon(Icons.chevron_right_rounded, color: p.textMuted, size: 18),
      ]),
    ),
  );
}
