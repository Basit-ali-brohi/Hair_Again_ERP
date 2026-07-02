import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../models/membership_models.dart';

class MembershipScreen extends StatefulWidget {
  const MembershipScreen({super.key});
  @override
  State<MembershipScreen> createState() => _MembershipScreenState();
}

class _MembershipScreenState extends State<MembershipScreen> with SingleTickerProviderStateMixin {
  late final TabController _tab;
  @override
  void initState() { super.initState(); _tab = TabController(length: 3, vsync: this); }
  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    return ScreenScaffold(
      title: 'MEMBERSHIP',
      subtitle: 'Membership plans, customer subscriptions & renewal management',
      actions: [
        Container(height: 42,
          decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: p.border)),
          child: TabBar(controller: _tab, isScrollable: true, dividerColor: Colors.transparent,
            indicatorColor: p.gold, indicatorSize: TabBarIndicatorSize.label,
            labelStyle: p.body(12.5, weight: FontWeight.w600), unselectedLabelStyle: p.body(12.5),
            labelColor: p.gold, unselectedLabelColor: p.textMuted, tabAlignment: TabAlignment.start,
            tabs: const [Tab(text: 'Plans'), Tab(text: 'Members'), Tab(text: 'Renewals Due')]),
        ),
      ],
      child: TabBarView(controller: _tab, children: const [
        _PlansTab(), _MembersTab(), _RenewalsTab(),
      ]),
    );
  }
}

// ── Plans ────────────────────────────────────────────────────────────────────
class _PlansTab extends StatefulWidget {
  const _PlansTab();
  @override
  State<_PlansTab> createState() => _PlansTabState();
}

class _PlansTabState extends State<_PlansTab> {
  void _showForm({MembershipPlan? existing}) {
    final editing = existing != null;
    final p = appState.palette;
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    double price = existing?.price ?? 5000;
    int months = existing?.durationMonths ?? 3;
    int sessions = existing?.maxSessions ?? 6;
    double discount = existing?.discountPercentage ?? 10;
    String colorTag = existing?.colorTag ?? '#DAA520';
    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, ss) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(width: 520, padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: p.border)),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(editing ? 'EDIT PLAN' : 'ADD MEMBERSHIP PLAN', style: p.display(22, spacing: 1.0)),
          const SizedBox(height: 20),
          FormField2(label: 'Plan Name *', controller: nameCtrl, hint: 'e.g. Gold Plan'),
          const SizedBox(height: 14),
          FormField2(label: 'Description', controller: descCtrl, hint: 'What does this plan include?', maxLines: 2),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: FormField2(label: 'Price (PKR)', controller: TextEditingController(text: price == 0 ? '' : price.toStringAsFixed(0)), hint: '5000', keyboard: TextInputType.number, onChanged: (v) => price = double.tryParse(v) ?? price)),
            const SizedBox(width: 14),
            Expanded(child: FormField2(label: 'Discount (%)', controller: TextEditingController(text: discount.toStringAsFixed(0)), hint: '10', keyboard: TextInputType.number, onChanged: (v) => discount = double.tryParse(v) ?? discount)),
          ]),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('DURATION (MONTHS)', style: p.body(11, weight: FontWeight.w700, spacing: 1.0, color: p.textMuted)),
              const SizedBox(height: 8),
              Row(children: [QtyButton(Icons.remove, () => ss(() { if (months > 1) months--; })), const SizedBox(width: 10), Text('$months', style: p.display(18)), const SizedBox(width: 10), QtyButton(Icons.add, () => ss(() => months++))]),
            ])),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('MAX SESSIONS', style: p.body(11, weight: FontWeight.w700, spacing: 1.0, color: p.textMuted)),
              const SizedBox(height: 8),
              Row(children: [QtyButton(Icons.remove, () => ss(() { if (sessions > 0) sessions--; })), const SizedBox(width: 10), Text('$sessions', style: p.display(18)), const SizedBox(width: 10), QtyButton(Icons.add, () => ss(() => sessions++))]),
            ])),
          ]),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            GhostButton(label: 'Cancel', onTap: () => Navigator.pop(ctx)),
            const SizedBox(width: 12),
            GoldButton(label: editing ? 'Save Changes' : 'Create Plan', onTap: () {
              if (nameCtrl.text.isEmpty) return;
              if (editing) {
                existing!.name = nameCtrl.text; existing.description = descCtrl.text; existing.price = price;
                existing.durationMonths = months; existing.maxSessions = sessions; existing.discountPercentage = discount;
                appState.touch();
              } else {
                appState.addMembershipPlan(MembershipPlan(id: appState.createPlanId(), name: nameCtrl.text, description: descCtrl.text, price: price, durationMonths: months, maxSessions: sessions, discountPercentage: discount, benefits: [], colorTag: colorTag));
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
    final plans = appState.membershipPlans;
    return Column(children: [
      Row(children: [const Spacer(), GoldButton(label: 'New Plan', icon: Icons.add, onTap: () => _showForm())]),
      const SizedBox(height: 12),
      Expanded(child: plans.isEmpty
        ? Center(child: Text('No membership plans created yet.', style: p.body(13, color: p.textMuted)))
        : ScrollArea(builder: (sc) => GridView.builder(
            controller: sc, padding: const EdgeInsets.only(right: 12),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 380, mainAxisExtent: 280, crossAxisSpacing: 16, mainAxisSpacing: 16),
            itemCount: plans.length,
            itemBuilder: (_, i) => _PlanCard(plan: plans[i], onEdit: () => _showForm(existing: plans[i]), onToggle: () { plans[i].isActive = !plans[i].isActive; appState.touch(); setState(() {}); }),
          ))),
    ]);
  }
}

class _PlanCard extends StatelessWidget {
  final MembershipPlan plan;
  final VoidCallback onEdit, onToggle;
  const _PlanCard({required this.plan, required this.onEdit, required this.onToggle});
  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    return Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(width: 44, height: 44, alignment: Alignment.center,
          decoration: BoxDecoration(gradient: p.goldGradient, borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.card_membership_outlined, size: 20, color: Colors.white)),
        const SizedBox(width: 12),
        Expanded(child: Text(plan.name, style: p.body(15, weight: FontWeight.w700))),
        StatusChip(label: plan.isActive ? 'Active' : 'Inactive', color: plan.isActive ? p.success : p.textMuted),
      ]),
      const SizedBox(height: 14),
      Text(money(plan.price), style: p.display(24, color: p.gold)),
      Text('per ${plan.durationMonths} month${plan.durationMonths > 1 ? 's' : ''}', style: p.body(12.5, color: p.textMuted)),
      const SizedBox(height: 12),
      _chip(p, Icons.fitness_center_outlined, '${plan.maxSessions} sessions'),
      const SizedBox(height: 6),
      _chip(p, Icons.discount_outlined, '${plan.discountPercentage.toStringAsFixed(0)}% discount'),
      if (plan.description.isNotEmpty) ...[const SizedBox(height: 8), Text(plan.description, style: p.body(12, color: p.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis)],
      const Spacer(),
      Row(children: [
        GhostButton(label: plan.isActive ? 'Deactivate' : 'Activate', onTap: onToggle),
        const Spacer(),
        GestureDetector(onTap: onEdit, child: MouseRegion(cursor: SystemMouseCursors.click, child: Container(width: 30, height: 30, decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(8)), child: Icon(Icons.edit_outlined, size: 15, color: p.text)))),
      ]),
    ]));
  }
  Widget _chip(AppPalette p, IconData ic, String t) => Row(children: [Icon(ic, size: 14, color: p.textMuted), const SizedBox(width: 8), Text(t, style: p.body(12.5, color: p.textMuted))]);
}

// ── Members ──────────────────────────────────────────────────────────────────
class _MembersTab extends StatefulWidget {
  const _MembersTab();
  @override
  State<_MembersTab> createState() => _MembersTabState();
}

class _MembersTabState extends State<_MembersTab> {
  String _q = '';
  MembershipStatus? _statusFilter;

  void _showDetail(CustomerMembership m) {
    final p = appState.palette;
    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, ss) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(width: 540, padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: p.border)),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 52, height: 52, alignment: Alignment.center,
              decoration: BoxDecoration(gradient: p.goldGradient, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.card_membership_outlined, size: 24, color: Colors.white)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(m.customerName, style: p.display(20)),
              Text(m.customerPhone, style: p.body(12.5, color: p.textMuted)),
            ])),
            StatusChip(label: m.status.label, color: _memberColor(p, m.status)),
            const SizedBox(width: 12),
            GestureDetector(onTap: () => Navigator.pop(ctx), child: MouseRegion(cursor: SystemMouseCursors.click, child: Icon(Icons.close, size: 20, color: p.textMuted))),
          ]),
          const SizedBox(height: 20),
          Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(12), border: Border.all(color: p.border)), child: Column(children: [
            _r(p, 'Plan', m.planName), _r(p, 'Start Date', prettyShort(m.startDate)),
            _r(p, 'End Date', prettyShort(m.endDate)), _r(p, 'Amount Paid', money(m.amountPaid)),
            _r(p, 'Sessions', '${m.sessionsUsed} / ${m.sessionsTotal} used (${m.sessionsRemaining} remaining)'),
          ])),
          const SizedBox(height: 16),
          Text('SESSION USAGE', style: p.body(11, weight: FontWeight.w700, spacing: 1.0, color: p.textMuted)),
          const SizedBox(height: 8),
          ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: m.usagePct, minHeight: 10, backgroundColor: p.border, color: p.gold)),
          const SizedBox(height: 4),
          Text('${(m.usagePct * 100).toStringAsFixed(0)}% sessions used', style: p.body(12, color: p.textMuted)),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            if (m.status == MembershipStatus.active) GoldButton(label: 'Use Session', onTap: () { if (m.sessionsRemaining > 0) { m.sessionsUsed++; appState.touch(); ss(() {}); } }),
            const SizedBox(width: 12),
            GhostButton(label: 'Close', onTap: () => Navigator.pop(ctx)),
          ]),
        ]),
      ),
    )));
  }

  Color _memberColor(AppPalette p, MembershipStatus s) => switch (s) {
    MembershipStatus.active => p.success, MembershipStatus.expired => p.danger,
    MembershipStatus.suspended => p.warning, MembershipStatus.cancelled => p.textMuted,
  };
  Widget _r(AppPalette p, String l, String v) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [SizedBox(width: 120, child: Text(l, style: p.body(12, color: p.textMuted))), Expanded(child: Text(v, style: p.body(12.5, weight: FontWeight.w500)))]));

  void _showEnroll() {
    final p = appState.palette;
    final nameCtrl = TextEditingController(); final phoneCtrl = TextEditingController(); final notesCtrl = TextEditingController();
    MembershipPlan? selectedPlan; double paid = 0;
    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, ss) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(width: 500, padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: p.border)),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('ENROLL CUSTOMER', style: p.display(22, spacing: 1.0)),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: FormField2(label: 'Customer Name *', controller: nameCtrl, hint: 'Full name')),
            const SizedBox(width: 14),
            Expanded(child: FormField2(label: 'Phone', controller: phoneCtrl, hint: '+92 ...')),
          ]),
          const SizedBox(height: 14),
          Dropdown2<MembershipPlan?>(label: 'Membership Plan *', value: selectedPlan,
            items: appState.membershipPlans.where((p) => p.isActive).map((p) => DropdownMenuItem(value: p, child: Text('${p.name} — ${money(p.price)}'))).toList(),
            onChanged: (v) => ss(() { selectedPlan = v; paid = v?.price ?? 0; })),
          const SizedBox(height: 14),
          FormField2(label: 'Amount Paid (PKR)', controller: TextEditingController(text: paid == 0 ? '' : paid.toStringAsFixed(0)), hint: '0', keyboard: TextInputType.number, onChanged: (v) => paid = double.tryParse(v) ?? 0),
          const SizedBox(height: 14),
          FormField2(label: 'Notes', controller: notesCtrl, hint: 'Optional notes…', maxLines: 2),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            GhostButton(label: 'Cancel', onTap: () => Navigator.pop(ctx)),
            const SizedBox(width: 12),
            GoldButton(label: 'Enroll', onTap: () {
              if (nameCtrl.text.isEmpty || selectedPlan == null) return;
              final pl = selectedPlan!;
              final now = DateTime.now();
              appState.addCustomerMembership(CustomerMembership(
                id: appState.createMembershipId(), customerId: '', customerName: nameCtrl.text,
                customerPhone: phoneCtrl.text, planId: pl.id, planName: pl.name,
                startDate: now, endDate: now.add(Duration(days: pl.durationMonths * 30)),
                sessionsTotal: pl.maxSessions, amountPaid: paid, notes: notesCtrl.text,
              ));
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
    var list = appState.customerMemberships;
    if (_q.isNotEmpty) list = list.where((m) => m.customerName.toLowerCase().contains(_q.toLowerCase()) || m.planName.toLowerCase().contains(_q.toLowerCase())).toList();
    if (_statusFilter != null) list = list.where((m) => m.status == _statusFilter).toList();

    return Column(children: [
      Row(children: [
        MetricCard(title: 'Total Members', value: '${appState.customerMemberships.length}', icon: Icons.group_outlined, delta: ''),
        const SizedBox(width: 14),
        MetricCard(title: 'Active', value: '${appState.customerMemberships.where((m) => m.status == MembershipStatus.active).length}', icon: Icons.check_circle_outline, delta: ''),
        const SizedBox(width: 14),
        MetricCard(title: 'Expired', value: '${appState.customerMemberships.where((m) => m.status == MembershipStatus.expired).length}', icon: Icons.cancel_outlined, delta: ''),
      ]),
      const SizedBox(height: 16),
      FilterBar(
        searchHint: 'Search by customer or plan…', onSearch: (v) => setState(() => _q = v),
        filters: [FilterDropdown<MembershipStatus?>(value: _statusFilter, items: [const DropdownMenuItem(value: null, child: Text('All Statuses')), ...MembershipStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.label)))], onChanged: (v) => setState(() => _statusFilter = v))],
        countText: '${list.length} members', onClear: () => setState(() { _q = ''; _statusFilter = null; }),
        trailing: [GoldButton(label: 'Enroll Customer', icon: Icons.person_add_outlined, onTap: _showEnroll)],
      ),
      const SizedBox(height: 12),
      Expanded(child: list.isEmpty
        ? Center(child: Text('No members found.', style: p.body(13, color: p.textMuted)))
        : ScrollArea(builder: (sc) => ListView.separated(controller: sc, padding: const EdgeInsets.only(right: 8), itemCount: list.length, separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final m = list[i];
              return MouseRegion(cursor: SystemMouseCursors.click, child: GestureDetector(onTap: () => _showDetail(m), child: Panel(child: Row(children: [
                Container(width: 42, height: 42, alignment: Alignment.center,
                  decoration: BoxDecoration(color: _memberColor(p, m.status).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                  child: Icon(Icons.card_membership_outlined, size: 20, color: _memberColor(p, m.status))),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(m.customerName, style: p.body(13.5, weight: FontWeight.w700)),
                  Text('${m.planName} · Expires ${prettyShort(m.endDate)}', style: p.body(12, color: p.textMuted)),
                ])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  StatusChip(label: m.status.label, color: _memberColor(p, m.status)),
                  const SizedBox(height: 6),
                  Text('${m.sessionsRemaining} sessions left', style: p.body(12, color: p.textMuted)),
                ]),
              ]))));
            }))),
    ]);
  }
}

// ── Renewals Due ─────────────────────────────────────────────────────────────
class _RenewalsTab extends StatefulWidget {
  const _RenewalsTab();
  @override
  State<_RenewalsTab> createState() => _RenewalsTabState();
}

class _RenewalsTabState extends State<_RenewalsTab> {
  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final now = DateTime.now();
    final due = appState.customerMemberships
      .where((m) => m.status == MembershipStatus.active && m.endDate.difference(now).inDays <= 30)
      .toList()..sort((a, b) => a.endDate.compareTo(b.endDate));

    return due.isEmpty
      ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.check_circle_outline, size: 44, color: p.success.withValues(alpha: 0.6)), const SizedBox(height: 12), Text('No renewals due in the next 30 days!', style: p.body(13, color: p.textMuted))]))
      : ScrollArea(builder: (sc) => ListView.separated(
          controller: sc, padding: const EdgeInsets.only(right: 8), itemCount: due.length, separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) {
            final m = due[i];
            final daysLeft = m.endDate.difference(now).inDays;
            final urgent = daysLeft <= 7;
            return Panel(child: Row(children: [
              Container(width: 44, height: 44, alignment: Alignment.center,
                decoration: BoxDecoration(color: (urgent ? p.danger : p.warning).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.notification_important_outlined, size: 22, color: urgent ? p.danger : p.warning)),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(m.customerName, style: p.body(13.5, weight: FontWeight.w700)),
                Text('${m.planName} · ${m.customerPhone}', style: p.body(12, color: p.textMuted)),
              ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('$daysLeft days left', style: p.body(13, weight: FontWeight.w700, color: urgent ? p.danger : p.warning)),
                const SizedBox(height: 4),
                Text('Expires ${prettyShort(m.endDate)}', style: p.body(12, color: p.textMuted)),
              ]),
              const SizedBox(width: 12),
              GoldButton(label: 'Renew', onTap: () {
                final plan = appState.membershipPlans.where((pl) => pl.id == m.planId).firstOrNull;
                if (plan != null) {
                  m.startDate = m.endDate;
                  m.endDate = m.endDate.add(Duration(days: plan.durationMonths * 30));
                  m.sessionsUsed = 0; m.sessionsTotal = plan.maxSessions;
                  appState.touch(); setState(() {});
                }
              }),
            ]));
          },
        ));
  }
}
