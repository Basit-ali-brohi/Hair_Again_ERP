// modules/appointments/views — custom month calendar grid + day timeline
// scheduler with inline confirm/cancel/delete, and the add-appointment overlay
// (patient + slot + assigned lead surgeon).
import 'package:flutter/material.dart';

import '../../../core/core.dart';
import '../models/appointment.dart';
import '../../crm/models/patient.dart';
import '../../pos_inventory/models/pos_models.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});
  @override
  State<AppointmentsScreen> createState() => AppointmentsScreenState();
}

class AppointmentsScreenState extends State<AppointmentsScreen> {
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime _selected = DateTime.now();
  String _search = '';
  ApptStatus? _statusFilter;

  void openAddAppointment() => _showForm();

  bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  List<Appointment> get _dayList {
    final q = _search.toLowerCase();
    final l = appState.appointments.where((a) => _sameDay(a.when, _selected) && (_statusFilter == null || a.status == _statusFilter) && (q.isEmpty || a.patientName.toLowerCase().contains(q) || a.treatment.toLowerCase().contains(q) || a.surgeon.toLowerCase().contains(q))).toList();
    l.sort((a, b) => a.when.compareTo(b.when));
    return l;
  }

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    return ScreenScaffold(
      title: 'APPOINTMENTS',
      subtitle: 'Schedule, confirm and track every clinic session.',
      actions: [GoldButton(label: 'Add Appointment', icon: Icons.add, onTap: openAddAppointment)],
      child: LayoutBuilder(builder: (ctx, c) {
        return ScrollArea(builder: (sc) => SingleChildScrollView(
          controller: sc,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            MetricRow([
              MetricCard(title: "Today's Bookings", value: '${appState.todaysAppointments}', delta: '+3', icon: Icons.today_outlined),
              MetricCard(title: 'Confirmed Procedures', value: '${appState.apptCount(ApptStatus.confirmed)}', delta: '+2', icon: Icons.verified_outlined),
              MetricCard(title: 'Pending Slots', value: '${appState.apptCount(ApptStatus.pending)}', delta: '${appState.apptCount(ApptStatus.pending)} awaiting confirm', deltaUp: false, icon: Icons.hourglass_bottom_outlined),
              MetricCard(title: 'Cancellations', value: '${appState.apptCount(ApptStatus.cancelled)}', delta: '${appState.apptCount(ApptStatus.cancelled)} this month', deltaUp: false, icon: Icons.event_busy_outlined),
            ]),
            const SizedBox(height: 18),
            SizedBox(
              height: c.maxHeight,
              child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Expanded(flex: 4, child: _calendar(p)),
                const SizedBox(width: 18),
                Expanded(flex: 6, child: _timeline(p)),
              ]),
            ),
            const SizedBox(height: 24),
          ]),
        ));
      }),
    );
  }

  Widget _calendar(AppPalette p) {
    final first = DateTime(_month.year, _month.month, 1);
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final leading = first.weekday % 7; // Sun=0
    final cells = <Widget>[];
    const dows = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    for (final d in dows) {
      cells.add(Center(child: Text(d, style: p.body(11, color: p.textMuted, weight: FontWeight.w700))));
    }
    for (int i = 0; i < leading; i++) {
      cells.add(const SizedBox());
    }
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_month.year, _month.month, day);
      final isSel = _sameDay(date, _selected);
      final isToday = _sameDay(date, DateTime.now());
      final has = appState.appointments.any((a) => _sameDay(a.when, date));
      cells.add(GestureDetector(
        onTap: () => setState(() => _selected = date),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Container(
            margin: const EdgeInsets.all(3),
            decoration: BoxDecoration(gradient: isSel ? p.goldGradient : null, color: isSel ? null : (isToday ? p.surfaceAlt : Colors.transparent), borderRadius: BorderRadius.circular(8), border: Border.all(color: isToday && !isSel ? p.gold.withValues(alpha: 0.5) : Colors.transparent)),
            child: Stack(alignment: Alignment.center, children: [Text('$day', style: p.body(13, color: isSel ? Colors.black87 : p.text, weight: isSel ? FontWeight.w700 : FontWeight.w500)), if (has) Positioned(bottom: 6, child: Container(width: 5, height: 5, decoration: BoxDecoration(color: isSel ? Colors.black87 : p.gold, shape: BoxShape.circle)))]),
          ),
        ),
      ));
    }
    return Panel(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [Expanded(child: Text('${monthName(_month.month)} ${_month.year}', style: p.display(24))), QtyButton(Icons.chevron_left, () => setState(() => _month = DateTime(_month.year, _month.month - 1))), const SizedBox(width: 8), QtyButton(Icons.chevron_right, () => setState(() => _month = DateTime(_month.year, _month.month + 1)))]),
        const SizedBox(height: 14),
        Expanded(child: GridView.count(crossAxisCount: 7, physics: const NeverScrollableScrollPhysics(), childAspectRatio: 1.05, children: cells)),
        const SizedBox(height: 6),
        Row(children: [Container(width: 8, height: 8, decoration: BoxDecoration(color: p.gold, shape: BoxShape.circle)), const SizedBox(width: 6), Text('Has appointments', style: p.body(11.5, color: p.textMuted))]),
      ]),
    );
  }

  Widget _timeline(AppPalette p) {
    final list = _dayList;
    return Panel(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SectionTitle(prettyDate(_selected), sub: '${list.length} slot(s) scheduled'),
        const SizedBox(height: 14),
        FilterBar(
          searchHint: 'Search slots…',
          onSearch: (v) => setState(() => _search = v),
          filters: [
            FilterDropdown<ApptStatus?>(
              icon: Icons.flag_outlined,
              value: _statusFilter,
              items: [
                const DropdownMenuItem<ApptStatus?>(value: null, child: Text('All Statuses')),
                ...ApptStatus.values.map((s) => DropdownMenuItem<ApptStatus?>(value: s, child: Text(s.label))),
              ],
              onChanged: (v) => setState(() => _statusFilter = v),
            ),
          ],
          onClear: () => setState(() { _search = ''; _statusFilter = null; }),
        ),
        const SizedBox(height: 16),
        Expanded(child: list.isEmpty ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.event_available_outlined, size: 42, color: p.textMuted.withValues(alpha: 0.5)), const SizedBox(height: 12), Text('No appointments for this day', style: p.body(13, color: p.textMuted))])) : ScrollArea(builder: (sc) => ListView.separated(controller: sc, padding: const EdgeInsets.only(right: 12), itemCount: list.length, separatorBuilder: (_, _) => const SizedBox(height: 10), itemBuilder: (_, i) => _slot(p, list[i])))),
      ]),
    );
  }

  void _showApptDetail(Appointment a) {
    final p = appState.palette;
    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, ss) {
      final c = p.apptColor(a.status);
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 500, padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: p.border)),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: c.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(10)), child: Icon(Icons.event_outlined, size: 22, color: c)),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(a.patientName, style: p.display(22, spacing: 0.3)),
                const SizedBox(height: 4),
                StatusChip(label: a.status.label, color: c),
              ])),
              GestureDetector(onTap: () => Navigator.pop(ctx), child: MouseRegion(cursor: SystemMouseCursors.click, child: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(8)), child: Icon(Icons.close, size: 18, color: p.textMuted)))),
            ]),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(8), border: Border.all(color: p.border)),
              child: Column(children: [
                Row(children: [Icon(Icons.schedule_outlined, size: 15, color: p.gold), const SizedBox(width: 10), Text('${prettyDate(a.when)} at ${timeLabel(a.when)}', style: p.body(13, weight: FontWeight.w600))]),
                const SizedBox(height: 12),
                Row(children: [Icon(Icons.healing_outlined, size: 15, color: p.gold), const SizedBox(width: 10), Expanded(child: Text(a.treatment, style: p.body(13)))]),
                const SizedBox(height: 12),
                Row(children: [Icon(Icons.medical_information_outlined, size: 15, color: p.gold), const SizedBox(width: 10), Text(a.surgeon, style: p.body(13))]),
              ]),
            ),
            const SizedBox(height: 20),
            Row(children: [
              if (a.status != ApptStatus.confirmed) GestureDetector(
                onTap: () { appState.setApptStatus(a, ApptStatus.confirmed); ss(() {}); setState(() {}); },
                child: MouseRegion(cursor: SystemMouseCursors.click, child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(color: p.success.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8), border: Border.all(color: p.success.withValues(alpha: 0.3))),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.check, size: 16, color: p.success), const SizedBox(width: 8), Text('Confirm', style: p.body(13, color: p.success, weight: FontWeight.w600))]),
                )),
              ),
              if (a.status != ApptStatus.confirmed) const SizedBox(width: 8),
              if (a.status != ApptStatus.cancelled) GestureDetector(
                onTap: () { appState.setApptStatus(a, ApptStatus.cancelled); ss(() {}); setState(() {}); },
                child: MouseRegion(cursor: SystemMouseCursors.click, child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(color: p.danger.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8), border: Border.all(color: p.danger.withValues(alpha: 0.3))),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.close, size: 16, color: p.danger), const SizedBox(width: 8), Text('Cancel', style: p.body(13, color: p.danger, weight: FontWeight.w600))]),
                )),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () async {
                  Navigator.pop(ctx);
                  final ok = await confirm(context, 'Delete appointment?', 'Remove ${a.patientName}\'s slot.');
                  if (ok) { appState.deleteAppointment(a); setState(() {}); }
                },
                child: MouseRegion(cursor: SystemMouseCursors.click, child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(8), border: Border.all(color: p.border)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.delete_outline, size: 16, color: p.textMuted), const SizedBox(width: 8), Text('Delete', style: p.body(13, color: p.textMuted))]),
                )),
              ),
              const SizedBox(width: 8),
              GhostButton(label: 'Close', onTap: () => Navigator.pop(ctx)),
            ]),
          ]),
        ),
      );
    }));
  }

  Widget _slot(AppPalette p, Appointment a) {
    final c = p.apptColor(a.status);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _showApptDetail(a),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(8), border: Border.all(color: p.border)),
          child: Row(children: [
            Container(width: 4, height: 46, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(8))),
            const SizedBox(width: 14),
            SizedBox(width: 78, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(timeLabel(a.when), style: p.display(22)), Text(a.status.label, style: p.body(10.5, color: c, weight: FontWeight.w600))])),
            const SizedBox(width: 8),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(a.patientName, style: p.body(14, weight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(a.treatment, style: p.body(12, color: p.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Row(children: [Icon(Icons.medical_information_outlined, size: 13, color: p.gold), const SizedBox(width: 5), Text(a.surgeon, style: p.body(11.5, color: p.textMuted))]),
            ])),
            if (a.status != ApptStatus.confirmed) _act(p, Icons.check, p.success, 'Confirm', () => appState.setApptStatus(a, ApptStatus.confirmed)),
            if (a.status != ApptStatus.cancelled) _act(p, Icons.close, p.danger, 'Cancel', () => appState.setApptStatus(a, ApptStatus.cancelled)),
            _act(p, Icons.delete_outline, p.textMuted, 'Delete', () async { final ok = await confirm(context, 'Delete appointment?', 'Remove ${a.patientName}\'s slot.'); if (ok) appState.deleteAppointment(a); }),
          ]),
        ),
      ),
    );
  }

  Widget _act(AppPalette p, IconData ic, Color c, String tip, VoidCallback onTap) => Padding(
        padding: const EdgeInsets.only(left: 6),
        child: Tooltip(message: tip, child: GestureDetector(onTap: onTap, child: MouseRegion(cursor: SystemMouseCursors.click, child: Container(width: 32, height: 32, decoration: BoxDecoration(color: c.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)), child: Icon(ic, size: 16, color: c))))),
      );

  void _showForm() {
    showDialog(context: context, barrierColor: Colors.black.withValues(alpha: 0.55), builder: (_) => AppointmentFormDialog(initialDate: _selected)).then((res) { if (res is DateTime) setState(() { _selected = res; _month = DateTime(res.year, res.month); }); });
  }
}

class AppointmentFormDialog extends StatefulWidget {
  final DateTime initialDate;
  const AppointmentFormDialog({super.key, required this.initialDate});
  @override
  State<AppointmentFormDialog> createState() => _AppointmentFormDialogState();
}

class _AppointmentFormDialogState extends State<AppointmentFormDialog> {
  Patient? _patient;
  Treatment? _treatment;
  String? _surgeon;
  late DateTime _date;
  TimeOfDay _time = const TimeOfDay(hour: 11, minute: 0);
  ApptStatus _status = ApptStatus.pending;

  @override
  void initState() {
    super.initState();
    _date = widget.initialDate;
    _patient = appState.patients.isNotEmpty ? appState.patients.first : null;
    _treatment = appState.treatments.first;
    _surgeon = appState.surgeons.first;
  }

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    return Dialog(
      backgroundColor: p.surface, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: p.border)),
      child: Container(
        width: 500, padding: const EdgeInsets.all(26),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: p.gold.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)), child: Icon(Icons.calendar_month, color: p.gold)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('NEW APPOINTMENT', style: p.display(28)), Text('Assign patient, time and surgeon', style: p.body(12.5, color: p.textMuted))])),
            IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Icons.close, color: p.textMuted)),
          ]),
          const SizedBox(height: 18),
          Dropdown2<Patient?>(label: 'Patient', value: _patient, items: appState.patients.map((pt) => DropdownMenuItem<Patient?>(value: pt, child: Text(pt.name))).toList(), onChanged: (v) => setState(() => _patient = v)),
          const SizedBox(height: 14),
          Dropdown2<Treatment?>(label: 'Treatment', value: _treatment, items: appState.treatments.map((t) => DropdownMenuItem<Treatment?>(value: t, child: Text(t.name, overflow: TextOverflow.ellipsis))).toList(), onChanged: (v) => setState(() => _treatment = v)),
          const SizedBox(height: 14),
          Dropdown2<String?>(label: 'Lead Surgeon', value: _surgeon, items: appState.surgeons.map((s) => DropdownMenuItem<String?>(value: s, child: Text(s))).toList(), onChanged: (v) => setState(() => _surgeon = v)),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: _picker(p, 'Date', prettyShort(_date), Icons.event, () async { final d = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime.now().subtract(const Duration(days: 1)), lastDate: DateTime.now().add(const Duration(days: 365)), builder: (ctx, c) => Theme(data: _pt(p), child: c!)); if (d != null) setState(() => _date = d); })),
            const SizedBox(width: 14),
            Expanded(child: _picker(p, 'Time', _time.format(context), Icons.schedule, () async { final t = await showTimePicker(context: context, initialTime: _time, builder: (ctx, c) => Theme(data: _pt(p), child: c!)); if (t != null) setState(() => _time = t); })),
          ]),
          const SizedBox(height: 14),
          Dropdown2<ApptStatus>(label: 'Status', value: _status, items: ApptStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.label))).toList(), onChanged: (v) => setState(() => _status = v ?? ApptStatus.pending)),
          const SizedBox(height: 24),
          Row(children: [const Spacer(), GhostButton(label: 'Cancel', onTap: () => Navigator.pop(context)), const SizedBox(width: 12), GoldButton(label: 'Confirm Booking', icon: Icons.check, onTap: () {
            if (_patient == null || _treatment == null || _surgeon == null) return;
            final when = DateTime(_date.year, _date.month, _date.day, _time.hour, _time.minute);
            appState.addAppointment(Appointment(id: appState.createAppointmentId(), patientName: _patient!.name, treatment: _treatment!.name, surgeon: _surgeon!, when: when, status: _status));
            Navigator.pop(context, when);
            toast(context, 'Appointment booked for ${_patient!.name}');
          })]),
        ]),
      ),
    );
  }

  ThemeData _pt(AppPalette p) {
    final base = appState.isDark ? ThemeData.dark() : ThemeData.light();
    return base.copyWith(colorScheme: base.colorScheme.copyWith(primary: p.gold, surface: p.surface, onPrimary: Colors.black87));
  }

  Widget _picker(AppPalette p, String label, String value, IconData ic, VoidCallback onTap) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: p.body(12, color: p.textMuted, weight: FontWeight.w600)),
        const SizedBox(height: 7),
        GestureDetector(onTap: onTap, child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13), decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(8), border: Border.all(color: p.border)), child: Row(children: [Icon(ic, size: 17, color: p.gold), const SizedBox(width: 10), Text(value, style: p.body(13.5, weight: FontWeight.w500))]))),
      ]);
}
