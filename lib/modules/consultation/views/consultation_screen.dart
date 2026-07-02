import 'package:flutter/material.dart';

import '../../../core/core.dart';
import '../models/consultation_models.dart';
import '../../staff/models/staff.dart';

class ConsultationScreen extends StatefulWidget {
  const ConsultationScreen({super.key});
  @override
  State<ConsultationScreen> createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends State<ConsultationScreen> {
  String _q = '';
  String? _doctorFilter;
  ConsultationRecord? _detail;

  List<String> get _doctors => appState.consultationRecords.map((r) => r.doctorName).toSet().toList()..sort();

  List<ConsultationRecord> get _filtered {
    var list = appState.consultationRecords;
    if (_q.isNotEmpty) {
      final q = _q.toLowerCase();
      list = list.where((r) => r.patientName.toLowerCase().contains(q) || r.doctorName.toLowerCase().contains(q) || r.patientPhone.contains(q)).toList();
    }
    if (_doctorFilter != null) list = list.where((r) => r.doctorName == _doctorFilter).toList();
    return list;
  }

  void _showConsultationForm({ConsultationRecord? existing}) {
    final editing = existing != null;
    final p = appState.palette;
    final nameCtrl = TextEditingController(text: existing?.patientName ?? '');
    final phoneCtrl = TextEditingController(text: existing?.patientPhone ?? '');
    final ageCtrl = TextEditingController(text: existing?.patientAge?.toString() ?? '');
    var gender = existing?.patientGender ?? 'Male';
    var norwoodScale = existing?.hairAnalysis?.norwoodScale ?? 3;
    var texture = existing?.hairAnalysis?.texture ?? HairTexture.medium;
    var hairType = existing?.hairAnalysis?.type ?? HairType.straight;
    var density = existing?.hairAnalysis?.density ?? 3;
    var miniaturation = existing?.hairAnalysis?.miniaturation ?? MiniaturationLevel.moderate;
    var scalp = existing?.scalpAnalysis?.condition ?? ScalpCondition.healthy;
    var hasFamilyHistory = existing?.hairAnalysis?.hasFamilyHistory ?? false;
    String? doctorId = existing != null
        ? appState.staff.where((s) => s.name == existing.doctorName).firstOrNull?.id ?? appState.staff.where((s) => s.role == StaffRole.doctor).firstOrNull?.id
        : appState.staff.where((s) => s.role == StaffRole.doctor).firstOrNull?.id;
    final notesCtrl = TextEditingController(text: existing?.doctorNotes ?? '');
    final recs = <TreatmentRecommendationItem>[...?existing?.recommendations];

    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, ss) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 800, padding: const EdgeInsets.all(0),
        decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: p.border)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Left nav
          Container(
            width: 200, padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: const BorderRadius.horizontal(left: Radius.circular(15))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(editing ? 'EDIT CONSULTATION' : 'NEW CONSULTATION', style: p.display(18, spacing: 0.8)),
              const SizedBox(height: 20),
              ...[('Patient Info', Icons.person_outline), ('Hair Analysis', Icons.search_outlined), ('Treatment Plan', Icons.medical_services_outlined), ('Doctor Notes', Icons.note_outlined)].map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(children: [Icon(e.$2, size: 16, color: p.gold), const SizedBox(width: 10), Text(e.$1, style: p.body(13, weight: FontWeight.w600, color: p.text))]),
              )),
              const Spacer(),
              GoldButton(label: editing ? 'Save Changes' : 'Save', onTap: () {
                if (!editing && nameCtrl.text.isEmpty) return;
                final hairAnalysis = HairAnalysis(
                  norwoodScale: norwoodScale,
                  texture: texture, type: hairType,
                  density: density, miniaturation: miniaturation,
                  hasFamilyHistory: hasFamilyHistory,
                );
                final scalpAnalysis = ScalpAnalysis(condition: scalp, scaliness: 2, sebumLevel: 3);
                if (editing) {
                  existing!.doctorName = appState.staff.where((s) => s.id == doctorId).firstOrNull?.name ?? existing.doctorName;
                  existing.hairAnalysis = hairAnalysis;
                  existing.scalpAnalysis = scalpAnalysis;
                  existing.recommendations.clear();
                  existing.recommendations.addAll(recs);
                  existing.doctorNotes = notesCtrl.text.isEmpty ? null : notesCtrl.text;
                  appState.updateConsultation(existing);
                } else {
                  final rec = ConsultationRecord(
                    id: appState.createConsultationId(),
                    patientId: 'PT-WALK-IN',
                    patientName: nameCtrl.text.trim(),
                    patientPhone: phoneCtrl.text.trim(),
                    patientGender: gender,
                    patientAge: int.tryParse(ageCtrl.text),
                    doctorName: appState.staff.where((s) => s.id == doctorId).firstOrNull?.name ?? 'Dr. Rehman',
                    consultationDate: DateTime.now(),
                    hairAnalysis: hairAnalysis,
                    scalpAnalysis: scalpAnalysis,
                    recommendations: recs,
                    doctorNotes: notesCtrl.text.isEmpty ? null : notesCtrl.text,
                  );
                  appState.addConsultation(rec);
                }
                Navigator.pop(ctx);
                setState(() {});
              }),
              const SizedBox(height: 8),
              GhostButton(label: 'Cancel', onTap: () => Navigator.pop(ctx)),
            ]),
          ),
          // Right form
          Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(28), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _SectionTitle('PATIENT INFORMATION', p),
            Row(children: [
              Expanded(child: FormField2(label: 'Full Name *', controller: nameCtrl, hint: 'e.g. Waqas Ahmed')),
              const SizedBox(width: 16),
              Expanded(child: FormField2(label: 'Phone *', controller: phoneCtrl, hint: '+92 3XX XXXXXXX', keyboard: TextInputType.phone)),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: FormField2(label: 'Age', controller: ageCtrl, hint: 'e.g. 34', keyboard: TextInputType.number)),
              const SizedBox(width: 16),
              Expanded(child: Dropdown2<String>(label: 'Gender', value: gender, items: ['Male','Female'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(), onChanged: (v) => ss(() => gender = v ?? gender))),
              const SizedBox(width: 16),
              Expanded(child: Dropdown2<String?>(label: 'Consulting Doctor', value: doctorId, items: [const DropdownMenuItem<String?>(value: null, child: Text('— Select —')), ...appState.staff.where((s) => s.role == StaffRole.doctor).map((s) => DropdownMenuItem<String?>(value: s.id, child: Text(s.name)))], onChanged: (v) => ss(() => doctorId = v))),
            ]),
            const SizedBox(height: 24),

            _SectionTitle('HAIR ANALYSIS', p),
            Text('Norwood Scale (Male Pattern Baldness)', style: p.body(12, color: p.textMuted, weight: FontWeight.w600)),
            const SizedBox(height: 10),
            Row(children: List.generate(7, (i) {
              final val = i + 1;
              final sel = norwoodScale == val;
              return Expanded(child: GestureDetector(
                onTap: () => ss(() => norwoodScale = val),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 140),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(color: sel ? p.gold.withValues(alpha: 0.15) : p.surfaceAlt, borderRadius: BorderRadius.circular(8), border: Border.all(color: sel ? p.gold : p.border, width: sel ? 2 : 1)),
                  child: Column(children: [
                    Text(roman(val), style: p.body(13, color: sel ? p.gold : p.textMuted, weight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(norwoodDesc(val).split(' ').first, style: p.body(9, color: sel ? p.gold : p.textMuted), textAlign: TextAlign.center),
                  ]),
                ),
              ));
            })),
            const SizedBox(height: 8),
            Text(norwoodDesc(norwoodScale), style: p.body(12, color: p.gold, weight: FontWeight.w500)),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: Dropdown2<HairTexture>(label: 'Hair Texture', value: texture, items: HairTexture.values.map((t) => DropdownMenuItem(value: t, child: Text(t.label))).toList(), onChanged: (v) => ss(() => texture = v ?? texture))),
              const SizedBox(width: 16),
              Expanded(child: Dropdown2<HairType>(label: 'Hair Type', value: hairType, items: HairType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.label))).toList(), onChanged: (v) => ss(() => hairType = v ?? hairType))),
              const SizedBox(width: 16),
              Expanded(child: Dropdown2<MiniaturationLevel>(label: 'Miniaturization', value: miniaturation, items: MiniaturationLevel.values.map((t) => DropdownMenuItem(value: t, child: Text(t.label))).toList(), onChanged: (v) => ss(() => miniaturation = v ?? miniaturation))),
            ]),
            const SizedBox(height: 16),
            Text('Hair Density (1=Very Thin, 5=Very Dense)', style: p.body(12, color: p.textMuted, weight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(children: List.generate(5, (i) {
              final val = i + 1;
              final sel = density == val;
              return Expanded(child: GestureDetector(
                onTap: () => ss(() => density = val),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 140),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(color: sel ? p.gold.withValues(alpha: 0.15) : p.surfaceAlt, borderRadius: BorderRadius.circular(8), border: Border.all(color: sel ? p.gold : p.border, width: sel ? 2 : 1)),
                  child: Center(child: Text('$val', style: p.body(14, color: sel ? p.gold : p.textMuted, weight: FontWeight.w700))),
                ),
              ));
            })),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: Dropdown2<ScalpCondition>(label: 'Scalp Condition', value: scalp, items: ScalpCondition.values.map((s) => DropdownMenuItem(value: s, child: Text(s.label))).toList(), onChanged: (v) => ss(() => scalp = v ?? scalp))),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Family History of Hair Loss', style: p.body(12, color: p.textMuted, weight: FontWeight.w600)),
                const SizedBox(height: 7),
                Row(children: [
                  Switch(value: hasFamilyHistory, onChanged: (v) => ss(() => hasFamilyHistory = v), activeColor: p.gold),
                  const SizedBox(width: 8),
                  Text(hasFamilyHistory ? 'Yes' : 'No', style: p.body(13, weight: FontWeight.w600, color: hasFamilyHistory ? p.gold : p.textMuted)),
                ]),
              ])),
            ]),
            const SizedBox(height: 24),

            _SectionTitle('TREATMENT RECOMMENDATIONS', p),
            ...recs.asMap().entries.map((entry) {
              final i = entry.key;
              final r = entry.value;
              return Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(children: [
                Container(width: 28, height: 28, alignment: Alignment.center, decoration: BoxDecoration(color: p.gold.withValues(alpha: 0.12), shape: BoxShape.circle), child: Text('${i + 1}', style: p.body(12, color: p.gold, weight: FontWeight.w700))),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(r.treatmentName, style: p.body(13.5, weight: FontWeight.w600)),
                  Text('${r.sessions} session(s) — ${money(r.estimatedCost)}', style: p.body(12, color: p.textMuted)),
                ])),
                IconButton(icon: Icon(Icons.remove_circle_outline, size: 18, color: p.danger), onPressed: () => ss(() => recs.removeAt(i)), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
              ]));
            }),
            TextButton.icon(
              icon: Icon(Icons.add, size: 18, color: p.gold),
              label: Text('Add Treatment', style: p.body(13, color: p.gold, weight: FontWeight.w600)),
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
              onPressed: () => _addTreatmentDialog(ctx, p, recs, () => ss(() {})),
            ),
            const SizedBox(height: 24),

            _SectionTitle('DOCTOR NOTES', p),
            FormField2(label: 'Clinical Notes & Recommendations', controller: notesCtrl, hint: 'Detailed clinical observations, advice, and follow-up instructions...', maxLines: 5),
          ]))),
        ]),
      ),
    )));
  }

  void _addTreatmentDialog(BuildContext ctx, AppPalette p, List<TreatmentRecommendationItem> recs, VoidCallback refresh) {
    final treatCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final costCtrl = TextEditingController();
    var priority = TreatmentPriority.recommended;
    var sessions = 1;
    showDialog(context: ctx, builder: (ctx2) => StatefulBuilder(builder: (ctx2, ss2) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 460, padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: p.border)),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('ADD TREATMENT', style: p.display(20, spacing: 1.0)),
          const SizedBox(height: 16),
          Dropdown2<String?>(label: 'Treatment', value: null, items: ['FUE Hair Transplant','DHI Technique','PRP Therapy','Mesotherapy','Scalp Micropigmentation','Laser Therapy','Hair Patch','Minoxidil Treatment','Finasteride Therapy','Growth Factor Treatment'].map((t) => DropdownMenuItem<String?>(value: t, child: Text(t))).toList(), onChanged: (v) { if (v != null) treatCtrl.text = v; }),
          const SizedBox(height: 16),
          FormField2(label: 'Treatment Name *', controller: treatCtrl, hint: 'Or type custom...'),
          const SizedBox(height: 12),
          FormField2(label: 'Description', controller: descCtrl, hint: 'Brief description of this treatment...'),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: FormField2(label: 'Estimated Cost (PKR)', controller: costCtrl, hint: 'e.g. 180000', keyboard: TextInputType.number)),
            const SizedBox(width: 16),
            Expanded(child: Dropdown2<TreatmentPriority>(label: 'Priority', value: priority, items: TreatmentPriority.values.map((pr) => DropdownMenuItem(value: pr, child: Text(pr.label))).toList(), onChanged: (v) => ss2(() => priority = v ?? priority))),
          ]),
          const SizedBox(height: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Sessions', style: p.body(12, color: p.textMuted, weight: FontWeight.w600)),
            const SizedBox(height: 7),
            Row(children: [
              QtyButton(Icons.remove, () => ss2(() => sessions = (sessions - 1).clamp(1, 50))),
              Expanded(child: Center(child: Text('$sessions', style: p.body(14, weight: FontWeight.w700)))),
              QtyButton(Icons.add, () => ss2(() => sessions++)),
            ]),
          ]),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            GhostButton(label: 'Cancel', onTap: () => Navigator.pop(ctx2)),
            const SizedBox(width: 12),
            GoldButton(label: 'Add', onTap: () {
              if (treatCtrl.text.isEmpty) return;
              recs.add(TreatmentRecommendationItem(
                treatmentName: treatCtrl.text,
                description: descCtrl.text.isEmpty ? treatCtrl.text : descCtrl.text,
                sessions: sessions, interval: 'Monthly',
                estimatedCost: double.tryParse(costCtrl.text) ?? 0,
                priority: priority,
              ));
              Navigator.pop(ctx2); refresh();
            }),
          ]),
        ]),
      ),
    )));
  }

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final list = _filtered;
    return ScreenScaffold(
      title: 'CONSULTATION MANAGEMENT',
      subtitle: 'Hair analysis, Norwood scale, treatment recommendations & doctor notes',
      actions: [GoldButton(label: 'New Consultation', icon: Icons.add, onTap: () => _showConsultationForm())],
      child: Row(children: [
        SizedBox(width: _detail == null ? 640 : 460, child: Column(children: [
          FilterBar(
            searchHint: 'Search patient name, phone, doctor…',
            onSearch: (v) => setState(() => _q = v),
            filters: [
              FilterDropdown<String?>(
                value: _doctorFilter, icon: Icons.person_outline,
                items: [const DropdownMenuItem(value: null, child: Text('All Doctors')), ..._doctors.map((d) => DropdownMenuItem(value: d, child: Text(d)))],
                onChanged: (v) => setState(() => _doctorFilter = v),
              ),
            ],
            countText: '${list.length} consultations',
            onClear: () => setState(() { _q = ''; _doctorFilter = null; }),
          ),
          const SizedBox(height: 12),
          Expanded(child: ScrollArea(builder: (sc) => ListView.builder(controller: sc, itemCount: list.length, itemBuilder: (_, i) {
            final r = list[i];
            final sel = _detail == r;
            return GestureDetector(
              onTap: () => setState(() => _detail = sel ? null : r),
              child: Panel(padding: const EdgeInsets.all(16), child: AnimatedContainer(
                duration: const Duration(milliseconds: 140),
                decoration: BoxDecoration(border: Border(left: BorderSide(width: sel ? 3 : 0, color: p.gold))),
                padding: EdgeInsets.only(left: sel ? 10 : 0),
                child: Row(children: [
                  CircleAvatar(radius: 22, backgroundColor: p.gold.withValues(alpha: 0.15), child: Text(r.patientName.substring(0, 1), style: p.body(14, color: p.gold, weight: FontWeight.w700))),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Text(r.patientName, style: p.body(14, weight: FontWeight.w700)),
                      const Spacer(),
                      Text(prettyShort(r.consultationDate), style: p.body(12, color: p.textMuted)),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () { setState(() => _detail = null); _showConsultationForm(existing: r); },
                        child: MouseRegion(cursor: SystemMouseCursors.click, child: Container(width: 28, height: 28, decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(7)), child: Icon(Icons.edit_outlined, size: 14, color: p.text))),
                      ),
                    ]),
                    const SizedBox(height: 5),
                    Row(children: [
                      _Tag(Icons.phone_outlined, r.patientPhone, p),
                      const SizedBox(width: 12),
                      _Tag(Icons.person_outline, r.doctorName, p),
                    ]),
                    const SizedBox(height: 5),
                    Row(children: [
                      if (r.hairAnalysis != null) StatusChip(label: 'Norwood ${roman(r.hairAnalysis!.norwoodScale)}', color: p.gold),
                      if (r.hairAnalysis != null) const SizedBox(width: 6),
                      if (r.recommendations.isNotEmpty) StatusChip(label: '${r.recommendations.length} treatments', color: p.info),
                      const SizedBox(width: 6),
                      if (r.totalEstimatedCost > 0) StatusChip(label: moneyShort(r.totalEstimatedCost), color: p.success),
                    ]),
                  ])),
                ]),
              )),
            );
          }))),
        ])),
        if (_detail != null) ...[
          const SizedBox(width: 18),
          Expanded(child: _ConsultationDetail(record: _detail!, onClose: () => setState(() => _detail = null))),
        ],
      ]),
    );
  }
}

class _ConsultationDetail extends StatelessWidget {
  final ConsultationRecord record;
  final VoidCallback onClose;
  const _ConsultationDetail({required this.record, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final r = record;
    final ha = r.hairAnalysis;
    final sa = r.scalpAnalysis;
    return ScrollArea(builder: (sc) => SingleChildScrollView(controller: sc, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Panel(child: Row(children: [
        CircleAvatar(radius: 28, backgroundColor: p.gold.withValues(alpha: 0.15), child: Text(r.patientName.substring(0, 1), style: p.body(18, color: p.gold, weight: FontWeight.w700))),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(r.patientName, style: p.display(26, spacing: 0.5)),
          Row(children: [
            if (r.patientAge != null) _Tag(Icons.cake_outlined, '${r.patientAge} yrs, ${r.patientGender}', p),
            if (r.patientAge != null) const SizedBox(width: 12),
            _Tag(Icons.phone_outlined, r.patientPhone, p),
          ]),
          const SizedBox(height: 6),
          _Tag(Icons.medical_services_outlined, r.doctorName, p),
        ])),
        IconButton(icon: Icon(Icons.close, color: p.textMuted), onPressed: onClose),
      ])),
      const SizedBox(height: 18),

      if (ha != null) Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('HAIR ANALYSIS', style: p.display(18, spacing: 0.5)),
        const SizedBox(height: 16),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _DetailRow('Norwood Scale', 'Stage ${roman(ha.norwoodScale)} — ${norwoodDesc(ha.norwoodScale)}', p, highlight: true),
            if (ha.ludwigScale != null) _DetailRow('Ludwig Scale', 'Stage ${ha.ludwigScale}', p),
            _DetailRow('Hair Texture', ha.texture.label, p),
            _DetailRow('Hair Type', ha.type.label, p),
          ])),
          const SizedBox(width: 24),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _DetailRow('Density', '${'●' * ha.density}${'○' * (5 - ha.density)} (${ha.density}/5)', p),
            _DetailRow('Miniaturization', ha.miniaturation.label, p),
            _DetailRow('Family History', ha.hasFamilyHistory ? 'Yes' : 'No', p, color: ha.hasFamilyHistory ? p.warning : p.success),
          ])),
        ]),
      ])),
      const SizedBox(height: 18),

      if (sa != null) Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('SCALP ANALYSIS', style: p.display(18, spacing: 0.5)),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: _DetailRow('Condition', sa.condition.label, p)),
          Expanded(child: _DetailRow('Scaliness', '${sa.scaliness}/5', p)),
          Expanded(child: _DetailRow('Sebum Level', '${sa.sebumLevel}/5', p)),
          Expanded(child: _DetailRow('Infection', sa.hasInfection ? 'Present' : 'None', p, color: sa.hasInfection ? p.warning : p.success)),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: _DetailRow('Scarring', sa.hasScarring ? 'Present' : 'None', p, color: sa.hasScarring ? p.danger : p.success)),
          Expanded(child: _DetailRow('Alopecia Areata', sa.hasAlopeciaAreata ? 'Present' : 'None', p, color: sa.hasAlopeciaAreata ? p.warning : p.success)),
        ]),
      ])),
      const SizedBox(height: 18),

      if (r.recommendations.isNotEmpty) Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Text('TREATMENT RECOMMENDATIONS', style: p.display(18, spacing: 0.5)), const Spacer(), Text('Total: ${money(r.totalEstimatedCost)}', style: p.body(14, color: p.gold, weight: FontWeight.w700))]),
        const SizedBox(height: 14),
        ...r.recommendations.asMap().entries.map((entry) {
          final i = entry.key;
          final rec = entry.value;
          final priColor = switch (rec.priority) { TreatmentPriority.essential => p.danger, TreatmentPriority.recommended => p.gold, TreatmentPriority.optional => p.info };
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(10), border: Border.all(color: priColor.withValues(alpha: 0.3))),
            child: Row(children: [
              Container(width: 28, height: 28, alignment: Alignment.center, decoration: BoxDecoration(color: priColor.withValues(alpha: 0.12), shape: BoxShape.circle), child: Text('${i + 1}', style: p.body(12, color: priColor, weight: FontWeight.w700))),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(rec.treatmentName, style: p.body(14, weight: FontWeight.w600)),
                Text('${rec.sessions} session(s) • ${rec.interval}', style: p.body(12, color: p.textMuted)),
              ])),
              StatusChip(label: rec.priority.label, color: priColor),
              const SizedBox(width: 12),
              Text(money(rec.estimatedCost), style: p.body(14, weight: FontWeight.w700, color: p.gold)),
            ]),
          );
        }),
      ])),
      const SizedBox(height: 18),

      if (r.doctorNotes != null && r.doctorNotes!.isNotEmpty) Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('DOCTOR NOTES', style: p.display(18, spacing: 0.5)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(10), border: Border.all(color: p.border)),
          child: Text(r.doctorNotes!, style: p.body(13.5, color: p.text).copyWith(height: 1.7)),
        ),
      ])),
    ])));
  }
}

Widget _SectionTitle(String label, AppPalette p) => Padding(
  padding: const EdgeInsets.only(bottom: 14),
  child: Row(children: [
    Container(width: 3, height: 18, decoration: BoxDecoration(color: p.gold, borderRadius: BorderRadius.circular(2))),
    const SizedBox(width: 10),
    Text(label, style: p.body(11.5, color: p.textMuted, weight: FontWeight.w700, spacing: 1.5)),
  ]),
);

Widget _Tag(IconData icon, String text, AppPalette p) => Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 13, color: p.textMuted), const SizedBox(width: 5), Text(text, style: p.body(12.5, color: p.textMuted))]);

Widget _DetailRow(String label, String value, AppPalette p, {bool highlight = false, Color? color}) => Padding(
  padding: const EdgeInsets.only(bottom: 10),
  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: p.body(11, color: p.textMuted, weight: FontWeight.w600, spacing: 0.5)),
    const SizedBox(height: 3),
    Text(value, style: p.body(13, color: color ?? (highlight ? p.gold : p.text), weight: highlight ? FontWeight.w700 : FontWeight.w500)),
  ]),
);
