// modules/pos_inventory/views — billing checkout + cart + split payment, the
// printable thermal-style receipt modal, and inventory table with stock
// steppers and low-stock markers.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/core.dart';
import '../models/pos_models.dart';
import '../../crm/models/patient.dart';
import '../../appointments/models/appointment.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});
  @override
  State<PosScreen> createState() => PosScreenState();
}

enum _StockFilter { all, inStock, low }

enum _InvSort { nameAz, priceHi, stockLo }

class PosScreenState extends State<PosScreen> {
  int _tab = 0;
  _StockFilter _stockFilter = _StockFilter.all;
  _InvSort _invSort = _InvSort.nameAz;
  String _itemSearch = '';
  String _cat = 'All';
  Patient? _patient;
  final List<InvoiceLine> _cart = [];
  final _advance = TextEditingController(text: '0');
  String _txSearch = '';
  final List<({String label, Patient? patient, List<InvoiceLine> lines, double advance})> _heldSales = [];

  void focusBilling() => setState(() => _tab = 0);
  void showLowStock() => setState(() { _tab = 1; _stockFilter = _StockFilter.low; });

  @override
  void dispose() {
    _advance.dispose();
    super.dispose();
  }

  double get _subtotal => _cart.fold(0, (s, l) => s + l.total);
  double get _balance {
    final a = double.tryParse(_advance.text.trim()) ?? 0;
    return (_subtotal - a).clamp(0, double.infinity);
  }

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    return ScreenScaffold(
      title: 'POS & INVENTORY',
      subtitle: 'Bill treatments, manage installments and track clinic stock.',
      actions: [
        _seg(p, 'Billing', 0, Icons.receipt_long_outlined),
        const SizedBox(width: 8),
        _seg(p, 'Inventory', 1, Icons.inventory_2_outlined),
        const SizedBox(width: 8),
        GhostButton(label: 'Refund', icon: Icons.undo_outlined, onTap: () => _showRefundDialog()),
        const SizedBox(width: 8),
        GhostButton(label: 'End of Day', icon: Icons.summarize_outlined, onTap: () => _showEndOfDay()),
      ],
      child: LayoutBuilder(builder: (ctx, c) {
        return ScrollArea(builder: (sc) => SingleChildScrollView(
          controller: sc,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: MetricRow([
                MetricCard(title: "Today's Sales", value: moneyShort(appState.todaysSales), delta: '+8%', icon: Icons.payments_outlined),
                MetricCard(title: 'Pending Installments', value: moneyShort(appState.pendingInstallments), delta: '${appState.invoices.where((i) => i.balance > 0).length} overdue', deltaUp: false, icon: Icons.schedule_outlined),
                MetricCard(title: 'Inventory Items', value: '${appState.inventoryCount}', delta: '+1 item added', icon: Icons.inventory_2_outlined),
                MetricCard(title: 'Low Stock Warnings', value: '${appState.lowStockCount}', delta: '${appState.lowStockCount} need reorder', deltaUp: false, icon: Icons.warning_amber_outlined),
              ]),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: c.maxHeight,
              child: Padding(
                padding: const EdgeInsets.only(right: 12, bottom: 16),
                child: _tab == 0 ? _billing(p) : _inventory(p),
              ),
            ),
          ]),
        ));
      }),
    );
  }

  Widget _seg(AppPalette p, String label, int idx, IconData icon) {
    final sel = _tab == idx;
    return GestureDetector(
      onTap: () => setState(() => _tab = idx),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(duration: const Duration(milliseconds: 140), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), decoration: BoxDecoration(gradient: sel ? p.goldGradient : null, color: sel ? null : p.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: sel ? Colors.transparent : p.border)), child: Row(children: [Icon(icon, size: 17, color: sel ? Colors.black87 : p.text), const SizedBox(width: 8), Text(label, style: p.body(13, color: sel ? Colors.black87 : p.text, weight: FontWeight.w600))])),
      ),
    );
  }

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
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [const SectionTitle('CURRENT BILL'), const Spacer(), if (_cart.isNotEmpty) GestureDetector(onTap: () => setState(_cart.clear), child: Text('Clear', style: p.body(12.5, color: p.danger, weight: FontWeight.w600)))]),
            const SizedBox(height: 4),
            Text(_patient == null ? 'No patient selected' : 'For: ${_patient!.name}', style: p.body(12, color: p.textMuted)),
            const SizedBox(height: 10),
            Expanded(child: _cart.isEmpty ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.shopping_cart_outlined, size: 36, color: p.textMuted.withValues(alpha: 0.5)), const SizedBox(height: 8), Text('Add treatments to start billing', style: p.body(12.5, color: p.textMuted))])) : ScrollArea(builder: (sc) => ListView.separated(controller: sc, padding: const EdgeInsets.only(right: 12), itemCount: _cart.length, separatorBuilder: (_, _) => Divider(height: 14, color: p.border), itemBuilder: (_, i) => _cartRow(p, _cart[i])))),
            Divider(height: 16, color: p.border),
            _total(p, 'Subtotal', money(_subtotal), muted: true),
            const SizedBox(height: 8),
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
            const SizedBox(height: 8),
            Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), decoration: BoxDecoration(color: p.gold.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(8), border: Border.all(color: p.gold.withValues(alpha: 0.4))), child: Row(children: [Text('BALANCE DUE', style: p.body(12.5, weight: FontWeight.w700)), const Spacer(), Flexible(child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerRight, child: Text(money(_balance), style: p.display(24, color: p.gold))))])),
            const SizedBox(height: 10),
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
                      Expanded(child: Text(e.value.label, style: p.body(12.5, color: p.gold))),
                      Text(money(e.value.lines.fold(0.0, (s, l) => s + l.total)), style: p.body(12, color: p.textMuted)),
                    ]))),
                  )),
                ]),
              ),
            ],
            Row(children: [
              Expanded(child: GhostButton(label: 'Hold Sale', icon: Icons.pause_circle_outlined, onTap: _holdSale)),
              const SizedBox(width: 10),
              Expanded(flex: 2, child: GoldButton(label: 'Generate Invoice', icon: Icons.receipt_long, onTap: _generate)),
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
      _heldSales.add((label: label, patient: _patient, lines: List.of(_cart), advance: double.tryParse(_advance.text) ?? 0));
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
      _patient = held.patient;
      _cart.clear();
      _cart.addAll(held.lines);
      _advance.text = held.advance.toStringAsFixed(0);
    });
  }

  void _showRefundDialog() {
    final p = appState.palette;
    final invoices = appState.invoices.where((i) => i.totalPaid > 0).toList();
    Invoice? selected;
    final reasonCtrl = TextEditingController();
    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, ss) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 520, padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(6), border: Border.all(color: p.border)),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.undo_outlined, color: Colors.red, size: 22)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('PROCESS REFUND', style: p.display(22, spacing: 0.6)), Text('Select invoice to refund', style: p.body(12, color: p.textMuted))])),
            GestureDetector(onTap: () => Navigator.pop(ctx), child: MouseRegion(cursor: SystemMouseCursors.click, child: Icon(Icons.close, color: p.textMuted))),
          ]),
          const SizedBox(height: 20),
          Dropdown2<Invoice?>(
            label: 'Select Invoice',
            value: selected,
            items: [const DropdownMenuItem<Invoice?>(value: null, child: Text('— Choose invoice —')), ...invoices.map((inv) => DropdownMenuItem<Invoice?>(value: inv, child: Text('#${inv.id} — ${inv.patientName} — ${money(inv.subtotal)}')))],
            onChanged: (v) => ss(() => selected = v),
          ),
          if (selected != null) ...[
            const SizedBox(height: 14),
            Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(8), border: Border.all(color: p.border)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Invoice #${selected!.id}', style: p.body(13, weight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text('Patient: ${selected!.patientName}', style: p.body(12.5, color: p.textMuted)),
              Text('Amount Paid: ${money(selected!.totalPaid)}', style: p.body(12.5, color: p.textMuted)),
              Text('Date: ${prettyShort(selected!.date)}', style: p.body(12.5, color: p.textMuted)),
            ])),
          ],
          const SizedBox(height: 14),
          FormField2(label: 'Reason for Refund', controller: reasonCtrl, hint: 'e.g. Patient request, service issue…', maxLines: 2),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            GhostButton(label: 'Cancel', onTap: () => Navigator.pop(ctx)),
            const SizedBox(width: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: selected == null ? null : () {
                Navigator.pop(ctx);
                toast(context, 'Refund processed for invoice #${selected!.id} — ${money(selected!.totalPaid)}');
              },
              child: Text('Process Refund', style: p.body(13, weight: FontWeight.w700, color: Colors.white)),
            ),
          ]),
        ]),
      ),
    )));
  }

  void _showEndOfDay() {
    final p = appState.palette;
    final today = DateTime.now();
    final todayInvoices = appState.invoices.where((i) => i.date.year == today.year && i.date.month == today.month && i.date.day == today.day).toList();
    final todayCash = todayInvoices.fold(0.0, (s, i) => s + i.totalPaid);
    final todayBalance = todayInvoices.fold(0.0, (s, i) => s + i.balance);
    showDialog(context: context, builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 520, padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(6), border: Border.all(color: p.border)),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: p.gold.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)), child: Icon(Icons.summarize_outlined, color: p.gold, size: 22)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('END OF DAY SUMMARY', style: p.display(20, spacing: 0.6)), Text(prettyDate(today), style: p.body(12, color: p.textMuted))])),
            GestureDetector(onTap: () => Navigator.pop(ctx), child: MouseRegion(cursor: SystemMouseCursors.click, child: Icon(Icons.close, color: p.textMuted))),
          ]),
          const SizedBox(height: 20),
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(8), border: Border.all(color: p.border)), child: Column(children: [
            _eodRow(p, 'Total Invoices', '${todayInvoices.length}'),
            _eodRow(p, "Today's Gross", money(todayInvoices.fold(0.0, (s, i) => s + i.subtotal))),
            _eodRow(p, 'Cash Collected', money(todayCash)),
            _eodRow(p, 'Pending Balance', money(todayBalance), danger: todayBalance > 0),
            _eodRow(p, 'Appointments Seen', '${appState.appointments.where((a) => a.when.day == today.day && a.when.month == today.month && a.status == ApptStatus.confirmed).length}'),
          ])),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: GhostButton(label: 'Close', onTap: () => Navigator.pop(ctx))),
            const SizedBox(width: 12),
            Expanded(child: GoldButton(label: 'Print Report', icon: Icons.print_outlined, onTap: () { Navigator.pop(ctx); toast(context, 'End-of-day report sent to printer'); })),
          ]),
        ]),
      ),
    ));
  }

  Widget _eodRow(AppPalette p, String label, String value, {bool danger = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(children: [
      Expanded(child: Text(label, style: p.body(13, color: p.textMuted))),
      Text(value, style: p.body(14, weight: FontWeight.w700, color: danger ? Colors.orange.shade400 : p.text)),
    ]),
  );

  void _generate() {
    if (_patient == null) return toast(context, 'Select a patient first');
    if (_cart.isEmpty) return toast(context, 'Add at least one treatment');
    final adv = double.tryParse(_advance.text.trim()) ?? 0;
    final inv = Invoice(id: appState.createInvoiceId(), patientName: _patient!.name, lines: _cart.map((l) => InvoiceLine(name: l.name, qty: l.qty, price: l.price)).toList(), advance: adv, date: DateTime.now());
    appState.addInvoice(inv);
    showDialog(context: context, barrierColor: Colors.black.withValues(alpha: 0.6), builder: (_) => InvoiceReceiptDialog(invoice: inv));
    setState(() { _cart.clear(); _advance.text = '0'; _patient = null; });
  }

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
      case _InvSort.nameAz:
        items.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      case _InvSort.priceHi:
        items.sort((a, b) => b.price.compareTo(a.price));
      case _InvSort.stockLo:
        items.sort((a, b) => a.stock.compareTo(b.stock));
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child: FilterBar(
            searchHint: 'Search items or categories…',
            onSearch: (v) => setState(() => _itemSearch = v),
            filters: [
              FilterDropdown<String>(
                icon: Icons.category_outlined,
                value: cats.contains(_cat) ? _cat : 'All',
                items: cats.map((c) => DropdownMenuItem(value: c, child: Text(c == 'All' ? 'All Categories' : c))).toList(),
                onChanged: (v) => setState(() => _cat = v ?? 'All'),
              ),
              FilterDropdown<_StockFilter>(
                icon: Icons.inventory_outlined,
                value: _stockFilter,
                items: const [
                  DropdownMenuItem(value: _StockFilter.all, child: Text('All Stock')),
                  DropdownMenuItem(value: _StockFilter.inStock, child: Text('In Stock')),
                  DropdownMenuItem(value: _StockFilter.low, child: Text('Low Stock')),
                ],
                onChanged: (v) => setState(() => _stockFilter = v ?? _StockFilter.all),
              ),
              FilterDropdown<_InvSort>(
                icon: Icons.sort,
                value: _invSort,
                items: const [
                  DropdownMenuItem(value: _InvSort.nameAz, child: Text('Name A–Z')),
                  DropdownMenuItem(value: _InvSort.priceHi, child: Text('Price High→Low')),
                  DropdownMenuItem(value: _InvSort.stockLo, child: Text('Stock Low→High')),
                ],
                onChanged: (v) => setState(() => _invSort = v ?? _InvSort.nameAz),
              ),
            ],
            countText: 'Showing ${items.length} of ${appState.inventory.length}',
            onClear: () => setState(() { _itemSearch = ''; _cat = 'All'; _stockFilter = _StockFilter.all; _invSort = _InvSort.nameAz; }),
          ),
        ),
        const SizedBox(width: 12),
        Padding(padding: const EdgeInsets.only(top: 4), child: GoldButton(label: 'Add Item', icon: Icons.add, dense: true, onTap: _addItem)),
      ]),
      const SizedBox(height: 16),
      Expanded(
        child: Panel(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Row(children: [Expanded(flex: 4, child: _th(p, 'ITEM')), Expanded(flex: 2, child: _th(p, 'CATEGORY')), Expanded(flex: 2, child: _th(p, 'PRICE')), Expanded(flex: 3, child: _th(p, 'STOCK')), Expanded(flex: 2, child: _th(p, 'STATUS')), const SizedBox(width: 72)])),
            const SizedBox(height: 6),
            Divider(height: 1, color: p.border),
            Expanded(child: items.isEmpty ? Center(child: Text('No inventory items found.', style: p.body(13, color: p.textMuted))) : ScrollArea(builder: (sc) => ListView.separated(controller: sc, padding: const EdgeInsets.only(right: 12), itemCount: items.length, separatorBuilder: (_, _) => Divider(height: 1, color: p.border), itemBuilder: (_, i) => _invRow(p, items[i])))),
          ]),
        ),
      ),
    ]);
  }

  Widget _th(AppPalette p, String t) => Text(t, style: p.body(11, color: p.textMuted, weight: FontWeight.w700, spacing: 0.8));

  Widget _invRow(AppPalette p, InventoryItem item) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Row(children: [
          Expanded(flex: 4, child: Row(children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(8)), child: Icon(Icons.inventory_2_outlined, size: 16, color: p.gold)), const SizedBox(width: 12), Expanded(child: Text(item.name, style: p.body(13.5, weight: FontWeight.w600), overflow: TextOverflow.ellipsis))])),
          Expanded(flex: 2, child: Text(item.category, style: p.body(13, color: p.textMuted))),
          Expanded(flex: 2, child: Text(money(item.price), style: p.body(13))),
          Expanded(flex: 3, child: Row(children: [QtyButton(Icons.remove, () => appState.adjustStock(item, -1)), Container(width: 44, alignment: Alignment.center, child: Text('${item.stock}', style: p.body(14, weight: FontWeight.w700))), QtyButton(Icons.add, () => appState.adjustStock(item, 1))])),
          Expanded(flex: 2, child: Align(alignment: Alignment.centerLeft, child: item.isLow ? StatusChip(label: 'Low Stock', color: p.danger) : StatusChip(label: 'In Stock', color: p.success))),
          SizedBox(width: 72, child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            GestureDetector(onTap: () => _editItem(item), child: MouseRegion(cursor: SystemMouseCursors.click, child: Container(width: 30, height: 30, decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(8)), child: Icon(Icons.edit_outlined, size: 15, color: p.text)))),
            const SizedBox(width: 6),
            GestureDetector(onTap: () async { final ok = await confirm(context, 'Delete item?', 'Remove "${item.name}" from inventory.'); if (ok) appState.deleteInventory(item); }, child: MouseRegion(cursor: SystemMouseCursors.click, child: Container(width: 30, height: 30, decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(8)), child: Icon(Icons.delete_outline, size: 15, color: p.textMuted)))),
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
            }),
          ]),
        ]),
      ),
    ));
  }
}

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
