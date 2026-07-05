import 'package:flutter/material.dart';

import '../../../core/core.dart';
import '../models/hr_models.dart';

class HrScreen extends StatefulWidget {
  const HrScreen({super.key});
  @override
  State<HrScreen> createState() => _HrScreenState();
}

class _HrScreenState extends State<HrScreen> with SingleTickerProviderStateMixin {
  late final TabController _tab;
  @override
  void initState() { super.initState(); _tab = TabController(length: 8, vsync: this); }
  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    return ScreenScaffold(
      title: 'HR MANAGEMENT',
      subtitle: 'Attendance, payroll, leave, shifts & recruitment',
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
              Tab(text: 'Overview'), Tab(text: 'Attendance'), Tab(text: 'Leave'),
              Tab(text: 'Payroll'), Tab(text: 'Salary Structure'),
              Tab(text: 'Shifts'), Tab(text: 'Recruitment'), Tab(text: 'Payslips'),
            ],
          ),
        ),
      ],
      child: EagerTabBarView(
        controller: _tab,
        children: [
          _OverviewTab(onGoToTab: (i) => _tab.animateTo(i)),
          const _AttendanceTab(),
          const _LeaveTab(),
          const _PayrollTab(),
          const _SalaryStructureTab(),
          const _ShiftsTab(),
          const _RecruitmentTab(),
          const _PayslipsTab(),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// OVERVIEW TAB
// ══════════════════════════════════════════════════════════════════════════════
class _OverviewTab extends StatelessWidget {
  final ValueChanged<int> onGoToTab;
  const _OverviewTab({required this.onGoToTab});

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final state = AppScope.of(context);
    return ScrollArea(builder: (sc) => SingleChildScrollView(controller: sc, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      MetricRow([
        MetricCard(title: 'Total Employees', value: '${state.staff.length}', delta: '+2 this month', icon: Icons.badge_outlined),
        MetricCard(title: 'Present Today', value: '${state.presentTodayCount}', delta: '${((state.presentTodayCount / state.staff.length.clamp(1, 9999)) * 100).toInt()}% rate', icon: Icons.how_to_reg_outlined),
        MetricCard(title: 'Pending Leaves', value: '${state.pendingLeaveCount}', delta: 'Needs approval', icon: Icons.event_note_outlined, deltaUp: state.pendingLeaveCount == 0),
        MetricCard(title: 'Payroll (Jun)', value: moneyShort(state.salaryStructures.fold(0.0, (s, ss) => s + ss.netSalary)), delta: '6 employees', icon: Icons.payments_outlined),
      ]),
      const SizedBox(height: 24),
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Quick summary panels
        Expanded(child: Column(children: [
          _Section('Pending Leave Approvals', p, trailing: GhostButton(label: 'View All', icon: Icons.arrow_forward, onTap: () => onGoToTab(2)),
            child: state.leaveRequests.where((r) => r.status == LeaveStatus.pending).isEmpty
              ? _empty(p, 'No pending leave requests')
              : Column(children: state.leaveRequests.where((r) => r.status == LeaveStatus.pending).take(4).map((r) => _LeaveCard(r: r, compact: true, onApprove: () { appState.approveLeave(r, appState.currentUser?.name ?? 'Manager'); }, onReject: () {})).toList()),
          ),
          const SizedBox(height: 18),
          _Section('Overtime Pending Approval', p, child: Column(children: appState.overtimeRecords.where((o) => !o.approved).map((o) => _OTRow(o: o, p: p)).toList())),
        ])),
        const SizedBox(width: 18),
        // Leave balances
        SizedBox(width: 340, child: _Section('Leave Balances — June 2026', p, child: Column(children: appState.leaveBalances.map((lb) {
          final emp = appState.staff.where((s) => s.id == lb.employeeId).firstOrNull;
          if (emp == null) return const SizedBox.shrink();
          return Padding(padding: const EdgeInsets.only(bottom: 12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              CircleAvatar(radius: 14, backgroundColor: p.gold.withValues(alpha: 0.15), child: Text(emp.name.substring(0, 1), style: p.body(12, color: p.gold, weight: FontWeight.w700))),
              const SizedBox(width: 10),
              Expanded(child: Text(emp.name, style: p.body(13, weight: FontWeight.w600))),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              _LeaveBalChip('Annual', lb.annualRemaining, lb.annual, p),
              const SizedBox(width: 8),
              _LeaveBalChip('Sick', lb.sickRemaining, lb.sick, p),
              const SizedBox(width: 8),
              _LeaveBalChip('Casual', lb.casualRemaining, lb.casual, p),
            ]),
            if (appState.leaveBalances.last != lb) Divider(height: 20, color: p.border),
          ]));
        }).toList())),
        ),
      ]),
    ])));
  }
}

Widget _empty(AppPalette p, String msg) => Padding(padding: const EdgeInsets.symmetric(vertical: 28), child: Center(child: Text(msg, style: p.body(13, color: p.textMuted))));

Widget _Section(String title, AppPalette p, {Widget? trailing, required Widget child}) => Panel(
  padding: const EdgeInsets.all(18),
  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [Text(title, style: p.display(18, spacing: 0.5)), const Spacer(), if (trailing != null) trailing]),
    const SizedBox(height: 14),
    child,
  ]),
);

class _OTRow extends StatelessWidget {
  final OvertimeRecord o;
  final AppPalette p;
  const _OTRow({required this.o, required this.p});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(o.employeeName, style: p.body(13, weight: FontWeight.w600)),
        Text('${o.hours}h × PKR ${o.ratePerHour.toInt()} = ${money(o.amount)}', style: p.body(12, color: p.textMuted)),
      ])),
      GoldButton(label: 'Approve', dense: true, onTap: () { o.approved = true; o.approvedBy = appState.currentUser?.name ?? 'Manager'; appState.touch(); }),
    ]),
  );
}

class _LeaveBalChip extends StatelessWidget {
  final String label;
  final int remaining;
  final int total;
  final AppPalette p;
  const _LeaveBalChip(this.label, this.remaining, this.total, this.p);
  @override
  Widget build(BuildContext context) {
    final ok = remaining > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: (ok ? p.success : p.danger).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6), border: Border.all(color: (ok ? p.success : p.danger).withValues(alpha: 0.3))),
      child: Text('$label: $remaining/$total', style: p.body(11, color: ok ? p.success : p.danger, weight: FontWeight.w600)),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// ATTENDANCE TAB
// ══════════════════════════════════════════════════════════════════════════════
class _AttendanceTab extends StatefulWidget {
  const _AttendanceTab();
  @override
  State<_AttendanceTab> createState() => _AttendanceTabState();
}

class _AttendanceTabState extends State<_AttendanceTab> {
  late DateTime _month;
  String _empQ = '';
  @override
  void initState() { super.initState(); _month = DateTime(DateTime.now().year, DateTime.now().month); }

  int get _daysInMonth => DateTime(_month.year, _month.month + 1, 0).day;

  AttendanceStatus _getStatus(String empId, int day) {
    final date = DateTime(_month.year, _month.month, day);
    final rec = appState.attendanceRecords.where((r) => r.employeeId == empId && r.date.year == date.year && r.date.month == date.month && r.date.day == date.day).firstOrNull;
    if (rec != null) return rec.status;
    if (date.weekday == DateTime.friday) return AttendanceStatus.off;
    if (date.isAfter(DateTime.now())) return AttendanceStatus.off;
    return AttendanceStatus.absent;
  }

  Color _statusColor(AttendanceStatus s, AppPalette p) => switch (s) {
    AttendanceStatus.present => p.success,
    AttendanceStatus.absent => p.danger,
    AttendanceStatus.late => p.warning,
    AttendanceStatus.halfDay => p.info,
    AttendanceStatus.leave => p.gold,
    AttendanceStatus.holiday || AttendanceStatus.off => p.textMuted,
  };

  void _showMarkDialog(String empId, String empName, int day) {
    final p = appState.palette;
    final current = _getStatus(empId, day);
    showDialog(context: context, builder: (_) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 400, padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: p.border)),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('MARK ATTENDANCE', style: p.display(20, spacing: 1.0)),
          const SizedBox(height: 4),
          Text('$empName — ${_month.year}/${_month.month.toString().padLeft(2, '0')}/$day', style: p.body(13, color: p.textMuted)),
          const SizedBox(height: 20),
          ...AttendanceStatus.values.map((s) => RadioListTile<AttendanceStatus>(
            value: s, groupValue: current,
            activeColor: p.gold,
            title: Row(children: [
              Container(width: 12, height: 12, margin: const EdgeInsets.only(right: 10), decoration: BoxDecoration(color: _statusColor(s, p), shape: BoxShape.circle)),
              Text('${s.label} (${s.code})', style: p.body(13.5)),
            ]),
            onChanged: (v) {
              if (v != null) { appState.setAttendance(empId, DateTime(_month.year, _month.month, day), v); Navigator.pop(context); setState(() {}); }
            },
            contentPadding: EdgeInsets.zero,
          )),
        ]),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final employees = _empQ.isEmpty ? appState.staff : appState.staff.where((s) => s.name.toLowerCase().contains(_empQ.toLowerCase())).toList();
    final days = List.generate(_daysInMonth, (i) => i + 1);

    return Column(children: [
      // Controls
      Panel(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), child: Row(children: [
        GhostButton(icon: Icons.chevron_left, label: '', onTap: () => setState(() => _month = DateTime(_month.year, _month.month - 1))),
        const SizedBox(width: 12),
        Text('${['January','February','March','April','May','June','July','August','September','October','November','December'][_month.month - 1]} ${_month.year}', style: p.display(22, spacing: 0.5)),
        const SizedBox(width: 12),
        GhostButton(icon: Icons.chevron_right, label: '', onTap: () => setState(() => _month = DateTime(_month.year, _month.month + 1))),
        const SizedBox(width: 16),
        SizedBox(width: 200, child: TextField(
          decoration: InputDecoration(hintText: 'Filter employee…', prefixIcon: const Icon(Icons.search, size: 16), isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: p.border)), filled: true, fillColor: p.surfaceAlt),
          onChanged: (v) => setState(() => _empQ = v),
          style: p.body(13),
        )),
        const Spacer(),
        // Legend
        ...[
          (AttendanceStatus.present, 'P = Present'),
          (AttendanceStatus.absent, 'A = Absent'),
          (AttendanceStatus.late, 'L = Late'),
          (AttendanceStatus.leave, 'LV = Leave'),
          (AttendanceStatus.off, '— = Off'),
        ].map((e) => Padding(padding: const EdgeInsets.only(left: 16), child: Row(children: [Container(width: 10, height: 10, margin: const EdgeInsets.only(right: 5), decoration: BoxDecoration(color: _statusColor(e.$1, p), shape: BoxShape.circle)), Text(e.$2, style: p.body(11.5, color: p.textMuted))]))),
      ])),
      const SizedBox(height: 12),
      // Grid
      Expanded(child: Panel(padding: EdgeInsets.zero, child: ScrollArea(builder: (sc) => SingleChildScrollView(controller: sc, child: FullWidthDataTable(child: DataTable(
        headingRowColor: WidgetStateProperty.all(p.surfaceAlt),
        dataRowColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? p.gold.withValues(alpha: 0.05) : Colors.transparent),
        columnSpacing: 12,
        horizontalMargin: 16,
        columns: [
          DataColumn(label: SizedBox(width: 140, child: Text('Employee', style: p.body(12, weight: FontWeight.w700)))),
          ...days.map((d) {
            final dt = DateTime(_month.year, _month.month, d);
            final isFri = dt.weekday == DateTime.friday;
            final isToday = dt.year == DateTime.now().year && dt.month == DateTime.now().month && dt.day == DateTime.now().day;
            return DataColumn(label: Container(
              width: 32,
              alignment: Alignment.center,
              decoration: isToday ? BoxDecoration(color: p.gold.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)) : null,
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('$d', style: p.body(11.5, color: isFri ? p.textMuted : (isToday ? p.gold : p.text), weight: isToday ? FontWeight.w700 : FontWeight.w400)),
                Text(['', 'M','T','W','T','F','S','S'][dt.weekday], style: p.body(10, color: isFri ? p.danger.withValues(alpha: 0.6) : p.textMuted)),
              ]),
            ));
          }),
        ],
        rows: employees.map((emp) {
          final present = days.where((d) => _getStatus(emp.id, d) == AttendanceStatus.present).length;
          final absent = days.where((d) { final s = _getStatus(emp.id, d); return s == AttendanceStatus.absent; }).length;
          return DataRow(cells: [
            DataCell(Row(children: [
              CircleAvatar(radius: 14, backgroundColor: p.gold.withValues(alpha: 0.15), child: Text(emp.name.substring(0, 1), style: p.body(11, color: p.gold, weight: FontWeight.w700))),
              const SizedBox(width: 8),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(emp.name, style: p.body(12.5, weight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text('P:$present A:$absent', style: p.body(10.5, color: p.textMuted)),
              ])),
            ])),
            ...days.map((d) {
              final s = _getStatus(emp.id, d);
              final color = _statusColor(s, p);
              return DataCell(GestureDetector(
                onTap: () => _showMarkDialog(emp.id, emp.name, d),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Center(child: Container(
                    width: 30, height: 26,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(4)),
                    child: Text(s.code, style: p.body(10.5, color: color, weight: FontWeight.w700)),
                  )),
                ),
              ));
            }),
          ]);
        }).toList(),
      )))))),
    ]);
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// LEAVE TAB
// ══════════════════════════════════════════════════════════════════════════════
class _LeaveTab extends StatefulWidget {
  const _LeaveTab();
  @override
  State<_LeaveTab> createState() => _LeaveTabState();
}

class _LeaveTabState extends State<_LeaveTab> {
  String _filter = 'All';
  final _search = TextEditingController();
  String _q = '';

  @override
  void dispose() { _search.dispose(); super.dispose(); }

  List<LeaveRequest> get _filtered {
    var list = appState.leaveRequests.where((r) {
      if (_filter == 'Pending') return r.status == LeaveStatus.pending;
      if (_filter == 'Approved') return r.status == LeaveStatus.approved;
      if (_filter == 'Rejected') return r.status == LeaveStatus.rejected;
      return true;
    }).toList();
    if (_q.isNotEmpty) {
      final q = _q.toLowerCase();
      list = list.where((r) => r.employeeName.toLowerCase().contains(q) || r.department.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  void _addLeave() {
    final p = appState.palette;
    final nameCtrl = TextEditingController();
    final deptCtrl = TextEditingController();
    final reasonCtrl = TextEditingController();
    var type = LeaveType.casual;
    DateTime from = DateTime.now().add(const Duration(days: 1));
    DateTime to = DateTime.now().add(const Duration(days: 1));
    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, ss) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 560, padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: p.border)),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('NEW LEAVE REQUEST', style: p.display(22, spacing: 1.0)),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: FormField2(label: 'Employee Name', controller: nameCtrl, hint: 'e.g. Dr. Rehman')),
            const SizedBox(width: 16),
            Expanded(child: FormField2(label: 'Department', controller: deptCtrl, hint: 'e.g. Medical')),
          ]),
          const SizedBox(height: 16),
          Dropdown2<LeaveType>(label: 'Leave Type', value: type, items: LeaveType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.label))).toList(), onChanged: (v) => ss(() => type = v ?? type)),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: _DatePickerField(label: 'From Date', value: from, palette: p, onPick: (d) => ss(() => from = d))),
            const SizedBox(width: 16),
            Expanded(child: _DatePickerField(label: 'To Date', value: to, palette: p, onPick: (d) => ss(() => to = d))),
          ]),
          const SizedBox(height: 16),
          FormField2(label: 'Reason', controller: reasonCtrl, hint: 'Reason for leave...', maxLines: 3),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            GhostButton(label: 'Cancel', onTap: () => Navigator.pop(ctx)),
            const SizedBox(width: 12),
            GoldButton(label: 'Submit Request', onTap: () {
              if (nameCtrl.text.isEmpty) return;
              appState.addLeaveRequest(LeaveRequest(id: 'LR-${appState.leaveRequests.length + 1}', employeeId: 'ST-0', employeeName: nameCtrl.text, department: deptCtrl.text, type: type, fromDate: from, toDate: to, reason: reasonCtrl.text, appliedAt: DateTime.now()));
              Navigator.pop(ctx);
              setState(() {});
            }),
          ]),
        ]),
      ),
    )));
  }

  void _rejectDialog(LeaveRequest r) {
    final p = appState.palette;
    final ctrl = TextEditingController();
    showDialog(context: context, builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 400, padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: p.border)),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('REJECT LEAVE REQUEST', style: p.display(20, spacing: 1.0)),
          const SizedBox(height: 16),
          FormField2(label: 'Reason for Rejection', controller: ctrl, hint: 'Provide a reason...', maxLines: 3),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            GhostButton(label: 'Cancel', onTap: () => Navigator.pop(ctx)),
            const SizedBox(width: 12),
            GoldButton(label: 'Reject', onTap: () { appState.rejectLeave(r, ctrl.text); Navigator.pop(ctx); setState(() {}); }),
          ]),
        ]),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final list = _filtered;
    return Column(children: [
      FilterBar(
        searchHint: 'Search employee or department…', onSearch: (v) => setState(() => _q = v),
        filters: [
          ...['All', 'Pending', 'Approved', 'Rejected'].map((f) => _FilterPill(label: f, selected: _filter == f, palette: p, onTap: () => setState(() => _filter = f))),
        ],
        countText: '${list.length} requests',
        trailing: [GoldButton(label: 'New Request', icon: Icons.add, onTap: _addLeave)],
      ),
      const SizedBox(height: 12),
      Expanded(child: ScrollArea(builder: (sc) => ListView.builder(controller: sc, itemCount: list.length, itemBuilder: (_, i) => _LeaveCard(
        r: list[i], compact: false,
        onApprove: () { appState.approveLeave(list[i], appState.currentUser?.name ?? 'Manager'); setState(() {}); },
        onReject: () { _rejectDialog(list[i]); },
      )))),
    ]);
  }
}

class _LeaveCard extends StatelessWidget {
  final LeaveRequest r;
  final bool compact;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  const _LeaveCard({required this.r, required this.compact, required this.onApprove, required this.onReject});

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final statusColor = switch (r.status) {
      LeaveStatus.pending => p.warning,
      LeaveStatus.approved => p.success,
      LeaveStatus.rejected => p.danger,
      LeaveStatus.cancelled => p.textMuted,
    };
    return Panel(
      padding: const EdgeInsets.all(16),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        CircleAvatar(radius: 20, backgroundColor: p.gold.withValues(alpha: 0.15), child: Text(r.employeeName.substring(0, 1), style: p.body(14, color: p.gold, weight: FontWeight.w700))),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(r.employeeName, style: p.body(14, weight: FontWeight.w600)),
            const SizedBox(width: 8),
            StatusChip(label: r.department, color: p.info),
            const Spacer(),
            StatusChip(label: r.status.label, color: statusColor),
          ]),
          const SizedBox(height: 6),
          Row(children: [
            _InfoTag(Icons.calendar_today_outlined, '${prettyShort(r.fromDate)} – ${prettyShort(r.toDate)} (${r.days} days)', p),
            const SizedBox(width: 16),
            _InfoTag(Icons.event_note_outlined, r.type.label, p),
          ]),
          if (!compact) ...[
            const SizedBox(height: 6),
            Text(r.reason, style: p.body(12.5, color: p.textMuted)),
            if (r.approvedBy != null) ...[const SizedBox(height: 4), Text('Approved by: ${r.approvedBy}', style: p.body(12, color: p.success))],
            if (r.rejectionReason != null && r.rejectionReason!.isNotEmpty) ...[const SizedBox(height: 4), Text('Rejection reason: ${r.rejectionReason}', style: p.body(12, color: p.danger))],
          ],
        ])),
        if (r.status == LeaveStatus.pending) ...[
          const SizedBox(width: 12),
          Column(children: [
            GoldButton(label: 'Approve', dense: true, onTap: onApprove),
            const SizedBox(height: 8),
            GhostButton(label: 'Reject', onTap: onReject),
          ]),
        ],
      ]),
    );
  }
}

Widget _InfoTag(IconData icon, String text, AppPalette p) => Row(children: [Icon(icon, size: 13, color: p.textMuted), const SizedBox(width: 5), Text(text, style: p.body(12.5, color: p.textMuted))]);

// ══════════════════════════════════════════════════════════════════════════════
// PAYROLL TAB
// ══════════════════════════════════════════════════════════════════════════════
class _PayrollTab extends StatefulWidget {
  const _PayrollTab();
  @override
  State<_PayrollTab> createState() => _PayrollTabState();
}

class _PayrollTabState extends State<_PayrollTab> {
  int _month = DateTime.now().month;
  int _year = DateTime.now().year;
  final _months = ['January','February','March','April','May','June','July','August','September','October','November','December'];

  List<PayrollRecord> get _records => appState.payrollRecords.where((r) => r.month == _month && r.year == _year).toList();
  bool get _hasRecords => _records.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    return Column(children: [
      Panel(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), child: Row(children: [
        FilterDropdown<int>(value: _month, items: List.generate(12, (i) => DropdownMenuItem(value: i + 1, child: Text(_months[i]))).toList(), onChanged: (v) => setState(() => _month = v ?? _month)),
        const SizedBox(width: 12),
        FilterDropdown<int>(value: _year, items: [2024,2025,2026].map((y) => DropdownMenuItem(value: y, child: Text('$y'))).toList(), onChanged: (v) => setState(() => _year = v ?? _year)),
        const Spacer(),
        if (!_hasRecords) GoldButton(label: 'Process ${_months[_month-1]} Payroll', icon: Icons.play_arrow_outlined, onTap: () { appState.processPayroll(_month, _year); setState(() {}); }),
        if (_hasRecords) ...[
          Text('Total: ${money(_records.fold(0.0, (s, r) => s + r.netSalary))}', style: p.display(22, spacing: 0.5, color: p.gold)),
          const SizedBox(width: 16),
          GhostButton(label: 'Export PDF', icon: Icons.picture_as_pdf_outlined, onTap: () => showPdfPreview(context, title: 'Payroll — ${_months[_month - 1]} $_year', build: () => buildPayrollPdf(_records, monthLabel: '${_months[_month - 1]} $_year'))),
          const SizedBox(width: 8),
          GhostButton(label: 'Mark All Paid', icon: Icons.payments_outlined, onTap: () { for (final r in _records) r.status = PayrollStatus.paid; setState(() {}); }),
        ],
      ])),
      const SizedBox(height: 12),
      if (!_hasRecords)
        Expanded(child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.payments_outlined, size: 64, color: p.textMuted),
          const SizedBox(height: 16),
          Text('No payroll processed for ${_months[_month-1]} $_year', style: p.body(16, color: p.textMuted)),
          const SizedBox(height: 16),
          GoldButton(label: 'Process Payroll Now', icon: Icons.play_arrow_outlined, onTap: () { appState.processPayroll(_month, _year); setState(() {}); }),
        ])))
      else
        Expanded(child: Panel(padding: EdgeInsets.zero, child: ScrollArea(builder: (sc) => SingleChildScrollView(controller: sc, child: DataTable(
          headingRowColor: WidgetStateProperty.all(p.surfaceAlt),
          columnSpacing: 20,
          horizontalMargin: 20,
          columns: [
            DataColumn(label: Text('Employee', style: p.body(12, weight: FontWeight.w700))),
            DataColumn(label: Text('Designation', style: p.body(12, weight: FontWeight.w700))),
            DataColumn(label: Text('Days', style: p.body(12, weight: FontWeight.w700))),
            DataColumn(label: Text('Basic Salary', style: p.body(12, weight: FontWeight.w700))),
            DataColumn(label: Text('Allowances', style: p.body(12, weight: FontWeight.w700))),
            DataColumn(label: Text('OT', style: p.body(12, weight: FontWeight.w700))),
            DataColumn(label: Text('Deductions', style: p.body(12, weight: FontWeight.w700))),
            DataColumn(label: Text('Net Salary', style: p.body(12, weight: FontWeight.w700))),
            DataColumn(label: Text('Status', style: p.body(12, weight: FontWeight.w700))),
          ],
          rows: _records.map((r) {
            final statusColor = switch (r.status) { PayrollStatus.paid => p.success, PayrollStatus.processed => p.warning, PayrollStatus.draft => p.textMuted };
            return DataRow(cells: [
              DataCell(Text(r.employeeName, style: p.body(13, weight: FontWeight.w600))),
              DataCell(Text(r.designation, style: p.body(12.5, color: p.textMuted))),
              DataCell(Text('${r.presentDays}/${r.workingDays}', style: p.body(12.5))),
              DataCell(Text(money(r.basicSalary), style: p.body(12.5))),
              DataCell(Text(money(r.allowances), style: p.body(12.5, color: p.success))),
              DataCell(Text(money(r.overtime), style: p.body(12.5, color: p.info))),
              DataCell(Text(money(r.deductions), style: p.body(12.5, color: p.danger))),
              DataCell(Text(money(r.netSalary), style: p.body(13, weight: FontWeight.w700, color: p.gold))),
              DataCell(GestureDetector(
                onTap: () { r.status = PayrollStatus.paid; r.paidOn = prettyShort(DateTime.now()); setState(() {}); },
                child: StatusChip(label: r.status.label, color: statusColor),
              )),
            ]);
          }).toList(),
        ))))),
    ]);
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SALARY STRUCTURE TAB
// ══════════════════════════════════════════════════════════════════════════════
class _SalaryStructureTab extends StatefulWidget {
  const _SalaryStructureTab();
  @override
  State<_SalaryStructureTab> createState() => _SalaryStructureTabState();
}

class _SalaryStructureTabState extends State<_SalaryStructureTab> {
  SalaryStructure? _selected;

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final structures = appState.salaryStructures;
    return Row(children: [
      // Employee list
      SizedBox(width: 300, child: Panel(padding: EdgeInsets.zero, child: Column(children: [
        Padding(padding: const EdgeInsets.all(16), child: Text('EMPLOYEES', style: p.display(18, spacing: 1.0))),
        Divider(height: 1, color: p.border),
        Expanded(child: ScrollArea(builder: (sc) => ListView.builder(controller: sc, itemCount: structures.length, itemBuilder: (_, i) {
          final ss = structures[i];
          final sel = _selected == ss;
          return GestureDetector(
            onTap: () => setState(() => _selected = ss),
            child: MouseRegion(cursor: SystemMouseCursors.click, child: AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(color: sel ? p.gold.withValues(alpha: 0.08) : Colors.transparent, border: Border(left: BorderSide(width: sel ? 3 : 0, color: p.gold))),
              child: Row(children: [
                CircleAvatar(radius: 18, backgroundColor: p.gold.withValues(alpha: 0.15), child: Text(ss.employeeName.substring(0, 1), style: p.body(13, color: p.gold, weight: FontWeight.w700))),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(ss.employeeName, style: p.body(13.5, weight: FontWeight.w600)),
                  Text(money(ss.netSalary), style: p.body(12, color: p.gold, weight: FontWeight.w600)),
                ])),
              ]),
            )),
          );
        }))),
      ]))),
      const SizedBox(width: 18),
      // Detail panel
      Expanded(child: _selected == null
        ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.person_search_outlined, size: 56, color: p.textMuted),
            const SizedBox(height: 12),
            Text('Select an employee to view salary structure', style: p.body(14, color: p.textMuted)),
          ]))
        : _SalaryStructureDetail(ss: _selected!, onUpdate: () => setState(() {}))
      ),
    ]);
  }
}

class _SalaryStructureDetail extends StatefulWidget {
  final SalaryStructure ss;
  final VoidCallback onUpdate;
  const _SalaryStructureDetail({required this.ss, required this.onUpdate});
  @override
  State<_SalaryStructureDetail> createState() => _SalaryStructureDetailState();
}

class _SalaryStructureDetailState extends State<_SalaryStructureDetail> {
  late final TextEditingController _basic;
  @override
  void initState() { super.initState(); _basic = TextEditingController(text: widget.ss.basicSalary.toStringAsFixed(0)); }
  @override
  void dispose() { _basic.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final ss = widget.ss;
    return ScrollArea(builder: (sc) => SingleChildScrollView(controller: sc, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Panel(child: Row(children: [
        CircleAvatar(radius: 28, backgroundColor: p.gold.withValues(alpha: 0.15), child: Text(ss.employeeName.substring(0, 1), style: p.body(18, color: p.gold, weight: FontWeight.w700))),
        const SizedBox(width: 16),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(ss.employeeName, style: p.display(26, spacing: 0.5)),
          Text(ss.designation, style: p.body(13.5, color: p.textMuted)),
        ]),
        const Spacer(),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('Net Salary', style: p.body(12, color: p.textMuted)),
          Text(money(ss.netSalary), style: p.display(30, color: p.gold)),
        ]),
      ])),
      const SizedBox(height: 18),
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('EARNINGS', style: p.body(11.5, color: p.textMuted, weight: FontWeight.w700, spacing: 1.2)),
          const SizedBox(height: 14),
          _SalRow('Basic Salary', ss.basicSalary, p, isBasic: true),
          ...ss.components.where((c) => c.type == SalaryComponentType.earning).map((c) => _SalRow(c.name, c.isPercentage ? ss.basicSalary * c.amount / 100 : c.amount, p, note: c.isPercentage ? '${c.amount.toInt()}%' : null)),
          Divider(color: p.border, height: 20),
          _SalRow('Gross Salary', ss.totalEarnings, p, bold: true, color: p.success),
        ]))),
        const SizedBox(width: 16),
        Expanded(child: Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('DEDUCTIONS', style: p.body(11.5, color: p.textMuted, weight: FontWeight.w700, spacing: 1.2)),
          const SizedBox(height: 14),
          ...ss.components.where((c) => c.type == SalaryComponentType.deduction).map((c) => _SalRow(c.name, c.isPercentage ? ss.basicSalary * c.amount / 100 : c.amount, p, note: c.isPercentage ? '${c.amount.toInt()}%' : null)),
          Divider(color: p.border, height: 20),
          _SalRow('Total Deductions', ss.totalDeductions, p, bold: true, color: p.danger),
          Divider(color: p.border, height: 20),
          _SalRow('NET PAYABLE', ss.netSalary, p, bold: true, color: p.gold, large: true),
        ]))),
      ]),
    ])));
  }
}

Widget _SalRow(String label, double amount, AppPalette p, {String? note, bool bold = false, Color? color, bool isBasic = false, bool large = false}) =>
  Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(children: [
    Expanded(child: Text('${label}${note != null ? ' ($note)' : ''}', style: p.body(large ? 14 : 13, color: color ?? p.text, weight: bold ? FontWeight.w700 : FontWeight.w400))),
    Text(money(amount), style: p.body(large ? 15 : 13, color: color ?? p.text, weight: bold ? FontWeight.w700 : FontWeight.w500)),
  ]));

// ══════════════════════════════════════════════════════════════════════════════
// SHIFTS TAB
// ══════════════════════════════════════════════════════════════════════════════
class _ShiftsTab extends StatefulWidget {
  const _ShiftsTab();
  @override
  State<_ShiftsTab> createState() => _ShiftsTabState();
}

class _ShiftsTabState extends State<_ShiftsTab> {
  void _addShift() {
    final p = appState.palette;
    final nameCtrl = TextEditingController();
    final startCtrl = TextEditingController(text: '09:00');
    final endCtrl = TextEditingController(text: '18:00');
    final days = <String>{'Mon', 'Tue', 'Wed', 'Thu', 'Sat'};
    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, ss) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 480, padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: p.border)),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('ADD SHIFT', style: p.display(22, spacing: 1.0)),
          const SizedBox(height: 20),
          FormField2(label: 'Shift Name', controller: nameCtrl, hint: 'e.g. Evening Shift'),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: FormField2(label: 'Start Time', controller: startCtrl, hint: '09:00')),
            const SizedBox(width: 16),
            Expanded(child: FormField2(label: 'End Time', controller: endCtrl, hint: '18:00')),
          ]),
          const SizedBox(height: 16),
          Text('Work Days', style: p.body(12, color: p.textMuted, weight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, children: ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'].map((d) => FilterChip(
            label: Text(d, style: p.body(12)), selected: days.contains(d),
            selectedColor: p.gold.withValues(alpha: 0.2), checkmarkColor: p.gold,
            side: BorderSide(color: days.contains(d) ? p.gold : p.border),
            backgroundColor: p.surfaceAlt,
            labelStyle: p.body(12, color: days.contains(d) ? p.gold : p.text),
            onSelected: (v) => ss(() => v ? days.add(d) : days.remove(d)),
          )).toList()),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            GhostButton(label: 'Cancel', onTap: () => Navigator.pop(ctx)),
            const SizedBox(width: 12),
            GoldButton(label: 'Save Shift', onTap: () {
              if (nameCtrl.text.isEmpty) return;
              appState.shifts.add(Shift(id: 'SH-${appState.shifts.length + 1}', name: nameCtrl.text, startTime: startCtrl.text, endTime: endCtrl.text, workDays: days.toList(), assignedEmployeeIds: []));
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
    return Column(children: [
      Row(children: [const Spacer(), GoldButton(label: 'Add Shift', icon: Icons.add, onTap: _addShift)],),
      const SizedBox(height: 12),
      Expanded(child: ScrollArea(builder: (sc) => SingleChildScrollView(controller: sc, child: Wrap(spacing: 18, runSpacing: 18, children: appState.shifts.map((sh) => _ShiftCard(sh: sh, p: p)).toList())))),
    ]);
  }
}

class _ShiftCard extends StatelessWidget {
  final Shift sh;
  final AppPalette p;
  const _ShiftCard({required this.sh, required this.p});
  @override
  Widget build(BuildContext context) => SizedBox(width: 320, child: Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [
      Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: p.gold.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)), child: Icon(Icons.schedule_outlined, size: 20, color: p.gold)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(sh.name, style: p.body(15, weight: FontWeight.w700)),
        Text('${sh.startTime} – ${sh.endTime}', style: p.body(13, color: p.textMuted)),
      ])),
    ]),
    const SizedBox(height: 14),
    Wrap(spacing: 6, children: sh.workDays.map((d) => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(6), border: Border.all(color: p.border)), child: Text(d, style: p.body(11.5, weight: FontWeight.w600)))).toList()),
    const SizedBox(height: 14),
    Text('ASSIGNED (${sh.assignedEmployeeIds.length})', style: p.body(10.5, color: p.textMuted, weight: FontWeight.w700, spacing: 1.1)),
    const SizedBox(height: 8),
    ...appState.staff.where((s) => sh.assignedEmployeeIds.contains(s.id)).map((e) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Row(children: [
      CircleAvatar(radius: 12, backgroundColor: p.gold.withValues(alpha: 0.15), child: Text(e.name.substring(0, 1), style: p.body(10, color: p.gold, weight: FontWeight.w700))),
      const SizedBox(width: 8),
      Text(e.name, style: p.body(13)),
    ]))),
    if (sh.assignedEmployeeIds.isEmpty) Text('No employees assigned', style: p.body(12.5, color: p.textMuted)),
  ])));
}

// ══════════════════════════════════════════════════════════════════════════════
// RECRUITMENT TAB
// ══════════════════════════════════════════════════════════════════════════════
class _RecruitmentTab extends StatefulWidget {
  const _RecruitmentTab();
  @override
  State<_RecruitmentTab> createState() => _RecruitmentTabState();
}

class _RecruitmentTabState extends State<_RecruitmentTab> {
  JobPost? _selectedJob;

  void _addJob() {
    final p = appState.palette;
    final titleCtrl = TextEditingController();
    final deptCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final reqCtrl = TextEditingController();
    final salCtrl = TextEditingController();
    var type = 'Full-time';
    var openings = 1;
    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, ss) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 600, padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: p.border)),
        child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('POST NEW JOB', style: p.display(22, spacing: 1.0)),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: FormField2(label: 'Job Title *', controller: titleCtrl, hint: 'e.g. Registered Nurse')),
            const SizedBox(width: 16),
            Expanded(child: FormField2(label: 'Department *', controller: deptCtrl, hint: 'e.g. Medical')),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: Dropdown2<String>(label: 'Employment Type', value: type, items: ['Full-time','Part-time','Contract','Internship'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(), onChanged: (v) => ss(() => type = v ?? type))),
            const SizedBox(width: 16),
            Expanded(child: FormField2(label: 'Salary Range', controller: salCtrl, hint: 'e.g. PKR 60,000 – 80,000')),
            const SizedBox(width: 16),
            SizedBox(width: 100, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Openings', style: p.body(12, color: p.textMuted, weight: FontWeight.w600)),
              const SizedBox(height: 7),
              Row(children: [
                QtyButton(Icons.remove, () => ss(() => openings = (openings - 1).clamp(1, 20))),
                Expanded(child: Center(child: Text('$openings', style: p.body(14, weight: FontWeight.w600)))),
                QtyButton(Icons.add, () => ss(() => openings++)),
              ]),
            ])),
          ]),
          const SizedBox(height: 16),
          FormField2(label: 'Job Description *', controller: descCtrl, hint: 'Describe the role and responsibilities...', maxLines: 4),
          const SizedBox(height: 16),
          FormField2(label: 'Requirements', controller: reqCtrl, hint: 'Qualifications, experience, skills required...', maxLines: 3),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            GhostButton(label: 'Cancel', onTap: () => Navigator.pop(ctx)),
            const SizedBox(width: 12),
            GoldButton(label: 'Post Job', onTap: () {
              if (titleCtrl.text.isEmpty) return;
              appState.addJobPost(JobPost(id: appState.createJobPostId(), title: titleCtrl.text, department: deptCtrl.text, type: type, openings: openings, description: descCtrl.text, requirements: reqCtrl.text, salaryRange: salCtrl.text, postedOn: DateTime.now(), applicants: []));
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
    return Row(children: [
      // Job posts list
      SizedBox(width: 360, child: Column(children: [
        Row(children: [Text('JOB POSTINGS', style: p.display(18, spacing: 0.8)), const Spacer(), GoldButton(label: 'Post Job', icon: Icons.add, dense: true, onTap: _addJob)]),
        const SizedBox(height: 12),
        Expanded(child: ScrollArea(builder: (sc) => ListView.builder(controller: sc, itemCount: appState.jobPosts.length, itemBuilder: (_, i) {
          final jp = appState.jobPosts[i];
          final sel = _selectedJob == jp;
          return GestureDetector(
            onTap: () => setState(() => _selectedJob = jp),
            child: Panel(padding: const EdgeInsets.all(14), child: AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              decoration: BoxDecoration(border: Border(left: BorderSide(width: sel ? 3 : 0, color: p.gold))),
              padding: EdgeInsets.only(left: sel ? 10 : 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text(jp.title, style: p.body(14, weight: FontWeight.w600))),
                  StatusChip(label: jp.isActive ? 'Active' : 'Closed', color: jp.isActive ? p.success : p.textMuted),
                ]),
                const SizedBox(height: 6),
                Row(children: [
                  _InfoTag(Icons.business_outlined, jp.department, p),
                  const SizedBox(width: 12),
                  _InfoTag(Icons.work_outline, jp.type, p),
                ]),
                const SizedBox(height: 6),
                Row(children: [
                  _InfoTag(Icons.people_outline, '${jp.totalApplicants} applicants', p),
                  const SizedBox(width: 12),
                  _InfoTag(Icons.assignment_outlined, '${jp.openings} opening(s)', p),
                ]),
              ]),
            )),
          );
        }))),
      ])),
      const SizedBox(width: 18),
      // Applicants
      Expanded(child: _selectedJob == null
        ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.work_outline, size: 56, color: p.textMuted),
            const SizedBox(height: 12),
            Text('Select a job posting to see applicants', style: p.body(14, color: p.textMuted)),
          ]))
        : _ApplicantsPanel(job: _selectedJob!, onUpdate: () => setState(() {}))
      ),
    ]);
  }
}

class _ApplicantsPanel extends StatefulWidget {
  final JobPost job;
  final VoidCallback onUpdate;
  const _ApplicantsPanel({required this.job, required this.onUpdate});
  @override
  State<_ApplicantsPanel> createState() => _ApplicantsPanelState();
}

class _ApplicantsPanelState extends State<_ApplicantsPanel> {
  void _addApplicant() {
    final p = appState.palette;
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final expCtrl = TextEditingController();
    final salCtrl = TextEditingController();
    final compCtrl = TextEditingController();
    showDialog(context: context, builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 560, padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: p.border)),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('ADD APPLICANT', style: p.display(22, spacing: 1.0)),
          const SizedBox(height: 4),
          Text('For: ${widget.job.title}', style: p.body(13, color: p.textMuted)),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: FormField2(label: 'Full Name *', controller: nameCtrl, hint: 'Applicant name')),
            const SizedBox(width: 16),
            Expanded(child: FormField2(label: 'Email', controller: emailCtrl, hint: 'email@example.com', keyboard: TextInputType.emailAddress)),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: FormField2(label: 'Phone *', controller: phoneCtrl, hint: '+92 3XX XXXXXXX', keyboard: TextInputType.phone)),
            const SizedBox(width: 16),
            Expanded(child: FormField2(label: 'Experience', controller: expCtrl, hint: 'e.g. 3 years in OT')),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: FormField2(label: 'Expected Salary', controller: salCtrl, hint: 'e.g. PKR 70,000')),
            const SizedBox(width: 16),
            Expanded(child: FormField2(label: 'Current Company', controller: compCtrl, hint: 'e.g. Aga Khan Hospital')),
          ]),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            GhostButton(label: 'Cancel', onTap: () => Navigator.pop(ctx)),
            const SizedBox(width: 12),
            GoldButton(label: 'Add Applicant', onTap: () {
              if (nameCtrl.text.isEmpty) return;
              appState.addApplicant(widget.job, JobApplicant(id: appState.createApplicantId(), name: nameCtrl.text, email: emailCtrl.text, phone: phoneCtrl.text, position: widget.job.title, experience: expCtrl.text, expectedSalary: salCtrl.text, currentCompany: compCtrl.text.isEmpty ? null : compCtrl.text, appliedOn: DateTime.now(), interviews: []));
              Navigator.pop(ctx); setState(() {}); widget.onUpdate();
            }),
          ]),
        ]),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Panel(child: Row(children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.job.title, style: p.display(26, spacing: 0.5)),
          Row(children: [
            _InfoTag(Icons.business_outlined, widget.job.department, p),
            const SizedBox(width: 12),
            _InfoTag(Icons.work_outline, widget.job.type, p),
            if (widget.job.salaryRange != null) ...[const SizedBox(width: 12), _InfoTag(Icons.payments_outlined, widget.job.salaryRange!, p)],
          ]),
        ]),
        const Spacer(),
        GoldButton(label: 'Add Applicant', icon: Icons.person_add_outlined, onTap: _addApplicant),
      ])),
      const SizedBox(height: 12),
      Expanded(child: ScrollArea(builder: (sc) => ListView.builder(controller: sc, itemCount: widget.job.applicants.length, itemBuilder: (_, i) {
        final a = widget.job.applicants[i];
        final statusColor = switch (a.status) {
          ApplicantStatus.received => p.textMuted, ApplicantStatus.shortlisted => p.info,
          ApplicantStatus.interviewed => p.warning, ApplicantStatus.selected => p.success,
          ApplicantStatus.rejected => p.danger, ApplicantStatus.withdrawn => p.textMuted,
        };
        return Panel(padding: const EdgeInsets.all(16), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          CircleAvatar(radius: 22, backgroundColor: p.gold.withValues(alpha: 0.15), child: Text(a.name.substring(0, 1), style: p.body(14, color: p.gold, weight: FontWeight.w700))),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Text(a.name, style: p.body(14, weight: FontWeight.w600)), const Spacer(), StatusChip(label: a.status.label, color: statusColor)]),
            const SizedBox(height: 6),
            Row(children: [
              if (a.email.isNotEmpty) _InfoTag(Icons.email_outlined, a.email, p),
              const SizedBox(width: 12),
              _InfoTag(Icons.phone_outlined, a.phone, p),
            ]),
            const SizedBox(height: 4),
            Row(children: [
              _InfoTag(Icons.work_history_outlined, a.experience, p),
              const SizedBox(width: 12),
              _InfoTag(Icons.payments_outlined, a.expectedSalary, p),
              if (a.currentCompany != null) ...[const SizedBox(width: 12), _InfoTag(Icons.business_outlined, a.currentCompany!, p)],
            ]),
            if (a.interviews.isNotEmpty) ...[
              const SizedBox(height: 6),
              ...a.interviews.map((iv) => Row(children: [Icon(Icons.event_outlined, size: 13, color: p.gold), const SizedBox(width: 5), Text('Interview: ${prettyShort(iv.scheduledAt)} with ${iv.interviewer} — ${iv.status}', style: p.body(12, color: p.gold))])),
            ],
          ])),
          const SizedBox(width: 12),
          Column(children: [
            if (a.status == ApplicantStatus.received) GoldButton(label: 'Shortlist', dense: true, onTap: () { appState.updateApplicantStatus(a, ApplicantStatus.shortlisted); setState(() {}); }),
            if (a.status == ApplicantStatus.shortlisted) GoldButton(label: 'Mark Interviewed', dense: true, onTap: () { appState.updateApplicantStatus(a, ApplicantStatus.interviewed); setState(() {}); }),
            if (a.status == ApplicantStatus.interviewed) GoldButton(label: 'Select', dense: true, onTap: () { appState.updateApplicantStatus(a, ApplicantStatus.selected); setState(() {}); }),
            if (a.status != ApplicantStatus.rejected && a.status != ApplicantStatus.selected) ...[
              const SizedBox(height: 8),
              GhostButton(label: 'Reject', onTap: () { appState.updateApplicantStatus(a, ApplicantStatus.rejected); setState(() {}); }),
            ],
          ]),
        ]));
      }))),
    ]);
  }
}

// ── Shared helpers ────────────────────────────────────────────────────────────
class _FilterPill extends StatelessWidget {
  final String label;
  final bool selected;
  final AppPalette palette;
  final VoidCallback onTap;
  const _FilterPill({required this.label, required this.selected, required this.palette, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final p = palette;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? p.gold.withValues(alpha: 0.15) : p.surfaceAlt,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? p.gold : p.border),
        ),
        child: Text(label, style: p.body(12.5, color: selected ? p.gold : p.textMuted, weight: selected ? FontWeight.w700 : FontWeight.w500)),
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime value;
  final AppPalette palette;
  final ValueChanged<DateTime> onPick;
  const _DatePickerField({required this.label, required this.value, required this.palette, required this.onPick});
  @override
  Widget build(BuildContext context) {
    final p = palette;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: p.body(12, color: p.textMuted, weight: FontWeight.w600)),
      const SizedBox(height: 7),
      GestureDetector(
        onTap: () async {
          final picked = await showDatePicker(context: context, initialDate: value, firstDate: DateTime(2020), lastDate: DateTime(2030),
            builder: (ctx, child) => Theme(data: ThemeData.dark().copyWith(colorScheme: ColorScheme.dark(primary: p.gold, surface: p.surface)), child: child!));
          if (picked != null) onPick(picked);
        },
        child: Container(
          height: 46, padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(8), border: Border.all(color: p.border)),
          child: Row(children: [
            Icon(Icons.calendar_today_outlined, size: 15, color: p.gold),
            const SizedBox(width: 10),
            Text(prettyShort(value), style: p.body(13.5, weight: FontWeight.w500)),
          ]),
        ),
      ),
    ]);
  }
}

// ── Payslips ──────────────────────────────────────────────────────────────────
class _PayslipsTab extends StatefulWidget {
  const _PayslipsTab();
  @override
  State<_PayslipsTab> createState() => _PayslipsTabState();
}

class _PayslipsTabState extends State<_PayslipsTab> {
  String _selectedMonth = 'Jul 2026';
  String? _selectedStaff;

  static const _months = ['Jul 2026', 'Jun 2026', 'May 2026', 'Apr 2026', 'Mar 2026', 'Feb 2026', 'Jan 2026'];

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final payrolls = appState.payrollRecords.where((pr) {
      final monthMatch = _selectedMonth.isEmpty || '${_monthName(pr.month)} ${pr.year}' == _selectedMonth;
      final staffMatch = _selectedStaff == null || _selectedStaff!.isEmpty || pr.employeeName == _selectedStaff;
      return monthMatch && staffMatch;
    }).toList();

    return ScrollArea(builder: (sc) => SingleChildScrollView(controller: sc, padding: const EdgeInsets.only(right: 12, bottom: 28), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      MetricRow([
        MetricCard(title: 'Payslips This Month', value: '${payrolls.length}', delta: '${payrolls.length} records', icon: Icons.receipt_long_outlined),
        MetricCard(title: 'Total Gross', value: money(payrolls.fold(0.0, (s, r) => s + r.grossSalary)), delta: 'gross salary', icon: Icons.payments_outlined),
        MetricCard(title: 'Total Deductions', value: money(payrolls.fold(0.0, (s, r) => s + r.deductions)), delta: 'deducted', deltaUp: false, icon: Icons.remove_circle_outline),
        MetricCard(title: 'Total Net Pay', value: money(payrolls.fold(0.0, (s, r) => s + r.netSalary)), delta: 'net payable', icon: Icons.account_balance_wallet_outlined),
      ]),
      const SizedBox(height: 18),
      Row(children: [
        Text('PAYSLIPS', style: p.display(18, spacing: 1.2)),
        const Spacer(),
        SizedBox(width: 180, child: Dropdown2<String>(label: 'Month', value: _selectedMonth, items: _months.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(), onChanged: (v) => setState(() => _selectedMonth = v ?? _selectedMonth))),
        const SizedBox(width: 12),
        SizedBox(width: 200, child: Dropdown2<String?>(label: 'Staff', value: _selectedStaff, items: [const DropdownMenuItem<String?>(value: null, child: Text('All Staff')), ...appState.staff.map((s) => DropdownMenuItem<String?>(value: s.name, child: Text(s.name, overflow: TextOverflow.ellipsis)))], onChanged: (v) => setState(() => _selectedStaff = v))),
      ]),
      const SizedBox(height: 14),
      if (payrolls.isEmpty)
        Center(child: Padding(padding: const EdgeInsets.all(40), child: Text('No payslips for selected period.', style: p.body(14, color: p.textMuted)))),
      ...payrolls.map((pr) => Padding(padding: const EdgeInsets.only(bottom: 14), child: Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: p.gold.withValues(alpha: 0.12), shape: BoxShape.circle), child: Center(child: Text(pr.employeeName.isNotEmpty ? pr.employeeName[0] : '?', style: p.body(16, weight: FontWeight.w700, color: p.gold)))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(pr.employeeName, style: p.body(14, weight: FontWeight.w700)),
            Text('${_monthName(pr.month)} ${pr.year}', style: p.body(12, color: p.textMuted)),
          ])),
          StatusChip(label: pr.status.label, color: pr.status == PayrollStatus.paid ? p.success : pr.status == PayrollStatus.processed ? p.info : p.warning),
          const SizedBox(width: 12),
          GhostButton(label: 'Print Payslip', icon: Icons.print_outlined, onTap: () => toast(context, 'Printing payslip for ${pr.employeeName}')),
        ]),
        const Divider(height: 20),
        Row(children: [
          _payRow(p, 'Basic Salary', money(pr.basicSalary)),
          _payRow(p, 'Allowances', money(pr.allowances)),
          _payRow(p, 'Overtime', money(pr.overtime)),
          _payRow(p, 'Deductions', money(pr.deductions), color: p.danger),
          _payRow(p, 'Net Pay', money(pr.netSalary), color: p.gold, bold: true),
        ]),
      ])))),
    ])));
  }

  Widget _payRow(AppPalette p, String label, String value, {Color? color, bool bold = false}) => Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: p.body(11, color: p.textMuted)),
    const SizedBox(height: 4),
    Text(value, style: p.body(13, weight: bold ? FontWeight.w700 : FontWeight.w500, color: color ?? p.text)),
  ]));

  String _monthName(int m) => const ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][m];
}
