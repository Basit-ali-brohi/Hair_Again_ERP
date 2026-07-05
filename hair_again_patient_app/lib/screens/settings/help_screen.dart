import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../../../core/widgets.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = HaTheme.of(context);
    return Scaffold(
      backgroundColor: p.bg,
      appBar: const KAppBar(title: 'Help & Support'),
      body: ListView(padding: const EdgeInsets.fromLTRB(20, 20, 20, 40), children: [
        // Hero
        Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [kGold.withValues(alpha: 0.14), kGold.withValues(alpha: 0.04)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: kGold.withValues(alpha: 0.22)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(gradient: kGoldGradient, borderRadius: BorderRadius.circular(14)),
                child: const Icon(Icons.support_agent_rounded, color: Colors.black87, size: 24),
              ),
              const SizedBox(width: 14),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('How can we help?', style: p.display(18, color: kGold)),
                Text('We\'re here for you', style: p.body(13, color: p.textMuted)),
              ]),
            ]),
          ]),
        ),

        // Quick contact cards
        Text('Contact Us', style: p.body(16, weight: FontWeight.w700)),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _ContactCard(
            p: p, icon: Icons.chat_bubble_outline_rounded, label: 'Live Chat',
            sub: 'Chat with support', color: kInfo,
            onTap: () => context.push('/chat'),
          )),
          const SizedBox(width: 12),
          Expanded(child: _ContactCard(
            p: p, icon: Icons.phone_outlined, label: 'Call Us',
            sub: '+92-21-XXXX-XXXX', color: kSuccess,
            onTap: () {},
          )),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _ContactCard(
            p: p, icon: Icons.email_outlined, label: 'Email',
            sub: 'support@hairagain.pk', color: kWarning,
            onTap: () {},
          )),
          const SizedBox(width: 12),
          Expanded(child: _ContactCard(
            p: p, icon: Icons.location_on_outlined, label: 'Visit Us',
            sub: 'Karachi Clinic', color: kGold,
            onTap: () {},
          )),
        ]),

        const SizedBox(height: 28),

        // FAQ
        Text('Frequently Asked Questions', style: p.body(16, weight: FontWeight.w700)),
        const SizedBox(height: 12),
        ..._faqs.map((q) => _FaqTile(faq: q, p: p)),

        const SizedBox(height: 28),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: p.border),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Still need help?', style: p.body(15, weight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text('Our support team is available 9 AM – 6 PM, Mon–Sat.', style: p.body(13, color: p.textMuted)),
            const SizedBox(height: 14),
            GoldButton(label: 'Open Live Chat', onTap: () => context.push('/chat'), icon: Icons.chat_rounded),
          ]),
        ),
      ]),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final AppPalette p;
  final IconData icon;
  final String label, sub;
  final Color color;
  final VoidCallback onTap;
  const _ContactCard({required this.p, required this.icon, required this.label, required this.sub, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: p.border),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 19, color: color),
        ),
        const SizedBox(height: 10),
        Text(label, style: p.body(14, weight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text(sub, style: p.body(11, color: p.textMuted), overflow: TextOverflow.ellipsis),
      ]),
    ),
  );
}

class _FaqTile extends StatefulWidget {
  final _Faq faq;
  final AppPalette p;
  const _FaqTile({required this.faq, required this.p});
  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> with SingleTickerProviderStateMixin {
  bool _open = false;
  late final AnimationController _ctrl;
  late final Animation<double> _expand;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 220));
    _expand = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  void _toggle() {
    setState(() { _open = !_open; _open ? _ctrl.forward() : _ctrl.reverse(); });
  }

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    decoration: BoxDecoration(
      color: widget.p.surface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: _open ? kGold.withValues(alpha: 0.35) : widget.p.border),
    ),
    child: Column(children: [
      GestureDetector(
        onTap: _toggle,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(children: [
            Expanded(child: Text(widget.faq.q, style: widget.p.body(14, weight: FontWeight.w600, color: _open ? kGold : widget.p.text))),
            const SizedBox(width: 8),
            AnimatedRotation(
              turns: _open ? 0.5 : 0,
              duration: const Duration(milliseconds: 220),
              child: Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: _open ? kGold : widget.p.textMuted),
            ),
          ]),
        ),
      ),
      SizeTransition(
        sizeFactor: _expand,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          child: Column(children: [
            Container(height: 1, color: widget.p.border, margin: const EdgeInsets.only(bottom: 12)),
            Text(widget.faq.a, style: widget.p.body(13, color: widget.p.textMuted).copyWith(height: 1.6)),
          ]),
        ),
      ),
    ]),
  );
}

class _Faq {
  final String q, a;
  const _Faq(this.q, this.a);
}

const _faqs = [
  _Faq(
    'How do I book an appointment?',
    'Tap the "Book Appointment" button on the Home screen or navigate to the Bookings tab. Select your preferred treatment, choose a doctor and time slot, then confirm. You\'ll receive a confirmation notification immediately.',
  ),
  _Faq(
    'Can I reschedule or cancel my appointment?',
    'Yes, you can reschedule or cancel from the Bookings screen. Select your appointment and tap "Reschedule" or "Cancel". Please note that cancellations within 24 hours may incur a fee as per our policy.',
  ),
  _Faq(
    'How do I reset my password?',
    'On the Login screen, tap "Forgot Password?" and enter your registered email address. You\'ll receive an OTP to verify your identity, after which you can set a new password.',
  ),
  _Faq(
    'Is my medical information secure?',
    'Absolutely. All your medical records are stored in encrypted, HIPAA-compliant servers. Only your treating doctors and authorized staff can access your clinical data. We never share your information with third parties.',
  ),
  _Faq(
    'What payment methods are accepted?',
    'We accept major credit/debit cards (Visa, Mastercard), bank transfers, and JazzCash/EasyPaisa for your convenience. All payments are processed through secure, certified payment gateways.',
  ),
  _Faq(
    'How does the Before & After Gallery work?',
    'The Gallery shows real patient results with our interactive before/after comparison slider. Drag the divider to see the transformation. These are actual Hair Again patients who have consented to share their results.',
  ),
  _Faq(
    'What is the Loyalty Program?',
    'Every treatment earns you Hair Again Points. Points can be redeemed for discounts on future treatments. Gold Members get priority booking, Silver Members get exclusive promotions, and Platinum Members enjoy VIP access.',
  ),
  _Faq(
    'How long does a hair transplant take?',
    'A typical FUE hair transplant procedure takes 6–8 hours. You can plan your visit with our clinic in advance. Our team will walk you through the entire process during your initial consultation.',
  ),
];
