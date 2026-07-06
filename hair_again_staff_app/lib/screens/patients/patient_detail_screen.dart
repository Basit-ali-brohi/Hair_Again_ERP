import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../core/staff_data.dart';

class PatientDetailScreen extends StatelessWidget {
  final StaffPatient patient;
  const PatientDetailScreen({super.key, required this.patient});

  Color get _tierColor => switch (patient.membershipTier) {
    'Platinum' => const Color(0xFF8B5CF6),
    'Gold'     => kGold,
    'Silver'   => const Color(0xFF9CA3AF),
    _          => kInfo,
  };

  @override
  Widget build(BuildContext context) {
    final p = HaTheme.of(context);
    final appts = staffData.allAppointments.where((a) => a.patientName == patient.name).toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

    return Scaffold(
      backgroundColor: p.bg,
      body: CustomScrollView(
        slivers: [
          // Patient hero
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: p.surface,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: p.text),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(icon: const Icon(Icons.add_circle_outline_rounded, color: kGold),
                  onPressed: () => context.push('/book-appointment', extra: patient.name)),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: p.isDark
                        ? [const Color(0xFF0E0E12), const Color(0xFF1A1500)]
                        : [const Color(0xFFFBF9F5), const Color(0xFFF5EDD8)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 50, 24, 16),
                    child: Row(children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: kGold.withValues(alpha: 0.15),
                        child: Text(patient.initials, style: p.display(20, color: kGold)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(patient.name, style: p.display(22)),
                        const SizedBox(height: 4),
                        Text(patient.phone, style: p.body(13, color: p.textMuted)),
                        const SizedBox(height: 6),
                        Row(children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: _tierColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
                            child: Text(patient.membershipTier, style: TextStyle(fontSize: 11, color: _tierColor, fontWeight: FontWeight.w700)),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: kGold.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              const Icon(Icons.stars_rounded, size: 12, color: kGold),
                              const SizedBox(width: 3),
                              Text('${patient.loyaltyPoints} pts', style: p.body(11, color: kGold, weight: FontWeight.w600)),
                            ]),
                          ),
                        ]),
                      ])),
                    ]),
                  ),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            sliver: SliverList(delegate: SliverChildListDelegate([

              // Quick stats
              Row(children: [
                Expanded(child: _InfoChip(label: 'Age',      value: patient.age,         icon: Icons.cake_rounded,    p: p)),
                const SizedBox(width: 10),
                Expanded(child: _InfoChip(label: 'Blood',    value: patient.bloodGroup,  icon: Icons.bloodtype_rounded,p: p)),
                const SizedBox(width: 10),
                Expanded(child: _InfoChip(label: 'Visits',   value: '${patient.visitCount}', icon: Icons.history_rounded, p: p)),
              ]),
              const SizedBox(height: 20),

              // Medical conditions
              Text('Medical Conditions', style: p.body(15, weight: FontWeight.w700)),
              const SizedBox(height: 10),
              Wrap(spacing: 8, runSpacing: 8, children: patient.conditions.map((c) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: kDanger.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: kDanger.withValues(alpha: 0.2)),
                ),
                child: Text(c, style: p.body(12, color: kDanger, weight: FontWeight.w600)),
              )).toList()),
              const SizedBox(height: 24),

              // Contact info
              Text('Contact', style: p.body(15, weight: FontWeight.w700)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: p.border)),
                child: Column(children: [
                  _ContactRow(Icons.phone_rounded, 'Phone', patient.phone, p),
                  Divider(color: p.border, height: 20),
                  _ContactRow(Icons.email_outlined, 'Email', patient.email, p),
                ]),
              ),
              const SizedBox(height: 24),

              // Appointment history
              SectionHeader(title: 'Visit History', action: appts.isNotEmpty ? 'Book Again' : null, onAction: () => context.push('/book-appointment', extra: patient.name)),
              const SizedBox(height: 12),
              if (appts.isEmpty)
                const EmptyState(icon: Icons.history_rounded, title: 'No Visit History', subtitle: 'First appointment not yet scheduled.')
              else
                ...appts.map((a) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: p.border)),
                  child: Row(children: [
                    Container(width: 40, height: 40,
                      decoration: BoxDecoration(color: a.statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                      child: Icon(a.statusIcon, color: a.statusColor, size: 18)),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(a.service, style: p.body(13, weight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                      Text('${a.fullDate} • ${a.timeStr}', style: p.body(11, color: p.textMuted)),
                    ])),
                    StatusBadge(label: a.status, color: a.statusColor),
                  ]),
                )),
            ])),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final AppPalette p;
  const _InfoChip({required this.label, required this.value, required this.icon, required this.p});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
    decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: p.border)),
    child: Column(children: [
      Icon(icon, color: kGold, size: 20),
      const SizedBox(height: 6),
      Text(value, style: p.body(14, color: kGold, weight: FontWeight.w800)),
      const SizedBox(height: 2),
      Text(label, style: p.body(10, color: p.textMuted)),
    ]),
  );
}

class _ContactRow extends StatelessWidget {
  final IconData icon; final String label, value; final AppPalette p;
  const _ContactRow(this.icon, this.label, this.value, this.p);
  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, size: 16, color: kGold), const SizedBox(width: 10),
    Text(label, style: p.body(13, color: p.textMuted)), const Spacer(),
    Flexible(child: Text(value, style: p.body(13, weight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
  ]);
}
