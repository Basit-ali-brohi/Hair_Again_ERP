import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../core/widgets.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = HaTheme.of(context);
    return Scaffold(
      backgroundColor: p.bg,
      appBar: const KAppBar(title: 'Terms & Conditions'),
      body: Column(children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            children: [
              DocHeader(p: p, icon: Icons.description_outlined, title: 'Terms & Conditions', date: 'Last updated: January 2025'),
              const SizedBox(height: 24),
              ..._sections.map((s) => DocSection(p: p, title: s.title, body: s.body)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          decoration: BoxDecoration(
            color: p.surface,
            border: Border(top: BorderSide(color: p.border)),
          ),
          child: GoldButton(label: 'I Understand', onTap: () => Navigator.pop(context)),
        ),
      ]),
    );
  }
}

const _sections = [
  _Section(
    '1. Acceptance of Terms',
    'By downloading, installing, or using the Hair Again Patient App ("App"), you agree to be bound by these Terms and Conditions. If you do not agree to these terms, please do not use the App.\n\nThese terms apply to all users of the App, including patients seeking hair restoration consultations, treatments, and related services.',
  ),
  _Section(
    '2. Medical Disclaimer',
    'The content provided in this App is for informational purposes only and does not constitute professional medical advice, diagnosis, or treatment. Hair Again provides licensed medical professionals for consultations; however, information shared in this App should not replace direct consultation with your doctor.\n\nAlways seek the advice of a qualified healthcare provider before making any decisions related to your hair restoration treatment.',
  ),
  _Section(
    '3. Appointment Booking',
    'Appointments booked through the App are subject to availability and clinic operating hours. Hair Again reserves the right to reschedule or cancel appointments due to unforeseen circumstances.\n\nPatients are required to provide at least 24 hours notice for appointment cancellations. Failure to provide adequate notice may result in a cancellation fee.',
  ),
  _Section(
    '4. Patient Information',
    'You agree to provide accurate, current, and complete information when creating your account and booking appointments. Hair Again uses your information solely for providing clinical services and improving your patient experience.\n\nYou are responsible for maintaining the confidentiality of your account credentials and for all activities that occur under your account.',
  ),
  _Section(
    '5. Payments',
    'Payment for services rendered is due at the time of service unless prior arrangements have been made. Hair Again accepts major credit cards, bank transfers, and other payment methods as listed in the App.\n\nAll fees are non-refundable unless Hair Again has failed to deliver the agreed service. Pricing is subject to change with advance notice.',
  ),
  _Section(
    '6. Intellectual Property',
    'All content in the App, including text, graphics, logos, and images, is the property of Hair Again Clinic and is protected by applicable intellectual property laws. You may not reproduce, distribute, or create derivative works without express written consent from Hair Again.',
  ),
  _Section(
    '7. Limitation of Liability',
    'Hair Again shall not be liable for any indirect, incidental, special, or consequential damages arising from your use of the App or our services. Our total liability is limited to the amount paid for the specific service that gives rise to the claim.',
  ),
  _Section(
    '8. Changes to Terms',
    'Hair Again reserves the right to modify these Terms at any time. Changes will be effective immediately upon posting to the App. Continued use of the App after changes constitutes acceptance of the new Terms.\n\nWe will notify users of significant changes via in-app notification.',
  ),
  _Section(
    '9. Contact',
    'If you have questions about these Terms, please contact us at:\n\nHair Again Clinic\nKarachi, Pakistan\nEmail: legal@hairagain.pk\nPhone: +92-21-XXXX-XXXX',
  ),
];

class _Section {
  final String title, body;
  const _Section(this.title, this.body);
}

class DocHeader extends StatelessWidget {
  final AppPalette p;
  final IconData icon;
  final String title, date;
  const DocHeader({super.key, required this.p, required this.icon, required this.title, required this.date});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [kGold.withValues(alpha: 0.12), kGold.withValues(alpha: 0.04)],
        begin: Alignment.topLeft, end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: kGold.withValues(alpha: 0.2)),
    ),
    child: Row(children: [
      Container(
        width: 52, height: 52,
        decoration: BoxDecoration(gradient: kGoldGradient, borderRadius: BorderRadius.circular(14)),
        child: Icon(icon, color: Colors.black87, size: 24),
      ),
      const SizedBox(width: 14),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: p.display(18, color: kGold)),
        const SizedBox(height: 4),
        Text(date, style: p.body(12, color: p.textMuted)),
      ]),
    ]),
  );
}

class DocSection extends StatelessWidget {
  final AppPalette p;
  final String title, body;
  const DocSection({super.key, required this.p, required this.title, required this.body});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 24),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: p.body(15, weight: FontWeight.w700, color: kGold)),
      const SizedBox(height: 8),
      Text(body, style: p.body(14, color: p.textMuted).copyWith(height: 1.6)),
    ]),
  );
}
