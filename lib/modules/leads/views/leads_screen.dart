import 'package:flutter/material.dart';

import '../../../core/core.dart';
import '../models/lead_models.dart';

class LeadsScreen extends StatefulWidget {
  const LeadsScreen({super.key});
  @override
  State<LeadsScreen> createState() => _LeadsScreenState();
}

class _LeadsScreenState extends State<LeadsScreen> with SingleTickerProviderStateMixin {
  late final TabController _tab;
  bool _kanban = true;
  String _q = '';
  LeadSource? _srcFilter;
  LeadPriority? _priFilter;
  LeadStage? _stageFilter;
  // ignore: unused_field
  Lead? _detail;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 7, vsync: this);
    _tab.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  List<Lead> get _filtered {
    var list = appState.leads;
    if (_q.isNotEmpty) {
      final q = _q.toLowerCase();
      list = list.where((l) => l.name.toLowerCase().contains(q) || l.phone.contains(q) || (l.email?.toLowerCase().contains(q) ?? false)).toList();
    }
    if (_srcFilter != null) list = list.where((l) => l.source == _srcFilter).toList();
    if (_priFilter != null) list = list.where((l) => l.priority == _priFilter).toList();
    if (_stageFilter != null) list = list.where((l) => l.stage == _stageFilter).toList();
    return list;
  }

  List<Lead> _forStage(LeadStage s) => _filtered.where((l) => l.stage == s).toList();

  void _showLeadForm({Lead? existing}) {
    final editing = existing != null;
    final p = appState.palette;
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final phoneCtrl = TextEditingController(text: existing?.phone ?? '');
    final waCtrl = TextEditingController(text: existing?.whatsapp ?? '');
    final emailCtrl = TextEditingController(text: existing?.email ?? '');
    final cityCtrl = TextEditingController(text: existing?.city ?? '');
    final ageCtrl = TextEditingController(text: existing?.age?.toString() ?? '');
    final budgetCtrl = TextEditingController(text: existing?.budgetRange ?? '');
    final notesCtrl = TextEditingController(text: existing?.notes ?? '');
    var source = existing?.source ?? LeadSource.instagram;
    var priority = existing?.priority ?? LeadPriority.warm;
    var gender = existing?.gender ?? 'Male';
    var service = existing?.serviceInterest ?? 'FUE Hair Transplant';
    String? assignedTo = existing?.assignedTo;
    DateTime? followUp = existing?.followUpDate;

    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, ss) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 700, padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: p.border)),
        child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(editing ? 'EDIT LEAD' : 'ADD NEW LEAD', style: p.display(26, spacing: 1.0)),
            const Spacer(),
            GestureDetector(onTap: () => Navigator.pop(ctx), child: Icon(Icons.close, color: p.textMuted, size: 20)),
          ]),
          const SizedBox(height: 24),
          Text('PERSONAL INFORMATION', style: p.body(10.5, color: p.textMuted, weight: FontWeight.w700, spacing: 1.5)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: FormField2(label: 'Full Name *', controller: nameCtrl, hint: 'e.g. Waqas Ahmed')),
            const SizedBox(width: 16),
            Expanded(child: FormField2(label: 'Phone *', controller: phoneCtrl, hint: '+92 3XX XXXXXXX', keyboard: TextInputType.phone)),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: FormField2(label: 'WhatsApp (if different)', controller: waCtrl, hint: '+92 3XX XXXXXXX', keyboard: TextInputType.phone)),
            const SizedBox(width: 16),
            Expanded(child: FormField2(label: 'Email', controller: emailCtrl, hint: 'email@example.com', keyboard: TextInputType.emailAddress)),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: FormField2(label: 'City', controller: cityCtrl, hint: 'e.g. Karachi')),
            const SizedBox(width: 16),
            Expanded(child: FormField2(label: 'Age', controller: ageCtrl, hint: 'e.g. 32', keyboard: TextInputType.number)),
            const SizedBox(width: 16),
            Expanded(child: Dropdown2<String>(label: 'Gender', value: gender, items: ['Male','Female','Other'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(), onChanged: (v) => ss(() => gender = v ?? gender))),
          ]),
          const SizedBox(height: 20),
          Text('LEAD DETAILS', style: p.body(10.5, color: p.textMuted, weight: FontWeight.w700, spacing: 1.5)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: Dropdown2<LeadSource>(label: 'Lead Source *', value: source, items: LeadSource.values.map((s) => DropdownMenuItem(value: s, child: Text(s.label))).toList(), onChanged: (v) => ss(() => source = v ?? source))),
            const SizedBox(width: 16),
            Expanded(child: Dropdown2<String>(label: 'Service Interest *', value: service, items: ['FUE Hair Transplant','PRP Therapy','Scalp Micropigmentation','Dermatology Consult','Mesotherapy','Laser Therapy','Hair Patch','Other'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(), onChanged: (v) => ss(() => service = v ?? service))),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: FormField2(label: 'Budget Range', controller: budgetCtrl, hint: 'e.g. PKR 300,000 – 500,000')),
            const SizedBox(width: 16),
            Expanded(child: Dropdown2<LeadPriority>(label: 'Priority', value: priority, items: LeadPriority.values.map((p) => DropdownMenuItem(value: p, child: Text(p.label))).toList(), onChanged: (v) => ss(() => priority = v ?? priority))),
          ]),
          const SizedBox(height: 20),
          Text('ASSIGNMENT & FOLLOW-UP', style: p.body(10.5, color: p.textMuted, weight: FontWeight.w700, spacing: 1.5)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: Dropdown2<String?>(label: 'Assign To', value: assignedTo, items: [const DropdownMenuItem<String?>(value: null, child: Text('— Unassigned —')), ...appState.staff.map((s) => DropdownMenuItem<String?>(value: s.name, child: Text(s.name)))], onChanged: (v) => ss(() => assignedTo = v))),
            const SizedBox(width: 16),
            Expanded(child: _DatePickerField2(label: 'Follow-up Date', value: followUp, palette: p, onPick: (d) => ss(() => followUp = d))),
          ]),
          const SizedBox(height: 12),
          FormField2(label: 'Notes', controller: notesCtrl, hint: 'Any additional information about this lead...', maxLines: 3),
          const SizedBox(height: 28),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            GhostButton(label: 'Cancel', onTap: () => Navigator.pop(ctx)),
            const SizedBox(width: 12),
            GoldButton(label: editing ? 'Save Changes' : 'Save Lead', icon: Icons.save_outlined, onTap: () {
              if (nameCtrl.text.isEmpty || phoneCtrl.text.isEmpty) return;
              if (editing) {
                existing!.name = nameCtrl.text.trim();
                existing.phone = phoneCtrl.text.trim();
                existing.whatsapp = waCtrl.text.isEmpty ? null : waCtrl.text.trim();
                existing.email = emailCtrl.text.isEmpty ? null : emailCtrl.text.trim();
                existing.city = cityCtrl.text.isEmpty ? null : cityCtrl.text.trim();
                existing.age = int.tryParse(ageCtrl.text);
                existing.gender = gender;
                existing.source = source;
                existing.serviceInterest = service;
                existing.budgetRange = budgetCtrl.text.isEmpty ? null : budgetCtrl.text.trim();
                existing.priority = priority;
                existing.assignedTo = assignedTo;
                existing.followUpDate = followUp;
                existing.notes = notesCtrl.text.isEmpty ? null : notesCtrl.text.trim();
                appState.updateLead(existing);
              } else {
                final lead = Lead(
                  id: appState.createLeadId(),
                  name: nameCtrl.text.trim(), phone: phoneCtrl.text.trim(),
                  whatsapp: waCtrl.text.isEmpty ? null : waCtrl.text.trim(),
                  email: emailCtrl.text.isEmpty ? null : emailCtrl.text.trim(),
                  city: cityCtrl.text.isEmpty ? null : cityCtrl.text.trim(),
                  age: int.tryParse(ageCtrl.text), gender: gender,
                  source: source, serviceInterest: service,
                  budgetRange: budgetCtrl.text.isEmpty ? null : budgetCtrl.text.trim(),
                  priority: priority, stage: LeadStage.newLead,
                  assignedTo: assignedTo, followUpDate: followUp,
                  notes: notesCtrl.text.isEmpty ? null : notesCtrl.text.trim(),
                  createdAt: DateTime.now(), updatedAt: DateTime.now(),
                  callLogs: [], followUps: [],
                );
                appState.addLead(lead);
              }
              Navigator.pop(ctx);
              setState(() {});
            }),
          ]),
        ])),
      ),
    )));
  }

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final tabLabels = [
      (Icons.view_kanban_outlined, 'Pipeline'),
      (Icons.list_alt_outlined, 'List'),
      (Icons.calendar_month_outlined, 'Follow-up Calendar'),
      (Icons.phone_in_talk_outlined, 'Call Logs'),
      (Icons.chat_outlined, 'WhatsApp'),
      (Icons.bar_chart_outlined, 'Source Analysis'),
      (Icons.person_off_outlined, 'Lost Leads'),
    ];
    return ScreenScaffold(
      title: 'LEAD MANAGEMENT',
      subtitle: 'Pipeline, follow-ups, call logs & conversion tracking',
      actions: [
        GoldButton(label: 'Add Lead', icon: Icons.person_add_outlined, onTap: () => _showLeadForm()),
      ],
      child: Column(children: [
        // Tab bar
        Container(
          decoration: BoxDecoration(color: p.surface, border: Border(bottom: BorderSide(color: p.border))),
          child: TabBar(
            controller: _tab,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: p.gold,
            labelColor: p.gold,
            unselectedLabelColor: p.textMuted,
            labelStyle: p.body(13, weight: FontWeight.w700),
            unselectedLabelStyle: p.body(13, weight: FontWeight.w500),
            tabs: tabLabels.map((t) => Tab(
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(t.$1, size: 15),
                const SizedBox(width: 7),
                Text(t.$2),
              ]),
            )).toList(),
          ),
        ),
        // Filter bar (only for pipeline/list tabs)
        if (_tab.index <= 1) ...[
          const SizedBox(height: 8),
          FilterBar(
            searchHint: 'Search name, phone, email…',
            onSearch: (v) => setState(() => _q = v),
            filters: [
              FilterDropdown<LeadSource?>(
                value: _srcFilter, icon: Icons.share_outlined,
                items: [const DropdownMenuItem(value: null, child: Text('All Sources')), ...LeadSource.values.map((s) => DropdownMenuItem(value: s, child: Text(s.label)))],
                onChanged: (v) => setState(() => _srcFilter = v),
              ),
              FilterDropdown<LeadPriority?>(
                value: _priFilter, icon: Icons.local_fire_department_outlined,
                items: [const DropdownMenuItem(value: null, child: Text('All Priorities')), ...LeadPriority.values.map((p) => DropdownMenuItem(value: p, child: Text(p.label)))],
                onChanged: (v) => setState(() => _priFilter = v),
              ),
              FilterDropdown<LeadStage?>(
                value: _stageFilter, icon: Icons.timeline_outlined,
                items: [const DropdownMenuItem(value: null, child: Text('All Stages')), ...LeadStage.values.map((s) => DropdownMenuItem(value: s, child: Text(s.label)))],
                onChanged: (v) => setState(() => _stageFilter = v),
              ),
            ],
            countText: '${_filtered.length} leads',
            onClear: () => setState(() { _srcFilter = null; _priFilter = null; _stageFilter = null; }),
          ),
          const SizedBox(height: 8),
          Row(children: [
            _SummaryPill('Hot', appState.hotLeadsCount, appState.palette.danger, p),
            const SizedBox(width: 8),
            _SummaryPill('Today\'s Follow-ups', appState.todayFollowUpsCount, appState.palette.warning, p),
            const SizedBox(width: 8),
            _SummaryPill('Converted', appState.convertedLeadsCount, appState.palette.success, p),
          ]),
          const SizedBox(height: 8),
        ],
        Expanded(child: EagerTabBarView(controller: _tab, children: [
          // Tab 0: Pipeline (Kanban)
          _KanbanView(filtered: _filtered, forStage: _forStage, onUpdate: () => setState(() {}), onDetail: (l) => setState(() => _detail = l), onEdit: (l) => _showLeadForm(existing: l)),
          // Tab 1: List
          _ListView(leads: _filtered, onUpdate: () => setState(() {}), onDetail: (l) => setState(() => _detail = l), onEdit: (l) => _showLeadForm(existing: l)),
          // Tab 2: Follow-up Calendar
          _FollowUpCalendarTab(leads: appState.leads, onUpdate: () => setState(() {})),
          // Tab 3: Call Logs
          _CallLogsTab(leads: appState.leads, onUpdate: () => setState(() {})),
          // Tab 4: WhatsApp Conversations
          _WhatsAppTab(leads: appState.leads),
          // Tab 5: Lead Source Analysis
          _SourceAnalysisTab(leads: appState.leads),
          // Tab 6: Lost Lead Analysis
          _LostLeadsTab(leads: appState.leads, onUpdate: () => setState(() {})),
        ])),
      ]),
    );
  }
}

Widget _SummaryPill(String label, int count, Color color, AppPalette p) => Container(
  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withValues(alpha: 0.3))),
  child: Row(mainAxisSize: MainAxisSize.min, children: [
    Text('$count', style: p.body(13.5, color: color, weight: FontWeight.w700)),
    const SizedBox(width: 6),
    Text(label, style: p.body(12.5, color: color, weight: FontWeight.w500)),
  ]),
);

// ══════════════════════════════════════════════════════════════════════════════
// TAB 2: FOLLOW-UP CALENDAR
// ══════════════════════════════════════════════════════════════════════════════
class _FollowUpCalendarTab extends StatefulWidget {
  final List<Lead> leads;
  final VoidCallback onUpdate;
  const _FollowUpCalendarTab({required this.leads, required this.onUpdate});
  @override
  State<_FollowUpCalendarTab> createState() => _FollowUpCalendarTabState();
}

class _FollowUpCalendarTabState extends State<_FollowUpCalendarTab> {
  late DateTime _month;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month, 1);
  }

  List<Lead> _leadsForDay(int day) => widget.leads.where((l) {
    final d = l.followUpDate;
    return d != null && d.year == _month.year && d.month == _month.month && d.day == day;
  }).toList();

  List<Lead> get _todayLeads {
    final now = DateTime.now();
    return widget.leads.where((l) {
      final d = l.followUpDate;
      return d != null && d.year == now.year && d.month == now.month && d.day == now.day;
    }).toList();
  }

  void _reschedule(Lead lead) {
    final p = appState.palette;
    DateTime? picked = lead.followUpDate;
    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, ss) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 380, padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: p.border)),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('RESCHEDULE FOLLOW-UP', style: p.display(20, spacing: 0.8)),
          const SizedBox(height: 6),
          Text(lead.name, style: p.body(13, color: p.textMuted)),
          const SizedBox(height: 20),
          _DatePickerField2(label: 'New Follow-up Date', value: picked, palette: p, onPick: (d) => ss(() => picked = d)),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            GhostButton(label: 'Cancel', onTap: () => Navigator.pop(ctx)),
            const SizedBox(width: 12),
            GoldButton(label: 'Reschedule', icon: Icons.event_outlined, onTap: () {
              if (picked != null) {
                lead.followUpDate = picked;
                appState.updateLead(lead);
                Navigator.pop(ctx);
                setState(() {});
                widget.onUpdate();
              }
            }),
          ]),
        ]),
      ),
    )));
  }

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final daysInMonth = DateUtils.getDaysInMonth(_month.year, _month.month);
    final firstWeekday = _month.weekday % 7; // 0=Sun
    final now = DateTime.now();
    final dayNames = ['Sun','Mon','Tue','Wed','Thu','Fri','Sat'];

    return ScrollArea(builder: (sc) => SingleChildScrollView(controller: sc, child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Calendar
        Expanded(flex: 3, child: Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Month nav
          Row(children: [
            GestureDetector(
              onTap: () => setState(() => _month = DateTime(_month.year, _month.month - 1, 1)),
              child: MouseRegion(cursor: SystemMouseCursors.click, child: Icon(Icons.chevron_left, color: p.textMuted)),
            ),
            const SizedBox(width: 12),
            Text('${_monthName(_month.month)} ${_month.year}', style: p.display(20, spacing: 0.5)),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () => setState(() => _month = DateTime(_month.year, _month.month + 1, 1)),
              child: MouseRegion(cursor: SystemMouseCursors.click, child: Icon(Icons.chevron_right, color: p.textMuted)),
            ),
          ]),
          const SizedBox(height: 16),
          // Day headers
          Row(children: dayNames.map((d) => Expanded(child: Center(child: Text(d, style: p.body(11.5, color: p.textMuted, weight: FontWeight.w700))))).toList()),
          const SizedBox(height: 8),
          // Grid
          ...List.generate(6, (row) {
            return Row(children: List.generate(7, (col) {
              final cellIdx = row * 7 + col;
              final dayNum = cellIdx - firstWeekday + 1;
              if (dayNum < 1 || dayNum > daysInMonth) {
                return const Expanded(child: SizedBox(height: 56));
              }
              final leads = _leadsForDay(dayNum);
              final isToday = now.year == _month.year && now.month == _month.month && now.day == dayNum;
              final hasLeads = leads.isNotEmpty;
              return Expanded(child: GestureDetector(
                onTap: hasLeads ? () {} : null,
                child: Container(
                  height: 56, margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isToday ? p.gold.withValues(alpha: 0.15) : hasLeads ? p.warning.withValues(alpha: 0.12) : p.surfaceAlt,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isToday ? p.gold.withValues(alpha: 0.6) : hasLeads ? p.warning.withValues(alpha: 0.4) : p.border),
                  ),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('$dayNum', style: p.body(14, weight: isToday ? FontWeight.w800 : FontWeight.w500, color: isToday ? p.gold : hasLeads ? p.warning : p.text)),
                    if (hasLeads) Container(
                      margin: const EdgeInsets.only(top: 2),
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(color: p.warning, borderRadius: BorderRadius.circular(6)),
                      child: Text('${leads.length}', style: p.body(10, color: Colors.black87, weight: FontWeight.w700)),
                    ),
                  ]),
                ),
              ));
            }));
          }),
        ]))),
        const SizedBox(width: 16),
        // Today's follow-ups
        Expanded(flex: 2, child: Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("TODAY'S FOLLOW-UPS", style: p.body(11, color: p.textMuted, weight: FontWeight.w700, spacing: 1.2)),
          const SizedBox(height: 4),
          Text(prettyDate(now), style: p.body(13, color: p.gold, weight: FontWeight.w600)),
          const SizedBox(height: 16),
          if (_todayLeads.isEmpty)
            Center(child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(children: [
                Icon(Icons.check_circle_outline, color: p.success, size: 32),
                const SizedBox(height: 8),
                Text('No follow-ups today', style: p.body(13, color: p.textMuted)),
              ]),
            ))
          else
            ..._todayLeads.map((l) {
              final priColor = switch (l.priority) { LeadPriority.hot => p.danger, LeadPriority.warm => p.warning, LeadPriority.cold => p.info };
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(10), border: Border.all(color: p.border)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text(l.name, style: p.body(13.5, weight: FontWeight.w700))),
                    StatusChip(label: l.priority.label, color: priColor),
                  ]),
                  const SizedBox(height: 4),
                  Row(children: [Icon(Icons.phone_outlined, size: 12, color: p.textMuted), const SizedBox(width: 4), Text(l.phone, style: p.body(12, color: p.textMuted))]),
                  const SizedBox(height: 4),
                  StatusChip(label: l.stage.label, color: p.info),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(child: GoldButton(label: 'Call', icon: Icons.phone_outlined, dense: true, onTap: () => toast(context, 'Calling ${l.name}…'))),
                    const SizedBox(width: 8),
                    Expanded(child: GhostButton(label: 'Reschedule', dense: true, onTap: () => _reschedule(l))),
                  ]),
                ]),
              );
            }),
        ]))),
      ]),
    )));
  }

  String _monthName(int m) => ['January','February','March','April','May','June','July','August','September','October','November','December'][m - 1];
}

// ══════════════════════════════════════════════════════════════════════════════
// TAB 3: CALL LOGS
// ══════════════════════════════════════════════════════════════════════════════
class _CallLogsTab extends StatefulWidget {
  final List<Lead> leads;
  final VoidCallback onUpdate;
  const _CallLogsTab({required this.leads, required this.onUpdate});
  @override
  State<_CallLogsTab> createState() => _CallLogsTabState();
}

class _CallLogsTabState extends State<_CallLogsTab> {
  void _showLogCallDialog() {
    final p = appState.palette;
    Lead? selectedLead;
    final notesCtrl = TextEditingController();
    final durCtrl = TextEditingController(text: '5');
    String status = 'Completed';
    DateTime callDate = DateTime.now();

    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, ss) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 480, padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: p.border)),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text('LOG A CALL', style: p.display(22, spacing: 0.8)),
            const Spacer(),
            GestureDetector(onTap: () => Navigator.pop(ctx), child: Icon(Icons.close, color: p.textMuted)),
          ]),
          const SizedBox(height: 20),
          Dropdown2<Lead?>(
            label: 'Select Lead',
            value: selectedLead,
            items: [const DropdownMenuItem<Lead?>(value: null, child: Text('— Choose lead —')), ...widget.leads.map((l) => DropdownMenuItem<Lead?>(value: l, child: Text('${l.name}  •  ${l.phone}')))],
            onChanged: (v) => ss(() => selectedLead = v),
          ),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: FormField2(label: 'Duration (minutes)', controller: durCtrl, hint: '5', keyboard: TextInputType.number)),
            const SizedBox(width: 14),
            Expanded(child: Dropdown2<String>(
              label: 'Status',
              value: status,
              items: ['Completed','Missed','Scheduled'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (v) => ss(() => status = v ?? status),
            )),
          ]),
          const SizedBox(height: 14),
          _DatePickerField2(label: 'Call Date', value: callDate, palette: p, onPick: (d) => ss(() => callDate = d)),
          const SizedBox(height: 14),
          FormField2(label: 'Notes', controller: notesCtrl, hint: 'Summary of the call…', maxLines: 3),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            GhostButton(label: 'Cancel', onTap: () => Navigator.pop(ctx)),
            const SizedBox(width: 12),
            GoldButton(label: 'Save Log', icon: Icons.save_outlined, onTap: () {
              if (selectedLead == null) return toast(context, 'Please select a lead');
              final log = CallLog(
                id: 'CL${DateTime.now().millisecondsSinceEpoch}',
                leadId: selectedLead!.id,
                dateTime: callDate,
                type: CallType.outbound,
                status: status == 'Missed' ? CallStatus.missed : CallStatus.answered,
                durationSeconds: (int.tryParse(durCtrl.text) ?? 5) * 60,
                calledBy: appState.staff.isNotEmpty ? appState.staff.first.name : 'Staff',
                notes: notesCtrl.text.isEmpty ? null : notesCtrl.text.trim(),
              );
              selectedLead!.callLogs.add(log);
              appState.updateLead(selectedLead!);
              Navigator.pop(ctx);
              setState(() {});
              widget.onUpdate();
              toast(context, 'Call logged for ${selectedLead!.name}');
            }),
          ]),
        ]),
      ),
    )));
  }

  List<(Lead, CallLog)> get _allLogs {
    final result = <(Lead, CallLog)>[];
    for (final lead in widget.leads) {
      for (final log in lead.callLogs) {
        result.add((lead, log));
      }
    }
    result.sort((a, b) => b.$2.dateTime.compareTo(a.$2.dateTime));
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final logs = _allLogs;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 12, 0, 8),
          child: Row(
            children: [
              Text('${logs.length} call log entries', style: p.body(13, color: p.textMuted)),
              const Spacer(),
              GoldButton(label: 'Log Call', icon: Icons.add_call, onTap: _showLogCallDialog),
            ],
          ),
        ),
        Expanded(
          child: Panel(
            padding: EdgeInsets.zero,
            child: logs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.phone_missed_outlined, size: 40, color: p.textMuted.withValues(alpha: 0.4)),
                      const SizedBox(height: 8),
                      Text('No call logs yet', style: p.body(13, color: p.textMuted)),
                      const SizedBox(height: 4),
                      Text('Use "Log Call" to record calls with leads', style: p.body(12, color: p.textMuted.withValues(alpha: 0.6))),
                    ],
                  ),
                )
              : ScrollArea(
                  builder: (sc) => SingleChildScrollView(
                    controller: sc,
                    child: FullWidthDataTable(
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(p.surfaceAlt),
                        columnSpacing: 16,
                        horizontalMargin: 20,
                        columns: [
                          DataColumn(label: Text('Lead Name', style: p.body(12, weight: FontWeight.w700))),
                          DataColumn(label: Text('Phone', style: p.body(12, weight: FontWeight.w700))),
                          DataColumn(label: Text('Date', style: p.body(12, weight: FontWeight.w700))),
                          DataColumn(label: Text('Duration', style: p.body(12, weight: FontWeight.w700))),
                          DataColumn(label: Text('Notes', style: p.body(12, weight: FontWeight.w700))),
                          DataColumn(label: Text('Status', style: p.body(12, weight: FontWeight.w700))),
                        ],
                        rows: logs.map((entry) {
                          final (lead, log) = entry;
                          final statusColor = switch (log.status) {
                            CallStatus.answered => p.success,
                            CallStatus.missed => p.danger,
                            CallStatus.busy => p.warning,
                            CallStatus.voicemail => p.info,
                          };
                          final statusLabel = switch (log.status) {
                            CallStatus.answered => 'Completed',
                            CallStatus.missed => 'Missed',
                            CallStatus.busy => 'Busy',
                            CallStatus.voicemail => 'Voicemail',
                          };
                          return DataRow(cells: [
                            DataCell(Text(lead.name, style: p.body(13, weight: FontWeight.w600))),
                            DataCell(Text(lead.phone, style: p.body(12.5))),
                            DataCell(Text(prettyDate(log.dateTime), style: p.body(12.5))),
                            DataCell(Text(log.durationLabel, style: p.body(12.5))),
                            DataCell(SizedBox(width: 200, child: Text(log.notes ?? '—', style: p.body(12.5, color: log.notes == null ? p.textMuted : p.text), maxLines: 1, overflow: TextOverflow.ellipsis))),
                            DataCell(StatusChip(label: statusLabel, color: statusColor)),
                          ]);
                        }).toList(),
                      ),
                    ),
                  ),
                ),
          ),
        ),
      ],
    );

  }
}

// ══════════════════════════════════════════════════════════════════════════════
// TAB 4: WHATSAPP CONVERSATIONS
// ══════════════════════════════════════════════════════════════════════════════
class _WhatsAppTab extends StatefulWidget {
  final List<Lead> leads;
  const _WhatsAppTab({required this.leads});
  @override
  State<_WhatsAppTab> createState() => _WhatsAppTabState();
}

class _WhatsAppTabState extends State<_WhatsAppTab> {
  Lead? _selected;
  final Map<String, List<_WaMsgEntry>> _convos = {};
  final _msgCtrl = TextEditingController();
  String _templateKey = 'Follow-up';

  @override
  void dispose() {
    _msgCtrl.dispose();
    super.dispose();
  }

  List<_WaMsgEntry> _msgs(Lead l) {
    if (!_convos.containsKey(l.id)) {
      _convos[l.id] = [
        _WaMsgEntry('Hi! I saw your inquiry about hair transplant services.', false, DateTime.now().subtract(const Duration(days: 2, hours: 3))),
        _WaMsgEntry('Yes, I am interested in FUE. What are your packages?', true, DateTime.now().subtract(const Duration(days: 2, hours: 2, minutes: 45))),
        _WaMsgEntry('We offer comprehensive FUE packages starting from PKR 250,000. Can we schedule a free consultation?', false, DateTime.now().subtract(const Duration(days: 2, hours: 2))),
        _WaMsgEntry('Sure, I can come this weekend.', true, DateTime.now().subtract(const Duration(days: 1, hours: 5))),
      ];
    }
    return _convos[l.id]!;
  }

  void _send() {
    if (_selected == null || _msgCtrl.text.trim().isEmpty) return;
    setState(() {
      _msgs(_selected!).add(_WaMsgEntry(_msgCtrl.text.trim(), false, DateTime.now()));
      _msgCtrl.clear();
    });
  }

  void _sendTemplate() {
    if (_selected == null) return;
    final templates = {
      'Follow-up': 'Hi ${_selected!.name}, just following up on your interest in ${_selected!.serviceInterest}. Are you still considering the treatment?',
      'Appointment Reminder': 'Hi ${_selected!.name}, this is a reminder about your upcoming consultation at Hair Again Clinic. Please confirm your attendance.',
      'Consultation Offer': 'Hi ${_selected!.name}, we are offering a FREE consultation this week for ${_selected!.serviceInterest}. Would you like to book a slot?',
    };
    final msg = templates[_templateKey] ?? '';
    setState(() => _msgs(_selected!).add(_WaMsgEntry(msg, false, DateTime.now())));
  }

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final leads = widget.leads;

    return Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      // Left: conversation list
      SizedBox(width: 280, child: Panel(padding: EdgeInsets.zero, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Row(children: [
            Icon(Icons.chat, color: const Color(0xFF25D366), size: 20),
            const SizedBox(width: 8),
            Text('CONVERSATIONS', style: p.body(11.5, weight: FontWeight.w700, spacing: 0.8)),
          ]),
        ),
        Divider(height: 1, color: p.border),
        Expanded(child: leads.isEmpty
          ? Center(child: Text('No leads yet', style: p.body(13, color: p.textMuted)))
          : ScrollArea(builder: (sc) => ListView.builder(
              controller: sc,
              itemCount: leads.length,
              itemBuilder: (_, i) {
                final l = leads[i];
                final msgs = _msgs(l);
                final last = msgs.isNotEmpty ? msgs.last.text : 'No messages';
                final sel = _selected?.id == l.id;
                return GestureDetector(
                  onTap: () => setState(() => _selected = l),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 120),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: sel ? p.gold.withValues(alpha: 0.10) : Colors.transparent,
                        border: Border(left: BorderSide(color: sel ? p.gold : Colors.transparent, width: 3)),
                      ),
                      child: Row(children: [
                        CircleAvatar(radius: 20, backgroundColor: p.surfaceAlt, child: Text(l.name[0].toUpperCase(), style: p.body(15, weight: FontWeight.w700, color: p.gold))),
                        const SizedBox(width: 10),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(l.name, style: p.body(13, weight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 2),
                          Text(last, style: p.body(11.5, color: p.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ])),
                      ]),
                    ),
                  ),
                );
              },
            ))),
      ]))),
      const SizedBox(width: 12),
      // Right: chat thread
      Expanded(child: Panel(padding: EdgeInsets.zero, child: _selected == null
        ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.chat_bubble_outline, size: 48, color: p.textMuted.withValues(alpha: 0.3)),
            const SizedBox(height: 12),
            Text('Select a lead to open conversation', style: p.body(13, color: p.textMuted)),
          ]))
        : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            // Chat header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: p.border))),
              child: Row(children: [
                CircleAvatar(radius: 18, backgroundColor: p.surfaceAlt, child: Text(_selected!.name[0].toUpperCase(), style: p.body(14, weight: FontWeight.w700, color: p.gold))),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(_selected!.name, style: p.body(14, weight: FontWeight.w700)),
                  Text(_selected!.phone, style: p.body(12, color: p.textMuted)),
                ])),
                Dropdown2<String>(
                  label: 'Template',
                  value: _templateKey,
                  items: ['Follow-up','Appointment Reminder','Consultation Offer'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (v) => setState(() => _templateKey = v ?? _templateKey),
                ),
                const SizedBox(width: 8),
                GhostButton(label: 'Send Template', icon: Icons.auto_awesome_outlined, onTap: _sendTemplate),
              ]),
            ),
            // Messages
            Expanded(child: ScrollArea(builder: (sc) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (sc.hasClients) sc.animateTo(sc.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
              });
              return ListView.builder(
                controller: sc,
                padding: const EdgeInsets.all(16),
                itemCount: _msgs(_selected!).length,
                itemBuilder: (_, i) {
                  final msg = _msgs(_selected!)[i];
                  final isOut = !msg.incoming;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      mainAxisAlignment: isOut ? MainAxisAlignment.end : MainAxisAlignment.start,
                      children: [
                        if (!isOut) ...[
                          CircleAvatar(radius: 14, backgroundColor: p.surfaceAlt, child: Text(_selected!.name[0].toUpperCase(), style: p.body(11, color: p.gold, weight: FontWeight.w700))),
                          const SizedBox(width: 8),
                        ],
                        Flexible(child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          constraints: const BoxConstraints(maxWidth: 420),
                          decoration: BoxDecoration(
                            color: isOut ? const Color(0xFF25D366).withValues(alpha: 0.18) : p.surfaceAlt,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(14),
                              topRight: const Radius.circular(14),
                              bottomLeft: Radius.circular(isOut ? 14 : 2),
                              bottomRight: Radius.circular(isOut ? 2 : 14),
                            ),
                            border: Border.all(color: isOut ? const Color(0xFF25D366).withValues(alpha: 0.35) : p.border),
                          ),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(msg.text, style: p.body(13)),
                            const SizedBox(height: 4),
                            Text(prettyShort(msg.time), style: p.body(10.5, color: p.textMuted)),
                          ]),
                        )),
                        if (isOut) const SizedBox(width: 8),
                      ],
                    ),
                  );
                },
              );
            })),
            // Input
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(border: Border(top: BorderSide(color: p.border))),
              child: Row(children: [
                Expanded(child: TextField(
                  controller: _msgCtrl,
                  style: p.body(13.5),
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: 'Type a message…',
                    hintStyle: p.body(13, color: p.textMuted),
                    filled: true, fillColor: p.surfaceAlt,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                  ),
                  onSubmitted: (_) => _send(),
                )),
                const SizedBox(width: 10),
                GoldButton(label: 'Send', icon: Icons.send_outlined, onTap: _send),
              ]),
            ),
          ]),
      )),
    ]);
  }
}

class _WaMsgEntry {
  final String text;
  final bool incoming;
  final DateTime time;
  _WaMsgEntry(this.text, this.incoming, this.time);
}

// ══════════════════════════════════════════════════════════════════════════════
// TAB 5: LEAD SOURCE ANALYSIS
// ══════════════════════════════════════════════════════════════════════════════
class _SourceAnalysisTab extends StatelessWidget {
  final List<Lead> leads;
  const _SourceAnalysisTab({required this.leads});

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final total = leads.length;

    // Build source breakdown
    final sourceGroups = <LeadSource, List<Lead>>{};
    for (final l in leads) {
      sourceGroups.putIfAbsent(l.source, () => []).add(l);
    }
    final converted = (l) => l.stage == LeadStage.converted;
    final ordered = LeadSource.values.toList()
      ..sort((a, b) => (sourceGroups[b]?.length ?? 0).compareTo(sourceGroups[a]?.length ?? 0));

    // Metrics
    final walkIn = sourceGroups[LeadSource.walkIn]?.length ?? 0;
    final social = (sourceGroups[LeadSource.instagram]?.length ?? 0) +
        (sourceGroups[LeadSource.facebook]?.length ?? 0) +
        (sourceGroups[LeadSource.tiktok]?.length ?? 0);
    final referral = sourceGroups[LeadSource.referral]?.length ?? 0;
    final google = sourceGroups[LeadSource.google]?.length ?? 0;
    final otherCount = (sourceGroups[LeadSource.other]?.length ?? 0) +
        (sourceGroups[LeadSource.youtube]?.length ?? 0) +
        (sourceGroups[LeadSource.event]?.length ?? 0) +
        (sourceGroups[LeadSource.phone]?.length ?? 0);

    return ScrollArea(builder: (sc) => SingleChildScrollView(controller: sc, child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        MetricRow([
          MetricCard(title: 'Walk-In', value: '$walkIn', delta: '—', icon: Icons.directions_walk_outlined),
          MetricCard(title: 'Social Media', value: '$social', delta: '—', icon: Icons.thumb_up_outlined),
          MetricCard(title: 'Referral', value: '$referral', delta: '—', icon: Icons.people_outlined),
          MetricCard(title: 'Google', value: '$google', delta: '—', icon: Icons.search_outlined),
          MetricCard(title: 'Other', value: '$otherCount', delta: '—', icon: Icons.more_horiz_outlined),
        ]),
        const SizedBox(height: 16),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Bar chart
          Expanded(child: Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('LEADS BY SOURCE', style: p.body(11, color: p.textMuted, weight: FontWeight.w700, spacing: 1.0)),
            const SizedBox(height: 20),
            ...ordered.where((s) => (sourceGroups[s]?.isNotEmpty ?? false)).map((src) {
              final count = sourceGroups[src]?.length ?? 0;
              final pct = total > 0 ? count / total : 0.0;
              final barColors = [p.gold, p.info, p.success, p.warning, p.danger, const Color(0xFF9B59B6), const Color(0xFF1ABC9C)];
              final colorIdx = ordered.indexOf(src) % barColors.length;
              final barColor = barColors[colorIdx];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    SizedBox(width: 120, child: Text(src.label, style: p.body(12.5, weight: FontWeight.w500))),
                    Expanded(child: LayoutBuilder(builder: (ctx, c) => Stack(children: [
                      Container(height: 22, decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(4))),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        height: 22, width: c.maxWidth * pct,
                        decoration: BoxDecoration(color: barColor.withValues(alpha: 0.7), borderRadius: BorderRadius.circular(4)),
                      ),
                    ]))),
                    const SizedBox(width: 10),
                    SizedBox(width: 32, child: Text('$count', style: p.body(12.5, weight: FontWeight.w700), textAlign: TextAlign.right)),
                  ]),
                ]),
              );
            }),
          ]))),
          const SizedBox(width: 14),
          // Table
          Expanded(child: Panel(padding: EdgeInsets.zero, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(children: [
                Text('SOURCE BREAKDOWN', style: p.body(11, color: p.textMuted, weight: FontWeight.w700, spacing: 1.0)),
                const Spacer(),
                GhostButton(label: 'Add Source', icon: Icons.add, dense: true, onTap: () => toast(context, 'Custom source has been added')),
              ]),
            ),
            FullWidthDataTable(child: DataTable(
              headingRowColor: WidgetStateProperty.all(p.surfaceAlt),
              columnSpacing: 16, horizontalMargin: 16,
              columns: [
                DataColumn(label: Text('Source', style: p.body(11.5, weight: FontWeight.w700))),
                DataColumn(label: Text('Total', style: p.body(11.5, weight: FontWeight.w700))),
                DataColumn(label: Text('Converted', style: p.body(11.5, weight: FontWeight.w700))),
                DataColumn(label: Text('Conv. Rate', style: p.body(11.5, weight: FontWeight.w700))),
              ],
              rows: ordered.map((src) {
                final srcLeads = sourceGroups[src] ?? [];
                if (srcLeads.isEmpty) return null;
                final conv = srcLeads.where(converted).length;
                final rate = srcLeads.isNotEmpty ? (conv / srcLeads.length * 100).toStringAsFixed(1) : '0.0';
                return DataRow(cells: [
                  DataCell(Text(src.label, style: p.body(13))),
                  DataCell(Text('${srcLeads.length}', style: p.body(13, weight: FontWeight.w600))),
                  DataCell(Text('$conv', style: p.body(13, color: p.success, weight: FontWeight.w600))),
                  DataCell(Text('$rate%', style: p.body(13))),
                ]);
              }).whereType<DataRow>().toList(),
            )),
          ]))),
        ]),
      ]),
    )));
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// TAB 6: LOST LEAD ANALYSIS
// ══════════════════════════════════════════════════════════════════════════════
class _LostLeadsTab extends StatelessWidget {
  final List<Lead> leads;
  final VoidCallback onUpdate;
  const _LostLeadsTab({required this.leads, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final lost = leads.where((l) => l.stage == LeadStage.lost).toList();
    final now = DateTime.now();
    final thisMonth = lost.where((l) => l.updatedAt.month == now.month && l.updatedAt.year == now.year).length;
    final totalLeads = leads.length;
    final converted = leads.where((l) => l.stage == LeadStage.converted).length;
    final recoveryRate = totalLeads > 0 ? (converted / totalLeads * 100).toStringAsFixed(1) : '0.0';

    // Loss reasons breakdown
    final reasons = <String, int>{};
    for (final l in lost) {
      final r = l.lostReason ?? '—';
      reasons[r] = (reasons[r] ?? 0) + 1;
    }
    final reasonColors = {'Price': p.danger, 'Competition': p.warning, 'No Follow-up': p.info, 'Not Interested': const Color(0xFF9B59B6), 'Other': p.textMuted, '—': p.textMuted};

    return ScrollArea(builder: (sc) => SingleChildScrollView(controller: sc, child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        MetricRow([
          MetricCard(title: 'Total Lost', value: '${lost.length}', deltaUp: false, delta: 'since start', icon: Icons.person_off_outlined),
          MetricCard(title: 'This Month Lost', value: '$thisMonth', deltaUp: false, delta: 'this month', icon: Icons.calendar_today_outlined),
          MetricCard(title: 'Recovery Rate', value: '$recoveryRate%', delta: 'conversion rate', icon: Icons.trending_up_outlined),
          MetricCard(title: 'Avg Time to Loss', value: '12 days', delta: 'estimated', icon: Icons.timer_outlined),
        ]),
        const SizedBox(height: 16),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Table
          Expanded(flex: 3, child: Panel(padding: EdgeInsets.zero, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text('LOST LEADS', style: p.body(11, color: p.textMuted, weight: FontWeight.w700, spacing: 1.0)),
            ),
            if (lost.isEmpty)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Center(child: Text('No lost leads — great work!', style: p.body(13, color: p.success))),
              )
            else
              FullWidthDataTable(child: DataTable(
                headingRowColor: WidgetStateProperty.all(p.surfaceAlt),
                columnSpacing: 14, horizontalMargin: 16,
                columns: [
                  DataColumn(label: Text('Name', style: p.body(11.5, weight: FontWeight.w700))),
                  DataColumn(label: Text('Service', style: p.body(11.5, weight: FontWeight.w700))),
                  DataColumn(label: Text('Lost Date', style: p.body(11.5, weight: FontWeight.w700))),
                  DataColumn(label: Text('Reason', style: p.body(11.5, weight: FontWeight.w700))),
                  DataColumn(label: Text('Priority', style: p.body(11.5, weight: FontWeight.w700))),
                  DataColumn(label: Text('Action', style: p.body(11.5, weight: FontWeight.w700))),
                ],
                rows: lost.map((l) {
                  final priColor = switch (l.priority) { LeadPriority.hot => p.danger, LeadPriority.warm => p.warning, LeadPriority.cold => p.info };
                  return DataRow(cells: [
                    DataCell(Text(l.name, style: p.body(13, weight: FontWeight.w600))),
                    DataCell(Text(l.serviceInterest, style: p.body(12.5))),
                    DataCell(Text(prettyShort(l.updatedAt), style: p.body(12.5, color: p.textMuted))),
                    DataCell(Text(l.lostReason ?? '—', style: p.body(12.5))),
                    DataCell(StatusChip(label: l.priority.label, color: priColor)),
                    DataCell(GestureDetector(
                      onTap: () {
                        l.stage = LeadStage.contacted;
                        l.lostReason = null;
                        appState.updateLead(l);
                        onUpdate();
                        toast(context, '${l.name} moved to Contacted — re-engagement started');
                      },
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(color: p.success.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6), border: Border.all(color: p.success.withValues(alpha: 0.35))),
                          child: Text('Re-engage', style: p.body(11.5, color: p.success, weight: FontWeight.w700)),
                        ),
                      ),
                    )),
                  ]);
                }).toList(),
              )),
          ]))),
          const SizedBox(width: 14),
          // Loss reason bars
          Expanded(flex: 2, child: Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('LOSS REASONS', style: p.body(11, color: p.textMuted, weight: FontWeight.w700, spacing: 1.0)),
            const SizedBox(height: 16),
            if (reasons.isEmpty)
              Text('No data yet', style: p.body(12.5, color: p.textMuted))
            else
              ...reasons.entries.map((e) {
                final pct = lost.isNotEmpty ? e.value / lost.length : 0.0;
                final color = reasonColors[e.key] ?? p.textMuted;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Expanded(child: Text(e.key, style: p.body(12.5, weight: FontWeight.w500))),
                      Text('${e.value}', style: p.body(12.5, weight: FontWeight.w700)),
                    ]),
                    const SizedBox(height: 5),
                    LayoutBuilder(builder: (ctx, c) => Stack(children: [
                      Container(height: 10, decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(5))),
                      Container(
                        height: 10,
                        width: c.maxWidth * pct,
                        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(5)),
                      ),
                    ])),
                    const SizedBox(height: 2),
                    Text('${(pct * 100).toStringAsFixed(0)}% of losses', style: p.body(10.5, color: p.textMuted)),
                  ]),
                );
              }),
          ]))),
        ]),
      ]),
    )));
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// KANBAN VIEW
// ══════════════════════════════════════════════════════════════════════════════
class _KanbanView extends StatelessWidget {
  final List<Lead> filtered;
  final List<Lead> Function(LeadStage) forStage;
  final VoidCallback onUpdate;
  final ValueChanged<Lead> onDetail;
  final ValueChanged<Lead> onEdit;
  const _KanbanView({required this.filtered, required this.forStage, required this.onUpdate, required this.onDetail, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final stages = [
      LeadStage.newLead, LeadStage.contacted, LeadStage.consultationBooked,
      LeadStage.proposalSent, LeadStage.negotiation, LeadStage.converted, LeadStage.lost,
    ];
    return ScrollArea(builder: (sc) => SingleChildScrollView(
      controller: sc, scrollDirection: Axis.horizontal,
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: stages.map((stage) {
        final leads = forStage(stage);
        return _KanbanColumn(stage: stage, leads: leads, onUpdate: onUpdate, onDetail: onDetail, onEdit: onEdit);
      }).toList()),
    ));
  }
}

class _KanbanColumn extends StatelessWidget {
  final LeadStage stage;
  final List<Lead> leads;
  final VoidCallback onUpdate;
  final ValueChanged<Lead> onDetail;
  final ValueChanged<Lead> onEdit;
  const _KanbanColumn({required this.stage, required this.leads, required this.onUpdate, required this.onDetail, required this.onEdit});

  Color _stageColor(AppPalette p) => switch (stage) {
    LeadStage.newLead => p.info,
    LeadStage.contacted => p.warning,
    LeadStage.consultationBooked => p.gold,
    LeadStage.proposalSent => const Color(0xFF9B59B6),
    LeadStage.negotiation => const Color(0xFFE67E22),
    LeadStage.converted => p.success,
    LeadStage.lost => p.danger,
  };

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final color = _stageColor(p);
    return Container(
      width: 250, margin: const EdgeInsets.only(right: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withValues(alpha: 0.35))),
          child: Row(children: [
            Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Expanded(child: Text(stage.label, style: p.body(13, color: color, weight: FontWeight.w700))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
              child: Text('${leads.length}', style: p.body(12, color: color, weight: FontWeight.w700)),
            ),
          ]),
        ),
        const SizedBox(height: 10),
        ...leads.map((l) => _KanbanCard(lead: l, stageColor: color, onUpdate: onUpdate, onDetail: onDetail, onEdit: onEdit)),
      ]),
    );
  }
}

class _KanbanCard extends StatefulWidget {
  final Lead lead;
  final Color stageColor;
  final VoidCallback onUpdate;
  final ValueChanged<Lead> onDetail;
  final ValueChanged<Lead> onEdit;
  const _KanbanCard({required this.lead, required this.stageColor, required this.onUpdate, required this.onDetail, required this.onEdit});
  @override
  State<_KanbanCard> createState() => _KanbanCardState();
}

class _KanbanCardState extends State<_KanbanCard> {
  bool _hover = false;
  Color _priorityColor(AppPalette p) => switch (widget.lead.priority) {
    LeadPriority.hot => p.danger, LeadPriority.warm => p.warning, LeadPriority.cold => p.info,
  };

  void _moveStage(BuildContext context) {
    final p = appState.palette;
    showDialog(context: context, builder: (_) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 360, padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: p.border)),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('MOVE TO STAGE', style: p.display(20, spacing: 1.0)),
          const SizedBox(height: 16),
          ...LeadStage.values.where((s) => s != widget.lead.stage).map((s) => ListTile(
            title: Text(s.label, style: p.body(13.5)),
            contentPadding: EdgeInsets.zero,
            onTap: () {
              appState.updateLeadStage(widget.lead, s);
              Navigator.pop(context);
              widget.onUpdate();
            },
          )),
        ]),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final l = widget.lead;
    final priColor = _priorityColor(p);
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: () => widget.onDetail(l),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.only(bottom: 10),
          transform: Matrix4.translationValues(0, _hover ? -2 : 0, 0),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: p.surface, borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _hover ? widget.stageColor.withValues(alpha: 0.5) : p.border),
            boxShadow: _hover ? [BoxShadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: 12, offset: const Offset(0, 4))] : [],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(l.name, style: p.body(13.5, weight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(color: priColor.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(6)),
                child: Text(l.priority.label, style: p.body(10.5, color: priColor, weight: FontWeight.w700)),
              ),
            ]),
            const SizedBox(height: 6),
            Row(children: [Icon(Icons.phone_outlined, size: 12, color: p.textMuted), const SizedBox(width: 4), Text(l.phone, style: p.body(12, color: p.textMuted))]),
            const SizedBox(height: 4),
            Row(children: [Icon(Icons.medical_services_outlined, size: 12, color: p.textMuted), const SizedBox(width: 4), Expanded(child: Text(l.serviceInterest, style: p.body(12, color: p.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis))]),
            const SizedBox(height: 8),
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(6), border: Border.all(color: p.border)),
                child: Text(l.source.label, style: p.body(11, weight: FontWeight.w500)),
              ),
              const Spacer(),
              if (l.followUpDate != null) Row(children: [
                Icon(Icons.event_outlined, size: 12, color: l.followUpDate!.isBefore(DateTime.now()) ? p.danger : p.warning),
                const SizedBox(width: 3),
                Text(prettyShort(l.followUpDate!), style: p.body(11, color: l.followUpDate!.isBefore(DateTime.now()) ? p.danger : p.warning, weight: FontWeight.w600)),
              ]),
              const SizedBox(width: 8),
              GestureDetector(onTap: () => widget.onEdit(l), child: MouseRegion(cursor: SystemMouseCursors.click, child: Icon(Icons.edit_outlined, size: 15, color: p.textMuted))),
              const SizedBox(width: 8),
              GestureDetector(onTap: () => _moveStage(context), child: Icon(Icons.swap_horiz_outlined, size: 17, color: p.textMuted)),
            ]),
          ]),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// LIST VIEW
// ══════════════════════════════════════════════════════════════════════════════
class _ListView extends StatelessWidget {
  final List<Lead> leads;
  final VoidCallback onUpdate;
  final ValueChanged<Lead> onDetail;
  final ValueChanged<Lead> onEdit;
  const _ListView({required this.leads, required this.onUpdate, required this.onDetail, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    return Panel(padding: EdgeInsets.zero, child: ScrollArea(builder: (sc) => SingleChildScrollView(
      controller: sc,
      child: FullWidthDataTable(child: DataTable(
        headingRowColor: WidgetStateProperty.all(p.surfaceAlt),
        columnSpacing: 16, horizontalMargin: 20,
        columns: [
          DataColumn(label: Text('Name', style: p.body(12, weight: FontWeight.w700))),
          DataColumn(label: Text('Phone', style: p.body(12, weight: FontWeight.w700))),
          DataColumn(label: Text('Source', style: p.body(12, weight: FontWeight.w700))),
          DataColumn(label: Text('Service Interest', style: p.body(12, weight: FontWeight.w700))),
          DataColumn(label: Text('Priority', style: p.body(12, weight: FontWeight.w700))),
          DataColumn(label: Text('Stage', style: p.body(12, weight: FontWeight.w700))),
          DataColumn(label: Text('Assigned To', style: p.body(12, weight: FontWeight.w700))),
          DataColumn(label: Text('Follow-up', style: p.body(12, weight: FontWeight.w700))),
          DataColumn(label: Text('Created', style: p.body(12, weight: FontWeight.w700))),
          DataColumn(label: Text('Actions', style: p.body(12, weight: FontWeight.w700))),
        ],
        rows: leads.map((l) {
          final priColor = switch (l.priority) { LeadPriority.hot => p.danger, LeadPriority.warm => p.warning, LeadPriority.cold => p.info };
          final stageColor = switch (l.stage) {
            LeadStage.newLead => p.info, LeadStage.contacted => p.warning,
            LeadStage.consultationBooked || LeadStage.proposalSent || LeadStage.negotiation => p.gold,
            LeadStage.converted => p.success, LeadStage.lost => p.danger,
          };
          return DataRow(cells: [
            DataCell(GestureDetector(onTap: () => onDetail(l), child: Text(l.name, style: p.body(13, weight: FontWeight.w600, color: p.gold)))),
            DataCell(Text(l.phone, style: p.body(12.5))),
            DataCell(StatusChip(label: l.source.label, color: p.info)),
            DataCell(Text(l.serviceInterest, style: p.body(12.5))),
            DataCell(StatusChip(label: l.priority.label, color: priColor)),
            DataCell(StatusChip(label: l.stage.label, color: stageColor)),
            DataCell(Text(l.assignedTo ?? '—', style: p.body(12.5, color: l.assignedTo == null ? p.textMuted : p.text))),
            DataCell(l.followUpDate == null ? Text('—', style: p.body(12.5, color: p.textMuted)) : Row(children: [Icon(Icons.event_outlined, size: 13, color: p.warning), const SizedBox(width: 4), Text(prettyShort(l.followUpDate!), style: p.body(12.5))])),
            DataCell(Text(prettyShort(l.createdAt), style: p.body(12.5, color: p.textMuted))),
            DataCell(Row(mainAxisSize: MainAxisSize.min, children: [
              GestureDetector(onTap: () => onDetail(l), child: MouseRegion(cursor: SystemMouseCursors.click, child: Container(width: 30, height: 30, decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(8)), child: Icon(Icons.open_in_new, size: 15, color: p.gold)))),
              const SizedBox(width: 6),
              GestureDetector(onTap: () => onEdit(l), child: MouseRegion(cursor: SystemMouseCursors.click, child: Container(width: 30, height: 30, decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(8)), child: Icon(Icons.edit_outlined, size: 15, color: p.text)))),
              const SizedBox(width: 6),
              GestureDetector(onTap: () { appState.deleteLead(l); onUpdate(); }, child: MouseRegion(cursor: SystemMouseCursors.click, child: Container(width: 30, height: 30, decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(8)), child: Icon(Icons.delete_outline, size: 15, color: p.textMuted)))),
            ])),
          ]);
        }).toList(),
      )))),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────
class _DatePickerField2 extends StatelessWidget {
  final String label;
  final DateTime? value;
  final AppPalette palette;
  final ValueChanged<DateTime> onPick;
  const _DatePickerField2({required this.label, required this.value, required this.palette, required this.onPick});
  @override
  Widget build(BuildContext context) {
    final p = palette;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: p.body(12, color: p.textMuted, weight: FontWeight.w600)),
      const SizedBox(height: 7),
      GestureDetector(
        onTap: () async {
          final picked = await showDatePicker(context: context, initialDate: value ?? DateTime.now().add(const Duration(days: 1)), firstDate: DateTime(2020), lastDate: DateTime(2030),
            builder: (ctx, child) => Theme(data: ThemeData.dark().copyWith(colorScheme: ColorScheme.dark(primary: p.gold, surface: p.surface)), child: child!));
          if (picked != null) onPick(picked);
        },
        child: Container(
          height: 46, padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(8), border: Border.all(color: p.border)),
          child: Row(children: [
            Icon(Icons.calendar_today_outlined, size: 15, color: p.gold),
            const SizedBox(width: 10),
            Text(value != null ? prettyShort(value!) : 'Select date', style: p.body(13.5, color: value != null ? p.text : p.textMuted, weight: FontWeight.w500)),
          ]),
        ),
      ),
    ]);
  }
}
