import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../core/staff_data.dart';

class BookAppointmentScreen extends StatefulWidget {
  final String? prefillPatient;
  const BookAppointmentScreen({super.key, this.prefillPatient});
  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  int _step = 0;
  StaffPatient? _patient;
  String? _service, _doctor;
  DateTime? _date;
  String? _slot;
  bool _confirmed = false;

  static const _services = [
    ('Hair Transplant Consult', Icons.person_rounded,   'Rs 1,500'),
    ('PRP Therapy',             Icons.water_drop_rounded,'Rs 12,000'),
    ('Scalp Micropigmentation', Icons.brush_rounded,    'Rs 25,000'),
    ('LLLT Laser Therapy',      Icons.flash_on_rounded, 'Rs 6,000'),
    ('Scalp Deep Treatment',    Icons.spa_rounded,      'Rs 4,500'),
    ('Hair Analysis',           Icons.biotech_rounded,  'Rs 800'),
  ];
  static const _doctors = [
    ('Dr. Bilal Khan',  'Hair Transplant Specialist', '4.9 ★'),
    ('Dr. Sara Malik',  'Trichologist',               '4.8 ★'),
    ('Dr. Omar Farooq', 'Dermatologist',              '4.7 ★'),
  ];
  static const _slots = ['09:00 AM','10:00 AM','11:00 AM','01:00 PM','02:00 PM','03:00 PM','04:00 PM'];

  @override
  void initState() {
    super.initState();
    if (widget.prefillPatient != null) {
      _patient = staffData.patients.firstWhere((p) => p.name == widget.prefillPatient, orElse: () => staffData.patients.first);
    }
  }

  void _next() { if (_step < 4) setState(() => _step++); }
  void _back() {
    if (_step > 0) { setState(() => _step--); } else { context.pop(); }
  }

  void _confirm() {
    if (_patient == null || _service == null || _doctor == null || _date == null || _slot == null) return;
    HapticFeedback.heavyImpact();
    final parts = _slot!.replaceAll(' AM', '').replaceAll(' PM', '').split(':');
    var h = int.parse(parts[0]);
    final m = int.parse(parts[1]);
    if (_slot!.contains('PM') && h != 12) h += 12;
    if (_slot!.contains('AM') && h == 12) h = 0;
    final dt = DateTime(_date!.year, _date!.month, _date!.day, h, m);
    staffData.addAppointment(StaffAppointment(
      id: 'a_${DateTime.now().millisecondsSinceEpoch}',
      patientName: _patient!.name, service: _service!, doctor: _doctor!,
      dateTime: dt, slot: _slot!, status: 'Scheduled',
    ));
    setState(() => _confirmed = true);
    Future.delayed(const Duration(milliseconds: 2800), () {
      if (mounted) context.go('/appointments');
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = HaTheme.of(context);
    return Stack(children: [
      Scaffold(
        backgroundColor: p.bg,
        appBar: StaffAppBar(title: 'Book Appointment', onBack: _back),
        body: Column(children: [
          // Progress
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Row(children: List.generate(5, (i) {
              final done = i < _step; final active = i == _step;
              return Expanded(child: Row(children: [
                Container(width: 24, height: 24,
                  decoration: BoxDecoration(color: done || active ? kGold : p.surface, shape: BoxShape.circle, border: Border.all(color: done || active ? kGold : p.border)),
                  child: done ? const Icon(Icons.check, size: 12, color: Colors.black87) : Center(child: Text('${i+1}', style: p.body(10, color: active ? Colors.black87 : p.textMuted, weight: FontWeight.w700)))),
                if (i < 4) Expanded(child: Container(height: 2, color: done ? kGold : p.border)),
              ]));
            })),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 6, 24, 16),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: ['Patient','Service','Doctor','Date/Time','Confirm']
                  .map((s) => Text(s, style: p.body(9, color: p.textMuted))).toList()),
          ),
          Container(height: 1, color: p.border),
          Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: [
            _stepPatient(p), _stepService(p), _stepDoctor(p), _stepDateTime(p), _stepConfirm(p),
          ][_step])),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            child: Row(children: [
              if (_step > 0) ...[
                Expanded(child: OutlineBtn(label: 'Back', onTap: _back)),
                const SizedBox(width: 12),
              ],
              Expanded(flex: 2, child: GoldButton(
                label: _step == 4 ? 'Confirm' : 'Next',
                icon: _step == 4 ? Icons.check_rounded : Icons.arrow_forward_rounded,
                onTap: _step == 4 ? _confirm : _next,
              )),
            ]),
          ),
        ]),
      ),
      if (_confirmed) ...[
        Positioned.fill(child: Container(color: Colors.black.withValues(alpha: 0.7))),
        Center(child: _SuccessCard(p: p, onTap: () => context.go('/appointments'))),
      ],
    ]);
  }

  Widget _stepPatient(AppPalette p) {
    final patients = staffData.patients;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Select Patient', style: p.display(22)),
      const SizedBox(height: 6),
      Text('Choose the patient for this appointment', style: p.body(13, color: p.textMuted)),
      const SizedBox(height: 20),
      ...patients.map((pt) => GestureDetector(
        onTap: () => setState(() => _patient = pt),
        child: AnimatedContainer(duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _patient?.id == pt.id ? kGold.withValues(alpha: 0.1) : p.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _patient?.id == pt.id ? kGold : p.border, width: _patient?.id == pt.id ? 1.5 : 1),
          ),
          child: Row(children: [
            CircleAvatar(radius: 22, backgroundColor: kGold.withValues(alpha: 0.15), child: Text(pt.initials, style: p.body(13, color: kGold, weight: FontWeight.w700))),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(pt.name, style: p.body(14, weight: FontWeight.w700)),
              Text(pt.phone, style: p.body(12, color: p.textMuted)),
            ])),
            if (_patient?.id == pt.id) const Icon(Icons.check_circle_rounded, color: kGold, size: 20),
          ]),
        ),
      )),
    ]);
  }

  Widget _stepService(AppPalette p) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text('Select Service', style: p.display(22)),
    const SizedBox(height: 6),
    Text('What treatment today?', style: p.body(13, color: p.textMuted)),
    const SizedBox(height: 20),
    ..._services.map((s) => GestureDetector(
      onTap: () => setState(() => _service = s.$1),
      child: AnimatedContainer(duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _service == s.$1 ? kGold.withValues(alpha: 0.1) : p.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _service == s.$1 ? kGold : p.border, width: _service == s.$1 ? 1.5 : 1),
        ),
        child: Row(children: [
          Icon(s.$2, color: _service == s.$1 ? kGold : p.textMuted, size: 20),
          const SizedBox(width: 14),
          Expanded(child: Text(s.$1, style: p.body(14, weight: FontWeight.w600))),
          Text(s.$3, style: p.body(13, color: kGold)),
          if (_service == s.$1) ...[const SizedBox(width: 8), const Icon(Icons.check_circle_rounded, color: kGold, size: 18)],
        ]),
      ),
    )),
  ]);

  Widget _stepDoctor(AppPalette p) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text('Select Doctor', style: p.display(22)),
    const SizedBox(height: 20),
    ..._doctors.map((d) => GestureDetector(
      onTap: () => setState(() => _doctor = d.$1),
      child: AnimatedContainer(duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _doctor == d.$1 ? kGold.withValues(alpha: 0.1) : p.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _doctor == d.$1 ? kGold : p.border, width: _doctor == d.$1 ? 1.5 : 1),
        ),
        child: Row(children: [
          CircleAvatar(radius: 22, backgroundColor: kGold.withValues(alpha: 0.15), child: Text(d.$1.split(' ').last[0] + d.$1.split(' ')[1][0], style: p.body(13, color: kGold, weight: FontWeight.w700))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(d.$1, style: p.body(14, weight: FontWeight.w700)),
            Text(d.$2, style: p.body(12, color: p.textMuted)),
          ])),
          Text(d.$3, style: p.body(13, color: kGold, weight: FontWeight.w600)),
          if (_doctor == d.$1) ...[const SizedBox(width: 8), const Icon(Icons.check_circle_rounded, color: kGold, size: 18)],
        ]),
      ),
    )),
  ]);

  Widget _stepDateTime(AppPalette p) {
    final now = DateTime.now();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Date & Time', style: p.display(22)),
      const SizedBox(height: 20),
      SizedBox(height: 78, child: ListView.builder(
        scrollDirection: Axis.horizontal, itemCount: 14,
        itemBuilder: (_, i) {
          final day = now.add(Duration(days: i + 1));
          final sel = _date?.day == day.day && _date?.month == day.month;
          const names = ['', 'Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
          return GestureDetector(
            onTap: () => setState(() => _date = day),
            child: AnimatedContainer(duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(right: 10), width: 54,
              decoration: BoxDecoration(
                color: sel ? kGold : p.surface, borderRadius: BorderRadius.circular(14),
                border: Border.all(color: sel ? kGold : p.border),
              ),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(names[day.weekday], style: p.body(10, color: sel ? Colors.black54 : p.textMuted)),
                const SizedBox(height: 2),
                Text('${day.day}', style: p.body(18, color: sel ? Colors.black87 : p.text, weight: FontWeight.w700)),
              ]),
            ),
          );
        },
      )),
      const SizedBox(height: 24),
      Text('Available Slots', style: p.body(14, weight: FontWeight.w700)),
      const SizedBox(height: 12),
      Wrap(spacing: 10, runSpacing: 10, children: _slots.map((s) {
        final sel = _slot == s;
        return GestureDetector(
          onTap: () => setState(() => _slot = s),
          child: AnimatedContainer(duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: sel ? kGold : p.surface, borderRadius: BorderRadius.circular(10),
              border: Border.all(color: sel ? kGold : p.border),
            ),
            child: Text(s, style: p.body(13, color: sel ? Colors.black87 : p.text, weight: sel ? FontWeight.w600 : FontWeight.w400)),
          ),
        );
      }).toList()),
    ]);
  }

  Widget _stepConfirm(AppPalette p) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text('Confirm Booking', style: p.display(22)),
    const SizedBox(height: 20),
    Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: p.border)),
      child: Column(children: [
        _Row(Icons.person_rounded,           'Patient',  _patient?.name ?? '—', p),
        Divider(color: p.border, height: 20),
        _Row(Icons.spa_rounded,              'Service',  _service ?? '—', p),
        Divider(color: p.border, height: 20),
        _Row(Icons.medical_services_rounded, 'Doctor',   _doctor  ?? '—', p),
        Divider(color: p.border, height: 20),
        _Row(Icons.calendar_today_rounded,   'Date',     _date != null ? '${_date!.day}/${_date!.month}/${_date!.year}' : '—', p),
        Divider(color: p.border, height: 20),
        _Row(Icons.access_time_rounded,      'Time',     _slot    ?? '—', p),
      ]),
    ),
  ]);
}

class _Row extends StatelessWidget {
  final IconData icon; final String label, value; final AppPalette p;
  const _Row(this.icon, this.label, this.value, this.p);
  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, size: 16, color: kGold), const SizedBox(width: 10),
    Text(label, style: p.body(13, color: p.textMuted)),
    const Spacer(),
    Flexible(child: Text(value, style: p.body(13, weight: FontWeight.w600), overflow: TextOverflow.ellipsis, textAlign: TextAlign.right)),
  ]);
}

class _SuccessCard extends StatelessWidget {
  final AppPalette p; final VoidCallback onTap;
  const _SuccessCard({required this.p, required this.onTap});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 32),
    child: Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(24),
        border: Border.all(color: kGold.withValues(alpha: 0.3)),
        boxShadow: [BoxShadow(color: kGold.withValues(alpha: 0.2), blurRadius: 40, offset: const Offset(0, 12))]),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 72, height: 72,
          decoration: BoxDecoration(gradient: kGoldGradient, shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: kGold.withValues(alpha: 0.4), blurRadius: 20)]),
          child: const Icon(Icons.check_rounded, color: Colors.black87, size: 36)),
        const SizedBox(height: 20),
        Text('Appointment Booked!', style: p.display(22), textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text('Patient will receive an SMS confirmation shortly.', style: p.body(13, color: p.textMuted), textAlign: TextAlign.center),
        const SizedBox(height: 24),
        GoldButton(label: 'View Schedule', onTap: onTap),
      ]),
    ),
  );
}
