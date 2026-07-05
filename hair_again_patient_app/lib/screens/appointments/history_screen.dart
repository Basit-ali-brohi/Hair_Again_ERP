import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../../../core/widgets.dart';

class AppointmentHistoryScreen extends StatefulWidget {
  const AppointmentHistoryScreen({super.key});
  @override
  State<AppointmentHistoryScreen> createState() => _AppointmentHistoryScreenState();
}

class _AppointmentHistoryScreenState extends State<AppointmentHistoryScreen> with SingleTickerProviderStateMixin {
  late final TabController _tab;
  @override
  void initState() { super.initState(); _tab = TabController(length: 2, vsync: this); }
  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  static const _upcoming = [
    _Appt('Hair Transplant Consultation', 'Dr. Bilal Khan', 'Mon, 7 Jul 2026', '11:00 AM', 'Confirmed', kSuccess),
    _Appt('PRP Therapy', 'Dr. Sara Malik', 'Fri, 18 Jul 2026', '02:00 PM', 'Pending', kWarning),
  ];

  static const _past = [
    _Appt('Scalp Analysis', 'Dr. Omar Farooq', 'Sat, 14 Jun 2026', '10:00 AM', 'Completed', kSuccess),
    _Appt('Hair Loss Consultation', 'Dr. Bilal Khan', 'Mon, 2 Jun 2026', '11:30 AM', 'Completed', kSuccess),
    _Appt('LLLT Session', 'Dr. Sara Malik', 'Wed, 21 May 2026', '03:00 PM', 'Cancelled', kDanger),
    _Appt('PRP Therapy', 'Dr. Bilal Khan', 'Sat, 3 May 2026', '09:00 AM', 'Completed', kSuccess),
  ];

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
            tabs: const [Tab(text: 'Upcoming'), Tab(text: 'Past')],
          ),
        ),
        Expanded(child: TabBarView(controller: _tab, children: [
          _AppointmentList(appts: _upcoming, showActions: true),
          _AppointmentList(appts: _past, showActions: false),
        ])),
      ]),
    );
  }
}

class _Appt {
  final String title, doctor, date, time, status;
  final Color statusColor;
  const _Appt(this.title, this.doctor, this.date, this.time, this.status, this.statusColor);
}

class _AppointmentList extends StatelessWidget {
  final List<_Appt> appts;
  final bool showActions;
  const _AppointmentList({required this.appts, required this.showActions});

  @override
  Widget build(BuildContext context) {
    if (appts.isEmpty) return const EmptyState(icon: Icons.calendar_today_outlined, title: 'No Appointments', subtitle: 'Book your first appointment today.');
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      itemCount: appts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _ApptCard(appt: appts[i], showActions: showActions),
    );
  }
}

class _ApptCard extends StatelessWidget {
  final _Appt appt;
  final bool showActions;
  const _ApptCard({super.key, required this.appt, required this.showActions});

  @override
  Widget build(BuildContext context) {
    final p = HaTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: p.border),
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
          Text('${appt.date}  •  ${appt.time}', style: p.body(13, color: p.textMuted)),
        ]),
        if (showActions && appt.status != 'Cancelled') ...[
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: OutlineBtn(label: 'Cancel', onTap: () {})),
            const SizedBox(width: 10),
            Expanded(child: GoldButton(label: 'Reschedule', onTap: () => context.push('/book'))),
          ]),
        ],
      ]),
    );
  }
}
