import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../../../core/widgets.dart';
import '../../../core/app_data_service.dart';

class AppointmentHistoryScreen extends StatefulWidget {
  const AppointmentHistoryScreen({super.key});
  @override
  State<AppointmentHistoryScreen> createState() => _AppointmentHistoryScreenState();
}

class _AppointmentHistoryScreenState extends State<AppointmentHistoryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    appData.addListener(_onDataChange);
  }

  void _onDataChange() { if (mounted) setState(() {}); }

  @override
  void dispose() { _tab.dispose(); appData.removeListener(_onDataChange); super.dispose(); }

  void _cancelAppt(BuildContext ctx, HaAppointment appt) {
    final p = HaTheme.of(ctx);
    showDialog(context: ctx, builder: (_) => AlertDialog(
      backgroundColor: p.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Text('Cancel Appointment', style: p.body(17, weight: FontWeight.w700)),
      content: Text('Cancel ${appt.title} on ${appt.shortDate}?\n\nNote: Cancellations within 24 hrs may incur a fee.', style: p.body(14, color: p.textMuted)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Keep', style: p.body(14, color: p.textMuted))),
        TextButton(onPressed: () { Navigator.pop(ctx); appData.cancelAppointment(appt.id); },
            child: Text('Cancel Booking', style: p.body(14, color: kDanger, weight: FontWeight.w700))),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    final p = HaTheme.of(context);
    return Scaffold(
      backgroundColor: p.bg,
      appBar: KAppBar(
        title: 'My Appointments',
        showBack: true,
        onBack: () => Navigator.canPop(context) ? Navigator.of(context).maybePop() : context.go('/home'),
        actions: [IconButton(icon: const Icon(Icons.add_circle_outline), color: kGold, onPressed: () => context.push('/book'))],
      ),
      body: Column(children: [
        Container(
          color: p.surface,
          child: TabBar(
            controller: _tab,
            indicatorColor: kGold,
            labelColor: kGold,
            unselectedLabelColor: p.textMuted,
            labelStyle: p.body(14, weight: FontWeight.w600),
            unselectedLabelStyle: p.body(14),
            dividerColor: p.border,
            tabs: [
              Tab(text: 'Upcoming (${appData.upcomingCount})'),
              const Tab(text: 'Past'),
            ],
          ),
        ),
        Expanded(child: TabBarView(controller: _tab, children: [
          _ApptList(
            appts: appData.upcoming,
            showActions: true,
            emptyTitle: 'No Upcoming Appointments',
            emptySubtitle: 'Book your next appointment today.',
            onCancel: (a) => _cancelAppt(context, a),
          ),
          _ApptList(
            appts: appData.past,
            showActions: false,
            emptyTitle: 'No Past Appointments',
            emptySubtitle: 'Your treatment history will appear here.',
          ),
        ])),
      ]),
    );
  }
}

class _ApptList extends StatelessWidget {
  final List<HaAppointment> appts;
  final bool showActions;
  final String emptyTitle, emptySubtitle;
  final void Function(HaAppointment)? onCancel;
  const _ApptList({required this.appts, required this.showActions, required this.emptyTitle, required this.emptySubtitle, this.onCancel});

  @override
  Widget build(BuildContext context) {
    if (appts.isEmpty) return EmptyState(icon: Icons.calendar_today_outlined, title: emptyTitle, subtitle: emptySubtitle);
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      itemCount: appts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _ApptCard(appt: appts[i], showActions: showActions, onCancel: onCancel),
    );
  }
}

class _ApptCard extends StatelessWidget {
  final HaAppointment appt;
  final bool showActions;
  final void Function(HaAppointment)? onCancel;
  const _ApptCard({super.key, required this.appt, required this.showActions, this.onCancel});

  @override
  Widget build(BuildContext context) {
    final p = HaTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: appt.status == 'Confirmed' ? kGold.withValues(alpha: 0.25) : p.border),
        boxShadow: [if (!p.isDark) BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(appt.title, style: p.body(15, weight: FontWeight.w700))),
          StatusBadge(label: appt.status, color: appt.statusColor),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Icon(Icons.person_outline, size: 14, color: p.textMuted), const SizedBox(width: 6),
          Text(appt.doctor, style: p.body(13, color: p.textMuted)),
        ]),
        const SizedBox(height: 6),
        Row(children: [
          Icon(Icons.calendar_today_outlined, size: 14, color: p.textMuted), const SizedBox(width: 6),
          Text('${appt.dateStr}  •  ${appt.slot}', style: p.body(13, color: p.textMuted)),
        ]),
        if (showActions && appt.status != 'Cancelled') ...[
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: OutlineBtn(label: 'Cancel', onTap: () => onCancel?.call(appt), color: kDanger)),
            const SizedBox(width: 10),
            Expanded(child: GoldButton(label: 'Reschedule', onTap: () => context.push('/book'))),
          ]),
        ],
        if (appt.status == 'Completed') ...[
          const SizedBox(height: 14),
          GoldButton(label: 'Book Again', onTap: () => context.push('/book'), icon: Icons.refresh_rounded),
        ],
      ]),
    );
  }
}
