import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../core/widgets.dart';

class TreatmentHistoryScreen extends StatelessWidget {
  const TreatmentHistoryScreen({super.key});

  static const _records = [
    _TxRecord('FUE Hair Transplant', 'Dr. Bilal Khan', '10 Mar 2026', '3,200 grafts — zone A & B', 'Completed', kSuccess),
    _TxRecord('PRP Therapy — Session 3', 'Dr. Sara Malik', '15 Feb 2026', 'Post-transplant stimulation', 'Completed', kSuccess),
    _TxRecord('PRP Therapy — Session 2', 'Dr. Sara Malik', '20 Jan 2026', 'Post-transplant stimulation', 'Completed', kSuccess),
    _TxRecord('PRP Therapy — Session 1', 'Dr. Sara Malik', '5 Jan 2026', 'Pre-op platelet therapy', 'Completed', kSuccess),
    _TxRecord('Scalp Analysis', 'Dr. Omar Farooq', '18 Dec 2025', 'Trichoscopy + density mapping', 'Completed', kSuccess),
    _TxRecord('Initial Consultation', 'Dr. Bilal Khan', '1 Dec 2025', 'Diagnosis & treatment planning', 'Completed', kSuccess),
  ];

  @override
  Widget build(BuildContext context) {
    final p = HaTheme.of(context);
    return Scaffold(
      backgroundColor: p.bg,
      appBar: const KAppBar(title: 'Treatment History'),
      body: Column(children: [
        // Summary cards
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Row(children: [
            Expanded(child: _SumCard(Icons.medical_services_outlined, '6', 'Procedures', kGold, p)),
            const SizedBox(width: 12),
            Expanded(child: _SumCard(Icons.calendar_today_outlined, '7 months', 'Journey', kInfo, p)),
            const SizedBox(width: 12),
            Expanded(child: _SumCard(Icons.check_circle_outline, '100%', 'Success', kSuccess, p)),
          ]),
        ),
        const SizedBox(height: 20),
        Container(height: 1, color: p.border),

        // Timeline
        Expanded(child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          itemCount: _records.length,
          itemBuilder: (_, i) => _TimelineItem(record: _records[i], isLast: i == _records.length - 1, p: p),
        )),
      ]),
    );
  }
}

class _TxRecord {
  final String title, doctor, date, notes, status;
  final Color statusColor;
  const _TxRecord(this.title, this.doctor, this.date, this.notes, this.status, this.statusColor);
}

class _SumCard extends StatelessWidget {
  final IconData icon;
  final String value, label;
  final Color color;
  final AppPalette p;
  const _SumCard(this.icon, this.value, this.label, this.color, this.p);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: color.withValues(alpha: 0.2)),
    ),
    child: Column(children: [
      Icon(icon, color: color, size: 20),
      const SizedBox(height: 6),
      Text(value, style: p.body(15, color: color, weight: FontWeight.w700)),
      Text(label, style: p.body(10, color: p.textMuted)),
    ]),
  );
}

class _TimelineItem extends StatelessWidget {
  final _TxRecord record;
  final bool isLast;
  final AppPalette p;
  const _TimelineItem({super.key, required this.record, required this.isLast, required this.p});

  @override
  Widget build(BuildContext context) => IntrinsicHeight(
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Timeline line
      Column(children: [
        Container(width: 12, height: 12, margin: const EdgeInsets.only(top: 4), decoration: const BoxDecoration(color: kGold, shape: BoxShape.circle)),
        if (!isLast) Expanded(child: Container(width: 2, color: p.border, margin: const EdgeInsets.symmetric(vertical: 4))),
      ]),
      const SizedBox(width: 16),
      // Card
      Expanded(child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: p.border),
          boxShadow: [if (!p.isDark) BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(record.title, style: p.body(14, weight: FontWeight.w700))),
            StatusBadge(label: record.status, color: record.statusColor),
          ]),
          const SizedBox(height: 8),
          Text(record.date, style: p.body(12, color: kGold, weight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(record.doctor, style: p.body(12, color: p.textMuted)),
          const SizedBox(height: 6),
          Container(height: 1, color: p.border),
          const SizedBox(height: 8),
          Row(children: [
            Icon(Icons.notes_outlined, size: 14, color: p.textMuted), const SizedBox(width: 6),
            Expanded(child: Text(record.notes, style: p.body(12, color: p.textMuted))),
          ]),
        ]),
      )),
    ]),
  );
}
