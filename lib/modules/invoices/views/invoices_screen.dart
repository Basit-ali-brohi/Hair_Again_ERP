// modules/invoices/views — billing history: searchable, filterable list of all
// generated invoices with in-app PDF view / print / download and delete.
import 'package:flutter/material.dart';

import '../../../core/core.dart';
import '../../pos_inventory/models/pos_models.dart';
import '../../pos_inventory/views/pos_screen.dart';

class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({super.key});
  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

enum _PayFilter { all, paid, pending }

class _InvoicesScreenState extends State<InvoicesScreen> {
  String _search = '';
  _PayFilter _filter = _PayFilter.all;

  List<Invoice> get _filtered {
    final q = _search.toLowerCase();
    return appState.invoices.where((i) {
      final mq = q.isEmpty || i.id.toLowerCase().contains(q) || i.patientName.toLowerCase().contains(q);
      final mf = switch (_filter) { _PayFilter.all => true, _PayFilter.paid => i.balance <= 0, _PayFilter.pending => i.balance > 0 };
      return mq && mf;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final list = _filtered;
    final billed = appState.invoices.fold<double>(0, (s, i) => s + i.subtotal);
    final collected = appState.invoices.fold<double>(0, (s, i) => s + (i.subtotal - i.balance));
    return ScreenScaffold(
      title: 'BILLING & INVOICES',
      subtitle: 'Every generated invoice — view, print or download as PDF.',
      actions: [GoldButton(label: 'New Invoice', icon: Icons.add, onTap: () => appState.go(2))],
      child: LayoutBuilder(builder: (ctx, c) {
        return ScrollArea(builder: (sc) => SingleChildScrollView(
          controller: sc,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            MetricRow([
              MetricCard(title: 'Total Invoices', value: '${appState.invoices.length}', delta: 'All time total', icon: Icons.receipt_long_outlined),
              MetricCard(title: 'Total Billed', value: moneyShort(billed), delta: '+12%', icon: Icons.request_quote_outlined),
              MetricCard(title: 'Collected', value: moneyShort(collected), delta: '+8%', icon: Icons.payments_outlined),
              MetricCard(title: 'Outstanding', value: moneyShort(appState.pendingInstallments), delta: '${appState.invoices.where((i) => i.balance > 0).length} pending', deltaUp: false, icon: Icons.schedule_outlined),
            ]),
            const SizedBox(height: 18),
            FilterBar(
              searchHint: 'Search by invoice # or patient…',
              onSearch: (v) => setState(() => _search = v),
              filters: [
                FilterDropdown<_PayFilter>(
                  icon: Icons.payments_outlined,
                  value: _filter,
                  items: const [
                    DropdownMenuItem(value: _PayFilter.all, child: Text('All Statuses')),
                    DropdownMenuItem(value: _PayFilter.paid, child: Text('Paid')),
                    DropdownMenuItem(value: _PayFilter.pending, child: Text('Pending')),
                  ],
                  onChanged: (v) => setState(() => _filter = v ?? _PayFilter.all),
                ),
              ],
              countText: 'Showing ${list.length} of ${appState.invoices.length}',
              onClear: () => setState(() { _search = ''; _filter = _PayFilter.all; }),
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: c.maxHeight,
              child: Panel(
                child: list.isEmpty
                ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.receipt_long_outlined, size: 44, color: p.textMuted.withValues(alpha: 0.5)),
                    const SizedBox(height: 12),
                    Text(appState.invoices.isEmpty ? 'No invoices yet — generate one from POS.' : 'No invoices match your search.', style: p.body(13, color: p.textMuted)),
                    if (appState.invoices.isEmpty) ...[const SizedBox(height: 14), GoldButton(label: 'Go to POS', icon: Icons.point_of_sale_outlined, onTap: () => appState.go(2))],
                  ]))
                : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Row(children: [Expanded(flex: 3, child: _th(p, 'INVOICE #')), Expanded(flex: 4, child: _th(p, 'PATIENT')), Expanded(flex: 3, child: _th(p, 'DATE')), Expanded(flex: 2, child: _th(p, 'TOTAL')), Expanded(flex: 2, child: _th(p, 'BALANCE')), Expanded(flex: 2, child: _th(p, 'STATUS')), const SizedBox(width: 122)])),
                    const SizedBox(height: 6),
                    Divider(height: 1, color: p.border),
                    Expanded(child: ScrollArea(builder: (sc2) => ListView.separated(controller: sc2, padding: const EdgeInsets.only(right: 12), itemCount: list.length, separatorBuilder: (_, _) => Divider(height: 1, color: p.border), itemBuilder: (_, i) => _row(p, list[i])))),
                  ]),
          ),
        ),
        const SizedBox(height: 24),
      ]),
    ));
  }),
);
  }

  Widget _th(AppPalette p, String t) => Text(t, style: p.body(11, color: p.textMuted, weight: FontWeight.w700, spacing: 0.8));

  void _showDetail(Invoice inv) {
    showDialog(context: context, builder: (_) => InvoiceReceiptDialog(invoice: inv, onPaymentRecorded: () => setState(() {})));
  }

  void _showRecordPayment(Invoice inv) {
    final p = appState.palette;
    final ctrl = TextEditingController(text: inv.balance.toStringAsFixed(0));
    showDialog(context: context, builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 420, padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: p.border)),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('RECORD PAYMENT', style: p.display(22, spacing: 1.0)),
          const SizedBox(height: 6),
          Text('Invoice ${inv.id} — Balance: ${money(inv.balance)}', style: p.body(13, color: p.textMuted)),
          const SizedBox(height: 20),
          FormField2(label: 'Payment Amount (PKR) *', controller: ctrl, hint: 'e.g. ${inv.balance.toStringAsFixed(0)}', keyboard: TextInputType.number),
          const SizedBox(height: 8),
          Row(children: [
            GestureDetector(
              onTap: () { ctrl.text = inv.balance.toStringAsFixed(0); },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: p.gold.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6), border: Border.all(color: p.gold.withValues(alpha: 0.3))),
                child: Text('Full Balance: ${money(inv.balance)}', style: p.body(12, color: p.gold, weight: FontWeight.w600)),
              ),
            ),
          ]),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            GhostButton(label: 'Cancel', onTap: () => Navigator.pop(ctx)),
            const SizedBox(width: 12),
            GoldButton(label: 'Record Payment', icon: Icons.payments_outlined, onTap: () {
              final amount = double.tryParse(ctrl.text) ?? 0;
              if (amount <= 0) return;
              inv.paidExtra = (inv.paidExtra + amount).clamp(0, inv.subtotal - inv.advance);
              appState.touch();
              Navigator.pop(ctx);
              setState(() {});
            }),
          ]),
        ]),
      ),
    ));
  }

  Widget _row(AppPalette p, Invoice inv) {
    final paid = inv.isPaid;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _showDetail(inv),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Row(children: [
            Expanded(flex: 3, child: Text(inv.id, style: p.body(13, weight: FontWeight.w700, color: p.gold))),
            Expanded(flex: 4, child: Text(inv.patientName, style: p.body(13))),
            Expanded(flex: 3, child: Text(prettyShort(inv.date), style: p.body(13, color: p.textMuted))),
            Expanded(flex: 2, child: Text(moneyShort(inv.subtotal), style: p.body(13))),
            Expanded(flex: 2, child: Text(paid ? '—' : moneyShort(inv.balance), style: p.body(13, color: paid ? p.textMuted : p.danger, weight: paid ? FontWeight.w400 : FontWeight.w600))),
            Expanded(flex: 2, child: Align(alignment: Alignment.centerLeft, child: StatusChip(label: paid ? 'Paid' : 'Pending', color: paid ? p.success : p.warning))),
            SizedBox(
              width: 122,
              child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                if (!paid) Tooltip(message: 'Record Payment', child: GestureDetector(onTap: () { _showRecordPayment(inv); }, child: MouseRegion(cursor: SystemMouseCursors.click, child: Container(width: 32, height: 32, decoration: BoxDecoration(color: p.success.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)), child: Icon(Icons.payments_outlined, size: 16, color: p.success))))),
                if (!paid) const SizedBox(width: 6),
                Tooltip(message: 'View / Print PDF', child: GestureDetector(onTap: () => showPdfPreview(context, title: 'Invoice ${inv.id}', build: () => buildInvoicePdf(inv)), child: MouseRegion(cursor: SystemMouseCursors.click, child: Container(width: 32, height: 32, decoration: BoxDecoration(color: p.gold.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)), child: Icon(Icons.picture_as_pdf_outlined, size: 16, color: p.gold))))),
                const SizedBox(width: 6),
                Tooltip(message: 'Delete', child: GestureDetector(onTap: () async { final ok = await confirm(context, 'Delete invoice?', 'Remove ${inv.id} from records.'); if (ok) { appState.deleteInvoice(inv); setState(() {}); } }, child: MouseRegion(cursor: SystemMouseCursors.click, child: Container(width: 32, height: 32, decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(8)), child: Icon(Icons.delete_outline, size: 16, color: p.textMuted))))),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}
