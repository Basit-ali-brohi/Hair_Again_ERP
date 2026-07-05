import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../core/widgets.dart';
import 'terms_screen.dart' show DocHeader, DocSection;

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = HaTheme.of(context);
    return Scaffold(
      backgroundColor: p.bg,
      appBar: const KAppBar(title: 'Privacy Policy'),
      body: Column(children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            children: [
              DocHeader(p: p, icon: Icons.privacy_tip_outlined, title: 'Privacy Policy', date: 'Last updated: January 2025'),
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
          child: GoldButton(label: 'Got It', onTap: () => Navigator.pop(context)),
        ),
      ]),
    );
  }
}

const _sections = [
  _PrivacySection(
    '1. Information We Collect',
    'We collect information you provide directly when creating an account:\n\n• Full name, email address, and phone number\n• Date of birth and gender (for medical records)\n• Medical history and treatment records\n• Payment information (processed securely via third-party)\n• Profile photos you upload\n\nWe also automatically collect device information, app usage data, and location data (only when you grant permission) to improve your experience.',
  ),
  _PrivacySection(
    '2. How We Use Your Information',
    'Hair Again uses your information to:\n\n• Schedule and manage your appointments\n• Maintain your medical records and treatment history\n• Send appointment reminders and notifications\n• Process payments for services\n• Improve our App and services\n• Comply with legal and regulatory requirements\n\nWe do not sell, trade, or rent your personal information to third parties.',
  ),
  _PrivacySection(
    '3. Data Security',
    'We implement industry-standard security measures to protect your personal and medical information:\n\n• All data transmitted is encrypted using TLS/SSL\n• Medical records are stored in HIPAA-compliant infrastructure\n• Access to your data is restricted to authorized personnel only\n• Regular security audits and vulnerability assessments\n\nWhile we strive to protect your information, no method of electronic storage or transmission is 100% secure.',
  ),
  _PrivacySection(
    '4. Information Sharing',
    'We may share your information with:\n\n• Licensed medical professionals at Hair Again Clinic for treatment purposes\n• Payment processors to complete transactions securely\n• Legal authorities when required by law\n• Service providers who assist in operating our App (under strict confidentiality agreements)\n\nWe will never share your medical information with insurers, employers, or marketers without your explicit consent.',
  ),
  _PrivacySection(
    '5. Your Rights',
    'You have the right to:\n\n• Access a copy of the personal data we hold about you\n• Request correction of inaccurate information\n• Request deletion of your account and associated data\n• Opt out of marketing communications at any time\n• Lodge a complaint with a supervisory authority\n\nTo exercise any of these rights, contact us at privacy@hairagain.pk.',
  ),
  _PrivacySection(
    '6. Data Retention',
    'We retain your personal data for as long as your account is active or as needed to provide services. Medical records are retained for a minimum of 7 years as required by Pakistani medical regulations.\n\nAfter account deletion, we may retain anonymized data for analytical purposes.',
  ),
  _PrivacySection(
    '7. Children\'s Privacy',
    'Our App is not intended for users under the age of 18. We do not knowingly collect personal information from children. If you believe a child has provided us with information, please contact us immediately.',
  ),
  _PrivacySection(
    '8. Contact Us',
    'If you have any questions about this Privacy Policy or how we handle your data:\n\nHair Again Clinic\nKarachi, Pakistan\nEmail: privacy@hairagain.pk\nPhone: +92-21-XXXX-XXXX\n\nData Protection Officer: dpo@hairagain.pk',
  ),
];

class _PrivacySection {
  final String title, body;
  const _PrivacySection(this.title, this.body);
}
