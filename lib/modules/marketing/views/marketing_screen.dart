import 'package:flutter/material.dart';

import '../../../core/core.dart';
import '../models/marketing_models.dart';

class MarketingScreen extends StatefulWidget {
  const MarketingScreen({super.key});
  @override
  State<MarketingScreen> createState() => _MarketingScreenState();
}

class _MarketingScreenState extends State<MarketingScreen> with SingleTickerProviderStateMixin {
  late final TabController _tab;
  @override
  void initState() { super.initState(); _tab = TabController(length: 4, vsync: this); }
  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    return ScreenScaffold(
      title: 'MARKETING',
      subtitle: 'Campaigns, promotions, coupons & engagement analytics',
      actions: [
        Container(
          height: 42,
          decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: p.border)),
          child: TabBar(
            controller: _tab, isScrollable: true, dividerColor: Colors.transparent,
            indicatorColor: p.gold, indicatorSize: TabBarIndicatorSize.label,
            labelStyle: p.body(12.5, weight: FontWeight.w600),
            unselectedLabelStyle: p.body(12.5),
            labelColor: p.gold, unselectedLabelColor: p.textMuted,
            tabAlignment: TabAlignment.start,
            tabs: const [Tab(text: 'Campaigns'), Tab(text: 'Promotions'), Tab(text: 'Coupons'), Tab(text: 'Analytics')],
          ),
        ),
      ],
      child: EagerTabBarView(controller: _tab, children: const [
        _CampaignsTab(), _PromotionsTab(), _CouponsTab(), _AnalyticsTab(),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// CAMPAIGNS TAB
// ══════════════════════════════════════════════════════════════════════════════
class _CampaignsTab extends StatefulWidget {
  const _CampaignsTab();
  @override
  State<_CampaignsTab> createState() => _CampaignsTabState();
}

class _CampaignsTabState extends State<_CampaignsTab> {
  String _q = '';
  CampaignType? _typeFilter;
  CampaignStatus? _statusFilter;

  void _showCampaignForm({Campaign? existing}) {
    final editing = existing != null;
    final p = appState.palette;
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final msgCtrl = TextEditingController(text: existing?.message ?? '');
    final budgetCtrl = TextEditingController(text: existing != null ? existing.budget.toStringAsFixed(0) : '');
    var type = existing?.type ?? CampaignType.sms;
    var target = existing?.target ?? CampaignTarget.allPatients;
    var status = existing?.status ?? CampaignStatus.draft;
    DateTime scheduled = existing?.scheduledAt ?? DateTime.now().add(const Duration(days: 1));
    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, ss) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 620, padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: p.border)),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(editing ? 'EDIT CAMPAIGN' : 'CREATE CAMPAIGN', style: p.display(22, spacing: 1.0)),
          const SizedBox(height: 20),
          FormField2(label: 'Campaign Name *', controller: nameCtrl, hint: 'e.g. Eid Special FUE Offer'),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: Dropdown2<CampaignType>(label: 'Type', value: type, items: CampaignType.values.map((t) => DropdownMenuItem(value: t, child: Row(children: [Icon(_typeIcon(t), size: 15, color: p.gold), const SizedBox(width: 8), Text(t.label)]))).toList(), onChanged: (v) => ss(() => type = v ?? type))),
            const SizedBox(width: 16),
            Expanded(child: Dropdown2<CampaignTarget>(label: 'Audience', value: target, items: CampaignTarget.values.map((t) => DropdownMenuItem(value: t, child: Text(t.label))).toList(), onChanged: (v) => ss(() => target = v ?? target))),
          ]),
          const SizedBox(height: 16),
          FormField2(label: 'Message / Content *', controller: msgCtrl, hint: _msgHint(type), maxLines: 5),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: FormField2(label: 'Budget (PKR)', controller: budgetCtrl, hint: 'e.g. 25000', keyboard: TextInputType.number)),
            const SizedBox(width: 16),
            Expanded(child: Dropdown2<CampaignStatus>(label: 'Status', value: status, items: CampaignStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.label))).toList(), onChanged: (v) => ss(() => status = v ?? status))),
          ]),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            GhostButton(label: 'Cancel', onTap: () => Navigator.pop(ctx)),
            const SizedBox(width: 12),
            GoldButton(label: editing ? 'Save Changes' : 'Save Campaign', onTap: () {
              if (nameCtrl.text.isEmpty) return;
              if (editing) {
                existing!.name = nameCtrl.text;
                existing.type = type;
                existing.target = target;
                existing.message = msgCtrl.text;
                existing.status = status;
                existing.budget = double.tryParse(budgetCtrl.text) ?? existing.budget;
                existing.scheduledAt = scheduled;
                appState.updateCampaign(existing);
              } else {
                appState.addCampaign(Campaign(id: appState.createCampaignId(), name: nameCtrl.text, type: type, target: target, message: msgCtrl.text, status: status, budget: double.tryParse(budgetCtrl.text) ?? 0, scheduledAt: scheduled, sentCount: 0, deliveredCount: 0, readCount: 0, responseCount: 0, createdAt: DateTime.now()));
              }
              Navigator.pop(ctx); setState(() {});
            }),
          ]),
        ]),
      ),
    )));
  }

  IconData _typeIcon(CampaignType t) => switch (t) {
    CampaignType.sms => Icons.sms_outlined, CampaignType.whatsapp => Icons.chat_outlined,
    CampaignType.email => Icons.email_outlined, CampaignType.push => Icons.notifications_outlined,
    CampaignType.social => Icons.share_outlined,
  };
  void _showCampaignDetail(Campaign c) {
    final p = appState.palette;
    showDialog(context: context, builder: (_) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 600, padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: p.border)),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: p.gold.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)), child: Icon(_typeIcon(c.type), size: 22, color: p.gold)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(c.name, style: p.display(22, spacing: 0.5)),
              const SizedBox(height: 4),
              Wrap(spacing: 8, children: [StatusChip(label: c.type.label, color: p.info), StatusChip(label: c.target.label, color: p.textMuted), StatusChip(label: c.status.label, color: _statusColor(p, c))]),
            ])),
            GestureDetector(onTap: () => Navigator.pop(context), child: MouseRegion(cursor: SystemMouseCursors.click, child: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(8)), child: Icon(Icons.close, size: 18, color: p.textMuted)))),
          ]),
          const SizedBox(height: 20),
          Container(
            width: double.infinity, padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(8), border: Border.all(color: p.border)),
            child: Text(c.message.isEmpty ? 'No message content yet.' : c.message, style: p.body(13, color: p.textMuted)),
          ),
          if (c.sentCount > 0) ...[
            const SizedBox(height: 20),
            Row(children: [
              _StatPill('Sent', c.sentCount, p.text, p),
              _StatPill('Delivered', c.deliveredCount, p.success, p),
              _StatPill('Read', c.readCount, p.info, p),
              _StatPill('Responses', c.responseCount, p.gold, p),
            ]),
            const SizedBox(height: 14),
            Row(children: [
              Text('Delivery Rate', style: p.body(12, color: p.textMuted)),
              const Spacer(),
              Text('${(c.deliveryRate * 100).toInt()}%', style: p.body(13, color: p.success, weight: FontWeight.w700)),
            ]),
            const SizedBox(height: 6),
            ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: c.deliveryRate, backgroundColor: p.surfaceAlt, color: p.success, minHeight: 6)),
          ],
          const SizedBox(height: 20),
          Row(children: [
            Icon(Icons.payments_outlined, size: 14, color: p.gold),
            const SizedBox(width: 8),
            Text('Budget: ${money(c.budget)}', style: p.body(13, color: p.gold, weight: FontWeight.w600)),
            const Spacer(),
            GhostButton(label: 'Close', onTap: () => Navigator.pop(context)),
            const SizedBox(width: 10),
            GoldButton(label: 'Edit', icon: Icons.edit_outlined, onTap: () { Navigator.pop(context); _showCampaignForm(existing: c); }),
          ]),
        ]),
      ),
    ));
  }

  Color _statusColor(AppPalette p, Campaign c) => switch (c.status) {
    CampaignStatus.draft => p.textMuted, CampaignStatus.scheduled => p.info,
    CampaignStatus.active => p.success, CampaignStatus.paused => p.warning,
    CampaignStatus.completed => p.gold, CampaignStatus.cancelled => p.danger,
  };

  String _msgHint(CampaignType t) => switch (t) {
    CampaignType.sms => 'Short SMS message (max 160 chars)...',
    CampaignType.whatsapp => 'WhatsApp message with formatting support...',
    CampaignType.email => 'Email body content (HTML supported)...',
    _ => 'Campaign message...',
  };

  @override
  Widget build(BuildContext context) {
    var list = appState.campaigns;
    if (_q.isNotEmpty) list = list.where((c) => c.name.toLowerCase().contains(_q.toLowerCase())).toList();
    if (_typeFilter != null) list = list.where((c) => c.type == _typeFilter).toList();
    if (_statusFilter != null) list = list.where((c) => c.status == _statusFilter).toList();
    return Column(children: [
      FilterBar(
        searchHint: 'Search campaigns…',
        onSearch: (v) => setState(() => _q = v),
        filters: [
          FilterDropdown<CampaignType?>(value: _typeFilter, icon: Icons.campaign_outlined, items: [const DropdownMenuItem(value: null, child: Text('All Types')), ...CampaignType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.label)))], onChanged: (v) => setState(() => _typeFilter = v)),
          FilterDropdown<CampaignStatus?>(value: _statusFilter, icon: Icons.info_outline, items: [const DropdownMenuItem(value: null, child: Text('All Statuses')), ...CampaignStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.label)))], onChanged: (v) => setState(() => _statusFilter = v)),
        ],
        countText: '${list.length} campaigns',
        onClear: () => setState(() { _q = ''; _typeFilter = null; _statusFilter = null; }),
        trailing: [GoldButton(label: 'Create Campaign', icon: Icons.add, onTap: () => _showCampaignForm())],
      ),
      const SizedBox(height: 12),
      Expanded(child: ScrollArea(builder: (sc) => SingleChildScrollView(controller: sc, child: Wrap(spacing: 18, runSpacing: 18, children: list.map((c) => _CampaignCard(c: c, onUpdate: () => setState(() {}), onEdit: () => _showCampaignForm(existing: c), onTap: () => _showCampaignDetail(c))).toList())))),
    ]);
  }
}

class _CampaignCard extends StatelessWidget {
  final Campaign c;
  final VoidCallback onUpdate;
  final VoidCallback onEdit;
  final VoidCallback onTap;
  const _CampaignCard({required this.c, required this.onUpdate, required this.onEdit, required this.onTap});

  IconData _typeIcon(CampaignType t) => switch (t) {
    CampaignType.sms => Icons.sms_outlined, CampaignType.whatsapp => Icons.chat_outlined,
    CampaignType.email => Icons.email_outlined, CampaignType.push => Icons.notifications_outlined,
    CampaignType.social => Icons.share_outlined,
  };
  Color _statusColor(AppPalette p) => switch (c.status) {
    CampaignStatus.draft => p.textMuted, CampaignStatus.scheduled => p.info,
    CampaignStatus.active => p.success, CampaignStatus.paused => p.warning,
    CampaignStatus.completed => p.gold, CampaignStatus.cancelled => p.danger,
  };

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    return SizedBox(width: 380, child: MouseRegion(cursor: SystemMouseCursors.click, child: GestureDetector(onTap: onTap, child: Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: p.gold.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)), child: Icon(_typeIcon(c.type), size: 20, color: p.gold)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(c.name, style: p.body(14.5, weight: FontWeight.w700), maxLines: 2, overflow: TextOverflow.ellipsis),
          Row(children: [StatusChip(label: c.type.label, color: p.info), const SizedBox(width: 6), StatusChip(label: c.target.label, color: p.textMuted)]),
        ])),
        StatusChip(label: c.status.label, color: _statusColor(p)),
      ]),
      const SizedBox(height: 14),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(8)),
        child: Text(c.message.isEmpty ? '—' : c.message, style: p.body(12.5, color: p.textMuted), maxLines: 3, overflow: TextOverflow.ellipsis),
      ),
      if (c.sentCount > 0) ...[
        const SizedBox(height: 14),
        Row(children: [
          _StatPill('Sent', c.sentCount, p.text, p),
          _StatPill('Delivered', c.deliveredCount, p.success, p),
          _StatPill('Read', c.readCount, p.info, p),
          _StatPill('Response', c.responseCount, p.gold, p),
        ]),
        const SizedBox(height: 10),
        Text('Delivery ${(c.deliveryRate * 100).toInt()}%', style: p.body(11.5, color: p.textMuted)),
        const SizedBox(height: 4),
        ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: c.deliveryRate, backgroundColor: p.surfaceAlt, color: p.success, minHeight: 6)),
      ],
      const SizedBox(height: 14),
      Row(children: [
        Text(money(c.budget), style: p.body(13, color: p.gold, weight: FontWeight.w600)),
        const Spacer(),
        GestureDetector(onTap: onEdit, child: MouseRegion(cursor: SystemMouseCursors.click, child: Container(width: 30, height: 30, decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(8)), child: Icon(Icons.edit_outlined, size: 15, color: p.text)))),
        const SizedBox(width: 8),
        if (c.status == CampaignStatus.draft) GoldButton(label: 'Schedule', dense: true, onTap: () { c.status = CampaignStatus.scheduled; onUpdate(); }),
        if (c.status == CampaignStatus.scheduled) GoldButton(label: 'Launch', dense: true, onTap: () { c.status = CampaignStatus.active; c.sentCount = 240 + (c.target == CampaignTarget.hotLeads ? -100 : 0); c.deliveredCount = (c.sentCount * 0.95).toInt(); c.readCount = (c.sentCount * 0.68).toInt(); c.responseCount = (c.sentCount * 0.12).toInt(); onUpdate(); }),
        if (c.status == CampaignStatus.active) GhostButton(label: 'Pause', onTap: () { c.status = CampaignStatus.paused; onUpdate(); }),
      ]),
    ])))));
  }
}

Widget _StatPill(String label, int val, Color color, AppPalette p) => Expanded(child: Column(children: [
  Text('$val', style: p.body(15, color: color, weight: FontWeight.w700)),
  Text(label, style: p.body(10.5, color: p.textMuted)),
]));

// ══════════════════════════════════════════════════════════════════════════════
// PROMOTIONS TAB
// ══════════════════════════════════════════════════════════════════════════════
class _PromotionsTab extends StatefulWidget {
  const _PromotionsTab();
  @override
  State<_PromotionsTab> createState() => _PromotionsTabState();
}

class _PromotionsTabState extends State<_PromotionsTab> {
  bool? _activeFilter;

  void _showPromoForm({Promotion? existing}) {
    final editing = existing != null;
    final p = appState.palette;
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    final valCtrl = TextEditingController(text: existing != null ? existing.discountValue.toStringAsFixed(0) : '');
    final servCtrl = TextEditingController(text: existing?.applicableServices.join(', ') ?? '');
    var dtype = existing?.discountType ?? DiscountType.percentage;
    DateTime start = existing?.startDate ?? DateTime.now();
    DateTime end = existing?.endDate ?? DateTime.now().add(const Duration(days: 30));
    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, ss) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 560, padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: p.border)),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(editing ? 'EDIT PROMOTION' : 'ADD PROMOTION', style: p.display(22, spacing: 1.0)),
          const SizedBox(height: 20),
          FormField2(label: 'Promotion Name *', controller: nameCtrl, hint: 'e.g. Ramadan Discount'),
          const SizedBox(height: 16),
          FormField2(label: 'Description', controller: descCtrl, hint: 'Promotion details and terms...', maxLines: 2),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: Dropdown2<DiscountType>(label: 'Discount Type', value: dtype, items: DiscountType.values.map((d) => DropdownMenuItem(value: d, child: Text(d.label))).toList(), onChanged: (v) => ss(() => dtype = v ?? dtype))),
            const SizedBox(width: 16),
            Expanded(child: FormField2(label: dtype == DiscountType.percentage ? 'Discount %' : 'Discount Amount (PKR)', controller: valCtrl, hint: dtype == DiscountType.percentage ? 'e.g. 20' : 'e.g. 5000', keyboard: TextInputType.number)),
          ]),
          const SizedBox(height: 16),
          FormField2(label: 'Applicable Services', controller: servCtrl, hint: 'e.g. FUE Transplant, PRP Therapy'),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: _DatePicker2(label: 'Start Date', value: start, palette: p, onPick: (d) => ss(() => start = d))),
            const SizedBox(width: 16),
            Expanded(child: _DatePicker2(label: 'End Date', value: end, palette: p, onPick: (d) => ss(() => end = d))),
          ]),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            GhostButton(label: 'Cancel', onTap: () => Navigator.pop(ctx)),
            const SizedBox(width: 12),
            GoldButton(label: editing ? 'Save Changes' : 'Save Promotion', onTap: () {
              if (nameCtrl.text.isEmpty) return;
              final services = servCtrl.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
              if (editing) {
                existing!.name = nameCtrl.text;
                existing.description = descCtrl.text;
                existing.discountType = dtype;
                existing.discountValue = double.tryParse(valCtrl.text) ?? existing.discountValue;
                existing.applicableServices = services;
                existing.startDate = start;
                existing.endDate = end;
                appState.updatePromotion(existing);
              } else {
                appState.addPromotion(Promotion(id: appState.createPromoId(), name: nameCtrl.text, description: descCtrl.text, discountType: dtype, discountValue: double.tryParse(valCtrl.text) ?? 0, applicableServices: services, startDate: start, endDate: end, isActive: true, createdBy: appState.currentUser?.name ?? 'Admin', createdAt: DateTime.now()));
              }
              Navigator.pop(ctx); setState(() {});
            }),
          ]),
        ]),
      ),
    )));
  }

  void _showPromoDetail(Promotion pr) {
    final p = appState.palette;
    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, ss) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 520, padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: p.border)),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: p.gold.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
              child: Column(children: [
                Text(pr.discountLabel, style: p.display(28, color: p.gold)),
                Text('OFF', style: p.body(11, color: p.gold, weight: FontWeight.w700, spacing: 1.5)),
              ]),
            ),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(pr.name, style: p.display(22, spacing: 0.3)),
              const SizedBox(height: 6),
              StatusChip(label: pr.isExpired ? 'Expired' : pr.isActive ? 'Active' : 'Inactive', color: pr.isExpired ? p.danger : pr.isActive ? p.success : p.textMuted),
            ])),
            GestureDetector(onTap: () => Navigator.pop(ctx), child: MouseRegion(cursor: SystemMouseCursors.click, child: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(8)), child: Icon(Icons.close, size: 18, color: p.textMuted)))),
          ]),
          const SizedBox(height: 18),
          if (pr.description.isNotEmpty) ...[
            Container(width: double.infinity, padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(8), border: Border.all(color: p.border)), child: Text(pr.description, style: p.body(13, color: p.textMuted))),
            const SizedBox(height: 14),
          ],
          if (pr.applicableServices.isNotEmpty) ...[
            Text('APPLICABLE SERVICES', style: p.body(11, color: p.textMuted, weight: FontWeight.w700, spacing: 0.8)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 6, children: pr.applicableServices.map((s) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(6), border: Border.all(color: p.border)), child: Text(s, style: p.body(12)))).toList()),
            const SizedBox(height: 14),
          ],
          Row(children: [Icon(Icons.date_range_outlined, size: 14, color: p.textMuted), const SizedBox(width: 8), Text('${prettyShort(pr.startDate)} – ${prettyShort(pr.endDate)}', style: p.body(12.5, color: p.textMuted))]),
          const SizedBox(height: 20),
          Row(children: [
            GestureDetector(
              onTap: () { pr.isActive = !pr.isActive; appState.touch(); ss(() {}); setState(() {}); },
              child: MouseRegion(cursor: SystemMouseCursors.click, child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(color: (pr.isActive ? p.danger : p.success).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8), border: Border.all(color: (pr.isActive ? p.danger : p.success).withValues(alpha: 0.3))),
                child: Text(pr.isActive ? 'Deactivate' : 'Activate', style: p.body(13, color: pr.isActive ? p.danger : p.success, weight: FontWeight.w600)),
              )),
            ),
            const Spacer(),
            GhostButton(label: 'Close', onTap: () => Navigator.pop(ctx)),
            const SizedBox(width: 10),
            GoldButton(label: 'Edit', icon: Icons.edit_outlined, onTap: () { Navigator.pop(ctx); _showPromoForm(existing: pr); }),
          ]),
        ]),
      ),
    )));
  }

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    var list = appState.promotions;
    if (_activeFilter != null) list = list.where((pr) => _activeFilter! ? (!pr.isExpired && pr.isActive) : (pr.isExpired || !pr.isActive)).toList();
    return Column(children: [
      FilterBar(
        searchHint: '',
        onSearch: (_) {},
        filters: [
          FilterDropdown<bool?>(value: _activeFilter, icon: Icons.toggle_on_outlined, items: const [DropdownMenuItem(value: null, child: Text('All Statuses')), DropdownMenuItem(value: true, child: Text('Active')), DropdownMenuItem(value: false, child: Text('Inactive / Expired'))], onChanged: (v) => setState(() => _activeFilter = v)),
        ],
        countText: '${list.length} promotions',
        onClear: () => setState(() => _activeFilter = null),
        trailing: [GoldButton(label: 'Add Promotion', icon: Icons.add, onTap: () => _showPromoForm())],
      ),
      const SizedBox(height: 12),
      Expanded(child: ScrollArea(builder: (sc) => ListView.builder(controller: sc, itemCount: list.length, itemBuilder: (_, i) {
        final pr = list[i];
        return MouseRegion(cursor: SystemMouseCursors.click, child: GestureDetector(onTap: () => _showPromoDetail(pr), child: Panel(padding: const EdgeInsets.all(18), child: Row(children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: p.gold.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
            child: Column(children: [
              Text(pr.discountLabel, style: p.display(28, color: p.gold)),
              Text('OFF', style: p.body(11, color: p.gold, weight: FontWeight.w700, spacing: 1.5)),
            ]),
          ),
          const SizedBox(width: 18),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(pr.name, style: p.body(15, weight: FontWeight.w700)),
              const Spacer(),
              StatusChip(label: pr.isExpired ? 'Expired' : 'Active', color: pr.isExpired ? p.danger : p.success),
            ]),
            const SizedBox(height: 6),
            Text(pr.description, style: p.body(12.5, color: p.textMuted)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 6, children: pr.applicableServices.map((s) => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(6), border: Border.all(color: p.border)), child: Text(s, style: p.body(11.5)))).toList()),
            const SizedBox(height: 8),
            Row(children: [
              Icon(Icons.date_range_outlined, size: 14, color: p.textMuted),
              const SizedBox(width: 6),
              Text('${prettyShort(pr.startDate)} – ${prettyShort(pr.endDate)}', style: p.body(12.5, color: p.textMuted)),
            ]),
          ])),
          const SizedBox(width: 12),
          Column(children: [
            GoldButton(label: 'Edit', icon: Icons.edit_outlined, dense: true, onTap: () => _showPromoForm(existing: pr)),
            const SizedBox(height: 8),
            GhostButton(label: pr.isActive ? 'Deactivate' : 'Activate', onTap: () { pr.isActive = !pr.isActive; appState.touch(); setState(() {}); }),
          ]),
        ]))));
      }))),
    ]);
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// COUPONS TAB
// ══════════════════════════════════════════════════════════════════════════════
class _CouponsTab extends StatefulWidget {
  const _CouponsTab();
  @override
  State<_CouponsTab> createState() => _CouponsTabState();
}

class _CouponsTabState extends State<_CouponsTab> {
  String _q = '';
  String? _statusFilter;

  void _showCouponForm({Coupon? existing}) {
    final editing = existing != null;
    final p = appState.palette;
    final codeCtrl = TextEditingController(text: existing?.code ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    final valCtrl = TextEditingController(text: existing != null ? existing.discountValue.toStringAsFixed(0) : '');
    final minCtrl = TextEditingController(text: existing != null ? existing.minimumOrderAmount.toStringAsFixed(0) : '');
    final maxCtrl = TextEditingController(text: existing?.maximumDiscountAmount != null ? existing!.maximumDiscountAmount!.toStringAsFixed(0) : '');
    var dtype = existing?.discountType ?? DiscountType.percentage;
    var usageLimit = existing?.usageLimit ?? 100;
    DateTime expiry = existing?.expiryDate ?? DateTime.now().add(const Duration(days: 60));
    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, ss) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 580, padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: p.border)),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(editing ? 'EDIT COUPON' : 'CREATE COUPON', style: p.display(22, spacing: 1.0)),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: FormField2(label: 'Coupon Code *', controller: codeCtrl, hint: 'e.g. EID2026 or HAIR15')),
            const SizedBox(width: 16),
            Expanded(child: FormField2(label: 'Description', controller: descCtrl, hint: 'What this coupon is for')),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: Dropdown2<DiscountType>(label: 'Discount Type', value: dtype, items: DiscountType.values.map((d) => DropdownMenuItem(value: d, child: Text(d.label))).toList(), onChanged: (v) => ss(() => dtype = v ?? dtype))),
            const SizedBox(width: 16),
            Expanded(child: FormField2(label: dtype == DiscountType.percentage ? 'Discount %' : 'Discount (PKR)', controller: valCtrl, hint: dtype == DiscountType.percentage ? 'e.g. 15' : 'e.g. 3000', keyboard: TextInputType.number)),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: FormField2(label: 'Min. Order (PKR)', controller: minCtrl, hint: 'e.g. 20000', keyboard: TextInputType.number)),
            const SizedBox(width: 16),
            Expanded(child: FormField2(label: 'Max. Discount (PKR)', controller: maxCtrl, hint: 'e.g. 10000 (optional)', keyboard: TextInputType.number)),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Usage Limit', style: p.body(12, color: p.textMuted, weight: FontWeight.w600)),
              const SizedBox(height: 7),
              Row(children: [
                QtyButton(Icons.remove, () => ss(() => usageLimit = (usageLimit - 10).clamp(1, 9999))),
                Expanded(child: Center(child: Text('$usageLimit', style: p.body(15, weight: FontWeight.w700)))),
                QtyButton(Icons.add, () => ss(() => usageLimit += 10)),
              ]),
            ])),
            const SizedBox(width: 16),
            Expanded(child: _DatePicker2(label: 'Expiry Date', value: expiry, palette: p, onPick: (d) => ss(() => expiry = d))),
          ]),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            GhostButton(label: 'Cancel', onTap: () => Navigator.pop(ctx)),
            const SizedBox(width: 12),
            GoldButton(label: editing ? 'Save Changes' : 'Create Coupon', onTap: () {
              if (codeCtrl.text.isEmpty) return;
              if (editing) {
                existing!.code = codeCtrl.text.toUpperCase().trim();
                existing.description = descCtrl.text;
                existing.discountType = dtype;
                existing.discountValue = double.tryParse(valCtrl.text) ?? existing.discountValue;
                existing.minimumOrderAmount = double.tryParse(minCtrl.text) ?? existing.minimumOrderAmount;
                existing.maximumDiscountAmount = double.tryParse(maxCtrl.text);
                existing.usageLimit = usageLimit;
                existing.expiryDate = expiry;
                appState.updateCoupon(existing);
              } else {
                appState.addCoupon(Coupon(id: appState.createCouponId(), code: codeCtrl.text.toUpperCase().trim(), description: descCtrl.text, discountType: dtype, discountValue: double.tryParse(valCtrl.text) ?? 0, minimumOrderAmount: double.tryParse(minCtrl.text) ?? 0, maximumDiscountAmount: double.tryParse(maxCtrl.text), usageLimit: usageLimit, usageCount: 0, expiryDate: expiry, isActive: true));
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
    var list = appState.coupons;
    if (_q.isNotEmpty) list = list.where((c) => c.code.toLowerCase().contains(_q.toLowerCase()) || c.description.toLowerCase().contains(_q.toLowerCase())).toList();
    if (_statusFilter == 'active') list = list.where((c) => c.isValid).toList();
    else if (_statusFilter == 'inactive') list = list.where((c) => !c.isActive).toList();
    else if (_statusFilter == 'expired') list = list.where((c) => c.isExpired).toList();
    return Column(children: [
      FilterBar(
        searchHint: 'Search coupon code or description…',
        onSearch: (v) => setState(() => _q = v),
        filters: [
          FilterDropdown<String?>(value: _statusFilter, icon: Icons.toggle_on_outlined, items: const [DropdownMenuItem(value: null, child: Text('All Statuses')), DropdownMenuItem(value: 'active', child: Text('Active')), DropdownMenuItem(value: 'inactive', child: Text('Inactive')), DropdownMenuItem(value: 'expired', child: Text('Expired'))], onChanged: (v) => setState(() => _statusFilter = v)),
        ],
        countText: '${list.length} coupons',
        onClear: () => setState(() { _q = ''; _statusFilter = null; }),
        trailing: [GoldButton(label: 'Create Coupon', icon: Icons.add, onTap: () => _showCouponForm())],
      ),
      const SizedBox(height: 12),
      Expanded(child: Panel(padding: EdgeInsets.zero, child: ScrollArea(builder: (sc) {
        return SingleChildScrollView(controller: sc, child: FullWidthDataTable(child: DataTable(
            headingRowColor: WidgetStateProperty.all(p.surfaceAlt),
            columnSpacing: 16, horizontalMargin: 20,
            columns: [
              DataColumn(label: Text('Code', style: p.body(12, weight: FontWeight.w700))),
              DataColumn(label: Text('Description', style: p.body(12, weight: FontWeight.w700))),
              DataColumn(label: Text('Discount', style: p.body(12, weight: FontWeight.w700))),
              DataColumn(label: Text('Min. Order', style: p.body(12, weight: FontWeight.w700))),
              DataColumn(label: Text('Used', style: p.body(12, weight: FontWeight.w700))),
              DataColumn(label: Text('Expiry', style: p.body(12, weight: FontWeight.w700))),
              DataColumn(label: Text('Status', style: p.body(12, weight: FontWeight.w700))),
              DataColumn(label: Text('Action', style: p.body(12, weight: FontWeight.w700))),
            ],
            rows: list.map((c) => DataRow(cells: [
              DataCell(Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: p.gold.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6), border: Border.all(color: p.gold.withValues(alpha: 0.3))),
                child: Text(c.code, style: p.body(13, color: p.gold, weight: FontWeight.w800, spacing: 1.5)),
              )),
              DataCell(Text(c.description, style: p.body(12.5))),
              DataCell(Text(c.discountLabel, style: p.body(13, weight: FontWeight.w600, color: p.success))),
              DataCell(Text(money(c.minimumOrderAmount), style: p.body(12.5))),
              DataCell(Text('${c.usageCount}/${c.usageLimit}', style: p.body(12.5))),
              DataCell(Text(prettyShort(c.expiryDate), style: p.body(12.5, color: c.isExpired ? p.danger : p.textMuted))),
              DataCell(StatusChip(label: !c.isActive ? 'Inactive' : c.isExpired ? 'Expired' : c.isUsageLimitReached ? 'Exhausted' : 'Active', color: !c.isActive || c.isExpired || c.isUsageLimitReached ? p.danger : p.success)),
              DataCell(Row(mainAxisSize: MainAxisSize.min, children: [
                GestureDetector(onTap: () => _showCouponForm(existing: c), child: MouseRegion(cursor: SystemMouseCursors.click, child: Container(width: 30, height: 30, decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(8)), child: Icon(Icons.edit_outlined, size: 15, color: p.text)))),
                const SizedBox(width: 6),
                GestureDetector(onTap: () { c.isActive = !c.isActive; appState.touch(); setState(() {}); }, child: MouseRegion(cursor: SystemMouseCursors.click, child: Container(width: 30, height: 30, decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(8)), child: Icon(c.isActive ? Icons.toggle_on_outlined : Icons.toggle_off_outlined, size: 20, color: c.isActive ? p.success : p.textMuted)))),
                const SizedBox(width: 6),
                GestureDetector(onTap: () { appState.deleteCoupon(c); setState(() {}); }, child: MouseRegion(cursor: SystemMouseCursors.click, child: Container(width: 30, height: 30, decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(8)), child: Icon(Icons.delete_outline, size: 15, color: p.textMuted)))),
              ])),
            ])).toList(),
          ),
        ));
      }))),
    ]);
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// ANALYTICS TAB
// ══════════════════════════════════════════════════════════════════════════════
class _AnalyticsTab extends StatelessWidget {
  const _AnalyticsTab();
  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final campaigns = appState.campaigns;
    final totalSent = campaigns.fold(0, (s, c) => s + c.sentCount);
    final totalDelivered = campaigns.fold(0, (s, c) => s + c.deliveredCount);
    final totalRead = campaigns.fold(0, (s, c) => s + c.readCount);
    final totalResponse = campaigns.fold(0, (s, c) => s + c.responseCount);
    return ScrollArea(builder: (sc) => SingleChildScrollView(controller: sc, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      MetricRow([
        MetricCard(title: 'Total Campaigns', value: '${campaigns.length}', delta: '${campaigns.where((c) => c.status == CampaignStatus.active).length} active', icon: Icons.campaign_outlined),
        MetricCard(title: 'Total Sent', value: '${totalSent}', delta: '${totalDelivered} delivered', icon: Icons.send_outlined),
        MetricCard(title: 'Read Rate', value: totalSent == 0 ? '0%' : '${(totalRead / totalSent * 100).toInt()}%', delta: '$totalRead opened', icon: Icons.mark_email_read_outlined),
        MetricCard(title: 'Response Rate', value: totalSent == 0 ? '0%' : '${(totalResponse / totalSent * 100).toInt()}%', delta: '$totalResponse responded', icon: Icons.reply_outlined),
      ]),
      const SizedBox(height: 24),
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('CAMPAIGN PERFORMANCE', style: p.display(18, spacing: 0.5)),
          const SizedBox(height: 16),
          ...campaigns.where((c) => c.sentCount > 0).map((c) => Padding(padding: const EdgeInsets.only(bottom: 16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Text(c.name, style: p.body(13, weight: FontWeight.w600)), const Spacer(), StatusChip(label: c.type.label, color: p.info)]),
            const SizedBox(height: 8),
            _ProgressBar('Delivered', c.deliveredCount / c.sentCount.clamp(1, 99999), p.success, p),
            const SizedBox(height: 6),
            _ProgressBar('Read', c.readCount / c.sentCount.clamp(1, 99999), p.info, p),
            const SizedBox(height: 6),
            _ProgressBar('Response', c.responseCount / c.sentCount.clamp(1, 99999), p.gold, p),
          ]))),
        ]))),
        const SizedBox(width: 18),
        SizedBox(width: 340, child: Column(children: [
          Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('BY CHANNEL', style: p.display(18, spacing: 0.5)),
            const SizedBox(height: 16),
            ...CampaignType.values.map((t) {
              final channelCampaigns = campaigns.where((c) => c.type == t);
              final sent = channelCampaigns.fold(0, (s, c) => s + c.sentCount);
              if (sent == 0) return const SizedBox.shrink();
              return Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(children: [
                Container(width: 32, height: 32, alignment: Alignment.center, decoration: BoxDecoration(color: p.gold.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)), child: Icon(_channelIcon(t), size: 16, color: p.gold)),
                const SizedBox(width: 12),
                Expanded(child: Text(t.label, style: p.body(13))),
                Text('$sent sent', style: p.body(13, color: p.textMuted)),
              ]));
            }),
          ])),
          const SizedBox(height: 18),
          Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('COUPONS SUMMARY', style: p.display(18, spacing: 0.5)),
            const SizedBox(height: 14),
            _SumRow('Total Coupons', '${appState.coupons.length}', p),
            _SumRow('Active', '${appState.coupons.where((c) => c.isValid).length}', p),
            _SumRow('Total Used', '${appState.coupons.fold(0, (s, c) => s + c.usageCount)}', p),
          ])),
        ])),
      ]),
    ])));
  }

  IconData _channelIcon(CampaignType t) => switch (t) {
    CampaignType.sms => Icons.sms_outlined, CampaignType.whatsapp => Icons.chat_outlined,
    CampaignType.email => Icons.email_outlined, CampaignType.push => Icons.notifications_outlined,
    CampaignType.social => Icons.share_outlined,
  };
}

Widget _ProgressBar(String label, double val, Color color, AppPalette p) => Row(children: [
  SizedBox(width: 80, child: Text(label, style: p.body(12, color: p.textMuted))),
  Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: val, backgroundColor: p.surfaceAlt, color: color, minHeight: 8))),
  const SizedBox(width: 8),
  Text('${(val * 100).toInt()}%', style: p.body(12, color: color, weight: FontWeight.w600)),
]);

Widget _SumRow(String label, String val, AppPalette p) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(children: [
  Text(label, style: p.body(13, color: p.textMuted)), const Spacer(),
  Text(val, style: p.body(13.5, weight: FontWeight.w700)),
]));

class _DatePicker2 extends StatelessWidget {
  final String label;
  final DateTime value;
  final AppPalette palette;
  final ValueChanged<DateTime> onPick;
  const _DatePicker2({required this.label, required this.value, required this.palette, required this.onPick});
  @override
  Widget build(BuildContext context) {
    final p = palette;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: p.body(12, color: p.textMuted, weight: FontWeight.w600)),
      const SizedBox(height: 7),
      GestureDetector(
        onTap: () async {
          final picked = await showDatePicker(context: context, initialDate: value, firstDate: DateTime(2020), lastDate: DateTime(2035),
            builder: (ctx, child) => Theme(data: ThemeData.dark().copyWith(colorScheme: ColorScheme.dark(primary: p.gold, surface: p.surface)), child: child!));
          if (picked != null) onPick(picked);
        },
        child: Container(height: 46, padding: const EdgeInsets.symmetric(horizontal: 14), decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(8), border: Border.all(color: p.border)), child: Row(children: [Icon(Icons.calendar_today_outlined, size: 15, color: p.gold), const SizedBox(width: 10), Text(prettyShort(value), style: p.body(13.5, weight: FontWeight.w500))])),
      ),
    ]);
  }
}
