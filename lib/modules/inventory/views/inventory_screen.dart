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
  void initState() { super.initState(); _tab = TabController(length: 4, vsync: this); }
  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    return ScreenScaffold(
      title: 'INVENTORY',
      subtitle: 'Stock management, movements, transfers & audit',
      actions: [
        Container(height: 42,
          decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: p.border)),
          child: TabBar(controller: _tab, isScrollable: true, dividerColor: Colors.transparent,
            indicatorColor: p.gold, indicatorSize: TabBarIndicatorSize.label,
            labelStyle: p.body(12.5, weight: FontWeight.w600), unselectedLabelStyle: p.body(12.5),
            labelColor: p.gold, unselectedLabelColor: p.textMuted, tabAlignment: TabAlignment.start,
            tabs: const [Tab(text: 'Dashboard'), Tab(text: 'Stock List'), Tab(text: 'Movements'), Tab(text: 'Audit')]),
        ),
      ],
      child: TabBarView(controller: _tab, children: const [
        _DashboardTab(), _StockListTab(), _MovementsTab(), _AuditTab(),
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
