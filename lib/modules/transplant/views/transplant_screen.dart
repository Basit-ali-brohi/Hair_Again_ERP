import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../models/transplant_models.dart';

class TransplantScreen extends StatefulWidget {
  const TransplantScreen({super.key});
  @override
  State<TransplantScreen> createState() => _TransplantScreenState();
}

class _TransplantScreenState extends State<TransplantScreen> with SingleTickerProviderStateMixin {
  late final TabController _tab;
  @override
  void initState() { super.initState(); _tab = TabController(length: 3, vsync: this); }
  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    return ScreenScaffold(
      title: 'HAIR TRANSPLANT',
      subtitle: 'Surgery cases, post-op follow-ups & surgical outcome tracking',
      actions: [
        Container(height: 42,
          decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: p.border)),
          child: TabBar(controller: _tab, isScrollable: true, dividerColor: Colors.transparent,
            indicatorColor: p.gold, indicatorSize: TabBarIndicatorSize.label,
            labelStyle: p.body(12.5, weight: FontWeight.w600), unselectedLabelStyle: p.body(12.5),
            labelColor: p.gold, unselectedLabelColor: p.textMuted, tabAlignment: TabAlignment.start,
            tabs: const [Tab(text: 'Surgery Cases'), Tab(text: 'Scheduled'), Tab(text: 'Post-Op Follow-Up')]),
        ),
      ],
      child: EagerTabBarView(controller: _tab, children: const [
        _CasesTab(), _ScheduledTab(), _PostOpTab(),
      ]),
    );
  }
}

Color _surgeryColor(AppPalette p, SurgeryStatus s) => switch (s) {
  SurgeryStatus.scheduled => p.info, SurgeryStatus.inProgress => p.warning,
  SurgeryStatus.completed => p.success, SurgeryStatus.postponed => p.textMuted,
  SurgeryStatus.cancelled => p.danger,
};

// ── Cases Tab ─────────────────────────────────────────────────────────────────
class _CasesTab extends StatefulWidget {
  const _CasesTab();
  @override
  State<_CasesTab> createState() => _CasesTabState();
}

class _CasesTabState extends State<_CasesTab> {
  String _q = '';
  SurgeryStatus? _statusFilter;
  TransplantTechnique? _techFilter;

  void _showDetail(TransplantCase tc) {
    final p = appState.palette;
    showDialog(context: context, builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(width: 640, padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: p.border)),
        child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 52, height: 52, alignment: Alignment.center,
              decoration: BoxDecoration(color: p.gold.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.content_cut_outlined, size: 24, color: p.gold)),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(tc.patientName, style: p.display(22)),
              Text('${tc.technique.label} · Norwood Scale ${tc.norwoodScale}', style: p.body(13, color: p.textMuted)),
            ])),
            StatusChip(label: tc.status.label, color: _surgeryColor(p, tc.status)),
            const SizedBox(width: 12),
            GestureDetector(onTap: () => Navigator.pop(ctx), child: MouseRegion(cursor: SystemMouseCursors.click, child: Icon(Icons.close, size: 20, color: p.textMuted))),
          ]),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(12), border: Border.all(color: p.border)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('SURGICAL DETAILS', style: p.body(11, weight: FontWeight.w700, spacing: 1.0, color: p.textMuted)),
              const SizedBox(height: 12),
              _detRow(p, 'Surgeon', tc.surgeonName),
              _detRow(p, 'Assistant', tc.assistantName),
              _detRow(p, 'Surgery Date', prettyShort(tc.surgeryDate)),
              _detRow(p, 'Technique', tc.technique.label),
              _detRow(p, 'Donor Area', tc.donorArea),
              _detRow(p, 'Recipient Area', tc.recipientArea),
            ]))),
            const SizedBox(width: 12),
            Expanded(child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(12), border: Border.all(color: p.border)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('GRAFT COUNTS', style: p.body(11, weight: FontWeight.w700, spacing: 1.0, color: p.textMuted)),
              const SizedBox(height: 12),
              _detRow(p, 'Extracted', '${tc.graftsExtracted}'),
              _detRow(p, 'Implanted', '${tc.graftsImplanted}'),
              _detRow(p, 'Survival Rate', '~${tc.survivalRateEstimate.toStringAsFixed(0)}%'),
              _detRow(p, 'Follow-ups', '${tc.followUps.length}'),
              _detRow(p, 'Procedure Cost', money(tc.procedureCost)),
            ]))),
          ]),
          if (tc.preOpNotes.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text('PRE-OP NOTES', style: p.body(11, weight: FontWeight.w700, spacing: 1.0, color: p.textMuted)),
            const SizedBox(height: 6),
            Text(tc.preOpNotes, style: p.body(13)),
          ],
          if (tc.postOpNotes.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text('POST-OP NOTES', style: p.body(11, weight: FontWeight.w700, spacing: 1.0, color: p.textMuted)),
            const SizedBox(height: 6),
            Text(tc.postOpNotes, style: p.body(13)),
          ],
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [GhostButton(label: 'Close', onTap: () => Navigator.pop(ctx))]),
        ])),
      ),
    ));
  }

  Widget _detRow(AppPalette p, String label, String val) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(children: [
      SizedBox(width: 110, child: Text(label, style: p.body(12, color: p.textMuted))),
      Expanded(child: Text(val, style: p.body(12.5, weight: FontWeight.w500))),
    ]));

  void _showAddCase() {
    final p = appState.palette;
    final patCtrl = TextEditingController(); final phoneCtrl = TextEditingController();
    final surgCtrl = TextEditingController(); final asstCtrl = TextEditingController();
    final donorCtrl = TextEditingController(text: 'Occipital Region');
    final recipCtrl = TextEditingController(text: 'Frontal & Crown');
    final preNotesCtrl = TextEditingController();
    var technique = TransplantTechnique.fue;
    int norwood = 3; int graftsE = 2000; int graftsI = 1800;
    double cost = 0;
    var surgDate = DateTime.now().add(const Duration(days: 7));
    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, ss) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(width: 580, padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: p.border)),
        child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('NEW SURGERY CASE', style: p.display(22, spacing: 1.0)),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: FormField2(label: 'Patient Name *', controller: patCtrl, hint: 'Full name')),
            const SizedBox(width: 14),
            Expanded(child: FormField2(label: 'Phone', controller: phoneCtrl, hint: '+92 ...')),
          ]),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: FormField2(label: 'Surgeon', controller: surgCtrl, hint: 'Dr. name')),
            const SizedBox(width: 14),
            Expanded(child: FormField2(label: 'Assistant', controller: asstCtrl, hint: 'Assistant name')),
          ]),
          const SizedBox(height: 14),
          Dropdown2<TransplantTechnique>(label: 'Technique', value: technique,
            items: TransplantTechnique.values.map((t) => DropdownMenuItem(value: t, child: Text(t.label))).toList(),
            onChanged: (v) => ss(() => technique = v ?? technique)),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('NORWOOD SCALE', style: p.body(11, weight: FontWeight.w700, spacing: 1.0, color: p.textMuted)),
              const SizedBox(height: 8),
              Row(children: [QtyButton(Icons.remove, () => ss(() { if (norwood > 1) norwood--; })), const SizedBox(width: 10), Text('$norwood', style: p.display(18)), const SizedBox(width: 10), QtyButton(Icons.add, () => ss(() { if (norwood < 7) norwood++; }))]),
            ])),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('GRAFTS (E / I)', style: p.body(11, weight: FontWeight.w700, spacing: 1.0, color: p.textMuted)),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: FormField2(label: '', controller: TextEditingController(text: '$graftsE'), hint: 'Extracted', onChanged: (v) => graftsE = int.tryParse(v) ?? graftsE, keyboard: TextInputType.number)),
                const SizedBox(width: 8),
                Expanded(child: FormField2(label: '', controller: TextEditingController(text: '$graftsI'), hint: 'Implanted', onChanged: (v) => graftsI = int.tryParse(v) ?? graftsI, keyboard: TextInputType.number)),
              ]),
            ])),
          ]),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () async { final d = await showDatePicker(context: ctx, initialDate: surgDate, firstDate: DateTime.now(), lastDate: DateTime(2030), builder: (c, ch) => Theme(data: ThemeData.dark().copyWith(colorScheme: ColorScheme.dark(primary: p.gold, surface: p.surface)), child: ch!)); if (d != null) ss(() => surgDate = d); },
            child: Container(height: 46, padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(8), border: Border.all(color: p.border)),
              child: Row(children: [Icon(Icons.calendar_today_outlined, size: 15, color: p.gold), const SizedBox(width: 10), Text('Surgery Date: ${prettyShort(surgDate)}', style: p.body(13))])),
          ),
          const SizedBox(height: 14),
          FormField2(label: 'Pre-Op Notes', controller: preNotesCtrl, hint: 'Patient history, contraindications…', maxLines: 2),
          const SizedBox(height: 14),
          FormField2(label: 'Procedure Cost (PKR)', controller: TextEditingController(), hint: '0', keyboard: TextInputType.number, onChanged: (v) => cost = double.tryParse(v) ?? 0),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            GhostButton(label: 'Cancel', onTap: () => Navigator.pop(ctx)),
            const SizedBox(width: 12),
            GoldButton(label: 'Create Case', onTap: () {
              if (patCtrl.text.isEmpty) return;
              appState.addTransplantCase(TransplantCase(
                id: appState.createTransplantId(), patientId: '', patientName: patCtrl.text,
                patientPhone: phoneCtrl.text, surgeonName: surgCtrl.text, assistantName: asstCtrl.text,
                technique: technique, norwoodScale: norwood, graftsExtracted: graftsE, graftsImplanted: graftsI,
                donorArea: donorCtrl.text, recipientArea: recipCtrl.text, surgeryDate: surgDate,
                preOpNotes: preNotesCtrl.text, procedureCost: cost, followUps: [],
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
    var list = appState.transplantCases;
    if (_q.isNotEmpty) list = list.where((t) => t.patientName.toLowerCase().contains(_q.toLowerCase())).toList();
    if (_statusFilter != null) list = list.where((t) => t.status == _statusFilter).toList();
    if (_techFilter != null) list = list.where((t) => t.technique == _techFilter).toList();

    return Column(children: [
      Row(children: [
        MetricCard(title: 'Total Cases', value: '${appState.transplantCases.length}', icon: Icons.content_cut_outlined, delta: ''),
        const SizedBox(width: 14),
        MetricCard(title: 'Completed', value: '${appState.transplantCases.where((t) => t.status == SurgeryStatus.completed).length}', icon: Icons.check_circle_outline, delta: ''),
        const SizedBox(width: 14),
        MetricCard(title: 'Scheduled', value: '${appState.transplantCases.where((t) => t.status == SurgeryStatus.scheduled).length}', icon: Icons.schedule_outlined, delta: ''),
      ]),
      const SizedBox(height: 16),
      FilterBar(
        searchHint: 'Search by patient name…',
        onSearch: (v) => setState(() => _q = v),
        filters: [
          FilterDropdown<SurgeryStatus?>(value: _statusFilter,
            items: [const DropdownMenuItem(value: null, child: Text('All Statuses')), ...SurgeryStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.label)))],
            onChanged: (v) => setState(() => _statusFilter = v)),
          FilterDropdown<TransplantTechnique?>(value: _techFilter,
            items: [const DropdownMenuItem(value: null, child: Text('All Techniques')), ...TransplantTechnique.values.map((t) => DropdownMenuItem(value: t, child: Text(t.label)))],
            onChanged: (v) => setState(() => _techFilter = v)),
        ],
        countText: '${list.length} cases',
        onClear: () => setState(() { _q = ''; _statusFilter = null; _techFilter = null; }),
        trailing: [GoldButton(label: 'New Case', icon: Icons.add, onTap: _showAddCase)],
      ),
      const SizedBox(height: 12),
      Expanded(child: list.isEmpty
        ? Center(child: Text('No surgery cases found.', style: p.body(13, color: p.textMuted)))
        : ScrollArea(builder: (sc) => ListView.separated(
            controller: sc, padding: const EdgeInsets.only(right: 8),
            itemCount: list.length, separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final tc = list[i];
              return MouseRegion(cursor: SystemMouseCursors.click, child: GestureDetector(onTap: () => _showDetail(tc), child: Panel(child: Row(children: [
                Container(width: 48, height: 48, alignment: Alignment.center,
                  decoration: BoxDecoration(color: _surgeryColor(p, tc.status).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                  child: Icon(Icons.content_cut_outlined, size: 22, color: _surgeryColor(p, tc.status))),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(tc.patientName, style: p.body(14, weight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('${tc.technique.label} · ${tc.graftsImplanted} grafts · Dr. ${tc.surgeonName}', style: p.body(12.5, color: p.textMuted)),
                  const SizedBox(height: 4),
                  Text(prettyShort(tc.surgeryDate), style: p.body(12, color: p.textMuted)),
                ])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  StatusChip(label: tc.status.label, color: _surgeryColor(p, tc.status)),
                  const SizedBox(height: 8),
                  Text(money(tc.procedureCost), style: p.body(13, weight: FontWeight.w700, color: p.gold)),
                ]),
              ]))));
            },
          ))),
    ]);
  }
}

// ── Scheduled ────────────────────────────────────────────────────────────────
class _ScheduledTab extends StatefulWidget {
  const _ScheduledTab();
  @override
  State<_ScheduledTab> createState() => _ScheduledTabState();
}

class _ScheduledTabState extends State<_ScheduledTab> {
  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final list = appState.transplantCases.where((t) => t.status == SurgeryStatus.scheduled || t.status == SurgeryStatus.inProgress).toList()
      ..sort((a, b) => a.surgeryDate.compareTo(b.surgeryDate));
    return list.isEmpty
      ? Center(child: Text('No upcoming surgeries scheduled.', style: p.body(13, color: p.textMuted)))
      : ScrollArea(builder: (sc) => ListView.separated(
          controller: sc, padding: const EdgeInsets.only(right: 8),
          itemCount: list.length, separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) {
            final tc = list[i];
            return Panel(child: Row(children: [
              Container(width: 58, height: 58, alignment: Alignment.center,
                decoration: BoxDecoration(color: p.gold.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('${tc.surgeryDate.day}', style: p.display(20, color: p.gold)),
                  Text(['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][tc.surgeryDate.month - 1], style: p.body(10, color: p.textMuted)),
                ])),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(tc.patientName, style: p.body(14, weight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('${tc.technique.label} — ${tc.graftsExtracted} grafts', style: p.body(12.5, color: p.textMuted)),
                Text('Dr. ${tc.surgeonName}', style: p.body(12.5, color: p.textMuted)),
              ])),
              GhostButton(label: 'Mark In-Progress', onTap: () { tc.status = SurgeryStatus.inProgress; appState.touch(); setState(() {}); }),
            ]));
          },
        ));
  }
}

// ── Post-Op Follow-Up ─────────────────────────────────────────────────────────
class _PostOpTab extends StatefulWidget {
  const _PostOpTab();
  @override
  State<_PostOpTab> createState() => _PostOpTabState();
}

class _PostOpTabState extends State<_PostOpTab> {
  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final allFollowUps = appState.transplantCases
      .expand((tc) => tc.followUps.map((f) => (tc: tc, visit: f)))
      .where((e) => !e.visit.completed)
      .toList()
      ..sort((a, b) => a.visit.scheduledDate.compareTo(b.visit.scheduledDate));

    return allFollowUps.isEmpty
      ? Center(child: Text('No pending post-op follow-ups.', style: p.body(13, color: p.textMuted)))
      : ScrollArea(builder: (sc) => ListView.separated(
          controller: sc, padding: const EdgeInsets.only(right: 8),
          itemCount: allFollowUps.length, separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) {
            final e = allFollowUps[i]; final visit = e.visit; final tc = e.tc;
            return Panel(child: Row(children: [
              Container(width: 48, height: 48, alignment: Alignment.center,
                decoration: BoxDecoration(color: p.info.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.medical_services_outlined, size: 22, color: p.info)),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${tc.patientName} — ${visit.label}', style: p.body(14, weight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('Scheduled: ${prettyShort(visit.scheduledDate)}', style: p.body(12.5, color: p.textMuted)),
                if (visit.notes.isNotEmpty) Text(visit.notes, style: p.body(12, color: p.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
              ])),
              GoldButton(label: 'Mark Complete', onTap: () {
                visit.completed = true; visit.actualDate = DateTime.now(); appState.touch(); setState(() {});
              }),
            ]));
          },
        ));
  }
}
