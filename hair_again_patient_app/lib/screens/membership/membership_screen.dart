import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../core/widgets.dart';

class MembershipScreen extends StatelessWidget {
  const MembershipScreen({super.key});

  static const _plans = [
    _Plan('Silver', 'Basic', kTextMuted, [
      '5% discount on all services',
      'Priority appointment booking',
      'Monthly newsletter',
    ], 'Rs 2,000 / month', false),
    _Plan('Gold', 'Most Popular', kGold, [
      '15% discount on all services',
      'Priority appointment booking',
      'Free scalp analysis (monthly)',
      'Dedicated support line',
      'Early access to promotions',
    ], 'Rs 4,500 / month', true),
    _Plan('Platinum', 'Premium', kInfo, [
      '25% discount on all services',
      'VIP appointment slots',
      'Free PRP session (quarterly)',
      'Dedicated specialist',
      '24/7 chat support',
      'Annual photo progress report',
    ], 'Rs 8,000 / month', false),
  ];

  @override
  Widget build(BuildContext context) {
    final p = HaTheme.of(context);
    return Scaffold(
      backgroundColor: p.bg,
      appBar: const KAppBar(title: 'Membership'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Current plan
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [kGold.withValues(alpha: 0.15), kGold.withValues(alpha: 0.05)]),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: kGold.withValues(alpha: 0.3)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: kGold, borderRadius: BorderRadius.circular(6)), child: Text('CURRENT PLAN', style: p.body(9, color: Colors.black87, weight: FontWeight.w800, spacing: 0.8))),
                const Spacer(),
                const Icon(Icons.workspace_premium_outlined, color: kGold, size: 24),
              ]),
              const SizedBox(height: 12),
              Text('Gold Membership', style: p.display(24, color: kGold)),
              const SizedBox(height: 4),
              Text('Active until 31 Aug 2026', style: p.body(13, color: p.textMuted)),
              const SizedBox(height: 16),
              Row(children: [
                _Benefit(Icons.percent, '15% off', p),
                const SizedBox(width: 16),
                _Benefit(Icons.spa_outlined, 'Free Analysis', p),
                const SizedBox(width: 16),
                _Benefit(Icons.support_agent_outlined, 'Priority', p),
              ]),
            ]),
          ),
          const SizedBox(height: 32),

          SectionHeader(title: 'Upgrade Your Plan'),
          const SizedBox(height: 16),

          ..._plans.map((plan) => _PlanCard(plan: plan)),
        ]),
      ),
    );
  }
}

class _Benefit extends StatelessWidget {
  final IconData icon;
  final String label;
  final AppPalette p;
  const _Benefit(this.icon, this.label, this.p);

  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Icon(icon, size: 14, color: kGold),
    const SizedBox(width: 4),
    Text(label, style: p.body(12, color: kGold, weight: FontWeight.w600)),
  ]);
}

class _Plan {
  final String name, tag;
  final Color color;
  final List<String> benefits;
  final String price;
  final bool current;
  const _Plan(this.name, this.tag, this.color, this.benefits, this.price, this.current);
}

class _PlanCard extends StatelessWidget {
  final _Plan plan;
  const _PlanCard({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    final p = HaTheme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: plan.current ? plan.color.withValues(alpha: 0.06) : p.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: plan.current ? plan.color : p.border, width: plan.current ? 1.5 : 1),
        boxShadow: [if (!p.isDark) BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(plan.name, style: p.display(20, color: plan.color)),
          const SizedBox(width: 10),
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: plan.color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)), child: Text(plan.tag, style: p.body(10, color: plan.color, weight: FontWeight.w700))),
          const Spacer(),
          Text(plan.price, style: p.body(14, color: plan.color, weight: FontWeight.w700)),
        ]),
        const SizedBox(height: 14),
        ...plan.benefits.map((b) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(children: [
            Icon(Icons.check_circle, size: 15, color: plan.color),
            const SizedBox(width: 10),
            Expanded(child: Text(b, style: p.body(13))),
          ]),
        )),
        const SizedBox(height: 8),
        GoldButton(
          label: plan.current ? 'Current Plan' : 'Upgrade to ${plan.name}',
          onTap: plan.current ? () {} : () {},
        ),
      ]),
    );
  }
}
