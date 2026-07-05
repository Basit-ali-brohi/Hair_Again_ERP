import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../models/hair_patch_models.dart';

class HairPatchScreen extends StatefulWidget {
  const HairPatchScreen({super.key});
  @override
  State<HairPatchScreen> createState() => _HairPatchScreenState();
}

class _HairPatchScreenState extends State<HairPatchScreen> with SingleTickerProviderStateMixin {
  late final TabController _tab;
  @override
  void initState() { super.initState(); _tab = TabController(length: 4, vsync: this); }
  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    return ScreenScaffold(
      title: 'HAIR PATCH',
      subtitle: 'Catalog, custom orders, fittings & maintenance management',
      actions: [
        Container(height: 42,
          decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: p.border)),
          child: TabBar(controller: _tab, isScrollable: true, dividerColor: Colors.transparent,
            indicatorColor: p.gold, indicatorSize: TabBarIndicatorSize.label,
            labelStyle: p.body(12.5, weight: FontWeight.w600), unselectedLabelStyle: p.body(12.5),
            labelColor: p.gold, unselectedLabelColor: p.textMuted, tabAlignment: TabAlignment.start,
            tabs: const [Tab(text: 'Catalog'), Tab(text: 'Orders'), Tab(text: 'Fittings'), Tab(text: 'Maintenance')]),
        ),
      ],
      child: EagerTabBarView(controller: _tab, children: const [
        _CatalogTab(), _OrdersTab(), _FittingsTab(), _MaintenanceTab(),
      ]),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────
Color _orderStatusColor(AppPalette p, PatchOrderStatus s) => switch (s) {
  PatchOrderStatus.pending       => p.textMuted,
  PatchOrderStatus.measuring     => p.info,
  PatchOrderStatus.production    => p.warning,
  PatchOrderStatus.qualityCheck  => const Color(0xFF9B59B6),
  PatchOrderStatus.ready         => p.gold,
  PatchOrderStatus.delivered     => p.success,
  PatchOrderStatus.cancelled     => p.danger,
};
Color _fittingColor(AppPalette p, FittingStatus s) => switch (s) {
  FittingStatus.scheduled   => p.info,
  FittingStatus.completed   => p.success,
  FittingStatus.rescheduled => p.warning,
  FittingStatus.noShow      => p.danger,
};

// ══════════════════════════════════════════════════════════════════════════════
// CATALOG TAB
// ══════════════════════════════════════════════════════════════════════════════
class _CatalogTab extends StatefulWidget {
  const _CatalogTab();
  @override
  State<_CatalogTab> createState() => _CatalogTabState();
}

class _CatalogTabState extends State<_CatalogTab> {
  String _q = '';
  PatchType? _typeFilter;

  void _showForm({HairPatchItem? existing}) {
    final editing = existing != null;
    final p = appState.palette;
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final skuCtrl  = TextEditingController(text: existing?.sku ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    final colorCtrl = TextEditingController(text: existing?.baseColor ?? 'Natural Black');
    var type    = existing?.type ?? PatchType.lace;
    var origin  = existing?.hairOrigin ?? HairOrigin.human;
    var density = existing?.hairDensity ?? 'Medium';
    var texture = existing?.hairTexture ?? 'Straight';
    double lenCm = existing?.lengthCm ?? 18.0;
    double widCm = existing?.widthCm  ?? 16.0;
    double price = existing?.price    ?? 15000;
    int    stock = existing?.stockQty ?? 0;

    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, ss) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(width: 620, padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: p.border)),
        child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(editing ? 'EDIT PATCH ITEM' : 'ADD PATCH TO CATALOG', style: p.display(22, spacing: 1.0)),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: FormField2(label: 'Patch Name *', controller: nameCtrl, hint: 'e.g. Premium Lace Front — Natural Black')),
            const SizedBox(width: 14),
            SizedBox(width: 140, child: FormField2(label: 'SKU', controller: skuCtrl, hint: 'HP-001')),
          ]),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: Dropdown2<PatchType>(label: 'Base Type', value: type,
              items: PatchType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.label))).toList(),
              onChanged: (v) => ss(() => type = v ?? type))),
            const SizedBox(width: 14),
            Expanded(child: Dropdown2<HairOrigin>(label: 'Hair Origin', value: origin,
              items: HairOrigin.values.map((o) => DropdownMenuItem(value: o, child: Text(o.label))).toList(),
              onChanged: (v) => ss(() => origin = v ?? origin))),
          ]),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: Dropdown2<String>(label: 'Hair Texture', value: texture,
              items: ['Straight', 'Wavy', 'Curly', 'Deep Wave'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (v) => ss(() => texture = v ?? texture))),
            const SizedBox(width: 14),
            Expanded(child: Dropdown2<String>(label: 'Density', value: density,
              items: ['Light', 'Light-Medium', 'Medium', 'Medium-Heavy', 'Heavy'].map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
              onChanged: (v) => ss(() => density = v ?? density))),
          ]),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: FormField2(label: 'Base Color', controller: colorCtrl, hint: 'e.g. Natural Black, #1B')),
            const SizedBox(width: 14),
            Expanded(child: FormField2(label: 'Length (cm)', controller: TextEditingController(text: lenCm.toStringAsFixed(1)),
              hint: '18.0', keyboard: TextInputType.number, onChanged: (v) => lenCm = double.tryParse(v) ?? lenCm)),
            const SizedBox(width: 14),
            Expanded(child: FormField2(label: 'Width (cm)', controller: TextEditingController(text: widCm.toStringAsFixed(1)),
              hint: '16.0', keyboard: TextInputType.number, onChanged: (v) => widCm = double.tryParse(v) ?? widCm)),
          ]),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: FormField2(label: 'Price (PKR)', controller: TextEditingController(text: price.toStringAsFixed(0)),
              hint: '15000', keyboard: TextInputType.number, onChanged: (v) => price = double.tryParse(v) ?? price)),
            const SizedBox(width: 14),
            Expanded(child: FormField2(label: 'Stock Qty', controller: TextEditingController(text: '$stock'),
              hint: '0', keyboard: TextInputType.number, onChanged: (v) => stock = int.tryParse(v) ?? stock)),
          ]),
          const SizedBox(height: 14),
          FormField2(label: 'Description / Features', controller: descCtrl, hint: 'Material details, care instructions…', maxLines: 2),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            GhostButton(label: 'Cancel', onTap: () => Navigator.pop(ctx)),
            const SizedBox(width: 12),
            GoldButton(label: editing ? 'Save Changes' : 'Add to Catalog', onTap: () {
              if (nameCtrl.text.isEmpty) return;
              if (editing) {
                existing!.name = nameCtrl.text; existing.sku = skuCtrl.text;
                existing.description = descCtrl.text; existing.baseColor = colorCtrl.text;
                existing.type = type; existing.hairOrigin = origin;
                existing.hairDensity = density; existing.hairTexture = texture;
                existing.lengthCm = lenCm; existing.widthCm = widCm;
                existing.price = price; existing.stockQty = stock;
                appState.touch();
              } else {
                appState.addHairPatchItem(HairPatchItem(
                  id: appState.createHairPatchId(), name: nameCtrl.text, sku: skuCtrl.text,
                  description: descCtrl.text, type: type, hairOrigin: origin,
                  baseColor: colorCtrl.text, hairDensity: density, hairTexture: texture,
                  lengthCm: lenCm, widthCm: widCm, price: price, stockQty: stock,
                  addedOn: DateTime.now(),
                ));
              }
              Navigator.pop(ctx); setState(() {});
            }),
          ]),
        ])),
      ),
    )));
  }

  void _showDetail(HairPatchItem item) {
    final p = appState.palette;
    showDialog(context: context, builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(width: 580, padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: p.border)),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 52, height: 52, alignment: Alignment.center,
              decoration: BoxDecoration(gradient: p.goldGradient, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.content_cut, size: 24, color: Colors.white)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(item.name, style: p.display(18)),
              Text('SKU: ${item.sku} · ${item.type.label}', style: p.body(12.5, color: p.textMuted)),
            ])),
            StatusChip(label: item.isActive ? 'Active' : 'Inactive', color: item.isActive ? p.success : p.textMuted),
            const SizedBox(width: 12),
            GestureDetector(onTap: () => Navigator.pop(ctx), child: MouseRegion(cursor: SystemMouseCursors.click, child: Icon(Icons.close, size: 20, color: p.textMuted))),
          ]),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: Container(padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(12), border: Border.all(color: p.border)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('SPECIFICATIONS', style: p.body(11, weight: FontWeight.w700, spacing: 1.0, color: p.textMuted)),
                const SizedBox(height: 10),
                _specRow(p, 'Base Type', item.type.label),
                _specRow(p, 'Hair Origin', item.hairOrigin.label),
                _specRow(p, 'Texture', item.hairTexture),
                _specRow(p, 'Density', item.hairDensity),
                _specRow(p, 'Base Color', item.baseColor),
                _specRow(p, 'Size', '${item.lengthCm}cm × ${item.widthCm}cm'),
              ]))),
            const SizedBox(width: 12),
            Expanded(child: Container(padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(12), border: Border.all(color: p.border)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('PRICING & STOCK', style: p.body(11, weight: FontWeight.w700, spacing: 1.0, color: p.textMuted)),
                const SizedBox(height: 10),
                _specRow(p, 'Price', money(item.price)),
                _specRow(p, 'In Stock', '${item.stockQty} units'),
                _specRow(p, 'Stock Value', money(item.price * item.stockQty)),
                _specRow(p, 'Added On', prettyShort(item.addedOn)),
              ]))),
          ]),
          if (item.description.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text('DESCRIPTION', style: p.body(11, weight: FontWeight.w700, spacing: 1.0, color: p.textMuted)),
            const SizedBox(height: 6),
            Text(item.description, style: p.body(13)),
          ],
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            GoldButton(label: 'Edit', icon: Icons.edit_outlined, onTap: () { Navigator.pop(ctx); _showForm(existing: item); }),
            const SizedBox(width: 10),
            GhostButton(label: 'Close', onTap: () => Navigator.pop(ctx)),
          ]),
        ]),
      ),
    ));
  }

  Widget _specRow(AppPalette p, String k, String v) => Padding(padding: const EdgeInsets.only(bottom: 8),
    child: Row(children: [SizedBox(width: 90, child: Text(k, style: p.body(12, color: p.textMuted))), Expanded(child: Text(v, style: p.body(12.5, weight: FontWeight.w600)))]));

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    var list = appState.hairPatchItems;
    if (_q.isNotEmpty) list = list.where((i) => i.name.toLowerCase().contains(_q.toLowerCase()) || i.sku.toLowerCase().contains(_q.toLowerCase())).toList();
    if (_typeFilter != null) list = list.where((i) => i.type == _typeFilter).toList();

    return Column(children: [
      Row(children: [
        MetricCard(title: 'Total Items', value: '${appState.hairPatchItems.length}', icon: Icons.content_cut, delta: ''),
        const SizedBox(width: 14),
        MetricCard(title: 'In Stock', value: '${appState.hairPatchItems.where((i) => i.stockQty > 0).length}', icon: Icons.inventory_2_outlined, delta: ''),
        const SizedBox(width: 14),
        MetricCard(title: 'Catalog Value', value: money(appState.hairPatchItems.fold(0.0, (s, i) => s + i.price * i.stockQty)), icon: Icons.monetization_on_outlined, delta: ''),
      ]),
      const SizedBox(height: 16),
      FilterBar(
        searchHint: 'Search by name or SKU…', onSearch: (v) => setState(() => _q = v),
        filters: [
          FilterDropdown<PatchType?>(value: _typeFilter,
            items: [const DropdownMenuItem(value: null, child: Text('All Types')), ...PatchType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.label)))],
            onChanged: (v) => setState(() => _typeFilter = v)),
        ],
        countText: '${list.length} items', onClear: () => setState(() { _q = ''; _typeFilter = null; }),
        trailing: [GoldButton(label: 'Add Patch', icon: Icons.add, onTap: () => _showForm())],
      ),
      const SizedBox(height: 12),
      Expanded(child: list.isEmpty
        ? Center(child: Text('No patches in catalog.', style: p.body(13, color: p.textMuted)))
        : ScrollArea(builder: (sc) => GridView.builder(
            controller: sc, padding: const EdgeInsets.only(right: 8),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 380, mainAxisExtent: 240, crossAxisSpacing: 14, mainAxisSpacing: 14),
            itemCount: list.length,
            itemBuilder: (_, i) {
              final item = list[i];
              return MouseRegion(cursor: SystemMouseCursors.click, child: GestureDetector(onTap: () => _showDetail(item), child: Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(width: 44, height: 44, alignment: Alignment.center,
                    decoration: BoxDecoration(gradient: p.goldGradient, borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.content_cut, size: 20, color: Colors.white)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(item.name, style: p.body(13, weight: FontWeight.w700), maxLines: 2, overflow: TextOverflow.ellipsis),
                    Text(item.sku, style: p.body(11.5, color: p.textMuted)),
                  ])),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  StatusChip(label: item.type.label, color: p.gold),
                  const SizedBox(width: 6),
                  StatusChip(label: item.hairOrigin.label, color: p.info),
                ]),
                const SizedBox(height: 8),
                _chip(p, '${item.lengthCm}×${item.widthCm} cm'),
                const SizedBox(height: 4),
                _chip(p, '${item.hairDensity} density · ${item.hairTexture}'),
                const Spacer(),
                Row(children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(money(item.price), style: p.display(18, color: p.gold)),
                    Text('Stock: ${item.stockQty}', style: p.body(12, color: item.stockQty > 0 ? p.success : p.danger)),
                  ]),
                  const Spacer(),
                  GestureDetector(onTap: () => _showForm(existing: item), child: MouseRegion(cursor: SystemMouseCursors.click,
                    child: Container(width: 32, height: 32, decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(8)), child: Icon(Icons.edit_outlined, size: 16, color: p.text)))),
                ]),
              ]))));
            },
          ))),
    ]);
  }
  Widget _chip(AppPalette p, String t) => Row(children: [Icon(Icons.circle, size: 5, color: p.textMuted), const SizedBox(width: 6), Text(t, style: p.body(12, color: p.textMuted))]);
}

// ══════════════════════════════════════════════════════════════════════════════
// ORDERS TAB
// ══════════════════════════════════════════════════════════════════════════════
class _OrdersTab extends StatefulWidget {
  const _OrdersTab();
  @override
  State<_OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<_OrdersTab> {
  String _q = '';
  PatchOrderStatus? _statusFilter;

  void _showNewOrder() {
    final p = appState.palette;
    final patCtrl   = TextEditingController();
    final phoneCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    HairPatchItem? selectedPatch;
    bool isCustom = false;
    double advance = 0, total = 0;
    double fb = 18, ee = 16, circ = 57;
    String hairline = 'Natural', color = '#1B1B1B', texture = 'Straight', density = 'Medium';
    DateTime? delivery = DateTime.now().add(const Duration(days: 14));

    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, ss) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(width: 660, padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: p.border)),
        child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('NEW PATCH ORDER', style: p.display(22, spacing: 1.0)),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: FormField2(label: 'Patient Name *', controller: patCtrl, hint: 'Full name')),
            const SizedBox(width: 14),
            Expanded(child: FormField2(label: 'Phone *', controller: phoneCtrl, hint: '+92 3XX XXXXXXX')),
          ]),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: Dropdown2<HairPatchItem?>(label: 'Select from Catalog', value: selectedPatch,
              items: [const DropdownMenuItem<HairPatchItem?>(value: null, child: Text('— Custom Order —')),
                ...appState.hairPatchItems.where((i) => i.isActive).map((i) => DropdownMenuItem(value: i, child: Text(i.name)))],
              onChanged: (v) => ss(() { selectedPatch = v; isCustom = v == null; total = v?.price ?? 0; }))),
            const SizedBox(width: 14),
            Expanded(child: FormField2(label: 'Total Cost (PKR)', controller: TextEditingController(text: total == 0 ? '' : total.toStringAsFixed(0)),
              hint: '0', keyboard: TextInputType.number, onChanged: (v) => total = double.tryParse(v) ?? total)),
          ]),
          const SizedBox(height: 14),
          FormField2(label: 'Advance Paid (PKR)', controller: TextEditingController(text: advance == 0 ? '' : advance.toStringAsFixed(0)),
            hint: '0', keyboard: TextInputType.number, onChanged: (v) => advance = double.tryParse(v) ?? advance),
          const SizedBox(height: 18),
          Text('SCALP MEASUREMENTS', style: p.body(11, weight: FontWeight.w700, spacing: 1.0, color: p.textMuted)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: FormField2(label: 'Front to Back (cm)', controller: TextEditingController(text: fb.toStringAsFixed(1)),
              hint: '18.0', keyboard: TextInputType.number, onChanged: (v) => fb = double.tryParse(v) ?? fb)),
            const SizedBox(width: 14),
            Expanded(child: FormField2(label: 'Ear to Ear (cm)', controller: TextEditingController(text: ee.toStringAsFixed(1)),
              hint: '16.0', keyboard: TextInputType.number, onChanged: (v) => ee = double.tryParse(v) ?? ee)),
            const SizedBox(width: 14),
            Expanded(child: FormField2(label: 'Circumference (cm)', controller: TextEditingController(text: circ.toStringAsFixed(1)),
              hint: '57.0', keyboard: TextInputType.number, onChanged: (v) => circ = double.tryParse(v) ?? circ)),
          ]),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: Dropdown2<String>(label: 'Hairline Shape', value: hairline,
              items: ['Natural', 'Receded', 'M-Shape', 'Straight', 'Custom'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (v) => ss(() => hairline = v ?? hairline))),
            const SizedBox(width: 14),
            Expanded(child: FormField2(label: 'Color Code', controller: TextEditingController(text: color),
              hint: '#1B1B1B', onChanged: (v) => color = v)),
            const SizedBox(width: 14),
            Expanded(child: Dropdown2<String>(label: 'Density', value: density,
              items: ['Light', 'Medium', 'Heavy'].map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
              onChanged: (v) => ss(() => density = v ?? density))),
          ]),
          const SizedBox(height: 14),
          FormField2(label: 'Notes', controller: notesCtrl, hint: 'Additional instructions for the order…', maxLines: 2),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            GhostButton(label: 'Cancel', onTap: () => Navigator.pop(ctx)),
            const SizedBox(width: 12),
            GoldButton(label: 'Create Order', onTap: () {
              if (patCtrl.text.isEmpty || phoneCtrl.text.isEmpty) return;
              appState.addPatchOrder(PatchOrder(
                id: appState.createPatchOrderId(), patientId: '', patientName: patCtrl.text,
                patientPhone: phoneCtrl.text, patchId: selectedPatch?.id, patchName: selectedPatch?.name,
                isCustom: isCustom, measurement: PatchMeasurement(frontToBack: fb, earToEar: ee, circumference: circ,
                  hairlineShape: hairline, colorCode: color, densityPreference: density),
                advancePaid: advance, totalCost: total, orderDate: DateTime.now(),
                expectedDelivery: delivery, notes: notesCtrl.text,
              ));
              Navigator.pop(ctx); setState(() {});
            }),
          ]),
        ])),
      ),
    )));
  }

  void _showDetail(PatchOrder order) {
    final p = appState.palette;
    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, ss) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(width: 600, padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: p.border)),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(order.patientName, style: p.display(20)),
              Text('Order #${order.id} · ${order.patientPhone}', style: p.body(12.5, color: p.textMuted)),
            ])),
            StatusChip(label: order.status.label, color: _orderStatusColor(p, order.status)),
            const SizedBox(width: 12),
            GestureDetector(onTap: () => Navigator.pop(ctx), child: MouseRegion(cursor: SystemMouseCursors.click, child: Icon(Icons.close, size: 20, color: p.textMuted))),
          ]),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: Container(padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(12), border: Border.all(color: p.border)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('ORDER DETAILS', style: p.body(11, weight: FontWeight.w700, spacing: 1.0, color: p.textMuted)), const SizedBox(height: 10),
                _r(p, 'Patch', order.patchName ?? (order.isCustom ? 'Custom Order' : '—')),
                _r(p, 'Total Cost', money(order.totalCost)),
                _r(p, 'Advance', money(order.advancePaid)),
                _r(p, 'Balance', money(order.totalCost - order.advancePaid)),
                _r(p, 'Order Date', prettyShort(order.orderDate)),
                if (order.expectedDelivery != null) _r(p, 'Expected', prettyShort(order.expectedDelivery!)),
              ]))),
            const SizedBox(width: 12),
            Expanded(child: Container(padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(12), border: Border.all(color: p.border)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('MEASUREMENTS', style: p.body(11, weight: FontWeight.w700, spacing: 1.0, color: p.textMuted)), const SizedBox(height: 10),
                _r(p, 'F→B', '${order.measurement.frontToBack} cm'),
                _r(p, 'Ear→Ear', '${order.measurement.earToEar} cm'),
                _r(p, 'Circumference', '${order.measurement.circumference} cm'),
                _r(p, 'Hairline', order.measurement.hairlineShape),
                _r(p, 'Color', order.measurement.colorCode),
                _r(p, 'Density', order.measurement.densityPreference),
              ]))),
          ]),
          const SizedBox(height: 20),
          Text('UPDATE STATUS', style: p.body(11, weight: FontWeight.w700, spacing: 1.0, color: p.textMuted)),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: PatchOrderStatus.values.where((s) => s != order.status).map((s) =>
            GhostButton(label: s.label, onTap: () { order.status = s; appState.touch(); ss(() {}); setState(() {}); })
          ).toList()),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [GhostButton(label: 'Close', onTap: () => Navigator.pop(ctx))]),
        ]),
      ),
    )));
  }

  Widget _r(AppPalette p, String k, String v) => Padding(padding: const EdgeInsets.only(bottom: 7), child: Row(children: [SizedBox(width: 100, child: Text(k, style: p.body(12, color: p.textMuted))), Expanded(child: Text(v, style: p.body(12.5, weight: FontWeight.w600)))]));

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    var list = appState.patchOrders;
    if (_q.isNotEmpty) list = list.where((o) => o.patientName.toLowerCase().contains(_q.toLowerCase()) || o.id.contains(_q)).toList();
    if (_statusFilter != null) list = list.where((o) => o.status == _statusFilter).toList();

    return Column(children: [
      Row(children: [
        MetricCard(title: 'Total Orders', value: '${appState.patchOrders.length}', icon: Icons.receipt_long_outlined, delta: ''),
        const SizedBox(width: 14),
        MetricCard(title: 'In Progress', value: '${appState.patchOrders.where((o) => o.status != PatchOrderStatus.delivered && o.status != PatchOrderStatus.cancelled).length}', icon: Icons.hourglass_top_outlined, delta: ''),
        const SizedBox(width: 14),
        MetricCard(title: 'Ready to Deliver', value: '${appState.patchOrders.where((o) => o.status == PatchOrderStatus.ready).length}', icon: Icons.check_circle_outline, delta: ''),
      ]),
      const SizedBox(height: 16),
      FilterBar(
        searchHint: 'Search by patient or order ID…', onSearch: (v) => setState(() => _q = v),
        filters: [FilterDropdown<PatchOrderStatus?>(value: _statusFilter,
          items: [const DropdownMenuItem(value: null, child: Text('All Statuses')), ...PatchOrderStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.label)))],
          onChanged: (v) => setState(() => _statusFilter = v))],
        countText: '${list.length} orders', onClear: () => setState(() { _q = ''; _statusFilter = null; }),
        trailing: [GoldButton(label: 'New Order', icon: Icons.add, onTap: _showNewOrder)],
      ),
      const SizedBox(height: 12),
      Expanded(child: list.isEmpty
        ? Center(child: Text('No patch orders found.', style: p.body(13, color: p.textMuted)))
        : Panel(padding: EdgeInsets.zero, child: ScrollArea(builder: (sc) => SingleChildScrollView(controller: sc,
            child: FullWidthDataTable(child: DataTable(
              headingRowColor: WidgetStateProperty.all(p.surfaceAlt), columnSpacing: 18, horizontalMargin: 20,
              columns: ['Order ID', 'Patient', 'Phone', 'Patch / Type', 'Total', 'Advance', 'Balance', 'Order Date', 'Expected', 'Status'].map((t) => DataColumn(label: Text(t, style: p.body(12, weight: FontWeight.w700)))).toList(),
              rows: list.map((o) => DataRow(
                onSelectChanged: (_) => _showDetail(o),
                color: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.hovered) ? p.surfaceAlt : Colors.transparent),
                cells: [
                  DataCell(Text(o.id, style: p.body(12.5, color: p.textMuted))),
                  DataCell(Text(o.patientName, style: p.body(13, weight: FontWeight.w600, color: p.gold))),
                  DataCell(Text(o.patientPhone, style: p.body(12.5))),
                  DataCell(Text(o.patchName ?? (o.isCustom ? 'Custom' : '—'), style: p.body(12.5))),
                  DataCell(Text(money(o.totalCost), style: p.body(12.5, weight: FontWeight.w600))),
                  DataCell(Text(money(o.advancePaid), style: p.body(12.5, color: p.success))),
                  DataCell(Text(money(o.totalCost - o.advancePaid), style: p.body(12.5, color: p.danger))),
                  DataCell(Text(prettyShort(o.orderDate), style: p.body(12.5))),
                  DataCell(Text(o.expectedDelivery != null ? prettyShort(o.expectedDelivery!) : '—', style: p.body(12.5))),
                  DataCell(StatusChip(label: o.status.label, color: _orderStatusColor(p, o.status))),
                ],
              )).toList(),
            )))))),
    ]);
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// FITTINGS TAB
// ══════════════════════════════════════════════════════════════════════════════
class _FittingsTab extends StatefulWidget {
  const _FittingsTab();
  @override
  State<_FittingsTab> createState() => _FittingsTabState();
}

class _FittingsTabState extends State<_FittingsTab> {
  FittingStatus? _statusFilter;

  void _showSchedule() {
    final p = appState.palette;
    final patCtrl   = TextEditingController();
    final phoneCtrl = TextEditingController();
    final techCtrl  = TextEditingController();
    final notesCtrl = TextEditingController();
    String? patchName;
    DateTime date = DateTime.now().add(const Duration(days: 2));

    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, ss) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(width: 500, padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: p.border)),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('SCHEDULE FITTING', style: p.display(22, spacing: 1.0)),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: FormField2(label: 'Patient Name *', controller: patCtrl, hint: 'Full name')),
            const SizedBox(width: 14),
            Expanded(child: FormField2(label: 'Phone', controller: phoneCtrl, hint: '+92 ...')),
          ]),
          const SizedBox(height: 14),
          FormField2(label: 'Patch / Item Name', controller: TextEditingController(), hint: 'Which patch is being fitted?',
            onChanged: (v) => patchName = v),
          const SizedBox(height: 14),
          FormField2(label: 'Technician', controller: techCtrl, hint: 'Assigned technician name'),
          const SizedBox(height: 14),
          _DatePickerRow(label: 'Fitting Date', value: date, palette: p, onPick: (d) => ss(() => date = d)),
          const SizedBox(height: 14),
          FormField2(label: 'Notes', controller: notesCtrl, hint: 'Pre-fitting instructions…', maxLines: 2),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            GhostButton(label: 'Cancel', onTap: () => Navigator.pop(ctx)),
            const SizedBox(width: 12),
            GoldButton(label: 'Schedule', onTap: () {
              if (patCtrl.text.isEmpty) return;
              appState.addPatchFitting(PatchFitting(
                id: appState.createFittingId(), patientId: '', patientName: patCtrl.text,
                patientPhone: phoneCtrl.text, patchName: patchName, scheduledDate: date,
                technicianName: techCtrl.text, notes: notesCtrl.text,
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
    var list = appState.patchFittings;
    if (_statusFilter != null) list = list.where((f) => f.status == _statusFilter).toList();
    list = List.from(list)..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));

    return Column(children: [
      FilterBar(searchHint: 'Search fittings…', onSearch: (_) {},
        filters: [FilterDropdown<FittingStatus?>(value: _statusFilter,
          items: [const DropdownMenuItem(value: null, child: Text('All Statuses')), ...FittingStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.label)))],
          onChanged: (v) => setState(() => _statusFilter = v))],
        countText: '${list.length} fittings', onClear: () => setState(() => _statusFilter = null),
        trailing: [GoldButton(label: 'Schedule Fitting', icon: Icons.add, onTap: _showSchedule)]),
      const SizedBox(height: 12),
      Expanded(child: list.isEmpty
        ? Center(child: Text('No fittings scheduled.', style: p.body(13, color: p.textMuted)))
        : ScrollArea(builder: (sc) => ListView.separated(controller: sc, padding: const EdgeInsets.only(right: 8), itemCount: list.length, separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final f = list[i];
              final color = _fittingColor(p, f.status);
              return Panel(child: Row(children: [
                Container(width: 52, height: 52, alignment: Alignment.center,
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('${f.scheduledDate.day}', style: p.display(18, color: color)),
                    Text(['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][f.scheduledDate.month-1], style: p.body(10, color: p.textMuted)),
                  ])),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(f.patientName, style: p.body(14, weight: FontWeight.w700)),
                  Text(f.patientPhone, style: p.body(12.5, color: p.textMuted)),
                  if (f.patchName != null) Text('Patch: ${f.patchName}', style: p.body(12, color: p.textMuted)),
                  if (f.technicianName.isNotEmpty) Text('Tech: ${f.technicianName}', style: p.body(12, color: p.textMuted)),
                ])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  StatusChip(label: f.status.label, color: color),
                  const SizedBox(height: 8),
                  if (f.status == FittingStatus.scheduled) Row(children: [
                    GoldButton(label: 'Mark Done', onTap: () { f.status = FittingStatus.completed; f.completedAt = DateTime.now(); appState.touch(); setState(() {}); }),
                    const SizedBox(width: 8),
                    GhostButton(label: 'Reschedule', onTap: () { f.status = FittingStatus.rescheduled; appState.touch(); setState(() {}); }),
                  ]),
                ]),
              ]));
            }))),
    ]);
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// MAINTENANCE TAB
// ══════════════════════════════════════════════════════════════════════════════
class _MaintenanceTab extends StatefulWidget {
  const _MaintenanceTab();
  @override
  State<_MaintenanceTab> createState() => _MaintenanceTabState();
}

class _MaintenanceTabState extends State<_MaintenanceTab> {
  MaintenanceType? _typeFilter;

  void _showSchedule() {
    final p = appState.palette;
    final patCtrl   = TextEditingController();
    final phoneCtrl = TextEditingController();
    final techCtrl  = TextEditingController();
    final notesCtrl = TextEditingController();
    var type = MaintenanceType.cleaning;
    double cost = 500;
    DateTime date = DateTime.now().add(const Duration(days: 7));

    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, ss) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(width: 500, padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: p.border)),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('SCHEDULE MAINTENANCE', style: p.display(22, spacing: 1.0)),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: FormField2(label: 'Patient Name *', controller: patCtrl, hint: 'Full name')),
            const SizedBox(width: 14),
            Expanded(child: FormField2(label: 'Phone', controller: phoneCtrl, hint: '+92 ...')),
          ]),
          const SizedBox(height: 14),
          Dropdown2<MaintenanceType>(label: 'Maintenance Type', value: type,
            items: MaintenanceType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.label))).toList(),
            onChanged: (v) => ss(() => type = v ?? type)),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: FormField2(label: 'Technician', controller: techCtrl, hint: 'Assigned technician')),
            const SizedBox(width: 14),
            Expanded(child: FormField2(label: 'Cost (PKR)', controller: TextEditingController(text: cost.toStringAsFixed(0)),
              hint: '500', keyboard: TextInputType.number, onChanged: (v) => cost = double.tryParse(v) ?? cost)),
          ]),
          const SizedBox(height: 14),
          _DatePickerRow(label: 'Maintenance Date', value: date, palette: p, onPick: (d) => ss(() => date = d)),
          const SizedBox(height: 14),
          FormField2(label: 'Notes', controller: notesCtrl, hint: 'Instructions or observations…', maxLines: 2),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            GhostButton(label: 'Cancel', onTap: () => Navigator.pop(ctx)),
            const SizedBox(width: 12),
            GoldButton(label: 'Schedule', onTap: () {
              if (patCtrl.text.isEmpty) return;
              appState.addPatchMaintenance(PatchMaintenance(
                id: appState.createMaintenanceId(), patientId: '', patientName: patCtrl.text,
                patientPhone: phoneCtrl.text, type: type, scheduledDate: date,
                technicianName: techCtrl.text, cost: cost, notes: notesCtrl.text,
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
    var list = appState.patchMaintenances;
    if (_typeFilter != null) list = list.where((m) => m.type == _typeFilter).toList();
    final pending = list.where((m) => !m.completed).toList()..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
    final done = list.where((m) => m.completed).toList();

    return Column(children: [
      Row(children: [
        MetricCard(title: 'Total Scheduled', value: '${appState.patchMaintenances.length}', icon: Icons.build_circle_outlined, delta: ''),
        const SizedBox(width: 14),
        MetricCard(title: 'Pending', value: '${appState.patchMaintenances.where((m) => !m.completed).length}', icon: Icons.pending_outlined, delta: ''),
        const SizedBox(width: 14),
        MetricCard(title: 'Completed', value: '${appState.patchMaintenances.where((m) => m.completed).length}', icon: Icons.check_circle_outline, delta: ''),
      ]),
      const SizedBox(height: 16),
      FilterBar(searchHint: 'Filter maintenance…', onSearch: (_) {},
        filters: [FilterDropdown<MaintenanceType?>(value: _typeFilter,
          items: [const DropdownMenuItem(value: null, child: Text('All Types')), ...MaintenanceType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.label)))],
          onChanged: (v) => setState(() => _typeFilter = v))],
        countText: '${list.length} records', onClear: () => setState(() => _typeFilter = null),
        trailing: [GoldButton(label: 'Schedule', icon: Icons.add, onTap: _showSchedule)]),
      const SizedBox(height: 12),
      Expanded(child: list.isEmpty
        ? Center(child: Text('No maintenance records.', style: p.body(13, color: p.textMuted)))
        : ScrollArea(builder: (sc) => SingleChildScrollView(controller: sc, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (pending.isNotEmpty) ...[
              Text('UPCOMING (${pending.length})', style: p.body(11, weight: FontWeight.w700, spacing: 1.0, color: p.textMuted)),
              const SizedBox(height: 8),
              ...pending.map((m) => Padding(padding: const EdgeInsets.only(bottom: 10), child: _MaintenanceCard(m: m, p: p, onUpdate: () => setState(() {})))),
              const SizedBox(height: 16),
            ],
            if (done.isNotEmpty) ...[
              Text('COMPLETED (${done.length})', style: p.body(11, weight: FontWeight.w700, spacing: 1.0, color: p.textMuted)),
              const SizedBox(height: 8),
              ...done.map((m) => Padding(padding: const EdgeInsets.only(bottom: 10), child: _MaintenanceCard(m: m, p: p, onUpdate: () => setState(() {})))),
            ],
          ])))),
    ]);
  }
}

class _MaintenanceCard extends StatelessWidget {
  final PatchMaintenance m;
  final AppPalette p;
  final VoidCallback onUpdate;
  const _MaintenanceCard({required this.m, required this.p, required this.onUpdate});
  @override
  Widget build(BuildContext context) {
    return Panel(child: Row(children: [
      Container(width: 44, height: 44, alignment: Alignment.center,
        decoration: BoxDecoration(color: (m.completed ? p.success : p.warning).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
        child: Icon(Icons.build_circle_outlined, size: 22, color: m.completed ? p.success : p.warning)),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(m.patientName, style: p.body(14, weight: FontWeight.w700)),
        Text(m.type.label, style: p.body(12.5, color: p.gold)),
        Text('${prettyShort(m.scheduledDate)} · ${m.patientPhone}', style: p.body(12, color: p.textMuted)),
        if (m.technicianName.isNotEmpty) Text('Tech: ${m.technicianName}', style: p.body(12, color: p.textMuted)),
      ])),
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text(money(m.cost), style: p.body(14, weight: FontWeight.w700, color: p.gold)),
        const SizedBox(height: 6),
        if (!m.completed) GoldButton(label: 'Mark Done', onTap: () { m.completed = true; m.completedAt = DateTime.now(); appState.touch(); onUpdate(); }),
        if (m.completed) StatusChip(label: 'Completed', color: p.success),
      ]),
    ]));
  }
}

// ── Shared Date Picker ────────────────────────────────────────────────────────
class _DatePickerRow extends StatelessWidget {
  final String label;
  final DateTime value;
  final AppPalette palette;
  final ValueChanged<DateTime> onPick;
  const _DatePickerRow({required this.label, required this.value, required this.palette, required this.onPick});
  @override
  Widget build(BuildContext context) {
    final p = palette;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: p.body(12, color: p.textMuted, weight: FontWeight.w600)),
      const SizedBox(height: 7),
      GestureDetector(
        onTap: () async {
          final d = await showDatePicker(context: context, initialDate: value, firstDate: DateTime(2024), lastDate: DateTime(2030),
            builder: (ctx, child) => Theme(data: ThemeData.dark().copyWith(colorScheme: ColorScheme.dark(primary: p.gold, surface: p.surface)), child: child!));
          if (d != null) onPick(d);
        },
        child: Container(height: 46, padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(8), border: Border.all(color: p.border)),
          child: Row(children: [
            Icon(Icons.calendar_today_outlined, size: 15, color: p.gold), const SizedBox(width: 10),
            Text(prettyShort(value), style: p.body(13.5, weight: FontWeight.w500)),
          ])),
      ),
    ]);
  }
}
