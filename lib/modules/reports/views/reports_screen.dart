import 'package:flutter/material.dart';

import '../../../core/core.dart';
import '../../appointments/models/appointment.dart';
import '../../crm/models/patient.dart';
import '../../finance/models/finance_models.dart';
import '../../inventory/models/inventory_models.dart';
import '../../leads/models/lead_models.dart';
import '../../marketing/models/marketing_models.dart';
import '../../transplant/models/transplant_models.dart';
import '../../treatment/models/treatment_models.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});
  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> with SingleTickerProviderStateMixin {
  late final TabController _tc = TabController(length: 7, vsync: this);
  String _period = 'This Month';
  static const _periods = ['Today', 'This Week', 'This Month', 'This Quarter', 'This Year', 'All Time'];

  @override
  void dispose() { _tc.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: 'REPORTS & ANALYTICS',
      subtitle: 'Comprehensive business intelligence across all modules.',
      actions: [
        FilterDropdown<String>(
          icon: Icons.calendar_today_outlined,
          value: _period,
          items: _periods.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
          onChanged: (v) => setState(() => _period = v ?? 'This Month'),
        ),
        const SizedBox(width: 10),
        GoldButton(label: 'Export PDF', icon: Icons.picture_as_pdf_outlined, onTap: () => showPdfPreview(context, title: 'Reports Export', build: () => buildReportPdf())),
      ],
      child: Column(children: [
        _TabRow(controller: _tc),
        const SizedBox(height: 2),
        Expanded(child: EagerTabBarView(controller: _tc, children: [
          _OverviewTab(period: _period),
          _RevenueTab(period: _period),
          _PatientTab(period: _period),
          _AppointmentTab(period: _period),
          _TreatmentTab(period: _period),
          _InventoryTab(period: _period),
          _MarketingTab(period: _period),
        ])),
      ]),
    );
  }
}

class _TabRow extends StatelessWidget {
  final TabController controller;
  const _TabRow({required this.controller});
  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    const tabs = ['Overview', 'Revenue', 'Patients', 'Appointments', 'Treatments', 'Inventory', 'Marketing'];
    return Container(
      color: p.surface,
      child: TabBar(
        controller: controller,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        labelColor: p.gold,
        unselectedLabelColor: p.textMuted,
        indicatorColor: p.gold,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: p.body(13, weight: FontWeight.w700),
        unselectedLabelStyle: p.body(13),
        tabs: tabs.map((t) => Tab(text: t)).toList(),
      ),
    );
  }
}

// ─── Overview Tab ─────────────────────────────────────────────────────────────
class _OverviewTab extends StatelessWidget {
  final String period;
  const _OverviewTab({required this.period});

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    return ScrollArea(builder: (sc) => SingleChildScrollView(
      controller: sc,
      padding: const EdgeInsets.fromLTRB(0, 16, 12, 28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        MetricRow([
          MetricCard(title: 'Gross Revenue', value: moneyShort(appState.grossRevenue), delta: '+18% vs last month', icon: Icons.account_balance_wallet_outlined),
          MetricCard(title: 'Net Profit', value: moneyShort(appState.grossRevenue - appState.operationalCost), delta: '+12% vs last month', icon: Icons.trending_up_rounded),
          MetricCard(title: 'Active Patients', value: '${appState.patients.length}', delta: '+${appState.patients.where((pt) => pt.status.name == 'new').length} new', icon: Icons.groups_outlined),
          MetricCard(title: 'Pending Invoices', value: moneyShort(appState.pendingInstallments), delta: '${appState.invoices.where((i) => i.balance > 0).length} unpaid', deltaUp: false, icon: Icons.request_quote_outlined),
        ]),
        const SizedBox(height: 18),
        LayoutBuilder(builder: (ctx, c) {
          final wide = c.maxWidth > 900;
          final sales = _salesPanel(p);
          final perf  = _perfPanel(p);
          if (wide) return IntrinsicHeight(child: Row(children: [Expanded(flex: 6, child: sales), const SizedBox(width: 18), Expanded(flex: 4, child: perf)]));
          return Column(children: [sales, const SizedBox(height: 18), perf]);
        }),
        const SizedBox(height: 18),
        _trendPanel(p),
        const SizedBox(height: 18),
        _moduleRevPanel(p),
      ]),
    ));
  }

  Widget _salesPanel(AppPalette p) => Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const SectionTitle('MONTHLY SALES', sub: 'Revenue & procedure volume'),
    const SizedBox(height: 14),
    Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Row(children: [
      Expanded(flex: 3, child: _th(p, 'MONTH')),
      Expanded(flex: 3, child: _th(p, 'REVENUE')),
      Expanded(flex: 2, child: _th(p, 'PROCEDURES')),
      Expanded(flex: 2, child: _th(p, 'AVG/CASE')),
    ])),
    const SizedBox(height: 6),
    Divider(height: 1, color: p.border),
    ...appState.monthlySales.map((r) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(children: [
        Expanded(flex: 3, child: Text(r.month, style: p.body(13, weight: FontWeight.w600))),
        Expanded(flex: 3, child: Text(moneyShort(r.revenue), style: p.body(13))),
        Expanded(flex: 2, child: Text('${r.procedures}', style: p.body(13, color: p.textMuted))),
        Expanded(flex: 2, child: Text(r.procedures == 0 ? '—' : moneyShort(r.revenue / r.procedures), style: p.body(13, color: p.textMuted))),
      ]),
    )),
    Divider(height: 1, color: p.border),
    const SizedBox(height: 10),
    Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Row(children: [
      Expanded(flex: 3, child: Text('TOTAL', style: p.body(12, weight: FontWeight.w700, color: p.gold))),
      Expanded(flex: 3, child: Text(moneyShort(appState.monthlySales.fold(0.0, (s, r) => s + r.revenue)), style: p.body(13, weight: FontWeight.w700))),
      Expanded(flex: 2, child: Text('${appState.monthlySales.fold(0, (s, r) => s + r.procedures)}', style: p.body(13, weight: FontWeight.w700))),
      const Expanded(flex: 2, child: SizedBox()),
    ])),
  ]));

  Widget _perfPanel(AppPalette p) {
    final docs = [(name: 'Dr. Rehman', share: 0.46), (name: 'Dr. Sara Iqbal', share: 0.33), (name: 'Dr. Bilal Khan', share: 0.21)];
    return Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SectionTitle('DOCTOR PERFORMANCE', sub: 'Revenue contribution'),
      const SizedBox(height: 18),
      ...docs.map((d) => Padding(padding: const EdgeInsets.only(bottom: 16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Expanded(child: Text(d.name, style: p.body(13, weight: FontWeight.w600))), Text(moneyShort(appState.grossRevenue * d.share), style: p.body(12.5, color: p.textMuted))]),
        const SizedBox(height: 8),
        _bar(p, d.share, null),
        const SizedBox(height: 4),
        Text('${(d.share * 100).toStringAsFixed(0)}% of clinic revenue', style: p.body(11, color: p.textMuted)),
      ]))),
    ]));
  }

  Widget _trendPanel(AppPalette p) => Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const SectionTitle('REVENUE TREND', sub: 'Weekly growth (PKR, thousands)'),
    const SizedBox(height: 20),
    SizedBox(height: 220, child: CustomPaint(painter: LineChartPainter(data: appState.weeklyRevenue, labels: appState.weekDays, line: p.gold, fillTop: p.gold.withValues(alpha: 0.22), fillBottom: p.gold.withValues(alpha: 0.0), grid: p.border, text: p.textMuted, dotFill: p.surface), child: const SizedBox.expand())),
  ]));

  Widget _moduleRevPanel(AppPalette p) {
    final modules = [
      (label: 'Transplants',  revenue: appState.grossRevenue * 0.52, count: 8),
      (label: 'PRP Therapy',  revenue: appState.grossRevenue * 0.21, count: 34),
      (label: 'Memberships',  revenue: appState.grossRevenue * 0.09, count: 12),
      (label: 'Retail Sales', revenue: appState.grossRevenue * 0.07, count: 46),
      (label: 'Mesotherapy',  revenue: appState.grossRevenue * 0.06, count: 18),
      (label: 'Hair Patch',   revenue: appState.grossRevenue * 0.05, count: 6),
    ];
    final total = modules.fold(0.0, (s, m) => s + m.revenue);
    return Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SectionTitle('REVENUE BY MODULE', sub: 'Contribution by service category'),
      const SizedBox(height: 14),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Row(children: [
        Expanded(flex: 3, child: _th(p, 'SERVICE')),
        Expanded(flex: 2, child: _th(p, 'REVENUE')),
        Expanded(flex: 1, child: _th(p, 'COUNT')),
        Expanded(flex: 2, child: _th(p, 'SHARE')),
        Expanded(flex: 3, child: _th(p, '')),
      ])),
      const SizedBox(height: 6),
      Divider(height: 1, color: p.border),
      ...modules.map((m) {
        final pct = total == 0 ? 0.0 : m.revenue / total;
        return Padding(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12), child: Row(children: [
          Expanded(flex: 3, child: Text(m.label, style: p.body(13, weight: FontWeight.w600))),
          Expanded(flex: 2, child: Text(moneyShort(m.revenue), style: p.body(13))),
          Expanded(flex: 1, child: Text('${m.count}', style: p.body(13, color: p.textMuted))),
          Expanded(flex: 2, child: Text('${(pct * 100).toStringAsFixed(1)}%', style: p.body(13, color: p.gold, weight: FontWeight.w600))),
          Expanded(flex: 3, child: _bar(p, pct, null)),
        ]));
      }),
    ]));
  }

  Widget _bar(AppPalette p, double frac, Color? color) => ClipRRect(borderRadius: BorderRadius.circular(6), child: Stack(children: [Container(height: 8, color: p.surfaceAlt), FractionallySizedBox(widthFactor: frac.clamp(0.0, 1.0), child: Container(height: 8, decoration: color != null ? BoxDecoration(color: color) : BoxDecoration(gradient: p.goldGradient)))]));

  Widget _th(AppPalette p, String t) => Text(t, style: p.body(11, color: p.textMuted, weight: FontWeight.w700, spacing: 0.8));
}

// ─── Revenue Tab ──────────────────────────────────────────────────────────────
class _RevenueTab extends StatefulWidget {
  final String period;
  const _RevenueTab({required this.period});
  @override State<_RevenueTab> createState() => _RevenueTabState();
}

class _RevenueTabState extends State<_RevenueTab> {
  Widget _bar(AppPalette p, double frac, Color? color) => ClipRRect(borderRadius: BorderRadius.circular(6), child: Stack(children: [Container(height: 8, color: p.surfaceAlt), FractionallySizedBox(widthFactor: frac.clamp(0.0, 1.0), child: Container(height: 8, decoration: color != null ? BoxDecoration(color: color) : BoxDecoration(gradient: p.goldGradient)))]));

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final income  = appState.incomeEntries.fold(0.0, (s, i) => s + i.amount);
    final expense = appState.expenseEntries.fold(0.0, (s, e) => s + e.amount);
    final net     = income - expense;
    return ScrollArea(builder: (sc) => SingleChildScrollView(
      controller: sc,
      padding: const EdgeInsets.fromLTRB(0, 16, 12, 28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        MetricRow([
          MetricCard(title: 'Total Income', value: moneyShort(income), delta: '+18% MoM', icon: Icons.arrow_upward_rounded),
          MetricCard(title: 'Total Expenses', value: moneyShort(expense), delta: '-4% MoM', deltaUp: false, icon: Icons.arrow_downward_rounded),
          MetricCard(title: 'Net Profit', value: moneyShort(net), delta: income == 0 ? '—' : '${(net / income * 100).toStringAsFixed(1)}% margin', icon: Icons.account_balance_outlined),
          MetricCard(title: 'Outstanding AR', value: moneyShort(appState.pendingInstallments), delta: '${appState.invoices.where((i) => i.balance > 0).length} invoices', deltaUp: false, icon: Icons.receipt_long_outlined),
        ]),
        const SizedBox(height: 18),
        LayoutBuilder(builder: (ctx, c) {
          final wide = c.maxWidth > 800;
          if (wide) return IntrinsicHeight(child: Row(children: [Expanded(child: _incomePanel(p)), const SizedBox(width: 18), Expanded(child: _expensePanel(p))]));
          return Column(children: [_incomePanel(p), const SizedBox(height: 18), _expensePanel(p)]);
        }),
        const SizedBox(height: 18),
        _invoicePanel(p),
        const SizedBox(height: 18),
        _cashbookPanel(p),
      ]),
    ));
  }

  Widget _incomePanel(AppPalette p) {
    final byCategory = <String, double>{};
    for (final inc in appState.incomeEntries) byCategory.update(inc.category.label, (v) => v + inc.amount, ifAbsent: () => inc.amount);
    final total = byCategory.values.fold(0.0, (s, v) => s + v);
    return Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SectionTitle('INCOME BREAKDOWN', sub: 'By category'),
      const SizedBox(height: 14),
      ...byCategory.entries.map((e) {
        final pct = total == 0 ? 0.0 : e.value / total;
        return Padding(padding: const EdgeInsets.only(bottom: 14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Expanded(child: Text(e.key, style: p.body(13))), Text(moneyShort(e.value), style: p.body(13, weight: FontWeight.w600))]),
          const SizedBox(height: 6),
          _bar(p, pct, null),
          const SizedBox(height: 3),
          Text('${(pct * 100).toStringAsFixed(1)}% of total income', style: p.body(11, color: p.textMuted)),
        ]));
      }),
      Divider(height: 18, color: p.border),
      Row(children: [Expanded(child: Text('TOTAL INCOME', style: p.body(12, weight: FontWeight.w700, color: p.gold))), Text(moneyShort(total), style: p.body(14, weight: FontWeight.w700))]),
    ]));
  }

  Widget _expensePanel(AppPalette p) {
    final byCategory = <String, double>{};
    for (final ex in appState.expenseEntries) byCategory.update(ex.category.label, (v) => v + ex.amount, ifAbsent: () => ex.amount);
    final total = byCategory.values.fold(0.0, (s, v) => s + v);
    return Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SectionTitle('EXPENSE BREAKDOWN', sub: 'By category'),
      const SizedBox(height: 14),
      ...byCategory.entries.map((e) {
        final pct = total == 0 ? 0.0 : e.value / total;
        return Padding(padding: const EdgeInsets.only(bottom: 14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Expanded(child: Text(e.key, style: p.body(13))), Text(moneyShort(e.value), style: p.body(13, weight: FontWeight.w600, color: Colors.red.shade300))]),
          const SizedBox(height: 6),
          _bar(p, pct, Colors.red.shade400),
        ]));
      }),
      Divider(height: 18, color: p.border),
      Row(children: [Expanded(child: Text('TOTAL EXPENSES', style: p.body(12, weight: FontWeight.w700, color: Colors.red.shade300))), Text(moneyShort(total), style: p.body(14, weight: FontWeight.w700, color: Colors.red.shade300))]),
    ]));
  }

  Widget _invoicePanel(AppPalette p) {
    final invoices = appState.invoices.take(10).toList();
    return Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SectionTitle('RECENT INVOICES', sub: 'Latest billing records'),
      const SizedBox(height: 14),
      FullWidthDataTable(child: DataTable(
        headingRowHeight: 36, dataRowMinHeight: 42, dataRowMaxHeight: 42,
        headingTextStyle: p.body(11, color: p.textMuted, weight: FontWeight.w700),
        dataTextStyle: p.body(12.5),
        columns: const [
          DataColumn(label: Text('INVOICE #')),
          DataColumn(label: Text('PATIENT')),
          DataColumn(label: Text('DATE')),
          DataColumn(label: Text('TOTAL'), numeric: true),
          DataColumn(label: Text('PAID'), numeric: true),
          DataColumn(label: Text('BALANCE'), numeric: true),
          DataColumn(label: Text('STATUS')),
        ],
        rows: invoices.map((inv) => DataRow(cells: [
          DataCell(Text(inv.id, style: p.body(12, color: p.gold))),
          DataCell(Text(inv.patientName)),
          DataCell(Text(prettyShort(inv.date))),
          DataCell(Text(money(inv.subtotal))),
          DataCell(Text(money(inv.totalPaid))),
          DataCell(Text(money(inv.balance), style: p.body(12.5, color: inv.balance > 0 ? Colors.orange.shade400 : p.textMuted))),
          DataCell(StatusChip(label: inv.balance <= 0 ? 'Paid' : 'Pending', color: inv.balance <= 0 ? Colors.green : Colors.orange)),
        ])).toList(),
      )),
    ]));
  }

  Widget _cashbookPanel(AppPalette p) {
    final entries = [
      ...appState.incomeEntries.take(5).map((i) => (date: i.date, desc: i.description ?? i.category.label, credit: i.amount, debit: 0.0)),
      ...appState.expenseEntries.take(5).map((e) => (date: e.date, desc: e.description ?? e.category.label, credit: 0.0, debit: e.amount)),
    ];
    entries.sort((a, b) => b.date.compareTo(a.date));
    return Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SectionTitle('CASH BOOK SUMMARY', sub: 'Recent debit & credit entries'),
      const SizedBox(height: 14),
      FullWidthDataTable(child: DataTable(
        headingRowHeight: 36, dataRowMinHeight: 40, dataRowMaxHeight: 40,
        headingTextStyle: p.body(11, color: p.textMuted, weight: FontWeight.w700),
        dataTextStyle: p.body(12.5),
        columns: const [
          DataColumn(label: Text('DATE')),
          DataColumn(label: Text('DESCRIPTION')),
          DataColumn(label: Text('CREDIT'), numeric: true),
          DataColumn(label: Text('DEBIT'), numeric: true),
        ],
        rows: entries.map((e) => DataRow(cells: [
          DataCell(Text(prettyShort(e.date))),
          DataCell(Text(e.desc)),
          DataCell(Text(e.credit > 0 ? money(e.credit) : '—', style: p.body(12.5, color: e.credit > 0 ? Colors.green.shade400 : p.textMuted))),
          DataCell(Text(e.debit > 0 ? money(e.debit) : '—', style: p.body(12.5, color: e.debit > 0 ? Colors.red.shade300 : p.textMuted))),
        ])).toList(),
      )),
    ]));
  }
}

// ─── Patient Tab ──────────────────────────────────────────────────────────────
class _PatientTab extends StatelessWidget {
  final String period;
  const _PatientTab({required this.period});

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final pts    = appState.patients;
    final male   = pts.where((pt) => pt.gender == 'Male').length;
    final female = pts.where((pt) => pt.gender == 'Female').length;
    final newPt  = pts.where((pt) => pt.status.name == 'new').length;
    final activePt = pts.where((pt) => pt.status.name == 'active').length;
    final totalConsult = appState.consultationRecords.length;
    final converted = appState.consultationRecords.where((c) => c.isConverted).length;

    final byCity = <String, int>{};
    for (final pt in pts) byCity.update(pt.city, (v) => v + 1, ifAbsent: () => 1);

    return ScrollArea(builder: (sc) => SingleChildScrollView(
      controller: sc,
      padding: const EdgeInsets.fromLTRB(0, 16, 12, 28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        MetricRow([
          MetricCard(title: 'Total Patients', value: '${pts.length}', delta: '+$newPt this period', icon: Icons.groups_outlined),
          MetricCard(title: 'Active Patients', value: '$activePt', delta: '${pts.isEmpty ? 0 : (activePt / pts.length * 100).toStringAsFixed(0)}% active rate', icon: Icons.person_outlined),
          MetricCard(title: 'Male / Female', value: '$male / $female', delta: '${pts.isEmpty ? 0 : (male / pts.length * 100).toStringAsFixed(0)}% male', icon: Icons.wc_outlined),
          MetricCard(title: 'Conversion Rate', value: '${totalConsult == 0 ? 0 : (converted / totalConsult * 100).toStringAsFixed(0)}%', delta: '$converted of $totalConsult consultations', icon: Icons.trending_up_rounded),
        ]),
        const SizedBox(height: 18),
        LayoutBuilder(builder: (ctx, c) {
          final wide = c.maxWidth > 800;
          final norwood = _norwoodPanel(p, pts);
          final cityPanel = _categoryPanel(p, 'PATIENTS BY CITY', byCity);
          if (wide) return IntrinsicHeight(child: Row(children: [Expanded(child: cityPanel), const SizedBox(width: 18), Expanded(child: norwood)]));
          return Column(children: [cityPanel, const SizedBox(height: 18), norwood]);
        }),
        const SizedBox(height: 18),
        _patientListPanel(p, pts),
      ]),
    ));
  }

  Widget _norwoodPanel(AppPalette p, List<Patient> pts) {
    final byNorwood = <int, int>{};
    for (final pt in pts) byNorwood.update(pt.norwood, (v) => v + 1, ifAbsent: () => 1);
    final max = byNorwood.values.isEmpty ? 1 : byNorwood.values.reduce((a, b) => a > b ? a : b);
    return Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SectionTitle('HAIR LOSS DISTRIBUTION', sub: 'By Norwood scale'),
      const SizedBox(height: 14),
      ...List.generate(7, (i) {
        final n = i + 1;
        final count = byNorwood[n] ?? 0;
        return Padding(padding: const EdgeInsets.only(bottom: 12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Expanded(child: Text('Norwood ${roman(n)}', style: p.body(13))), Text('$count patients', style: p.body(12, color: p.textMuted))]),
          const SizedBox(height: 6),
          ClipRRect(borderRadius: BorderRadius.circular(6), child: Stack(children: [Container(height: 8, color: p.surfaceAlt), FractionallySizedBox(widthFactor: (count / max).clamp(0.0, 1.0), child: Container(height: 8, decoration: BoxDecoration(gradient: p.goldGradient)))])),
        ]));
      }),
    ]));
  }

  Widget _categoryPanel(AppPalette p, String title, Map<String, int> data) {
    final sorted = data.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final max = sorted.isEmpty ? 1 : sorted.first.value;
    return Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SectionTitle(title, sub: '${sorted.length} categories'),
      const SizedBox(height: 14),
      ...sorted.map((e) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Expanded(child: Text(e.key, style: p.body(13))), Text('${e.value} patients', style: p.body(12, color: p.textMuted))]),
        const SizedBox(height: 6),
        ClipRRect(borderRadius: BorderRadius.circular(6), child: Stack(children: [Container(height: 8, color: p.surfaceAlt), FractionallySizedBox(widthFactor: (e.value / max).clamp(0.0, 1.0), child: Container(height: 8, decoration: BoxDecoration(gradient: p.goldGradient)))])),
      ]))),
    ]));
  }

  Widget _patientListPanel(AppPalette p, List<Patient> pts) => Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const SectionTitle('PATIENT REGISTER', sub: 'All registered patients'),
    const SizedBox(height: 14),
    FullWidthDataTable(child: DataTable(
      headingRowHeight: 36, dataRowMinHeight: 40, dataRowMaxHeight: 40,
      headingTextStyle: p.body(11, color: p.textMuted, weight: FontWeight.w700),
      dataTextStyle: p.body(12.5),
      columns: const [
        DataColumn(label: Text('PATIENT')),
        DataColumn(label: Text('GENDER')),
        DataColumn(label: Text('AGE'), numeric: true),
        DataColumn(label: Text('CITY')),
        DataColumn(label: Text('STATUS')),
        DataColumn(label: Text('NORWOOD'), numeric: true),
      ],
      rows: pts.map((pt) => DataRow(cells: [
        DataCell(Text(pt.name, style: p.body(13, weight: FontWeight.w600))),
        DataCell(Text(pt.gender)),
        DataCell(Text('${pt.age}')),
        DataCell(Text(pt.city)),
        DataCell(StatusChip(label: pt.status.label, color: p.statusColor(pt.status))),
        DataCell(Text('NW ${pt.norwood}')),
      ])).toList(),
    )),
  ]));
}

// ─── Appointment Tab ───────────────────────────────────────────────────────────
class _AppointmentTab extends StatelessWidget {
  final String period;
  const _AppointmentTab({required this.period});

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final apts = appState.appointments;
    final confirmed   = apts.where((a) => a.status == ApptStatus.confirmed).length;
    final cancelled   = apts.where((a) => a.status == ApptStatus.cancelled).length;
    final pending     = apts.where((a) => a.status == ApptStatus.pending).length;
    final upcoming    = apts.where((a) => a.when.isAfter(DateTime.now())).length;

    final byDoctor = <String, int>{};
    for (final a in apts) byDoctor.update(a.surgeon, (v) => v + 1, ifAbsent: () => 1);

    final byStatus = <String, int>{'Confirmed': confirmed, 'Pending': pending, 'Cancelled': cancelled};

    return ScrollArea(builder: (sc) => SingleChildScrollView(
      controller: sc,
      padding: const EdgeInsets.fromLTRB(0, 16, 12, 28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        MetricRow([
          MetricCard(title: 'Total Appointments', value: '${apts.length}', delta: '$upcoming upcoming', icon: Icons.calendar_month_outlined),
          MetricCard(title: 'Confirmed', value: '$confirmed', delta: '${apts.isEmpty ? 0 : (confirmed / apts.length * 100).toStringAsFixed(0)}% confirmed', icon: Icons.check_circle_outline_rounded),
          MetricCard(title: 'Pending', value: '$pending', delta: 'Awaiting confirmation', icon: Icons.hourglass_empty_outlined),
          MetricCard(title: 'Cancellations', value: '$cancelled', delta: '${apts.isEmpty ? 0 : (cancelled / apts.length * 100).toStringAsFixed(0)}% cancel rate', deltaUp: false, icon: Icons.cancel_outlined),
        ]),
        const SizedBox(height: 18),
        LayoutBuilder(builder: (ctx, c) {
          final wide = c.maxWidth > 800;
          final docPanel    = _mapPanel(p, 'BY DOCTOR', byDoctor);
          final statusPanel = _mapPanel(p, 'BY STATUS', byStatus);
          if (wide) return IntrinsicHeight(child: Row(children: [Expanded(child: docPanel), const SizedBox(width: 18), Expanded(child: statusPanel)]));
          return Column(children: [docPanel, const SizedBox(height: 18), statusPanel]);
        }),
        const SizedBox(height: 18),
        _apptTable(p, apts),
      ]),
    ));
  }

  Widget _mapPanel(AppPalette p, String title, Map<String, int> data) {
    final sorted = data.entries.where((e) => e.value > 0).toList()..sort((a, b) => b.value.compareTo(a.value));
    final max = sorted.isEmpty ? 1 : sorted.first.value;
    return Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SectionTitle(title, sub: '${sorted.length} items'),
      const SizedBox(height: 14),
      ...sorted.map((e) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Expanded(child: Text(e.key, style: p.body(13))), Text('${e.value}', style: p.body(12, color: p.textMuted))]),
        const SizedBox(height: 6),
        ClipRRect(borderRadius: BorderRadius.circular(6), child: Stack(children: [Container(height: 8, color: p.surfaceAlt), FractionallySizedBox(widthFactor: (e.value / max).clamp(0.0, 1.0), child: Container(height: 8, decoration: BoxDecoration(gradient: p.goldGradient)))])),
      ]))),
    ]));
  }

  Widget _apptTable(AppPalette p, List<Appointment> apts) => Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const SectionTitle('APPOINTMENT LOG', sub: 'All appointment records'),
    const SizedBox(height: 14),
    FullWidthDataTable(child: DataTable(
      headingRowHeight: 36, dataRowMinHeight: 40, dataRowMaxHeight: 40,
      headingTextStyle: p.body(11, color: p.textMuted, weight: FontWeight.w700),
      dataTextStyle: p.body(12.5),
      columns: const [
        DataColumn(label: Text('PATIENT')),
        DataColumn(label: Text('SURGEON')),
        DataColumn(label: Text('DATE & TIME')),
        DataColumn(label: Text('TREATMENT')),
        DataColumn(label: Text('STATUS')),
      ],
      rows: apts.take(20).map((a) => DataRow(cells: [
        DataCell(Text(a.patientName, style: p.body(13, weight: FontWeight.w600))),
        DataCell(Text(a.surgeon)),
        DataCell(Text('${prettyShort(a.when)}  ${a.when.hour.toString().padLeft(2, '0')}:${a.when.minute.toString().padLeft(2, '0')}')),
        DataCell(Text(a.treatment)),
        DataCell(StatusChip(label: a.status.label, color: a.status == ApptStatus.confirmed ? Colors.green : a.status == ApptStatus.cancelled ? Colors.red : Colors.orange)),
      ])).toList(),
    )),
  ]));
}

// ─── Treatment Tab ─────────────────────────────────────────────────────────────
class _TreatmentTab extends StatelessWidget {
  final String period;
  const _TreatmentTab({required this.period});

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final plans = appState.treatmentPlans;
    final sessions  = plans.expand((pl) => pl.sessions).toList();
    final completed = sessions.where((s) => s.status.name == 'completed').length;
    final revenue   = sessions.where((s) => s.status.name == 'completed').fold(0.0, (s, ses) => s + ses.cost);

    return ScrollArea(builder: (sc) => SingleChildScrollView(
      controller: sc,
      padding: const EdgeInsets.fromLTRB(0, 16, 12, 28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        MetricRow([
          MetricCard(title: 'Active Plans', value: '${plans.length}', delta: '${plans.where((pl) => pl.completedSessions < pl.totalSessions).length} ongoing', icon: Icons.spa_outlined),
          MetricCard(title: 'Sessions Done', value: '$completed / ${sessions.length}', delta: sessions.isEmpty ? '—' : '${(completed / sessions.length * 100).toStringAsFixed(0)}% completion', icon: Icons.check_circle_outline_rounded),
          MetricCard(title: 'Session Revenue', value: moneyShort(revenue), delta: 'From completed sessions', icon: Icons.payments_outlined),
          MetricCard(title: 'Transplant Cases', value: '${appState.transplantCases.length}', delta: '${appState.transplantCases.where((c) => c.status.name == 'completed').length} completed', icon: Icons.content_cut_outlined),
        ]),
        const SizedBox(height: 18),
        _plansPanel(p, plans),
        const SizedBox(height: 18),
        _transplantPanel(p),
      ]),
    ));
  }

  Widget _plansPanel(AppPalette p, List<TreatmentPlan> plans) => Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const SectionTitle('TREATMENT PLANS', sub: 'Session progress per patient'),
    const SizedBox(height: 14),
    FullWidthDataTable(child: DataTable(
      headingRowHeight: 36, dataRowMinHeight: 56, dataRowMaxHeight: 56,
      headingTextStyle: p.body(11, color: p.textMuted, weight: FontWeight.w700),
      dataTextStyle: p.body(12.5),
      columns: const [
        DataColumn(label: Text('PATIENT')),
        DataColumn(label: Text('TREATMENT')),
        DataColumn(label: Text('DOCTOR')),
        DataColumn(label: Text('PROGRESS')),
        DataColumn(label: Text('SESSIONS'), numeric: true),
      ],
      rows: plans.map((pl) {
        final pct = pl.totalSessions == 0 ? 0.0 : pl.completedSessions / pl.totalSessions;
        return DataRow(cells: [
          DataCell(Text(pl.patientName, style: p.body(13, weight: FontWeight.w600))),
          DataCell(ConstrainedBox(constraints: const BoxConstraints(maxWidth: 200), child: Text(pl.treatmentName))),
          DataCell(Text(pl.doctorName)),
          DataCell(SizedBox(width: 130, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            ClipRRect(borderRadius: BorderRadius.circular(6), child: Stack(children: [Container(height: 8, color: p.surfaceAlt), FractionallySizedBox(widthFactor: pct.clamp(0.0, 1.0), child: Container(height: 8, decoration: BoxDecoration(gradient: p.goldGradient)))])),
            const SizedBox(height: 4),
            Text('${(pct * 100).toStringAsFixed(0)}% complete', style: p.body(10, color: p.textMuted)),
          ]))),
          DataCell(Text('${pl.completedSessions} / ${pl.totalSessions}')),
        ]);
      }).toList(),
    )),
  ]));

  Widget _transplantPanel(AppPalette p) => Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const SectionTitle('TRANSPLANT CASES', sub: 'Surgical procedure records'),
    const SizedBox(height: 14),
    FullWidthDataTable(child: DataTable(
      headingRowHeight: 36, dataRowMinHeight: 40, dataRowMaxHeight: 40,
      headingTextStyle: p.body(11, color: p.textMuted, weight: FontWeight.w700),
      dataTextStyle: p.body(12.5),
      columns: const [
        DataColumn(label: Text('PATIENT')),
        DataColumn(label: Text('SURGEON')),
        DataColumn(label: Text('DATE')),
        DataColumn(label: Text('TECHNIQUE')),
        DataColumn(label: Text('GRAFTS'), numeric: true),
        DataColumn(label: Text('COST'), numeric: true),
        DataColumn(label: Text('STATUS')),
      ],
      rows: appState.transplantCases.map((tc) => DataRow(cells: [
        DataCell(Text(tc.patientName, style: p.body(13, weight: FontWeight.w600))),
        DataCell(Text(tc.surgeonName)),
        DataCell(Text(prettyShort(tc.surgeryDate))),
        DataCell(Text(tc.technique.label)),
        DataCell(Text('${tc.graftsImplanted}')),
        DataCell(Text(moneyShort(tc.procedureCost))),
        DataCell(StatusChip(label: tc.status.label, color: Colors.green)),
      ])).toList(),
    )),
  ]));
}

// ─── Inventory Tab ─────────────────────────────────────────────────────────────
class _InventoryTab extends StatelessWidget {
  final String period;
  const _InventoryTab({required this.period});

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final items     = appState.stockItems;
    final lowStock  = items.where((i) => i.isLow).length;
    final outOfStock = items.where((i) => i.isOut).length;
    final totalValue = items.fold(0.0, (s, i) => s + i.stockValue);
    final movements = appState.stockMovements;

    return ScrollArea(builder: (sc) => SingleChildScrollView(
      controller: sc,
      padding: const EdgeInsets.fromLTRB(0, 16, 12, 28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        MetricRow([
          MetricCard(title: 'Total SKUs', value: '${items.length}', delta: '${items.where((i) => i.isActive).length} active', icon: Icons.inventory_2_outlined),
          MetricCard(title: 'Stock Value', value: moneyShort(totalValue), delta: 'Cost basis valuation', icon: Icons.account_balance_wallet_outlined),
          MetricCard(title: 'Low Stock', value: '$lowStock items', delta: 'Below reorder level', deltaUp: false, icon: Icons.warning_amber_outlined),
          MetricCard(title: 'Out of Stock', value: '$outOfStock items', delta: 'Immediate reorder needed', deltaUp: false, icon: Icons.remove_shopping_cart_outlined),
        ]),
        const SizedBox(height: 18),
        _stockTable(p, items),
        const SizedBox(height: 18),
        _movementsPanel(p, movements),
      ]),
    ));
  }

  Widget _stockTable(AppPalette p, List<StockItem> items) => Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const SectionTitle('STOCK REGISTER', sub: 'Current inventory levels'),
    const SizedBox(height: 14),
    FullWidthDataTable(child: DataTable(
      headingRowHeight: 36, dataRowMinHeight: 40, dataRowMaxHeight: 40,
      headingTextStyle: p.body(11, color: p.textMuted, weight: FontWeight.w700),
      dataTextStyle: p.body(12.5),
      columns: const [
        DataColumn(label: Text('ITEM')),
        DataColumn(label: Text('CATEGORY')),
        DataColumn(label: Text('QTY'), numeric: true),
        DataColumn(label: Text('REORDER'), numeric: true),
        DataColumn(label: Text('VALUE'), numeric: true),
        DataColumn(label: Text('STATUS')),
      ],
      rows: items.map((item) => DataRow(
        color: WidgetStateProperty.resolveWith((s) => item.isOut ? Colors.red.withValues(alpha: 0.06) : item.isLow ? Colors.orange.withValues(alpha: 0.06) : null),
        cells: [
          DataCell(Text(item.name, style: p.body(13, weight: FontWeight.w600))),
          DataCell(Text(item.category.label)),
          DataCell(Text('${item.currentQty}', style: p.body(12.5, color: item.isOut ? Colors.red.shade400 : item.isLow ? Colors.orange.shade400 : null))),
          DataCell(Text('${item.reorderLevel}')),
          DataCell(Text(moneyShort(item.stockValue))),
          DataCell(StatusChip(label: item.isOut ? 'Out' : item.isLow ? 'Low' : 'OK', color: item.isOut ? Colors.red : item.isLow ? Colors.orange : Colors.green)),
        ],
      )).toList(),
    )),
  ]));

  Widget _movementsPanel(AppPalette p, List<StockMovement> movements) => Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const SectionTitle('STOCK MOVEMENTS', sub: 'Recent transactions'),
    const SizedBox(height: 14),
    FullWidthDataTable(child: DataTable(
      headingRowHeight: 36, dataRowMinHeight: 40, dataRowMaxHeight: 40,
      headingTextStyle: p.body(11, color: p.textMuted, weight: FontWeight.w700),
      dataTextStyle: p.body(12.5),
      columns: const [
        DataColumn(label: Text('DATE')),
        DataColumn(label: Text('ITEM')),
        DataColumn(label: Text('TYPE')),
        DataColumn(label: Text('QTY'), numeric: true),
        DataColumn(label: Text('BY')),
        DataColumn(label: Text('REFERENCE')),
      ],
      rows: movements.take(15).map((m) => DataRow(cells: [
        DataCell(Text(prettyShort(m.date))),
        DataCell(Text(m.itemName, style: p.body(13, weight: FontWeight.w600))),
        DataCell(StatusChip(label: m.type.label, color: m.type.isIn ? Colors.green : Colors.red.shade400)),
        DataCell(Text('${m.type.isIn ? '+' : '-'}${m.qty}', style: p.body(13, color: m.type.isIn ? Colors.green.shade400 : Colors.red.shade400))),
        DataCell(Text(m.performedBy)),
        DataCell(Text(m.reference.isEmpty ? '—' : m.reference, style: p.body(12.5, color: p.textMuted))),
      ])).toList(),
    )),
  ]));
}

// ─── Marketing Tab ─────────────────────────────────────────────────────────────
class _MarketingTab extends StatelessWidget {
  final String period;
  const _MarketingTab({required this.period});

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final leads     = appState.leads;
    final campaigns = appState.campaigns;
    final coupons   = appState.coupons;
    final converted = leads.where((l) => l.stage == LeadStage.converted).length;
    final convRate  = leads.isEmpty ? 0.0 : converted / leads.length;

    return ScrollArea(builder: (sc) => SingleChildScrollView(
      controller: sc,
      padding: const EdgeInsets.fromLTRB(0, 16, 12, 28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        MetricRow([
          MetricCard(title: 'Total Leads', value: '${leads.length}', delta: '${leads.where((l) => l.stage == LeadStage.newLead).length} new this period', icon: Icons.person_add_outlined),
          MetricCard(title: 'Conversion Rate', value: '${(convRate * 100).toStringAsFixed(0)}%', delta: '$converted leads converted', icon: Icons.trending_up_rounded),
          MetricCard(title: 'Active Campaigns', value: '${campaigns.where((c) => c.status == CampaignStatus.active).length}', delta: '${campaigns.length} total campaigns', icon: Icons.campaign_outlined),
          MetricCard(title: 'Coupons Issued', value: '${coupons.length}', delta: '${coupons.where((c) => c.usageCount > 0).length} redeemed', icon: Icons.discount_outlined),
        ]),
        const SizedBox(height: 18),
        LayoutBuilder(builder: (ctx, c) {
          final wide = c.maxWidth > 800;
          final sourcePanel = _leadSourcePanel(p, leads);
          final campPanel   = _campaignPanel(p, campaigns);
          if (wide) return IntrinsicHeight(child: Row(children: [Expanded(child: sourcePanel), const SizedBox(width: 18), Expanded(child: campPanel)]));
          return Column(children: [sourcePanel, const SizedBox(height: 18), campPanel]);
        }),
        const SizedBox(height: 18),
        _leadsTable(p, leads),
      ]),
    ));
  }

  Widget _leadSourcePanel(AppPalette p, List<Lead> leads) {
    final bySource = <String, int>{};
    for (final l in leads) bySource.update(l.source.label, (v) => v + 1, ifAbsent: () => 1);
    final sorted = bySource.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final max = sorted.isEmpty ? 1 : sorted.first.value;
    return Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SectionTitle('LEADS BY SOURCE', sub: 'Channel attribution'),
      const SizedBox(height: 14),
      ...sorted.map((e) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Expanded(child: Text(e.key, style: p.body(13))), Text('${e.value} leads', style: p.body(12, color: p.textMuted))]),
        const SizedBox(height: 6),
        ClipRRect(borderRadius: BorderRadius.circular(6), child: Stack(children: [Container(height: 8, color: p.surfaceAlt), FractionallySizedBox(widthFactor: (e.value / max).clamp(0.0, 1.0), child: Container(height: 8, decoration: BoxDecoration(gradient: p.goldGradient)))])),
      ]))),
    ]));
  }

  Widget _campaignPanel(AppPalette p, List<Campaign> campaigns) => Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const SectionTitle('CAMPAIGNS', sub: 'Performance overview'),
    const SizedBox(height: 14),
    ...campaigns.take(6).map((c) => Padding(padding: const EdgeInsets.only(bottom: 14), child: Row(children: [
      Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: c.status == CampaignStatus.active ? Colors.green : p.textMuted)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(c.name, style: p.body(13, weight: FontWeight.w600)),
        Text(c.type.label, style: p.body(11.5, color: p.textMuted)),
      ])),
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text(moneyShort(c.budget), style: p.body(12.5, color: p.gold, weight: FontWeight.w600)),
        Text('${c.sentCount} sent', style: p.body(10, color: p.textMuted)),
      ]),
    ]))),
  ]));

  Widget _leadsTable(AppPalette p, List<Lead> leads) => Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const SectionTitle('LEAD LOG', sub: 'All leads with status'),
    const SizedBox(height: 14),
    FullWidthDataTable(child: DataTable(
      headingRowHeight: 36, dataRowMinHeight: 40, dataRowMaxHeight: 40,
      headingTextStyle: p.body(11, color: p.textMuted, weight: FontWeight.w700),
      dataTextStyle: p.body(12.5),
      columns: const [
        DataColumn(label: Text('NAME')),
        DataColumn(label: Text('PHONE')),
        DataColumn(label: Text('SOURCE')),
        DataColumn(label: Text('DATE')),
        DataColumn(label: Text('STATUS')),
        DataColumn(label: Text('ASSIGNED TO')),
      ],
      rows: leads.take(20).map((l) => DataRow(cells: [
        DataCell(Text(l.name, style: p.body(13, weight: FontWeight.w600))),
        DataCell(Text(l.phone)),
        DataCell(Text(l.source.label)),
        DataCell(Text(prettyShort(l.createdAt))),
        DataCell(StatusChip(label: l.stage.label, color: Colors.blue)),
        DataCell(Text(l.assignedTo ?? 'Unassigned', style: p.body(12.5, color: p.textMuted))),
      ])).toList(),
    )),
  ]));
}
