import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../models/vendor_models.dart';

class VendorsScreen extends StatefulWidget {
  const VendorsScreen({super.key});
  @override
  State<VendorsScreen> createState() => _VendorsScreenState();
}

class _VendorsScreenState extends State<VendorsScreen> with SingleTickerProviderStateMixin {
  late final TabController _tab;
  @override
  void initState() { super.initState(); _tab = TabController(length: 3, vsync: this); }
  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    return ScreenScaffold(
      title: 'VENDORS & PURCHASING',
      subtitle: 'Vendor directory, purchase orders & goods receiving management',
      actions: [
        Container(height: 42,
          decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: p.border)),
          child: TabBar(controller: _tab, isScrollable: true, dividerColor: Colors.transparent,
            indicatorColor: p.gold, indicatorSize: TabBarIndicatorSize.label,
            labelStyle: p.body(12.5, weight: FontWeight.w600), unselectedLabelStyle: p.body(12.5),
            labelColor: p.gold, unselectedLabelColor: p.textMuted, tabAlignment: TabAlignment.start,
            tabs: const [Tab(text: 'Vendors'), Tab(text: 'Purchase Orders'), Tab(text: 'Goods Receiving')]),
        ),
      ],
      child: TabBarView(controller: _tab, children: const [
        _VendorsTab(), _POTab(), _GRTab(),
      ]),
    );
  }
}

// ── Vendors ──────────────────────────────────────────────────────────────────
class _VendorsTab extends StatefulWidget {
  const _VendorsTab();
  @override
  State<_VendorsTab> createState() => _VendorsTabState();
}

class _VendorsTabState extends State<_VendorsTab> {
  String _q = '';

  void _showDetail(Vendor v) {
    final p = appState.palette;
    showDialog(context: context, builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(width: 560, padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: p.border)),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 52, height: 52, alignment: Alignment.center,
              decoration: BoxDecoration(color: p.gold.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.storefront_outlined, size: 24, color: p.gold)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(v.name, style: p.display(20)),
              Text('${v.category} · ${v.city}', style: p.body(12.5, color: p.textMuted)),
            ])),
            StatusChip(label: v.isActive ? 'Active' : 'Inactive', color: v.isActive ? p.success : p.textMuted),
            const SizedBox(width: 12),
            GestureDetector(onTap: () => Navigator.pop(ctx), child: MouseRegion(cursor: SystemMouseCursors.click, child: Icon(Icons.close, size: 20, color: p.textMuted))),
          ]),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(12), border: Border.all(color: p.border)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('CONTACT', style: p.body(11, weight: FontWeight.w700, spacing: 1.0, color: p.textMuted)), const SizedBox(height: 10),
              _r(p, Icons.person_outline, v.contactPerson), _r(p, Icons.phone_outlined, v.phone),
              _r(p, Icons.email_outlined, v.email), _r(p, Icons.location_on_outlined, '${v.address}, ${v.city}'),
            ]))),
            const SizedBox(width: 12),
            Expanded(child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(12), border: Border.all(color: p.border)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('FINANCIALS', style: p.body(11, weight: FontWeight.w700, spacing: 1.0, color: p.textMuted)), const SizedBox(height: 10),
              _kv(p, 'Total Purchases', money(v.totalPurchases)),
              _kv(p, 'Outstanding', money(v.outstandingBalance)),
              _kv(p, 'Payment Terms', v.paymentTerms),
              _kv(p, 'Tax ID', v.taxId.isEmpty ? '—' : v.taxId),
            ]))),
          ]),
          if (v.notes.isNotEmpty) ...[const SizedBox(height: 14), Text('NOTES', style: p.body(11, weight: FontWeight.w700, spacing: 1.0, color: p.textMuted)), const SizedBox(height: 6), Text(v.notes, style: p.body(13))],
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [GhostButton(label: 'Close', onTap: () => Navigator.pop(ctx))]),
        ]),
      ),
    ));
  }

  Widget _r(AppPalette p, IconData ic, String t) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [Icon(ic, size: 14, color: p.textMuted), const SizedBox(width: 8), Expanded(child: Text(t, style: p.body(12.5), maxLines: 1, overflow: TextOverflow.ellipsis))]));
  Widget _kv(AppPalette p, String k, String v) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [Expanded(child: Text(k, style: p.body(12, color: p.textMuted))), Text(v, style: p.body(12.5, weight: FontWeight.w600))]));

  void _showForm({Vendor? existing}) {
    final editing = existing != null;
    final p = appState.palette;
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final contactCtrl = TextEditingController(text: existing?.contactPerson ?? '');
    final phoneCtrl = TextEditingController(text: existing?.phone ?? '');
    final emailCtrl = TextEditingController(text: existing?.email ?? '');
    final addrCtrl = TextEditingController(text: existing?.address ?? '');
    final cityCtrl = TextEditingController(text: existing?.city ?? 'Karachi');
    final catCtrl = TextEditingController(text: existing?.category ?? 'Products');
    final notesCtrl = TextEditingController(text: existing?.notes ?? '');
    showDialog(context: context, builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(width: 540, padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: p.border)),
        child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(editing ? 'EDIT VENDOR' : 'ADD VENDOR', style: p.display(22, spacing: 1.0)),
          const SizedBox(height: 20),
          Row(children: [Expanded(child: FormField2(label: 'Vendor Name *', controller: nameCtrl, hint: 'Company name')), const SizedBox(width: 14), Expanded(child: FormField2(label: 'Category', controller: catCtrl, hint: 'Products / Services'))]),
          const SizedBox(height: 14),
          Row(children: [Expanded(child: FormField2(label: 'Contact Person', controller: contactCtrl, hint: 'Name')), const SizedBox(width: 14), Expanded(child: FormField2(label: 'Phone', controller: phoneCtrl, hint: '+92 ...'))]),
          const SizedBox(height: 14),
          Row(children: [Expanded(child: FormField2(label: 'Email', controller: emailCtrl, hint: 'vendor@email.com')), const SizedBox(width: 14), Expanded(child: FormField2(label: 'City', controller: cityCtrl, hint: 'Karachi'))]),
          const SizedBox(height: 14),
          FormField2(label: 'Address', controller: addrCtrl, hint: 'Street address'),
          const SizedBox(height: 14),
          FormField2(label: 'Notes', controller: notesCtrl, hint: 'Optional remarks…', maxLines: 2),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            GhostButton(label: 'Cancel', onTap: () => Navigator.pop(ctx)),
            const SizedBox(width: 12),
            GoldButton(label: editing ? 'Save Changes' : 'Add Vendor', onTap: () {
              if (nameCtrl.text.isEmpty) return;
              if (editing) {
                existing!.name = nameCtrl.text; existing.contactPerson = contactCtrl.text; existing.phone = phoneCtrl.text;
                existing.email = emailCtrl.text; existing.address = addrCtrl.text; existing.city = cityCtrl.text;
                existing.category = catCtrl.text; existing.notes = notesCtrl.text; appState.touch();
              } else {
                appState.addVendor(Vendor(id: appState.createVendorId(), name: nameCtrl.text, contactPerson: contactCtrl.text, phone: phoneCtrl.text, email: emailCtrl.text, address: addrCtrl.text, city: cityCtrl.text, category: catCtrl.text, notes: notesCtrl.text));
              }
              Navigator.pop(ctx); setState(() {});
            }),
          ]),
        ])),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    var list = appState.vendors;
    if (_q.isNotEmpty) list = list.where((v) => v.name.toLowerCase().contains(_q.toLowerCase()) || v.category.toLowerCase().contains(_q.toLowerCase())).toList();

    return Column(children: [
      FilterBar(searchHint: 'Search vendors…', onSearch: (v) => setState(() => _q = v), filters: [], countText: '${list.length} vendors', onClear: () => setState(() => _q = ''),
        trailing: [GoldButton(label: 'Add Vendor', icon: Icons.add, onTap: () => _showForm())]),
      const SizedBox(height: 12),
      Expanded(child: list.isEmpty
        ? Center(child: Text('No vendors added.', style: p.body(13, color: p.textMuted)))
        : ScrollArea(builder: (sc) => ListView.separated(controller: sc, padding: const EdgeInsets.only(right: 8), itemCount: list.length, separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final v = list[i];
              return MouseRegion(cursor: SystemMouseCursors.click, child: GestureDetector(onTap: () => _showDetail(v), child: Panel(child: Row(children: [
                Container(width: 44, height: 44, alignment: Alignment.center,
                  decoration: BoxDecoration(color: p.gold.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                  child: Icon(Icons.storefront_outlined, size: 22, color: p.gold)),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(v.name, style: p.body(13.5, weight: FontWeight.w700)),
                  Text('${v.category} · ${v.contactPerson} · ${v.phone}', style: p.body(12, color: p.textMuted)),
                ])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  StatusChip(label: v.isActive ? 'Active' : 'Inactive', color: v.isActive ? p.success : p.textMuted),
                  const SizedBox(height: 6),
                  Text(money(v.totalPurchases), style: p.body(12.5, color: p.textMuted)),
                ]),
                const SizedBox(width: 10),
                _sqBtn(p, Icons.edit_outlined, p.text, () => _showForm(existing: v)),
              ]))));
            }))),
    ]);
  }
  Widget _sqBtn(AppPalette p, IconData ic, Color c, VoidCallback fn) => GestureDetector(onTap: fn, child: MouseRegion(cursor: SystemMouseCursors.click, child: Container(width: 30, height: 30, decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(8)), child: Icon(ic, size: 15, color: c))));
}

// ── Purchase Orders ──────────────────────────────────────────────────────────
class _POTab extends StatefulWidget {
  const _POTab();
  @override
  State<_POTab> createState() => _POTabState();
}

class _POTabState extends State<_POTab> {
  String _q = '';
  POStatus? _statusFilter;

  void _showDetail(PurchaseOrder po) {
    final p = appState.palette;
    final statusColor = _poColor(p, po.status);
    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, ss) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(width: 620, padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: p.border)),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('PO #${po.id}', style: p.display(20)),
              Text('${po.vendorName} · ${prettyShort(po.orderDate)}', style: p.body(12.5, color: p.textMuted)),
            ])),
            StatusChip(label: po.status.label, color: statusColor),
            const SizedBox(width: 12),
            GestureDetector(onTap: () => Navigator.pop(ctx), child: MouseRegion(cursor: SystemMouseCursors.click, child: Icon(Icons.close, size: 20, color: p.textMuted))),
          ]),
          const SizedBox(height: 16),
          Panel(padding: EdgeInsets.zero, child: Column(children: [
            Padding(padding: const EdgeInsets.all(14), child: Row(children: [
              Expanded(child: Text('Item', style: p.body(12, weight: FontWeight.w700))),
              SizedBox(width: 60, child: Text('Qty', style: p.body(12, weight: FontWeight.w700), textAlign: TextAlign.center)),
              SizedBox(width: 80, child: Text('Unit Price', style: p.body(12, weight: FontWeight.w700), textAlign: TextAlign.right)),
              SizedBox(width: 90, child: Text('Total', style: p.body(12, weight: FontWeight.w700), textAlign: TextAlign.right)),
            ])),
            const Divider(height: 1),
            ...po.items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(children: [
                Expanded(child: Text(item.name, style: p.body(12.5))),
                SizedBox(width: 60, child: Text('${item.qty}', style: p.body(12.5), textAlign: TextAlign.center)),
                SizedBox(width: 80, child: Text(money(item.unitPrice), style: p.body(12.5), textAlign: TextAlign.right)),
                SizedBox(width: 90, child: Text(money(item.total), style: p.body(12.5, weight: FontWeight.w600), textAlign: TextAlign.right)),
              ]),
            )),
            const Divider(height: 1),
            Padding(padding: const EdgeInsets.all(14), child: Row(children: [
              const Spacer(), Text('TOTAL', style: p.body(13, weight: FontWeight.w700)),
              const SizedBox(width: 20),
              Text(money(po.totalAmount), style: p.body(15, weight: FontWeight.w800, color: p.gold)),
            ])),
          ])),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            if (po.status == POStatus.draft) GoldButton(label: 'Mark as Sent', onTap: () { po.status = POStatus.sent; appState.touch(); ss(() {}); setState(() {}); }),
            if (po.status == POStatus.sent) GoldButton(label: 'Mark Received', onTap: () { po.status = POStatus.received; appState.touch(); ss(() {}); setState(() {}); }),
            const SizedBox(width: 10),
            GhostButton(label: 'Close', onTap: () => Navigator.pop(ctx)),
          ]),
        ]),
      ),
    )));
  }

  Color _poColor(AppPalette p, POStatus s) => switch (s) {
    POStatus.draft => p.textMuted, POStatus.sent => p.info, POStatus.received => p.success,
    POStatus.partial => p.warning, POStatus.cancelled => p.danger,
  };

  void _showCreatePO() {
    final p = appState.palette;
    Vendor? selectedVendor;
    final items = <POItem>[];
    final itemNameCtrl = TextEditingController(); final itemUnitCtrl = TextEditingController(text: 'pcs');
    int itemQty = 1; double itemPrice = 0;
    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, ss) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(width: 620, padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: p.border)),
        child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('CREATE PURCHASE ORDER', style: p.display(22, spacing: 1.0)),
          const SizedBox(height: 20),
          Dropdown2<Vendor?>(label: 'Select Vendor *', value: selectedVendor,
            items: appState.vendors.where((v) => v.isActive).map((v) => DropdownMenuItem(value: v, child: Text(v.name))).toList(),
            onChanged: (v) => ss(() => selectedVendor = v)),
          const SizedBox(height: 16),
          Text('ORDER ITEMS', style: p.body(11, weight: FontWeight.w700, spacing: 1.0, color: p.textMuted)),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: FormField2(label: 'Item Name', controller: itemNameCtrl, hint: 'e.g. PRP Kit')),
            const SizedBox(width: 10),
            SizedBox(width: 80, child: FormField2(label: 'Unit', controller: itemUnitCtrl, hint: 'pcs')),
            const SizedBox(width: 10),
            SizedBox(width: 80, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('QTY', style: p.body(11, weight: FontWeight.w700, spacing: 1.0, color: p.textMuted)),
              const SizedBox(height: 8),
              Row(children: [QtyButton(Icons.remove, () => ss(() { if (itemQty > 1) itemQty--; })), const SizedBox(width: 6), Text('$itemQty', style: p.body(14)), const SizedBox(width: 6), QtyButton(Icons.add, () => ss(() => itemQty++))]),
            ])),
            const SizedBox(width: 10),
            SizedBox(width: 130, child: FormField2(label: 'Unit Price', controller: TextEditingController(), hint: '0', keyboard: TextInputType.number, onChanged: (v) => itemPrice = double.tryParse(v) ?? 0)),
            const SizedBox(width: 10),
            GoldButton(label: 'Add', onTap: () { if (itemNameCtrl.text.isEmpty) return; ss(() { items.add(POItem(name: itemNameCtrl.text, unit: itemUnitCtrl.text, qty: itemQty, unitPrice: itemPrice)); itemNameCtrl.clear(); itemQty = 1; itemPrice = 0; }); }),
          ]),
          if (items.isNotEmpty) ...[
            const SizedBox(height: 14),
            ...items.map((item) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [
              Expanded(child: Text(item.name, style: p.body(12.5))),
              Text('${item.qty} × ${money(item.unitPrice)} = ${money(item.total)}', style: p.body(12.5, color: p.textMuted)),
              const SizedBox(width: 8),
              GestureDetector(onTap: () => ss(() => items.remove(item)), child: MouseRegion(cursor: SystemMouseCursors.click, child: Icon(Icons.close, size: 16, color: p.textMuted))),
            ]))),
            Align(alignment: Alignment.centerRight, child: Text('Total: ${money(items.fold(0.0, (s, i) => s + i.total))}', style: p.body(14, weight: FontWeight.w700, color: p.gold))),
          ],
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            GhostButton(label: 'Cancel', onTap: () => Navigator.pop(ctx)),
            const SizedBox(width: 12),
            GoldButton(label: 'Create PO', onTap: () {
              if (selectedVendor == null || items.isEmpty) return;
              appState.addPurchaseOrder(PurchaseOrder(id: appState.createPOId(), vendorId: selectedVendor!.id, vendorName: selectedVendor!.name, items: List.from(items), orderDate: DateTime.now(), createdBy: 'Admin'));
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
    var list = appState.purchaseOrders;
    if (_q.isNotEmpty) list = list.where((po) => po.vendorName.toLowerCase().contains(_q.toLowerCase()) || po.id.contains(_q)).toList();
    if (_statusFilter != null) list = list.where((po) => po.status == _statusFilter).toList();

    return Column(children: [
      FilterBar(
        searchHint: 'Search by vendor or PO#…', onSearch: (v) => setState(() => _q = v),
        filters: [FilterDropdown<POStatus?>(value: _statusFilter, items: [const DropdownMenuItem(value: null, child: Text('All Statuses')), ...POStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.label)))], onChanged: (v) => setState(() => _statusFilter = v))],
        countText: '${list.length} orders', onClear: () => setState(() { _q = ''; _statusFilter = null; }),
        trailing: [GoldButton(label: 'Create PO', icon: Icons.add, onTap: _showCreatePO)],
      ),
      const SizedBox(height: 12),
      Expanded(child: list.isEmpty
        ? Center(child: Text('No purchase orders found.', style: p.body(13, color: p.textMuted)))
        : ScrollArea(builder: (sc) => ListView.separated(controller: sc, padding: const EdgeInsets.only(right: 8), itemCount: list.length, separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final po = list[i];
              final color = _poColor(p, po.status);
              return MouseRegion(cursor: SystemMouseCursors.click, child: GestureDetector(onTap: () => _showDetail(po), child: Panel(child: Row(children: [
                Container(width: 44, height: 44, alignment: Alignment.center,
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                  child: Icon(Icons.receipt_long_outlined, size: 22, color: color)),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('PO #${po.id} — ${po.vendorName}', style: p.body(13.5, weight: FontWeight.w700)),
                  Text('${po.items.length} items · ${prettyShort(po.orderDate)}', style: p.body(12, color: p.textMuted)),
                ])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  StatusChip(label: po.status.label, color: color),
                  const SizedBox(height: 6),
                  Text(money(po.totalAmount), style: p.body(13, weight: FontWeight.w700, color: p.gold)),
                ]),
              ]))));
            }))),
    ]);
  }
}

// ── Goods Receiving ──────────────────────────────────────────────────────────
class _GRTab extends StatefulWidget {
  const _GRTab();
  @override
  State<_GRTab> createState() => _GRTabState();
}

class _GRTabState extends State<_GRTab> {
  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final grns = appState.goodsReceivings;
    return grns.isEmpty
      ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.inventory_2_outlined, size: 44, color: p.textMuted.withValues(alpha: 0.5)),
          const SizedBox(height: 12),
          Text('No goods received yet. Receive items from a Sent PO.', style: p.body(13, color: p.textMuted)),
        ]))
      : ScrollArea(builder: (sc) => ListView.separated(
          controller: sc, padding: const EdgeInsets.only(right: 8), itemCount: grns.length, separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) {
            final gr = grns[i];
            return Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(Icons.inventory_2_outlined, size: 20, color: p.success), const SizedBox(width: 10),
                Expanded(child: Text('GRN #${gr.id} — ${gr.vendorName}', style: p.body(13.5, weight: FontWeight.w700))),
                Text(prettyShort(gr.receivedDate), style: p.body(12, color: p.textMuted)),
              ]),
              const SizedBox(height: 10),
              ...gr.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(children: [
                  Icon(Icons.circle, size: 6, color: p.textMuted), const SizedBox(width: 8),
                  Expanded(child: Text(item.name, style: p.body(12.5))),
                  Text('${item.receivedQty}/${item.orderedQty}', style: p.body(12.5, color: item.receivedQty < item.orderedQty ? p.warning : p.success)),
                  const SizedBox(width: 10),
                  StatusChip(label: item.condition, color: item.condition == 'good' ? p.success : item.condition == 'damaged' ? p.danger : p.warning),
                ]),
              )),
              if (gr.notes.isNotEmpty) ...[const SizedBox(height: 6), Text(gr.notes, style: p.body(12, color: p.textMuted))],
            ]));
          },
        ));
  }
}
