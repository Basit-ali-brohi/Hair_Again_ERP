import 'package:flutter/material.dart';

import '../../../core/core.dart';
import '../../appointments/models/appointment.dart';
import '../../auth/models/auth_models.dart';
import '../../crm/models/patient.dart';
import '../../pos_inventory/models/pos_models.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback onRegisterPatient, onBookAppointment, onCreateInvoice, onLowStock;
  const DashboardScreen({super.key, required this.onRegisterPatient, required this.onBookAppointment, required this.onCreateInvoice, required this.onLowStock});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isToday(DateTime dt) {
    final now = DateTime.now();
    return dt.year == now.year && dt.month == now.month && dt.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    // Listen to appState changes
    AppScope.of(context);
    final p = pal(context);

    // Data for new panels
    final List<Appointment> todayAppts = appState.appointments
        .where((a) => _isToday(a.when) && a.status != ApptStatus.cancelled)
        .toList()
      ..sort((a, b) => a.when.compareTo(b.when));

    final List<Patient> recentPatients = appState.patients.reversed.take(5).toList();

    final List<InventoryItem> lowStock = appState.inventory
        .where((i) => i.isLow)
        .take(5)
        .toList();

    final List<Invoice> pendingInvoices = appState.invoices
        .where((inv) => !inv.isPaid)
        .take(5)
        .toList();

    final double target = 3000000;
    final double actual = appState.monthlyRevenue;
    final double targetPct = (actual / target).clamp(0.0, 1.0);

    return ScreenScaffold(
      title: 'DASHBOARD',
      subtitle: 'Welcome back, ${appState.currentUser?.name ?? "User"} — here is the clinic at a glance.',
      actions: [
        GhostButton(label: 'Export Report', icon: Icons.file_download_outlined, onTap: () => appState.go(4)),
        const SizedBox(width: 12),
        GoldButton(label: 'New Patient', icon: Icons.add, onTap: widget.onRegisterPatient),
      ],
      child: ScrollArea(builder: (sc) => SingleChildScrollView(
        controller: sc,
        padding: const EdgeInsets.only(right: 12, bottom: 28),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // ── Role Summary Card ────────────────────────────────────────────
          const _RoleSummaryCard(),
          const SizedBox(height: 18),

          // ── Row 1: KPI Metric Cards ──────────────────────────────────────
          MetricRow([
            MetricCard(title: 'Total Registered Patients', value: '${appState.totalPatients}', delta: '+12%', icon: Icons.groups_outlined),
            MetricCard(title: "Today's Appointments", value: '${appState.todaysAppointments}', delta: '+3', icon: Icons.event_available_outlined),
            MetricCard(title: 'Monthly Revenue', value: moneyShort(appState.monthlyRevenue), delta: '+18%', icon: Icons.payments_outlined),
            MetricCard(title: 'Active Marketing Leads', value: '${appState.activeLeads}', delta: '+5', icon: Icons.campaign_outlined),
          ]),
          const SizedBox(height: 18),

          // ── Row 2: Quick Actions ─────────────────────────────────────────
          Text('QUICK ACTIONS', style: p.display(18, spacing: 1.2)),
          const SizedBox(height: 12),
          MetricRow([
            _QuickAction(icon: Icons.person_add_alt_1, title: 'Register New Patient', subtitle: 'Add to CRM dossier', onTap: widget.onRegisterPatient),
            _QuickAction(icon: Icons.calendar_month, title: 'Book Appointment', subtitle: 'Schedule a session', onTap: widget.onBookAppointment),
            _QuickAction(icon: Icons.receipt_long, title: 'Create POS Invoice', subtitle: 'Bill a treatment', onTap: widget.onCreateInvoice),
            _QuickAction(icon: Icons.inventory_2, title: 'Check Low Stock', subtitle: '${appState.lowStockCount} items need reorder', onTap: widget.onLowStock),
          ]),
          const SizedBox(height: 18),

          // ── Row 3: Charts ────────────────────────────────────────────────
          LayoutBuilder(builder: (context, c) {
            if (c.maxWidth > 900) {
              return const IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Expanded(flex: 6, child: _RevenueChartCard()),
                SizedBox(width: 18),
                Expanded(flex: 4, child: _DistributionCard()),
              ]));
            }
            return const Column(children: [_RevenueChartCard(), SizedBox(height: 18), _DistributionCard()]);
          }),
          const SizedBox(height: 18),

          // ── Row 4: Monthly Target ────────────────────────────────────────
          _MonthlyTargetPanel(actual: actual, target: target, pct: targetPct),
          const SizedBox(height: 18),

          // ── Row 5: Today's Appointments | Recent Patients | Alerts ───────
          LayoutBuilder(builder: (context, c) {
            if (c.maxWidth > 900) {
              return IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Expanded(flex: 5, child: _TodayApptsPanel(appts: todayAppts, onBook: widget.onBookAppointment)),
                const SizedBox(width: 18),
                Expanded(flex: 4, child: _RecentPatientsPanel(patients: recentPatients, onAdd: widget.onRegisterPatient)),
                const SizedBox(width: 18),
                Expanded(flex: 4, child: Column(children: [
                  Expanded(child: _LowStockPanel(items: lowStock, onView: widget.onLowStock)),
                  const SizedBox(height: 12),
                  Expanded(child: _PendingInvoicesPanel(invoices: pendingInvoices, onView: widget.onCreateInvoice)),
                ])),
              ]));
            }
            return Column(children: [
              _TodayApptsPanel(appts: todayAppts, onBook: widget.onBookAppointment),
              const SizedBox(height: 18),
              _RecentPatientsPanel(patients: recentPatients, onAdd: widget.onRegisterPatient),
              const SizedBox(height: 18),
              _LowStockPanel(items: lowStock, onView: widget.onLowStock),
              const SizedBox(height: 18),
              _PendingInvoicesPanel(invoices: pendingInvoices, onView: widget.onCreateInvoice),
            ]);
          }),
        ]),
      )),
    );
  }
}

// ── Revenue Chart ─────────────────────────────────────────────────────────────
class _RevenueChartCard extends StatelessWidget {
  const _RevenueChartCard();
  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    return Panel(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Expanded(child: SectionTitle('WEEKLY FINANCIAL GROWTH', sub: 'Revenue trend (PKR, thousands)')),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: p.success.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
            child: Row(children: [
              Icon(Icons.trending_up, size: 14, color: p.success),
              const SizedBox(width: 5),
              Text('+24.6% WoW', style: p.body(12, color: p.success, weight: FontWeight.w600)),
            ]),
          ),
        ]),
        const SizedBox(height: 22),
        SizedBox(
          height: 220,
          child: CustomPaint(
            painter: LineChartPainter(
              data: appState.weeklyRevenue,
              labels: appState.weekDays,
              line: p.gold,
              fillTop: p.gold.withValues(alpha: 0.22),
              fillBottom: p.gold.withValues(alpha: 0.0),
              grid: p.border,
              text: p.textMuted,
              dotFill: p.surface,
            ),
            child: const SizedBox.expand(),
          ),
        ),
      ]),
    );
  }
}

// ── Treatment Distribution ────────────────────────────────────────────────────
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
            width: 160, height: 160,
            child: CustomPaint(
              painter: PieChartPainter(segments: data.map((d) => (d.value, d.color)).toList(), trackColor: p.surfaceAlt),
              child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text('${data.fold<double>(0, (s, d) => s + d.value).toStringAsFixed(0)}%', style: p.display(30)),
                Text('Total Mix', style: p.body(11, color: p.textMuted)),
              ])),
            ),
          ),
        ),
        const SizedBox(height: 18),
        ...data.map((d) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(children: [
            Container(width: 10, height: 10, decoration: BoxDecoration(color: d.color, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 10),
            Expanded(child: Text(d.label, style: p.body(13))),
            Text('${d.value.toStringAsFixed(0)}%', style: p.body(13, weight: FontWeight.w700)),
          ]),
        )),
      ]),
    );
  }
}

// ── Monthly Revenue Target ────────────────────────────────────────────────────
class _MonthlyTargetPanel extends StatelessWidget {
  final double actual, target, pct;
  const _MonthlyTargetPanel({required this.actual, required this.target, required this.pct});
  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final isAhead = pct >= 0.8;
    return Panel(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(children: [
        Icon(Icons.flag_outlined, size: 20, color: p.gold),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text('MONTHLY REVENUE TARGET', style: p.body(11, color: p.textMuted, weight: FontWeight.w700, spacing: 1.0)),
            const Spacer(),
            Text('${money(actual)}  /  ${money(target)}', style: p.body(13, weight: FontWeight.w700)),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: (isAhead ? p.success : p.warning).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(4)),
              child: Text('${(pct * 100).toStringAsFixed(0)}% achieved', style: p.body(11.5, color: isAhead ? p.success : p.warning, weight: FontWeight.w600)),
            ),
          ]),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(value: pct, minHeight: 8, backgroundColor: p.border, color: isAhead ? p.success : p.warning),
          ),
        ])),
      ]),
    );
  }
}

// ── Today's Appointments ──────────────────────────────────────────────────────
class _TodayApptsPanel extends StatelessWidget {
  final List<Appointment> appts;
  final VoidCallback onBook;
  const _TodayApptsPanel({required this.appts, required this.onBook});
  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    return Panel(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: SectionTitle("TODAY'S APPOINTMENTS", sub: '${appts.length} scheduled for today')),
          GhostButton(label: 'Book New', icon: Icons.add, onTap: onBook),
        ]),
        const SizedBox(height: 14),
        if (appts.isEmpty)
          _EmptyState(icon: Icons.event_available_outlined, text: 'No appointments today')
        else
          ...appts.map((a) => _ApptRow(a: a, p: p)),
      ]),
    );
  }
}

class _ApptRow extends StatelessWidget {
  final Appointment a;
  final AppPalette p;
  const _ApptRow({required this.a, required this.p});
  @override
  Widget build(BuildContext context) {
    final color = switch (a.status) {
      ApptStatus.confirmed => p.success,
      ApptStatus.pending   => p.warning,
      ApptStatus.cancelled => p.danger,
      ApptStatus.checkedIn => p.info,
      ApptStatus.completed => p.gold,
    };
    final timeStr = '${a.when.hour.toString().padLeft(2, '0')}:${a.when.minute.toString().padLeft(2, '0')}';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(5), border: Border.all(color: p.border)),
      child: Row(children: [
        Container(
          width: 46, height: 46,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(5)),
          child: Center(child: Text(timeStr, style: p.body(12, color: color, weight: FontWeight.w800))),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(a.patientName, style: p.body(13.5, weight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text('${a.treatment}  ·  Dr. ${a.surgeon}', style: p.body(12, color: p.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
        ])),
        StatusChip(label: a.status.label, color: color),
      ]),
    );
  }
}

// ── Recent Patients ───────────────────────────────────────────────────────────
class _RecentPatientsPanel extends StatelessWidget {
  final List<Patient> patients;
  final VoidCallback onAdd;
  const _RecentPatientsPanel({required this.patients, required this.onAdd});
  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    return Panel(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Expanded(child: SectionTitle('RECENT PATIENTS', sub: 'Last registered')),
          GhostButton(label: 'Add', icon: Icons.add, onTap: onAdd),
        ]),
        const SizedBox(height: 14),
        if (patients.isEmpty)
          _EmptyState(icon: Icons.people_outline, text: 'No patients yet')
        else
          ...patients.map((pt) => _PatientRow(pt: pt, p: p)),
      ]),
    );
  }
}

class _PatientRow extends StatelessWidget {
  final Patient pt;
  final AppPalette p;
  const _PatientRow({required this.pt, required this.p});
  @override
  Widget build(BuildContext context) {
    final color = switch (pt.status) {
      PatientStatus.lead      => p.warning,
      PatientStatus.active    => p.success,
      PatientStatus.completed => p.info,
    };
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(5), border: Border.all(color: p.border)),
      child: Row(children: [
        CircleAvatar(radius: 17, backgroundColor: p.gold.withValues(alpha: 0.15), child: Text(pt.name.isNotEmpty ? pt.name[0].toUpperCase() : '?', style: p.body(13, color: p.gold, weight: FontWeight.w700))),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(pt.name, style: p.body(13, weight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(pt.phone, style: p.body(11.5, color: p.textMuted)),
        ])),
        StatusChip(label: pt.status.label, color: color),
      ]),
    );
  }
}

// ── Low Stock Alerts ──────────────────────────────────────────────────────────
class _LowStockPanel extends StatelessWidget {
  final List<InventoryItem> items;
  final VoidCallback onView;
  const _LowStockPanel({required this.items, required this.onView});
  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    return Panel(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.warning_amber_rounded, size: 16, color: p.warning),
          const SizedBox(width: 8),
          Expanded(child: Text('LOW STOCK ALERTS', style: p.body(11, color: p.textMuted, weight: FontWeight.w700, spacing: 1.0))),
          MouseRegion(cursor: SystemMouseCursors.click, child: GestureDetector(onTap: onView, child: Text('View All', style: p.body(12, color: p.gold, weight: FontWeight.w600)))),
        ]),
        const SizedBox(height: 12),
        if (items.isEmpty)
          _EmptyState(icon: Icons.check_circle_outline, text: 'All stock levels OK', color: p.success)
        else
          ...items.map((i) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(children: [
              Expanded(child: Text(i.name, style: p.body(12.5, weight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: p.danger.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(4)),
                child: Text('${i.stock} / ${i.reorderLevel}', style: p.body(11.5, color: p.danger, weight: FontWeight.w700)),
              ),
            ]),
          )),
      ]),
    );
  }
}

// ── Pending Invoices ──────────────────────────────────────────────────────────
class _PendingInvoicesPanel extends StatelessWidget {
  final List<Invoice> invoices;
  final VoidCallback onView;
  const _PendingInvoicesPanel({required this.invoices, required this.onView});
  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    return Panel(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.receipt_long_outlined, size: 16, color: p.info),
          const SizedBox(width: 8),
          Expanded(child: Text('PENDING INVOICES', style: p.body(11, color: p.textMuted, weight: FontWeight.w700, spacing: 1.0))),
          MouseRegion(cursor: SystemMouseCursors.click, child: GestureDetector(onTap: onView, child: Text('View All', style: p.body(12, color: p.gold, weight: FontWeight.w600)))),
        ]),
        const SizedBox(height: 12),
        if (invoices.isEmpty)
          _EmptyState(icon: Icons.check_circle_outline, text: 'No pending invoices', color: p.success)
        else
          ...invoices.map((inv) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(children: [
              Expanded(child: Text(inv.patientName, style: p.body(12.5, weight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis)),
              const SizedBox(width: 8),
              Text(money(inv.balance), style: p.body(12.5, color: p.danger, weight: FontWeight.w700)),
            ]),
          )),
      ]),
    );
  }
}

// ── Quick Action Card ─────────────────────────────────────────────────────────
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
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: _hover ? p.gold.withValues(alpha: 0.10) : p.surface,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: _hover ? p.gold : p.border),
          ),
          child: Row(children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(gradient: _hover ? p.goldGradient : null, color: _hover ? null : p.surfaceAlt, borderRadius: BorderRadius.circular(6)),
              child: Icon(widget.icon, size: 20, color: _hover ? Colors.black87 : p.gold),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.title, style: p.body(13.5, weight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(widget.subtitle, style: p.body(12, color: p.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
            ])),
            Icon(Icons.arrow_forward, size: 17, color: _hover ? p.gold : p.textMuted),
          ]),
        ),
      ),
    );
  }
}

// ── Role Summary Card ─────────────────────────────────────────────────────────
class _RoleSummaryCard extends StatelessWidget {
  const _RoleSummaryCard();

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final role = appState.currentUser?.role;
    final kpis = _kpisForRole(role, p);
    if (kpis == null) return const SizedBox.shrink();
    return Panel(
      padding: const EdgeInsets.all(18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(gradient: p.goldGradient, borderRadius: BorderRadius.circular(8)), child: Icon(Icons.dashboard_customize_outlined, size: 16, color: Colors.black87)),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('ROLE OVERVIEW — ${role?.label.toUpperCase() ?? 'ADMIN'}', style: p.body(11, color: p.textMuted, weight: FontWeight.w700, spacing: 1.0)),
            Text('Your personalised at-a-glance summary', style: p.body(11.5, color: p.textMuted)),
          ]),
        ]),
        const SizedBox(height: 16),
        Row(children: kpis.map((kpi) => Expanded(child: _RoleKpi(title: kpi.$1, value: kpi.$2, icon: kpi.$3, color: kpi.$4))).toList()),
      ]),
    );
  }

  List<(String, String, IconData, Color)>? _kpisForRole(UserRole? role, AppPalette p) {
    switch (role) {
      case UserRole.superAdmin:
      case UserRole.owner:
      case null:
        return [
          ('Monthly Revenue', moneyShort(appState.monthlyRevenue), Icons.payments_outlined, p.gold),
          ('Total Patients', '${appState.totalPatients}', Icons.groups_outlined, p.info),
          ('Active Staff', '${appState.staff.length}', Icons.badge_outlined, p.success),
          ('Active Branches', '1', Icons.business_outlined, p.warning),
        ];
      case UserRole.branchManager:
        return [
          ("Today's Appts", '${appState.todaysAppointments}', Icons.event_available_outlined, p.gold),
          ('Staff Present', '${appState.staff.length}', Icons.badge_outlined, p.success),
          ('Revenue Today', moneyShort(appState.monthlyRevenue / 30), Icons.payments_outlined, p.info),
          ('Pending Tasks', '3', Icons.task_outlined, p.warning),
        ];
      case UserRole.hr:
        return [
          ('Total Staff', '${appState.staff.length}', Icons.badge_outlined, p.gold),
          ('Pending Leaves', '4', Icons.beach_access_outlined, p.warning),
          ('Attendance Rate', '94%', Icons.check_circle_outline, p.success),
          ('Payroll Due', moneyShort(appState.staff.fold(0.0, (s, e) => s + e.salary)), Icons.account_balance_wallet_outlined, p.info),
        ];
      case UserRole.accountant:
        return [
          ('Pending Payments', '${appState.invoices.where((i) => !i.isPaid).length}', Icons.pending_actions_outlined, p.warning),
          ("Today's Revenue", moneyShort(appState.monthlyRevenue / 30), Icons.payments_outlined, p.gold),
          ('Outstanding', moneyShort(appState.invoices.where((i) => !i.isPaid).fold(0.0, (s, i) => s + i.balance)), Icons.receipt_long_outlined, p.danger),
          ('Cash Balance', moneyShort(appState.monthlyRevenue * 0.42), Icons.account_balance_outlined, p.success),
        ];
      case UserRole.inventoryManager:
        return [
          ('Low Stock Items', '${appState.lowStockCount}', Icons.inventory_2_outlined, p.danger),
          ('Stock Value', moneyShort(appState.inventory.fold(0.0, (s, i) => s + i.stock * i.price)), Icons.warehouse_outlined, p.gold),
          ('PO Pending', '2', Icons.local_shipping_outlined, p.warning),
          ('Returns Pending', '1', Icons.assignment_return_outlined, p.info),
        ];
      case UserRole.salesManager:
        return [
          ('New Leads', '${appState.activeLeads}', Icons.person_search_outlined, p.gold),
          ('Conversions', '${appState.patients.where((p) => p.status.name == 'active').length}', Icons.trending_up_outlined, p.success),
          ("Follow-ups Today", '5', Icons.follow_the_signs_outlined, p.warning),
          ('Revenue', moneyShort(appState.monthlyRevenue), Icons.payments_outlined, p.info),
        ];
      case UserRole.marketingManager:
        return [
          ('Campaign Reach', '${appState.campaigns.fold(0, (s, c) => s + c.sentCount)}', Icons.campaign_outlined, p.gold),
          ('Active Coupons', '${appState.coupons.where((c) => c.isValid).length}', Icons.discount_outlined, p.success),
          ('New Sign-ups', '${appState.patients.length}', Icons.person_add_outlined, p.info),
          ('WhatsApp Sent', '${appState.campaigns.where((c) => c.type.name == 'whatsapp').fold(0, (s, c) => s + c.sentCount)}', Icons.chat_outlined, p.warning),
        ];
      case UserRole.receptionist:
        return [
          ("Today's Appts", '${appState.todaysAppointments}', Icons.event_available_outlined, p.gold),
          ('Checked In', '${appState.appointments.where((a) => a.status.name == 'confirmed').length}', Icons.check_circle_outline, p.success),
          ('Pending', '${appState.appointments.where((a) => a.status.name == 'pending').length}', Icons.pending_outlined, p.warning),
          ('New Walk-ins', '2', Icons.directions_walk_outlined, p.info),
        ];
      default:
        return [
          ('Monthly Revenue', moneyShort(appState.monthlyRevenue), Icons.payments_outlined, p.gold),
          ('Total Patients', '${appState.totalPatients}', Icons.groups_outlined, p.info),
          ('Active Staff', '${appState.staff.length}', Icons.badge_outlined, p.success),
          ('Active Branches', '1', Icons.business_outlined, p.warning),
        ];
    }
  }
}

class _RoleKpi extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;
  const _RoleKpi({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.07), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withValues(alpha: 0.22))),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(8)), child: Icon(icon, size: 16, color: color)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: p.body(16, weight: FontWeight.w800, color: color)),
          Text(title, style: p.body(11, color: p.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
        ])),
      ]),
    );
  }
}

// ── Shared helper ─────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;
  const _EmptyState({required this.icon, required this.text, this.color});
  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 28, color: color ?? p.textMuted.withValues(alpha: 0.4)),
        const SizedBox(height: 8),

        Text(text, style: p.body(12.5, color: p.textMuted)),
      ])),
    );
  }
}
