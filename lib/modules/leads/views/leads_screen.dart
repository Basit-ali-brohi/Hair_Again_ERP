import 'package:flutter/material.dart';

import '../../../core/core.dart';
import '../models/lead_models.dart';

class LeadsScreen extends StatefulWidget {
  const LeadsScreen({super.key});
  @override
  State<LeadsScreen> createState() => _LeadsScreenState();
}

class _LeadsScreenState extends State<LeadsScreen> {
  bool _kanban = true;
  String _q = '';
  LeadSource? _srcFilter;
  LeadPriority? _priFilter;
  LeadStage? _stageFilter;
  // ignore: unused_field
  Lead? _detail;

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
    return ScreenScaffold(
      title: 'LEAD MANAGEMENT',
      subtitle: 'Pipeline, follow-ups, call logs & conversion tracking',
      actions: [
        // View toggle
        Container(
          decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: p.border)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            _ViewToggleBtn(icon: Icons.view_kanban_outlined, label: 'Pipeline', active: _kanban, palette: p, onTap: () => setState(() => _kanban = true)),
            _ViewToggleBtn(icon: Icons.list_alt_outlined, label: 'List', active: !_kanban, palette: p, onTap: () => setState(() => _kanban = false)),
          ]),
        ),
        const SizedBox(width: 12),
        GoldButton(label: 'Add Lead', icon: Icons.person_add_outlined, onTap: () => _showLeadForm()),
      ],
      child: Column(children: [
        // Filter bar
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
        Expanded(child: _kanban ? _KanbanView(filtered: _filtered, forStage: _forStage, onUpdate: () => setState(() {}), onDetail: (l) => setState(() => _detail = l), onEdit: (l) => _showLeadForm(existing: l)) : _ListView(leads: _filtered, onUpdate: () => setState(() {}), onDetail: (l) => setState(() => _detail = l), onEdit: (l) => _showLeadForm(existing: l))),
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
        // Column header
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
        // Lead cards
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
            Row(children: [
              Icon(Icons.phone_outlined, size: 12, color: p.textMuted),
              const SizedBox(width: 4),
              Text(l.phone, style: p.body(12, color: p.textMuted)),
            ]),
            const SizedBox(height: 4),
            Row(children: [
              Icon(Icons.medical_services_outlined, size: 12, color: p.textMuted),
              const SizedBox(width: 4),
              Expanded(child: Text(l.serviceInterest, style: p.body(12, color: p.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis)),
            ]),
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
class _ViewToggleBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final AppPalette palette;
  final VoidCallback onTap;
  const _ViewToggleBtn({required this.icon, required this.label, required this.active, required this.palette, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final p = palette;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(color: active ? p.gold.withValues(alpha: 0.15) : Colors.transparent, borderRadius: BorderRadius.circular(7)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 16, color: active ? p.gold : p.textMuted),
          const SizedBox(width: 7),
          Text(label, style: p.body(12.5, color: active ? p.gold : p.textMuted, weight: active ? FontWeight.w700 : FontWeight.w500)),
        ]),
      ),
    );
  }
}

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
          final picked = await showDatePicker(context: context, initialDate: value ?? DateTime.now().add(const Duration(days: 1)), firstDate: DateTime.now(), lastDate: DateTime(2030),
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
