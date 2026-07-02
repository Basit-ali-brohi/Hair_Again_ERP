import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../models/loyalty_models.dart';

class LoyaltyScreen extends StatefulWidget {
  const LoyaltyScreen({super.key});
  @override
  State<LoyaltyScreen> createState() => _LoyaltyScreenState();
}

class _LoyaltyScreenState extends State<LoyaltyScreen> with SingleTickerProviderStateMixin {
  late final TabController _tab;
  @override
  void initState() { super.initState(); _tab = TabController(length: 4, vsync: this); }
  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    return ScreenScaffold(
      title: 'LOYALTY & REWARDS',
      subtitle: 'Points system, tier management, rewards catalogue & referral program',
      actions: [
        Container(height: 42,
          decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: p.border)),
          child: TabBar(controller: _tab, isScrollable: true, dividerColor: Colors.transparent,
            indicatorColor: p.gold, indicatorSize: TabBarIndicatorSize.label,
            labelStyle: p.body(12.5, weight: FontWeight.w600), unselectedLabelStyle: p.body(12.5),
            labelColor: p.gold, unselectedLabelColor: p.textMuted, tabAlignment: TabAlignment.start,
            tabs: const [Tab(text: 'Dashboard'), Tab(text: 'Points Ledger'), Tab(text: 'Rewards'), Tab(text: 'Referrals')]),
        ),
      ],
      child: TabBarView(controller: _tab, children: const [
        _DashboardTab(), _PointsTab(), _RewardsTab(), _ReferralsTab(),
      ]),
    );
  }
}

Color _tierColor(AppPalette p, LoyaltyTier t) => switch (t) {
  LoyaltyTier.bronze => const Color(0xFFCD7F32),
  LoyaltyTier.silver => const Color(0xFFC0C0C0),
  LoyaltyTier.gold => p.gold,
  LoyaltyTier.platinum => const Color(0xFF00D4FF),
};

// ── Dashboard ────────────────────────────────────────────────────────────────
class _DashboardTab extends StatelessWidget {
  const _DashboardTab();
  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final accounts = appState.loyaltyAccounts;
    final totalPts = accounts.fold(0, (s, a) => s + a.availablePoints);
    final redeemedPts = accounts.fold(0, (s, a) => s + a.redeemedPoints);
    final bronze = accounts.where((a) => a.tier == LoyaltyTier.bronze).length;
    final silver = accounts.where((a) => a.tier == LoyaltyTier.silver).length;
    final gold = accounts.where((a) => a.tier == LoyaltyTier.gold).length;
    final platinum = accounts.where((a) => a.tier == LoyaltyTier.platinum).length;
    return ScrollArea(builder: (sc) => SingleChildScrollView(controller: sc, child: Column(children: [
      Row(children: [
        MetricCard(title: 'Total Members', value: '${accounts.length}', icon: Icons.people_outline, delta: ''),
        const SizedBox(width: 14),
        MetricCard(title: 'Total Points', value: '$totalPts', icon: Icons.stars_outlined, delta: ''),
        const SizedBox(width: 14),
        MetricCard(title: 'Redeemed', value: '$redeemedPts', icon: Icons.redeem_outlined, delta: ''),
        const SizedBox(width: 14),
        MetricCard(title: 'Referrals', value: '${appState.referrals.length}', icon: Icons.share_outlined, delta: ''),
      ]),
      const SizedBox(height: 20),
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('TIER DISTRIBUTION', style: p.display(18, spacing: 0.5)),
          const SizedBox(height: 16),
          _tierRow(p, LoyaltyTier.bronze, 'Bronze', bronze, accounts.length),
          _tierRow(p, LoyaltyTier.silver, 'Silver', silver, accounts.length),
          _tierRow(p, LoyaltyTier.gold, 'Gold', gold, accounts.length),
          _tierRow(p, LoyaltyTier.platinum, 'Platinum', platinum, accounts.length),
        ]))),
        const SizedBox(width: 18),
        SizedBox(width: 340, child: Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('TOP MEMBERS', style: p.display(18, spacing: 0.5)),
          const SizedBox(height: 16),
          ...((accounts.toList()..sort((a, b) => b.availablePoints.compareTo(a.availablePoints))).take(5).map((a) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(children: [
              Container(width: 36, height: 36, alignment: Alignment.center,
                decoration: BoxDecoration(color: _tierColor(p, a.tier).withValues(alpha: 0.15), shape: BoxShape.circle),
                child: Icon(Icons.stars, size: 18, color: _tierColor(p, a.tier))),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(a.customerName, style: p.body(13, weight: FontWeight.w600)),
                Text(a.tier.label, style: p.body(11.5, color: _tierColor(p, a.tier))),
              ])),
              Text('${a.availablePoints} pts', style: p.body(13, weight: FontWeight.w700, color: p.gold)),
            ]),
          ))),
        ]))),
      ]),
    ])));
  }

  static Widget _tierRow(AppPalette p, LoyaltyTier tier, String label, int count, int total) {
    final pct = total == 0 ? 0.0 : count / total;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(children: [
        SizedBox(width: 70, child: Text(label, style: p.body(13, weight: FontWeight.w500))),
        Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: pct, minHeight: 10, backgroundColor: p.border, color: _tierColor(p, tier)))),
        const SizedBox(width: 10),
        SizedBox(width: 30, child: Text('$count', style: p.body(12.5, color: p.textMuted))),
      ]),
    );
  }
}

// ── Points Ledger ─────────────────────────────────────────────────────────────
class _PointsTab extends StatefulWidget {
  const _PointsTab();
  @override
  State<_PointsTab> createState() => _PointsTabState();
}

class _PointsTabState extends State<_PointsTab> {
  String _q = '';
  LoyaltyTier? _tierFilter;

  void _showDetail(LoyaltyAccount acc) {
    final p = appState.palette;
    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, ss) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(width: 580, padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: p.border)),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 52, height: 52, alignment: Alignment.center,
              decoration: BoxDecoration(color: _tierColor(p, acc.tier).withValues(alpha: 0.12), shape: BoxShape.circle),
              child: Icon(Icons.stars, size: 26, color: _tierColor(p, acc.tier))),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(acc.customerName, style: p.display(20)),
              Text(acc.customerPhone, style: p.body(12.5, color: p.textMuted)),
            ])),
            StatusChip(label: acc.tier.label, color: _tierColor(p, acc.tier)),
            const SizedBox(width: 12),
            GestureDetector(onTap: () => Navigator.pop(ctx), child: MouseRegion(cursor: SystemMouseCursors.click, child: Icon(Icons.close, size: 20, color: p.textMuted))),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: _statBox(p, 'Total Earned', '${acc.totalPoints}', p.gold)),
            const SizedBox(width: 10),
            Expanded(child: _statBox(p, 'Redeemed', '${acc.redeemedPoints}', p.danger)),
            const SizedBox(width: 10),
            Expanded(child: _statBox(p, 'Available', '${acc.availablePoints}', p.success)),
          ]),
          const SizedBox(height: 16),
          Text('TRANSACTION HISTORY', style: p.body(11, weight: FontWeight.w700, spacing: 1.0, color: p.textMuted)),
          const SizedBox(height: 10),
          SizedBox(height: 220, child: ScrollArea(builder: (sc) => ListView.separated(
            controller: sc, itemCount: acc.transactions.length, separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final tx = acc.transactions[i];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(children: [
                  Icon(tx.isEarned ? Icons.add_circle_outline : Icons.remove_circle_outline, size: 16, color: tx.isEarned ? p.success : p.danger),
                  const SizedBox(width: 10),
                  Expanded(child: Text(tx.description, style: p.body(12.5))),
                  Text(prettyShort(tx.date), style: p.body(11.5, color: p.textMuted)),
                  const SizedBox(width: 10),
                  Text('${tx.isEarned ? '+' : '-'}${tx.points}', style: p.body(13, weight: FontWeight.w700, color: tx.isEarned ? p.success : p.danger)),
                ]),
              );
            },
          ))),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            GoldButton(label: 'Add Points', icon: Icons.add, onTap: () {
              acc.totalPoints += 100;
              acc.transactions.add(PointTransaction(id: DateTime.now().millisecondsSinceEpoch.toString(), type: 'earned', description: 'Manual points award', points: 100, date: DateTime.now()));
              acc.recalcTier(); appState.touch(); ss(() {}); setState(() {});
            }),
            const SizedBox(width: 10),
            GhostButton(label: 'Close', onTap: () => Navigator.pop(ctx)),
          ]),
        ]),
      ),
    )));
  }

  Widget _statBox(AppPalette p, String label, String val, Color color) => Container(padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withValues(alpha: 0.2))),
    child: Column(children: [Text(val, style: p.display(20, color: color)), const SizedBox(height: 4), Text(label, style: p.body(11.5, color: p.textMuted))]));

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    var list = appState.loyaltyAccounts;
    if (_q.isNotEmpty) list = list.where((a) => a.customerName.toLowerCase().contains(_q.toLowerCase())).toList();
    if (_tierFilter != null) list = list.where((a) => a.tier == _tierFilter).toList();

    return Column(children: [
      FilterBar(
        searchHint: 'Search by customer name…', onSearch: (v) => setState(() => _q = v),
        filters: [FilterDropdown<LoyaltyTier?>(value: _tierFilter, items: [const DropdownMenuItem(value: null, child: Text('All Tiers')), ...LoyaltyTier.values.map((t) => DropdownMenuItem(value: t, child: Text(t.label)))], onChanged: (v) => setState(() => _tierFilter = v))],
        countText: '${list.length} accounts', onClear: () => setState(() { _q = ''; _tierFilter = null; }),
      ),
      const SizedBox(height: 12),
      Expanded(child: list.isEmpty
        ? Center(child: Text('No loyalty accounts found.', style: p.body(13, color: p.textMuted)))
        : ScrollArea(builder: (sc) => ListView.separated(controller: sc, padding: const EdgeInsets.only(right: 8), itemCount: list.length, separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final acc = list[i];
              return MouseRegion(cursor: SystemMouseCursors.click, child: GestureDetector(onTap: () => _showDetail(acc), child: Panel(child: Row(children: [
                Container(width: 44, height: 44, alignment: Alignment.center,
                  decoration: BoxDecoration(color: _tierColor(p, acc.tier).withValues(alpha: 0.12), shape: BoxShape.circle),
                  child: Icon(Icons.stars, size: 20, color: _tierColor(p, acc.tier))),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(acc.customerName, style: p.body(13.5, weight: FontWeight.w700)),
                  Text(acc.customerPhone, style: p.body(12, color: p.textMuted)),
                ])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('${acc.availablePoints} pts', style: p.body(14, weight: FontWeight.w700, color: p.gold)),
                  const SizedBox(height: 4),
                  StatusChip(label: acc.tier.label, color: _tierColor(p, acc.tier)),
                ]),
              ]))));
            }))),
    ]);
  }
}

// ── Rewards ──────────────────────────────────────────────────────────────────
class _RewardsTab extends StatefulWidget {
  const _RewardsTab();
  @override
  State<_RewardsTab> createState() => _RewardsTabState();
}

class _RewardsTabState extends State<_RewardsTab> {
  void _showForm({Reward? existing}) {
    final editing = existing != null;
    final p = appState.palette;
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    int points = existing?.pointsRequired ?? 500;
    double value = existing?.value ?? 0;
    String type = existing?.rewardType ?? 'discount';
    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, ss) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(width: 480, padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: p.border)),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(editing ? 'EDIT REWARD' : 'ADD REWARD', style: p.display(22, spacing: 1.0)),
          const SizedBox(height: 20),
          FormField2(label: 'Reward Name *', controller: nameCtrl, hint: 'e.g. 10% Off Voucher'),
          const SizedBox(height: 14),
          Dropdown2<String>(label: 'Reward Type', value: type,
            items: const [DropdownMenuItem(value: 'discount', child: Text('Discount')), DropdownMenuItem(value: 'free_service', child: Text('Free Service')), DropdownMenuItem(value: 'gift', child: Text('Gift Item')), DropdownMenuItem(value: 'cashback', child: Text('Cashback'))],
            onChanged: (v) => ss(() => type = v ?? type)),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('POINTS REQUIRED', style: p.body(11, weight: FontWeight.w700, spacing: 1.0, color: p.textMuted)),
              const SizedBox(height: 8),
              Row(children: [QtyButton(Icons.remove, () => ss(() => points = (points - 100).clamp(100, 99999))), const SizedBox(width: 8), Text('$points', style: p.display(16)), const SizedBox(width: 8), QtyButton(Icons.add, () => ss(() => points += 100))]),
            ])),
            const SizedBox(width: 14),
            Expanded(child: FormField2(label: 'Value (PKR / %)', controller: TextEditingController(text: value == 0 ? '' : value.toStringAsFixed(0)), hint: '0', keyboard: TextInputType.number, onChanged: (v) => value = double.tryParse(v) ?? 0)),
          ]),
          const SizedBox(height: 14),
          FormField2(label: 'Description', controller: descCtrl, hint: 'Terms and what the customer gets…', maxLines: 2),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            GhostButton(label: 'Cancel', onTap: () => Navigator.pop(ctx)),
            const SizedBox(width: 12),
            GoldButton(label: editing ? 'Save Changes' : 'Add Reward', onTap: () {
              if (nameCtrl.text.isEmpty) return;
              if (editing) {
                existing!.name = nameCtrl.text; existing.description = descCtrl.text;
                existing.rewardType = type; existing.pointsRequired = points; existing.value = value;
                appState.touch();
              } else {
                appState.addReward(Reward(id: appState.createRewardId(), name: nameCtrl.text, description: descCtrl.text, rewardType: type, pointsRequired: points, value: value));
              }
              Navigator.pop(ctx); setState(() {});
            }),
          ]),
        ]),
      ),
    )));
  }

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final rewards = appState.rewards;
    return Column(children: [
      Row(children: [const Spacer(), GoldButton(label: 'Add Reward', icon: Icons.add, onTap: () => _showForm())]),
      const SizedBox(height: 12),
      Expanded(child: rewards.isEmpty
        ? Center(child: Text('No rewards defined yet.', style: p.body(13, color: p.textMuted)))
        : ScrollArea(builder: (sc) => GridView.builder(
            controller: sc, padding: const EdgeInsets.only(right: 12),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 340, mainAxisExtent: 200, crossAxisSpacing: 14, mainAxisSpacing: 14),
            itemCount: rewards.length,
            itemBuilder: (_, i) {
              final r = rewards[i];
              return Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(width: 40, height: 40, alignment: Alignment.center,
                    decoration: BoxDecoration(color: p.gold.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                    child: Icon(Icons.redeem_outlined, size: 20, color: p.gold)),
                  const SizedBox(width: 10),
                  Expanded(child: Text(r.name, style: p.body(13.5, weight: FontWeight.w700), maxLines: 2)),
                ]),
                const SizedBox(height: 10),
                StatusChip(label: r.typeLabel, color: p.info),
                const SizedBox(height: 8),
                Text('${r.pointsRequired} points required', style: p.body(12.5, color: p.textMuted)),
                if (r.value > 0) Text('Value: ${money(r.value)}', style: p.body(12.5, color: p.textMuted)),
                const Spacer(),
                Row(children: [
                  StatusChip(label: r.isActive ? 'Active' : 'Inactive', color: r.isActive ? p.success : p.textMuted),
                  const Spacer(),
                  GestureDetector(onTap: () => _showForm(existing: r), child: MouseRegion(cursor: SystemMouseCursors.click, child: Container(width: 28, height: 28, decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(7)), child: Icon(Icons.edit_outlined, size: 14, color: p.text)))),
                  const SizedBox(width: 6),
                  GestureDetector(onTap: () { r.isActive = !r.isActive; appState.touch(); setState(() {}); }, child: MouseRegion(cursor: SystemMouseCursors.click, child: Container(width: 28, height: 28, decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(7)), child: Icon(r.isActive ? Icons.toggle_on_outlined : Icons.toggle_off_outlined, size: 14, color: r.isActive ? p.success : p.textMuted)))),
                ]),
              ]));
            },
          ))),
    ]);
  }
}

// ── Referrals ─────────────────────────────────────────────────────────────────
class _ReferralsTab extends StatefulWidget {
  const _ReferralsTab();
  @override
  State<_ReferralsTab> createState() => _ReferralsTabState();
}

class _ReferralsTabState extends State<_ReferralsTab> {
  ReferralStatus? _statusFilter;

  void _showAddReferral() {
    final p = appState.palette;
    final referrerCtrl = TextEditingController(); final refereeCtrl = TextEditingController(); final phoneCtrl = TextEditingController();
    showDialog(context: context, builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(width: 460, padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: p.border)),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('LOG REFERRAL', style: p.display(22, spacing: 1.0)),
          const SizedBox(height: 20),
          FormField2(label: 'Referrer Name *', controller: referrerCtrl, hint: 'Who referred?'),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: FormField2(label: 'New Customer (Referee) *', controller: refereeCtrl, hint: 'Name')),
            const SizedBox(width: 14),
            Expanded(child: FormField2(label: 'Phone', controller: phoneCtrl, hint: '+92 ...')),
          ]),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            GhostButton(label: 'Cancel', onTap: () => Navigator.pop(ctx)),
            const SizedBox(width: 12),
            GoldButton(label: 'Log Referral', onTap: () {
              if (referrerCtrl.text.isEmpty || refereeCtrl.text.isEmpty) return;
              appState.addReferral(Referral(id: appState.createReferralId(), referrerId: '', referrerName: referrerCtrl.text, refereeName: refereeCtrl.text, refereePhone: phoneCtrl.text, createdAt: DateTime.now()));
              Navigator.pop(ctx); setState(() {});
            }),
          ]),
        ]),
      ),
    ));
  }

  Color _refColor(AppPalette p, ReferralStatus s) => switch (s) {
    ReferralStatus.pending => p.warning, ReferralStatus.qualified => p.info,
    ReferralStatus.rewarded => p.success, ReferralStatus.expired => p.textMuted,
  };

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    var list = appState.referrals;
    if (_statusFilter != null) list = list.where((r) => r.status == _statusFilter).toList();

    return Column(children: [
      FilterBar(searchHint: 'Search referrals…', onSearch: (_) {}, filters: [
        FilterDropdown<ReferralStatus?>(value: _statusFilter,
          items: [const DropdownMenuItem(value: null, child: Text('All Statuses')), ...ReferralStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.label)))],
          onChanged: (v) => setState(() => _statusFilter = v)),
      ], countText: '${list.length} referrals', onClear: () => setState(() => _statusFilter = null),
        trailing: [GoldButton(label: 'Log Referral', icon: Icons.add, onTap: _showAddReferral)]),
      const SizedBox(height: 12),
      Expanded(child: list.isEmpty
        ? Center(child: Text('No referrals logged.', style: p.body(13, color: p.textMuted)))
        : Panel(padding: EdgeInsets.zero, child: ScrollArea(builder: (sc) => SingleChildScrollView(controller: sc, child: FullWidthDataTable(child: DataTable(
            headingRowColor: WidgetStateProperty.all(p.surfaceAlt), columnSpacing: 20, horizontalMargin: 20,
            columns: ['Referrer', 'Referee', 'Phone', 'Date', 'Points', 'Status', 'Action'].map((t) => DataColumn(label: Text(t, style: p.body(12, weight: FontWeight.w700)))).toList(),
            rows: list.map((r) => DataRow(cells: [
              DataCell(Text(r.referrerName, style: p.body(13, weight: FontWeight.w600))),
              DataCell(Text(r.refereeName, style: p.body(12.5))),
              DataCell(Text(r.refereePhone, style: p.body(12.5))),
              DataCell(Text(prettyShort(r.createdAt), style: p.body(12.5))),
              DataCell(Text('${r.pointsEarned}', style: p.body(12.5, color: p.gold))),
              DataCell(StatusChip(label: r.status.label, color: _refColor(p, r.status))),
              DataCell(r.status == ReferralStatus.pending
                ? GoldButton(label: 'Qualify', onTap: () { r.status = ReferralStatus.qualified; r.qualifiedAt = DateTime.now(); r.pointsEarned = 200; appState.touch(); setState(() {}); })
                : const SizedBox.shrink()),
            ])).toList(),
          )))))),
    ]);
  }
}
