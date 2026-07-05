// modules/crm/views — master-detail patient list + dossier, Norwood register
// overlay, and live add/filter/update/delete against the shared store.
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../core/core.dart';
import '../models/patient.dart';

class CrmScreen extends StatefulWidget {
  const CrmScreen({super.key});
  @override
  State<CrmScreen> createState() => CrmScreenState();
}

class CrmScreenState extends State<CrmScreen> {
  String _search = '';
  PatientStatus? _statusFilter;
  String? _genderFilter;
  String? _cityFilter;
  Patient? _selected;

  void openAddPatient() => _showForm();
  void selectPatient(Patient p) => setState(() => _selected = p);

  List<String> get _cities => ['All Cities', ...{for (final p in appState.patients) p.city}.toList()..sort()];

  List<Patient> get _filtered {
    final q = _search.toLowerCase();
    return appState.patients.where((p) {
      final mq = q.isEmpty || p.name.toLowerCase().contains(q) || p.phone.contains(q) || p.email.toLowerCase().contains(q) || p.city.toLowerCase().contains(q);
      final mf = _statusFilter == null || p.status == _statusFilter;
      final mg = _genderFilter == null || p.gender == _genderFilter;
      final mc = _cityFilter == null || p.city == _cityFilter;
      return mq && mf && mg && mc;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final list = _filtered;
    if (_selected != null && !appState.patients.contains(_selected)) _selected = null;
    _selected ??= list.isNotEmpty ? list.first : null;

    return ScreenScaffold(
      title: 'CRM & PATIENT CARE',
      subtitle: 'Manage leads, patients and their full transplant journey.',
      actions: [GoldButton(label: 'Add Patient', icon: Icons.person_add_alt_1, onTap: openAddPatient)],
      child: LayoutBuilder(builder: (ctx, c) {
        final panelH = c.maxHeight;
        return ScrollArea(builder: (sc) => SingleChildScrollView(
          controller: sc,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            MetricRow([
              MetricCard(title: 'New Leads', value: '${appState.activeLeads}', delta: '+5', icon: Icons.person_search_outlined),
              MetricCard(title: 'Scheduled Procedures', value: '${appState.scheduledProcedures}', delta: '+2', icon: Icons.event_outlined),
              MetricCard(title: 'Completed Sessions', value: '${appState.completedSessions}', delta: '+9', icon: Icons.task_alt_outlined),
              MetricCard(title: 'Follow-up Alerts', value: '${appState.followUpAlerts}', delta: '${appState.followUpAlerts} need action', deltaUp: false, icon: Icons.notifications_active_outlined),
            ]),
            const SizedBox(height: 18),
            FilterBar(
              searchHint: 'Search by name, phone, email or city…',
              onSearch: (v) => setState(() => _search = v),
              filters: [
                FilterDropdown<PatientStatus?>(
                  icon: Icons.flag_outlined,
                  value: _statusFilter,
                  items: const [
                    DropdownMenuItem<PatientStatus?>(value: null, child: Text('All Statuses')),
                    DropdownMenuItem<PatientStatus?>(value: PatientStatus.lead, child: Text('Lead')),
                    DropdownMenuItem<PatientStatus?>(value: PatientStatus.active, child: Text('Active Patient')),
                    DropdownMenuItem<PatientStatus?>(value: PatientStatus.completed, child: Text('Completed')),
                  ],
                  onChanged: (v) => setState(() => _statusFilter = v),
                ),
                FilterDropdown<String?>(
                  icon: Icons.wc_outlined,
                  value: _genderFilter,
                  items: const [
                    DropdownMenuItem<String?>(value: null, child: Text('All Genders')),
                    DropdownMenuItem<String?>(value: 'Male', child: Text('Male')),
                    DropdownMenuItem<String?>(value: 'Female', child: Text('Female')),
                  ],
                  onChanged: (v) => setState(() => _genderFilter = v),
                ),
                FilterDropdown<String?>(
                  icon: Icons.location_city_outlined,
                  value: _cityFilter,
                  items: [const DropdownMenuItem<String?>(value: null, child: Text('All Cities')), ..._cities.skip(1).map((c) => DropdownMenuItem<String?>(value: c, child: Text(c)))],
                  onChanged: (v) => setState(() => _cityFilter = v),
                ),
              ],
              countText: 'Showing ${list.length} of ${appState.patients.length}',
              onClear: () => setState(() { _search = ''; _statusFilter = null; _genderFilter = null; _cityFilter = null; }),
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: panelH,
              child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Expanded(flex: 4, child: Panel(padding: const EdgeInsets.all(8), child: list.isEmpty ? Center(child: Text('No patients match your search.', style: p.body(13, color: p.textMuted))) : ScrollArea(builder: (sc2) => ListView.separated(controller: sc2, padding: const EdgeInsets.fromLTRB(6, 6, 12, 6), itemCount: list.length, separatorBuilder: (_, _) => const SizedBox(height: 6), itemBuilder: (_, i) => _tile(p, list[i]))))),
                const SizedBox(width: 18),
                Expanded(flex: 6, child: _selected == null ? Panel(child: Center(child: Text('Select a patient to view dossier', style: p.body(13, color: p.textMuted)))) : _Dossier(patient: _selected!, onEdit: () => _showForm(existing: _selected), onDelete: () { appState.deletePatient(_selected!); setState(() => _selected = null); })),
              ]),
            ),
            const SizedBox(height: 24),
          ]),
        ));
      }),
    );
  }

  Widget _tile(AppPalette p, Patient pt) {
    final sel = pt == _selected;
    return GestureDetector(
      onTap: () => setState(() => _selected = pt),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: sel ? p.gold.withValues(alpha: 0.10) : Colors.transparent, borderRadius: BorderRadius.circular(8), border: Border.all(color: sel ? p.gold.withValues(alpha: 0.6) : p.border)),
          child: Row(children: [
            Container(width: 42, height: 42, alignment: Alignment.center, decoration: BoxDecoration(color: p.statusColor(pt.status).withValues(alpha: 0.16), borderRadius: BorderRadius.circular(8)), child: Text(pt.initials, style: p.body(14, color: p.statusColor(pt.status), weight: FontWeight.w700))),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(pt.name, style: p.body(14, weight: FontWeight.w600)), const SizedBox(height: 2), Text(pt.phone, style: p.body(12, color: p.textMuted))])),
            StatusChip(label: pt.status.label, color: p.statusColor(pt.status)),
          ]),
        ),
      ),
    );
  }

  void _showForm({Patient? existing}) {
    showDialog(context: context, barrierColor: Colors.black.withValues(alpha: 0.55), builder: (_) => PatientFormDialog(existing: existing)).then((res) { if (res is Patient) setState(() => _selected = res); });
  }
}

class _Dossier extends StatefulWidget {
  final Patient patient;
  final VoidCallback onEdit, onDelete;
  const _Dossier({required this.patient, required this.onEdit, required this.onDelete});
  @override
  State<_Dossier> createState() => _DossierState();
}

class _DossierState extends State<_Dossier> with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Patient get patient => widget.patient;

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    return Panel(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // ── Header row ──────────────────────────────────────────────────────
        Row(children: [
          Container(width: 64, height: 64, alignment: Alignment.center, decoration: BoxDecoration(gradient: p.goldGradient, borderRadius: BorderRadius.circular(8)), child: Text(patient.initials, style: p.display(28, color: Colors.black87))),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(patient.name, style: p.display(32)),
            const SizedBox(height: 4),
            Wrap(spacing: 8, runSpacing: 6, crossAxisAlignment: WrapCrossAlignment.center, children: [StatusChip(label: patient.status.label, color: p.statusColor(patient.status)), Text('${patient.gender} • ${patient.age} yrs • ${patient.city}', style: p.body(12.5, color: p.textMuted))]),
          ])),
          GhostButton(label: 'Export PDF', icon: Icons.picture_as_pdf_outlined, onTap: () => showPdfPreview(context, title: '${patient.name} — Dossier', build: () => buildPatientPdf(patient))),
          const SizedBox(width: 8),
          GhostButton(label: 'Edit', icon: Icons.edit_outlined, onTap: widget.onEdit),
          const SizedBox(width: 8),
          _DeleteButton(onTap: widget.onDelete),
        ]),
        const SizedBox(height: 14),
        // ── TabBar ──────────────────────────────────────────────────────────
        Container(
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: p.border))),
          child: TabBar(
            controller: _tab,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            dividerColor: Colors.transparent,
            indicatorColor: p.gold,
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: p.body(13, weight: FontWeight.w600),
            unselectedLabelStyle: p.body(13),
            labelColor: p.gold,
            unselectedLabelColor: p.textMuted,
            tabs: const [Tab(text: 'Overview'), Tab(text: 'Medical History'), Tab(text: 'Notes'), Tab(text: 'Documents')],
          ),
        ),
        const SizedBox(height: 12),
        // ── TabBarView ──────────────────────────────────────────────────────
        Expanded(child: EagerTabBarView(controller: _tab, children: [
          _OverviewTab(patient: patient),
          _MedicalHistoryTab(patient: patient),
          _NotesTab(patient: patient),
          _DocumentsTab(patient: patient),
        ])),
      ]),
    );
  }

}

// ── Overview Tab ──────────────────────────────────────────────────────────────
class _OverviewTab extends StatefulWidget {
  final Patient patient;
  const _OverviewTab({required this.patient});
  @override
  State<_OverviewTab> createState() => _OverviewTabState();
}

class _OverviewTabState extends State<_OverviewTab> {
  Patient get patient => widget.patient;

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    return ScrollArea(builder: (sc) => SingleChildScrollView(
      controller: sc,
      padding: const EdgeInsets.only(right: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        LayoutBuilder(builder: (context, c) {
          final contact = _info(p, 'CONTACT', [_row(p, Icons.phone_outlined, patient.phone), _row(p, Icons.email_outlined, patient.email), _row(p, Icons.location_on_outlined, patient.city)]);
          final norwood = _norwood(p);
          if (c.maxWidth > 560) return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: contact), const SizedBox(width: 16), Expanded(child: norwood)]);
          return Column(children: [contact, const SizedBox(height: 16), norwood]);
        }),
        const SizedBox(height: 22),
        const SectionTitle('TRANSPLANT JOURNEY', sub: 'Tap a milestone to toggle completion'),
        const SizedBox(height: 14),
        ...List.generate(patient.journey.length, (i) => _timeline(context, p, i)),
        const SizedBox(height: 8),
        GhostButton(label: 'Add Journey Milestone', icon: Icons.add, onTap: () => _addMilestone(context)),
        const SizedBox(height: 22),
        _beforeAfterGallery(context, p),
        const SizedBox(height: 22),
        _communicationLog(context, p),
      ]),
    ));
  }

  Widget _info(AppPalette p, String title, List<Widget> rows) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(8), border: Border.all(color: p.border)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: p.body(11, color: p.textMuted, weight: FontWeight.w700, spacing: 1.0)), const SizedBox(height: 12), ...rows]));

  Widget _row(AppPalette p, IconData ic, String t) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(children: [Icon(ic, size: 16, color: p.gold), const SizedBox(width: 10), Expanded(child: Text(t, style: p.body(13)))]));

  Widget _norwood(AppPalette p) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(8), border: Border.all(color: p.border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Expanded(child: Text('HAIR LOSS STAGE', style: p.body(11, color: p.textMuted, weight: FontWeight.w700, spacing: 1.0))), Text('Norwood ${roman(patient.norwood)}', style: p.body(12.5, color: p.gold, weight: FontWeight.w700))]),
          const SizedBox(height: 16),
          Row(children: List.generate(7, (i) => Expanded(child: Container(height: 8, margin: EdgeInsets.only(right: i < 6 ? 5 : 0), decoration: BoxDecoration(color: i < patient.norwood ? p.gold : p.border, borderRadius: BorderRadius.circular(8)))))),
          const SizedBox(height: 12),
          Text(norwoodDesc(patient.norwood), style: p.body(12.5, color: p.textMuted)),
        ]),
      );

  Widget _timeline(BuildContext context, AppPalette p, int i) {
    final step = patient.journey[i];
    final last = i == patient.journey.length - 1;
    return GestureDetector(
      onTap: () { step.done = !step.done; appState.touch(); },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Column(children: [
              AnimatedContainer(duration: const Duration(milliseconds: 200), width: 26, height: 26, decoration: BoxDecoration(color: step.done ? p.gold : p.surfaceAlt, borderRadius: BorderRadius.circular(8), border: Border.all(color: step.done ? p.gold : p.border, width: 1.5)), child: Icon(step.done ? Icons.check : Icons.circle_outlined, size: 15, color: step.done ? Colors.black87 : p.textMuted)),
              if (!last) Expanded(child: Container(width: 2, color: p.border, margin: const EdgeInsets.symmetric(vertical: 4))),
            ]),
            const SizedBox(width: 14),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: last ? 0 : 18),
                child: Container(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(color: step.done ? p.gold.withValues(alpha: 0.07) : p.surfaceAlt, borderRadius: BorderRadius.circular(8), border: Border.all(color: p.border)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Expanded(child: Text(step.title, style: p.body(13.5, weight: FontWeight.w700))), Text(step.date, style: p.body(11.5, color: p.textMuted))]), const SizedBox(height: 3), Text(step.detail, style: p.body(12.5, color: p.textMuted))]),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  void _addMilestone(BuildContext context) {
    final t = TextEditingController(), d = TextEditingController(), dt = TextEditingController(text: prettyShort(DateTime.now()));
    final p = pal(context);
    showDialog(context: context, builder: (_) => Dialog(
      backgroundColor: p.surface, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: p.border)),
      child: Container(
        width: 420, padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('ADD MILESTONE', style: p.display(26)),
          const SizedBox(height: 18),
          FormField2(label: 'Title', controller: t, hint: 'e.g. PRP — Session 2'),
          const SizedBox(height: 14),
          FormField2(label: 'Detail', controller: d, hint: 'Notes…'),
          const SizedBox(height: 14),
          FormField2(label: 'Date', controller: dt, hint: 'e.g. 27 Jun'),
          const SizedBox(height: 22),
          Row(children: [
            Expanded(child: GhostButton(label: 'Cancel', onTap: () => Navigator.pop(context))),
            const SizedBox(width: 12),
            Expanded(child: GoldButton(label: 'Add', onTap: () { if (t.text.trim().isEmpty) return; patient.journey.add(JourneyStep(title: t.text.trim(), detail: d.text.trim().isEmpty ? '—' : d.text.trim(), date: dt.text.trim())); appState.touch(); Navigator.pop(context); })),
          ]),
        ]),
      ),
    ));
  }

  Widget _beforeAfterGallery(BuildContext context, AppPalette p) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('BEFORE & AFTER GALLERY', style: p.body(11, color: p.textMuted, weight: FontWeight.w700, spacing: 1.0)),
          const SizedBox(height: 3),
          Text('Progress photo documentation', style: p.body(11.5, color: p.textMuted)),
        ])),
        GhostButton(label: 'Add Photo', icon: Icons.add_a_photo_outlined, onTap: () => _pickPhoto(context, p)),
      ]),
      const SizedBox(height: 14),
      if (patient.photos.isEmpty)
        GestureDetector(
          onTap: () => _pickPhoto(context, p),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Container(
              height: 110,
              decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(8), border: Border.all(color: p.border)),
              child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.add_photo_alternate_outlined, size: 32, color: p.textMuted.withValues(alpha: 0.5)),
                const SizedBox(height: 8),
                Text('No photos yet — click to add a before/after image', style: p.body(12, color: p.textMuted)),
              ])),
            ),
          ),
        )
      else
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: patient.photos.length + 1,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (_, i) {
              if (i == patient.photos.length) {
                return GestureDetector(
                  onTap: () => _pickPhoto(context, p),
                  child: MouseRegion(cursor: SystemMouseCursors.click, child: Container(
                    width: 110,
                    decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(8), border: Border.all(color: p.border)),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.add_a_photo_outlined, color: p.textMuted, size: 22),
                      const SizedBox(height: 8),
                      Text('Add Photo', style: p.body(11, color: p.textMuted)),
                    ]),
                  )),
                );
              }
              final photo = patient.photos[i];
              final file = File(photo.path);
              final exists = file.existsSync();
              return Container(
                width: 120,
                decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(8), border: Border.all(color: p.gold.withValues(alpha: 0.35))),
                child: Column(children: [
                  Expanded(child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                    child: exists
                      ? Image.file(file, fit: BoxFit.cover, width: 120)
                      : Center(child: Icon(Icons.broken_image_outlined, size: 28, color: p.textMuted.withValues(alpha: 0.5))),
                  )),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(photo.label, style: p.body(10.5, weight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text(photo.date, style: p.body(10, color: p.textMuted)),
                    ]),
                  ),
                ]),
              );
            },
          ),
        ),
    ]);
  }

  Future<void> _pickPhoto(BuildContext context, AppPalette p) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image, allowMultiple: false);
    if (result == null || result.files.isEmpty) return;
    final path = result.files.first.path;
    if (path == null) return;
    if (!context.mounted) return;

    final labelCtrl = TextEditingController();
    final dateCtrl = TextEditingController(text: prettyShort(DateTime.now()));

    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (_) => Dialog(
        backgroundColor: p.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: p.border)),
        child: Container(
          width: 380,
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(children: [
              Container(padding: const EdgeInsets.all(9), decoration: BoxDecoration(color: p.gold.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)), child: Icon(Icons.add_a_photo_outlined, color: p.gold, size: 18)),
              const SizedBox(width: 12),
              Text('LABEL PHOTO', style: p.display(24)),
            ]),
            const SizedBox(height: 18),
            FormField2(label: 'Label', controller: labelCtrl, hint: 'e.g. Before Surgery, Month-3 Follow-up'),
            const SizedBox(height: 14),
            FormField2(label: 'Date', controller: dateCtrl, hint: 'e.g. Jul 2026'),
            const SizedBox(height: 22),
            Row(children: [
              Expanded(child: GhostButton(label: 'Cancel', onTap: () => Navigator.pop(context, false))),
              const SizedBox(width: 12),
              Expanded(child: GoldButton(label: 'Add Photo', icon: Icons.check, onTap: () => Navigator.pop(context, true))),
            ]),
          ]),
        ),
      ),
    );

    if (confirmed != true) return;
    patient.photos.add(PatientPhoto(
      label: labelCtrl.text.trim().isEmpty ? 'Photo' : labelCtrl.text.trim(),
      date: dateCtrl.text.trim(),
      path: path,
    ));
    appState.touch();
  }

  Widget _communicationLog(BuildContext ctx, AppPalette p) {
    final logs = [
      (icon: Icons.phone_outlined, title: 'Follow-up call', subtitle: 'Discussed post-op care routine', date: 'Jun 28, 2026', type: 'call'),
      (icon: Icons.message_outlined, title: 'WhatsApp message', subtitle: 'Sent care instructions and appointment reminder', date: 'Jun 25, 2026', type: 'whatsapp'),
      (icon: Icons.email_outlined, title: 'Email sent', subtitle: 'Monthly newsletter and promotional offer', date: 'Jun 15, 2026', type: 'email'),
      (icon: Icons.calendar_today_outlined, title: 'Appointment confirmed', subtitle: 'Day-30 post-op review scheduled', date: 'Jun 10, 2026', type: 'appt'),
    ];
    final typeColors = {'call': Colors.blue, 'whatsapp': Colors.green, 'email': p.gold, 'appt': p.info};
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('COMMUNICATION HISTORY', style: p.body(11, color: p.textMuted, weight: FontWeight.w700, spacing: 1.0)),
          const SizedBox(height: 3),
          Text('Calls, messages and interactions', style: p.body(11.5, color: p.textMuted)),
        ])),
        GhostButton(label: 'Log Activity', icon: Icons.add, onTap: () => toast(ctx, 'Log an interaction with this patient')),
      ]),
      const SizedBox(height: 14),
      ...logs.map((log) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(children: [
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: (typeColors[log.type] ?? p.gold).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)), child: Icon(log.icon, size: 16, color: typeColors[log.type] ?? p.gold)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(log.title, style: p.body(13, weight: FontWeight.w600)),
          Text(log.subtitle, style: p.body(12, color: p.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
        ])),
        Text(log.date, style: p.body(11, color: p.textMuted)),
      ]))),
    ]);
  }
}

// ── Medical History Tab ───────────────────────────────────────────────────────
class _MedicalHistoryTab extends StatefulWidget {
  final Patient patient;
  const _MedicalHistoryTab({required this.patient});
  @override
  State<_MedicalHistoryTab> createState() => _MedicalHistoryTabState();
}

class _MedicalHistoryTabState extends State<_MedicalHistoryTab> {
  Patient get patient => widget.patient;

  void _showAddMedicalNote(BuildContext context) {
    final p = pal(context);
    final cond = TextEditingController();
    final dateCtrl = TextEditingController(text: prettyShort(DateTime.now()));
    final notesCtrl = TextEditingController();
    showDialog(context: context, builder: (_) => Dialog(
      backgroundColor: p.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: p.border)),
      child: Container(
        width: 480, padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('ADD MEDICAL NOTE', style: p.display(24)),
          const SizedBox(height: 18),
          FormField2(label: 'Condition / Treatment', controller: cond, hint: 'e.g. Alopecia Areata, Minoxidil 5%'),
          const SizedBox(height: 14),
          FormField2(label: 'Date', controller: dateCtrl, hint: 'e.g. Jul 2026'),
          const SizedBox(height: 14),
          FormField2(label: 'Notes', controller: notesCtrl, hint: 'Additional details…', maxLines: 3),
          const SizedBox(height: 22),
          Row(children: [
            Expanded(child: GhostButton(label: 'Cancel', onTap: () => Navigator.pop(context))),
            const SizedBox(width: 12),
            Expanded(child: GoldButton(label: 'Add', onTap: () {
              if (cond.text.trim().isEmpty) return;
              patient.medicalNotes.add(MedicalNote(id: 'MN-${patient.medicalNotes.length + 1}', condition: cond.text.trim(), date: dateCtrl.text.trim(), notes: notesCtrl.text.trim()));
              appState.touch();
              setState(() {});
              Navigator.pop(context);
            })),
          ]),
        ]),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    return ScrollArea(builder: (sc) => SingleChildScrollView(
      controller: sc,
      padding: const EdgeInsets.only(right: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Hair Loss History
        Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(8), border: Border.all(color: p.border)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('HAIR LOSS HISTORY', style: p.body(11, color: p.textMuted, weight: FontWeight.w700, spacing: 1.0)),
          const SizedBox(height: 14),
          Row(children: [
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(gradient: p.goldGradient, borderRadius: BorderRadius.circular(8)), child: Text('NW ${roman(patient.norwood)}', style: p.body(14, color: Colors.black87, weight: FontWeight.w800))),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Current Stage: Norwood ${roman(patient.norwood)}', style: p.body(14, weight: FontWeight.w700)),
              Text(norwoodDesc(patient.norwood), style: p.body(12.5, color: p.textMuted)),
              const SizedBox(height: 8),
              Row(children: List.generate(7, (i) => Expanded(child: Container(height: 8, margin: EdgeInsets.only(right: i < 6 ? 4 : 0), decoration: BoxDecoration(color: i < patient.norwood ? p.gold : p.border, borderRadius: BorderRadius.circular(4)))))),
            ])),
          ]),
        ])),
        const SizedBox(height: 18),
        Row(children: [
          Expanded(child: Text('MEDICAL CONDITIONS & PREVIOUS TREATMENTS', style: p.body(11, color: p.textMuted, weight: FontWeight.w700, spacing: 1.0))),
          GoldButton(label: 'Add Medical Note', icon: Icons.add, onTap: () => _showAddMedicalNote(context)),
        ]),
        const SizedBox(height: 12),
        if (patient.medicalNotes.isEmpty)
          Container(padding: const EdgeInsets.all(24), alignment: Alignment.center, decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(8), border: Border.all(color: p.border)), child: Text('No medical notes recorded yet.', style: p.body(13, color: p.textMuted)))
        else
          Panel(padding: EdgeInsets.zero, child: FullWidthDataTable(child: DataTable(
            headingRowColor: WidgetStateProperty.all(p.surfaceAlt),
            columnSpacing: 16, horizontalMargin: 20,
            columns: [
              DataColumn(label: Text('Condition / Treatment', style: p.body(12, weight: FontWeight.w700))),
              DataColumn(label: Text('Date', style: p.body(12, weight: FontWeight.w700))),
              DataColumn(label: Text('Notes', style: p.body(12, weight: FontWeight.w700))),
              DataColumn(label: Text('', style: p.body(12))),
            ],
            rows: patient.medicalNotes.map((m) => DataRow(cells: [
              DataCell(Text(m.condition, style: p.body(13, weight: FontWeight.w600))),
              DataCell(Text(m.date, style: p.body(12.5, color: p.textMuted))),
              DataCell(SizedBox(width: 200, child: Text(m.notes.isEmpty ? '—' : m.notes, style: p.body(12.5, color: p.textMuted), maxLines: 2, overflow: TextOverflow.ellipsis))),
              DataCell(GestureDetector(onTap: () { patient.medicalNotes.remove(m); appState.touch(); setState(() {}); }, child: MouseRegion(cursor: SystemMouseCursors.click, child: Icon(Icons.delete_outline, size: 15, color: p.textMuted)))),
            ])).toList(),
          ))),
        const SizedBox(height: 24),
      ]),
    ));
  }
}

// ── Notes Tab ─────────────────────────────────────────────────────────────────
class _NotesTab extends StatefulWidget {
  final Patient patient;
  const _NotesTab({required this.patient});
  @override
  State<_NotesTab> createState() => _NotesTabState();
}

class _NotesTabState extends State<_NotesTab> {
  Patient get patient => widget.patient;

  static const _categories = ['General', 'Follow-up', 'Complaint', 'Compliment'];

  Color _catColor(AppPalette p, String cat) => switch (cat) {
    'Follow-up' => p.info,
    'Complaint' => p.danger,
    'Compliment' => p.success,
    _ => p.textMuted,
  };

  void _showAddNote(BuildContext context) {
    final p = pal(context);
    final contentCtrl = TextEditingController();
    String category = 'General';
    showDialog(context: context, builder: (_) => StatefulBuilder(builder: (ctx, ss) => Dialog(
      backgroundColor: p.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: p.border)),
      child: Container(
        width: 480, padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('ADD NOTE', style: p.display(24)),
          const SizedBox(height: 18),
          FormField2(label: 'Note Content', controller: contentCtrl, hint: 'Write your note here…', maxLines: 5),
          const SizedBox(height: 14),
          Dropdown2<String>(label: 'Category', value: category, items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(), onChanged: (v) => ss(() => category = v ?? 'General')),
          const SizedBox(height: 22),
          Row(children: [
            Expanded(child: GhostButton(label: 'Cancel', onTap: () => Navigator.pop(context))),
            const SizedBox(width: 12),
            Expanded(child: GoldButton(label: 'Save Note', onTap: () {
              if (contentCtrl.text.trim().isEmpty) return;
              patient.notes.add(PatientNote(
                id: 'PN-${patient.notes.length + 1}',
                content: contentCtrl.text.trim(),
                date: prettyShort(DateTime.now()),
                author: appState.currentUser?.name ?? 'Staff',
                category: category,
              ));
              appState.touch();
              setState(() {});
              Navigator.pop(context);
            })),
          ]),
        ]),
      ),
    )));
  }

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    return ScrollArea(builder: (sc) => SingleChildScrollView(
      controller: sc,
      padding: const EdgeInsets.only(right: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text('PATIENT NOTES', style: p.body(11, color: p.textMuted, weight: FontWeight.w700, spacing: 1.0))),
          GoldButton(label: 'Add Note', icon: Icons.add, onTap: () => _showAddNote(context)),
        ]),
        const SizedBox(height: 14),
        if (patient.notes.isEmpty)
          Container(padding: const EdgeInsets.all(24), alignment: Alignment.center, decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(8), border: Border.all(color: p.border)), child: Text('No notes yet — tap Add Note to create one.', style: p.body(13, color: p.textMuted)))
        else
          ...patient.notes.reversed.map((note) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(8), border: Border.all(color: _catColor(p, note.category).withValues(alpha: 0.35))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  StatusChip(label: note.category, color: _catColor(p, note.category)),
                  const SizedBox(width: 8),
                  Expanded(child: Text('${note.author} • ${note.date}', style: p.body(11.5, color: p.textMuted))),
                  GestureDetector(onTap: () { patient.notes.remove(note); appState.touch(); setState(() {}); }, child: MouseRegion(cursor: SystemMouseCursors.click, child: Icon(Icons.delete_outline, size: 15, color: p.textMuted))),
                ]),
                const SizedBox(height: 10),
                Text(note.content, style: p.body(13.5)),
              ]),
            ),
          )),
        const SizedBox(height: 24),
      ]),
    ));
  }
}

// ── Documents Tab ─────────────────────────────────────────────────────────────
class _DocumentsTab extends StatefulWidget {
  final Patient patient;
  const _DocumentsTab({required this.patient});
  @override
  State<_DocumentsTab> createState() => _DocumentsTabState();
}

class _DocumentsTabState extends State<_DocumentsTab> {
  Patient get patient => widget.patient;

  static const _docTypes = ['CNIC', 'Consent Form', 'Medical Report', 'Insurance', 'Before-Photo', 'After-Photo', 'Other'];

  void _showAddDocument(BuildContext context) {
    final p = pal(context);
    final nameCtrl = TextEditingController();
    final dateCtrl = TextEditingController(text: prettyShort(DateTime.now()));
    final notesCtrl = TextEditingController();
    String docType = 'Other';
    showDialog(context: context, builder: (_) => StatefulBuilder(builder: (ctx, ss) => Dialog(
      backgroundColor: p.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: p.border)),
      child: Container(
        width: 480, padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('ADD DOCUMENT', style: p.display(24)),
          const SizedBox(height: 18),
          FormField2(label: 'Document Name', controller: nameCtrl, hint: 'e.g. Consent Form — FUE Transplant'),
          const SizedBox(height: 14),
          Dropdown2<String>(label: 'Document Type', value: docType, items: _docTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(), onChanged: (v) => ss(() => docType = v ?? 'Other')),
          const SizedBox(height: 14),
          FormField2(label: 'Date', controller: dateCtrl, hint: 'e.g. Jul 2026'),
          const SizedBox(height: 14),
          FormField2(label: 'Notes (optional)', controller: notesCtrl, hint: 'Additional details…', maxLines: 2),
          const SizedBox(height: 22),
          Row(children: [
            Expanded(child: GhostButton(label: 'Cancel', onTap: () => Navigator.pop(context))),
            const SizedBox(width: 12),
            Expanded(child: GoldButton(label: 'Add Document', onTap: () {
              if (nameCtrl.text.trim().isEmpty) return;
              patient.docsList.add(PatientDocument(
                id: 'PD-${patient.docsList.length + 1}',
                name: nameCtrl.text.trim(),
                docType: docType,
                date: dateCtrl.text.trim(),
                notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
              ));
              appState.touch();
              setState(() {});
              Navigator.pop(context);
            })),
          ]),
        ]),
      ),
    )));
  }

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    return ScrollArea(builder: (sc) => SingleChildScrollView(
      controller: sc,
      padding: const EdgeInsets.only(right: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text('DOCUMENTS', style: p.body(11, color: p.textMuted, weight: FontWeight.w700, spacing: 1.0))),
          GoldButton(label: 'Add Document', icon: Icons.add, onTap: () => _showAddDocument(context)),
        ]),
        const SizedBox(height: 12),
        if (patient.docsList.isEmpty)
          Container(padding: const EdgeInsets.all(24), alignment: Alignment.center, decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(8), border: Border.all(color: p.border)), child: Text('No documents uploaded yet.', style: p.body(13, color: p.textMuted)))
        else
          Panel(padding: EdgeInsets.zero, child: FullWidthDataTable(child: DataTable(
            headingRowColor: WidgetStateProperty.all(p.surfaceAlt),
            columnSpacing: 16, horizontalMargin: 20,
            columns: [
              DataColumn(label: Text('Document Name', style: p.body(12, weight: FontWeight.w700))),
              DataColumn(label: Text('Type', style: p.body(12, weight: FontWeight.w700))),
              DataColumn(label: Text('Date', style: p.body(12, weight: FontWeight.w700))),
              DataColumn(label: Text('Notes', style: p.body(12, weight: FontWeight.w700))),
              DataColumn(label: Text('', style: p.body(12))),
            ],
            rows: patient.docsList.map((d) => DataRow(cells: [
              DataCell(Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.insert_drive_file_outlined, size: 14, color: p.gold), const SizedBox(width: 8), Text(d.name, style: p.body(13, weight: FontWeight.w600))])),
              DataCell(StatusChip(label: d.docType, color: p.info)),
              DataCell(Text(d.date, style: p.body(12.5, color: p.textMuted))),
              DataCell(SizedBox(width: 160, child: Text(d.notes ?? '—', style: p.body(12.5, color: p.textMuted), maxLines: 2, overflow: TextOverflow.ellipsis))),
              DataCell(GestureDetector(onTap: () { patient.docsList.remove(d); appState.touch(); setState(() {}); }, child: MouseRegion(cursor: SystemMouseCursors.click, child: Icon(Icons.delete_outline, size: 15, color: p.textMuted)))),
            ])).toList(),
          ))),
        const SizedBox(height: 24),
      ]),
    ));
  }
}

class _DeleteButton extends StatefulWidget {
  final VoidCallback onTap;
  const _DeleteButton({required this.onTap});
  @override
  State<_DeleteButton> createState() => _DeleteButtonState();
}

class _DeleteButtonState extends State<_DeleteButton> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: () async { final ok = await confirm(context, 'Delete patient?', 'This permanently removes the dossier from the demo state.'); if (ok) widget.onTap(); },
        child: AnimatedContainer(duration: const Duration(milliseconds: 140), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: _hover ? p.danger.withValues(alpha: 0.14) : Colors.transparent, borderRadius: BorderRadius.circular(8), border: Border.all(color: _hover ? p.danger : p.border)), child: Icon(Icons.delete_outline, size: 18, color: _hover ? p.danger : p.textMuted)),
      ),
    );
  }
}

class PatientFormDialog extends StatefulWidget {
  final Patient? existing;
  const PatientFormDialog({super.key, this.existing});
  @override
  State<PatientFormDialog> createState() => _PatientFormDialogState();
}

class _PatientFormDialogState extends State<PatientFormDialog> {
  late final TextEditingController _name, _phone, _email, _city, _age;
  String _gender = 'Male';
  PatientStatus _status = PatientStatus.lead;
  double _norwood = 2;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name = TextEditingController(text: e?.name ?? '');
    _phone = TextEditingController(text: e?.phone ?? '+92 ');
    _email = TextEditingController(text: e?.email ?? '');
    _city = TextEditingController(text: e?.city ?? 'Karachi');
    _age = TextEditingController(text: e?.age.toString() ?? '');
    _gender = e?.gender ?? 'Male';
    _status = e?.status ?? PatientStatus.lead;
    _norwood = (e?.norwood ?? 2).toDouble();
  }

  @override
  void dispose() {
    for (final c in [_name, _phone, _email, _city, _age]) {
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
        width: 560, constraints: const BoxConstraints(maxHeight: 680), padding: const EdgeInsets.all(26),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: p.gold.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)), child: Icon(editing ? Icons.edit_outlined : Icons.person_add_alt_1, color: p.gold)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(editing ? 'EDIT PATIENT' : 'REGISTER PATIENT', style: p.display(28)), Text('Fill the dossier details below', style: p.body(12.5, color: p.textMuted))])),
            IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Icons.close, color: p.textMuted)),
          ]),
          const SizedBox(height: 18),
          Flexible(
            child: SingleChildScrollView(
              child: Column(children: [
                FormField2(label: 'Full Name', controller: _name, hint: 'Patient name'),
                const SizedBox(height: 14),
                Row(children: [Expanded(child: FormField2(label: 'Phone', controller: _phone, keyboard: TextInputType.phone)), const SizedBox(width: 14), Expanded(child: FormField2(label: 'Email', controller: _email, keyboard: TextInputType.emailAddress))]),
                const SizedBox(height: 14),
                Row(children: [
                  Expanded(child: FormField2(label: 'City', controller: _city)),
                  const SizedBox(width: 14),
                  SizedBox(width: 110, child: FormField2(label: 'Age', controller: _age, keyboard: TextInputType.number)),
                  const SizedBox(width: 14),
                  Expanded(child: Dropdown2<String>(label: 'Gender', value: _gender, items: const [DropdownMenuItem(value: 'Male', child: Text('Male')), DropdownMenuItem(value: 'Female', child: Text('Female'))], onChanged: (v) => setState(() => _gender = v ?? 'Male'))),
                ]),
                const SizedBox(height: 14),
                Dropdown2<PatientStatus>(label: 'Status', value: _status, items: PatientStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.label))).toList(), onChanged: (v) => setState(() => _status = v ?? PatientStatus.lead)),
                const SizedBox(height: 16),
                Align(alignment: Alignment.centerLeft, child: Text('NORWOOD SCALE — ${roman(_norwood.round())}', style: p.body(12, color: p.textMuted, weight: FontWeight.w600))),
                SliderTheme(data: SliderThemeData(activeTrackColor: p.gold, inactiveTrackColor: p.border, thumbColor: p.gold, overlayColor: p.gold.withValues(alpha: 0.15), trackHeight: 4), child: Slider(value: _norwood, min: 1, max: 7, divisions: 6, label: roman(_norwood.round()), onChanged: (v) => setState(() => _norwood = v))),
              ]),
            ),
          ),
          const SizedBox(height: 20),
          Row(children: [const Spacer(), GhostButton(label: 'Cancel', onTap: () => Navigator.pop(context)), const SizedBox(width: 12), GoldButton(label: editing ? 'Save Changes' : 'Register Patient', icon: Icons.check, onTap: _save)]),
        ]),
      ),
    );
  }

  void _save() {
    if (_name.text.trim().isEmpty) {
      toast(context, 'Please enter the patient name');
      return;
    }
    final age = int.tryParse(_age.text.trim()) ?? 30;
    if (widget.existing != null) {
      final e = widget.existing!;
      e..name = _name.text.trim()..phone = _phone.text.trim()..email = _email.text.trim()..city = _city.text.trim()..age = age..gender = _gender..status = _status..norwood = _norwood.round();
      appState.touch();
      Navigator.pop(context, e);
    } else {
      final p = Patient(
        id: appState.createPatientId(), name: _name.text.trim(), phone: _phone.text.trim(),
        email: _email.text.trim().isEmpty ? '—' : _email.text.trim(), city: _city.text.trim().isEmpty ? 'Karachi' : _city.text.trim(),
        age: age, gender: _gender, status: _status, norwood: _norwood.round(),
        journey: [JourneyStep(title: _status == PatientStatus.lead ? 'Lead Captured' : 'Consultation', detail: _status == PatientStatus.lead ? 'New enquiry registered' : 'Initial assessment', date: prettyShort(DateTime.now()), done: true)],
      );
      appState.addPatient(p);
      Navigator.pop(context, p);
    }
  }
}
