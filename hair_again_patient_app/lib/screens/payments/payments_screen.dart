import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../core/widgets.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});
  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> with SingleTickerProviderStateMixin {
  late final TabController _tab;
  @override
  void initState() { super.initState(); _tab = TabController(length: 2, vsync: this); }
  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  static const _methods = [
    _Method('JazzCash', '0312-345-6789', Icons.phone_android_outlined, true),
    _Method('EasyPaisa', '0342-987-6543', Icons.account_balance_wallet_outlined, false),
    _Method('HBL Debit Card', '**** 4521', Icons.credit_card_outlined, false),
  ];

  static const _txns = [
    _Txn('PRP Therapy — Session 3', '15 Feb 2026', 'Rs 12,000', 'Paid', kSuccess),
    _Txn('Membership — Gold Plan', '1 Feb 2026', 'Rs 4,500', 'Paid', kSuccess),
    _Txn('PRP Therapy — Session 2', '20 Jan 2026', 'Rs 12,000', 'Paid', kSuccess),
    _Txn('FUE Hair Transplant — 50%', '10 Mar 2026', 'Rs 40,000', 'Paid', kSuccess),
    _Txn('FUE Hair Transplant — 50%', '10 Apr 2026', 'Rs 40,000', 'Pending', kWarning),
    _Txn('Consultation Fee', '1 Dec 2025', 'Rs 1,500', 'Paid', kSuccess),
  ];

  @override
  Widget build(BuildContext context) {
    final p = HaTheme.of(context);
    return Scaffold(
      backgroundColor: p.bg,
      appBar: const KAppBar(title: 'Payments'),
      body: Column(children: [
        // Balance summary
        Container(
          padding: const EdgeInsets.all(20),
          color: p.surface,
          child: Row(children: [
            Expanded(child: _BalanceTile('Rs 40,000', 'Amount Due', kDanger, Icons.warning_amber_outlined, p)),
            Container(width: 1, height: 48, color: p.border),
            Expanded(child: _BalanceTile('Rs 70,000', 'Total Paid', kSuccess, Icons.check_circle_outline, p)),
            Container(width: 1, height: 48, color: p.border),
            Expanded(child: _BalanceTile('Rs 1,10,000', 'Total Spend', kGold, Icons.analytics_outlined, p)),
          ]),
        ),
        Container(height: 1, color: p.border),

        TabBar(
          controller: _tab,
          indicatorColor: kGold, labelColor: kGold, unselectedLabelColor: p.textMuted,
          labelStyle: p.body(14, weight: FontWeight.w600), unselectedLabelStyle: p.body(14),
          dividerColor: p.border,
          tabs: const [Tab(text: 'Transactions'), Tab(text: 'Payment Methods')],
        ),

        Expanded(child: TabBarView(controller: _tab, children: [
          // Transactions
          ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
            itemCount: _txns.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final t = _txns[i];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: p.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: p.border),
                  boxShadow: [if (!p.isDark) BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
                ),
                child: Row(children: [
                  Container(width: 40, height: 40, decoration: BoxDecoration(color: t.statusColor.withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(Icons.receipt_outlined, color: t.statusColor, size: 18)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(t.title, style: p.body(13, weight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 3),
                    Text(t.date, style: p.body(11, color: p.textMuted)),
                  ])),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text(t.amount, style: p.body(14, weight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    StatusBadge(label: t.status, color: t.statusColor),
                  ]),
                ]),
              );
            },
          ),

          // Payment methods
          ListView(padding: const EdgeInsets.fromLTRB(20, 20, 20, 40), children: [
            ..._methods.map((m) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: m.isDefault ? kGold.withValues(alpha: 0.08) : p.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: m.isDefault ? kGold.withValues(alpha: 0.3) : p.border),
              ),
              child: Row(children: [
                Container(width: 44, height: 44, decoration: BoxDecoration(color: kGold.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)), child: Icon(m.icon, color: kGold, size: 22)),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(m.name, style: p.body(14, weight: FontWeight.w700)),
                  Text(m.detail, style: p.body(12, color: p.textMuted)),
                ])),
                if (m.isDefault) Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: kGold, borderRadius: BorderRadius.circular(4)), child: Text('DEFAULT', style: p.body(9, color: Colors.black87, weight: FontWeight.w800))),
              ]),
            )),
            const SizedBox(height: 8),
            OutlineBtn(label: '+ Add Payment Method', onTap: () {}),
          ]),
        ])),
      ]),
    );
  }
}

class _BalanceTile extends StatelessWidget {
  final String value, label;
  final Color color;
  final IconData icon;
  final AppPalette p;
  const _BalanceTile(this.value, this.label, this.color, this.icon, this.p);

  @override
  Widget build(BuildContext context) => Column(children: [
    Icon(icon, color: color, size: 18),
    const SizedBox(height: 4),
    Text(value, style: p.body(14, color: color, weight: FontWeight.w700)),
    Text(label, style: p.body(10, color: p.textMuted)),
  ]);
}

class _Method {
  final String name, detail;
  final IconData icon;
  final bool isDefault;
  const _Method(this.name, this.detail, this.icon, this.isDefault);
}

class _Txn {
  final String title, date, amount, status;
  final Color statusColor;
  const _Txn(this.title, this.date, this.amount, this.status, this.statusColor);
}
