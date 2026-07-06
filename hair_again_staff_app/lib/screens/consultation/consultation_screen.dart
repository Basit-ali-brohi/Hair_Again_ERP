import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../core/staff_data.dart';

class ConsultationScreen extends StatefulWidget {
  final String? appointmentId;
  const ConsultationScreen({super.key, this.appointmentId});
  @override
  State<ConsultationScreen> createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends State<ConsultationScreen> {
  StaffAppointment? _appt;
  final _chiefCtrl     = TextEditingController();
  final _historyCtrl   = TextEditingController();
  final _notesCtrl     = TextEditingController();
  final _planCtrl      = TextEditingController();

  String? _hairLoss = 'Norwood III';
  String? _scalpType = 'Normal';
  final _selectedFindings = <String>{};
  bool _saved = false;

  static const _hairLossStages  = ['Norwood I','Norwood II','Norwood III','Norwood IV','Norwood V','Norwood VI','Norwood VII'];
  static const _scalpTypes      = ['Normal','Oily','Dry','Combination','Sensitive'];
  static const _clinicalFindings = ['Male Pattern Baldness','Alopecia Areata','Telogen Effluvium','Trichotillomania','Scalp Psoriasis','Seborrheic Dermatitis','Androgenic Alopecia'];

  @override
  void initState() {
    super.initState();
    if (widget.appointmentId != null) {
      try {
        _appt = staffData.allAppointments.firstWhere((a) => a.id == widget.appointmentId);
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _chiefCtrl.dispose(); _historyCtrl.dispose();
    _notesCtrl.dispose(); _planCtrl.dispose();
    super.dispose();
  }

  void _save() {
    setState(() => _saved = true);
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) context.pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = HaTheme.of(context);
    return Scaffold(
      backgroundColor: p.bg,
      appBar: StaffAppBar(title: 'Consultation Form'),
      body: _saved
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(width: 80, height: 80, decoration: BoxDecoration(gradient: kGoldGradient, shape: BoxShape.circle),
                child: const Icon(Icons.check_rounded, color: Colors.black87, size: 40)),
              const SizedBox(height: 20),
              Text('Consultation Saved!', style: p.display(22)),
              const SizedBox(height: 8),
              Text('Record saved to patient profile.', style: p.body(14, color: p.textMuted)),
            ]))
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                // Patient info banner
                if (_appt != null)
                  InfoBanner(
                    text: 'Patient: ${_appt!.patientName}  •  ${_appt!.service}  •  ${_appt!.timeStr}',
                    color: kGold, icon: Icons.person_rounded,
                  ),
                const SizedBox(height: 24),

                // Chief complaint
                _SectionLabel('Chief Complaint', p),
                const SizedBox(height: 8),
                TextField(controller: _chiefCtrl, style: p.body(14), maxLines: 2,
                  decoration: InputDecoration(hintText: 'Describe the patient\'s main concern...', hintStyle: p.body(14, color: p.textMuted))),
                const SizedBox(height: 20),

                // Hair loss stage
                _SectionLabel('Hair Loss Stage', p),
                const SizedBox(height: 10),
                Wrap(spacing: 8, runSpacing: 8, children: _hairLossStages.map((s) {
                  final sel = s == _hairLoss;
                  return GestureDetector(
                    onTap: () => setState(() => _hairLoss = s),
                    child: AnimatedContainer(duration: const Duration(milliseconds: 160),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: sel ? kGold.withValues(alpha: 0.15) : p.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: sel ? kGold : p.border, width: sel ? 1.5 : 1),
                      ),
                      child: Text(s, style: p.body(12, color: sel ? kGold : p.textMuted, weight: sel ? FontWeight.w700 : FontWeight.w400)),
                    ),
                  );
                }).toList()),
                const SizedBox(height: 20),

                // Scalp type
                _SectionLabel('Scalp Type', p),
                const SizedBox(height: 10),
                Wrap(spacing: 8, runSpacing: 8, children: _scalpTypes.map((s) {
                  final sel = s == _scalpType;
                  return GestureDetector(
                    onTap: () => setState(() => _scalpType = s),
                    child: AnimatedContainer(duration: const Duration(milliseconds: 160),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: sel ? kInfo.withValues(alpha: 0.12) : p.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: sel ? kInfo : p.border),
                      ),
                      child: Text(s, style: p.body(12, color: sel ? kInfo : p.textMuted, weight: sel ? FontWeight.w700 : FontWeight.w400)),
                    ),
                  );
                }).toList()),
                const SizedBox(height: 20),

                // Clinical findings
                _SectionLabel('Clinical Findings', p),
                const SizedBox(height: 10),
                ...(_clinicalFindings.map((f) {
                  final sel = _selectedFindings.contains(f);
                  return GestureDetector(
                    onTap: () => setState(() => sel ? _selectedFindings.remove(f) : _selectedFindings.add(f)),
                    child: AnimatedContainer(duration: const Duration(milliseconds: 160),
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: sel ? kDanger.withValues(alpha: 0.06) : p.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: sel ? kDanger.withValues(alpha: 0.35) : p.border),
                      ),
                      child: Row(children: [
                        Icon(sel ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                            size: 20, color: sel ? kDanger : p.textMuted),
                        const SizedBox(width: 12),
                        Text(f, style: p.body(13, color: sel ? kDanger : p.text, weight: sel ? FontWeight.w600 : FontWeight.w400)),
                      ]),
                    ),
                  );
                })),
                const SizedBox(height: 20),

                // Medical history
                _SectionLabel('Medical History', p),
                const SizedBox(height: 8),
                TextField(controller: _historyCtrl, style: p.body(14), maxLines: 3,
                  decoration: InputDecoration(hintText: 'Previous treatments, medications, allergies...', hintStyle: p.body(14, color: p.textMuted))),
                const SizedBox(height: 20),

                // Doctor notes
                _SectionLabel('Doctor\'s Notes', p),
                const SizedBox(height: 8),
                TextField(controller: _notesCtrl, style: p.body(14), maxLines: 4,
                  decoration: InputDecoration(hintText: 'Clinical observations and examination findings...', hintStyle: p.body(14, color: p.textMuted))),
                const SizedBox(height: 20),

                // Treatment plan
                _SectionLabel('Recommended Treatment Plan', p),
                const SizedBox(height: 8),
                TextField(controller: _planCtrl, style: p.body(14), maxLines: 3,
                  decoration: InputDecoration(hintText: 'Proposed treatment, sessions required, estimated cost...', hintStyle: p.body(14, color: p.textMuted))),
                const SizedBox(height: 32),

                GoldButton(label: 'SAVE CONSULTATION', icon: Icons.save_rounded, onTap: _save),
              ]),
            ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  final AppPalette p;
  const _SectionLabel(this.text, this.p);
  @override
  Widget build(BuildContext context) => Row(children: [
    Container(width: 3, height: 16, decoration: BoxDecoration(gradient: kGoldGradient, borderRadius: BorderRadius.circular(2))),
    const SizedBox(width: 8),
    Text(text, style: p.body(14, weight: FontWeight.w700)),
  ]);
}
