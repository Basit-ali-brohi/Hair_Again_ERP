import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../core/staff_data.dart';

class PatientsScreen extends StatefulWidget {
  const PatientsScreen({super.key});
  @override
  State<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> {
  final _search = TextEditingController();
  List<StaffPatient> _results = [];

  @override
  void initState() {
    super.initState();
    _results = staffData.patients;
    _search.addListener(() => setState(() => _results = staffData.searchPatients(_search.text)));
  }

  @override
  void dispose() { _search.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final p = HaTheme.of(context);
    return Scaffold(
      backgroundColor: p.bg,
      appBar: StaffAppBar(title: 'Patients'),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: SearchBar2(controller: _search, hint: 'Search by name or phone...'),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Row(children: [
            Text('${_results.length} patient${_results.length != 1 ? 's' : ''}', style: p.body(13, color: p.textMuted)),
          ]),
        ),
        Expanded(child: _results.isEmpty
          ? const EmptyState(icon: Icons.person_search_rounded, title: 'No patients found', subtitle: 'Try a different name or phone number')
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              itemCount: _results.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _PatientCard(patient: _results[i], p: p)
                  .animate().fadeIn(delay: (i * 40).ms, duration: 260.ms).slideX(begin: 0.04, end: 0),
            ),
        ),
      ]),
    );
  }
}

class _PatientCard extends StatelessWidget {
  final StaffPatient patient;
  final AppPalette p;
  const _PatientCard({required this.patient, required this.p});

  Color get _tierColor => switch (patient.membershipTier) {
    'Platinum' => const Color(0xFF8B5CF6),
    'Gold'     => kGold,
    'Silver'   => const Color(0xFF9CA3AF),
    _          => kInfo,
  };

  @override
  Widget build(BuildContext context) => PressableCard(
    onTap: () => context.push('/patient-detail', extra: patient),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: p.surface, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: p.border),
        boxShadow: [if (!p.isDark) BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Row(children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: kGold.withValues(alpha: 0.12),
          child: Text(patient.initials, style: p.body(14, color: kGold, weight: FontWeight.w800)),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(patient.name, style: p.body(15, weight: FontWeight.w700)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(color: _tierColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
              child: Text(patient.membershipTier, style: TextStyle(fontSize: 10, color: _tierColor, fontWeight: FontWeight.w700)),
            ),
          ]),
          const SizedBox(height: 4),
          Text(patient.phone, style: p.body(12, color: p.textMuted)),
          const SizedBox(height: 3),
          Row(children: [
            Icon(Icons.medical_information_outlined, size: 12, color: p.textMuted), const SizedBox(width: 3),
            Flexible(child: Text(patient.conditions.join(', '), style: p.body(11, color: p.textMuted), overflow: TextOverflow.ellipsis)),
          ]),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('${patient.visitCount} visits', style: p.body(12, color: kGold, weight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(patient.lastVisit, style: p.body(11, color: p.textMuted)),
          const SizedBox(height: 4),
          Icon(Icons.chevron_right_rounded, color: p.textMuted, size: 18),
        ]),
      ]),
    ),
  );
}
