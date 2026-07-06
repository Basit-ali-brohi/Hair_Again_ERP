import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../core/staff_data.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _tab = 0; // bottom nav index
  late Timer _clockTimer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    staffData.addListener(_onData);
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  void _onData() { if (mounted) setState(() {}); }

  @override
  void dispose() { staffData.removeListener(_onData); _clockTimer.cancel(); super.dispose(); }

  List<(IconData, IconData, String)> get _navItems => staffData.role == StaffRole.doctor
      ? [
          (Icons.dashboard_rounded,          Icons.dashboard_outlined,             'Home'),
          (Icons.calendar_month_rounded,     Icons.calendar_month_outlined,        'Schedule'),
          (Icons.people_rounded,             Icons.people_outline_rounded,         'Patients'),
          (Icons.medical_information_rounded,Icons.medical_information_outlined,   'Consult'),
          (Icons.person_rounded,             Icons.person_outline_rounded,         'Profile'),
        ]
      : [
          (Icons.dashboard_rounded,      Icons.dashboard_outlined,      'Home'),
          (Icons.calendar_month_rounded, Icons.calendar_month_outlined, 'Schedule'),
          (Icons.people_rounded,         Icons.people_outline_rounded,  'Patients'),
          (Icons.point_of_sale_rounded,  Icons.point_of_sale_outlined,  'POS'),
          (Icons.person_rounded,         Icons.person_outline_rounded,  'Profile'),
        ];

  List<String> get _navRoutes => staffData.role == StaffRole.doctor
      ? ['/dashboard', '/appointments', '/patients', '/consultation', '/profile']
      : ['/dashboard', '/appointments', '/patients', '/pos', '/profile'];

  @override
  Widget build(BuildContext context) {
    final p = HaTheme.of(context);
    final unread = staffData.unreadCount;

    return Scaffold(
      backgroundColor: p.bg,
      body: _DashboardBody(p: p, now: _now),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: p.surface, border: Border(top: BorderSide(color: p.border))),
        child: SafeArea(
          child: SizedBox(
            height: 64,
            child: Row(children: List.generate(_navItems.length, (i) {
              final item = _navItems[i];
              final sel = i == _tab;
              return Expanded(child: GestureDetector(
                onTap: () {
                  setState(() => _tab = i);
                  if (_navRoutes[i] != '/dashboard') context.push(_navRoutes[i]);
                },
                behavior: HitTestBehavior.opaque,
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Stack(clipBehavior: Clip.none, children: [
                    Icon(sel ? item.$1 : item.$2, color: sel ? kGold : p.textMuted, size: 24),
                    if (i == 0 && unread > 0)
                      Positioned(top: -4, right: -6, child: Container(
                        width: 14, height: 14,
                        decoration: const BoxDecoration(color: kDanger, shape: BoxShape.circle),
                        child: Center(child: Text('$unread', style: const TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.w800))),
                      )),
                  ]),
                  const SizedBox(height: 3),
                  Text(item.$3, style: TextStyle(fontSize: 10, color: sel ? kGold : p.textMuted, fontWeight: sel ? FontWeight.w700 : FontWeight.w400)),
                ]),
              ));
            })),
          ),
        ),
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  final AppPalette p;
  final DateTime now;
  const _DashboardBody({required this.p, required this.now});

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final upcoming = staffData.todayAppointments.where((a) => a.status == 'Scheduled' || a.status == 'Checked In').take(3).toList();

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Hero
        SliverToBoxAdapter(child: _HeroHeader(p: p, topPad: topPad, now: now)),

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
          sliver: SliverList(delegate: SliverChildListDelegate([

            // Stat cards 2×2
            const SizedBox(height: 24),
            Row(children: [
              Expanded(child: StatCard(label: "Today's Appointments", value: '${staffData.todayCount}',    icon: Icons.calendar_today_rounded,  color: kGold,    onTap: () => context.push('/appointments'))),
              const SizedBox(width: 12),
              Expanded(child: StatCard(label: 'Checked In',           value: '${staffData.checkedInCount}',icon: Icons.login_rounded,            color: kWarning, onTap: () => context.push('/appointments'))),
            ]).animate().fadeIn(delay: 100.ms, duration: 350.ms).slideY(begin: 0.06, end: 0),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: StatCard(label: 'Completed', value: '${staffData.completedTodayCount}', icon: Icons.check_circle_rounded, color: kSuccess, onTap: () => context.push('/appointments'))),
              const SizedBox(width: 12),
              if (staffData.role.canViewRevenue)
                Expanded(child: StatCard(label: "Today's Revenue", value: 'Rs ${NumberFormat('#,###').format(staffData.todayRevenue.toInt())}', icon: Icons.payments_rounded, color: kInfo, onTap: () => context.push('/pos')))
              else
                Expanded(child: StatCard(label: 'Pending', value: '${staffData.pendingCount}', icon: Icons.pending_actions_rounded, color: const Color(0xFF9B59B6), onTap: () => context.push('/appointments'))),
            ]).animate().fadeIn(delay: 160.ms, duration: 350.ms).slideY(begin: 0.06, end: 0),
            const SizedBox(height: 28),

            // Clock in/out
            _ClockWidget(p: p).animate().fadeIn(delay: 200.ms, duration: 350.ms),
            const SizedBox(height: 28),

            // Upcoming appointments
            SectionHeader(title: "Today's Schedule", action: 'View All', onAction: () => context.push('/appointments')),
            const SizedBox(height: 14),
            if (upcoming.isEmpty)
              const EmptyState(icon: Icons.event_available_rounded, title: 'All Done!', subtitle: 'No more appointments today.')
            else
              ...upcoming.map((a) => _ApptRow(appt: a, p: p, onAction: () => context.push('/appointments')))
                  .toList().asMap().entries.map((e) =>
                      e.value.animate().fadeIn(delay: (240 + e.key * 60).ms, duration: 300.ms)),
            const SizedBox(height: 28),

            // Quick actions
            SectionHeader(title: 'Quick Actions'),
            const SizedBox(height: 14),
            Builder(builder: (ctx) {
              final role = staffData.role;
              final actions = [
                if (role.canBookAppt)
                  _QuickAction(icon: Icons.add_circle_rounded,          label: 'Book Appt',    color: kGold,                    onTap: () => ctx.push('/book-appointment')),
                _QuickAction(icon: Icons.person_search_rounded,         label: 'Find Patient', color: kInfo,                    onTap: () => ctx.push('/patients')),
                if (role.canAccessPOS)
                  _QuickAction(icon: Icons.receipt_long_rounded,        label: 'New Bill',     color: kSuccess,                 onTap: () => ctx.push('/pos')),
                if (role.canConsult)
                  _QuickAction(icon: Icons.medical_information_rounded, label: 'Consult',      color: const Color(0xFF9B59B6),  onTap: () => ctx.push('/consultation')),
                _QuickAction(icon: Icons.notifications_rounded,         label: 'Alerts',       color: kWarning,                 onTap: () => ctx.push('/notifications')),
                _QuickAction(icon: Icons.fingerprint_rounded,           label: 'Attendance',   color: kDanger,                  onTap: () => ctx.push('/attendance')),
              ];
              return GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12, mainAxisSpacing: 12,
                childAspectRatio: 1.1,
                children: actions,
              );
            }).animate().fadeIn(delay: 360.ms, duration: 350.ms),
          ])),
        ),
      ],
    );
  }
}

class _HeroHeader extends StatelessWidget {
  final AppPalette p;
  final double topPad;
  final DateTime now;
  const _HeroHeader({required this.p, required this.topPad, required this.now});

  String get _greeting {
    final h = now.hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.fromLTRB(20, topPad + 18, 20, 24),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: p.isDark
            ? [const Color(0xFF0E0E12), const Color(0xFF1A1500), const Color(0xFF0E0E12)]
            : [const Color(0xFFFBF9F5), const Color(0xFFF5EDD8), const Color(0xFFFBF9F5)],
        stops: const [0.0, 0.5, 1.0],
        begin: Alignment.topLeft, end: Alignment.bottomRight,
      ),
      border: Border(bottom: BorderSide(color: p.border)),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('$_greeting,', style: p.body(13, color: p.textMuted)),
          Text(staffData.staffName, style: p.display(24)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(color: kGold.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20), border: Border.all(color: kGold.withValues(alpha: 0.3))),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(staffData.role.icon, size: 12, color: kGold),
              const SizedBox(width: 5),
              Text(staffData.role.label, style: p.body(11, color: kGold, weight: FontWeight.w600)),
            ]),
          ),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          // Notification bell
          GestureDetector(
            onTap: () => context.push('/notifications'),
            child: Stack(children: [
              Container(width: 44, height: 44,
                decoration: BoxDecoration(color: kGold.withValues(alpha: 0.1), shape: BoxShape.circle, border: Border.all(color: kGold.withValues(alpha: 0.2))),
                child: const Icon(Icons.notifications_rounded, color: kGold, size: 22)),
              if (staffData.unreadCount > 0) Positioned(top: 8, right: 8, child: Container(
                width: 8, height: 8,
                decoration: const BoxDecoration(color: kDanger, shape: BoxShape.circle),
              )),
            ]),
          ),
          const SizedBox(height: 6),
          // Clock
          Text(DateFormat('hh:mm a').format(now), style: p.body(13, color: kGold, weight: FontWeight.w700)),
          Text(DateFormat('EEE, d MMM').format(now), style: p.body(11, color: p.textMuted)),
        ]),
      ]),
    ]),
  );
}

class _ClockWidget extends StatelessWidget {
  final AppPalette p;
  const _ClockWidget({required this.p});

  @override
  Widget build(BuildContext context) {
    final clocked = staffData.clockedIn;
    final since = staffData.clockInTime;
    String duration = '';
    if (clocked && since != null) {
      final diff = DateTime.now().difference(since);
      final h = diff.inHours;
      final m = diff.inMinutes % 60;
      duration = '${h}h ${m}m';
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: clocked ? kSuccess.withValues(alpha: 0.35) : p.border),
        boxShadow: [if (clocked) BoxShadow(color: kSuccess.withValues(alpha: 0.08), blurRadius: 16)],
      ),
      child: Row(children: [
        Container(width: 48, height: 48,
          decoration: BoxDecoration(
            color: (clocked ? kSuccess : p.surfaceAlt).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(clocked ? Icons.timer_rounded : Icons.timer_off_rounded,
              color: clocked ? kSuccess : p.textMuted, size: 24)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(clocked ? 'Currently Working' : 'Not Clocked In', style: p.body(14, weight: FontWeight.w700)),
          Text(clocked ? 'Duration: $duration' : 'Tap to start your shift', style: p.body(12, color: p.textMuted)),
        ])),
        GestureDetector(
          onTap: () => clocked ? staffData.clockOut() : staffData.clockIn(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: clocked ? null : kGoldGradient,
              color: clocked ? kDanger.withValues(alpha: 0.1) : null,
              borderRadius: BorderRadius.circular(12),
              border: clocked ? Border.all(color: kDanger.withValues(alpha: 0.4)) : null,
            ),
            child: Text(clocked ? 'Clock Out' : 'Clock In',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: clocked ? kDanger : Colors.black87)),
          ),
        ),
      ]),
    );
  }
}

class _ApptRow extends StatelessWidget {
  final StaffAppointment appt;
  final AppPalette p;
  final VoidCallback onAction;
  const _ApptRow({required this.appt, required this.p, required this.onAction});

  @override
  Widget build(BuildContext context) => PressableCard(
    onTap: onAction,
    child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: p.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: p.border),
        boxShadow: [if (!p.isDark) BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6)],
      ),
      child: Row(children: [
        Container(width: 44, height: 44,
          decoration: BoxDecoration(
            color: appt.statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(appt.statusIcon, color: appt.statusColor, size: 20)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(appt.patientName, style: p.body(14, weight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(appt.service, style: p.body(12, color: p.textMuted), overflow: TextOverflow.ellipsis),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(appt.timeStr, style: p.body(13, color: kGold, weight: FontWeight.w700)),
          const SizedBox(height: 4),
          StatusBadge(label: appt.status, color: appt.statusColor),
        ]),
      ]),
    ),
  );
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = HaTheme.of(context);
    return PressableCard(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: p.surface, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.06), blurRadius: 8)],
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(width: 44, height: 44,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: color, size: 22)),
          const SizedBox(height: 8),
          Text(label, style: p.body(11, weight: FontWeight.w600, color: p.isDark ? Colors.white70 : p.textMuted), textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}
