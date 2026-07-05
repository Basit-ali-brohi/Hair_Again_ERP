import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../models/inventory_models.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});
  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> with SingleTickerProviderStateMixin {
  late final TabController _tab;
  @override
  void initState() { super.initState(); _tab = TabController(length: 7, vsync: this); }
  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    return ScreenScaffold(
      title: 'INVENTORY',
      subtitle: 'Stock management, movements, transfers, consumption, returns & audit',
      actions: [
        Container(height: 42,
          decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: p.border)),
          child: TabBar(controller: _tab, isScrollable: true, dividerColor: Colors.transparent,
            indicatorColor: p.gold, indicatorSize: TabBarIndicatorSize.label,
            labelStyle: p.body(12.5, weight: FontWeight.w600), unselectedLabelStyle: p.body(12.5),
            labelColor: p.gold, unselectedLabelColor: p.textMuted, tabAlignment: TabAlignment.start,
            tabs: const [
              Tab(text: 'Dashboard'), Tab(text: 'Stock List'), Tab(text: 'Movements'),
              Tab(text: 'Stock Transfer'), Tab(text: 'Consumption'), Tab(text: 'Returns'),
              Tab(text: 'Audit'),
            ]),
        ),
      ],
      child: EagerTabBarView(controller: _tab, children: const [
        _DashboardTab(), _StockListTab(), _MovementsTab(),
        _TransferTab(), _ConsumptionTab(), _ReturnsTab(),
        _AuditTab(),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// DASHBOARD TAB
// ══════════════════════════════════════════════════════════════════════════════
class _DashboardTab extends StatelessWidget {
  const _DashboardTab();
  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final items = appState.stockItems;
    final totalValue = items.fold(0.0, (s, i) => s + i.stockValue);
    final lowStock = items.where((i) => i.isLow).toList();
    final outOfStock = items.where((i) => i.isOut).toList();
    final catMap = <StockCategory, int>{};
    for (final i in items) catMap[i.category] = (catMap[i.category] ?? 0) + 1;

    return ScrollArea(builder: (sc) => SingleChildScrollView(controller: sc, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        MetricCard(title: 'Total Items', value: '${items.length}', icon: Icons.inventory_2_outlined, delta: ''),
        const SizedBox(width: 14),
        MetricCard(title: 'Stock Value', value: money(totalValue), icon: Icons.monetization_on_outlined, delta: ''),
        const SizedBox(width: 14),
        MetricCard(title: 'Low Stock', value: '${lowStock.length}', icon: Icons.warning_amber_outlined, delta: lowStock.isNotEmpty ? 'attention' : '', deltaUp: false),
        const SizedBox(width: 14),
        MetricCard(title: 'Out of Stock', value: '${outOfStock.length}', icon: Icons.remove_shopping_cart_outlined, delta: outOfStock.isNotEmpty ? 'critical' : '', deltaUp: false),
      ]),
      const SizedBox(height: 20),
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('BY CATEGORY', style: p.display(18, spacing: 0.5)),
          const SizedBox(height: 16),
          ...catMap.entries.map((e) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(children: [
            Container(width: 10, height: 10, decoration: BoxDecoration(color: p.gold, shape: BoxShape.circle)),
            const SizedBox(width: 10),
            Expanded(child: Text(e.key.label, style: p.body(13, weight: FontWeight.w500))),
            Text('${e.value}', style: p.body(13, weight: FontWeight.w700, color: p.gold)),
          ]))),
        ]))),
        const SizedBox(width: 18),
        Expanded(child: Column(children: [
          if (lowStock.isNotEmpty) Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Icon(Icons.warning_amber_outlined, size: 18, color: p.warning), const SizedBox(width: 8), Text('LOW STOCK ALERTS', style: p.body(12, weight: FontWeight.w700, spacing: 0.5, color: p.warning))]),
            const SizedBox(height: 12),
            ...lowStock.take(6).map((item) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [
              Expanded(child: Text(item.name, style: p.body(12.5, weight: FontWeight.w500))),
              Text('${item.currentQty} ${item.unit}', style: p.body(12.5, weight: FontWeight.w700, color: p.warning)),
              const SizedBox(width: 8),
              Text('/ ${item.reorderLevel} min', style: p.body(11.5, color: p.textMuted)),
            ]))),
          ])),
          if (outOfStock.isNotEmpty) ...[
            const SizedBox(height: 14),
            Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [Icon(Icons.error_outline, size: 18, color: p.danger), const SizedBox(width: 8), Text('OUT OF STOCK', style: p.body(12, weight: FontWeight.w700, spacing: 0.5, color: p.danger))]),
              const SizedBox(height: 12),
              ...outOfStock.take(4).map((item) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [
                Expanded(child: Text(item.name, style: p.body(12.5, weight: FontWeight.w500))),
                StatusChip(label: 'OUT', color: p.danger),
              ]))),
            ])),
          ],
        ])),
        const SizedBox(width: 18),
        SizedBox(width: 300, child: Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('RECENT MOVEMENTS', style: p.display(18, spacing: 0.5)),
          const SizedBox(height: 16),
          ...appState.stockMovements.reversed.take(8).map((mv) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(children: [
            Icon(mv.type.isIn ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded, size: 14, color: mv.type.isIn ? p.success : p.danger),
            const SizedBox(width: 8),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(mv.itemName, style: p.body(12.5, weight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
              Text(mv.type.label, style: p.body(11, color: p.textMuted)),
            ])),
            Text('${mv.type.isIn ? '+' : '-'}${mv.qty}', style: p.body(13, weight: FontWeight.w700, color: mv.type.isIn ? p.success : p.danger)),
          ]))),
        ]))),
      ]),
    ])));
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// STOCK LIST TAB
// ══════════════════════════════════════════════════════════════════════════════
class _StockListTab extends StatefulWidget {
  const _StockListTab();
  @override
  State<_StockListTab> createState() => _StockListTabState();
}

class _StockListTabState extends State<_StockListTab> {
  String _q = '';
  StockCategory? _catFilter;
  bool? _lowStockFilter;

  void _showForm({StockItem? existing}) {
    final editing = existing != null;
    final p = appState.palette;
    final nameCtrl  = TextEditingController(text: existing?.name ?? '');
    final skuCtrl   = TextEditingController(text: existing?.sku ?? '');
    final unitCtrl  = TextEditingController(text: existing?.unit ?? 'pcs');
    final locCtrl   = TextEditingController(text: existing?.location ?? '');
    final vendorCtrl = TextEditingController(text: existing?.vendorName ?? '');
    var cat = existing?.category ?? StockCategory.consumable;
    double cost = existing?.costPrice ?? 0;
    double sell = existing?.sellingPrice ?? 0;
    int qty = existing?.currentQty ?? 0;
    int reorder = existing?.reorderLevel ?? 5;

    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, ss) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(width: 580, padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: p.border)),
        child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(editing ? 'EDIT STOCK ITEM' : 'ADD STOCK ITEM', style: p.display(22, spacing: 1.0)),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: FormField2(label: 'Item Name *', controller: nameCtrl, hint: 'e.g. PRP Kit')),
            const SizedBox(width: 14),
            SizedBox(width: 140, child: FormField2(label: 'SKU', controller: skuCtrl, hint: 'INV-001')),
          ]),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: Dropdown2<StockCategory>(label: 'Category', value: cat,
              items: StockCategory.values.map((c) => DropdownMenuItem(value: c, child: Text(c.label))).toList(),
              onChanged: (v) => ss(() => cat = v ?? cat))),
            const SizedBox(width: 14),
            Expanded(child: FormField2(label: 'Unit', controller: unitCtrl, hint: 'pcs / ml / kg / box')),
          ]),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: FormField2(label: 'Cost Price (PKR)', controller: TextEditingController(text: cost == 0 ? '' : cost.toStringAsFixed(0)),
              hint: '0', keyboard: TextInputType.number, onChanged: (v) => cost = double.tryParse(v) ?? cost)),
            const SizedBox(width: 14),
            Expanded(child: FormField2(label: 'Selling Price (PKR)', controller: TextEditingController(text: sell == 0 ? '' : sell.toStringAsFixed(0)),
              hint: '0', keyboard: TextInputType.number, onChanged: (v) => sell = double.tryParse(v) ?? sell)),
          ]),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: FormField2(label: editing ? 'Current Qty' : 'Opening Qty', controller: TextEditingController(text: '$qty'),
              hint: '0', keyboard: TextInputType.number, onChanged: (v) => qty = int.tryParse(v) ?? qty)),
            const SizedBox(width: 14),
            Expanded(child: FormField2(label: 'Reorder Level', controller: TextEditingController(text: '$reorder'),
              hint: '5', keyboard: TextInputType.number, onChanged: (v) => reorder = int.tryParse(v) ?? reorder)),
          ]),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: FormField2(label: 'Storage Location', controller: locCtrl, hint: 'Shelf A-3')),
            const SizedBox(width: 14),
            Expanded(child: FormField2(label: 'Vendor', controller: vendorCtrl, hint: 'Supplier name')),
          ]),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            GhostButton(label: 'Cancel', onTap: () => Navigator.pop(ctx)),
            const SizedBox(width: 12),
            GoldButton(label: editing ? 'Save Changes' : 'Add Item', onTap: () {
              if (nameCtrl.text.isEmpty) return;
              if (editing) {
                existing!.name = nameCtrl.text; existing.sku = skuCtrl.text; existing.unit = unitCtrl.text;
                existing.category = cat; existing.costPrice = cost; existing.sellingPrice = sell;
                existing.currentQty = qty; existing.reorderLevel = reorder;
                existing.location = locCtrl.text; existing.vendorName = vendorCtrl.text;
                existing.lastUpdated = DateTime.now(); appState.touch();
              } else {
                appState.addStockItem(StockItem(
                  id: appState.createStockItemId(), name: nameCtrl.text, sku: skuCtrl.text,
                  unit: unitCtrl.text, category: cat, costPrice: cost, sellingPrice: sell,
                  currentQty: qty, reorderLevel: reorder, location: locCtrl.text,
                  vendorName: vendorCtrl.text, lastUpdated: DateTime.now(),
                ));
              }
              Navigator.pop(ctx); setState(() {});
            }),
          ]),
        ])),
      ),
    )));
  }

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    var list = appState.stockItems;
    if (_q.isNotEmpty) list = list.where((i) => i.name.toLowerCase().contains(_q.toLowerCase()) || i.sku.toLowerCase().contains(_q.toLowerCase())).toList();
    if (_catFilter != null) list = list.where((i) => i.category == _catFilter).toList();
    if (_lowStockFilter == true) list = list.where((i) => i.isLow || i.isOut).toList();

    return Column(children: [
      FilterBar(
        searchHint: 'Search by name or SKU…', onSearch: (v) => setState(() => _q = v),
        filters: [
          FilterDropdown<StockCategory?>(value: _catFilter,
            items: [const DropdownMenuItem(value: null, child: Text('All Categories')), ...StockCategory.values.map((c) => DropdownMenuItem(value: c, child: Text(c.label)))],
            onChanged: (v) => setState(() => _catFilter = v)),
          FilterDropdown<bool?>(value: _lowStockFilter,
            items: const [DropdownMenuItem(value: null, child: Text('All Stock')), DropdownMenuItem(value: true, child: Text('Low / Out of Stock'))],
            onChanged: (v) => setState(() => _lowStockFilter = v)),
        ],
        countText: '${list.length} items', onClear: () => setState(() { _q = ''; _catFilter = null; _lowStockFilter = null; }),
        trailing: [GoldButton(label: 'Add Item', icon: Icons.add, onTap: () => _showForm())],
      ),
      const SizedBox(height: 12),
      Expanded(child: list.isEmpty
        ? Center(child: Text('No stock items found.', style: p.body(13, color: p.textMuted)))
        : Panel(padding: EdgeInsets.zero, child: ScrollArea(builder: (sc) => SingleChildScrollView(controller: sc,
            child: FullWidthDataTable(child: DataTable(
              headingRowColor: WidgetStateProperty.all(p.surfaceAlt), columnSpacing: 16, horizontalMargin: 20,
              columns: ['Item', 'SKU', 'Category', 'Unit', 'Qty', 'Reorder', 'Cost', 'Value', 'Location', 'Status', ''].map((t) => DataColumn(label: Text(t, style: p.body(12, weight: FontWeight.w700)))).toList(),
              rows: list.map((item) => DataRow(
                color: WidgetStateProperty.resolveWith((s) => item.isOut ? p.danger.withValues(alpha: 0.06) : item.isLow ? p.warning.withValues(alpha: 0.06) : Colors.transparent),
                cells: [
                  DataCell(Text(item.name, style: p.body(13, weight: FontWeight.w600))),
                  DataCell(Text(item.sku, style: p.body(12, color: p.textMuted))),
                  DataCell(StatusChip(label: item.category.label, color: p.info)),
                  DataCell(Text(item.unit, style: p.body(12.5))),
                  DataCell(Text('${item.currentQty}', style: p.body(13, weight: FontWeight.w700, color: item.isOut ? p.danger : item.isLow ? p.warning : p.success))),
                  DataCell(Text('${item.reorderLevel}', style: p.body(12.5, color: p.textMuted))),
                  DataCell(Text(money(item.costPrice), style: p.body(12.5))),
                  DataCell(Text(money(item.stockValue), style: p.body(12.5, weight: FontWeight.w600, color: p.gold))),
                  DataCell(Text(item.location.isEmpty ? '—' : item.location, style: p.body(12.5))),
                  DataCell(StatusChip(label: item.isOut ? 'Out' : item.isLow ? 'Low' : 'OK', color: item.isOut ? p.danger : item.isLow ? p.warning : p.success)),
                  DataCell(GestureDetector(onTap: () => _showForm(existing: item), child: MouseRegion(cursor: SystemMouseCursors.click, child: Icon(Icons.edit_outlined, size: 15, color: p.textMuted)))),
                ],
              )).toList(),
            )))))),
    ]);
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// MOVEMENTS TAB
// ══════════════════════════════════════════════════════════════════════════════
class _MovementsTab extends StatefulWidget {
  const _MovementsTab();
  @override
  State<_MovementsTab> createState() => _MovementsTabState();
}

class _MovementsTabState extends State<_MovementsTab> {
  StockMovementType? _typeFilter;

  void _showAddMovement() {
    final p = appState.palette;
    StockItem? selectedItem;
    var type = StockMovementType.purchase;
    int qty = 1;
    double unitCost = 0;
    final refCtrl   = TextEditingController();
    final byCtrl    = TextEditingController(text: 'Admin');
    final notesCtrl = TextEditingController();

    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, ss) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(width: 500, padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: p.border)),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('RECORD STOCK MOVEMENT', style: p.display(22, spacing: 1.0)),
          const SizedBox(height: 20),
          Dropdown2<StockItem?>(label: 'Select Item *', value: selectedItem,
            items: [const DropdownMenuItem<StockItem?>(value: null, child: Text('— Select —')),
              ...appState.stockItems.map((i) => DropdownMenuItem(value: i, child: Text('${i.name} (${i.currentQty} ${i.unit})')))],
            onChanged: (v) => ss(() { selectedItem = v; unitCost = v?.costPrice ?? 0; })),
          const SizedBox(height: 14),
          Dropdown2<StockMovementType>(label: 'Movement Type', value: type,
            items: StockMovementType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.label))).toList(),
            onChanged: (v) => ss(() => type = v ?? type)),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('QUANTITY', style: p.body(11, weight: FontWeight.w700, spacing: 1.0, color: p.textMuted)),
              const SizedBox(height: 8),
              Row(children: [
                QtyButton(Icons.remove, () => ss(() { if (qty > 1) qty--; })),
                const SizedBox(width: 12),
                Text('$qty', style: p.display(18)),
                const SizedBox(width: 12),
                QtyButton(Icons.add, () => ss(() => qty++)),
              ]),
            ])),
            const SizedBox(width: 14),
            Expanded(child: FormField2(label: 'Unit Cost (PKR)', controller: TextEditingController(text: unitCost == 0 ? '' : unitCost.toStringAsFixed(0)),
              hint: '0', keyboard: TextInputType.number, onChanged: (v) => unitCost = double.tryParse(v) ?? unitCost)),
          ]),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: FormField2(label: 'Reference #', controller: refCtrl, hint: 'PO-001 / Invoice no.')),
            const SizedBox(width: 14),
            Expanded(child: FormField2(label: 'Performed By', controller: byCtrl, hint: 'Name')),
          ]),
          const SizedBox(height: 14),
          FormField2(label: 'Notes', controller: notesCtrl, hint: 'Reason or remarks…', maxLines: 2),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            GhostButton(label: 'Cancel', onTap: () => Navigator.pop(ctx)),
            const SizedBox(width: 12),
            GoldButton(label: 'Record', onTap: () {
              if (selectedItem == null) return;
              final mv = StockMovement(
                id: appState.createMovementId(), itemId: selectedItem!.id, itemName: selectedItem!.name,
                unit: selectedItem!.unit, type: type, qty: qty, unitCost: unitCost,
                reference: refCtrl.text, performedBy: byCtrl.text, notes: notesCtrl.text, date: DateTime.now(),
              );
              appState.recordMovement(mv);
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
    var list = appState.stockMovements;
    if (_typeFilter != null) list = list.where((m) => m.type == _typeFilter).toList();
    final sorted = List<StockMovement>.from(list)..sort((a, b) => b.date.compareTo(a.date));

    return Column(children: [
      FilterBar(searchHint: 'Filter movements…', onSearch: (_) {},
        filters: [FilterDropdown<StockMovementType?>(value: _typeFilter,
          items: [const DropdownMenuItem(value: null, child: Text('All Types')), ...StockMovementType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.label)))],
          onChanged: (v) => setState(() => _typeFilter = v))],
        countText: '${sorted.length} movements', onClear: () => setState(() => _typeFilter = null),
        trailing: [GoldButton(label: 'Record Movement', icon: Icons.add, onTap: _showAddMovement)]),
      const SizedBox(height: 12),
      Expanded(child: sorted.isEmpty
        ? Center(child: Text('No stock movements recorded.', style: p.body(13, color: p.textMuted)))
        : Panel(padding: EdgeInsets.zero, child: ScrollArea(builder: (sc) => SingleChildScrollView(controller: sc,
            child: FullWidthDataTable(child: DataTable(
              headingRowColor: WidgetStateProperty.all(p.surfaceAlt), columnSpacing: 16, horizontalMargin: 20,
              columns: ['Date', 'Item', 'Type', 'Qty', 'Unit Cost', 'Total Value', 'Reference', 'By', 'Notes'].map((t) => DataColumn(label: Text(t, style: p.body(12, weight: FontWeight.w700)))).toList(),
              rows: sorted.map((mv) => DataRow(cells: [
                DataCell(Text(prettyShort(mv.date), style: p.body(12.5, color: p.textMuted))),
                DataCell(Text(mv.itemName, style: p.body(13, weight: FontWeight.w600))),
                DataCell(StatusChip(label: mv.type.label, color: mv.type.isIn ? p.success : p.danger)),
                DataCell(Row(children: [
                  Icon(mv.type.isIn ? Icons.add : Icons.remove, size: 12, color: mv.type.isIn ? p.success : p.danger),
                  Text('${mv.qty} ${mv.unit}', style: p.body(13, weight: FontWeight.w700, color: mv.type.isIn ? p.success : p.danger)),
                ])),
                DataCell(Text(money(mv.unitCost), style: p.body(12.5))),
                DataCell(Text(money(mv.qty * mv.unitCost), style: p.body(12.5, weight: FontWeight.w600, color: p.gold))),
                DataCell(Text(mv.reference.isEmpty ? '—' : mv.reference, style: p.body(12.5))),
                DataCell(Text(mv.performedBy, style: p.body(12.5))),
                DataCell(Text(mv.notes.isEmpty ? '—' : mv.notes, style: p.body(12, color: p.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis)),
              ])).toList(),
            )))))),
    ]);
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// AUDIT TAB
// ══════════════════════════════════════════════════════════════════════════════
class _AuditTab extends StatefulWidget {
  const _AuditTab();
  @override
  State<_AuditTab> createState() => _AuditTabState();
}

class _AuditTabState extends State<_AuditTab> {
  StockAudit? _activeAudit;

  void _startAudit() {
    final p = appState.palette;
    final byCtrl    = TextEditingController(text: 'Admin');
    final notesCtrl = TextEditingController();

    showDialog(context: context, builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(width: 460, padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: p.border)),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('START STOCK AUDIT', style: p.display(22, spacing: 1.0)),
          const SizedBox(height: 12),
          Text('A new audit will load all current stock items. You can then enter physical counts for each item.', style: p.body(13, color: p.textMuted)),
          const SizedBox(height: 20),
          FormField2(label: 'Conducted By', controller: byCtrl, hint: 'Your name'),
          const SizedBox(height: 14),
          FormField2(label: 'Notes', controller: notesCtrl, hint: 'Audit scope or remarks…', maxLines: 2),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            GhostButton(label: 'Cancel', onTap: () => Navigator.pop(ctx)),
            const SizedBox(width: 12),
            GoldButton(label: 'Start Audit', onTap: () {
              final audit = StockAudit(
                id: appState.createAuditId(), conductedBy: byCtrl.text, notes: notesCtrl.text,
                auditDate: DateTime.now(),
                lines: appState.stockItems.map((i) => AuditLine(itemId: i.id, itemName: i.name, unit: i.unit, systemQty: i.currentQty, physicalQty: i.currentQty)).toList(),
              );
              appState.addStockAudit(audit);
              Navigator.pop(ctx);
              setState(() => _activeAudit = audit);
            }),
          ]),
        ]),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final audits = appState.stockAudits;

    if (_activeAudit != null && !_activeAudit!.completed) {
      return _AuditSheet(audit: _activeAudit!, p: p, onComplete: () { setState(() => _activeAudit = null); });
    }

    return Column(children: [
      Row(children: [
        const Spacer(),
        GoldButton(label: 'Start New Audit', icon: Icons.fact_check_outlined, onTap: _startAudit),
      ]),
      const SizedBox(height: 12),
      Expanded(child: audits.isEmpty
        ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.fact_check_outlined, size: 44, color: p.textMuted.withValues(alpha: 0.4)),
            const SizedBox(height: 12),
            Text('No audits conducted yet.', style: p.body(13, color: p.textMuted)),
          ]))
        : ScrollArea(builder: (sc) => ListView.separated(controller: sc, padding: const EdgeInsets.only(right: 8), itemCount: audits.length, separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final audit = audits[audits.length - 1 - i];
              final variances = audit.lines.where((l) => l.variance != 0).length;
              return Panel(child: Row(children: [
                Container(width: 44, height: 44, alignment: Alignment.center,
                  decoration: BoxDecoration(color: audit.completed ? p.success.withValues(alpha: 0.12) : p.warning.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                  child: Icon(Icons.fact_check_outlined, size: 22, color: audit.completed ? p.success : p.warning)),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Audit #${audit.id}', style: p.body(13.5, weight: FontWeight.w700)),
                  Text('By ${audit.conductedBy} · ${prettyShort(audit.auditDate)}', style: p.body(12.5, color: p.textMuted)),
                  Text('${audit.lines.length} items · $variances variance${variances != 1 ? 's' : ''}', style: p.body(12, color: variances > 0 ? p.warning : p.success)),
                ])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  StatusChip(label: audit.completed ? 'Completed' : 'In Progress', color: audit.completed ? p.success : p.warning),
                  if (!audit.completed) ...[const SizedBox(height: 8),
                    GoldButton(label: 'Resume', onTap: () => setState(() => _activeAudit = audit)),
                  ],
                ]),
              ]));
            }))),
    ]);
  }
}

class _AuditSheet extends StatefulWidget {
  final StockAudit audit;
  final AppPalette p;
  final VoidCallback onComplete;
  const _AuditSheet({required this.audit, required this.p, required this.onComplete});
  @override
  State<_AuditSheet> createState() => _AuditSheetState();
}

class _AuditSheetState extends State<_AuditSheet> {
  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final audit = widget.audit;
    return Column(children: [
      Panel(child: Row(children: [
        Icon(Icons.fact_check_outlined, size: 20, color: p.gold), const SizedBox(width: 10),
        Text('ACTIVE AUDIT #${audit.id} · ${audit.lines.length} items', style: p.body(13, weight: FontWeight.w700)),
        const Spacer(),
        GhostButton(label: 'Discard', onTap: widget.onComplete),
        const SizedBox(width: 10),
        GoldButton(label: 'Complete Audit', onTap: () {
          audit.completed = true;
          for (final line in audit.lines) {
            final item = appState.stockItems.where((i) => i.id == line.itemId).firstOrNull;
            if (item != null && line.variance != 0) {
              item.currentQty = line.physicalQty;
              item.lastUpdated = DateTime.now();
            }
          }
          appState.touch(); widget.onComplete();
        }),
      ])),
      const SizedBox(height: 12),
      Expanded(child: Panel(padding: EdgeInsets.zero, child: ScrollArea(builder: (sc) => SingleChildScrollView(controller: sc,
          child: FullWidthDataTable(child: DataTable(
            headingRowColor: WidgetStateProperty.all(p.surfaceAlt), columnSpacing: 16, horizontalMargin: 20,
            columns: ['Item', 'Unit', 'System Qty', 'Physical Count', 'Variance'].map((t) => DataColumn(label: Text(t, style: p.body(12, weight: FontWeight.w700)))).toList(),
            rows: audit.lines.map((line) => DataRow(
              color: WidgetStateProperty.resolveWith((s) => line.variance < 0 ? p.danger.withValues(alpha: 0.05) : line.variance > 0 ? p.success.withValues(alpha: 0.05) : Colors.transparent),
              cells: [
                DataCell(Text(line.itemName, style: p.body(13, weight: FontWeight.w600))),
                DataCell(Text(line.unit, style: p.body(12.5))),
                DataCell(Text('${line.systemQty}', style: p.body(13, weight: FontWeight.w600, color: p.gold))),
                DataCell(SizedBox(width: 100, child: TextFormField(
                  initialValue: '${line.physicalQty}',
                  keyboardType: TextInputType.number,
                  style: p.body(13, weight: FontWeight.w700),
                  decoration: InputDecoration(isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: p.border)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: p.border)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: p.gold, width: 1.5))),
                  onChanged: (v) => setState(() => line.physicalQty = int.tryParse(v) ?? line.physicalQty),
                ))),
                DataCell(Text(line.variance == 0 ? '—' : '${line.variance > 0 ? '+' : ''}${line.variance}',
                  style: p.body(13, weight: FontWeight.w700, color: line.variance == 0 ? p.textMuted : line.variance > 0 ? p.success : p.danger))),
              ],
            )).toList(),
          )))))),
    ]);
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// STOCK TRANSFER TAB
// ══════════════════════════════════════════════════════════════════════════════
class _TransferEntry {
  final String date, product, from, to, transferredBy;
  final int qty;
  final String notes;
  _TransferEntry({required this.date, required this.product, required this.from, required this.to, required this.qty, required this.transferredBy, this.notes = ''});
}

class _TransferTab extends StatefulWidget {
  const _TransferTab();
  @override
  State<_TransferTab> createState() => _TransferTabState();
}

class _TransferTabState extends State<_TransferTab> {
  static const _locations = ['Main Store', 'Branch 1', 'Branch 2'];
  final _history = <_TransferEntry>[
    _TransferEntry(date: '1 Jul 2026', product: 'PRP Kit', from: 'Main Store', to: 'Branch 1', qty: 5, transferredBy: 'Admin'),
    _TransferEntry(date: '28 Jun 2026', product: 'Hair Serum', from: 'Main Store', to: 'Branch 2', qty: 10, transferredBy: 'Manager'),
  ];

  StockItem? _selectedProduct;
  String _fromLoc = 'Main Store';
  String _toLoc = 'Branch 1';
  int _qty = 1;
  DateTime _date = DateTime.now();
  final _notesCtrl = TextEditingController();
  final _byCtrl = TextEditingController(text: 'Admin');

  @override
  void dispose() { _notesCtrl.dispose(); _byCtrl.dispose(); super.dispose(); }

  void _transfer() {
    if (_selectedProduct == null) { toast(context, 'Select a product'); return; }
    if (_fromLoc == _toLoc) { toast(context, 'From and To locations must differ'); return; }
    if (_qty <= 0 || _qty > _selectedProduct!.currentQty) { toast(context, 'Insufficient stock'); return; }
    setState(() {
      _history.insert(0, _TransferEntry(
        date: prettyShort(_date), product: _selectedProduct!.name,
        from: _fromLoc, to: _toLoc, qty: _qty,
        transferredBy: _byCtrl.text.isEmpty ? 'Admin' : _byCtrl.text,
        notes: _notesCtrl.text,
      ));
      _selectedProduct!.currentQty -= _qty;
      _notesCtrl.clear();
      _qty = 1;
    });
    appState.touch();
    toast(context, 'Transfer logged successfully');
  }

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    return ScrollArea(builder: (sc) => SingleChildScrollView(controller: sc, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('NEW STOCK TRANSFER', style: p.display(18, spacing: 0.5)),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: Dropdown2<String>(label: 'From Location', value: _fromLoc,
            items: _locations.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
            onChanged: (v) => setState(() => _fromLoc = v ?? _fromLoc))),
          const SizedBox(width: 14),
          Expanded(child: Dropdown2<String>(label: 'To Location', value: _toLoc,
            items: _locations.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
            onChanged: (v) => setState(() => _toLoc = v ?? _toLoc))),
          const SizedBox(width: 14),
          Expanded(child: Dropdown2<StockItem?>(label: 'Product', value: _selectedProduct,
            items: [const DropdownMenuItem<StockItem?>(value: null, child: Text('— Select —')),
              ...appState.stockItems.map((i) => DropdownMenuItem(value: i, child: Text('${i.name} (${i.currentQty} ${i.unit})')))],
            onChanged: (v) => setState(() => _selectedProduct = v))),
        ]),
        const SizedBox(height: 14),
        Row(children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('QUANTITY', style: p.body(11, weight: FontWeight.w700, spacing: 1.0, color: p.textMuted)),
            const SizedBox(height: 8),
            Row(children: [
              QtyButton(Icons.remove, () => setState(() { if (_qty > 1) _qty--; })),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text('$_qty', style: p.display(18))),
              QtyButton(Icons.add, () => setState(() => _qty++)),
            ]),
          ]),
          const SizedBox(width: 20),
          Expanded(child: FormField2(label: 'Transferred By', controller: _byCtrl, hint: 'Staff name')),
          const SizedBox(width: 14),
          Expanded(child: FormField2(label: 'Notes', controller: _notesCtrl, hint: 'Remarks…')),
        ]),
        const SizedBox(height: 18),
        Row(children: [
          const Spacer(),
          GoldButton(label: 'Transfer Stock', icon: Icons.swap_horiz_rounded, onTap: _transfer),
        ]),
      ])),
      const SizedBox(height: 20),
      Panel(padding: EdgeInsets.zero, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.all(16), child: Text('TRANSFER HISTORY', style: p.display(16, spacing: 0.5))),
        _history.isEmpty
          ? Padding(padding: const EdgeInsets.all(24), child: Center(child: Text('No transfers recorded.', style: p.body(13, color: p.textMuted))))
          : FullWidthDataTable(child: DataTable(
            headingRowColor: WidgetStateProperty.all(p.surfaceAlt),
            columnSpacing: 16, horizontalMargin: 20,
            columns: ['Date', 'Product', 'From', 'To', 'Qty', 'By', 'Notes']
              .map((c) => DataColumn(label: Text(c, style: p.body(12, weight: FontWeight.w700)))).toList(),
            rows: _history.map((t) => DataRow(cells: [
              DataCell(Text(t.date, style: p.body(12.5, color: p.textMuted))),
              DataCell(Text(t.product, style: p.body(13, weight: FontWeight.w600))),
              DataCell(StatusChip(label: t.from, color: p.info)),
              DataCell(StatusChip(label: t.to, color: p.warning)),
              DataCell(Text('${t.qty}', style: p.body(13, weight: FontWeight.w700, color: p.gold))),
              DataCell(Text(t.transferredBy, style: p.body(12.5))),
              DataCell(Text(t.notes.isEmpty ? '—' : t.notes, style: p.body(12, color: p.textMuted))),
            ])).toList(),
          )),
      ])),
    ])));
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// STOCK CONSUMPTION TAB
// ══════════════════════════════════════════════════════════════════════════════
class _ConsumptionEntry {
  final String date, product, purpose, staff;
  final int qty;
  final double costPerUnit;
  _ConsumptionEntry({required this.date, required this.product, required this.qty, required this.purpose, required this.staff, required this.costPerUnit});
  double get totalCost => qty * costPerUnit;
}

class _ConsumptionTab extends StatefulWidget {
  const _ConsumptionTab();
  @override
  State<_ConsumptionTab> createState() => _ConsumptionTabState();
}

class _ConsumptionTabState extends State<_ConsumptionTab> {
  static const _purposes = ['Treatment', 'Cleaning', 'Demo', 'Training', 'Other'];

  final _entries = <_ConsumptionEntry>[
    _ConsumptionEntry(date: '3 Jul 2026', product: 'PRP Kit', qty: 2, purpose: 'Treatment', staff: 'Dr. Rashid', costPerUnit: 4500),
    _ConsumptionEntry(date: '3 Jul 2026', product: 'Hair Serum', qty: 1, purpose: 'Treatment', staff: 'Dr. Sara', costPerUnit: 1200),
    _ConsumptionEntry(date: '2 Jul 2026', product: 'Surgical Gloves', qty: 10, purpose: 'Treatment', staff: 'Nurse Hina', costPerUnit: 15),
    _ConsumptionEntry(date: '1 Jul 2026', product: 'Cleaning Solution', qty: 3, purpose: 'Cleaning', staff: 'Housekeeper', costPerUnit: 350),
  ];

  void _logConsumption() {
    final p = appState.palette;
    StockItem? selected;
    String purpose = 'Treatment';
    int qty = 1;
    final staffCtrl = TextEditingController(text: 'Admin');
    DateTime date = DateTime.now();

    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, ss) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(width: 520, padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: p.border)),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('LOG CONSUMPTION', style: p.display(22, spacing: 1.0)),
          const SizedBox(height: 20),
          Dropdown2<StockItem?>(label: 'Product *', value: selected,
            items: [const DropdownMenuItem<StockItem?>(value: null, child: Text('— Select Product —')),
              ...appState.stockItems.map((i) => DropdownMenuItem(value: i, child: Text('${i.name} (${i.currentQty} ${i.unit})')))],
            onChanged: (v) => ss(() => selected = v)),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: Dropdown2<String>(label: 'Purpose', value: purpose,
              items: _purposes.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
              onChanged: (v) => ss(() => purpose = v ?? purpose))),
            const SizedBox(width: 14),
            Expanded(child: FormField2(label: 'Staff Member', controller: staffCtrl, hint: 'Name')),
          ]),
          const SizedBox(height: 14),
          Row(children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('QUANTITY', style: p.body(11, weight: FontWeight.w700, spacing: 1.0, color: p.textMuted)),
              const SizedBox(height: 8),
              Row(children: [
                QtyButton(Icons.remove, () => ss(() { if (qty > 1) qty--; })),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text('$qty', style: p.display(18))),
                QtyButton(Icons.add, () => ss(() => qty++)),
              ]),
            ]),
            const SizedBox(width: 20),
            Expanded(child: _InvDatePicker(label: 'Date', value: date, palette: p, onPick: (d) => ss(() => date = d))),
          ]),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            GhostButton(label: 'Cancel', onTap: () => Navigator.pop(ctx)),
            const SizedBox(width: 12),
            GoldButton(label: 'Log', onTap: () {
              if (selected == null) return;
              setState(() {
                _entries.insert(0, _ConsumptionEntry(
                  date: prettyShort(date), product: selected!.name,
                  qty: qty, purpose: purpose, staff: staffCtrl.text,
                  costPerUnit: selected!.costPrice,
                ));
                if (selected!.currentQty >= qty) selected!.currentQty -= qty;
              });
              appState.touch();
              Navigator.pop(ctx);
              toast(context, 'Consumption logged');
            }),
          ]),
        ]),
      ),
    )));
  }

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final now = DateTime.now();
    final todayEntries = _entries.where((e) => e.date == prettyShort(now)).toList();
    final todayCost = todayEntries.fold(0.0, (s, e) => s + e.totalCost);
    final monthCost = _entries.fold(0.0, (s, e) => s + e.totalCost);
    final productCounts = <String, int>{};
    for (final e in _entries) productCounts[e.product] = (productCounts[e.product] ?? 0) + e.qty;
    final topProduct = productCounts.isEmpty ? '—' : productCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    return Column(children: [
      MetricRow([
        MetricCard(title: "Today's Consumption Cost", value: money(todayCost), icon: Icons.today_outlined, delta: '${todayEntries.length} entries'),
        MetricCard(title: 'Most Consumed Product', value: topProduct, icon: Icons.star_outline_rounded, delta: ''),
        MetricCard(title: 'Total Cost This Month', value: money(monthCost), icon: Icons.calendar_month_outlined, delta: '${_entries.length} entries'),
      ]),
      const SizedBox(height: 12),
      Row(children: [const Spacer(), GoldButton(label: 'Log Consumption', icon: Icons.add, onTap: _logConsumption)]),
      const SizedBox(height: 12),
      Expanded(child: Panel(padding: EdgeInsets.zero, child: ScrollArea(builder: (sc) => SingleChildScrollView(controller: sc,
        child: FullWidthDataTable(child: DataTable(
          headingRowColor: WidgetStateProperty.all(p.surfaceAlt),
          columnSpacing: 16, horizontalMargin: 20,
          columns: ['Date', 'Product', 'Qty Used', 'Purpose', 'Staff', 'Cost/Unit', 'Total Cost']
            .map((c) => DataColumn(label: Text(c, style: p.body(12, weight: FontWeight.w700)))).toList(),
          rows: _entries.map((e) => DataRow(cells: [
            DataCell(Text(e.date, style: p.body(12.5, color: p.textMuted))),
            DataCell(Text(e.product, style: p.body(13, weight: FontWeight.w600))),
            DataCell(Text('${e.qty}', style: p.body(13, weight: FontWeight.w700, color: p.danger))),
            DataCell(StatusChip(label: e.purpose, color: p.info)),
            DataCell(Text(e.staff, style: p.body(12.5))),
            DataCell(Text(money(e.costPerUnit), style: p.body(12.5, color: p.textMuted))),
            DataCell(Text(money(e.totalCost), style: p.body(13, weight: FontWeight.w700, color: p.gold))),
          ])).toList(),
        )))))),
    ]);
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// STOCK RETURNS TAB
// ══════════════════════════════════════════════════════════════════════════════
class _ReturnEntry {
  final String id, product;
  final int qty;
  final String reason, notes;
  String status; // Pending / Processed / Credited
  final String date;
  _ReturnEntry({required this.id, required this.date, required this.product, required this.qty, required this.reason, this.notes = '', this.status = 'Pending'});
}

class _ReturnsTab extends StatefulWidget {
  const _ReturnsTab();
  @override
  State<_ReturnsTab> createState() => _ReturnsTabState();
}

class _ReturnsTabState extends State<_ReturnsTab> {
  static const _reasons = ['Defective', 'Wrong Item', 'Unused', 'Expired', 'Overstock'];

  final _returns = <_ReturnEntry>[
    _ReturnEntry(id: 'RET-001', date: '2 Jul 2026', product: 'Hair Serum', qty: 2, reason: 'Defective', status: 'Processed'),
    _ReturnEntry(id: 'RET-002', date: '3 Jul 2026', product: 'PRP Vials', qty: 1, reason: 'Wrong Item', status: 'Pending'),
  ];

  int _nextId = 3;

  void _addReturn() {
    final p = appState.palette;
    StockItem? selected;
    String reason = 'Defective';
    int qty = 1;
    final notesCtrl = TextEditingController();

    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, ss) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(width: 500, padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: p.border)),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('ADD STOCK RETURN', style: p.display(22, spacing: 1.0)),
          const SizedBox(height: 20),
          Dropdown2<StockItem?>(label: 'Product *', value: selected,
            items: [const DropdownMenuItem<StockItem?>(value: null, child: Text('— Select Product —')),
              ...appState.stockItems.map((i) => DropdownMenuItem(value: i, child: Text(i.name)))],
            onChanged: (v) => ss(() => selected = v)),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: Dropdown2<String>(label: 'Reason', value: reason,
              items: _reasons.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
              onChanged: (v) => ss(() => reason = v ?? reason))),
            const SizedBox(width: 14),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('QUANTITY', style: p.body(11, weight: FontWeight.w700, spacing: 1.0, color: p.textMuted)),
              const SizedBox(height: 8),
              Row(children: [
                QtyButton(Icons.remove, () => ss(() { if (qty > 1) qty--; })),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 14), child: Text('$qty', style: p.display(18))),
                QtyButton(Icons.add, () => ss(() => qty++)),
              ]),
            ]),
          ]),
          const SizedBox(height: 14),
          FormField2(label: 'Notes', controller: notesCtrl, hint: 'Additional details…', maxLines: 2),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            GhostButton(label: 'Cancel', onTap: () => Navigator.pop(ctx)),
            const SizedBox(width: 12),
            GoldButton(label: 'Submit Return', onTap: () {
              if (selected == null) return;
              setState(() {
                _returns.insert(0, _ReturnEntry(
                  id: 'RET-${_nextId.toString().padLeft(3, '0')}',
                  date: prettyShort(DateTime.now()),
                  product: selected!.name, qty: qty,
                  reason: reason, notes: notesCtrl.text,
                ));
                _nextId++;
              });
              Navigator.pop(ctx);
              toast(context, 'Return submitted');
            }),
          ]),
        ]),
      ),
    )));
  }

  Color _statusColor(AppPalette p, String s) => switch (s) {
    'Processed' => p.success, 'Credited' => p.info, _ => p.warning,
  };

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    return Column(children: [
      Row(children: [const Spacer(), GoldButton(label: 'Add Return', icon: Icons.undo_rounded, onTap: _addReturn)]),
      const SizedBox(height: 12),
      Expanded(child: _returns.isEmpty
        ? Center(child: Text('No returns recorded.', style: p.body(13, color: p.textMuted)))
        : Panel(padding: EdgeInsets.zero, child: ScrollArea(builder: (sc) => SingleChildScrollView(controller: sc,
            child: FullWidthDataTable(child: DataTable(
              headingRowColor: WidgetStateProperty.all(p.surfaceAlt),
              columnSpacing: 16, horizontalMargin: 20,
              columns: ['Date', 'Return ID', 'Product', 'Qty', 'Reason', 'Status', 'Action']
                .map((c) => DataColumn(label: Text(c, style: p.body(12, weight: FontWeight.w700)))).toList(),
              rows: _returns.map((r) => DataRow(cells: [
                DataCell(Text(r.date, style: p.body(12.5, color: p.textMuted))),
                DataCell(Text(r.id, style: p.body(12.5, color: p.textMuted))),
                DataCell(Text(r.product, style: p.body(13, weight: FontWeight.w600))),
                DataCell(Text('${r.qty}', style: p.body(13, weight: FontWeight.w700, color: p.gold))),
                DataCell(StatusChip(label: r.reason, color: p.warning)),
                DataCell(StatusChip(label: r.status, color: _statusColor(p, r.status))),
                DataCell(r.status != 'Pending' ? Text('—', style: p.body(12.5, color: p.textMuted))
                  : GoldButton(label: 'Process', onTap: () {
                    setState(() => r.status = 'Processed');
                    // put qty back in stock
                    final item = appState.stockItems.where((i) => i.name == r.product).firstOrNull;
                    if (item != null) { item.currentQty += r.qty; appState.touch(); }
                    toast(context, 'Return processed');
                  })),
              ])).toList(),
            )))))),
    ]);
  }
}

// ── Shared date picker for inventory tabs ─────────────────────────────────────
class _InvDatePicker extends StatelessWidget {
  final String label;
  final DateTime value;
  final AppPalette palette;
  final ValueChanged<DateTime> onPick;
  const _InvDatePicker({required this.label, required this.value, required this.palette, required this.onPick});
  @override
  Widget build(BuildContext context) {
    final p = palette;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: p.body(12, color: p.textMuted, weight: FontWeight.w600)),
      const SizedBox(height: 7),
      GestureDetector(
        onTap: () async {
          final picked = await showDatePicker(context: context, initialDate: value,
            firstDate: DateTime(2020), lastDate: DateTime(2030),
            builder: (ctx, child) => Theme(data: ThemeData.dark().copyWith(colorScheme: ColorScheme.dark(primary: p.gold, surface: p.surface)), child: child!));
          if (picked != null) onPick(picked);
        },
        child: Container(height: 46, padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(8), border: Border.all(color: p.border)),
          child: Row(children: [Icon(Icons.calendar_today_outlined, size: 15, color: p.gold), const SizedBox(width: 10), Text(prettyShort(value), style: p.body(13.5, weight: FontWeight.w500))])),
      ),
    ]);
  }
}
