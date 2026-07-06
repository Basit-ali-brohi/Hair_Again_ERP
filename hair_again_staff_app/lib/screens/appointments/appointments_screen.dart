import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../core/staff_data.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});
  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    staffData.addListener(_onData);
  }

  void _onData() { if (mounted) setState(() {}); }

  @override
  void dispose() { _tab.dispose(); staffData.removeListener(_onData); super.dispose(); }

  void _showActions(BuildContext ctx, StaffAppointment appt) {
    final p = HaTheme.of(ctx);
    showModalBottomSheet(
      context: ctx,
      backgroundColor: p.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: p.border, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 20),
          Text(appt.patientName, style: p.body(18, weight: FontWeight.w800)),
          Text('${appt.service} • ${appt.timeStr}', style: p.body(13, color: p.textMuted)),
          const SizedBox(height: 24),
          if (appt.status == 'Scheduled') ...[
            _ActionTile(icon: Icons.login_rounded, label: 'Check In Patient', color: kSuccess, onTap: () { Navigator.pop(ctx); staffData.checkIn(appt.id); }),
            const SizedBox(height: 10),
          ],
          if (appt.status == 'Checked In') ...[
            _ActionTile(icon: Icons.medical_information_rounded, label: 'Start Consultation', color: const Color(0xFF9B59B6),
                onTap: () { Navigator.pop(ctx); ctx.push('/consultation', extra: appt.id); }),
            const SizedBox(height: 10),
            _ActionTile(icon: Icons.check_circle_rounded, label: 'Mark Completed', color: kSuccess,
                onTap: () { Navigator.pop(ctx); staffData.checkOut(appt.id); }),
            const SizedBox(height: 10),
          ],
          if (appt.status != 'Completed' && appt.status != 'Cancelled')
            _ActionTile(icon: Icons.cancel_rounded, label: 'Cancel Appointment', color: kDanger,
                onTap: () { Navigator.pop(ctx); _confirmCancel(ctx, appt); }),
        ]),
      ),
    );
  }

  void _confirmCancel(BuildContext ctx, StaffAppointment appt) {
    final p = HaTheme.of(ctx);
    showDialog(context: ctx, builder: (_) => AlertDialog(
      backgroundColor: p.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Text('Cancel Appointment', style: p.body(17, weight: FontWeight.w700)),
      content: Text('Cancel ${appt.patientName}\'s ${appt.service} at ${appt.timeStr}?', style: p.body(14, color: p.textMuted)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Keep', style: p.body(14, color: p.textMuted))),
        TextButton(onPressed: () { Navigator.pop(ctx); staffData.cancelAppt(appt.id); },
            child: Text('Cancel', style: p.body(14, color: kDanger, weight: FontWeight.w700))),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    final p = HaTheme.of(context);
    final today = staffData.todayAppointments;
    final upcoming = staffData.allAppointments
        .where((a) => !a.isToday && a.dateTime.isAfter(DateTime.now()))
        .toList()..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    return Scaffold(
      backgroundColor: p.bg,
      appBar: StaffAppBar(
        title: 'Appointments',
        actions: [
          IconButton(icon: const Icon(Icons.add_circle_outline_rounded, color: kGold), onPressed: () => context.push('/book-appointment')),
        ],
      ),
      body: Column(children: [
        Container(
          color: p.surface,
          child: TabBar(
            controller: _tab,
            indicatorColor: kGold, labelColor: kGold, unselectedLabelColor: p.textMuted,
            labelStyle: p.body(14, weight: FontWeight.w600),
            unselectedLabelStyle: p.body(14),
            dividerColor: p.border,
            tabs: [
              Tab(text: 'Today (${today.length})'),
              Tab(text: 'Upcoming (${upcoming.length})'),
            ],
          ),
        ),
        Expanded(child: TabBarView(controller: _tab, children: [
          _ApptList(appts: today, p: p, onTap: (a) => _showActions(context, a),
              empty: const EmptyState(icon: Icons.event_available_rounded, title: 'No Appointments Today', subtitle: 'Enjoy the quiet day!')),
          _ApptList(appts: upcoming, p: p, onTap: (a) => _showActions(context, a),
              empty: const EmptyState(icon: Icons.upcoming_rounded, title: 'No Upcoming Appointments', subtitle: 'Schedule is clear ahead.')),
        ])),
      ]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/book-appointment'),
        backgroundColor: kGold,
        foregroundColor: Colors.black87,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Book', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _ApptList extends StatelessWidget {
  final List<StaffAppointment> appts;
  final AppPalette p;
  final void Function(StaffAppointment) onTap;
  final Widget empty;
  const _ApptList({required this.appts, required this.p, required this.onTap, required this.empty});

  @override
  Widget build(BuildContext context) {
    if (appts.isEmpty) return empty;
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      itemCount: appts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _ApptCard(appt: appts[i], p: p, onTap: () => onTap(appts[i]))
          .animate().fadeIn(delay: (i * 50).ms, duration: 280.ms).slideX(begin: 0.04, end: 0),
    );
  }
}

class _ApptCard extends StatelessWidget {
  final StaffAppointment appt;
  final AppPalette p;
  final VoidCallback onTap;
  const _ApptCard({required this.appt, required this.p, required this.onTap});

  @override
  Widget build(BuildContext context) => PressableCard(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: p.surface, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: appt.status == 'Checked In' ? kWarning.withValues(alpha: 0.35) : p.border),
        boxShadow: [if (!p.isDark) BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Row(children: [
        Container(width: 52, height: 52,
          decoration: BoxDecoration(
            color: appt.statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(appt.statusIcon, color: appt.statusColor, size: 24)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(appt.patientName, style: p.body(15, weight: FontWeight.w700)),
          const SizedBox(height: 3),
          Text(appt.service, style: p.body(12, color: p.textMuted), overflow: TextOverflow.ellipsis),
          const SizedBox(height: 3),
          Row(children: [
            Icon(Icons.person_outline_rounded, size: 12, color: p.textMuted), const SizedBox(width: 3),
            Flexible(child: Text(appt.doctor, style: p.body(11, color: p.textMuted), overflow: TextOverflow.ellipsis)),
          ]),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(appt.timeStr, style: p.body(14, color: kGold, weight: FontWeight.w800)),
          const SizedBox(height: 6),
          StatusBadge(label: appt.status, color: appt.statusColor),
          const SizedBox(height: 6),
          Icon(Icons.chevron_right_rounded, color: p.textMuted, size: 18),
        ]),
      ]),
    ),
  );
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionTile({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = HaTheme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(children: [
          Icon(icon, color: color, size: 22), const SizedBox(width: 14),
          Text(label, style: p.body(14, color: color, weight: FontWeight.w600)),
          const Spacer(),
          Icon(Icons.chevron_right_rounded, color: color, size: 18),
        ]),
      ),
    );
  }
}
