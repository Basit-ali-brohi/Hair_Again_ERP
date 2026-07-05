// modules/pos_inventory/views — billing checkout + cart + split payment, the
// printable thermal-style receipt modal, inventory table with stock
// steppers and low-stock markers, plus refund / exchange / hold / EOD tabs.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/core.dart';
import '../models/pos_models.dart';
import '../../crm/models/patient.dart';
import '../../appointments/models/appointment.dart';

// ── Hold Sale model ──────────────────────────────────────────────────────────
class _HeldSale {
  final String id;
  final String patientName;
  final List<InvoiceLine> items;
  final double total;
  final DateTime heldAt;
  _HeldSale({required this.id, required this.patientName, required this.items, required this.total, required this.heldAt});
}

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});
  @override
  State<PosScreen> createState() => PosScreenState();
}

enum _StockFilter { all, inStock, low }
enum _InvSort { nameAz, priceHi, stockLo }

class PosScreenState extends State<PosScreen> with SingleTickerProviderStateMixin {
  late final TabController _tab;
  _StockFilter _stockFilter = _StockFilter.all;
  _InvSort _invSort = _InvSort.nameAz;
  String _itemSearch = '';
  String _cat = 'All';
  Patient? _patient;
  final List<InvoiceLine> _cart = [];
  final _advance = TextEditingController(text: '0');
  String _txSearch = '';
  final List<_HeldSale> _heldSales = [];

  // Exchange state
  InventoryItem? _exchangeOld;
  InventoryItem? _exchangeNew;

  // EOD denomination controllers
  final Map<int, TextEditingController> _denomCtrl = {
    5000: TextEditingController(text: '0'),
    1000: TextEditingController(text: '0'),
    500: TextEditingController(text: '0'),
    100: TextEditingController(text: '0'),
    50: TextEditingController(text: '0'),
    20: TextEditingController(text: '0'),
    10: TextEditingController(text: '0'),
  };

  void focusBilling() => setState(() => _tab.index == 0 ? null : _tab.animateTo(0));
  void showLowStock() => setState(() { _tab.animateTo(1); _stockFilter = _StockFilter.low; });

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 6, vsync: this);
    _tab.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _advance.dispose();
    for (final c in _denomCtrl.values) c.dispose();
    _tab.dispose();
    super.dispose();
  }

  double get _subtotal => _cart.fold(0, (s, l) => s + l.total);
  double get _balance {
    final a = double.tryParse(_advance.text.trim()) ?? 0;
    return (_subtotal - a).clamp(0, double.infinity);
  }

  double get _denomTotal => _denomCtrl.entries.fold(0.0, (s, e) => s + (int.tryParse(e.value.text) ?? 0) * e.key);

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final tabLabels = [
      (Icons.receipt_long_outlined, 'Billing'),
      (Icons.inventory_2_outlined, 'Inventory'),
      (Icons.undo_outlined, 'Refunds'),
      (Icons.swap_horiz_outlined, 'Exchange'),
      (Icons.pause_circle_outlined, 'Hold Sales'),
      (Icons.summarize_outlined, 'End of Day'),
    ];
    return ScreenScaffold(
      title: 'POS & INVENTORY',
      subtitle: 'Bill treatments, manage installments and track clinic stock.',
      actions: [],
      child: LayoutBuilder(builder: (ctx, c) {
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: MetricRow([
              MetricCard(title: "Today's Sales", value: moneyShort(appState.todaysSales), delta: '+8%', icon: Icons.payments_outlined),
              MetricCard(title: 'Pending Installments', value: moneyShort(appState.pendingInstallments), delta: '${appState.invoices.where((i) => i.balance > 0).length} overdue', deltaUp: false, icon: Icons.schedule_outlined),
              MetricCard(title: 'Inventory Items', value: '${appState.inventoryCount}', delta: '+1 item added', icon: Icons.inventory_2_outlined),
              MetricCard(title: 'Low Stock Warnings', value: '${appState.lowStockCount}', delta: '${appState.lowStockCount} need reorder', deltaUp: false, icon: Icons.warning_amber_outlined),
            ]),
          ),
          const SizedBox(height: 8),
          // Tab bar
          Container(
            decoration: BoxDecoration(color: p.surface, border: Border(bottom: BorderSide(color: p.border))),
            child: TabBar(
              controller: _tab,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorColor: p.gold,
              labelColor: p.gold,
              unselectedLabelColor: p.textMuted,
              labelStyle: p.body(13, weight: FontWeight.w700),
              unselectedLabelStyle: p.body(13, weight: FontWeight.w500),
              tabs: tabLabels.map((t) => Tab(
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(t.$1, size: 15),
                  const SizedBox(width: 7),
                  Text(t.$2),
                ]),
              )).toList(),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(child: Padding(
            padding: const EdgeInsets.only(right: 12, bottom: 16),
            child: EagerTabBarView(controller: _tab, children: [
              _billing(p),
              _inventory(p),
              _refundsTab(p),
              _exchangeTab(p),
              _holdSalesTab(p),
              _eodTab(p),
            ]),
          )),
        ]);
      }),
    );
  }

  // ── Tab 0: Billing ─────────────────────────────────────────────────────────
  Widget _billing(AppPalette p) {
    final treatments = appState.treatments.where((t) => _txSearch.isEmpty || t.name.toLowerCase().contains(_txSearch.toLowerCase())).toList();
    return Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Expanded(
        flex: 6,
        child: Panel(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SectionTitle('BUILD INVOICE'),
            const SizedBox(height: 14),
            Dropdown2<Patient?>(label: 'Select Patient', value: _patient, items: [const DropdownMenuItem<Patient?>(value: null, child: Text('— Choose patient —')), ...appState.patients.map((pt) => DropdownMenuItem<Patient?>(value: pt, child: Text('${pt.name}  •  ${pt.phone}')))], onChanged: (v) => setState(() => _patient = v)),
            const SizedBox(height: 16),
            SearchBox(hint: 'Search treatments…', onChanged: (v) => setState(() => _txSearch = v)),
            const SizedBox(height: 12),
            Expanded(child: ScrollArea(builder: (sc) => ListView.separated(controller: sc, padding: const EdgeInsets.only(right: 12), itemCount: treatments.length, separatorBuilder: (_, _) => const SizedBox(height: 8), itemBuilder: (_, i) => _txRow(p, treatments[i])))),
          ]),
        ),
      ),
      const SizedBox(width: 18),
      Expanded(
        flex: 5,
        child: Panel(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [const SectionTitle('CURRENT BILL'), const Spacer(), if (_cart.isNotEmpty) GestureDetector(onTap: () => setState(_cart.clear), child: Text('Clear', style: p.body(12.5, color: p.danger, weight: FontWeight.w600)))]),
            const SizedBox(height: 4),
            Text(_patient == null ? 'No patient selected' : 'For: ${_patient!.name}', style: p.body(12, color: p.textMuted)),
            const SizedBox(height: 10),
            Expanded(child: _cart.isEmpty ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.shopping_cart_outlined, size: 36, color: p.textMuted.withValues(alpha: 0.5)), const SizedBox(height: 6), Text('Add treatments to start billing', style: p.body(12.5, color: p.textMuted))])) : ScrollArea(builder: (sc) => ListView.separated(controller: sc, padding: const EdgeInsets.only(right: 12), itemCount: _cart.length, separatorBuilder: (_, _) => Divider(height: 14, color: p.border), itemBuilder: (_, i) => _cartRow(p, _cart[i])))),
            Divider(height: 10, color: p.border),
            _total(p, 'Subtotal', money(_subtotal), muted: true),
            const SizedBox(height: 4),
            Row(children: [
              Expanded(child: Text('Advance / Split Payment', style: p.body(12.5, color: p.textMuted))),
              SizedBox(
                width: 150,
                child: TextField(
                  controller: _advance, keyboardType: TextInputType.number, textAlign: TextAlign.right, style: p.body(14, weight: FontWeight.w600), cursorColor: p.gold, inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(isDense: true, prefixText: 'PKR ', prefixStyle: p.body(13, color: p.textMuted), filled: true, fillColor: p.surfaceAlt, contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: p.border)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: p.gold, width: 1.5))),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ]),
            const SizedBox(height: 4),
            Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6), decoration: BoxDecoration(color: p.gold.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(8), border: Border.all(color: p.gold.withValues(alpha: 0.4))), child: Row(children: [Text('BALANCE DUE', style: p.body(12.5, weight: FontWeight.w700)), const Spacer(), Flexible(child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerRight, child: Text(money(_balance), style: p.display(24, color: p.gold))))])),
            const SizedBox(height: 4),
            if (_heldSales.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(8), border: Border.all(color: p.border)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('HELD SALES (${_heldSales.length})', style: p.body(10, color: p.textMuted, weight: FontWeight.w700, spacing: 0.8)),
                  const SizedBox(height: 8),
                  ..._heldSales.asMap().entries.map((e) => GestureDetector(
                    onTap: () => _restoreHeld(e.key),
                    child: MouseRegion(cursor: SystemMouseCursors.click, child: Padding(padding: const EdgeInsets.only(bottom: 6), child: Row(children: [
                      Icon(Icons.restore_outlined, size: 14, color: p.gold),
                      const SizedBox(width: 8),
                      Expanded(child: Text(e.value.patientName, style: p.body(12.5, color: p.gold))),
                      Text(money(e.value.total), style: p.body(12, color: p.textMuted)),
                    ]))),
                  )),
                ]),
              ),
            ],
            Row(children: [
              Expanded(child: GhostButton(label: 'Hold Sale', icon: Icons.pause_circle_outlined, onTap: _holdSale, dense: true)),
              const SizedBox(width: 10),
              Expanded(flex: 2, child: GoldButton(label: 'Generate Invoice', icon: Icons.receipt_long, onTap: _generate, dense: true)),
            ]),
          ]),
        ),
      ),
    ]);
  }

  Widget _txRow(AppPalette p, Treatment t) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(8), border: Border.all(color: p.border)),
        child: Row(children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: p.gold.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)), child: Icon(Icons.medical_services_outlined, size: 16, color: p.gold)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t.name, style: p.body(13, weight: FontWeight.w600)), Text(money(t.price), style: p.body(12, color: p.textMuted))])),
          GoldButton(label: 'Add', dense: true, onTap: () => _add(t)),
        ]),
      );

  Widget _cartRow(AppPalette p, InvoiceLine l) => Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(l.name, style: p.body(13, weight: FontWeight.w600)), Text('${money(l.price)} each', style: p.body(11.5, color: p.textMuted))])),
        QtyButton(Icons.remove, () { if (l.qty > 1) { setState(() => l.qty--); } else { setState(() => _cart.remove(l)); } }),
        Container(width: 32, alignment: Alignment.center, child: Text('${l.qty}', style: p.body(14, weight: FontWeight.w700))),
        QtyButton(Icons.add, () => setState(() => l.qty++)),
        const SizedBox(width: 12),
        SizedBox(width: 92, child: Text(money(l.total), textAlign: TextAlign.right, style: p.body(13.5, weight: FontWeight.w700))),
      ]);

  Widget _total(AppPalette p, String label, String value, {bool muted = false}) => Row(children: [Text(label, style: p.body(13, color: muted ? p.textMuted : p.text)), const Spacer(), Text(value, style: p.body(14, weight: FontWeight.w700))]);

  void _add(Treatment t) {
    InvoiceLine? ex;
    for (final l in _cart) {
      if (l.name == t.name) { ex = l; break; }
    }
    setState(() => ex != null ? ex.qty++ : _cart.add(InvoiceLine(name: t.name, qty: 1, price: t.price)));
  }

  void _holdSale() {
    if (_cart.isEmpty) return toast(context, 'Nothing in cart to hold');
    final label = _patient?.name ?? 'Unnamed (${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')})';
    setState(() {
      _heldSales.add(_HeldSale(
        id: 'HS${DateTime.now().millisecondsSinceEpoch}',
        patientName: label,
        items: List.of(_cart),
        total: _subtotal,
        heldAt: DateTime.now(),
      ));
      _cart.clear();
      _advance.text = '0';
      _patient = null;
    });
    toast(context, 'Sale held — you can restore it anytime');
  }

  void _restoreHeld(int idx) {
    final held = _heldSales[idx];
    setState(() {
      _heldSales.removeAt(idx);
      _patient = appState.patients.cast<Patient?>().firstWhere((p) => p?.name == held.patientName, orElse: () => null);
      _cart.clear();
      _cart.addAll(held.items);
      _advance.text = '0';
    });
  }

  void _generate() {
    if (_patient == null) return toast(context, 'Select a patient first');
    if (_cart.isEmpty) return toast(context, 'Add at least one treatment');
    final adv = double.tryParse(_advance.text.trim()) ?? 0;
    final inv = Invoice(id: appState.createInvoiceId(), patientName: _patient!.name, lines: _cart.map((l) => InvoiceLine(name: l.name, qty: l.qty, price: l.price)).toList(), advance: adv, date: DateTime.now());
    appState.addInvoice(inv);
    showDialog(context: context, barrierColor: Colors.black.withValues(alpha: 0.6), builder: (_) => InvoiceReceiptDialog(invoice: inv));
    setState(() { _cart.clear(); _advance.text = '0'; _patient = null; });
  }

  // ── Tab 1: Inventory ───────────────────────────────────────────────────────
  Widget _inventory(AppPalette p) {
    final cats = <String>{'All', ...appState.inventory.map((i) => i.category)}.toList();
    final q = _itemSearch.toLowerCase();
    var items = appState.inventory.where((i) {
      final mq = q.isEmpty || i.name.toLowerCase().contains(q) || i.category.toLowerCase().contains(q);
      final mc = _cat == 'All' || i.category == _cat;
      final ms = switch (_stockFilter) { _StockFilter.all => true, _StockFilter.inStock => !i.isLow, _StockFilter.low => i.isLow };
      return mq && mc && ms;
    }).toList();
    switch (_invSort) {
      case _InvSort.nameAz: items.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      case _InvSort.priceHi: items.sort((a, b) => b.price.compareTo(a.price));
      case _InvSort.stockLo: items.sort((a, b) => a.stock.compareTo(b.stock));
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child: FilterBar(
            searchHint: 'Search items or categories…',
            onSearch: (v) => setState(() => _itemSearch = v),
            filters: [
              FilterDropdown<String>(icon: Icons.category_outlined, value: cats.contains(_cat) ? _cat : 'All', items: cats.map((c) => DropdownMenuItem(value: c, child: Text(c == 'All' ? 'All Categories' : c))).toList(), onChanged: (v) => setState(() => _cat = v ?? 'All')),
              FilterDropdown<_StockFilter>(icon: Icons.inventory_outlined, value: _stockFilter, items: const [DropdownMenuItem(value: _StockFilter.all, child: Text('All Stock')), DropdownMenuItem(value: _StockFilter.inStock, child: Text('In Stock')), DropdownMenuItem(value: _StockFilter.low, child: Text('Low Stock'))], onChanged: (v) => setState(() => _stockFilter = v ?? _StockFilter.all)),
              FilterDropdown<_InvSort>(icon: Icons.sort, value: _invSort, items: const [DropdownMenuItem(value: _InvSort.nameAz, child: Text('Name A–Z')), DropdownMenuItem(value: _InvSort.priceHi, child: Text('Price High→Low')), DropdownMenuItem(value: _InvSort.stockLo, child: Text('Stock Low→High'))], onChanged: (v) => setState(() => _invSort = v ?? _InvSort.nameAz)),
            ],
            countText: 'Showing ${items.length} of ${appState.inventory.length}',
            onClear: () => setState(() { _itemSearch = ''; _cat = 'All'; _stockFilter = _StockFilter.all; _invSort = _InvSort.nameAz; }),
          ),
        ),
        const SizedBox(width: 12),
        Padding(padding: const EdgeInsets.only(top: 4), child: GoldButton(label: 'Add Item', icon: Icons.add, dense: true, onTap: _addItem)),
      ]),
      const SizedBox(height: 16),
      Expanded(child: Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Row(children: [Expanded(flex: 4, child: _th(p, 'ITEM')), Expanded(flex: 2, child: _th(p, 'CATEGORY')), Expanded(flex: 2, child: _th(p, 'PRICE')), Expanded(flex: 3, child: _th(p, 'STOCK')), Expanded(flex: 2, child: _th(p, 'STATUS')), const SizedBox(width: 72)])),
        const SizedBox(height: 6),
        Divider(height: 1, color: p.border),
        Expanded(child: items.isEmpty ? Center(child: Text('No inventory items found.', style: p.body(13, color: p.textMuted))) : ScrollArea(builder: (sc) => ListView.separated(controller: sc, padding: const EdgeInsets.only(right: 12), itemCount: items.length, separatorBuilder: (_, _) => Divider(height: 1, color: p.border), itemBuilder: (_, i) => _invRow(p, items[i])))),
      ]))),
    ]);
  }

  Widget _th(AppPalette p, String t) => Text(t, style: p.body(11, color: p.textMuted, weight: FontWeight.w700, spacing: 0.8));

  Widget _invRow(AppPalette p, InventoryItem item) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Row(children: [
          Expanded(flex: 4, child: Row(children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(8)), child: Icon(Icons.inventory_2_outlined, size: 16, color: p.gold)), const SizedBox(width: 12), Expanded(child: Text(item.name, style: p.body(13.5, weight: FontWeight.w600), overflow: TextOverflow.ellipsis))])),
          Expanded(flex: 2, child: Text(item.category, style: p.body(13, color: p.textMuted))),
          Expanded(flex: 2, child: Text(money(item.price), style: p.body(13))),
          Expanded(flex: 3, child: Row(children: [QtyButton(Icons.remove, () { appState.adjustStock(item, -1); setState(() {}); }), Container(width: 44, alignment: Alignment.center, child: Text('${item.stock}', style: p.body(14, weight: FontWeight.w700))), QtyButton(Icons.add, () { appState.adjustStock(item, 1); setState(() {}); })])),
          Expanded(flex: 2, child: Align(alignment: Alignment.centerLeft, child: item.isLow ? StatusChip(label: 'Low Stock', color: p.danger) : StatusChip(label: 'In Stock', color: p.success))),
          SizedBox(width: 72, child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            GestureDetector(onTap: () => _editItem(item), child: MouseRegion(cursor: SystemMouseCursors.click, child: Container(width: 30, height: 30, decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(8)), child: Icon(Icons.edit_outlined, size: 15, color: p.text)))),
            const SizedBox(width: 6),
            GestureDetector(onTap: () async { final ok = await confirm(context, 'Delete item?', 'Remove "${item.name}" from inventory.'); if (ok) { appState.deleteInventory(item); setState(() {}); } }, child: MouseRegion(cursor: SystemMouseCursors.click, child: Container(width: 30, height: 30, decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(8)), child: Icon(Icons.delete_outline, size: 15, color: p.textMuted)))),
          ])),
        ]),
      );

  void _addItem() => _showItemForm();
  void _editItem(InventoryItem item) => _showItemForm(existing: item);

  void _showItemForm({InventoryItem? existing}) {
    final editing = existing != null;
    final name = TextEditingController(text: existing?.name ?? '');
    final cat = TextEditingController(text: existing?.category ?? 'Consumables');
    final price = TextEditingController(text: existing != null ? existing.price.toStringAsFixed(0) : '1000');
    final stock = TextEditingController(text: existing != null ? '${existing.stock}' : '20');
    final reorder = TextEditingController(text: existing != null ? '${existing.reorderLevel}' : '10');
    final p = pal(context);
    showDialog(context: context, builder: (_) => Dialog(
      backgroundColor: p.surface, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: p.border)),
      child: Container(
        width: 480, padding: const EdgeInsets.all(26),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(editing ? 'EDIT INVENTORY ITEM' : 'ADD INVENTORY ITEM', style: p.display(26)),
          const SizedBox(height: 18),
          FormField2(label: 'Item Name *', controller: name, hint: 'e.g. PRP Centrifuge Kits'),
          const SizedBox(height: 14),
          FormField2(label: 'Category', controller: cat),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: FormField2(label: 'Unit Price (PKR)', controller: price, keyboard: TextInputType.number)),
            const SizedBox(width: 14),
            Expanded(child: FormField2(label: editing ? 'Stock (set absolute)' : 'Stock', controller: stock, keyboard: TextInputType.number)),
            const SizedBox(width: 14),
            Expanded(child: FormField2(label: 'Reorder Level', controller: reorder, keyboard: TextInputType.number)),
          ]),
          const SizedBox(height: 22),
          Row(children: [
            const Spacer(),
            GhostButton(label: 'Cancel', onTap: () => Navigator.pop(context)),
            const SizedBox(width: 12),
            GoldButton(label: editing ? 'Save Changes' : 'Add Item', icon: Icons.check, onTap: () {
              if (name.text.trim().isEmpty) return;
              if (editing) {
                existing!.name = name.text.trim();
                existing.category = cat.text.trim().isEmpty ? 'General' : cat.text.trim();
                existing.price = double.tryParse(price.text.trim()) ?? existing.price;
                existing.stock = int.tryParse(stock.text.trim()) ?? existing.stock;
                existing.reorderLevel = int.tryParse(reorder.text.trim()) ?? existing.reorderLevel;
                appState.updateInventory(existing);
              } else {
                appState.addInventory(InventoryItem(id: appState.createInventoryId(), name: name.text.trim(), category: cat.text.trim().isEmpty ? 'General' : cat.text.trim(), price: double.tryParse(price.text.trim()) ?? 0, stock: int.tryParse(stock.text.trim()) ?? 0, reorderLevel: int.tryParse(reorder.text.trim()) ?? 0));
              }
              Navigator.pop(context);
              setState(() {});
            }),
          ]),
        ]),
      ),
    ));
  }

  // ── Tab 2: Refund Management ───────────────────────────────────────────────
  Widget _refundsTab(AppPalette p) {
    final invoices = appState.invoices.where((i) => i.totalPaid > 0).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(children: [
          Text('${invoices.length} paid invoice(s) eligible for refund', style: p.body(13, color: p.textMuted)),
        ]),
      ),
      Expanded(
        child: Panel(
          padding: EdgeInsets.zero,
          child: invoices.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.receipt_long_outlined, size: 40, color: p.textMuted.withValues(alpha: 0.3)),
                    const SizedBox(height: 8),
                    Text('No paid invoices found', style: p.body(13, color: p.textMuted)),
                  ],
                ),
              )
            : ScrollArea(
                builder: (sc) => SingleChildScrollView(
                  controller: sc,
                  child: FullWidthDataTable(
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(p.surfaceAlt),
                      columnSpacing: 16,
                      horizontalMargin: 20,
                      columns: [
                        DataColumn(label: Text('Patient', style: p.body(12, weight: FontWeight.w700))),
                        DataColumn(label: Text('Invoice ID', style: p.body(12, weight: FontWeight.w700))),
                        DataColumn(label: Text('Amount', style: p.body(12, weight: FontWeight.w700))),
                        DataColumn(label: Text('Paid', style: p.body(12, weight: FontWeight.w700))),
                        DataColumn(label: Text('Date', style: p.body(12, weight: FontWeight.w700))),
                        DataColumn(label: Text('Action', style: p.body(12, weight: FontWeight.w700))),
                      ],
                      rows: invoices.map((inv) => DataRow(cells: [
                        DataCell(Text(inv.patientName, style: p.body(13, weight: FontWeight.w600))),
                        DataCell(Text('#${inv.id}', style: p.body(12.5, color: p.textMuted))),
                        DataCell(Text(money(inv.subtotal), style: p.body(12.5))),
                        DataCell(Text(money(inv.totalPaid), style: p.body(12.5, color: p.success, weight: FontWeight.w600))),
                        DataCell(Text(prettyShort(inv.date), style: p.body(12.5, color: p.textMuted))),
                        DataCell(
                          GestureDetector(
                            onTap: () => _showRefundDialog(inv),
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: p.danger.withValues(alpha: 0.10),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: p.danger.withValues(alpha: 0.35)),
                                ),
                                child: Text('Refund', style: p.body(11.5, color: p.danger, weight: FontWeight.w700)),
                              ),
                            ),
                          ),
                        ),
                      ])).toList(),
                    ),
                  ),
                ),
              ),
        ),
      ),
    ]);
  }

  void _showRefundDialog(Invoice inv) {
    final p = appState.palette;
    final reasonCtrl = TextEditingController();
    final amtCtrl = TextEditingController(text: inv.totalPaid.toStringAsFixed(0));
    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, ss) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 520, padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: p.border)),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: p.danger.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)), child: Icon(Icons.undo_outlined, color: p.danger, size: 22)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('PROCESS REFUND', style: p.display(22, spacing: 0.6)),
              Text('Invoice #${inv.id} — ${inv.patientName}', style: p.body(12, color: p.textMuted)),
            ])),
            GestureDetector(onTap: () => Navigator.pop(ctx), child: Icon(Icons.close, color: p.textMuted)),
          ]),
          const SizedBox(height: 20),
          Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(8), border: Border.all(color: p.border)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ...inv.lines.map((l) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(children: [
              Expanded(child: Text('${l.name} × ${l.qty}', style: p.body(12.5))),
              Text(money(l.total), style: p.body(12.5, weight: FontWeight.w600)),
            ]))),
            Divider(color: p.border, height: 12),
            Row(children: [Text('Total Paid', style: p.body(12.5, color: p.textMuted)), const Spacer(), Text(money(inv.totalPaid), style: p.body(13, color: p.success, weight: FontWeight.w700))]),
          ])),
          const SizedBox(height: 14),
          FormField2(label: 'Refund Amount (PKR)', controller: amtCtrl, hint: inv.totalPaid.toStringAsFixed(0), keyboard: TextInputType.number),
          const SizedBox(height: 12),
          FormField2(label: 'Reason for Refund', controller: reasonCtrl, hint: 'e.g. Patient request, service issue…', maxLines: 2),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            GhostButton(label: 'Cancel', onTap: () => Navigator.pop(ctx)),
            const SizedBox(width: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: p.danger, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: () {
                final amt = double.tryParse(amtCtrl.text.trim()) ?? inv.totalPaid;
                Navigator.pop(ctx);
                toast(context, 'Refund of ${money(amt)} processed for invoice #${inv.id}');
              },
              child: Text('Process Refund', style: p.body(13, weight: FontWeight.w700, color: Colors.white)),
            ),
          ]),
        ]),
      ),
    )));
  }

  // ── Tab 3: Exchange ────────────────────────────────────────────────────────
  Widget _exchangeTab(AppPalette p) {
    final inventory = appState.inventory;
    final oldPrice = _exchangeOld?.price ?? 0.0;
    final newPrice = _exchangeNew?.price ?? 0.0;
    final diff = newPrice - oldPrice;
    return ScrollArea(builder: (sc) => SingleChildScrollView(controller: sc, child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('PRODUCT EXCHANGE', style: p.display(22, spacing: 0.5)),
          const SizedBox(height: 6),
          Text('Select the product being returned and the replacement product', style: p.body(12.5, color: p.textMuted)),
          const SizedBox(height: 24),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('RETURNING PRODUCT', style: p.body(11, color: p.textMuted, weight: FontWeight.w700, spacing: 1.0)),
              const SizedBox(height: 12),
              Dropdown2<InventoryItem?>(
                label: 'Select Product to Return',
                value: _exchangeOld,
                items: [const DropdownMenuItem<InventoryItem?>(value: null, child: Text('— Choose product —')), ...inventory.map((i) => DropdownMenuItem<InventoryItem?>(value: i, child: Text('${i.name} — ${money(i.price)}')))],
                onChanged: (v) => setState(() => _exchangeOld = v),
              ),
              if (_exchangeOld != null) ...[
                const SizedBox(height: 12),
                Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(8), border: Border.all(color: p.border)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(_exchangeOld!.name, style: p.body(14, weight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('Category: ${_exchangeOld!.category}', style: p.body(12.5, color: p.textMuted)),
                  Text('Price: ${money(_exchangeOld!.price)}', style: p.body(12.5, color: p.danger)),
                ])),
              ],
            ])),
            const SizedBox(width: 24),
            Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const SizedBox(height: 40),
              Icon(Icons.swap_horiz, size: 32, color: p.gold),
            ]),
            const SizedBox(width: 24),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('REPLACEMENT PRODUCT', style: p.body(11, color: p.textMuted, weight: FontWeight.w700, spacing: 1.0)),
              const SizedBox(height: 12),
              Dropdown2<InventoryItem?>(
                label: 'Select Replacement Product',
                value: _exchangeNew,
                items: [const DropdownMenuItem<InventoryItem?>(value: null, child: Text('— Choose product —')), ...inventory.where((i) => i.id != _exchangeOld?.id).map((i) => DropdownMenuItem<InventoryItem?>(value: i, child: Text('${i.name} — ${money(i.price)}')))],
                onChanged: (v) => setState(() => _exchangeNew = v),
              ),
              if (_exchangeNew != null) ...[
                const SizedBox(height: 12),
                Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(8), border: Border.all(color: p.border)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(_exchangeNew!.name, style: p.body(14, weight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('Category: ${_exchangeNew!.category}', style: p.body(12.5, color: p.textMuted)),
                  Text('Price: ${money(_exchangeNew!.price)}', style: p.body(12.5, color: p.success)),
                ])),
              ],
            ])),
          ]),
          const SizedBox(height: 24),
          if (_exchangeOld != null && _exchangeNew != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: diff == 0 ? p.surfaceAlt : diff > 0 ? p.warning.withValues(alpha: 0.10) : p.success.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(10), border: Border.all(color: diff == 0 ? p.border : diff > 0 ? p.warning.withValues(alpha: 0.4) : p.success.withValues(alpha: 0.4))),
              child: Row(children: [
                Icon(diff == 0 ? Icons.check_circle_outline : diff > 0 ? Icons.arrow_upward : Icons.arrow_downward, color: diff == 0 ? p.success : diff > 0 ? p.warning : p.success, size: 22),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('PRICE DIFFERENCE', style: p.body(11, color: p.textMuted, weight: FontWeight.w700, spacing: 0.8)),
                  const SizedBox(height: 4),
                  Text(diff == 0 ? 'Equal exchange — no additional charge' : diff > 0 ? 'Customer pays additional ${money(diff.abs())}' : 'Refund ${money(diff.abs())} to customer', style: p.body(13.5, weight: FontWeight.w600)),
                ])),
                Text(diff == 0 ? 'PKR 0' : '${diff > 0 ? '+' : '-'} ${money(diff.abs())}', style: p.display(22, color: diff == 0 ? p.success : diff > 0 ? p.warning : p.success)),
              ]),
            ),
            const SizedBox(height: 16),
          ],
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            GhostButton(label: 'Clear', onTap: () => setState(() { _exchangeOld = null; _exchangeNew = null; })),
            const SizedBox(width: 12),
            GoldButton(
              label: 'Process Exchange',
              icon: Icons.swap_horiz,
              onTap: () {
                if (_exchangeOld == null || _exchangeNew == null) return;
                setState(() { _exchangeOld = null; _exchangeNew = null; });
                toast(context, 'Exchange processed successfully');
              },
            ),
          ]),
        ])),
      ]),
    )));
  }

  // ── Tab 4: Hold Sales ──────────────────────────────────────────────────────
  Widget _holdSalesTab(AppPalette p) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(children: [
          Text('${_heldSales.length} held sale(s)', style: p.body(13, color: p.textMuted)),
          const Spacer(),
          GoldButton(
            label: 'Hold Current Sale',
            icon: Icons.pause_circle_outlined,
            onTap: () {
              _holdSale();
              // Force rebuild via setState already called in _holdSale
            },
          ),
        ]),
      ),
      Expanded(child: _heldSales.isEmpty
        ? Panel(child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.pause_circle_outline, size: 48, color: p.textMuted.withValues(alpha: 0.3)),
            const SizedBox(height: 12),
            Text('No held sales', style: p.body(13, color: p.textMuted)),
            const SizedBox(height: 4),
            Text('Use "Hold Sale" in Billing tab or the button above', style: p.body(12, color: p.textMuted.withValues(alpha: 0.6))),
          ])))
        : ScrollArea(builder: (sc) => ListView.builder(
            controller: sc,
            itemCount: _heldSales.length,
            itemBuilder: (_, i) {
              final h = _heldSales[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: p.border)),
                child: Row(children: [
                  Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: p.warning.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)), child: Icon(Icons.pause_circle_outlined, color: p.warning, size: 22)),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(h.patientName, style: p.body(14, weight: FontWeight.w700)),
                    const SizedBox(height: 3),
                    Text('${h.items.length} item(s)  •  ${money(h.total)}', style: p.body(12.5, color: p.textMuted)),
                    Text('Held at ${h.heldAt.hour.toString().padLeft(2, '0')}:${h.heldAt.minute.toString().padLeft(2, '0')}', style: p.body(11.5, color: p.textMuted)),
                  ])),
                  const SizedBox(width: 12),
                  GoldButton(label: 'Resume', icon: Icons.play_arrow_outlined, dense: true, onTap: () {
                    _restoreHeld(i);
                    _tab.animateTo(0);
                    toast(context, 'Sale restored — switch to Billing');
                  }),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => setState(() => _heldSales.removeAt(i)),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Container(width: 34, height: 34, decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(8)), child: Icon(Icons.delete_outline, size: 16, color: p.textMuted)),
                    ),
                  ),
                ]),
              );
            },
          ))),
    ]);
  }

  // ── Tab 5: End of Day ──────────────────────────────────────────────────────
  Widget _eodTab(AppPalette p) {
    final today = DateTime.now();
    final todayInvoices = appState.invoices.where((i) => i.date.year == today.year && i.date.month == today.month && i.date.day == today.day).toList();
    final grossSales = todayInvoices.fold(0.0, (s, i) => s + i.subtotal);
    final cashCollected = todayInvoices.fold(0.0, (s, i) => s + i.totalPaid);
    final pendingBalance = todayInvoices.fold(0.0, (s, i) => s + i.balance);
    final txCount = todayInvoices.length;
    final netRevenue = cashCollected;

    return ScrollArea(builder: (sc) => SingleChildScrollView(controller: sc, child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // Summary metrics
        MetricRow([
          MetricCard(title: 'Total Sales', value: money(grossSales), icon: Icons.payments_outlined, delta: '$txCount transactions'),
          MetricCard(title: 'Cash Collected', value: money(cashCollected), icon: Icons.account_balance_wallet_outlined, delta: 'paid today'),
          MetricCard(title: 'Card Sales', value: money(cashCollected * 0.4), icon: Icons.credit_card_outlined, delta: 'estimated'),
          MetricCard(title: 'Net Revenue', value: money(netRevenue), icon: Icons.trending_up_outlined, delta: 'after pending'),
          MetricCard(title: 'Total Transactions', value: '$txCount', icon: Icons.receipt_long_outlined, delta: 'invoices today'),
          MetricCard(title: 'Pending Balance', value: money(pendingBalance), deltaUp: false, icon: Icons.pending_outlined, delta: 'outstanding'),
        ]),
        const SizedBox(height: 16),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Cash denominations
          Expanded(child: Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('CASH DENOMINATIONS', style: p.body(11, color: p.textMuted, weight: FontWeight.w700, spacing: 1.0)),
            const SizedBox(height: 4),
            Text('Count notes to verify actual cash', style: p.body(12, color: p.textMuted)),
            const SizedBox(height: 16),
            ..._denomCtrl.entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(children: [
                SizedBox(width: 80, child: Text('PKR ${e.key}', style: p.body(13, weight: FontWeight.w600))),
                const SizedBox(width: 12),
                Container(
                  width: 36, height: 36, alignment: Alignment.center,
                  decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(6), border: Border.all(color: p.border)),
                  child: Text('×', style: p.body(14, color: p.textMuted)),
                ),
                const SizedBox(width: 8),
                SizedBox(width: 100, child: TextField(
                  controller: e.value,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: p.body(14, weight: FontWeight.w700),
                  cursorColor: p.gold,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    isDense: true, filled: true, fillColor: p.surfaceAlt,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: p.border)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: p.gold, width: 1.5)),
                  ),
                  onChanged: (_) => setState(() {}),
                )),
                const SizedBox(width: 12),
                Text('= ${money((int.tryParse(e.value.text) ?? 0) * e.key.toDouble())}', style: p.body(13, color: p.textMuted)),
              ]),
            )),
            Divider(color: p.border, height: 24),
            Row(children: [
              Text('TOTAL CASH COUNTED', style: p.body(13, weight: FontWeight.w700)),
              const Spacer(),
              Text(money(_denomTotal), style: p.display(22, color: p.gold)),
            ]),
          ]))),
          const SizedBox(width: 16),
          // Expected vs actual + actions
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('EXPECTED vs ACTUAL CASH', style: p.body(11, color: p.textMuted, weight: FontWeight.w700, spacing: 1.0)),
              const SizedBox(height: 16),
              _eodBar(p, 'Expected', cashCollected, cashCollected),
              const SizedBox(height: 10),
              _eodBar(p, 'Actual (Counted)', _denomTotal, cashCollected),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Variance', style: p.body(12.5, color: p.textMuted)),
                  const SizedBox(height: 3),
                  Text(
                    _denomTotal == 0 ? '—' : money((_denomTotal - cashCollected).abs()),
                    style: p.body(15, weight: FontWeight.w700, color: _denomTotal == cashCollected ? p.success : p.danger),
                  ),
                ])),
                if (_denomTotal > 0) StatusChip(
                  label: _denomTotal == cashCollected ? 'Balanced' : _denomTotal > cashCollected ? 'Overage' : 'Shortage',
                  color: _denomTotal == cashCollected ? p.success : p.danger,
                ),
              ]),
            ])),
            const SizedBox(height: 12),
            Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Text('DAY SUMMARY', style: p.body(11, color: p.textMuted, weight: FontWeight.w700, spacing: 1.0)),
              const SizedBox(height: 12),
              _eodRow(p, 'Date', prettyDate(today)),
              _eodRow(p, 'Total Invoices', '$txCount'),
              _eodRow(p, 'Gross Revenue', money(grossSales)),
              _eodRow(p, 'Cash Collected', money(cashCollected)),
              _eodRow(p, 'Outstanding', money(pendingBalance), danger: pendingBalance > 0),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: GhostButton(label: 'Print Z-Report', icon: Icons.print_outlined, onTap: () => toast(context, 'Z-Report sent to printer'))),
                const SizedBox(width: 10),
                Expanded(child: GoldButton(label: 'Close Day', icon: Icons.check_circle_outline, onTap: () => toast(context, 'Day closed successfully — have a great evening!'))),
              ]),
            ])),
          ])),
        ]),
      ]),
    )));
  }

  Widget _eodRow(AppPalette p, String label, String value, {bool danger = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(children: [
      Expanded(child: Text(label, style: p.body(13, color: p.textMuted))),
      Text(value, style: p.body(14, weight: FontWeight.w700, color: danger ? Colors.orange.shade400 : p.text)),
    ]),
  );

  Widget _eodBar(AppPalette p, String label, double value, double max) {
    final pct = max > 0 ? (value / max).clamp(0.0, 1.0) : 0.0;
    final color = label.contains('Actual') ? p.info : p.gold;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: Text(label, style: p.body(12, color: p.textMuted))),
        Text(money(value), style: p.body(12.5, weight: FontWeight.w600)),
      ]),
      const SizedBox(height: 5),
      LayoutBuilder(builder: (ctx, c) => Stack(children: [
        Container(height: 12, decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(6))),
        AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          height: 12, width: c.maxWidth * pct,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.75), borderRadius: BorderRadius.circular(6)),
        ),
      ])),
    ]);
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// INVOICE RECEIPT DIALOG
// ══════════════════════════════════════════════════════════════════════════════
class InvoiceReceiptDialog extends StatelessWidget {
  final Invoice invoice;
  final VoidCallback? onPaymentRecorded;
  const InvoiceReceiptDialog({super.key, required this.invoice, this.onPaymentRecorded});

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    return Dialog(
      backgroundColor: p.surface, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: p.border)),
      child: Container(
        width: 480, constraints: const BoxConstraints(maxHeight: 720), padding: const EdgeInsets.all(28),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            Container(width: 46, height: 46, decoration: BoxDecoration(gradient: p.goldGradient, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.spa_outlined, color: Colors.black87, size: 24)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('HAIR AGAIN', style: p.display(28, spacing: 1.5)), Text('Hair Transplant & Care • Karachi', style: p.body(11, color: p.textMuted))])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: (invoice.isPaid ? p.success : p.warning).withValues(alpha: 0.14), borderRadius: BorderRadius.circular(8)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(invoice.isPaid ? Icons.check_circle : Icons.schedule_outlined, size: 14, color: invoice.isPaid ? p.success : p.warning),
                const SizedBox(width: 5),
                Text(invoice.isPaid ? 'PAID' : 'PENDING', style: p.body(11, color: invoice.isPaid ? p.success : p.warning, weight: FontWeight.w700)),
              ]),
            ),
          ]),
          const SizedBox(height: 20),
          _dashed(p),
          const SizedBox(height: 16),
          Row(children: [_kv(p, 'INVOICE', invoice.id), const Spacer(), _kv(p, 'DATE', prettyDate(invoice.date), end: true)]),
          const SizedBox(height: 10),
          _kv(p, 'BILLED TO', invoice.patientName),
          const SizedBox(height: 16),
          _dashed(p),
          const SizedBox(height: 14),
          Flexible(
            child: SingleChildScrollView(
              child: Column(children: [
                Row(children: [Expanded(flex: 5, child: Text('ITEM', style: p.body(10.5, color: p.textMuted, weight: FontWeight.w700, spacing: 0.8))), Expanded(flex: 1, child: Text('QTY', textAlign: TextAlign.center, style: p.body(10.5, color: p.textMuted, weight: FontWeight.w700))), Expanded(flex: 2, child: Text('AMOUNT', textAlign: TextAlign.right, style: p.body(10.5, color: p.textMuted, weight: FontWeight.w700)))]),
                const SizedBox(height: 10),
                ...invoice.lines.map((l) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(flex: 5, child: Text(l.name, style: p.body(12.5, weight: FontWeight.w500))), Expanded(flex: 1, child: Text('${l.qty}', textAlign: TextAlign.center, style: p.body(12.5))), Expanded(flex: 2, child: Text(money(l.total), textAlign: TextAlign.right, style: p.body(12.5, weight: FontWeight.w600)))]))),
              ]),
            ),
          ),
          const SizedBox(height: 6),
          _dashed(p),
          const SizedBox(height: 14),
          _sum(p, 'Subtotal', money(invoice.subtotal)),
          const SizedBox(height: 8),
          _sum(p, 'Advance Paid', '- ${money(invoice.advance)}'),
          const SizedBox(height: 12),
          Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(gradient: p.goldGradient, borderRadius: BorderRadius.circular(8)), child: Row(children: [Text('BALANCE DUE', style: p.body(13, color: Colors.black87, weight: FontWeight.w700)), const Spacer(), Text(money(invoice.balance), style: p.display(26, color: Colors.black87))])),
          const SizedBox(height: 18),
          Center(child: Text('Thank you for choosing HAIR AGAIN', style: p.body(11.5, color: p.textMuted))),
          const SizedBox(height: 18),
          Row(children: [Expanded(child: GhostButton(label: 'View / Print PDF', icon: Icons.picture_as_pdf_outlined, onTap: () => showPdfPreview(context, title: 'Invoice ${invoice.id}', build: () => buildInvoicePdf(invoice)))), const SizedBox(width: 12), Expanded(child: GoldButton(label: 'Done', icon: Icons.check, onTap: () => Navigator.pop(context)))]),
        ]),
      ),
    );
  }

  Widget _kv(AppPalette p, String k, String v, {bool end = false}) => Column(crossAxisAlignment: end ? CrossAxisAlignment.end : CrossAxisAlignment.start, children: [Text(k, style: p.body(10, color: p.textMuted, weight: FontWeight.w700, spacing: 0.8)), const SizedBox(height: 3), Text(v, style: p.body(13.5, weight: FontWeight.w600))]);
  Widget _sum(AppPalette p, String k, String v) => Row(children: [Text(k, style: p.body(13, color: p.textMuted)), const Spacer(), Text(v, style: p.body(13.5, weight: FontWeight.w600))]);
  Widget _dashed(AppPalette p) => LayoutBuilder(builder: (context, c) { final count = (c.maxWidth / 8).floor(); return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: List.generate(count, (_) => Container(width: 4, height: 1, color: p.border))); });
}
