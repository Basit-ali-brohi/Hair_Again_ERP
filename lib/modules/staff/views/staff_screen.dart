// modules/staff/views — staff & doctors directory with search, role filter,
// active toggle and full add / edit / delete CRUD.
import 'package:flutter/material.dart';

import '../../../core/core.dart';
import '../models/staff.dart';

class StaffScreen extends StatefulWidget {
  const StaffScreen({super.key});
  @override
  State<StaffScreen> createState() => _StaffScreenState();
}

enum _StaffSort { nameAz, nameZa, role }

class _StaffScreenState extends State<StaffScreen> with SingleTickerProviderStateMixin {
  late final TabController _tab = TabController(length: 8, vsync: this);
  String _search = '';
  StaffRole? _filter;
  _StaffSort _sort = _StaffSort.nameAz;

  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  List<Staff> get _filtered {
    final q = _search.toLowerCase();
    final l = appState.staff.where((s) {
      final mq = q.isEmpty || s.name.toLowerCase().contains(q) || s.specialty.toLowerCase().contains(q) || s.phone.contains(q);
      final mf = _filter == null || s.role == _filter;
      return mq && mf;
    }).toList();
    switch (_sort) {
      case _StaffSort.nameAz:
        l.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      case _StaffSort.nameZa:
        l.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
      case _StaffSort.role:
        l.sort((a, b) => a.role.index.compareTo(b.role.index));
    }
    return l;
  }

  Color _roleColor(AppPalette p, StaffRole r) => switch (r) {
        StaffRole.doctor => p.gold,
        StaffRole.nurse => p.info,
        StaffRole.receptionist => p.success,
        StaffRole.manager => p.warning,
      };

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final list = _filtered;
    int countRole(StaffRole r) => appState.staff.where((s) => s.role == r).length;
    return ScreenScaffold(
      title: 'STAFF & DOCTORS',
      subtitle: 'Manage your clinical team, roles, performance & commissions.',
      actions: [
        Container(
          height: 42,
          decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: p.border)),
          child: TabBar(
            controller: _tab, isScrollable: true, dividerColor: Colors.transparent,
            indicatorColor: p.gold, indicatorSize: TabBarIndicatorSize.label,
            labelStyle: p.body(12.5, weight: FontWeight.w600),
            unselectedLabelStyle: p.body(12.5),
            labelColor: p.gold, unselectedLabelColor: p.textMuted,
            tabAlignment: TabAlignment.start,
            tabs: const [
              Tab(text: 'Directory'),
              Tab(text: 'Performance'),
              Tab(text: 'Commission'),
              Tab(text: 'Documents'),
              Tab(text: 'Contracts'),
              Tab(text: 'Incentives'),
              Tab(text: 'Warnings'),
              Tab(text: 'Exit Mgmt'),
            ],
          ),
        ),
        const SizedBox(width: 10),
        GoldButton(label: 'Add Staff', icon: Icons.person_add_alt_1, onTap: () => _showForm()),
      ],
      child: EagerTabBarView(controller: _tab, children: [
        // ── Tab 1: Directory ─────────────────────────────────────────────────
        LayoutBuilder(builder: (ctx, c) => ScrollArea(builder: (sc) => SingleChildScrollView(
          controller: sc,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            MetricRow([
              MetricCard(title: 'Total Staff', value: '${appState.staff.length}', delta: '+1 this quarter', icon: Icons.groups_2_outlined),
              MetricCard(title: 'Doctors', value: '${countRole(StaffRole.doctor)}', delta: '${countRole(StaffRole.doctor)} specialists', icon: Icons.medical_information_outlined),
              MetricCard(title: 'Support Staff', value: '${countRole(StaffRole.nurse) + countRole(StaffRole.receptionist)}', delta: 'All departments', icon: Icons.support_agent_outlined),
              MetricCard(title: 'On Duty Today', value: '${appState.staff.where((s) => s.active).length}', delta: '${appState.staff.isEmpty ? 100 : ((appState.staff.where((s) => s.active).length / appState.staff.length) * 100).round()}% attendance', icon: Icons.verified_user_outlined),
            ]),
            const SizedBox(height: 18),
            FilterBar(
              searchHint: 'Search by name, specialty or phone…',
              onSearch: (v) => setState(() => _search = v),
              filters: [
                FilterDropdown<StaffRole?>(
                  icon: Icons.badge_outlined, value: _filter,
                  items: [const DropdownMenuItem<StaffRole?>(value: null, child: Text('All Roles')), ...StaffRole.values.map((r) => DropdownMenuItem<StaffRole?>(value: r, child: Text(r.label)))],
                  onChanged: (v) => setState(() => _filter = v),
                ),
                FilterDropdown<_StaffSort>(
                  icon: Icons.sort, value: _sort,
                  items: const [DropdownMenuItem(value: _StaffSort.nameAz, child: Text('Name A–Z')), DropdownMenuItem(value: _StaffSort.nameZa, child: Text('Name Z–A')), DropdownMenuItem(value: _StaffSort.role, child: Text('By Role'))],
                  onChanged: (v) => setState(() => _sort = v ?? _StaffSort.nameAz),
                ),
              ],
              countText: 'Showing ${list.length} of ${appState.staff.length}',
              onClear: () => setState(() { _search = ''; _filter = null; _sort = _StaffSort.nameAz; }),
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: c.maxHeight,
              child: Panel(child: list.isEmpty
                  ? Center(child: Text('No staff match your search.', style: p.body(13, color: p.textMuted)))
                  : ScrollArea(builder: (sc2) => GridView.builder(
                      controller: sc2,
                      padding: const EdgeInsets.fromLTRB(2, 2, 14, 2),
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 440, mainAxisExtent: 160, crossAxisSpacing: 14, mainAxisSpacing: 14),
                      itemCount: list.length,
                      itemBuilder: (_, i) => _card(p, list[i]),
                    ))),
            ),
            const SizedBox(height: 24),
          ]),
        ))),
        // ── Tab 2: Performance ───────────────────────────────────────────────
        _PerformanceTab(roleColor: _roleColor),
        // ── Tab 3: Commission ────────────────────────────────────────────────
        _CommissionTab(roleColor: _roleColor),
        // ── Tab 4: Documents ─────────────────────────────────────────────────
        _DocumentsTab(roleColor: _roleColor),
        // ── Tab 5: Contracts ─────────────────────────────────────────────────
        _ContractsTab(roleColor: _roleColor),
        // ── Tab 6: Incentives ────────────────────────────────────────────────
        _IncentivesTab(roleColor: _roleColor),
        // ── Tab 7: Warnings ──────────────────────────────────────────────────
        _WarningsTab(roleColor: _roleColor),
        // ── Tab 8: Exit Mgmt ─────────────────────────────────────────────────
        _ExitMgmtTab(roleColor: _roleColor),
      ]),
    );
  }

  void _showDetail(Staff s) {
    final p = appState.palette;
    final rc = _roleColor(p, s.role);
    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, ss) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 480, padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: p.border)),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 64, height: 64, alignment: Alignment.center, decoration: BoxDecoration(color: rc.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(12)), child: Text(s.initials, style: p.display(28, color: rc))),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(s.name, style: p.display(24, spacing: 0.3)),
              const SizedBox(height: 6),
              Wrap(spacing: 8, children: [StatusChip(label: s.role.label, color: rc), StatusChip(label: s.active ? 'On Duty' : 'Off Duty', color: s.active ? p.success : p.textMuted)]),
            ])),
            GestureDetector(onTap: () => Navigator.pop(ctx), child: MouseRegion(cursor: SystemMouseCursors.click, child: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(8)), child: Icon(Icons.close, size: 18, color: p.textMuted)))),
          ]),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(8), border: Border.all(color: p.border)),
            child: Column(children: [
              if (s.specialty.isNotEmpty) ...[
                Row(children: [Icon(Icons.medical_information_outlined, size: 15, color: p.gold), const SizedBox(width: 10), Expanded(child: Text(s.specialty, style: p.body(13)))]),
                const SizedBox(height: 12),
              ],
              Row(children: [Icon(Icons.phone_outlined, size: 15, color: p.gold), const SizedBox(width: 10), Text(s.phone, style: p.body(13))]),
              const SizedBox(height: 12),
              Row(children: [Icon(Icons.email_outlined, size: 15, color: p.gold), const SizedBox(width: 10), Expanded(child: Text(s.email, style: p.body(13)))]),
            ]),
          ),
          const SizedBox(height: 22),
          Row(children: [
            GestureDetector(
              onTap: () { s.active = !s.active; appState.touch(); ss(() {}); setState(() {}); },
              child: MouseRegion(cursor: SystemMouseCursors.click, child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(color: (s.active ? p.success : p.textMuted).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8), border: Border.all(color: (s.active ? p.success : p.textMuted).withValues(alpha: 0.3))),
                child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(s.active ? Icons.toggle_on : Icons.toggle_off_outlined, size: 18, color: s.active ? p.success : p.textMuted), const SizedBox(width: 8), Text(s.active ? 'On Duty' : 'Off Duty', style: p.body(13, color: s.active ? p.success : p.textMuted, weight: FontWeight.w600))]),
              )),
            ),
            const Spacer(),
            GhostButton(label: 'Close', onTap: () => Navigator.pop(ctx)),
            const SizedBox(width: 10),
            GoldButton(label: 'Edit', icon: Icons.edit_outlined, onTap: () { Navigator.pop(ctx); _showForm(existing: s); }),
          ]),
        ]),
      ),
    )));
  }

  Widget _card(AppPalette p, Staff s) {
    final rc = _roleColor(p, s.role);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _showDetail(s),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(8), border: Border.all(color: p.border)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(width: 44, height: 44, alignment: Alignment.center, decoration: BoxDecoration(color: rc.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(8)), child: Text(s.initials, style: p.body(15, color: rc, weight: FontWeight.w700))),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(s.name, style: p.body(14.5, weight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(s.specialty.isEmpty ? s.role.label : s.specialty, style: p.body(12, color: p.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
              ])),
              StatusChip(label: s.role.label, color: rc),
            ]),
            const Spacer(),
            Row(children: [
              Icon(Icons.email_outlined, size: 13, color: p.textMuted),
              const SizedBox(width: 6),
              Expanded(child: Text(s.email, style: p.body(11.5, color: p.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis)),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Icon(Icons.phone_outlined, size: 13, color: p.textMuted),
              const SizedBox(width: 6),
              Text(s.phone, style: p.body(11.5, color: p.textMuted)),
              const Spacer(),
              _sqBtn(p, s.active ? Icons.toggle_on : Icons.toggle_off_outlined, s.active ? p.success : p.textMuted, s.active ? 'Set off-duty' : 'Set on-duty', () { s.active = !s.active; appState.touch(); setState(() {}); }),
              const SizedBox(width: 6),
              _sqBtn(p, Icons.edit_outlined, p.text, 'Edit', () => _showForm(existing: s)),
              const SizedBox(width: 6),
              _sqBtn(p, Icons.delete_outline, p.textMuted, 'Delete', () async { final ok = await confirm(context, 'Delete staff?', 'Remove ${s.name} from the directory.'); if (ok) appState.deleteStaff(s); }),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _sqBtn(AppPalette p, IconData ic, Color c, String tip, VoidCallback onTap) => Tooltip(
        message: tip,
        child: GestureDetector(onTap: onTap, child: MouseRegion(cursor: SystemMouseCursors.click, child: Container(width: 30, height: 30, decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: p.border)), child: Icon(ic, size: 16, color: c)))),
      );

  void _showForm({Staff? existing}) {
    showDialog(context: context, barrierColor: Colors.black.withValues(alpha: 0.55), builder: (_) => StaffFormDialog(existing: existing)).then((_) => setState(() {}));
  }
}

// ─── Performance Tab ─────────────────────────────────────────────────────────
class _PerformanceTab extends StatelessWidget {
  final Color Function(AppPalette, StaffRole) roleColor;
  const _PerformanceTab({required this.roleColor});

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final staff = appState.staff;
    final total = appState.grossRevenue;
    final shares = {
      'Dr. Rehman':    0.46,
      'Dr. Sara Iqbal': 0.33,
      'Dr. Bilal Khan': 0.21,
    };
    return ScrollArea(builder: (sc) => SingleChildScrollView(
      controller: sc,
      padding: const EdgeInsets.fromLTRB(0, 16, 12, 28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        MetricRow([
          MetricCard(title: 'Total Doctors', value: '${staff.where((s) => s.role == StaffRole.doctor).length}', delta: 'Active practitioners', icon: Icons.medical_information_outlined),
          MetricCard(title: 'Clinic Revenue', value: moneyShort(total), delta: 'This period', icon: Icons.account_balance_wallet_outlined),
          MetricCard(title: 'Total Appointments', value: '${appState.appointments.length}', delta: 'All time', icon: Icons.calendar_month_outlined),
          MetricCard(title: 'Treatment Plans', value: '${appState.treatmentPlans.length}', delta: '${appState.treatmentPlans.where((pl) => pl.completedSessions < pl.totalSessions).length} ongoing', icon: Icons.spa_outlined),
        ]),
        const SizedBox(height: 18),
        Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SectionTitle('DOCTOR REVENUE CONTRIBUTION', sub: 'Attributed revenue by practitioner'),
          const SizedBox(height: 18),
          ...staff.where((s) => s.role == StaffRole.doctor).map((doc) {
            final share = shares[doc.name] ?? 0.1;
            final rev   = total * share;
            final apts  = appState.appointments.where((a) => a.surgeon == doc.name).length;
            return Padding(padding: const EdgeInsets.only(bottom: 20), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(width: 44, height: 44, alignment: Alignment.center, decoration: BoxDecoration(color: roleColor(p, doc.role).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)), child: Text(doc.initials, style: p.body(14, color: roleColor(p, doc.role), weight: FontWeight.w700))),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text(doc.name, style: p.body(14, weight: FontWeight.w700))),
                  Text(moneyShort(rev), style: p.body(14, color: p.gold, weight: FontWeight.w700)),
                ]),
                const SizedBox(height: 3),
                Text(doc.specialty.isEmpty ? doc.role.label : doc.specialty, style: p.body(12, color: p.textMuted)),
                const SizedBox(height: 10),
                ClipRRect(borderRadius: BorderRadius.circular(8), child: Stack(children: [Container(height: 10, color: p.surfaceAlt), FractionallySizedBox(widthFactor: share.clamp(0.0, 1.0), child: Container(height: 10, decoration: BoxDecoration(gradient: p.goldGradient)))])),
                const SizedBox(height: 5),
                Row(children: [
                  Text('${(share * 100).toStringAsFixed(0)}% of clinic revenue', style: p.body(11, color: p.textMuted)),
                  const Spacer(),
                  Text('$apts appointments', style: p.body(11, color: p.textMuted)),
                ]),
              ])),
            ]));
          }),
        ])),
        const SizedBox(height: 18),
        Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SectionTitle('APPOINTMENT LOAD', sub: 'Appointments per doctor this period'),
          const SizedBox(height: 14),
          ...staff.where((s) => s.role == StaffRole.doctor).map((doc) {
            final apts = appState.appointments.where((a) => a.surgeon == doc.name).length;
            final max  = staff.where((s) => s.role == StaffRole.doctor).map((d) => appState.appointments.where((a) => a.surgeon == d.name).length).fold(1, (prev, e) => e > prev ? e : prev);
            return Padding(padding: const EdgeInsets.only(bottom: 14), child: Row(children: [
              SizedBox(width: 140, child: Text(doc.name, style: p.body(13), overflow: TextOverflow.ellipsis)),
              const SizedBox(width: 12),
              Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(6), child: Stack(children: [Container(height: 8, color: p.surfaceAlt), FractionallySizedBox(widthFactor: apts == 0 ? 0.0 : (apts / max).clamp(0.0, 1.0), child: Container(height: 8, decoration: BoxDecoration(gradient: p.goldGradient)))]))),
              const SizedBox(width: 12),
              SizedBox(width: 30, child: Text('$apts', style: p.body(12.5, color: p.textMuted), textAlign: TextAlign.right)),
            ]));
          }),
        ])),
      ]),
    ));
  }
}

// ─── Commission Tab ───────────────────────────────────────────────────────────
class _CommissionTab extends StatefulWidget {
  final Color Function(AppPalette, StaffRole) roleColor;
  const _CommissionTab({required this.roleColor});
  @override State<_CommissionTab> createState() => _CommissionTabState();
}

class _CommissionTabState extends State<_CommissionTab> {
  final _commRates = <String, double>{};
  bool _edited = false;

  double _rate(Staff s) => _commRates[s.id] ?? _defaultRate(s.role);
  double _defaultRate(StaffRole r) => switch (r) {
    StaffRole.doctor => 0.10,
    StaffRole.nurse  => 0.05,
    StaffRole.receptionist => 0.02,
    StaffRole.manager => 0.03,
  };
  double _revenue(Staff s) => appState.grossRevenue * _shareFor(s);
  double _shareFor(Staff s) => switch (s.name) {
    'Dr. Rehman'    => 0.46,
    'Dr. Sara Iqbal' => 0.33,
    'Dr. Bilal Khan' => 0.21,
    _ => 0.0,
  };

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final staff = appState.staff;
    final totalComm = staff.fold(0.0, (s, m) => s + (_revenue(m) * _rate(m)));
    return ScrollArea(builder: (sc) => SingleChildScrollView(
      controller: sc,
      padding: const EdgeInsets.fromLTRB(0, 16, 12, 28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        MetricRow([
          MetricCard(title: 'Total Commission', value: moneyShort(totalComm), delta: 'This period', icon: Icons.payments_outlined),
          MetricCard(title: 'Doctor Commission', value: moneyShort(staff.where((s) => s.role == StaffRole.doctor).fold(0.0, (sum, m) => sum + _revenue(m) * _rate(m))), delta: '10% default rate', icon: Icons.medical_information_outlined),
          MetricCard(title: 'Staff Commission', value: moneyShort(staff.where((s) => s.role != StaffRole.doctor).fold(0.0, (sum, m) => sum + _revenue(m) * _rate(m))), delta: 'Support team', icon: Icons.support_agent_outlined),
          MetricCard(title: 'Staff Members', value: '${staff.length}', delta: '${staff.where((s) => s.active).length} on duty', icon: Icons.groups_2_outlined),
        ]),
        const SizedBox(height: 18),
        Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SectionTitle('COMMISSION LEDGER', sub: 'Adjust rates and view earned amounts'),
            ])),
            if (_edited) GoldButton(label: 'Save Rates', icon: Icons.check, dense: true, onTap: () { setState(() => _edited = false); toast(context, 'Commission rates saved'); }),
          ]),
          const SizedBox(height: 16),
          FullWidthDataTable(child: DataTable(
            headingRowHeight: 36, dataRowMinHeight: 52, dataRowMaxHeight: 52,
            headingTextStyle: p.body(11, color: p.textMuted, weight: FontWeight.w700),
            dataTextStyle: p.body(12.5),
            columns: const [
              DataColumn(label: Text('STAFF MEMBER')),
              DataColumn(label: Text('ROLE')),
              DataColumn(label: Text('BASE REVENUE'), numeric: true),
              DataColumn(label: Text('RATE %')),
              DataColumn(label: Text('COMMISSION'), numeric: true),
              DataColumn(label: Text('STATUS')),
            ],
            rows: staff.map((s) {
              final rev  = _revenue(s);
              final rate = _rate(s);
              final comm = rev * rate;
              return DataRow(cells: [
                DataCell(Row(children: [
                  Container(width: 36, height: 36, alignment: Alignment.center, decoration: BoxDecoration(color: widget.roleColor(p, s.role).withValues(alpha: 0.14), borderRadius: BorderRadius.circular(8)), child: Text(s.initials, style: p.body(12, color: widget.roleColor(p, s.role), weight: FontWeight.w700))),
                  const SizedBox(width: 10),
                  Text(s.name, style: p.body(13, weight: FontWeight.w600)),
                ])),
                DataCell(StatusChip(label: s.role.label, color: widget.roleColor(p, s.role))),
                DataCell(Text(moneyShort(rev))),
                DataCell(SizedBox(width: 100, child: Row(children: [
                  SizedBox(width: 50, child: TextFormField(
                    initialValue: '${(rate * 100).toStringAsFixed(0)}',
                    style: p.body(12.5),
                    decoration: InputDecoration(suffixText: '%', suffixStyle: p.body(11, color: p.textMuted), border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: p.border)), contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6)),
                    keyboardType: TextInputType.number,
                    onChanged: (v) { final val = double.tryParse(v); if (val != null) setState(() { _commRates[s.id] = val / 100; _edited = true; }); },
                  )),
                ]))),
                DataCell(Text(moneyShort(comm), style: p.body(13, weight: FontWeight.w600, color: p.gold))),
                DataCell(StatusChip(label: s.active ? 'Active' : 'Inactive', color: s.active ? Colors.green : p.textMuted)),
              ]);
            }).toList(),
          )),
        ])),
      ]),
    ));
  }
}

// ─── Documents Tab ────────────────────────────────────────────────────────────
class _DocumentsTab extends StatefulWidget {
  final Color Function(AppPalette, StaffRole) roleColor;
  const _DocumentsTab({required this.roleColor});
  @override State<_DocumentsTab> createState() => _DocumentsTabState();
}

class _DocumentsTabState extends State<_DocumentsTab> {
  void _showAddDialog() {
    final p = appState.palette;
    Staff? selectedStaff = appState.staff.isNotEmpty ? appState.staff.first : null;
    String docType = 'CNIC';
    final titleC = TextEditingController();
    final dateC = TextEditingController(text: prettyShort(DateTime.now()));
    final notesC = TextEditingController();
    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, ss) => Dialog(
      backgroundColor: p.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: p.border)),
      child: Container(width: 500, padding: const EdgeInsets.all(26), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: p.gold.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)), child: Icon(Icons.upload_file_outlined, color: p.gold)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('ADD DOCUMENT', style: p.display(22)), Text('Attach a staff document', style: p.body(12.5, color: p.textMuted))])),
          IconButton(onPressed: () => Navigator.pop(ctx), icon: Icon(Icons.close, color: p.textMuted)),
        ]),
        const SizedBox(height: 18),
        Dropdown2<Staff>(
          label: 'Staff Member',
          value: selectedStaff,
          items: appState.staff.map((s) => DropdownMenuItem(value: s, child: Text(s.name))).toList(),
          onChanged: (v) => ss(() => selectedStaff = v),
        ),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: Dropdown2<String>(
            label: 'Document Type',
            value: docType,
            items: ['CNIC', 'Degree', 'Contract', 'Medical', 'Other'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
            onChanged: (v) => ss(() => docType = v ?? 'CNIC'),
          )),
          const SizedBox(width: 14),
          Expanded(child: FormField2(label: 'Upload Date', controller: dateC, hint: 'e.g. 3 Jul')),
        ]),
        const SizedBox(height: 14),
        FormField2(label: 'Title', controller: titleC, hint: 'e.g. National ID Card'),
        const SizedBox(height: 14),
        FormField2(label: 'Notes (optional)', controller: notesC, hint: 'Any additional notes'),
        const SizedBox(height: 22),
        Row(children: [const Spacer(), GhostButton(label: 'Cancel', onTap: () => Navigator.pop(ctx)), const SizedBox(width: 12), GoldButton(label: 'Add Document', icon: Icons.check, onTap: () {
          if (selectedStaff == null || titleC.text.trim().isEmpty) { toast(ctx, 'Please fill in required fields'); return; }
          selectedStaff!.documents.add(StaffDocument(id: 'DOC-${selectedStaff!.documents.length + 1}', title: titleC.text.trim(), docType: docType, uploadDate: dateC.text.trim(), notes: notesC.text.trim().isEmpty ? null : notesC.text.trim()));
          appState.touch();
          Navigator.pop(ctx);
          setState(() {});
          toast(context, 'Document added');
        })],
        ),
      ])),
    )));
  }

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final rows = <({Staff staff, StaffDocument doc})>[];
    for (final s in appState.staff) {
      for (final d in s.documents) rows.add((staff: s, doc: d));
    }
    return ScrollArea(builder: (sc) => SingleChildScrollView(
      controller: sc,
      padding: const EdgeInsets.fromLTRB(0, 16, 12, 28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('STAFF DOCUMENTS', style: p.display(20)),
            Text('${rows.length} document${rows.length == 1 ? '' : 's'} on file', style: p.body(12.5, color: p.textMuted)),
          ])),
          GoldButton(label: 'Add Document', icon: Icons.upload_file_outlined, onTap: _showAddDialog),
        ]),
        const SizedBox(height: 18),
        Panel(child: rows.isEmpty
            ? Padding(padding: const EdgeInsets.all(32), child: Center(child: Text('No documents uploaded yet.', style: p.body(13, color: p.textMuted))))
            : FullWidthDataTable(child: DataTable(
                headingRowHeight: 36, dataRowMinHeight: 48, dataRowMaxHeight: 48,
                headingTextStyle: p.body(11, color: p.textMuted, weight: FontWeight.w700),
                dataTextStyle: p.body(12.5),
                columns: const [
                  DataColumn(label: Text('EMPLOYEE')),
                  DataColumn(label: Text('DOC TYPE')),
                  DataColumn(label: Text('TITLE')),
                  DataColumn(label: Text('DATE')),
                  DataColumn(label: Text('NOTES')),
                  DataColumn(label: Text('ACTIONS')),
                ],
                rows: rows.map((r) => DataRow(cells: [
                  DataCell(Row(children: [
                    Container(width: 32, height: 32, alignment: Alignment.center, decoration: BoxDecoration(color: widget.roleColor(p, r.staff.role).withValues(alpha: 0.14), borderRadius: BorderRadius.circular(6)), child: Text(r.staff.initials, style: p.body(11, color: widget.roleColor(p, r.staff.role), weight: FontWeight.w700))),
                    const SizedBox(width: 8),
                    Text(r.staff.name, style: p.body(13, weight: FontWeight.w600)),
                  ])),
                  DataCell(StatusChip(label: r.doc.docType, color: p.info)),
                  DataCell(Text(r.doc.title)),
                  DataCell(Text(r.doc.uploadDate)),
                  DataCell(Text(r.doc.notes ?? '—', style: p.body(12, color: p.textMuted))),
                  DataCell(Tooltip(message: 'Delete', child: GestureDetector(onTap: () async {
                    final ok = await confirm(context, 'Delete document?', 'Remove "${r.doc.title}" from ${r.staff.name}.');
                    if (ok) { r.staff.documents.remove(r.doc); appState.touch(); setState(() {}); }
                  }, child: MouseRegion(cursor: SystemMouseCursors.click, child: Icon(Icons.delete_outline, size: 18, color: p.danger))))),
                ])).toList(),
              )),
        ),
      ]),
    ));
  }
}

// ─── Contracts Tab ────────────────────────────────────────────────────────────
class _ContractsTab extends StatefulWidget {
  final Color Function(AppPalette, StaffRole) roleColor;
  const _ContractsTab({required this.roleColor});
  @override State<_ContractsTab> createState() => _ContractsTabState();
}

class _ContractsTabState extends State<_ContractsTab> {
  void _showAddDialog() {
    final p = appState.palette;
    Staff? selectedStaff = appState.staff.isNotEmpty ? appState.staff.first : null;
    String contractType = 'Full-Time';
    final startC = TextEditingController(text: prettyShort(DateTime.now()));
    final endC = TextEditingController();
    final salaryC = TextEditingController();
    final notesC = TextEditingController();
    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, ss) => Dialog(
      backgroundColor: p.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: p.border)),
      child: Container(width: 520, padding: const EdgeInsets.all(26), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: p.gold.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)), child: Icon(Icons.description_outlined, color: p.gold)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('ADD CONTRACT', style: p.display(22)), Text('Define employment contract terms', style: p.body(12.5, color: p.textMuted))])),
          IconButton(onPressed: () => Navigator.pop(ctx), icon: Icon(Icons.close, color: p.textMuted)),
        ]),
        const SizedBox(height: 18),
        Dropdown2<Staff>(
          label: 'Staff Member',
          value: selectedStaff,
          items: appState.staff.map((s) => DropdownMenuItem(value: s, child: Text(s.name))).toList(),
          onChanged: (v) => ss(() => selectedStaff = v),
        ),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: Dropdown2<String>(
            label: 'Contract Type',
            value: contractType,
            items: ['Full-Time', 'Part-Time', 'Contract', 'Internship'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
            onChanged: (v) => ss(() => contractType = v ?? 'Full-Time'),
          )),
          const SizedBox(width: 14),
          Expanded(child: FormField2(label: 'Monthly Salary (PKR)', controller: salaryC, hint: 'e.g. 50000', keyboard: TextInputType.number)),
        ]),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: FormField2(label: 'Start Date', controller: startC, hint: 'e.g. 1 Jan 2026')),
          const SizedBox(width: 14),
          Expanded(child: FormField2(label: 'End Date', controller: endC, hint: 'e.g. 31 Dec 2026')),
        ]),
        const SizedBox(height: 14),
        FormField2(label: 'Notes (optional)', controller: notesC, hint: 'Additional contract notes'),
        const SizedBox(height: 22),
        Row(children: [const Spacer(), GhostButton(label: 'Cancel', onTap: () => Navigator.pop(ctx)), const SizedBox(width: 12), GoldButton(label: 'Add Contract', icon: Icons.check, onTap: () {
          if (selectedStaff == null || salaryC.text.trim().isEmpty || endC.text.trim().isEmpty) { toast(ctx, 'Please fill in all required fields'); return; }
          final salary = double.tryParse(salaryC.text.trim());
          if (salary == null) { toast(ctx, 'Invalid salary amount'); return; }
          selectedStaff!.contracts.add(StaffContract(id: 'CON-${selectedStaff!.contracts.length + 1}', type: contractType, startDate: startC.text.trim(), endDate: endC.text.trim(), salary: salary, notes: notesC.text.trim().isEmpty ? null : notesC.text.trim()));
          appState.touch();
          Navigator.pop(ctx);
          setState(() {});
          toast(context, 'Contract added');
        })],
        ),
      ])),
    )));
  }

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final rows = <({Staff staff, StaffContract contract})>[];
    for (final s in appState.staff) {
      for (final c in s.contracts) rows.add((staff: s, contract: c));
    }
    return ScrollArea(builder: (sc) => SingleChildScrollView(
      controller: sc,
      padding: const EdgeInsets.fromLTRB(0, 16, 12, 28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('STAFF CONTRACTS', style: p.display(20)),
            Text('${rows.length} contract${rows.length == 1 ? '' : 's'} on record', style: p.body(12.5, color: p.textMuted)),
          ])),
          GoldButton(label: 'Add Contract', icon: Icons.description_outlined, onTap: _showAddDialog),
        ]),
        const SizedBox(height: 18),
        Panel(child: rows.isEmpty
            ? Padding(padding: const EdgeInsets.all(32), child: Center(child: Text('No contracts on record.', style: p.body(13, color: p.textMuted))))
            : FullWidthDataTable(child: DataTable(
                headingRowHeight: 36, dataRowMinHeight: 48, dataRowMaxHeight: 48,
                headingTextStyle: p.body(11, color: p.textMuted, weight: FontWeight.w700),
                dataTextStyle: p.body(12.5),
                columns: const [
                  DataColumn(label: Text('EMPLOYEE')),
                  DataColumn(label: Text('TYPE')),
                  DataColumn(label: Text('START')),
                  DataColumn(label: Text('END')),
                  DataColumn(label: Text('SALARY'), numeric: true),
                  DataColumn(label: Text('STATUS')),
                  DataColumn(label: Text('ACTIONS')),
                ],
                rows: rows.map((r) => DataRow(cells: [
                  DataCell(Row(children: [
                    Container(width: 32, height: 32, alignment: Alignment.center, decoration: BoxDecoration(color: widget.roleColor(p, r.staff.role).withValues(alpha: 0.14), borderRadius: BorderRadius.circular(6)), child: Text(r.staff.initials, style: p.body(11, color: widget.roleColor(p, r.staff.role), weight: FontWeight.w700))),
                    const SizedBox(width: 8),
                    Text(r.staff.name, style: p.body(13, weight: FontWeight.w600)),
                  ])),
                  DataCell(Text(r.contract.type)),
                  DataCell(Text(r.contract.startDate)),
                  DataCell(Text(r.contract.endDate)),
                  DataCell(Text(money(r.contract.salary), style: p.body(13, color: p.gold, weight: FontWeight.w600))),
                  DataCell(StatusChip(label: r.contract.active ? 'Active' : 'Expired', color: r.contract.active ? p.success : p.danger)),
                  DataCell(Row(children: [
                    Tooltip(message: r.contract.active ? 'Mark Expired' : 'Mark Active', child: GestureDetector(onTap: () { r.contract.active = !r.contract.active; appState.touch(); setState(() {}); }, child: MouseRegion(cursor: SystemMouseCursors.click, child: Icon(r.contract.active ? Icons.toggle_on : Icons.toggle_off_outlined, size: 18, color: r.contract.active ? p.success : p.textMuted)))),
                    const SizedBox(width: 10),
                    Tooltip(message: 'Delete', child: GestureDetector(onTap: () async {
                      final ok = await confirm(context, 'Delete contract?', 'Remove this contract for ${r.staff.name}.');
                      if (ok) { r.staff.contracts.remove(r.contract); appState.touch(); setState(() {}); }
                    }, child: MouseRegion(cursor: SystemMouseCursors.click, child: Icon(Icons.delete_outline, size: 18, color: p.danger)))),
                  ])),
                ])).toList(),
              )),
        ),
      ]),
    ));
  }
}

// ─── Incentives Tab ───────────────────────────────────────────────────────────
class _IncentivesTab extends StatefulWidget {
  final Color Function(AppPalette, StaffRole) roleColor;
  const _IncentivesTab({required this.roleColor});
  @override State<_IncentivesTab> createState() => _IncentivesTabState();
}

class _IncentivesTabState extends State<_IncentivesTab> {
  void _showAddDialog() {
    final p = appState.palette;
    Staff? selectedStaff = appState.staff.isNotEmpty ? appState.staff.first : null;
    final monthC = TextEditingController(text: 'Jul 2026');
    final reasonC = TextEditingController();
    final amountC = TextEditingController();
    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, ss) => Dialog(
      backgroundColor: p.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: p.border)),
      child: Container(width: 500, padding: const EdgeInsets.all(26), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: p.gold.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)), child: Icon(Icons.stars_outlined, color: p.gold)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('ADD INCENTIVE', style: p.display(22)), Text('Record a staff incentive or bonus', style: p.body(12.5, color: p.textMuted))])),
          IconButton(onPressed: () => Navigator.pop(ctx), icon: Icon(Icons.close, color: p.textMuted)),
        ]),
        const SizedBox(height: 18),
        Dropdown2<Staff>(
          label: 'Staff Member',
          value: selectedStaff,
          items: appState.staff.map((s) => DropdownMenuItem(value: s, child: Text(s.name))).toList(),
          onChanged: (v) => ss(() => selectedStaff = v),
        ),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: FormField2(label: 'Month', controller: monthC, hint: 'e.g. Jul 2026')),
          const SizedBox(width: 14),
          Expanded(child: FormField2(label: 'Amount (PKR)', controller: amountC, hint: 'e.g. 5000', keyboard: TextInputType.number)),
        ]),
        const SizedBox(height: 14),
        FormField2(label: 'Reason', controller: reasonC, hint: 'e.g. Outstanding performance'),
        const SizedBox(height: 22),
        Row(children: [const Spacer(), GhostButton(label: 'Cancel', onTap: () => Navigator.pop(ctx)), const SizedBox(width: 12), GoldButton(label: 'Add Incentive', icon: Icons.check, onTap: () {
          if (selectedStaff == null || reasonC.text.trim().isEmpty || amountC.text.trim().isEmpty) { toast(ctx, 'Please fill in all required fields'); return; }
          final amount = double.tryParse(amountC.text.trim());
          if (amount == null) { toast(ctx, 'Invalid amount'); return; }
          selectedStaff!.incentives.add(StaffIncentive(id: 'INC-${selectedStaff!.incentives.length + 1}', month: monthC.text.trim(), reason: reasonC.text.trim(), amount: amount));
          appState.touch();
          Navigator.pop(ctx);
          setState(() {});
          toast(context, 'Incentive added');
        })],
        ),
      ])),
    )));
  }

  String _nextStatus(String current) => switch (current) {
    'Pending' => 'Approved',
    'Approved' => 'Paid',
    _ => 'Pending',
  };

  Color _statusColor(AppPalette p, String status) => switch (status) {
    'Approved' => p.info,
    'Paid' => p.success,
    _ => p.warning,
  };

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final rows = <({Staff staff, StaffIncentive incentive})>[];
    for (final s in appState.staff) {
      for (final i in s.incentives) rows.add((staff: s, incentive: i));
    }
    final totalAmount = rows.fold(0.0, (sum, r) => sum + r.incentive.amount);
    final paidCount = rows.where((r) => r.incentive.status == 'Paid').length;
    return ScrollArea(builder: (sc) => SingleChildScrollView(
      controller: sc,
      padding: const EdgeInsets.fromLTRB(0, 16, 12, 28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        MetricRow([
          MetricCard(title: 'Total Incentives', value: '${rows.length}', delta: 'All time', icon: Icons.stars_outlined),
          MetricCard(title: 'Total Amount', value: moneyShort(totalAmount), delta: 'All incentives', icon: Icons.payments_outlined),
          MetricCard(title: 'Paid Out', value: '$paidCount', delta: 'of ${rows.length} incentives', icon: Icons.check_circle_outline),
          MetricCard(title: 'Pending Approval', value: '${rows.where((r) => r.incentive.status == 'Pending').length}', delta: 'Awaiting review', icon: Icons.pending_outlined),
        ]),
        const SizedBox(height: 18),
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('INCENTIVES & BONUSES', style: p.display(20)),
            Text('Tap status to cycle: Pending → Approved → Paid', style: p.body(12.5, color: p.textMuted)),
          ])),
          GoldButton(label: 'Add Incentive', icon: Icons.stars_outlined, onTap: _showAddDialog),
        ]),
        const SizedBox(height: 18),
        Panel(child: rows.isEmpty
            ? Padding(padding: const EdgeInsets.all(32), child: Center(child: Text('No incentives recorded yet.', style: p.body(13, color: p.textMuted))))
            : FullWidthDataTable(child: DataTable(
                headingRowHeight: 36, dataRowMinHeight: 48, dataRowMaxHeight: 48,
                headingTextStyle: p.body(11, color: p.textMuted, weight: FontWeight.w700),
                dataTextStyle: p.body(12.5),
                columns: const [
                  DataColumn(label: Text('EMPLOYEE')),
                  DataColumn(label: Text('MONTH')),
                  DataColumn(label: Text('REASON')),
                  DataColumn(label: Text('AMOUNT'), numeric: true),
                  DataColumn(label: Text('STATUS')),
                  DataColumn(label: Text('ACTIONS')),
                ],
                rows: rows.map((r) => DataRow(cells: [
                  DataCell(Row(children: [
                    Container(width: 32, height: 32, alignment: Alignment.center, decoration: BoxDecoration(color: widget.roleColor(p, r.staff.role).withValues(alpha: 0.14), borderRadius: BorderRadius.circular(6)), child: Text(r.staff.initials, style: p.body(11, color: widget.roleColor(p, r.staff.role), weight: FontWeight.w700))),
                    const SizedBox(width: 8),
                    Text(r.staff.name, style: p.body(13, weight: FontWeight.w600)),
                  ])),
                  DataCell(Text(r.incentive.month)),
                  DataCell(Text(r.incentive.reason)),
                  DataCell(Text(money(r.incentive.amount), style: p.body(13, color: p.gold, weight: FontWeight.w600))),
                  DataCell(Tooltip(message: 'Click to advance status', child: GestureDetector(onTap: () { r.incentive.status = _nextStatus(r.incentive.status); appState.touch(); setState(() {}); }, child: MouseRegion(cursor: SystemMouseCursors.click, child: StatusChip(label: r.incentive.status, color: _statusColor(p, r.incentive.status)))))),
                  DataCell(Tooltip(message: 'Delete', child: GestureDetector(onTap: () async {
                    final ok = await confirm(context, 'Delete incentive?', 'Remove this incentive for ${r.staff.name}.');
                    if (ok) { r.staff.incentives.remove(r.incentive); appState.touch(); setState(() {}); }
                  }, child: MouseRegion(cursor: SystemMouseCursors.click, child: Icon(Icons.delete_outline, size: 18, color: p.danger))))),
                ])).toList(),
              )),
        ),
      ]),
    ));
  }
}

// ─── Warnings Tab ─────────────────────────────────────────────────────────────
class _WarningsTab extends StatefulWidget {
  final Color Function(AppPalette, StaffRole) roleColor;
  const _WarningsTab({required this.roleColor});
  @override State<_WarningsTab> createState() => _WarningsTabState();
}

class _WarningsTabState extends State<_WarningsTab> {
  void _showAddDialog() {
    final p = appState.palette;
    Staff? selectedStaff = appState.staff.isNotEmpty ? appState.staff.first : null;
    String severity = 'Minor';
    final reasonC = TextEditingController();
    final issuedByC = TextEditingController();
    final dateC = TextEditingController(text: prettyShort(DateTime.now()));
    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, ss) => Dialog(
      backgroundColor: p.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: p.border)),
      child: Container(width: 500, padding: const EdgeInsets.all(26), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: p.danger.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)), child: Icon(Icons.warning_amber_outlined, color: p.danger)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('ISSUE WARNING', style: p.display(22)), Text('Record a disciplinary warning', style: p.body(12.5, color: p.textMuted))])),
          IconButton(onPressed: () => Navigator.pop(ctx), icon: Icon(Icons.close, color: p.textMuted)),
        ]),
        const SizedBox(height: 18),
        Dropdown2<Staff>(
          label: 'Staff Member',
          value: selectedStaff,
          items: appState.staff.map((s) => DropdownMenuItem(value: s, child: Text(s.name))).toList(),
          onChanged: (v) => ss(() => selectedStaff = v),
        ),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: Dropdown2<String>(
            label: 'Severity',
            value: severity,
            items: ['Minor', 'Major', 'Final'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
            onChanged: (v) => ss(() => severity = v ?? 'Minor'),
          )),
          const SizedBox(width: 14),
          Expanded(child: FormField2(label: 'Date', controller: dateC, hint: 'e.g. 3 Jul')),
        ]),
        const SizedBox(height: 14),
        FormField2(label: 'Issued By', controller: issuedByC, hint: 'e.g. Dr. Rehman / Manager'),
        const SizedBox(height: 14),
        FormField2(label: 'Reason', controller: reasonC, hint: 'Describe the disciplinary issue'),
        const SizedBox(height: 22),
        Row(children: [const Spacer(), GhostButton(label: 'Cancel', onTap: () => Navigator.pop(ctx)), const SizedBox(width: 12), GoldButton(label: 'Issue Warning', icon: Icons.check, onTap: () {
          if (selectedStaff == null || reasonC.text.trim().isEmpty || issuedByC.text.trim().isEmpty) { toast(ctx, 'Please fill in all required fields'); return; }
          selectedStaff!.warnings.add(StaffWarning(id: 'WARN-${selectedStaff!.warnings.length + 1}', date: dateC.text.trim(), reason: reasonC.text.trim(), severity: severity, issuedBy: issuedByC.text.trim()));
          appState.touch();
          Navigator.pop(ctx);
          setState(() {});
          toast(context, 'Warning issued');
        })],
        ),
      ])),
    )));
  }

  Color _severityColor(AppPalette p, String severity) => switch (severity) {
    'Major' => p.warning,
    'Final' => p.danger,
    _ => p.info,
  };

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final rows = <({Staff staff, StaffWarning warning})>[];
    for (final s in appState.staff) {
      for (final w in s.warnings) rows.add((staff: s, warning: w));
    }
    return ScrollArea(builder: (sc) => SingleChildScrollView(
      controller: sc,
      padding: const EdgeInsets.fromLTRB(0, 16, 12, 28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('DISCIPLINARY WARNINGS', style: p.display(20)),
            Text('${rows.length} warning${rows.length == 1 ? '' : 's'} on record', style: p.body(12.5, color: p.textMuted)),
          ])),
          GoldButton(label: 'Issue Warning', icon: Icons.warning_amber_outlined, onTap: _showAddDialog),
        ]),
        const SizedBox(height: 18),
        Panel(child: rows.isEmpty
            ? Padding(padding: const EdgeInsets.all(32), child: Center(child: Text('No warnings on record.', style: p.body(13, color: p.textMuted))))
            : FullWidthDataTable(child: DataTable(
                headingRowHeight: 36, dataRowMinHeight: 48, dataRowMaxHeight: 52,
                headingTextStyle: p.body(11, color: p.textMuted, weight: FontWeight.w700),
                dataTextStyle: p.body(12.5),
                columns: const [
                  DataColumn(label: Text('EMPLOYEE')),
                  DataColumn(label: Text('DATE')),
                  DataColumn(label: Text('SEVERITY')),
                  DataColumn(label: Text('REASON')),
                  DataColumn(label: Text('ISSUED BY')),
                  DataColumn(label: Text('ACTIONS')),
                ],
                rows: rows.map((r) => DataRow(cells: [
                  DataCell(Row(children: [
                    Container(width: 32, height: 32, alignment: Alignment.center, decoration: BoxDecoration(color: widget.roleColor(p, r.staff.role).withValues(alpha: 0.14), borderRadius: BorderRadius.circular(6)), child: Text(r.staff.initials, style: p.body(11, color: widget.roleColor(p, r.staff.role), weight: FontWeight.w700))),
                    const SizedBox(width: 8),
                    Text(r.staff.name, style: p.body(13, weight: FontWeight.w600)),
                  ])),
                  DataCell(Text(r.warning.date)),
                  DataCell(StatusChip(label: r.warning.severity, color: _severityColor(p, r.warning.severity))),
                  DataCell(Expanded(child: Text(r.warning.reason, maxLines: 2, overflow: TextOverflow.ellipsis))),
                  DataCell(Text(r.warning.issuedBy, style: p.body(12, color: p.textMuted))),
                  DataCell(Tooltip(message: 'Delete', child: GestureDetector(onTap: () async {
                    final ok = await confirm(context, 'Delete warning?', 'Remove this warning for ${r.staff.name}.');
                    if (ok) { r.staff.warnings.remove(r.warning); appState.touch(); setState(() {}); }
                  }, child: MouseRegion(cursor: SystemMouseCursors.click, child: Icon(Icons.delete_outline, size: 18, color: p.danger))))),
                ])).toList(),
              )),
        ),
      ]),
    ));
  }
}

// ─── Exit Management Tab ──────────────────────────────────────────────────────
class _ExitMgmtTab extends StatefulWidget {
  final Color Function(AppPalette, StaffRole) roleColor;
  const _ExitMgmtTab({required this.roleColor});
  @override State<_ExitMgmtTab> createState() => _ExitMgmtTabState();
}

class _ExitMgmtTabState extends State<_ExitMgmtTab> {
  void _showInitiateDialog() {
    final p = appState.palette;
    final eligibleStaff = appState.staff.where((s) => s.exitRecord == null).toList();
    if (eligibleStaff.isEmpty) { toast(context, 'All staff already have exit records'); return; }
    Staff? selectedStaff = eligibleStaff.first;
    String exitType = 'Resignation';
    final lastDayC = TextEditingController(text: prettyShort(DateTime.now()));
    final reasonC = TextEditingController();
    final notesC = TextEditingController();
    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, ss) => Dialog(
      backgroundColor: p.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: p.border)),
      child: Container(width: 520, padding: const EdgeInsets.all(26), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: p.warning.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)), child: Icon(Icons.exit_to_app_outlined, color: p.warning)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('INITIATE EXIT', style: p.display(22)), Text('Begin the offboarding process', style: p.body(12.5, color: p.textMuted))])),
          IconButton(onPressed: () => Navigator.pop(ctx), icon: Icon(Icons.close, color: p.textMuted)),
        ]),
        const SizedBox(height: 18),
        Dropdown2<Staff>(
          label: 'Staff Member',
          value: selectedStaff,
          items: eligibleStaff.map((s) => DropdownMenuItem(value: s, child: Text(s.name))).toList(),
          onChanged: (v) => ss(() => selectedStaff = v),
        ),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: Dropdown2<String>(
            label: 'Exit Type',
            value: exitType,
            items: ['Resignation', 'Termination', 'Retirement'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
            onChanged: (v) => ss(() => exitType = v ?? 'Resignation'),
          )),
          const SizedBox(width: 14),
          Expanded(child: FormField2(label: 'Last Working Day', controller: lastDayC, hint: 'e.g. 31 Jul')),
        ]),
        const SizedBox(height: 14),
        FormField2(label: 'Reason', controller: reasonC, hint: 'Reason for exit'),
        const SizedBox(height: 14),
        FormField2(label: 'Notes (optional)', controller: notesC, hint: 'Handover notes, etc.'),
        const SizedBox(height: 22),
        Row(children: [const Spacer(), GhostButton(label: 'Cancel', onTap: () => Navigator.pop(ctx)), const SizedBox(width: 12), GoldButton(label: 'Initiate Exit', icon: Icons.check, onTap: () {
          if (selectedStaff == null || reasonC.text.trim().isEmpty || lastDayC.text.trim().isEmpty) { toast(ctx, 'Please fill in all required fields'); return; }
          selectedStaff!.exitRecord = StaffExitRecord(exitType: exitType, lastWorkingDay: lastDayC.text.trim(), reason: reasonC.text.trim(), notes: notesC.text.trim().isEmpty ? null : notesC.text.trim());
          appState.touch();
          Navigator.pop(ctx);
          setState(() {});
          toast(context, 'Exit initiated for ${selectedStaff!.name}');
        })],
        ),
      ])),
    )));
  }

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final exiting = appState.staff.where((s) => s.exitRecord != null).toList();
    final thisMonth = prettyShort(DateTime.now()).split(' ').last;
    final thisMonthExits = exiting.where((s) => s.exitRecord!.lastWorkingDay.contains(thisMonth)).length;
    final pendingHandover = exiting.where((s) => s.exitRecord!.handoverStatus == 'Pending').length;
    final settled = exiting.where((s) => s.exitRecord!.settled).length;

    return ScrollArea(builder: (sc) => SingleChildScrollView(
      controller: sc,
      padding: const EdgeInsets.fromLTRB(0, 16, 12, 28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        MetricRow([
          MetricCard(title: 'Total Exits', value: '${exiting.length}', delta: 'All time', icon: Icons.exit_to_app_outlined),
          MetricCard(title: 'This Month', value: '$thisMonthExits', delta: 'Recent departures', icon: Icons.calendar_today_outlined),
          MetricCard(title: 'Pending Handover', value: '$pendingHandover', delta: 'Needs completion', icon: Icons.pending_outlined),
          MetricCard(title: 'Final Settlements', value: '$settled', delta: 'of ${exiting.length} exits', icon: Icons.check_circle_outline),
        ]),
        const SizedBox(height: 18),
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('EXIT MANAGEMENT', style: p.display(20)),
            Text('Track offboarding, handovers and final settlements', style: p.body(12.5, color: p.textMuted)),
          ])),
          GoldButton(label: 'Initiate Exit', icon: Icons.exit_to_app_outlined, onTap: _showInitiateDialog),
        ]),
        const SizedBox(height: 18),
        if (exiting.isEmpty)
          Panel(child: Padding(padding: const EdgeInsets.all(32), child: Center(child: Text('No exits initiated.', style: p.body(13, color: p.textMuted)))))
        else
          ...exiting.map((s) {
            final ex = s.exitRecord!;
            final rc = widget.roleColor(p, s.role);
            return Padding(padding: const EdgeInsets.only(bottom: 14), child: Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(width: 48, height: 48, alignment: Alignment.center, decoration: BoxDecoration(color: rc.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(10)), child: Text(s.initials, style: p.body(16, color: rc, weight: FontWeight.w700))),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(s.name, style: p.body(15, weight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Wrap(spacing: 8, runSpacing: 4, children: [
                    StatusChip(label: s.role.label, color: rc),
                    StatusChip(label: ex.exitType, color: ex.exitType == 'Termination' ? p.danger : p.warning),
                  ]),
                ])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  StatusChip(label: ex.settled ? 'Settled' : 'Unsettled', color: ex.settled ? p.success : p.danger),
                  const SizedBox(height: 6),
                  StatusChip(label: 'Handover: ${ex.handoverStatus}', color: ex.handoverStatus == 'Complete' ? p.success : p.warning),
                ]),
              ]),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(8), border: Border.all(color: p.border)),
                child: Column(children: [
                  Row(children: [
                    Icon(Icons.calendar_today_outlined, size: 14, color: p.textMuted), const SizedBox(width: 8),
                    Text('Last Working Day: ', style: p.body(12, color: p.textMuted)),
                    Text(ex.lastWorkingDay, style: p.body(12, weight: FontWeight.w600)),
                  ]),
                  if (ex.reason.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Icon(Icons.info_outline, size: 14, color: p.textMuted), const SizedBox(width: 8),
                      Expanded(child: Text(ex.reason, style: p.body(12, color: p.textMuted))),
                    ]),
                  ],
                  if (ex.notes != null) ...[
                    const SizedBox(height: 8),
                    Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Icon(Icons.note_outlined, size: 14, color: p.textMuted), const SizedBox(width: 8),
                      Expanded(child: Text(ex.notes!, style: p.body(12, color: p.textMuted))),
                    ]),
                  ],
                ]),
              ),
              const SizedBox(height: 12),
              Row(children: [
                GhostButton(label: ex.handoverStatus == 'Complete' ? 'Handover Done' : 'Mark Handover Complete', dense: true, onTap: () {
                  ex.handoverStatus = ex.handoverStatus == 'Complete' ? 'Pending' : 'Complete';
                  appState.touch(); setState(() {});
                }),
                const SizedBox(width: 10),
                GoldButton(label: ex.settled ? 'Settlement Done' : 'Mark Settled', dense: true, icon: ex.settled ? Icons.check_circle : Icons.payments_outlined, onTap: () {
                  ex.settled = !ex.settled;
                  appState.touch(); setState(() {});
                  toast(context, ex.settled ? '${s.name} marked as settled' : 'Settlement reverted');
                }),
                const Spacer(),
                Tooltip(message: 'Remove exit record', child: GestureDetector(onTap: () async {
                  final ok = await confirm(context, 'Remove exit record?', 'This will remove the exit record for ${s.name}.');
                  if (ok) { s.exitRecord = null; appState.touch(); setState(() {}); }
                }, child: MouseRegion(cursor: SystemMouseCursors.click, child: Icon(Icons.delete_outline, size: 18, color: p.danger)))),
              ]),
            ])));
          }),
        const SizedBox(height: 8),
      ]),
    ));
  }
}

// ─── Staff Form Dialog ────────────────────────────────────────────────────────
class StaffFormDialog extends StatefulWidget {
  final Staff? existing;
  const StaffFormDialog({super.key, this.existing});
  @override
  State<StaffFormDialog> createState() => _StaffFormDialogState();
}

class _StaffFormDialogState extends State<StaffFormDialog> {
  late final TextEditingController _name, _specialty, _phone, _email;
  StaffRole _role = StaffRole.doctor;
  bool _active = true;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name = TextEditingController(text: e?.name ?? '');
    _specialty = TextEditingController(text: e?.specialty ?? '');
    _phone = TextEditingController(text: e?.phone ?? '+92 ');
    _email = TextEditingController(text: e?.email ?? '');
    _role = e?.role ?? StaffRole.doctor;
    _active = e?.active ?? true;
  }

  @override
  void dispose() {
    for (final c in [_name, _specialty, _phone, _email]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final editing = widget.existing != null;
    return Dialog(
      backgroundColor: p.surface, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: p.border)),
      child: Container(
        width: 520, padding: const EdgeInsets.all(26),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: p.gold.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)), child: Icon(editing ? Icons.edit_outlined : Icons.person_add_alt_1, color: p.gold)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(editing ? 'EDIT STAFF' : 'ADD STAFF', style: p.display(28)), Text('Team member details & role', style: p.body(12.5, color: p.textMuted))])),
            IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Icons.close, color: p.textMuted)),
          ]),
          const SizedBox(height: 18),
          FormField2(label: 'Full Name', controller: _name, hint: 'e.g. Dr. Ayesha Malik'),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: Dropdown2<StaffRole>(label: 'Role', value: _role, items: StaffRole.values.map((r) => DropdownMenuItem(value: r, child: Text(r.label))).toList(), onChanged: (v) => setState(() => _role = v ?? StaffRole.doctor))),
            const SizedBox(width: 14),
            Expanded(child: FormField2(label: 'Specialty / Dept', controller: _specialty, hint: 'e.g. FUE Surgeon')),
          ]),
          const SizedBox(height: 14),
          Row(children: [Expanded(child: FormField2(label: 'Phone', controller: _phone, keyboard: TextInputType.phone)), const SizedBox(width: 14), Expanded(child: FormField2(label: 'Email', controller: _email, keyboard: TextInputType.emailAddress))]),
          const SizedBox(height: 16),
          Row(children: [
            Text('Status', style: p.body(12, color: p.textMuted, weight: FontWeight.w600)),
            const SizedBox(width: 14),
            GestureDetector(onTap: () => setState(() => _active = !_active), child: MouseRegion(cursor: SystemMouseCursors.click, child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: (_active ? p.success : p.textMuted).withValues(alpha: 0.14), borderRadius: BorderRadius.circular(8), border: Border.all(color: _active ? p.success : p.border)), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(_active ? Icons.toggle_on : Icons.toggle_off_outlined, size: 18, color: _active ? p.success : p.textMuted), const SizedBox(width: 8), Text(_active ? 'On Duty' : 'Off Duty', style: p.body(12.5, color: _active ? p.success : p.textMuted, weight: FontWeight.w600))])))),
          ]),
          const SizedBox(height: 22),
          Row(children: [const Spacer(), GhostButton(label: 'Cancel', onTap: () => Navigator.pop(context)), const SizedBox(width: 12), GoldButton(label: editing ? 'Save Changes' : 'Add Staff', icon: Icons.check, onTap: _save)]),
        ]),
      ),
    );
  }

  void _save() {
    if (_name.text.trim().isEmpty) {
      toast(context, 'Please enter the staff name');
      return;
    }
    if (widget.existing != null) {
      final e = widget.existing!;
      e..name = _name.text.trim()..role = _role..specialty = _specialty.text.trim()..phone = _phone.text.trim()..email = _email.text.trim()..active = _active;
      appState.touch();
    } else {
      appState.addStaff(Staff(id: 'ST-${DateTime.now().millisecondsSinceEpoch % 100000}', name: _name.text.trim(), role: _role, specialty: _specialty.text.trim(), phone: _phone.text.trim(), email: _email.text.trim().isEmpty ? '—' : _email.text.trim(), active: _active));
    }
    Navigator.pop(context);
  }
}
