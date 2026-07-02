// modules/dashboard/views — KPI metrics, weekly trend line chart, treatment
// share pie, and quick-action cards wired to the navigation controller.
import 'package:flutter/material.dart';

import '../../../core/core.dart';

class DashboardScreen extends StatelessWidget {
  final VoidCallback onRegisterPatient, onBookAppointment, onCreateInvoice, onLowStock;
  const DashboardScreen({super.key, required this.onRegisterPatient, required this.onBookAppointment, required this.onCreateInvoice, required this.onLowStock});

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    return ScreenScaffold(
      title: 'DASHBOARD',
      subtitle: 'Welcome back, Dr. Rehman — here is the clinic at a glance.',
      actions: [
        GhostButton(label: 'Export Report', icon: Icons.file_download_outlined, onTap: () => appState.go(4)),
        const SizedBox(width: 12),
        GoldButton(label: 'New Patient', icon: Icons.add, onTap: onRegisterPatient),
      ],
      child: ScrollArea(builder: (sc) => SingleChildScrollView(
        controller: sc,
        padding: const EdgeInsets.only(right: 12),
        child: Column(children: [
          MetricRow([
            MetricCard(title: 'Total Registered Patients', value: '${appState.totalPatients}', delta: '+12%', icon: Icons.groups_outlined),
            MetricCard(title: "Today's Appointments", value: '${appState.todaysAppointments}', delta: '+3', icon: Icons.event_available_outlined),
            MetricCard(title: 'Monthly Revenue', value: moneyShort(appState.monthlyRevenue), delta: '+18%', icon: Icons.payments_outlined),
            MetricCard(title: 'Active Marketing Leads', value: '${appState.activeLeads}', delta: '+5', icon: Icons.campaign_outlined),
          ]),
          const SizedBox(height: 18),
          LayoutBuilder(builder: (context, c) {
            if (c.maxWidth > 900) {
              return const IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Expanded(flex: 6, child: _RevenueChartCard()), SizedBox(width: 18), Expanded(flex: 4, child: _DistributionCard())]));
            }
            return const Column(children: [_RevenueChartCard(), SizedBox(height: 18), _DistributionCard()]);
          }),
          const SizedBox(height: 18),
          Align(alignment: Alignment.centerLeft, child: Text('QUICK ACTIONS', style: p.display(24, spacing: 1.2))),
          const SizedBox(height: 14),
          MetricRow([
            _QuickAction(icon: Icons.person_add_alt_1, title: 'Register New Patient', subtitle: 'Add to CRM dossier', onTap: onRegisterPatient),
            _QuickAction(icon: Icons.calendar_month, title: 'Book Appointment', subtitle: 'Schedule a session', onTap: onBookAppointment),
            _QuickAction(icon: Icons.receipt_long, title: 'Create POS Invoice', subtitle: 'Bill a treatment', onTap: onCreateInvoice),
            _QuickAction(icon: Icons.inventory_2, title: 'Check Low Stock', subtitle: '${appState.lowStockCount} items need reorder', onTap: onLowStock),
          ]),
          const SizedBox(height: 28),
        ]),
      )),
    );
  }
}

class _RevenueChartCard extends StatelessWidget {
  const _RevenueChartCard();
  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    return Panel(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Expanded(child: SectionTitle('WEEKLY FINANCIAL GROWTH', sub: 'Revenue trend (PKR, thousands)')),
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: p.success.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)), child: Row(children: [Icon(Icons.trending_up, size: 14, color: p.success), const SizedBox(width: 5), Text('+24.6% WoW', style: p.body(12, color: p.success, weight: FontWeight.w600))])),
        ]),
        const SizedBox(height: 22),
        SizedBox(height: 230, child: CustomPaint(painter: LineChartPainter(data: appState.weeklyRevenue, labels: appState.weekDays, line: p.gold, fillTop: p.gold.withValues(alpha: 0.25), fillBottom: p.gold.withValues(alpha: 0.0), grid: p.border, text: p.textMuted, dotFill: p.surface), child: const SizedBox.expand())),
      ]),
    );
  }
}

class _DistributionCard extends StatelessWidget {
  const _DistributionCard();
  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final data = appState.distribution(p);
    return Panel(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SectionTitle('TREATMENT DISTRIBUTION', sub: 'Share of procedures this month'),
        const SizedBox(height: 18),
        Center(
          child: SizedBox(
            width: 168, height: 168,
            child: CustomPaint(painter: PieChartPainter(segments: data.map((d) => (d.value, d.color)).toList(), trackColor: p.surfaceAlt), child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Text('${data.fold<double>(0, (s, d) => s + d.value).toStringAsFixed(0)}%', style: p.display(34)), Text('Total Mix', style: p.body(11, color: p.textMuted))]))),
          ),
        ),
        const SizedBox(height: 20),
        ...data.map((d) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(children: [Container(width: 11, height: 11, decoration: BoxDecoration(color: d.color, borderRadius: BorderRadius.circular(3))), const SizedBox(width: 10), Expanded(child: Text(d.label, style: p.body(13))), Text('${d.value.toStringAsFixed(0)}%', style: p.body(13, weight: FontWeight.w700))]))),
      ]),
    );
  }
}

class _QuickAction extends StatefulWidget {
  final IconData icon;
  final String title, subtitle;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.title, required this.subtitle, required this.onTap});
  @override
  State<_QuickAction> createState() => _QuickActionState();
}

class _QuickActionState extends State<_QuickAction> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          transform: Matrix4.translationValues(0, _hover ? -3 : 0, 0),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: _hover ? p.gold.withValues(alpha: 0.10) : p.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: _hover ? p.gold : p.border)),
          child: Row(children: [
            Container(width: 48, height: 48, decoration: BoxDecoration(gradient: _hover ? p.goldGradient : null, color: _hover ? null : p.surfaceAlt, borderRadius: BorderRadius.circular(8)), child: Icon(widget.icon, size: 22, color: _hover ? Colors.black87 : p.gold)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(widget.title, style: p.body(14, weight: FontWeight.w700)), const SizedBox(height: 3), Text(widget.subtitle, style: p.body(12, color: p.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis)])),
            Icon(Icons.arrow_forward, size: 18, color: _hover ? p.gold : p.textMuted),
          ]),
        ),
      ),
    );
  }
}
