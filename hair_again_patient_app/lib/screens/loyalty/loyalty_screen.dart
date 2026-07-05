import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../core/widgets.dart';

class LoyaltyScreen extends StatelessWidget {
  const LoyaltyScreen({super.key});

  static const _history = [
    _LoyalTx('PRP Therapy — Session 3', '+150 pts', 'Earned', kSuccess, '15 Feb 2026'),
    _LoyalTx('PRP Therapy — Session 2', '+150 pts', 'Earned', kSuccess, '20 Jan 2026'),
    _LoyalTx('Membership Bonus', '+500 pts', 'Bonus', kGold, '1 Jan 2026'),
    _LoyalTx('Reward Redemption', '−200 pts', 'Redeemed', kDanger, '10 Dec 2025'),
    _LoyalTx('FUE Hair Transplant', '+800 pts', 'Earned', kSuccess, '10 Mar 2026'),
    _LoyalTx('Referral Bonus', '+300 pts', 'Referral', kInfo, '5 Dec 2025'),
  ];

  static const _rewards = [
    _Reward('Free Scalp Analysis', 200, Icons.biotech_outlined),
    _Reward('Rs 500 Off Next Visit', 500, Icons.local_offer_outlined),
    _Reward('Free PRP Session', 1500, Icons.water_drop_outlined),
    _Reward('Rs 2000 Off Treatment', 2000, Icons.card_giftcard_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final p = HaTheme.of(context);
    return Scaffold(
      backgroundColor: p.bg,
      appBar: const KAppBar(title: 'Loyalty Rewards'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
        child: Column(children: [
          // Points card — adaptive gradient
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: p.isDark
                ? const LinearGradient(colors: [Color(0xFF1A1500), Color(0xFF0E0E12)], begin: Alignment.topLeft, end: Alignment.bottomRight)
                : const LinearGradient(colors: [Color(0xFF3D2B00), Color(0xFF2A1F00)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: kGold.withValues(alpha: 0.3)),
            ),
            child: Column(children: [
              Text('YOUR POINTS', style: p.label(12, color: Colors.white54)),
              const SizedBox(height: 8),
              Text('1,250', style: p.display(52, color: kGold)),
              Text('Hair Again Points', style: p.body(14, color: Colors.white54)),
              const SizedBox(height: 20),
              Divider(color: kGold.withValues(alpha: 0.2), thickness: 1),
              const SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                _PointStat('2,400', 'Total Earned'),
                Container(height: 36, width: 1, color: kGold.withValues(alpha: 0.2)),
                _PointStat('200', 'Redeemed'),
                Container(height: 36, width: 1, color: kGold.withValues(alpha: 0.2)),
                _PointStat('950', 'Next Reward'),
              ]),
            ]),
          ),
          const SizedBox(height: 28),

          // Redeem rewards
          const SectionHeader(title: 'Redeem Rewards'),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.3,
            children: _rewards.map((r) => _RewardCard(reward: r, myPoints: 1250)).toList(),
          ),
          const SizedBox(height: 28),

          // History
          const SectionHeader(title: 'Points History'),
          const SizedBox(height: 14),
          ..._history.map((tx) => _TxRow(tx: tx)),
        ]),
      ),
    );
  }
}

class _PointStat extends StatelessWidget {
  final String value, label;
  const _PointStat(this.value, this.label);
  @override
  Widget build(BuildContext context) => Column(children: [
    Text(value, style: const TextStyle(fontSize: 16, color: kGold, fontWeight: FontWeight.w700)),
    const SizedBox(height: 2),
    Text(label, style: const TextStyle(fontSize: 11, color: Colors.white54)),
  ]);
}

class _LoyalTx {
  final String label, points, type, date;
  final Color color;
  const _LoyalTx(this.label, this.points, this.type, this.color, this.date);
}

class _Reward {
  final String label;
  final int cost;
  final IconData icon;
  const _Reward(this.label, this.cost, this.icon);
}

class _RewardCard extends StatelessWidget {
  final _Reward reward;
  final int myPoints;
  const _RewardCard({super.key, required this.reward, required this.myPoints});

  @override
  Widget build(BuildContext context) {
    final p = HaTheme.of(context);
    final canRedeem = myPoints >= reward.cost;
    return GestureDetector(
      onTap: canRedeem ? () {} : null,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: canRedeem ? kGold.withValues(alpha: 0.08) : p.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: canRedeem ? kGold.withValues(alpha: 0.3) : p.border),
          boxShadow: [if (!p.isDark) BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(reward.icon, color: canRedeem ? kGold : p.textMuted, size: 24),
          const Spacer(),
          Text(reward.label, style: p.body(13, weight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 6),
          Row(children: [
            Text('${reward.cost} pts', style: p.body(12, color: canRedeem ? kGold : p.textMuted, weight: FontWeight.w700)),
            const Spacer(),
            if (canRedeem) const Icon(Icons.arrow_forward_ios, size: 12, color: kGold),
            if (!canRedeem) Icon(Icons.lock_outline, size: 14, color: p.textMuted),
          ]),
        ]),
      ),
    );
  }
}

class _TxRow extends StatelessWidget {
  final _LoyalTx tx;
  const _TxRow({super.key, required this.tx});

  @override
  Widget build(BuildContext context) {
    final p = HaTheme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.border),
        boxShadow: [if (!p.isDark) BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(children: [
        Container(width: 36, height: 36, decoration: BoxDecoration(color: tx.color.withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(Icons.star_rounded, size: 18, color: tx.color)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(tx.label, style: p.body(13, weight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(tx.date, style: p.body(11, color: p.textMuted)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(tx.points, style: p.body(14, color: tx.color, weight: FontWeight.w700)),
          StatusBadge(label: tx.type, color: tx.color),
        ]),
      ]),
    );
  }
}
