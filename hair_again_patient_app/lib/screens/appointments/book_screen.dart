import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../../../core/widgets.dart';

class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen({super.key});
  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  int _step = 0;
  String? _service;
  String? _doctor;
  DateTime? _date;
  String? _slot;

  static const _services = [
    ('Hair Transplant Consultation', Icons.person_outlined,  'Rs 1,500'),
    ('FUE Hair Transplant',          Icons.content_cut_outlined,'From Rs 80,000'),
    ('PRP Therapy',                  Icons.water_drop_outlined, 'From Rs 12,000'),
    ('Scalp Micropigmentation',      Icons.brush_outlined,      'From Rs 25,000'),
    ('LLLT Laser Therapy',           Icons.flash_on_outlined,   'From Rs 6,000'),
  ];

  static const _doctors = [
    ('Dr. Bilal Khan',  'Hair Transplant Specialist', '10+ yrs exp', '4.9'),
    ('Dr. Sara Malik',  'Trichologist',               '8 yrs exp',   '4.8'),
    ('Dr. Omar Farooq', 'Dermatologist',              '12 yrs exp',  '4.7'),
  ];

  static const _slots = ['09:00 AM','10:00 AM','11:00 AM','01:00 PM','02:00 PM','03:00 PM','04:00 PM'];

  void _next() { if (_step < 3) setState(() => _step++); }
  void _back() { if (_step > 0) setState(() => _step--); else Navigator.of(context).pop(); }

  void _confirm() {
    final p = HaTheme.of(context);
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: p.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.check_circle, color: kSuccess, size: 56),
        const SizedBox(height: 16),
        Text('Appointment Confirmed!', style: p.display(20), textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text('You\'ll receive a confirmation SMS & email shortly.', style: p.body(13, color: p.textMuted), textAlign: TextAlign.center),
        const SizedBox(height: 24),
        GoldButton(label: 'View Appointments', onTap: () { Navigator.pop(context); context.go('/appointments'); }),
      ]),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final p = HaTheme.of(context);
    return Scaffold(
      backgroundColor: p.bg,
      appBar: KAppBar(title: 'Book Appointment'),
      body: Column(children: [
        // Step indicator
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          child: Row(children: List.generate(4, (i) {
            final done = i < _step;
            final active = i == _step;
            return Expanded(child: Row(children: [
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  color: done || active ? kGold : p.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: done || active ? kGold : p.border),
                ),
                child: done
                    ? const Icon(Icons.check, size: 14, color: Colors.black87)
                    : Center(child: Text('${i+1}', style: p.body(12, color: active ? Colors.black87 : p.textMuted, weight: FontWeight.w700))),
              ),
              if (i < 3) Expanded(child: Container(height: 2, color: done ? kGold : p.border)),
            ]));
          })),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            for (final s in ['Service', 'Doctor', 'Date & Time', 'Confirm'])
              Text(s, style: p.body(10, color: p.textMuted)),
          ]),
        ),
        Container(height: 1, color: p.border),

        // Step content
        Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: [
          _step0(p), _step1(p), _step2(p), _step3(p),
        ][_step])),

        // Navigation buttons
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          child: Row(children: [
            if (_step > 0) ...[
              Expanded(child: OutlineBtn(label: 'Back', onTap: _back)),
              const SizedBox(width: 12),
            ],
            Expanded(flex: 2, child: GoldButton(
              label: _step == 3 ? 'Confirm Booking' : 'Next',
              icon: _step == 3 ? Icons.check : Icons.arrow_forward,
              onTap: _step == 3 ? _confirm : _next,
            )),
          ]),
        ),
      ]),
    );
  }

  Widget _step0(AppPalette p) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text('Select Service', style: p.display(22)),
    const SizedBox(height: 6),
    Text('What would you like to book today?', style: p.body(13, color: p.textMuted)),
    const SizedBox(height: 20),
    ..._services.map((s) => GestureDetector(
      onTap: () => setState(() => _service = s.$1),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _service == s.$1 ? kGold.withValues(alpha: 0.1) : p.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _service == s.$1 ? kGold : p.border, width: _service == s.$1 ? 1.5 : 1),
        ),
        child: Row(children: [
          Icon(s.$2, color: _service == s.$1 ? kGold : p.textMuted, size: 22),
          const SizedBox(width: 14),
          Expanded(child: Text(s.$1, style: p.body(14, weight: FontWeight.w600))),
          Text(s.$3, style: p.body(13, color: kGold)),
          if (_service == s.$1) ...[const SizedBox(width: 8), const Icon(Icons.check_circle, color: kGold, size: 18)],
        ]),
      ),
    )),
  ]);

  Widget _step1(AppPalette p) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text('Select Doctor', style: p.display(22)),
    const SizedBox(height: 6),
    Text('Choose your preferred specialist', style: p.body(13, color: p.textMuted)),
    const SizedBox(height: 20),
    ..._doctors.map((d) => GestureDetector(
      onTap: () => setState(() => _doctor = d.$1),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _doctor == d.$1 ? kGold.withValues(alpha: 0.1) : p.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _doctor == d.$1 ? kGold : p.border, width: _doctor == d.$1 ? 1.5 : 1),
        ),
        child: Row(children: [
          CircleAvatar(radius: 24, backgroundColor: kGold.withValues(alpha: 0.15), child: Text(d.$1.split(' ').last[0] + d.$1.split(' ')[1][0], style: p.body(13, color: kGold, weight: FontWeight.w700))),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(d.$1, style: p.body(15, weight: FontWeight.w700)),
            Text(d.$2, style: p.body(12, color: p.textMuted)),
            const SizedBox(height: 4),
            Row(children: [
              Icon(Icons.star_rounded, color: Colors.amber.shade400, size: 14),
              const SizedBox(width: 3),
              Text(d.$4, style: p.body(12, color: p.textMuted)),
              const SizedBox(width: 8),
              Text(d.$3, style: p.body(12, color: p.textMuted)),
            ]),
          ])),
          if (_doctor == d.$1) const Icon(Icons.check_circle, color: kGold, size: 18),
        ]),
      ),
    )),
  ]);

  Widget _step2(AppPalette p) {
    final now = DateTime.now();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Select Date & Time', style: p.display(22)),
      const SizedBox(height: 6),
      Text('Pick an available slot', style: p.body(13, color: p.textMuted)),
      const SizedBox(height: 20),
      // Date picker row
      SizedBox(height: 80, child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 14,
        itemBuilder: (_, i) {
          final day = now.add(Duration(days: i + 1));
          final sel = _date?.day == day.day && _date?.month == day.month;
          final dayNames = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
          return GestureDetector(
            onTap: () => setState(() => _date = day),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 10),
              width: 56,
              decoration: BoxDecoration(
                color: sel ? kGold : p.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: sel ? kGold : p.border),
              ),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(dayNames[day.weekday], style: p.body(11, color: sel ? Colors.black54 : p.textMuted)),
                const SizedBox(height: 4),
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
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: sel ? kGold : p.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: sel ? kGold : p.border),
            ),
            child: Text(s, style: p.body(13, color: sel ? Colors.black87 : p.text, weight: sel ? FontWeight.w600 : FontWeight.w400)),
          ),
        );
      }).toList()),
    ]);
  }

  Widget _step3(AppPalette p) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text('Confirm Booking', style: p.display(22)),
    const SizedBox(height: 6),
    Text('Review your appointment details', style: p.body(13, color: p.textMuted)),
    const SizedBox(height: 24),
    Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: p.border)),
      child: Column(children: [
        _ConfirmRow(Icons.spa_outlined, 'Service', _service ?? '—', p),
        Divider(color: p.border, height: 24),
        _ConfirmRow(Icons.person_outlined, 'Doctor', _doctor ?? '—', p),
        Divider(color: p.border, height: 24),
        _ConfirmRow(Icons.calendar_today_outlined, 'Date', _date != null ? '${_date!.day}/${_date!.month}/${_date!.year}' : '—', p),
        Divider(color: p.border, height: 24),
        _ConfirmRow(Icons.access_time_outlined, 'Time', _slot ?? '—', p),
      ]),
    ),
    const SizedBox(height: 20),
    Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: kGold.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: kGold.withValues(alpha: 0.2))),
      child: Row(children: [
        const Icon(Icons.info_outline, color: kGold, size: 18),
        const SizedBox(width: 10),
        Expanded(child: Text('You can reschedule or cancel up to 4 hours before your appointment.', style: p.body(12, color: p.textMuted))),
      ]),
    ),
  ]);
}

class _ConfirmRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final AppPalette p;
  const _ConfirmRow(this.icon, this.label, this.value, this.p);

  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, size: 18, color: kGold),
    const SizedBox(width: 12),
    Text(label, style: p.body(13, color: p.textMuted)),
    const Spacer(),
    Flexible(child: Text(value, style: p.body(14, weight: FontWeight.w600), textAlign: TextAlign.right, overflow: TextOverflow.ellipsis)),
  ]);
}
