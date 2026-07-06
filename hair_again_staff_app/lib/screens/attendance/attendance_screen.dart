import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../core/staff_data.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});
  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  @override
  void initState() { super.initState(); staffData.addListener(_onData); }
  void _onData() { if (mounted) setState(() {}); }
  @override
  void dispose() { staffData.removeListener(_onData); super.dispose(); }

  int get _presentCount => staffData.attendance.where((a) => a.status == 'Present').length;
  int get _absentCount  => staffData.attendance.where((a) => a.status == 'Absent').length;
  int get _halfCount    => staffData.attendance.where((a) => a.status == 'Half Day').length;
  double get _totalHours => staffData.attendance.fold(0, (s, a) => s + a.hoursWorked);

  @override
  Widget build(BuildContext context) {
    final p = HaTheme.of(context);
    final clocked = staffData.clockedIn;
    final clockInTime = staffData.clockInTime;

    String duration = '--';
    if (clocked && clockInTime != null) {
      final diff = DateTime.now().difference(clockInTime);
      duration = '${diff.inHours}h ${diff.inMinutes % 60}m';
    }

    return Scaffold(
      backgroundColor: p.bg,
      appBar: const StaffAppBar(title: 'Attendance'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // Today's clock widget
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: p.isDark
                    ? [const Color(0xFF0E0E12), const Color(0xFF1A1500)]
                    : [const Color(0xFFFBF9F5), const Color(0xFFF5EDD8)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: clocked ? kSuccess.withValues(alpha: 0.4) : p.border),
              boxShadow: [if (clocked) BoxShadow(color: kSuccess.withValues(alpha: 0.08), blurRadius: 16)],
            ),
            child: Column(children: [
              Row(children: [
                Container(width: 56, height: 56,
                  decoration: BoxDecoration(
                    color: (clocked ? kSuccess : p.surfaceAlt).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(clocked ? Icons.timer_rounded : Icons.timer_off_rounded,
                      color: clocked ? kSuccess : p.textMuted, size: 28)),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Today — ${DateFormat('d MMM yyyy').format(DateTime.now())}', style: p.body(12, color: p.textMuted)),
                  Text(clocked ? 'Clocked In' : 'Not Clocked In', style: p.body(18, weight: FontWeight.w800, color: clocked ? kSuccess : p.text)),
                  if (clocked && clockInTime != null)
                    Text('Since ${DateFormat('hh:mm a').format(clockInTime)} • $duration', style: p.body(12, color: p.textMuted)),
                ])),
              ]),
              const SizedBox(height: 20),
              GoldButton(
                label: clocked ? 'CLOCK OUT' : 'CLOCK IN',
                icon: clocked ? Icons.logout_rounded : Icons.login_rounded,
                onTap: clocked ? staffData.clockOut : staffData.clockIn,
              ),
            ]),
          ),
          const SizedBox(height: 24),

          // Monthly summary
          Text('This Month', style: p.body(16, weight: FontWeight.w700)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _SummaryCard(label: 'Present',   value: '$_presentCount', color: kSuccess, icon: Icons.check_circle_rounded, p: p)),
            const SizedBox(width: 10),
            Expanded(child: _SummaryCard(label: 'Absent',    value: '$_absentCount',  color: kDanger,  icon: Icons.cancel_rounded, p: p)),
            const SizedBox(width: 10),
            Expanded(child: _SummaryCard(label: 'Half Day',  value: '$_halfCount',    color: kWarning, icon: Icons.timelapse_rounded, p: p)),
            const SizedBox(width: 10),
            Expanded(child: _SummaryCard(label: 'Hours',     value: '${_totalHours.toInt()}h', color: kInfo, icon: Icons.schedule_rounded, p: p)),
          ]),
          const SizedBox(height: 28),

          // Attendance log
          Text('Attendance Log', style: p.body(16, weight: FontWeight.w700)),
          const SizedBox(height: 12),
          ...staffData.attendance.map((rec) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: p.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: p.border),
            ),
            child: Row(children: [
              Container(width: 44, height: 44,
                decoration: BoxDecoration(color: rec.statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: Center(child: Text(
                  DateFormat('d').format(rec.date),
                  style: p.body(16, color: rec.statusColor, weight: FontWeight.w800),
                ))),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(rec.dateStr, style: p.body(13, weight: FontWeight.w600)),
                if (rec.clockIn != null) Text('In: ${rec.clockIn}  →  Out: ${rec.clockOut ?? '—'}', style: p.body(11, color: p.textMuted)),
              ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                StatusBadge(label: rec.status, color: rec.statusColor),
                if (rec.hoursWorked > 0) ...[
                  const SizedBox(height: 4),
                  Text('${rec.hoursWorked}h', style: p.body(11, color: p.textMuted)),
                ],
              ]),
            ]),
          )),
        ]),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label, value;
  final Color color;
  final IconData icon;
  final AppPalette p;
  const _SummaryCard({required this.label, required this.value, required this.color, required this.icon, required this.p});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
    decoration: BoxDecoration(
      color: p.surface, borderRadius: BorderRadius.circular(14),
      border: Border.all(color: color.withValues(alpha: 0.2)),
    ),
    child: Column(children: [
      Icon(icon, color: color, size: 22),
      const SizedBox(height: 6),
      Text(value, style: p.body(16, color: color, weight: FontWeight.w800)),
      const SizedBox(height: 2),
      Text(label, style: p.body(10, color: p.textMuted), textAlign: TextAlign.center),
    ]),
  );
}
