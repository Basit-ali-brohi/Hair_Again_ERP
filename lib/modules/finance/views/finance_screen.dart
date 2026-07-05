import 'package:flutter/material.dart';

import '../../../core/core.dart';
import '../models/finance_models.dart';

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});
  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> with SingleTickerProviderStateMixin {
  late final TabController _tab;
  @override
  void initState() { super.initState(); _tab = TabController(length: 7, vsync: this); }
  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    return ScreenScaffold(
      title: 'FINANCE & ACCOUNTS',
      subtitle: 'Income, expenses, cash book, bank accounts & journal entries',
      actions: [
        GhostButton(label: 'Export PDF', icon: Icons.picture_as_pdf_outlined, onTap: () => showPdfPreview(context, title: 'Finance Report', build: () => buildReportPdf())),
      ],
      child: Column(children: [
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
            tabs: const [
              Tab(text: 'Dashboard'), Tab(text: 'Income'), Tab(text: 'Expenses'),
              Tab(text: 'Cash Book'), Tab(text: 'Bank Accounts'), Tab(text: 'Journal Entries'), Tab(text: 'Transactions'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: EagerTabBarView(controller: _tab, children: const [
            _DashboardTab(), _IncomeTab(), _ExpensesTab(),
            _CashBookTab(), _BankTab(), _JournalTab(), _TransactionsTab(),
          ]),
        ),
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
    final income = appState.thisMonthIncome;
    final expense = appState.thisMonthExpense;
    final net = income - expense;
    return ScrollArea(builder: (sc) => SingleChildScrollView(controller: sc, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      MetricRow([
        MetricCard(title: 'Total Income (Jun)', value: moneyShort(income), delta: '+12% vs May', icon: Icons.arrow_downward_rounded),
        MetricCard(title: 'Total Expenses (Jun)', value: moneyShort(expense), delta: '-3% vs May', icon: Icons.arrow_upward_rounded, deltaUp: false),
        MetricCard(title: 'Net Profit (Jun)', value: moneyShort(net), delta: '${(net / income * 100).toStringAsFixed(1)}% margin', icon: Icons.trending_up_outlined),
        MetricCard(title: 'Cash Balance', value: moneyShort(appState.cashBalance), delta: 'Available', icon: Icons.account_balance_wallet_outlined),
      ]),
      const SizedBox(height: 24),
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text('INCOME vs EXPENSES', style: p.display(18, spacing: 0.5)),
            const Spacer(),
            StatusChip(label: 'Jun 2026', color: p.info),
          ]),
          const SizedBox(height: 20),
          SizedBox(height: 200, child: CustomPaint(
            painter: _IncExpBarPainter(income: income, expense: expense, palette: p),
            size: Size.infinite,
          )),
          const SizedBox(height: 16),
          Row(children: [
            _Legend('Income', p.success, p),
            const SizedBox(width: 20),
            _Legend('Expenses', p.danger, p),
            const SizedBox(width: 20),
            _Legend('Net Profit', p.gold, p),
          ]),
        ]))),
        const SizedBox(width: 18),
        SizedBox(width: 340, child: Column(children: [
          Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('BANK BALANCES', style: p.display(18, spacing: 0.5)),
            const SizedBox(height: 14),
            ...appState.bankAccounts.map((ba) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(children: [
              Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: p.gold.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Icon(Icons.account_balance_outlined, size: 18, color: p.gold)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(ba.bankName + (ba.isPrimary ? ' (Primary)' : ''), style: p.body(13, weight: FontWeight.w600)),
                Text(ba.accountTitle, style: p.body(11.5, color: p.textMuted)),
              ])),
              Text(money(ba.currentBalance), style: p.body(13.5, weight: FontWeight.w700, color: p.gold)),
            ]))),
            Divider(height: 20, color: p.border),
            Row(children: [
              Text('TOTAL', style: p.body(13, weight: FontWeight.w700)),
              const Spacer(),
              Text(money(appState.totalBankBalance), style: p.body(14, weight: FontWeight.w700, color: p.gold)),
            ]),
          ])),
          const SizedBox(height: 18),
          Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('EXPENSE BREAKDOWN', style: p.display(18, spacing: 0.5)),
            const SizedBox(height: 14),
            ..._expenseBreakdown(p),
          ])),
        ])),
      ]),
    ])));
  }

  List<Widget> _expenseBreakdown(AppPalette p) {
    final byCategory = <ExpenseCategory, double>{};
    for (final e in appState.expenseEntries) {
      byCategory[e.category] = (byCategory[e.category] ?? 0) + e.amount;
    }
    final total = byCategory.values.fold(0.0, (s, v) => s + v);
    return byCategory.entries.map((e) {
      final pct = total == 0 ? 0.0 : e.value / total;
      return Padding(padding: const EdgeInsets.only(bottom: 12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(e.key.label, style: p.body(12.5), maxLines: 1, overflow: TextOverflow.ellipsis),
          const Spacer(),
          Text(money(e.value), style: p.body(12.5, weight: FontWeight.w600)),
        ]),
        const SizedBox(height: 5),
        ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: pct, backgroundColor: p.surfaceAlt, color: p.gold, minHeight: 5)),
      ]));
    }).toList();
  }
}

class _IncExpBarPainter extends CustomPainter {
  final double income;
  final double expense;
  final AppPalette palette;
  const _IncExpBarPainter({required this.income, required this.expense, required this.palette});
  @override
  void paint(Canvas canvas, Size size) {
    final p = palette;
    final maxVal = income * 1.2;
    final bw = size.width / 5;
    void bar(double x, double val, Color color) {
      final h = maxVal == 0 ? 0.0 : (val / maxVal) * (size.height - 30);
      final rect = Rect.fromLTWH(x, size.height - 30 - h, bw, h);
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(6)), Paint()..color = color);
    }
    bar(size.width * 0.1, income, p.success.withValues(alpha: 0.8));
    bar(size.width * 0.1 + bw + 20, expense, p.danger.withValues(alpha: 0.8));
    bar(size.width * 0.1 + (bw + 20) * 2, income - expense, p.gold.withValues(alpha: 0.8));
  }
  @override
  bool shouldRepaint(_) => true;
}

Widget _Legend(String label, Color color, AppPalette p) => Row(mainAxisSize: MainAxisSize.min, children: [
  Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
  const SizedBox(width: 6),
  Text(label, style: p.body(12)),
]);

// ══════════════════════════════════════════════════════════════════════════════
// INCOME TAB
// ══════════════════════════════════════════════════════════════════════════════
class _IncomeTab extends StatefulWidget {
  const _IncomeTab();
  @override
  State<_IncomeTab> createState() => _IncomeTabState();
}

class _IncomeTabState extends State<_IncomeTab> {
  String _q = '';
  IncomeCategory? _catFilter;
  PaymentMethod? _methodFilter;
  String? _period;

  List<String> get _periods {
    final months = <String>{};
    for (final e in appState.incomeEntries) months.add('${e.date.month}-${e.date.year}');
    return months.toList()..sort((a, b) { final ap = a.split('-'); final bp = b.split('-'); return DateTime(int.parse(bp[1]), int.parse(bp[0])).compareTo(DateTime(int.parse(ap[1]), int.parse(ap[0]))); });
  }
  String _periodLabel(String p) { final parts = p.split('-'); return '${monthName(int.parse(parts[0]))} ${parts[1]}'; }

  List<IncomeEntry> get _filtered {
    var list = appState.incomeEntries;
    if (_q.isNotEmpty) { final q = _q.toLowerCase(); list = list.where((e) => (e.receivedFrom?.toLowerCase().contains(q) ?? false) || (e.description?.toLowerCase().contains(q) ?? false) || (e.referenceNo?.toLowerCase().contains(q) ?? false)).toList(); }
    if (_catFilter != null) list = list.where((e) => e.category == _catFilter).toList();
    if (_methodFilter != null) list = list.where((e) => e.paymentMethod == _methodFilter).toList();
    if (_period != null) { final parts = _period!.split('-'); final m = int.parse(parts[0]); final y = int.parse(parts[1]); list = list.where((e) => e.date.month == m && e.date.year == y).toList(); }
    return list;
  }

  void _addIncome() => _showIncomeForm();
  void _editIncome(IncomeEntry entry) => _showIncomeForm(existing: entry);

  void _showIncomeForm({IncomeEntry? existing}) {
    final editing = existing != null;
    final p = appState.palette;
    final amtCtrl = TextEditingController(text: existing != null ? existing.amount.toStringAsFixed(0) : '');
    final fromCtrl = TextEditingController(text: existing?.receivedFrom ?? '');
    final refCtrl = TextEditingController(text: existing?.referenceNo ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    var cat = existing?.category ?? IncomeCategory.treatmentRevenue;
    var method = existing?.paymentMethod ?? PaymentMethod.cash;
    DateTime date = existing?.date ?? DateTime.now();
    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, ss) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 560, padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: p.border)),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(editing ? 'EDIT INCOME ENTRY' : 'ADD INCOME ENTRY', style: p.display(22, spacing: 1.0)),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: Dropdown2<IncomeCategory>(label: 'Category *', value: cat, items: IncomeCategory.values.map((c) => DropdownMenuItem(value: c, child: Text(c.label))).toList(), onChanged: (v) => ss(() => cat = v ?? cat))),
            const SizedBox(width: 16),
            Expanded(child: FormField2(label: 'Amount (PKR) *', controller: amtCtrl, hint: '0.00', keyboard: TextInputType.number)),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: Dropdown2<PaymentMethod>(label: 'Payment Method *', value: method, items: PaymentMethod.values.map((m) => DropdownMenuItem(value: m, child: Text(m.label))).toList(), onChanged: (v) => ss(() => method = v ?? method))),
            const SizedBox(width: 16),
            Expanded(child: _DatePicker(label: 'Date *', value: date, palette: p, onPick: (d) => ss(() => date = d))),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: FormField2(label: 'Received From', controller: fromCtrl, hint: 'Patient name / company')),
            const SizedBox(width: 16),
            Expanded(child: FormField2(label: 'Reference No.', controller: refCtrl, hint: 'Invoice / transaction ID')),
          ]),
          const SizedBox(height: 16),
          FormField2(label: 'Description', controller: descCtrl, hint: 'Details about this income...', maxLines: 2),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            GhostButton(label: 'Cancel', onTap: () => Navigator.pop(ctx)),
            const SizedBox(width: 12),
            GoldButton(label: 'Save Entry', onTap: () {
              final amt = double.tryParse(amtCtrl.text);
              if (amt == null) return;
              if (editing) {
                existing!.date = date; existing.category = cat; existing.amount = amt; existing.paymentMethod = method;
                existing.referenceNo = refCtrl.text.isEmpty ? null : refCtrl.text;
                existing.receivedFrom = fromCtrl.text.isEmpty ? null : fromCtrl.text;
                existing.description = descCtrl.text.isEmpty ? null : descCtrl.text;
                appState.updateIncomeEntry(existing);
              } else {
                appState.addIncomeEntry(IncomeEntry(id: appState.createIncomeId(), date: date, category: cat, amount: amt, paymentMethod: method, referenceNo: refCtrl.text.isEmpty ? null : refCtrl.text, receivedFrom: fromCtrl.text.isEmpty ? null : fromCtrl.text, description: descCtrl.text.isEmpty ? null : descCtrl.text));
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
    final list = _filtered;
    final total = list.fold(0.0, (s, e) => s + e.amount);
    return Column(children: [
      Row(children: [const Spacer(), GoldButton(label: 'Add Income', icon: Icons.add, onTap: _addIncome)]),
      const SizedBox(height: 8),
      FilterBar(
        searchHint: 'Search received from, description, ref. no…', onSearch: (v) => setState(() => _q = v),
        filters: [
          FilterDropdown<IncomeCategory?>(value: _catFilter, icon: Icons.category_outlined, items: [const DropdownMenuItem(value: null, child: Text('All Categories')), ...IncomeCategory.values.map((c) => DropdownMenuItem(value: c, child: Text(c.label)))], onChanged: (v) => setState(() => _catFilter = v)),
          FilterDropdown<PaymentMethod?>(value: _methodFilter, icon: Icons.payment_outlined, items: [const DropdownMenuItem(value: null, child: Text('All Methods')), ...PaymentMethod.values.map((m) => DropdownMenuItem(value: m, child: Text(m.label)))], onChanged: (v) => setState(() => _methodFilter = v)),
          FilterDropdown<String?>(value: _period, icon: Icons.calendar_month_outlined, items: [const DropdownMenuItem<String?>(value: null, child: Text('All Periods')), ..._periods.map((p) => DropdownMenuItem<String?>(value: p, child: Text(_periodLabel(p))))], onChanged: (v) => setState(() => _period = v)),
        ],
        countText: '${list.length} entries | ${money(total)}',
        onClear: () => setState(() { _catFilter = null; _methodFilter = null; _period = null; }),
      ),
      const SizedBox(height: 12),
      Expanded(child: Panel(padding: EdgeInsets.zero, child: ScrollArea(builder: (sc) => SingleChildScrollView(controller: sc, child: FullWidthDataTable(child: DataTable(
        key: ValueKey(list.length),
        headingRowColor: WidgetStateProperty.all(p.surfaceAlt),
        columnSpacing: 16, horizontalMargin: 20,
        columns: [
          DataColumn(label: Text('Date', style: p.body(12, weight: FontWeight.w700))),
          DataColumn(label: Text('Category', style: p.body(12, weight: FontWeight.w700))),
          DataColumn(numeric: true, label: Text('Amount', style: p.body(12, weight: FontWeight.w700))),
          DataColumn(label: Text('Method', style: p.body(12, weight: FontWeight.w700))),
          DataColumn(label: Text('Received From', style: p.body(12, weight: FontWeight.w700))),
          DataColumn(label: Text('Ref. No.', style: p.body(12, weight: FontWeight.w700))),
          DataColumn(label: Text('Description', style: p.body(12, weight: FontWeight.w700))),
          DataColumn(label: Text('Verified', style: p.body(12, weight: FontWeight.w700))),
          DataColumn(label: Text('Action', style: p.body(12, weight: FontWeight.w700))),
        ],
        rows: list.map((e) => DataRow(cells: [
          DataCell(Text(prettyShort(e.date), style: p.body(12.5))),
          DataCell(StatusChip(label: e.category.label, color: p.success)),
          DataCell(Text(money(e.amount), style: p.body(13.5, weight: FontWeight.w700, color: p.success))),
          DataCell(Text(e.paymentMethod.label, style: p.body(12.5))),
          DataCell(Text(e.receivedFrom ?? '—', style: p.body(12.5))),
          DataCell(Text(e.referenceNo ?? '—', style: p.body(12.5, color: p.textMuted))),
          DataCell(SizedBox(width: 200, child: Text(e.description ?? '—', style: p.body(12.5, color: p.textMuted), maxLines: 2, overflow: TextOverflow.ellipsis))),
          DataCell(Icon(e.isVerified ? Icons.check_circle_outline : Icons.pending_outlined, size: 18, color: e.isVerified ? p.success : p.warning)),
          DataCell(Row(mainAxisSize: MainAxisSize.min, children: [
            GestureDetector(onTap: () => _editIncome(e), child: MouseRegion(cursor: SystemMouseCursors.click, child: Container(width: 30, height: 30, decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(8)), child: Icon(Icons.edit_outlined, size: 15, color: p.text)))),
            const SizedBox(width: 6),
            GestureDetector(onTap: () { appState.deleteIncomeEntry(e); setState(() {}); }, child: MouseRegion(cursor: SystemMouseCursors.click, child: Container(width: 30, height: 30, decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(8)), child: Icon(Icons.delete_outline, size: 15, color: p.textMuted)))),
          ])),
        ])).toList(),
      ))))))
    ]);
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// EXPENSES TAB
// ══════════════════════════════════════════════════════════════════════════════
class _ExpensesTab extends StatefulWidget {
  const _ExpensesTab();
  @override
  State<_ExpensesTab> createState() => _ExpensesTabState();
}

class _ExpensesTabState extends State<_ExpensesTab> {
  String _q = '';
  ExpenseCategory? _catFilter;
  PaymentMethod? _methodFilter;
  String? _period;
  bool? _approvedFilter;
  final _searchCtrl = TextEditingController();

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  List<String> get _periods {
    final months = <String>{};
    for (final e in appState.expenseEntries) months.add('${e.date.month}-${e.date.year}');
    return months.toList()..sort((a, b) { final ap = a.split('-'); final bp = b.split('-'); return DateTime(int.parse(bp[1]), int.parse(bp[0])).compareTo(DateTime(int.parse(ap[1]), int.parse(ap[0]))); });
  }
  String _periodLabel(String p) { final parts = p.split('-'); return '${monthName(int.parse(parts[0]))} ${parts[1]}'; }

  List<ExpenseEntry> get _filtered {
    var list = appState.expenseEntries;
    if (_q.isNotEmpty) { final q = _q.toLowerCase(); list = list.where((e) => (e.vendor?.toLowerCase().contains(q) ?? false) || (e.description?.toLowerCase().contains(q) ?? false) || (e.invoiceNo?.toLowerCase().contains(q) ?? false)).toList(); }
    if (_catFilter != null) list = list.where((e) => e.category == _catFilter).toList();
    if (_methodFilter != null) list = list.where((e) => e.paymentMethod == _methodFilter).toList();
    if (_approvedFilter != null) list = list.where((e) => e.isApproved == _approvedFilter).toList();
    if (_period != null) { final parts = _period!.split('-'); final m = int.parse(parts[0]); final y = int.parse(parts[1]); list = list.where((e) => e.date.month == m && e.date.year == y).toList(); }
    return list;
  }

  void _addExpense() => _showExpenseForm();
  void _editExpense(ExpenseEntry entry) => _showExpenseForm(existing: entry);

  void _showExpenseForm({ExpenseEntry? existing}) {
    final editing = existing != null;
    final p = appState.palette;
    final amtCtrl = TextEditingController(text: existing != null ? existing.amount.toStringAsFixed(0) : '');
    final vendorCtrl = TextEditingController(text: existing?.vendor ?? '');
    final invCtrl = TextEditingController(text: existing?.invoiceNo ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    var cat = existing?.category ?? ExpenseCategory.supplies;
    var method = existing?.paymentMethod ?? PaymentMethod.cash;
    DateTime date = existing?.date ?? DateTime.now();
    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, ss) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 560, padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: p.border)),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(editing ? 'EDIT EXPENSE ENTRY' : 'ADD EXPENSE ENTRY', style: p.display(22, spacing: 1.0)),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: Dropdown2<ExpenseCategory>(label: 'Category *', value: cat, items: ExpenseCategory.values.map((c) => DropdownMenuItem(value: c, child: Text(c.label))).toList(), onChanged: (v) => ss(() => cat = v ?? cat))),
            const SizedBox(width: 16),
            Expanded(child: FormField2(label: 'Amount (PKR) *', controller: amtCtrl, hint: '0.00', keyboard: TextInputType.number)),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: Dropdown2<PaymentMethod>(label: 'Payment Method *', value: method, items: PaymentMethod.values.map((m) => DropdownMenuItem(value: m, child: Text(m.label))).toList(), onChanged: (v) => ss(() => method = v ?? method))),
            const SizedBox(width: 16),
            Expanded(child: _DatePicker(label: 'Date *', value: date, palette: p, onPick: (d) => ss(() => date = d))),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: FormField2(label: 'Vendor / Payee', controller: vendorCtrl, hint: 'e.g. MedStar Supplies')),
            const SizedBox(width: 16),
            Expanded(child: FormField2(label: 'Invoice / Bill No.', controller: invCtrl, hint: 'e.g. INV-4521')),
          ]),
          const SizedBox(height: 16),
          FormField2(label: 'Description', controller: descCtrl, hint: 'Details about this expense...', maxLines: 2),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            GhostButton(label: 'Cancel', onTap: () => Navigator.pop(ctx)),
            const SizedBox(width: 12),
            GoldButton(label: editing ? 'Save Changes' : 'Save Entry', onTap: () {
              final amt = double.tryParse(amtCtrl.text);
              if (amt == null) return;
              if (editing) {
                existing!.date = date; existing.category = cat; existing.amount = amt; existing.paymentMethod = method;
                existing.vendor = vendorCtrl.text.isEmpty ? null : vendorCtrl.text;
                existing.invoiceNo = invCtrl.text.isEmpty ? null : invCtrl.text;
                existing.description = descCtrl.text.isEmpty ? null : descCtrl.text;
                appState.updateExpenseEntry(existing);
              } else {
                appState.addExpenseEntry(ExpenseEntry(id: appState.createExpenseId(), date: date, category: cat, amount: amt, paymentMethod: method, vendor: vendorCtrl.text.isEmpty ? null : vendorCtrl.text, invoiceNo: invCtrl.text.isEmpty ? null : invCtrl.text, description: descCtrl.text.isEmpty ? null : descCtrl.text));
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
    final list = _filtered;
    final total = list.fold(0.0, (s, e) => s + e.amount);
    return Column(children: [
      Row(children: [const Spacer(), GoldButton(label: 'Add Expense', icon: Icons.add, onTap: _addExpense)]),
      const SizedBox(height: 8),
      Panel(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          FilterDropdown<ExpenseCategory?>(value: _catFilter, icon: Icons.category_outlined, items: [const DropdownMenuItem(value: null, child: Text('All Categories')), ...ExpenseCategory.values.map((c) => DropdownMenuItem(value: c, child: Text(c.label)))], onChanged: (v) => setState(() => _catFilter = v)),
          const SizedBox(width: 10),
          FilterDropdown<PaymentMethod?>(value: _methodFilter, icon: Icons.payment_outlined, items: [const DropdownMenuItem(value: null, child: Text('All Methods')), ...PaymentMethod.values.map((m) => DropdownMenuItem(value: m, child: Text(m.label)))], onChanged: (v) => setState(() => _methodFilter = v)),
          const SizedBox(width: 10),
          FilterDropdown<bool?>(value: _approvedFilter, icon: Icons.verified_outlined, items: const [DropdownMenuItem<bool?>(value: null, child: Text('All Statuses')), DropdownMenuItem<bool?>(value: true, child: Text('Approved')), DropdownMenuItem<bool?>(value: false, child: Text('Pending'))], onChanged: (v) => setState(() => _approvedFilter = v)),
          const SizedBox(width: 10),
          FilterDropdown<String?>(value: _period, icon: Icons.calendar_month_outlined, items: [const DropdownMenuItem<String?>(value: null, child: Text('All Periods')), ..._periods.map((p) => DropdownMenuItem<String?>(value: p, child: Text(_periodLabel(p))))], onChanged: (v) => setState(() => _period = v)),
          const Spacer(),
          Text('${list.length} entries | ${moneyShort(total)}', style: p.body(12, color: p.textMuted, weight: FontWeight.w500)),
          const SizedBox(width: 8),
          GhostButton(label: 'Clear', icon: Icons.refresh, onTap: () { _searchCtrl.clear(); setState(() { _q = ''; _catFilter = null; _methodFilter = null; _approvedFilter = null; _period = null; }); }),
        ]),
        const SizedBox(height: 10),
        SearchBox(controller: _searchCtrl, hint: 'Search vendor, description, invoice no…', onChanged: (v) => setState(() => _q = v)),
      ])),
      const SizedBox(height: 12),
      Expanded(child: Panel(padding: EdgeInsets.zero, child: ScrollArea(builder: (sc) => SingleChildScrollView(controller: sc, child: FullWidthDataTable(child: DataTable(
        key: ValueKey(list.length),
        headingRowColor: WidgetStateProperty.all(p.surfaceAlt),
        columnSpacing: 16, horizontalMargin: 20,
        columns: [
          DataColumn(label: Text('Date', style: p.body(12, weight: FontWeight.w700))),
          DataColumn(label: Text('Category', style: p.body(12, weight: FontWeight.w700))),
          DataColumn(numeric: true, label: Text('Amount', style: p.body(12, weight: FontWeight.w700))),
          DataColumn(label: Text('Method', style: p.body(12, weight: FontWeight.w700))),
          DataColumn(label: Text('Vendor', style: p.body(12, weight: FontWeight.w700))),
          DataColumn(label: Text('Invoice No.', style: p.body(12, weight: FontWeight.w700))),
          DataColumn(label: Text('Description', style: p.body(12, weight: FontWeight.w700))),
          DataColumn(label: Text('Status', style: p.body(12, weight: FontWeight.w700))),
          DataColumn(label: Text('Action', style: p.body(12, weight: FontWeight.w700))),
        ],
        rows: list.map((e) => DataRow(cells: [
          DataCell(Text(prettyShort(e.date), style: p.body(12.5))),
          DataCell(StatusChip(label: e.category.label, color: p.danger)),
          DataCell(Text(money(e.amount), style: p.body(13.5, weight: FontWeight.w700, color: Color.lerp(p.danger, p.textMuted, 0.28)!))),
          DataCell(Text(e.paymentMethod.label, style: p.body(12.5))),
          DataCell(Text(e.vendor ?? '—', style: p.body(12.5))),
          DataCell(Text(e.invoiceNo ?? '—', style: p.body(12.5, color: p.textMuted))),
          DataCell(SizedBox(width: 180, child: Text(e.description ?? '—', style: p.body(12.5, color: p.textMuted), maxLines: 2, overflow: TextOverflow.ellipsis))),
          DataCell(StatusChip(label: e.isApproved ? 'Approved' : 'Pending', color: e.isApproved ? p.success : p.warning)),
          DataCell(Row(mainAxisSize: MainAxisSize.min, children: [
            if (!e.isApproved) ...[GestureDetector(onTap: () { e.isApproved = true; e.approvedBy = appState.currentUser?.name; setState(() {}); }, child: MouseRegion(cursor: SystemMouseCursors.click, child: Container(width: 30, height: 30, decoration: BoxDecoration(color: p.success.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)), child: Icon(Icons.check_circle_outline, size: 15, color: p.success)))), const SizedBox(width: 6)],
            GestureDetector(onTap: () => _editExpense(e), child: MouseRegion(cursor: SystemMouseCursors.click, child: Container(width: 30, height: 30, decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(8)), child: Icon(Icons.edit_outlined, size: 15, color: p.text)))),
            const SizedBox(width: 6),
            GestureDetector(onTap: () { appState.deleteExpenseEntry(e); setState(() {}); }, child: MouseRegion(cursor: SystemMouseCursors.click, child: Container(width: 30, height: 30, decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(8)), child: Icon(Icons.delete_outline, size: 15, color: p.textMuted)))),
          ])),
        ])).toList(),
      ))))))
    ]);
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// CASH BOOK TAB  (enhanced — Add Entry + date-range filter)
// ══════════════════════════════════════════════════════════════════════════════
class _CashBookTab extends StatefulWidget {
  const _CashBookTab();
  @override
  State<_CashBookTab> createState() => _CashBookTabState();
}

class _CashBookTabState extends State<_CashBookTab> {
  String _range = 'This Month'; // This Month / Last Month / All Time
  // Local extra entries added via "Add Entry" — merged with appState seed
  final _local = <CashBookEntry>[];

  static const _categories = ['Sales', 'Salaries', 'Rent', 'Utilities', 'Supplies', 'Miscellaneous'];

  List<CashBookEntry> get _all {
    final combined = [...appState.cashBookEntries, ..._local];
    combined.sort((a, b) => b.date.compareTo(a.date));
    final now = DateTime.now();
    return combined.where((e) {
      if (_range == 'This Month') return e.date.month == now.month && e.date.year == now.year;
      if (_range == 'Last Month') { final lm = DateTime(now.year, now.month - 1); return e.date.month == lm.month && e.date.year == lm.year; }
      return true;
    }).toList();
  }

  void _addEntry() {
    final p = appState.palette;
    final descCtrl = TextEditingController();
    final amtCtrl = TextEditingController();
    final partyCtrl = TextEditingController();
    String type = 'receipt';
    String category = 'Sales';
    DateTime date = DateTime.now();

    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, ss) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(width: 520, padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: p.border)),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('ADD CASH BOOK ENTRY', style: p.display(22, spacing: 1.0)),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: Dropdown2<String>(label: 'Type', value: type,
              items: [DropdownMenuItem(value: 'receipt', child: Text('Credit (Receipt)')), DropdownMenuItem(value: 'payment', child: Text('Debit (Payment)'))],
              onChanged: (v) => ss(() => type = v ?? type))),
            const SizedBox(width: 14),
            Expanded(child: FormField2(label: 'Amount (PKR) *', controller: amtCtrl, hint: '0.00', keyboard: TextInputType.number)),
          ]),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: FormField2(label: 'Description *', controller: descCtrl, hint: 'Details of transaction')),
            const SizedBox(width: 14),
            Expanded(child: Dropdown2<String>(label: 'Category', value: category,
              items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => ss(() => category = v ?? category))),
          ]),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: FormField2(label: 'Party / Description', controller: partyCtrl, hint: 'Person or company name')),
            const SizedBox(width: 14),
            Expanded(child: _DatePicker(label: 'Date', value: date, palette: p, onPick: (d) => ss(() => date = d))),
          ]),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            GhostButton(label: 'Cancel', onTap: () => Navigator.pop(ctx)),
            const SizedBox(width: 12),
            GoldButton(label: 'Add Entry', onTap: () {
              final amt = double.tryParse(amtCtrl.text);
              if (amt == null || descCtrl.text.isEmpty) return;
              final prevBal = _all.isEmpty ? appState.cashBalance : _all.first.runningBalance;
              final newBal = type == 'receipt' ? prevBal + amt : prevBal - amt;
              setState(() => _local.add(CashBookEntry(
                id: 'CB-L-${_local.length + 1}', date: date, type: type, amount: amt,
                description: descCtrl.text, party: partyCtrl.text.isEmpty ? null : partyCtrl.text,
                referenceNo: category, runningBalance: newBal,
              )));
              Navigator.pop(ctx);
              toast(context, 'Cash book entry added');
            }),
          ]),
        ]),
      ),
    )));
  }

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final entries = _all;
    final receipts = entries.where((e) => e.type == 'receipt').fold(0.0, (s, e) => s + e.amount);
    final payments = entries.where((e) => e.type == 'payment').fold(0.0, (s, e) => s + e.amount);
    final opening = entries.isEmpty ? 0.0 : (entries.last.runningBalance - entries.last.amount * (entries.last.type == 'receipt' ? 1 : -1));
    final closing = entries.isEmpty ? 0.0 : entries.first.runningBalance;

    return Column(children: [
      Row(children: [
        SizedBox(
          width: 160,
          child: Dropdown2<String>(label: '', value: _range,
            items: ['This Month', 'Last Month', 'All Time'].map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
            onChanged: (v) => setState(() => _range = v ?? _range)),
        ),
        const Spacer(),
        GoldButton(label: 'Add Entry', icon: Icons.add, onTap: _addEntry),
      ]),
      const SizedBox(height: 12),
      Panel(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14), child: Row(children: [
        _CashStat('Opening Balance', opening, p.textMuted, p),
        _Divider(p),
        _CashStat('Total Receipts', receipts, p.success, p),
        _Divider(p),
        _CashStat('Total Payments', payments, p.danger, p),
        _Divider(p),
        _CashStat('Closing Balance', closing, p.gold, p),
      ])),
      const SizedBox(height: 12),
      Expanded(child: Panel(padding: EdgeInsets.zero, child: ScrollArea(builder: (sc) => SingleChildScrollView(controller: sc, child: FullWidthDataTable(child: DataTable(
        key: ValueKey(entries.length),
        headingRowColor: WidgetStateProperty.all(p.surfaceAlt),
        columnSpacing: 20, horizontalMargin: 20,
        columns: [
          DataColumn(label: Text('Date', style: p.body(12, weight: FontWeight.w700))),
          DataColumn(label: Text('Description', style: p.body(12, weight: FontWeight.w700))),
          DataColumn(label: Text('Type', style: p.body(12, weight: FontWeight.w700))),
          DataColumn(label: Text('Party', style: p.body(12, weight: FontWeight.w700))),
          DataColumn(numeric: true, label: Text('Amount', style: p.body(12, weight: FontWeight.w700))),
          DataColumn(numeric: true, label: Text('Balance', style: p.body(12, weight: FontWeight.w700))),
        ],
        rows: entries.map((e) => DataRow(cells: [
          DataCell(Text(prettyShort(e.date), style: p.body(12.5))),
          DataCell(Text(e.description, style: p.body(12.5))),
          DataCell(StatusChip(label: e.type == 'receipt' ? 'Credit' : 'Debit', color: e.type == 'receipt' ? p.success : p.danger)),
          DataCell(Text(e.party ?? '—', style: p.body(12.5, color: p.textMuted))),
          DataCell(Text(money(e.amount), style: p.body(13, color: e.type == 'receipt' ? p.success : p.danger, weight: FontWeight.w600))),
          DataCell(Text(money(e.runningBalance), style: p.body(13.5, color: p.gold, weight: FontWeight.w700))),
        ])).toList(),
      ))))))
    ]);
  }
}

Widget _CashStat(String label, double value, Color color, AppPalette p) => Expanded(child: Column(children: [
  Text(label, style: p.body(11.5, color: p.textMuted, weight: FontWeight.w600)), const SizedBox(height: 4),
  Text(money(value), style: p.body(16, color: color, weight: FontWeight.w700)),
]));

Widget _Divider(AppPalette p) => Container(width: 1, height: 40, margin: const EdgeInsets.symmetric(horizontal: 20), color: p.border);

// ══════════════════════════════════════════════════════════════════════════════
// BANK ACCOUNTS TAB  (enhanced — Reconcile + Add Transaction per account)
// ══════════════════════════════════════════════════════════════════════════════

// Local transaction entry (stored per bank tab session)
class _BankTxn {
  final String bankId, type, reference, notes;
  final double amount;
  final DateTime date;
  bool reconciled;
  _BankTxn({required this.bankId, required this.type, required this.amount, required this.date, required this.reference, this.notes = '', this.reconciled = false});
}

class _BankTab extends StatefulWidget {
  const _BankTab();
  @override
  State<_BankTab> createState() => _BankTabState();
}

class _BankTabState extends State<_BankTab> {
  // Local transactions added in this session
  final _txns = <_BankTxn>[
    _BankTxn(bankId: 'BA-1', type: 'Deposit', amount: 150000, date: DateTime(2026, 7, 1), reference: 'REF-001', notes: 'Patient payment batch'),
    _BankTxn(bankId: 'BA-1', type: 'Withdrawal', amount: 45000, date: DateTime(2026, 6, 30), reference: 'REF-002', notes: 'Supplier payment'),
    _BankTxn(bankId: 'BA-2', type: 'Deposit', amount: 220000, date: DateTime(2026, 6, 28), reference: 'PAY-55', notes: 'Salary credit', reconciled: true),
  ];

  void _addAccount() {
    final p = appState.palette;
    final bankCtrl = TextEditingController();
    final titleCtrl = TextEditingController();
    final acNoCtrl = TextEditingController();
    final branchCtrl = TextEditingController();
    final ibanCtrl = TextEditingController();
    final balCtrl = TextEditingController();
    showDialog(context: context, builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 560, padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: p.border)),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('ADD BANK ACCOUNT', style: p.display(22, spacing: 1.0)),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: FormField2(label: 'Bank Name *', controller: bankCtrl, hint: 'e.g. HBL')),
            const SizedBox(width: 16),
            Expanded(child: FormField2(label: 'Account Title *', controller: titleCtrl, hint: 'e.g. Hair Again Clinic')),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: FormField2(label: 'Account Number *', controller: acNoCtrl, hint: '0001234567890')),
            const SizedBox(width: 16),
            Expanded(child: FormField2(label: 'Branch Name', controller: branchCtrl, hint: 'e.g. Clifton Branch')),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: FormField2(label: 'IBAN', controller: ibanCtrl, hint: 'PK12HABB0001234567890000')),
            const SizedBox(width: 16),
            Expanded(child: FormField2(label: 'Opening Balance (PKR)', controller: balCtrl, hint: '0.00', keyboard: TextInputType.number)),
          ]),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            GhostButton(label: 'Cancel', onTap: () => Navigator.pop(ctx)),
            const SizedBox(width: 12),
            GoldButton(label: 'Save Account', onTap: () {
              if (bankCtrl.text.isEmpty) return;
              final bal = double.tryParse(balCtrl.text) ?? 0;
              appState.bankAccounts.add(BankAccount(id: 'BA-${appState.bankAccounts.length + 1}', bankName: bankCtrl.text, accountTitle: titleCtrl.text, accountNumber: acNoCtrl.text, branchName: branchCtrl.text, iban: ibanCtrl.text, openingBalance: bal, currentBalance: bal));
              Navigator.pop(ctx); setState(() {});
            }),
          ]),
        ]),
      ),
    ));
  }

  void _reconcile(BankAccount ba) {
    final p = appState.palette;
    final acctTxns = _txns.where((t) => t.bankId == ba.id).toList();
    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, ss) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(width: 600, padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: p.border)),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('RECONCILE — ${ba.bankName}', style: p.display(22, spacing: 1.0)),
          const SizedBox(height: 6),
          Text('Check each transaction that appears on your bank statement.', style: p.body(12.5, color: p.textMuted)),
          const SizedBox(height: 18),
          acctTxns.isEmpty
            ? Padding(padding: const EdgeInsets.all(20), child: Center(child: Text('No transactions for this account.', style: p.body(13, color: p.textMuted))))
            : Column(children: acctTxns.map((t) => CheckboxListTile(
                value: t.reconciled, activeColor: p.gold,
                title: Text('${prettyShort(t.date)} — ${t.type}  |  ${money(t.amount)}', style: p.body(13)),
                subtitle: Text('${t.reference}  ${t.notes}', style: p.body(11.5, color: p.textMuted)),
                onChanged: (v) { ss(() => t.reconciled = v ?? false); setState(() {}); },
              )).toList()),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            Text('${acctTxns.where((t) => t.reconciled).length}/${acctTxns.length} reconciled', style: p.body(12.5, color: p.textMuted)),
            const Spacer(),
            GhostButton(label: 'Done', onTap: () => Navigator.pop(ctx)),
          ]),
        ]),
      ),
    )));
  }

  void _addTransaction(BankAccount ba) {
    final p = appState.palette;
    final amtCtrl = TextEditingController();
    final refCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    String type = 'Deposit';
    DateTime date = DateTime.now();
    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, ss) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(width: 500, padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: p.border)),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('ADD TRANSACTION — ${ba.bankName}', style: p.display(20, spacing: 0.5)),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: Dropdown2<String>(label: 'Type', value: type,
              items: ['Deposit', 'Withdrawal', 'Transfer'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (v) => ss(() => type = v ?? type))),
            const SizedBox(width: 14),
            Expanded(child: FormField2(label: 'Amount (PKR) *', controller: amtCtrl, hint: '0.00', keyboard: TextInputType.number)),
          ]),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: FormField2(label: 'Reference No.', controller: refCtrl, hint: 'Cheque / TRN no.')),
            const SizedBox(width: 14),
            Expanded(child: _DatePicker(label: 'Date', value: date, palette: p, onPick: (d) => ss(() => date = d))),
          ]),
          const SizedBox(height: 14),
          FormField2(label: 'Notes', controller: notesCtrl, hint: 'Transaction details…', maxLines: 2),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            GhostButton(label: 'Cancel', onTap: () => Navigator.pop(ctx)),
            const SizedBox(width: 12),
            GoldButton(label: 'Add Transaction', onTap: () {
              final amt = double.tryParse(amtCtrl.text);
              if (amt == null) return;
              setState(() {
                _txns.insert(0, _BankTxn(bankId: ba.id, type: type, amount: amt, date: date, reference: refCtrl.text, notes: notesCtrl.text));
                if (type == 'Deposit') ba.currentBalance += amt;
                else if (type == 'Withdrawal') ba.currentBalance -= amt;
              });
              Navigator.pop(ctx);
              toast(context, 'Transaction recorded');
            }),
          ]),
        ]),
      ),
    )));
  }

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final demoBanks = [
      if (appState.bankAccounts.isEmpty) ...[
        BankAccount(id: 'BA-1', bankName: 'HBL', accountTitle: 'Hair Again Main Account', accountNumber: 'XXXX-XXXX-1234', branchName: 'Clifton Branch', iban: 'PK36HABB0000001123456702', openingBalance: 500000, currentBalance: 642500, isPrimary: true),
        BankAccount(id: 'BA-2', bankName: 'MCB', accountTitle: 'Hair Again Payroll Account', accountNumber: 'XXXX-XXXX-5678', branchName: 'DHA Branch', iban: 'PK74MUCB0002010098765014', openingBalance: 300000, currentBalance: 220000),
      ],
      ...appState.bankAccounts,
    ];
    return Column(children: [
      Row(children: [const Spacer(), GoldButton(label: 'Add Bank Account', icon: Icons.add, onTap: _addAccount)]),
      const SizedBox(height: 12),
      Expanded(child: ScrollArea(builder: (sc) => SingleChildScrollView(controller: sc, child: Wrap(spacing: 18, runSpacing: 18, children: demoBanks.map((ba) {
        final lastTxn = _txns.where((t) => t.bankId == ba.id).toList()..sort((a, b) => b.date.compareTo(a.date));
        return SizedBox(width: 400, child: Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: p.gold.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)), child: Icon(Icons.account_balance_outlined, size: 22, color: p.gold)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(ba.bankName, style: p.body(15, weight: FontWeight.w700)),
                if (ba.isPrimary) ...[const SizedBox(width: 8), StatusChip(label: 'Primary', color: p.gold)],
              ]),
              Text(ba.accountTitle, style: p.body(12.5, color: p.textMuted)),
            ])),
          ]),
          const SizedBox(height: 16),
          Text('CURRENT BALANCE', style: p.body(10.5, color: p.textMuted, weight: FontWeight.w700, spacing: 1.0)),
          Text(money(ba.currentBalance), style: p.display(28, color: p.gold)),
          const SizedBox(height: 16),
          Divider(height: 1, color: p.border),
          const SizedBox(height: 14),
          _BankDetail('Account No.', ba.accountNumber, p),
          _BankDetail('Branch', ba.branchName, p),
          _BankDetail('IBAN', ba.iban, p),
          _BankDetail('Opening Balance', money(ba.openingBalance), p),
          if (lastTxn.isNotEmpty) _BankDetail('Last Transaction', prettyShort(lastTxn.first.date), p),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: GhostButton(label: 'Reconcile', icon: Icons.checklist_outlined, dense: true, onTap: () => _reconcile(ba))),
            const SizedBox(width: 10),
            Expanded(child: GoldButton(label: 'Add Transaction', icon: Icons.add, dense: true, onTap: () => _addTransaction(ba))),
          ]),
        ])));
      }).toList())))),
    ]);
  }
}

Widget _BankDetail(String label, String value, AppPalette p) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [
  SizedBox(width: 140, child: Text(label, style: p.body(12, color: p.textMuted))),
  Expanded(child: Text(value, style: p.body(12.5, weight: FontWeight.w600))),
]));

// ══════════════════════════════════════════════════════════════════════════════
// JOURNAL ENTRIES TAB
// ══════════════════════════════════════════════════════════════════════════════
class _JournalTab extends StatefulWidget {
  const _JournalTab();
  @override
  State<_JournalTab> createState() => _JournalTabState();
}

class _JournalTabState extends State<_JournalTab> {
  void _addJournal() {
    final p = appState.palette;
    final descCtrl = TextEditingController();
    final refCtrl = TextEditingController();
    var type = 'General';
    DateTime date = DateTime.now();
    final lines = <JournalLine>[JournalLine(account: '', debit: 0, credit: 0), JournalLine(account: '', debit: 0, credit: 0)];
    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, ss) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 700, padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: p.border)),
        child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('NEW JOURNAL ENTRY', style: p.display(22, spacing: 1.0)),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: Dropdown2<String>(label: 'Voucher Type', value: type, items: ['General','Payment','Receipt','Contra'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(), onChanged: (v) => ss(() => type = v ?? type))),
            const SizedBox(width: 16),
            Expanded(child: _DatePicker(label: 'Date', value: date, palette: p, onPick: (d) => ss(() => date = d))),
            const SizedBox(width: 16),
            Expanded(child: FormField2(label: 'Reference No.', controller: refCtrl, hint: 'JV-001')),
          ]),
          const SizedBox(height: 16),
          FormField2(label: 'Description *', controller: descCtrl, hint: 'Journal entry narration...'),
          const SizedBox(height: 20),
          // Lines table
          Container(
            decoration: BoxDecoration(border: Border.all(color: p.border), borderRadius: BorderRadius.circular(8)),
            child: Column(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: const BorderRadius.vertical(top: Radius.circular(7))),
                child: Row(children: [
                  Expanded(flex: 3, child: Text('Account', style: p.body(12, weight: FontWeight.w700))),
                  SizedBox(width: 120, child: Text('Debit (PKR)', style: p.body(12, weight: FontWeight.w700))),
                  const SizedBox(width: 12),
                  SizedBox(width: 120, child: Text('Credit (PKR)', style: p.body(12, weight: FontWeight.w700))),
                  const SizedBox(width: 40),
                ]),
              ),
              ...lines.asMap().entries.map((entry) {
                final i = entry.key;
                final l = entry.value;
                final acCtrl = TextEditingController(text: l.account);
                final drCtrl = TextEditingController(text: l.debit > 0 ? l.debit.toStringAsFixed(0) : '');
                final crCtrl = TextEditingController(text: l.credit > 0 ? l.credit.toStringAsFixed(0) : '');
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(border: Border(top: BorderSide(color: p.border))),
                  child: Row(children: [
                    Expanded(flex: 3, child: TextField(controller: acCtrl, style: p.body(13), cursorColor: p.gold, decoration: InputDecoration(isCollapsed: true, border: InputBorder.none, hintText: 'Account name', hintStyle: p.body(13, color: p.textMuted)), onChanged: (v) => ss(() => l.account = v))),
                    SizedBox(width: 120, child: TextField(controller: drCtrl, style: p.body(13, color: p.success), cursorColor: p.gold, keyboardType: TextInputType.number, decoration: InputDecoration(isCollapsed: true, border: InputBorder.none, hintText: '0', hintStyle: p.body(13, color: p.textMuted)), onChanged: (v) => ss(() => l.debit = double.tryParse(v) ?? 0))),
                    const SizedBox(width: 12),
                    SizedBox(width: 120, child: TextField(controller: crCtrl, style: p.body(13, color: p.danger), cursorColor: p.gold, keyboardType: TextInputType.number, decoration: InputDecoration(isCollapsed: true, border: InputBorder.none, hintText: '0', hintStyle: p.body(13, color: p.textMuted)), onChanged: (v) => ss(() => l.credit = double.tryParse(v) ?? 0))),
                    SizedBox(width: 40, child: IconButton(icon: Icon(Icons.remove_circle_outline, size: 18, color: p.danger), onPressed: () { if (lines.length > 2) ss(() => lines.removeAt(i)); }, padding: EdgeInsets.zero, constraints: const BoxConstraints())),
                  ]),
                );
              }),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(children: [
                  GhostButton(label: 'Add Line', icon: Icons.add, onTap: () => ss(() => lines.add(JournalLine(account: '', debit: 0, credit: 0)))),
                  const Spacer(),
                  Text('Total Debit: ${money(lines.fold(0.0, (s, l) => s + l.debit))}', style: p.body(13, color: p.success, weight: FontWeight.w700)),
                  const SizedBox(width: 20),
                  Text('Total Credit: ${money(lines.fold(0.0, (s, l) => s + l.credit))}', style: p.body(13, color: p.danger, weight: FontWeight.w700)),
                ]),
              ),
            ]),
          ),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            GhostButton(label: 'Cancel', onTap: () => Navigator.pop(ctx)),
            const SizedBox(width: 12),
            GoldButton(label: 'Save Draft', onTap: () {
              if (descCtrl.text.isEmpty) return;
              appState.addJournalEntry(JournalEntry(id: 'JV-${appState.journalEntries.length + 1}', date: date, description: descCtrl.text, referenceNo: refCtrl.text.isEmpty ? null : refCtrl.text, voucherType: type, lines: lines, isPosted: false, createdBy: appState.currentUser?.name ?? 'System'));
              Navigator.pop(ctx); setState(() {});
            }),
            const SizedBox(width: 8),
            GoldButton(label: 'Post Entry', onTap: () {
              if (descCtrl.text.isEmpty) return;
              appState.addJournalEntry(JournalEntry(id: 'JV-${appState.journalEntries.length + 1}', date: date, description: descCtrl.text, referenceNo: refCtrl.text.isEmpty ? null : refCtrl.text, voucherType: type, lines: lines, isPosted: true, createdBy: appState.currentUser?.name ?? 'System'));
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
    return Column(children: [
      Row(children: [const Spacer(), GoldButton(label: 'New Journal Entry', icon: Icons.add, onTap: _addJournal)]),
      const SizedBox(height: 12),
      appState.journalEntries.isEmpty
        ? Expanded(child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.import_contacts_outlined, size: 56, color: p.textMuted),
            const SizedBox(height: 12),
            Text('No journal entries yet', style: p.body(14, color: p.textMuted)),
            const SizedBox(height: 12),
            GoldButton(label: 'Create Journal Entry', icon: Icons.add, onTap: _addJournal),
          ])))
        : Expanded(child: ScrollArea(builder: (sc) => ListView.builder(controller: sc, itemCount: appState.journalEntries.length, itemBuilder: (_, i) {
          final je = appState.journalEntries[i];
          return Panel(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              StatusChip(label: je.voucherType, color: p.info),
              const SizedBox(width: 10),
              Text(je.id, style: p.body(13, weight: FontWeight.w700)),
              const SizedBox(width: 10),
              Text(prettyShort(je.date), style: p.body(12.5, color: p.textMuted)),
              const Spacer(),
              StatusChip(label: je.isBalanced ? 'Balanced' : 'Unbalanced', color: je.isBalanced ? p.success : p.danger),
              const SizedBox(width: 10),
              StatusChip(label: je.isPosted ? 'Posted' : 'Draft', color: je.isPosted ? p.success : p.warning),
              if (!je.isPosted) ...[const SizedBox(width: 10), GoldButton(label: 'Post', onTap: () => setState(() => je.isPosted = true))],
            ]),
            const SizedBox(height: 8),
            Text(je.description, style: p.body(13.5, weight: FontWeight.w600)),
            const SizedBox(height: 10),
            ...je.lines.map((l) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Row(children: [
              Expanded(child: Text(l.account, style: p.body(13))),
              SizedBox(width: 140, child: Text(l.debit > 0 ? money(l.debit) : '', style: p.body(13, color: p.success, weight: FontWeight.w600))),
              SizedBox(width: 140, child: Text(l.credit > 0 ? money(l.credit) : '', style: p.body(13, color: p.danger, weight: FontWeight.w600))),
            ]))),
          ]));
        }))),
    ]);
  }
}

// ── Shared widget ─────────────────────────────────────────────────────────────
class _DatePicker extends StatelessWidget {
  final String label;
  final DateTime value;
  final AppPalette palette;
  final ValueChanged<DateTime> onPick;
  const _DatePicker({required this.label, required this.value, required this.palette, required this.onPick});
  @override
  Widget build(BuildContext context) {
    final p = palette;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: p.body(12, color: p.textMuted, weight: FontWeight.w600)),
      const SizedBox(height: 7),
      GestureDetector(
        onTap: () async {
          final picked = await showDatePicker(context: context, initialDate: value, firstDate: DateTime(2020), lastDate: DateTime(2030),
            builder: (ctx, child) => Theme(data: ThemeData.dark().copyWith(colorScheme: ColorScheme.dark(primary: p.gold, surface: p.surface)), child: child!));
          if (picked != null) onPick(picked);
        },
        child: Container(height: 46, padding: const EdgeInsets.symmetric(horizontal: 14), decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(8), border: Border.all(color: p.border)), child: Row(children: [Icon(Icons.calendar_today_outlined, size: 15, color: p.gold), const SizedBox(width: 10), Text(prettyShort(value), style: p.body(13.5, weight: FontWeight.w500))])),
      ),
    ]);
  }
}

// ── Transactions ──────────────────────────────────────────────────────────────
class _TransactionsTab extends StatefulWidget {
  const _TransactionsTab();
  @override
  State<_TransactionsTab> createState() => _TransactionsTabState();
}

class _TransactionsTabState extends State<_TransactionsTab> {
  String _typeFilter = 'All';
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final incomes = (_typeFilter == 'All' || _typeFilter == 'Income') ? appState.incomeEntries : <IncomeEntry>[];
    final expenses = (_typeFilter == 'All' || _typeFilter == 'Expense') ? appState.expenseEntries : <ExpenseEntry>[];

    final allRows = <_TxRow>[
      ...incomes.map((e) => _TxRow(date: e.date, desc: e.description ?? e.category.name, category: e.category.name, type: 'Income', amount: e.amount, ref: e.referenceNo ?? '')),
      ...expenses.map((e) => _TxRow(date: e.date, desc: e.description ?? e.category.name, category: e.category.name, type: 'Expense', amount: e.amount, ref: e.invoiceNo ?? '')),
    ]..sort((a, b) => b.date.compareTo(a.date));

    final filtered = _search.isEmpty ? allRows : allRows.where((r) => r.desc.toLowerCase().contains(_search.toLowerCase()) || r.category.toLowerCase().contains(_search.toLowerCase())).toList();

    final totalCredits = filtered.where((r) => r.type == 'Income').fold(0.0, (s, r) => s + r.amount);
    final totalDebits = filtered.where((r) => r.type == 'Expense').fold(0.0, (s, r) => s + r.amount);

    return ScrollArea(builder: (sc) => SingleChildScrollView(controller: sc, padding: const EdgeInsets.only(right: 12, bottom: 28), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      MetricRow([
        MetricCard(title: 'Total Transactions', value: '${filtered.length}', delta: '${filtered.length} entries', icon: Icons.swap_horiz_outlined),
        MetricCard(title: 'Total Credits', value: money(totalCredits), delta: 'income total', icon: Icons.add_circle_outline),
        MetricCard(title: 'Total Debits', value: money(totalDebits), delta: 'expense total', deltaUp: false, icon: Icons.remove_circle_outline),
        MetricCard(title: 'Net Position', value: money(totalCredits - totalDebits), delta: 'net balance', deltaUp: totalCredits >= totalDebits, icon: Icons.account_balance_outlined),
      ]),
      const SizedBox(height: 18),
      Row(children: [
        Text('ALL TRANSACTIONS', style: p.display(18, spacing: 1.2)),
        const Spacer(),
        SizedBox(width: 180, child: FormField2(label: '', controller: TextEditingController(text: _search), hint: 'Search...', onChanged: (v) => setState(() => _search = v))),
        const SizedBox(width: 12),
        ...['All', 'Income', 'Expense'].map((t) => Padding(padding: const EdgeInsets.only(left: 6), child: GestureDetector(onTap: () => setState(() => _typeFilter = t), child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), decoration: BoxDecoration(color: _typeFilter == t ? p.gold.withValues(alpha: 0.15) : p.surfaceAlt, borderRadius: BorderRadius.circular(8), border: Border.all(color: _typeFilter == t ? p.gold : p.border)), child: Text(t, style: p.body(13, color: _typeFilter == t ? p.gold : p.textMuted, weight: FontWeight.w600)))))),
      ]),
      const SizedBox(height: 14),
      if (filtered.isEmpty)
        Center(child: Padding(padding: const EdgeInsets.all(40), child: Text('No transactions found.', style: p.body(14, color: p.textMuted)))),
      if (filtered.isNotEmpty)
        Panel(padding: EdgeInsets.zero, child: FullWidthDataTable(child: DataTable(
          key: ValueKey(filtered.length),
          columns: const [DataColumn(label: Text('Date')), DataColumn(label: Text('Description')), DataColumn(label: Text('Category')), DataColumn(label: Text('Type')), DataColumn(label: Text('Amount')), DataColumn(label: Text('Reference'))],
          rows: filtered.map((r) {
            final isIncome = r.type == 'Income';
            return DataRow(cells: [
              DataCell(Text(prettyShort(r.date), style: p.body(13))),
              DataCell(SizedBox(width: 180, child: Text(r.desc, style: p.body(13, weight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis))),
              DataCell(Text(r.category, style: p.body(13, color: p.textMuted))),
              DataCell(StatusChip(label: r.type, color: isIncome ? p.success : p.danger)),
              DataCell(Text(money(r.amount), style: p.body(13, weight: FontWeight.w700, color: isIncome ? p.success : p.danger))),
              DataCell(Text(r.ref.isEmpty ? '—' : r.ref, style: p.body(12, color: p.textMuted))),
            ]);
          }).toList(),
        ))),
    ])));
  }
}

class _TxRow {
  final DateTime date; final String desc, category, type, ref; final double amount;
  _TxRow({required this.date, required this.desc, required this.category, required this.type, required this.amount, required this.ref});
}
