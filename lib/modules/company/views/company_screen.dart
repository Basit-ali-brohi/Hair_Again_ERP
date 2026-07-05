import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../models/company_models.dart';

class CompanyScreen extends StatefulWidget {
  const CompanyScreen({super.key});
  @override
  State<CompanyScreen> createState() => _CompanyScreenState();
}

class _CompanyScreenState extends State<CompanyScreen> with SingleTickerProviderStateMixin {
  late final TabController _tab;
  @override
  void initState() { super.initState(); _tab = TabController(length: 6, vsync: this); }
  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    return ScreenScaffold(
      title: 'COMPANY MANAGEMENT',
      subtitle: 'Clinic profile, branches, departments, designations & operating schedule',
      actions: [
        Container(height: 42,
          decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: p.border)),
          child: TabBar(controller: _tab, isScrollable: true, dividerColor: Colors.transparent,
            indicatorColor: p.gold, indicatorSize: TabBarIndicatorSize.label,
            labelStyle: p.body(12.5, weight: FontWeight.w600), unselectedLabelStyle: p.body(12.5),
            labelColor: p.gold, unselectedLabelColor: p.textMuted, tabAlignment: TabAlignment.start,
            tabs: const [Tab(text: 'Company Profile'), Tab(text: 'Branches'), Tab(text: 'Departments'),
              Tab(text: 'Designations'), Tab(text: 'Working Hours'), Tab(text: 'Holidays')]),
        ),
      ],
      child: EagerTabBarView(controller: _tab, children: const [
        _ProfileTab(), _BranchesTab(), _DepartmentsTab(),
        _DesignationsTab(), _WorkingHoursTab(), _HolidaysTab(),
      ]),
    );
  }
}

// ── Company Profile ────────────────────────────────────────────────────────────
class _ProfileTab extends StatefulWidget {
  const _ProfileTab();
  @override
  State<_ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<_ProfileTab> {
  bool _editing = false;
  late final _nameCtrl = TextEditingController(text: appState.clinicName);
  late final _addrCtrl = TextEditingController(text: appState.clinicAddress);
  late final _phoneCtrl = TextEditingController(text: appState.clinicPhone);
  late final _emailCtrl = TextEditingController(text: appState.clinicEmail);
  final _regCtrl = TextEditingController(text: 'HA-2019-0042');
  final _taxCtrl = TextEditingController(text: 'NTN-1234567-8');
  final _webCtrl = TextEditingController(text: 'www.hairagain.pk');
  final _estCtrl = TextEditingController(text: '2019');

  @override
  void dispose() {
    for (final c in [_nameCtrl, _addrCtrl, _phoneCtrl, _emailCtrl, _regCtrl, _taxCtrl, _webCtrl, _estCtrl]) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    return ScrollArea(builder: (sc) => SingleChildScrollView(controller: sc, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 80, height: 80, alignment: Alignment.center,
            decoration: BoxDecoration(gradient: p.goldGradient, borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.spa_outlined, size: 40, color: Colors.white)),
          const SizedBox(width: 20),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(appState.clinicName, style: p.display(28)),
            const SizedBox(height: 4),
            Text(appState.clinicAddress, style: p.body(13, color: p.textMuted)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, children: [
              StatusChip(label: 'Active Clinic', color: p.success),
              StatusChip(label: 'Est. 2019', color: p.info),
              StatusChip(label: '1 Branch', color: p.textMuted),
            ]),
          ])),
          if (!_editing) GoldButton(label: 'Edit Profile', icon: Icons.edit_outlined, onTap: () => setState(() => _editing = true)),
          if (_editing) ...[
            GhostButton(label: 'Cancel', onTap: () => setState(() => _editing = false)),
            const SizedBox(width: 10),
            GoldButton(label: 'Save Changes', icon: Icons.check, onTap: () {
              appState.clinicName = _nameCtrl.text;
              appState.clinicAddress = _addrCtrl.text;
              appState.clinicPhone = _phoneCtrl.text;
              appState.clinicEmail = _emailCtrl.text;
              appState.touch();
              setState(() => _editing = false);
            }),
          ],
        ]),
      ])),
      const SizedBox(height: 18),
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('BASIC INFORMATION', style: p.display(18, spacing: 0.5)),
          const SizedBox(height: 16),
          if (_editing) ...[
            FormField2(label: 'Clinic Name', controller: _nameCtrl, hint: 'Hair Again International'),
            const SizedBox(height: 14),
            FormField2(label: 'Address', controller: _addrCtrl, hint: 'Full clinic address'),
            const SizedBox(height: 14),
            FormField2(label: 'Phone', controller: _phoneCtrl, hint: '+92 21 111 444 555'),
            const SizedBox(height: 14),
            FormField2(label: 'Email', controller: _emailCtrl, hint: 'care@hairagain.pk'),
            const SizedBox(height: 14),
            FormField2(label: 'Website', controller: _webCtrl, hint: 'www.hairagain.pk'),
          ] else ...[
            _infoRow(p, Icons.business_outlined, 'Name', appState.clinicName),
            _infoRow(p, Icons.location_on_outlined, 'Address', appState.clinicAddress),
            _infoRow(p, Icons.phone_outlined, 'Phone', appState.clinicPhone),
            _infoRow(p, Icons.email_outlined, 'Email', appState.clinicEmail),
            _infoRow(p, Icons.language_outlined, 'Website', _webCtrl.text),
          ],
        ]))),
        const SizedBox(width: 18),
        SizedBox(width: 340, child: Column(children: [
          Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('LEGAL & TAX', style: p.display(18, spacing: 0.5)),
            const SizedBox(height: 16),
            if (_editing) ...[
              FormField2(label: 'Registration No.', controller: _regCtrl, hint: 'Company registration number'),
              const SizedBox(height: 14),
              FormField2(label: 'NTN / Tax ID', controller: _taxCtrl, hint: 'e.g. NTN-1234567-8'),
              const SizedBox(height: 14),
              FormField2(label: 'Established Year', controller: _estCtrl, hint: '2019', keyboard: TextInputType.number),
            ] else ...[
              _infoRow(p, Icons.badge_outlined, 'Reg. No.', _regCtrl.text),
              _infoRow(p, Icons.receipt_long_outlined, 'NTN', _taxCtrl.text),
              _infoRow(p, Icons.calendar_today_outlined, 'Est. Year', _estCtrl.text),
            ],
          ])),
          const SizedBox(height: 18),
          Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('QUICK STATS', style: p.display(18, spacing: 0.5)),
            const SizedBox(height: 14),
            _statRow(p, 'Total Patients', '${appState.patients.length}'),
            _statRow(p, 'Total Staff', '${appState.staff.length}'),
            _statRow(p, 'Branches', '${appState.branches.length}'),
            _statRow(p, 'Departments', '${appState.departments.length}'),
          ])),
        ])),
      ]),
    ])));
  }

  Widget _infoRow(AppPalette p, IconData ic, String label, String val) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Row(children: [
      Icon(ic, size: 16, color: p.gold), const SizedBox(width: 12),
      SizedBox(width: 80, child: Text(label, style: p.body(12.5, color: p.textMuted))),
      Expanded(child: Text(val, style: p.body(13, weight: FontWeight.w500))),
    ]));

  Widget _statRow(AppPalette p, String label, String val) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(children: [
      Text(label, style: p.body(13, color: p.textMuted)), const Spacer(),
      Text(val, style: p.body(14, weight: FontWeight.w700, color: p.gold)),
    ]));
}

// ── Branches ──────────────────────────────────────────────────────────────────
class _BranchesTab extends StatefulWidget {
  const _BranchesTab();
  @override
  State<_BranchesTab> createState() => _BranchesTabState();
}

class _BranchesTabState extends State<_BranchesTab> {
  void _showForm({Branch? existing}) {
    final editing = existing != null;
    final p = appState.palette;
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final addrCtrl = TextEditingController(text: existing?.address ?? '');
    final cityCtrl = TextEditingController(text: existing?.city ?? 'Karachi');
    final phoneCtrl = TextEditingController(text: existing?.phone ?? '');
    final emailCtrl = TextEditingController(text: existing?.email ?? '');
    final mgCtrl = TextEditingController(text: existing?.managerName ?? '');
    showDialog(context: context, builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(width: 540, padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: p.border)),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(editing ? 'EDIT BRANCH' : 'ADD BRANCH', style: p.display(22, spacing: 1.0)),
          const SizedBox(height: 20),
          FormField2(label: 'Branch Name *', controller: nameCtrl, hint: 'e.g. Hair Again — DHA Branch'),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: FormField2(label: 'City', controller: cityCtrl, hint: 'Karachi')),
            const SizedBox(width: 14),
            Expanded(child: FormField2(label: 'Phone', controller: phoneCtrl, hint: '+92 21 ...')),
          ]),
          const SizedBox(height: 14),
          FormField2(label: 'Address', controller: addrCtrl, hint: 'Full street address'),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: FormField2(label: 'Email', controller: emailCtrl, hint: 'branch@hairagain.pk')),
            const SizedBox(width: 14),
            Expanded(child: FormField2(label: 'Branch Manager', controller: mgCtrl, hint: 'Manager name')),
          ]),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            GhostButton(label: 'Cancel', onTap: () => Navigator.pop(ctx)),
            const SizedBox(width: 12),
            GoldButton(label: editing ? 'Save Changes' : 'Add Branch', onTap: () {
              if (nameCtrl.text.isEmpty) return;
              if (editing) {
                existing!.name = nameCtrl.text; existing.address = addrCtrl.text;
                existing.city = cityCtrl.text; existing.phone = phoneCtrl.text;
                existing.email = emailCtrl.text; existing.managerName = mgCtrl.text;
                appState.touch();
              } else {
                appState.addBranch(Branch(id: appState.createBranchId(), name: nameCtrl.text,
                  address: addrCtrl.text, city: cityCtrl.text, phone: phoneCtrl.text,
                  email: emailCtrl.text, managerName: mgCtrl.text));
              }
              Navigator.pop(ctx); setState(() {});
            }),
          ]),
        ]),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final list = appState.branches;
    return Column(children: [
      Row(children: [const Spacer(), GoldButton(label: 'Add Branch', icon: Icons.add, onTap: () => _showForm())]),
      const SizedBox(height: 12),
      Expanded(child: list.isEmpty
        ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.location_city_outlined, size: 44, color: p.textMuted.withValues(alpha: 0.5)),
            const SizedBox(height: 12),
            Text('No branches added yet.', style: p.body(13, color: p.textMuted)),
          ]))
        : ScrollArea(builder: (sc) => GridView.builder(
            controller: sc, padding: const EdgeInsets.only(right: 12),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 440, mainAxisExtent: 220, crossAxisSpacing: 16, mainAxisSpacing: 16),
            itemCount: list.length, itemBuilder: (_, i) => _BranchCard(b: list[i], onEdit: () => _showForm(existing: list[i]), onDelete: () { appState.deleteBranch(list[i]); setState(() {}); }, onUpdate: () => setState(() {})),
          ))),
    ]);
  }
}

class _BranchCard extends StatelessWidget {
  final Branch b;
  final VoidCallback onEdit, onDelete, onUpdate;
  const _BranchCard({required this.b, required this.onEdit, required this.onDelete, required this.onUpdate});
  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    return Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(width: 48, height: 48, alignment: Alignment.center,
          decoration: BoxDecoration(color: p.gold.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
          child: Icon(Icons.location_city_outlined, size: 22, color: p.gold)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(b.name, style: p.body(14.5, weight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
          StatusChip(label: b.isPrimary ? 'Primary' : 'Branch', color: b.isPrimary ? p.gold : p.info),
        ])),
        StatusChip(label: b.isActive ? 'Active' : 'Inactive', color: b.isActive ? p.success : p.textMuted),
      ]),
      const SizedBox(height: 14),
      _row(p, Icons.location_on_outlined, '${b.address}, ${b.city}'),
      const SizedBox(height: 8),
      _row(p, Icons.phone_outlined, b.phone),
      const SizedBox(height: 8),
      _row(p, Icons.person_outlined, b.managerName.isEmpty ? 'No manager assigned' : b.managerName),
      const Spacer(),
      Row(children: [
        GhostButton(label: b.isActive ? 'Deactivate' : 'Activate', onTap: () { b.isActive = !b.isActive; appState.touch(); onUpdate(); }),
        const Spacer(),
        _sqBtn(p, Icons.edit_outlined, p.text, 'Edit', onEdit),
        const SizedBox(width: 6),
        _sqBtn(p, Icons.delete_outline, p.textMuted, 'Delete', onDelete),
      ]),
    ]));
  }
  Widget _row(AppPalette p, IconData ic, String t) => Row(children: [Icon(ic, size: 14, color: p.textMuted), const SizedBox(width: 8), Expanded(child: Text(t, style: p.body(12.5, color: p.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis))]);
  Widget _sqBtn(AppPalette p, IconData ic, Color c, String tip, VoidCallback fn) => Tooltip(message: tip, child: GestureDetector(onTap: fn, child: MouseRegion(cursor: SystemMouseCursors.click, child: Container(width: 30, height: 30, decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(8)), child: Icon(ic, size: 15, color: c)))));
}

// ── Departments ──────────────────────────────────────────────────────────────
class _DepartmentsTab extends StatefulWidget {
  const _DepartmentsTab();
  @override
  State<_DepartmentsTab> createState() => _DepartmentsTabState();
}

class _DepartmentsTabState extends State<_DepartmentsTab> {
  String _q = '';
  void _showForm({Department? existing}) {
    final editing = existing != null;
    final p = appState.palette;
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    final headCtrl = TextEditingController(text: existing?.headName ?? '');
    showDialog(context: context, builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(width: 460, padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: p.border)),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(editing ? 'EDIT DEPARTMENT' : 'ADD DEPARTMENT', style: p.display(22, spacing: 1.0)),
          const SizedBox(height: 20),
          FormField2(label: 'Department Name *', controller: nameCtrl, hint: 'e.g. Medical'),
          const SizedBox(height: 14),
          FormField2(label: 'Description', controller: descCtrl, hint: 'What this department handles...', maxLines: 2),
          const SizedBox(height: 14),
          FormField2(label: 'Department Head', controller: headCtrl, hint: 'e.g. Dr. Rehman'),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            GhostButton(label: 'Cancel', onTap: () => Navigator.pop(ctx)),
            const SizedBox(width: 12),
            GoldButton(label: editing ? 'Save Changes' : 'Add Department', onTap: () {
              if (nameCtrl.text.isEmpty) return;
              if (editing) {
                existing!.name = nameCtrl.text; existing.description = descCtrl.text; existing.headName = headCtrl.text; appState.touch();
              } else {
                appState.addDepartment(Department(id: appState.createDeptId(), name: nameCtrl.text, description: descCtrl.text, headName: headCtrl.text));
              }
              Navigator.pop(ctx); setState(() {});
            }),
          ]),
        ]),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    var list = appState.departments;
    if (_q.isNotEmpty) list = list.where((d) => d.name.toLowerCase().contains(_q.toLowerCase())).toList();
    return Column(children: [
      FilterBar(searchHint: 'Search departments…', onSearch: (v) => setState(() => _q = v),
        filters: [], countText: '${list.length} departments', onClear: () => setState(() => _q = ''),
        trailing: [GoldButton(label: 'Add Department', icon: Icons.add, onTap: () => _showForm())]),
      const SizedBox(height: 12),
      Expanded(child: Panel(padding: EdgeInsets.zero, child: ScrollArea(builder: (sc) => SingleChildScrollView(controller: sc, child: FullWidthDataTable(child: DataTable(
        headingRowColor: WidgetStateProperty.all(p.surfaceAlt),
        columnSpacing: 20, horizontalMargin: 20,
        columns: ['Department', 'Head', 'Employees', 'Status', 'Action'].map((t) => DataColumn(label: Text(t, style: p.body(12, weight: FontWeight.w700)))).toList(),
        rows: list.map((d) => DataRow(cells: [
          DataCell(Text(d.name, style: p.body(13, weight: FontWeight.w600))),
          DataCell(Text(d.headName.isEmpty ? '—' : d.headName, style: p.body(12.5))),
          DataCell(Text('${d.employeeCount}', style: p.body(12.5))),
          DataCell(StatusChip(label: d.isActive ? 'Active' : 'Inactive', color: d.isActive ? p.success : p.textMuted)),
          DataCell(Row(mainAxisSize: MainAxisSize.min, children: [
            _sqBtn(p, Icons.edit_outlined, p.text, () => _showForm(existing: d)),
            const SizedBox(width: 6),
            _sqBtn(p, Icons.delete_outline, p.textMuted, () { appState.deleteDepartment(d); setState(() {}); }),
          ])),
        ])).toList(),
      )))))),
    ]);
  }
  Widget _sqBtn(AppPalette p, IconData ic, Color c, VoidCallback fn) => GestureDetector(onTap: fn, child: MouseRegion(cursor: SystemMouseCursors.click, child: Container(width: 30, height: 30, decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(8)), child: Icon(ic, size: 15, color: c))));
}

// ── Designations ─────────────────────────────────────────────────────────────
class _DesignationsTab extends StatefulWidget {
  const _DesignationsTab();
  @override
  State<_DesignationsTab> createState() => _DesignationsTabState();
}

class _DesignationsTabState extends State<_DesignationsTab> {
  String _q = '';
  void _showForm({Designation? existing}) {
    final editing = existing != null;
    final p = appState.palette;
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final deptCtrl = TextEditingController(text: existing?.department ?? '');
    final gradeCtrl = TextEditingController(text: existing?.gradeLevel ?? 'Grade 1');
    showDialog(context: context, builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(width: 460, padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: p.border)),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(editing ? 'EDIT DESIGNATION' : 'ADD DESIGNATION', style: p.display(22, spacing: 1.0)),
          const SizedBox(height: 20),
          FormField2(label: 'Title *', controller: titleCtrl, hint: 'e.g. Lead Surgeon'),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: FormField2(label: 'Department', controller: deptCtrl, hint: 'e.g. Medical')),
            const SizedBox(width: 14),
            Expanded(child: FormField2(label: 'Grade Level', controller: gradeCtrl, hint: 'e.g. Grade 1')),
          ]),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            GhostButton(label: 'Cancel', onTap: () => Navigator.pop(ctx)),
            const SizedBox(width: 12),
            GoldButton(label: editing ? 'Save Changes' : 'Add Designation', onTap: () {
              if (titleCtrl.text.isEmpty) return;
              if (editing) {
                existing!.title = titleCtrl.text; existing.department = deptCtrl.text; existing.gradeLevel = gradeCtrl.text; appState.touch();
              } else {
                appState.addDesignation(Designation(id: appState.createDesigId(), title: titleCtrl.text, department: deptCtrl.text, gradeLevel: gradeCtrl.text));
              }
              Navigator.pop(ctx); setState(() {});
            }),
          ]),
        ]),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    var list = appState.designations;
    if (_q.isNotEmpty) list = list.where((d) => d.title.toLowerCase().contains(_q.toLowerCase()) || d.department.toLowerCase().contains(_q.toLowerCase())).toList();
    return Column(children: [
      FilterBar(searchHint: 'Search designations…', onSearch: (v) => setState(() => _q = v),
        filters: [], countText: '${list.length} designations', onClear: () => setState(() => _q = ''),
        trailing: [GoldButton(label: 'Add Designation', icon: Icons.add, onTap: () => _showForm())]),
      const SizedBox(height: 12),
      Expanded(child: Panel(padding: EdgeInsets.zero, child: ScrollArea(builder: (sc) => SingleChildScrollView(controller: sc, child: FullWidthDataTable(child: DataTable(
        headingRowColor: WidgetStateProperty.all(p.surfaceAlt), columnSpacing: 20, horizontalMargin: 20,
        columns: ['Title', 'Department', 'Grade', 'Status', 'Action'].map((t) => DataColumn(label: Text(t, style: p.body(12, weight: FontWeight.w700)))).toList(),
        rows: list.map((d) => DataRow(cells: [
          DataCell(Text(d.title, style: p.body(13, weight: FontWeight.w600))),
          DataCell(Text(d.department.isEmpty ? '—' : d.department, style: p.body(12.5))),
          DataCell(Text(d.gradeLevel, style: p.body(12.5, color: p.textMuted))),
          DataCell(StatusChip(label: d.isActive ? 'Active' : 'Inactive', color: d.isActive ? p.success : p.textMuted)),
          DataCell(Row(mainAxisSize: MainAxisSize.min, children: [
            _sqBtn(p, Icons.edit_outlined, p.text, () => _showForm(existing: d)),
            const SizedBox(width: 6),
            _sqBtn(p, Icons.delete_outline, p.textMuted, () { appState.deleteDesignation(d); setState(() {}); }),
          ])),
        ])).toList(),
      )))))),
    ]);
  }
  Widget _sqBtn(AppPalette p, IconData ic, Color c, VoidCallback fn) => GestureDetector(onTap: fn, child: MouseRegion(cursor: SystemMouseCursors.click, child: Container(width: 30, height: 30, decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(8)), child: Icon(ic, size: 15, color: c))));
}

// ── Working Hours ─────────────────────────────────────────────────────────────
class _WorkingHoursTab extends StatefulWidget {
  const _WorkingHoursTab();
  @override
  State<_WorkingHoursTab> createState() => _WorkingHoursTabState();
}

class _WorkingHoursTabState extends State<_WorkingHoursTab> {
  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final days = appState.workingDays;
    return Column(children: [
      Row(children: [const Spacer(), GoldButton(label: 'Save Schedule', icon: Icons.save_outlined, onTap: () { appState.touch(); toast(context, 'Working hours saved successfully'); })]),
      const SizedBox(height: 12),
      Expanded(child: Panel(child: ScrollArea(builder: (sc) => SingleChildScrollView(controller: sc, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('WEEKLY SCHEDULE', style: p.display(18, spacing: 0.5)),
        const SizedBox(height: 6),
        Text('Set clinic operating hours for each day of the week', style: p.body(12.5, color: p.textMuted)),
        const SizedBox(height: 20),
        ...days.map((day) => _DayRow(day: day, onChanged: () => setState(() {}))),
      ]))))),
    ]);
  }
}

class _DayRow extends StatefulWidget {
  final WorkingDay day;
  final VoidCallback onChanged;
  const _DayRow({required this.day, required this.onChanged});
  @override
  State<_DayRow> createState() => _DayRowState();
}

class _DayRowState extends State<_DayRow> {
  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final d = widget.day;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          SizedBox(width: 50, child: Text(d.day, style: p.body(13, weight: FontWeight.w700))),
          const SizedBox(width: 16),
          Switch(value: d.isOpen, onChanged: (v) { d.isOpen = v; widget.onChanged(); }, activeColor: p.gold),
          const SizedBox(width: 16),
          if (!d.isOpen)
            SizedBox(width: 200, child: Container(height: 44, alignment: Alignment.centerLeft,
              decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(8), border: Border.all(color: p.border)),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text('Closed', style: p.body(13, color: p.textMuted))))
          else ...[
            _timeField(p, 'Open', d.openTime, (v) { d.openTime = v; widget.onChanged(); }),
            const SizedBox(width: 10),
            Text('to', style: p.body(13, color: p.textMuted)),
            const SizedBox(width: 10),
            _timeField(p, 'Close', d.closeTime, (v) { d.closeTime = v; widget.onChanged(); }),
            const SizedBox(width: 20),
            Text('Break:', style: p.body(12.5, color: p.textMuted)),
            const SizedBox(width: 10),
            _timeField(p, 'Start', d.breakStart, (v) { d.breakStart = v; widget.onChanged(); }),
            const SizedBox(width: 8),
            Text('–', style: p.body(13, color: p.textMuted)),
            const SizedBox(width: 8),
            _timeField(p, 'End', d.breakEnd, (v) { d.breakEnd = v; widget.onChanged(); }),
          ],
        ]),
      ),
    );
  }

  Widget _timeField(AppPalette p, String hint, String val, ValueChanged<String> onChange) {
    final ctrl = TextEditingController(text: val);
    return SizedBox(width: 80, child: Container(
      height: 44,
      decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(8), border: Border.all(color: p.border)),
      child: TextField(controller: ctrl, textAlign: TextAlign.center,
        style: p.body(13), cursorColor: p.gold,
        decoration: InputDecoration(isCollapsed: true, border: InputBorder.none, hintText: hint,
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8)),
        onChanged: onChange),
    ));
  }
}

// ── Holidays ─────────────────────────────────────────────────────────────────
class _HolidaysTab extends StatefulWidget {
  const _HolidaysTab();
  @override
  State<_HolidaysTab> createState() => _HolidaysTabState();
}

class _HolidaysTabState extends State<_HolidaysTab> {
  void _showForm({Holiday? existing}) {
    final editing = existing != null;
    final p = appState.palette;
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    var type = existing?.type ?? 'public';
    var date = existing?.date ?? DateTime.now();
    var recurring = existing?.isRecurring ?? false;
    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, ss) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(width: 460, padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: p.border)),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(editing ? 'EDIT HOLIDAY' : 'ADD HOLIDAY', style: p.display(22, spacing: 1.0)),
          const SizedBox(height: 20),
          FormField2(label: 'Holiday Name *', controller: nameCtrl, hint: 'e.g. Eid ul Fitr'),
          const SizedBox(height: 14),
          Dropdown2<String>(label: 'Type', value: type,
            items: const [DropdownMenuItem(value: 'public', child: Text('Public Holiday')), DropdownMenuItem(value: 'optional', child: Text('Optional Holiday')), DropdownMenuItem(value: 'clinic', child: Text('Clinic Closure'))],
            onChanged: (v) => ss(() => type = v ?? type)),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () async { final picked = await showDatePicker(context: ctx, initialDate: date, firstDate: DateTime(2024), lastDate: DateTime(2030), builder: (c, ch) => Theme(data: ThemeData.dark().copyWith(colorScheme: ColorScheme.dark(primary: p.gold, surface: p.surface)), child: ch!)); if (picked != null) ss(() => date = picked); },
            child: Container(height: 46, padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(8), border: Border.all(color: p.border)),
              child: Row(children: [Icon(Icons.calendar_today_outlined, size: 15, color: p.gold), const SizedBox(width: 10), Text(prettyShort(date), style: p.body(13.5))])),
          ),
          const SizedBox(height: 14),
          Row(children: [
            Checkbox(value: recurring, onChanged: (v) => ss(() => recurring = v ?? recurring), activeColor: p.gold),
            const SizedBox(width: 8),
            Text('Recurring every year', style: p.body(13)),
          ]),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            GhostButton(label: 'Cancel', onTap: () => Navigator.pop(ctx)),
            const SizedBox(width: 12),
            GoldButton(label: editing ? 'Save Changes' : 'Add Holiday', onTap: () {
              if (nameCtrl.text.isEmpty) return;
              if (editing) {
                existing!.name = nameCtrl.text; existing.type = type; existing.date = date; existing.isRecurring = recurring; appState.touch();
              } else {
                appState.addHoliday(Holiday(id: appState.createHolidayId(), name: nameCtrl.text, type: type, date: date, isRecurring: recurring));
              }
              Navigator.pop(ctx); setState(() {});
            }),
          ]),
        ]),
      ),
    )));
  }

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final list = appState.holidays..sort((a, b) => a.date.compareTo(b.date));
    return Column(children: [
      Row(children: [const Spacer(), GoldButton(label: 'Add Holiday', icon: Icons.add, onTap: () => _showForm())]),
      const SizedBox(height: 12),
      Expanded(child: Panel(padding: EdgeInsets.zero, child: ScrollArea(builder: (sc) => SingleChildScrollView(controller: sc, child: FullWidthDataTable(child: DataTable(
        headingRowColor: WidgetStateProperty.all(p.surfaceAlt), columnSpacing: 20, horizontalMargin: 20,
        columns: ['Holiday', 'Date', 'Type', 'Recurring', 'Action'].map((t) => DataColumn(label: Text(t, style: p.body(12, weight: FontWeight.w700)))).toList(),
        rows: list.map((h) => DataRow(cells: [
          DataCell(Text(h.name, style: p.body(13, weight: FontWeight.w600))),
          DataCell(Text(prettyShort(h.date), style: p.body(12.5))),
          DataCell(StatusChip(label: h.typeLabel, color: h.type == 'public' ? p.danger : h.type == 'optional' ? p.warning : p.info)),
          DataCell(Icon(h.isRecurring ? Icons.repeat : Icons.looks_one_outlined, size: 18, color: h.isRecurring ? p.success : p.textMuted)),
          DataCell(Row(mainAxisSize: MainAxisSize.min, children: [
            GestureDetector(onTap: () => _showForm(existing: h), child: MouseRegion(cursor: SystemMouseCursors.click, child: Container(width: 30, height: 30, decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(8)), child: Icon(Icons.edit_outlined, size: 15, color: p.text)))),
            const SizedBox(width: 6),
            GestureDetector(onTap: () { appState.deleteHoliday(h); setState(() {}); }, child: MouseRegion(cursor: SystemMouseCursors.click, child: Container(width: 30, height: 30, decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(8)), child: Icon(Icons.delete_outline, size: 15, color: p.textMuted)))),
          ])),
        ])).toList(),
      )))))),
    ]);
  }
}
