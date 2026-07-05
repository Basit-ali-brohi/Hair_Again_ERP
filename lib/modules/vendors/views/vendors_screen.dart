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
  void initState() { super.initState(); _tab = TabController(length: 6, vsync: this); }
  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    return ScreenScaffold(
      title: 'VENDORS & PURCHASING',
      subtitle: 'Vendor directory, purchase orders, requests, goods receiving & payments',
      actions: [
        Container(height: 42,
          decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: p.border)),
          child: TabBar(controller: _tab, isScrollable: true, dividerColor: Colors.transparent,
            indicatorColor: p.gold, indicatorSize: TabBarIndicatorSize.label,
            labelStyle: p.body(12.5, weight: FontWeight.w600), unselectedLabelStyle: p.body(12.5),
            labelColor: p.gold, unselectedLabelColor: p.textMuted, tabAlignment: TabAlignment.start,
            tabs: const [
              Tab(text: 'Vendors'), Tab(text: 'Purchase Orders'), Tab(text: 'Goods Receiving'),
              Tab(text: 'Purchase Requests'), Tab(text: 'Receive Goods'), Tab(text: 'Vendor Payments'),
            ]),
        ),
      ],
      child: EagerTabBarView(controller: _tab, children: const [
        _VendorsTab(), _POTab(), _GRTab(),
        _PurchaseRequestsTab(), _ReceiveGoodsTab(), _VendorPaymentsTab(),
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

// ══════════════════════════════════════════════════════════════════════════════
// PURCHASE REQUESTS TAB
// ══════════════════════════════════════════════════════════════════════════════
class _PurchaseRequest {
  final String id, item, requester, reason;
  final int qty;
  final String urgency; // Low / Medium / High
  String status; // Pending / Approved / Rejected / Ordered
  final String date;
  _PurchaseRequest({required this.id, required this.date, required this.item, required this.qty, required this.urgency, required this.requester, required this.reason, this.status = 'Pending'});
}

class _PurchaseRequestsTab extends StatefulWidget {
  const _PurchaseRequestsTab();
  @override
  State<_PurchaseRequestsTab> createState() => _PurchaseRequestsTabState();
}

class _PurchaseRequestsTabState extends State<_PurchaseRequestsTab> {
  final _requests = <_PurchaseRequest>[
    _PurchaseRequest(id: 'PR-001', date: '1 Jul 2026', item: 'PRP Vials (Box of 10)', qty: 5, urgency: 'High', requester: 'Dr. Rashid', reason: 'Running low in Branch 1', status: 'Approved'),
    _PurchaseRequest(id: 'PR-002', date: '2 Jul 2026', item: 'Surgical Gloves (M)', qty: 20, urgency: 'Medium', requester: 'Nurse Hina', reason: 'Monthly restock', status: 'Pending'),
    _PurchaseRequest(id: 'PR-003', date: '3 Jul 2026', item: 'Hair Serum Deluxe', qty: 10, urgency: 'Low', requester: 'Reception', reason: 'Client retail demand', status: 'Pending'),
  ];
  int _nextId = 4;

  static const _urgencies = ['Low', 'Medium', 'High'];
  static const _staffList = ['Dr. Rashid', 'Dr. Sara', 'Nurse Hina', 'Reception', 'Manager', 'Admin'];

  Color _urgencyColor(AppPalette p, String u) => switch (u) { 'High' => p.danger, 'Medium' => p.warning, _ => p.success };
  Color _statusColor(AppPalette p, String s) => switch (s) { 'Approved' => p.success, 'Rejected' => p.danger, 'Ordered' => p.info, _ => p.warning };

  void _newRequest() {
    final p = appState.palette;
    final itemCtrl = TextEditingController();
    final reasonCtrl = TextEditingController();
    String urgency = 'Medium';
    String requester = _staffList.first;
    int qty = 1;

    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, ss) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(width: 540, padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: p.border)),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('NEW PURCHASE REQUEST', style: p.display(22, spacing: 1.0)),
          const SizedBox(height: 20),
          FormField2(label: 'Item / Product *', controller: itemCtrl, hint: 'e.g. PRP Vials Box of 10'),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: Dropdown2<String>(label: 'Urgency', value: urgency,
              items: _urgencies.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
              onChanged: (v) => ss(() => urgency = v ?? urgency))),
            const SizedBox(width: 14),
            Expanded(child: Dropdown2<String>(label: 'Requested By', value: requester,
              items: _staffList.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (v) => ss(() => requester = v ?? requester))),
            const SizedBox(width: 14),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('QTY', style: p.body(11, weight: FontWeight.w700, spacing: 1.0, color: p.textMuted)),
              const SizedBox(height: 8),
              Row(children: [
                QtyButton(Icons.remove, () => ss(() { if (qty > 1) qty--; })),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text('$qty', style: p.display(18))),
                QtyButton(Icons.add, () => ss(() => qty++)),
              ]),
            ]),
          ]),
          const SizedBox(height: 14),
          FormField2(label: 'Reason', controller: reasonCtrl, hint: 'Why is this needed?', maxLines: 2),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            GhostButton(label: 'Cancel', onTap: () => Navigator.pop(ctx)),
            const SizedBox(width: 12),
            GoldButton(label: 'Submit Request', onTap: () {
              if (itemCtrl.text.isEmpty) return;
              setState(() {
                _requests.insert(0, _PurchaseRequest(
                  id: 'PR-${_nextId.toString().padLeft(3, '0')}',
                  date: prettyShort(DateTime.now()),
                  item: itemCtrl.text, qty: qty,
                  urgency: urgency, requester: requester,
                  reason: reasonCtrl.text,
                ));
                _nextId++;
              });
              Navigator.pop(ctx);
              toast(context, 'Purchase request submitted');
            }),
          ]),
        ]),
      ),
    )));
  }

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    return Column(children: [
      Row(children: [const Spacer(), GoldButton(label: 'New Request', icon: Icons.add, onTap: _newRequest)]),
      const SizedBox(height: 12),
      Expanded(child: _requests.isEmpty
        ? Center(child: Text('No purchase requests.', style: p.body(13, color: p.textMuted)))
        : Panel(padding: EdgeInsets.zero, child: ScrollArea(builder: (sc) => SingleChildScrollView(controller: sc,
            child: FullWidthDataTable(child: DataTable(
              headingRowColor: WidgetStateProperty.all(p.surfaceAlt),
              columnSpacing: 16, horizontalMargin: 20,
              columns: ['Date', 'ID', 'Item', 'Qty', 'Urgency', 'Requested By', 'Reason', 'Status', 'Action']
                .map((c) => DataColumn(label: Text(c, style: p.body(12, weight: FontWeight.w700)))).toList(),
              rows: _requests.map((r) => DataRow(cells: [
                DataCell(Text(r.date, style: p.body(12.5, color: p.textMuted))),
                DataCell(Text(r.id, style: p.body(12.5, color: p.textMuted))),
                DataCell(Text(r.item, style: p.body(13, weight: FontWeight.w600))),
                DataCell(Text('${r.qty}', style: p.body(13, weight: FontWeight.w700, color: p.gold))),
                DataCell(StatusChip(label: r.urgency, color: _urgencyColor(p, r.urgency))),
                DataCell(Text(r.requester, style: p.body(12.5))),
                DataCell(SizedBox(width: 160, child: Text(r.reason, style: p.body(12, color: p.textMuted), maxLines: 2, overflow: TextOverflow.ellipsis))),
                DataCell(StatusChip(label: r.status, color: _statusColor(p, r.status))),
                DataCell(r.status != 'Pending'
                  ? Text('—', style: p.body(12.5, color: p.textMuted))
                  : Row(mainAxisSize: MainAxisSize.min, children: [
                      _VSmBtn(p, 'Approve', p.success, () { setState(() => r.status = 'Approved'); toast(context, 'Request approved'); }),
                      const SizedBox(width: 6),
                      _VSmBtn(p, 'Reject', p.danger, () { setState(() => r.status = 'Rejected'); toast(context, 'Request rejected'); }),
                    ])),
              ])).toList(),
            )))))),
    ]);
  }
}

Widget _VSmBtn(AppPalette p, String label, Color color, VoidCallback onTap) =>
  GestureDetector(onTap: onTap, child: MouseRegion(cursor: SystemMouseCursors.click,
    child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: p.body(11.5, color: color, weight: FontWeight.w700)))));

// ══════════════════════════════════════════════════════════════════════════════
// RECEIVE GOODS TAB  (enhanced version with stock update)
// ══════════════════════════════════════════════════════════════════════════════
class _GRNEntry {
  final String id, vendor, poNumber, receivedBy;
  final DateTime date;
  final List<_GRNItem> items;
  final String status; // Partial / Complete
  String notes;
  _GRNEntry({required this.id, required this.vendor, required this.poNumber, required this.receivedBy, required this.date, required this.items, required this.status, this.notes = ''});
  double get totalValue => items.fold(0.0, (s, i) => s + i.qty * i.unitPrice);
}

class _GRNItem { String name; int qty; double unitPrice; _GRNItem({required this.name, required this.qty, required this.unitPrice}); }

class _ReceiveGoodsTab extends StatefulWidget {
  const _ReceiveGoodsTab();
  @override
  State<_ReceiveGoodsTab> createState() => _ReceiveGoodsTabState();
}

class _ReceiveGoodsTabState extends State<_ReceiveGoodsTab> {
  int _nextGrn = 1;
  final _grns = <_GRNEntry>[
    _GRNEntry(id: 'GRN-001', vendor: 'MedStar Supplies', poNumber: 'PO-001', receivedBy: 'Warehouse Manager',
      date: DateTime(2026, 6, 28), items: [_GRNItem(name: 'PRP Kit', qty: 10, unitPrice: 4500), _GRNItem(name: 'Hair Serum', qty: 20, unitPrice: 1200)],
      status: 'Complete'),
    _GRNEntry(id: 'GRN-002', vendor: 'PharmaCare', poNumber: 'PO-004', receivedBy: 'Admin',
      date: DateTime(2026, 7, 1), items: [_GRNItem(name: 'Surgical Gloves (M)', qty: 50, unitPrice: 15)],
      status: 'Partial', notes: 'Remaining 50 units expected next week'),
  ];

  void _receiveGoods() {
    final p = appState.palette;
    Vendor? selectedVendor;
    final receivedByCtrl = TextEditingController(text: 'Warehouse Manager');
    final notesCtrl = TextEditingController();
    final itemNameCtrl = TextEditingController();
    final itemPriceCtrl = TextEditingController();
    final items = <_GRNItem>[];
    int itemQty = 1;
    String status = 'Complete';

    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, ss) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(width: 620, padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: p.border)),
        child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('RECEIVE GOODS', style: p.display(22, spacing: 1.0)),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: Dropdown2<Vendor?>(label: 'Vendor *', value: selectedVendor,
              items: [const DropdownMenuItem<Vendor?>(value: null, child: Text('— Select Vendor —')),
                ...appState.vendors.where((v) => v.isActive).map((v) => DropdownMenuItem(value: v, child: Text(v.name)))],
              onChanged: (v) => ss(() => selectedVendor = v))),
            const SizedBox(width: 14),
            Expanded(child: FormField2(label: 'Received By', controller: receivedByCtrl, hint: 'Staff name')),
            const SizedBox(width: 14),
            Expanded(child: Dropdown2<String>(label: 'Status', value: status,
              items: ['Complete', 'Partial'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (v) => ss(() => status = v ?? status))),
          ]),
          const SizedBox(height: 16),
          Text('ITEMS RECEIVED', style: p.body(11, weight: FontWeight.w700, spacing: 1.0, color: p.textMuted)),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: FormField2(label: 'Item Name', controller: itemNameCtrl, hint: 'Product name')),
            const SizedBox(width: 10),
            SizedBox(width: 80, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('QTY', style: p.body(11, weight: FontWeight.w700, spacing: 1.0, color: p.textMuted)),
              const SizedBox(height: 8),
              Row(children: [
                QtyButton(Icons.remove, () => ss(() { if (itemQty > 1) itemQty--; })),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Text('$itemQty', style: p.body(14))),
                QtyButton(Icons.add, () => ss(() => itemQty++)),
              ]),
            ])),
            const SizedBox(width: 10),
            SizedBox(width: 140, child: FormField2(label: 'Unit Price (PKR)', controller: itemPriceCtrl, hint: '0', keyboard: TextInputType.number)),
            const SizedBox(width: 10),
            GoldButton(label: 'Add', onTap: () {
              if (itemNameCtrl.text.isEmpty) return;
              ss(() {
                items.add(_GRNItem(name: itemNameCtrl.text, qty: itemQty, unitPrice: double.tryParse(itemPriceCtrl.text) ?? 0));
                itemNameCtrl.clear(); itemPriceCtrl.clear(); itemQty = 1;
              });
            }),
          ]),
          if (items.isNotEmpty) ...[
            const SizedBox(height: 10),
            ...items.map((i) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Row(children: [
              Expanded(child: Text(i.name, style: p.body(12.5))),
              Text('${i.qty} × ${money(i.unitPrice)}', style: p.body(12.5, color: p.textMuted)),
              const SizedBox(width: 8),
              GestureDetector(onTap: () => ss(() => items.remove(i)), child: Icon(Icons.close, size: 16, color: p.textMuted)),
            ]))),
            Align(alignment: Alignment.centerRight, child: Text('Total: ${money(items.fold(0.0, (s, i) => s + i.qty * i.unitPrice))}', style: p.body(14, weight: FontWeight.w700, color: p.gold))),
          ],
          const SizedBox(height: 14),
          FormField2(label: 'Notes', controller: notesCtrl, hint: 'Remarks, discrepancies…', maxLines: 2),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            GhostButton(label: 'Cancel', onTap: () => Navigator.pop(ctx)),
            const SizedBox(width: 12),
            GoldButton(label: 'Confirm Receipt', onTap: () {
              if (selectedVendor == null || items.isEmpty) return;
              final grn = _GRNEntry(
                id: 'GRN-${(_nextGrn + 2).toString().padLeft(3, '0')}',
                vendor: selectedVendor!.name,
                poNumber: 'PO-AUTO-$_nextGrn',
                receivedBy: receivedByCtrl.text,
                date: DateTime.now(),
                items: List.from(items),
                status: status,
                notes: notesCtrl.text,
              );
              // update stock quantities
              for (final item in items) {
                final stockItem = appState.stockItems.where((s) => s.name.toLowerCase().contains(item.name.toLowerCase())).firstOrNull;
                if (stockItem != null) { stockItem.currentQty += item.qty; stockItem.lastUpdated = DateTime.now(); }
              }
              setState(() { _grns.insert(0, grn); _nextGrn++; });
              appState.touch();
              Navigator.pop(ctx);
              toast(context, 'Goods receipt recorded — stock updated');
            }),
          ]),
        ])),
      ),
    )));
  }

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    return Column(children: [
      Row(children: [const Spacer(), GoldButton(label: 'Receive Goods', icon: Icons.move_to_inbox_outlined, onTap: _receiveGoods)]),
      const SizedBox(height: 12),
      Expanded(child: _grns.isEmpty
        ? Center(child: Text('No goods received yet.', style: p.body(13, color: p.textMuted)))
        : Panel(padding: EdgeInsets.zero, child: ScrollArea(builder: (sc) => SingleChildScrollView(controller: sc,
            child: FullWidthDataTable(child: DataTable(
              headingRowColor: WidgetStateProperty.all(p.surfaceAlt),
              columnSpacing: 16, horizontalMargin: 20,
              columns: ['Date', 'GRN #', 'Vendor', 'PO #', 'Items', 'Total Value', 'Received By', 'Status']
                .map((c) => DataColumn(label: Text(c, style: p.body(12, weight: FontWeight.w700)))).toList(),
              rows: _grns.map((g) => DataRow(cells: [
                DataCell(Text(prettyShort(g.date), style: p.body(12.5, color: p.textMuted))),
                DataCell(Text(g.id, style: p.body(12.5, weight: FontWeight.w700))),
                DataCell(Text(g.vendor, style: p.body(13, weight: FontWeight.w600))),
                DataCell(Text(g.poNumber, style: p.body(12.5, color: p.textMuted))),
                DataCell(Text('${g.items.length} item${g.items.length != 1 ? 's' : ''}', style: p.body(12.5))),
                DataCell(Text(money(g.totalValue), style: p.body(13, weight: FontWeight.w700, color: p.gold))),
                DataCell(Text(g.receivedBy, style: p.body(12.5))),
                DataCell(StatusChip(label: g.status, color: g.status == 'Complete' ? p.success : p.warning)),
              ])).toList(),
            )))))),
    ]);
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// VENDOR PAYMENTS TAB
// ══════════════════════════════════════════════════════════════════════════════
class _VendorPayment {
  final String id, vendor, invoiceNo, method, notes;
  final double amount;
  String status; // Pending / Paid
  final String date;
  _VendorPayment({required this.id, required this.date, required this.vendor, required this.invoiceNo, required this.amount, required this.method, this.notes = '', this.status = 'Pending'});
}

class _VendorPaymentsTab extends StatefulWidget {
  const _VendorPaymentsTab();
  @override
  State<_VendorPaymentsTab> createState() => _VendorPaymentsTabState();
}

class _VendorPaymentsTabState extends State<_VendorPaymentsTab> {
  int _nextId = 4;
  static const _methods = ['Cash', 'Bank Transfer', 'Cheque'];

  final _payments = <_VendorPayment>[
    _VendorPayment(id: 'VP-001', date: '25 Jun 2026', vendor: 'MedStar Supplies', invoiceNo: 'INV-1021', amount: 85000, method: 'Bank Transfer', status: 'Paid'),
    _VendorPayment(id: 'VP-002', date: '1 Jul 2026', vendor: 'PharmaCare', invoiceNo: 'INV-5542', amount: 32500, method: 'Cheque', status: 'Pending'),
    _VendorPayment(id: 'VP-003', date: '3 Jul 2026', vendor: 'LabTech Solutions', invoiceNo: 'INV-7710', amount: 15000, method: 'Cash', status: 'Pending'),
  ];

  void _recordPayment() {
    final p = appState.palette;
    Vendor? selectedVendor;
    final amtCtrl = TextEditingController();
    final invCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    String method = 'Bank Transfer';
    DateTime date = DateTime.now();

    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, ss) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(width: 540, padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: p.border)),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('RECORD VENDOR PAYMENT', style: p.display(22, spacing: 1.0)),
          const SizedBox(height: 20),
          Dropdown2<Vendor?>(label: 'Vendor *', value: selectedVendor,
            items: [const DropdownMenuItem<Vendor?>(value: null, child: Text('— Select Vendor —')),
              ...appState.vendors.where((v) => v.isActive).map((v) => DropdownMenuItem(value: v, child: Text(v.name)))],
            onChanged: (v) => ss(() => selectedVendor = v)),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: FormField2(label: 'Invoice No. *', controller: invCtrl, hint: 'INV-XXXX')),
            const SizedBox(width: 14),
            Expanded(child: FormField2(label: 'Amount (PKR) *', controller: amtCtrl, hint: '0.00', keyboard: TextInputType.number)),
          ]),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: Dropdown2<String>(label: 'Payment Method', value: method,
              items: _methods.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
              onChanged: (v) => ss(() => method = v ?? method))),
            const SizedBox(width: 14),
            Expanded(child: _VendorDatePicker(label: 'Payment Date', value: date, palette: p, onPick: (d) => ss(() => date = d))),
          ]),
          const SizedBox(height: 14),
          FormField2(label: 'Notes', controller: notesCtrl, hint: 'Payment remarks…', maxLines: 2),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            GhostButton(label: 'Cancel', onTap: () => Navigator.pop(ctx)),
            const SizedBox(width: 12),
            GoldButton(label: 'Record Payment', onTap: () {
              if (selectedVendor == null || invCtrl.text.isEmpty) return;
              final amt = double.tryParse(amtCtrl.text);
              if (amt == null || amt <= 0) return;
              setState(() {
                _payments.insert(0, _VendorPayment(
                  id: 'VP-${_nextId.toString().padLeft(3, '0')}',
                  date: prettyShort(date),
                  vendor: selectedVendor!.name,
                  invoiceNo: invCtrl.text,
                  amount: amt,
                  method: method,
                  notes: notesCtrl.text,
                ));
                _nextId++;
              });
              Navigator.pop(ctx);
              toast(context, 'Payment recorded');
            }),
          ]),
        ]),
      ),
    )));
  }

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final totalPayable = _payments.where((p) => p.status == 'Pending').fold(0.0, (s, p) => s + p.amount);
    final paidThisMonth = _payments.where((p) => p.status == 'Paid').fold(0.0, (s, p) => s + p.amount);
    final overdueCount = _payments.where((p) => p.status == 'Pending').length;
    final pendingApproval = _payments.where((p) => p.status == 'Pending').length;

    return Column(children: [
      MetricRow([
        MetricCard(title: 'Total Payable', value: money(totalPayable), icon: Icons.payments_outlined, delta: '$overdueCount pending', deltaUp: false),
        MetricCard(title: 'Paid This Month', value: money(paidThisMonth), icon: Icons.check_circle_outline, delta: 'settled', deltaUp: true),
        MetricCard(title: 'Overdue Payments', value: '$overdueCount', icon: Icons.warning_amber_outlined, delta: 'require attention', deltaUp: false),
        MetricCard(title: 'Pending Approvals', value: '$pendingApproval', icon: Icons.pending_actions_outlined, delta: ''),
      ]),
      const SizedBox(height: 12),
      Row(children: [const Spacer(), GoldButton(label: 'Record Payment', icon: Icons.add, onTap: _recordPayment)]),
      const SizedBox(height: 12),
      Expanded(child: _payments.isEmpty
        ? Center(child: Text('No payment records.', style: p.body(13, color: p.textMuted)))
        : Panel(padding: EdgeInsets.zero, child: ScrollArea(builder: (sc) => SingleChildScrollView(controller: sc,
            child: FullWidthDataTable(child: DataTable(
              headingRowColor: WidgetStateProperty.all(p.surfaceAlt),
              columnSpacing: 16, horizontalMargin: 20,
              columns: ['Date', 'ID', 'Vendor', 'Invoice No.', 'Amount', 'Method', 'Status', 'Action']
                .map((c) => DataColumn(label: Text(c, style: p.body(12, weight: FontWeight.w700)))).toList(),
              rows: _payments.map((pay) => DataRow(cells: [
                DataCell(Text(pay.date, style: p.body(12.5, color: p.textMuted))),
                DataCell(Text(pay.id, style: p.body(12.5, color: p.textMuted))),
                DataCell(Text(pay.vendor, style: p.body(13, weight: FontWeight.w600))),
                DataCell(Text(pay.invoiceNo, style: p.body(12.5))),
                DataCell(Text(money(pay.amount), style: p.body(13.5, weight: FontWeight.w700, color: p.gold))),
                DataCell(StatusChip(label: pay.method, color: p.info)),
                DataCell(StatusChip(label: pay.status, color: pay.status == 'Paid' ? p.success : p.warning)),
                DataCell(pay.status == 'Paid'
                  ? Text('—', style: p.body(12.5, color: p.textMuted))
                  : GoldButton(label: 'Mark Paid', onTap: () { setState(() => pay.status = 'Paid'); toast(context, 'Payment marked as paid'); })),
              ])).toList(),
            )))))),
    ]);
  }
}

// ── Shared date picker for vendor tabs ────────────────────────────────────────
class _VendorDatePicker extends StatelessWidget {
  final String label;
  final DateTime value;
  final AppPalette palette;
  final ValueChanged<DateTime> onPick;
  const _VendorDatePicker({required this.label, required this.value, required this.palette, required this.onPick});
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

