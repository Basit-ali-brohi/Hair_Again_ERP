import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../models/treatment_models.dart';

class TreatmentScreen extends StatefulWidget {
  const TreatmentScreen({super.key});
  @override
  State<TreatmentScreen> createState() => _TreatmentScreenState();
}

class _TreatmentScreenState extends State<TreatmentScreen> with SingleTickerProviderStateMixin {
  late final TabController _tab;
  @override
  void initState() { super.initState(); _tab = TabController(length: 3, vsync: this); }
  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    return ScreenScaffold(
      title: 'TREATMENT MANAGEMENT',
      subtitle: 'Treatment plans, sessions, progress tracking & patient follow-up',
      actions: [
        Container(height: 42,
          decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: p.border)),
          child: TabBar(controller: _tab, isScrollable: true, dividerColor: Colors.transparent,
            indicatorColor: p.gold, indicatorSize: TabBarIndicatorSize.label,
            labelStyle: p.body(12.5, weight: FontWeight.w600), unselectedLabelStyle: p.body(12.5),
            labelColor: p.gold, unselectedLabelColor: p.textMuted, tabAlignment: TabAlignment.start,
            tabs: const [Tab(text: 'Treatment Plans'), Tab(text: 'Sessions'), Tab(text: 'Progress Tracker')]),
        ),
      ],
      child: TabBarView(controller: _tab, children: const [
        _PlansTab(), _SessionsTab(), _ProgressTab(),
      ]),
    );
  }
}

// ── Treatment Plans ───────────────────────────────────────────────────────────
class _PlansTab extends StatefulWidget {
  const _PlansTab();
  @override
  State<_PlansTab> createState() => _PlansTabState();
}

class _PlansTabState extends State<_PlansTab> {
  String _q = '';
  TreatmentPlanStatus? _statusFilter;

  void _showDetail(TreatmentPlan plan) {
    final p = appState.palette;
    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, ss) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(width: 600, padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: p.border)),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 52, height: 52, alignment: Alignment.center,
              decoration: BoxDecoration(color: p.gold.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.spa_outlined, size: 24, color: p.gold)),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(plan.treatmentName, style: p.display(22)),
              const SizedBox(height: 4),
              Text(plan.patientName, style: p.body(13, color: p.textMuted)),
            ])),
            StatusChip(label: plan.status.label, color: _planColor(p, plan)),
            const SizedBox(width: 12),
            GestureDetector(onTap: () => Navigator.pop(ctx), child: MouseRegion(cursor: SystemMouseCursors.click, child: Icon(Icons.close, size: 20, color: p.textMuted))),
          ]),
          const SizedBox(height: 20),
          Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: appState.palette.surfaceAlt, borderRadius: BorderRadius.circular(12), border: Border.all(color: appState.palette.border)), child: Column(children: [
            _detRow(p, 'Doctor', plan.doctorName),
            _detRow(p, 'Total Sessions', '${plan.totalSessions}'),
            _detRow(p, 'Completed', '${plan.completedSessions}'),
            _detRow(p, 'Start Date', prettyShort(plan.startDate)),
            if (plan.endDate != null) _detRow(p, 'End Date', prettyShort(plan.endDate!)),
            _detRow(p, 'Total Cost', money(plan.totalCost)),
          ])),
          const SizedBox(height: 16),
          Text('PROGRESS', style: p.body(11, weight: FontWeight.w700, spacing: 1.0, color: p.textMuted)),
          const SizedBox(height: 8),
          ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: plan.progressPct, minHeight: 12, backgroundColor: p.border, color: p.gold)),
          const SizedBox(height: 4),
          Text('${(plan.progressPct * 100).toStringAsFixed(0)}% complete', style: p.body(12, color: p.textMuted)),
          if (plan.planDetails.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('PLAN DETAILS', style: p.body(11, weight: FontWeight.w700, spacing: 1.0, color: p.textMuted)),
            const SizedBox(height: 8),
            Text(plan.planDetails, style: p.body(13)),
          ],
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [GhostButton(label: 'Close', onTap: () => Navigator.pop(ctx))]),
        ]),
      ),
    )));
  }

  Color _planColor(AppPalette p, TreatmentPlan plan) => switch (plan.status) {
    TreatmentPlanStatus.active => p.success,
    TreatmentPlanStatus.completed => p.info,
    TreatmentPlanStatus.paused => p.warning,
    TreatmentPlanStatus.cancelled => p.danger,
  };

  Widget _detRow(AppPalette p, String label, String val) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(children: [
      SizedBox(width: 120, child: Text(label, style: p.body(12.5, color: p.textMuted))),
      Expanded(child: Text(val, style: p.body(13, weight: FontWeight.w500))),
    ]));

  void _showAddPlan() {
    final p = appState.palette;
    final nameCtrl = TextEditingController();
    final treatCtrl = TextEditingController();
    final docCtrl = TextEditingController();
    final detCtrl = TextEditingController();
    int sessions = 6;
    double cost = 0;
    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, ss) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(width: 540, padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: p.border)),
        child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('NEW TREATMENT PLAN', style: p.display(22, spacing: 1.0)),
          const SizedBox(height: 20),
          FormField2(label: 'Patient Name *', controller: nameCtrl, hint: 'Search or enter patient name'),
          const SizedBox(height: 14),
          FormField2(label: 'Treatment Name *', controller: treatCtrl, hint: 'e.g. PRP Therapy — 6 Session Plan'),
          const SizedBox(height: 14),
          FormField2(label: 'Assigned Doctor *', controller: docCtrl, hint: 'e.g. Dr. Sarah Ahmed'),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('TOTAL SESSIONS', style: p.body(11, weight: FontWeight.w700, spacing: 1.0, color: p.textMuted)),
              const SizedBox(height: 8),
              Row(children: [
                QtyButton(Icons.remove, () => ss(() { if (sessions > 1) sessions--; })),
                const SizedBox(width: 14),
                Text('$sessions', style: p.display(20)),
                const SizedBox(width: 14),
                QtyButton(Icons.add, () => ss(() => sessions++)),
              ]),
            ])),
            const SizedBox(width: 14),
            Expanded(child: FormField2(label: 'Total Cost (PKR)', controller: TextEditingController(text: cost == 0 ? '' : cost.toStringAsFixed(0)), hint: '0', keyboard: TextInputType.number, onChanged: (v) => cost = double.tryParse(v) ?? 0)),
          ]),
          const SizedBox(height: 14),
          FormField2(label: 'Plan Details', controller: detCtrl, hint: 'Describe the treatment protocol…', maxLines: 3),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            GhostButton(label: 'Cancel', onTap: () => Navigator.pop(ctx)),
            const SizedBox(width: 12),
            GoldButton(label: 'Create Plan', onTap: () {
              if (nameCtrl.text.isEmpty || treatCtrl.text.isEmpty) return;
              appState.addTreatmentPlan(TreatmentPlan(
                id: appState.createTreatId(), patientId: '', patientName: nameCtrl.text,
                treatmentName: treatCtrl.text, doctorName: docCtrl.text, totalSessions: sessions,
                startDate: DateTime.now(), planDetails: detCtrl.text, sessions: [],
              ));
              Navigator.pop(ctx); setState(() {});
            }),
          ]),
        ])),
      ),
    )));
  }

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    var list = appState.treatmentPlans;
    if (_q.isNotEmpty) list = list.where((t) => t.patientName.toLowerCase().contains(_q.toLowerCase()) || t.treatmentName.toLowerCase().contains(_q.toLowerCase())).toList();
    if (_statusFilter != null) list = list.where((t) => t.status == _statusFilter).toList();

    final active = appState.treatmentPlans.where((t) => t.status == TreatmentPlanStatus.active).length;
    final completed = appState.treatmentPlans.where((t) => t.status == TreatmentPlanStatus.completed).length;

    return Column(children: [
      Row(children: [
        MetricCard(title: 'Total Plans', value: '${appState.treatmentPlans.length}', icon: Icons.spa_outlined, delta: ''),
        const SizedBox(width: 14),
        MetricCard(title: 'Active', value: '$active', icon: Icons.play_circle_outline, delta: ''),
        const SizedBox(width: 14),
        MetricCard(title: 'Completed', value: '$completed', icon: Icons.check_circle_outline, delta: ''),
      ]),
      const SizedBox(height: 16),
      FilterBar(
        searchHint: 'Search by patient or treatment…',
        onSearch: (v) => setState(() => _q = v),
        filters: [
          FilterDropdown<TreatmentPlanStatus?>(value: _statusFilter, items: [const DropdownMenuItem(value: null, child: Text('All Statuses')), ...TreatmentPlanStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.label)))], onChanged: (v) => setState(() => _statusFilter = v)),
        ],
        countText: '${list.length} plans',
        onClear: () => setState(() { _q = ''; _statusFilter = null; }),
        trailing: [GoldButton(label: 'New Plan', icon: Icons.add, onTap: _showAddPlan)],
      ),
      const SizedBox(height: 12),
      Expanded(child: list.isEmpty
        ? Center(child: Text('No treatment plans found.', style: p.body(13, color: p.textMuted)))
        : ScrollArea(builder: (sc) => ListView.separated(controller: sc, padding: const EdgeInsets.only(right: 8),
            itemCount: list.length, separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _PlanCard(plan: list[i], onTap: () => _showDetail(list[i]), onUpdate: () => setState(() {}))))),
    ]);
  }
}

class _PlanCard extends StatelessWidget {
  final TreatmentPlan plan;
  final VoidCallback onTap, onUpdate;
  const _PlanCard({required this.plan, required this.onTap, required this.onUpdate});
  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final statusColor = switch (plan.status) {
      TreatmentPlanStatus.active => p.success, TreatmentPlanStatus.completed => p.info,
      TreatmentPlanStatus.paused => p.warning, TreatmentPlanStatus.cancelled => p.danger,
    };
    return MouseRegion(cursor: SystemMouseCursors.click, child: GestureDetector(onTap: onTap, child: Panel(child: Row(children: [
      Container(width: 48, height: 48, alignment: Alignment.center,
        decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
        child: Icon(Icons.spa_outlined, size: 22, color: statusColor)),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(plan.treatmentName, style: p.body(14, weight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text('${plan.patientName} · Dr. ${plan.doctorName}', style: p.body(12.5, color: p.textMuted)),
        const SizedBox(height: 8),
        ClipRRect(borderRadius: BorderRadius.circular(3), child: LinearProgressIndicator(value: plan.progressPct, minHeight: 6, backgroundColor: p.border, color: statusColor)),
        const SizedBox(height: 4),
        Text('${plan.completedSessions}/${plan.totalSessions} sessions', style: p.body(12, color: p.textMuted)),
      ])),
      const SizedBox(width: 16),
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        StatusChip(label: plan.status.label, color: statusColor),
        const SizedBox(height: 8),
        Text(money(plan.totalCost), style: p.body(13, weight: FontWeight.w700, color: p.gold)),
      ]),
    ]))));
  }
}

// ── Sessions ─────────────────────────────────────────────────────────────────
class _SessionsTab extends StatefulWidget {
  const _SessionsTab();
  @override
  State<_SessionsTab> createState() => _SessionsTabState();
}

class _SessionsTabState extends State<_SessionsTab> {
  String _q = '';
  SessionStatus? _statusFilter;

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    var allSessions = appState.treatmentPlans.expand((plan) => plan.sessions).toList();
    if (_q.isNotEmpty) allSessions = allSessions.where((s) => s.patientName.toLowerCase().contains(_q.toLowerCase()) || s.doctorName.toLowerCase().contains(_q.toLowerCase())).toList();
    if (_statusFilter != null) allSessions = allSessions.where((s) => s.status == _statusFilter).toList();
    allSessions.sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));

    return Column(children: [
      FilterBar(
        searchHint: 'Search sessions…',
        onSearch: (v) => setState(() => _q = v),
        filters: [
          FilterDropdown<SessionStatus?>(value: _statusFilter,
            items: [const DropdownMenuItem(value: null, child: Text('All Statuses')), ...SessionStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.label)))],
            onChanged: (v) => setState(() => _statusFilter = v)),
        ],
        countText: '${allSessions.length} sessions',
        onClear: () => setState(() { _q = ''; _statusFilter = null; }),
      ),
      const SizedBox(height: 12),
      Expanded(child: Panel(padding: EdgeInsets.zero, child: ScrollArea(builder: (sc) => SingleChildScrollView(controller: sc, child: FullWidthDataTable(child: DataTable(
        headingRowColor: WidgetStateProperty.all(p.surfaceAlt),
        columnSpacing: 20, horizontalMargin: 20,
        columns: ['#', 'Patient', 'Doctor', 'Scheduled Date', 'Cost', 'Status'].map((t) => DataColumn(label: Text(t, style: p.body(12, weight: FontWeight.w700)))).toList(),
        rows: allSessions.map((s) => DataRow(cells: [
          DataCell(Text('#${s.sessionNumber}', style: p.body(13, weight: FontWeight.w600, color: p.gold))),
          DataCell(Text(s.patientName, style: p.body(12.5))),
          DataCell(Text(s.doctorName, style: p.body(12.5))),
          DataCell(Text(prettyShort(s.scheduledDate), style: p.body(12.5))),
          DataCell(Text(money(s.cost), style: p.body(12.5))),
          DataCell(StatusChip(label: s.status.label, color: _sessionColor(p, s.status))),
        ])).toList(),
      )))))),
    ]);
  }

  Color _sessionColor(AppPalette p, SessionStatus s) => switch (s) {
    SessionStatus.scheduled => p.info, SessionStatus.completed => p.success,
    SessionStatus.missed => p.danger, SessionStatus.rescheduled => p.warning,
  };
}

// ── Progress Tracker ──────────────────────────────────────────────────────────
class _ProgressTab extends StatefulWidget {
  const _ProgressTab();
  @override
  State<_ProgressTab> createState() => _ProgressTabState();
}

class _ProgressTabState extends State<_ProgressTab> {
  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final plans = appState.treatmentPlans.where((t) => t.status == TreatmentPlanStatus.active).toList();
    return ScrollArea(builder: (sc) => ListView.separated(
      controller: sc, padding: const EdgeInsets.only(right: 8),
      itemCount: plans.isEmpty ? 1 : plans.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (_, i) {
        if (plans.isEmpty) return Center(child: Text('No active treatment plans.', style: p.body(13, color: p.textMuted)));
        final plan = plans[i];
        final next = plan.nextSession;
        return Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(plan.treatmentName, style: p.body(15, weight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text('${plan.patientName} · Dr. ${plan.doctorName}', style: p.body(12.5, color: p.textMuted)),
            ])),
            Text('${(plan.progressPct * 100).toStringAsFixed(0)}%', style: p.display(22, color: p.gold)),
          ]),
          const SizedBox(height: 16),
          ClipRRect(borderRadius: BorderRadius.circular(6), child: LinearProgressIndicator(value: plan.progressPct, minHeight: 16, backgroundColor: p.border, color: p.gold)),
          const SizedBox(height: 8),
          Text('${plan.completedSessions} of ${plan.totalSessions} sessions completed', style: p.body(12.5, color: p.textMuted)),
          if (next != null) ...[
            const SizedBox(height: 14),
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(8)),
              child: Row(children: [
                Icon(Icons.event_outlined, size: 16, color: p.gold), const SizedBox(width: 10),
                Text('Next: Session #${next.sessionNumber} — ${prettyShort(next.scheduledDate)}', style: p.body(13, weight: FontWeight.w500)),
              ])),
          ],
          if (plan.progressNotes.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text('NOTES', style: p.body(11, weight: FontWeight.w700, spacing: 1.0, color: p.textMuted)),
            const SizedBox(height: 6),
            Text(plan.progressNotes, style: p.body(12.5, color: p.textMuted)),
          ],
        ]));
      },
    ));
  }
}
