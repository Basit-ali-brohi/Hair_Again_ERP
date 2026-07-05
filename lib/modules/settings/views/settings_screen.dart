import 'package:flutter/material.dart';
import '../../../core/core.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  late final TextEditingController _name, _addr, _phone, _email;
  final Map<String, Set<int>> _schedule = {
    'Dr. Rehman': {1, 2, 3, 4, 5},
    'Dr. Sara Iqbal': {1, 3, 5},
    'Dr. Bilal Khan': {2, 4, 6},
  };

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 10, vsync: this);
    _name  = TextEditingController(text: appState.clinicName);
    _addr  = TextEditingController(text: appState.clinicAddress);
    _phone = TextEditingController(text: appState.clinicPhone);
    _email = TextEditingController(text: appState.clinicEmail);
  }

  @override
  void dispose() {
    _tab.dispose();
    for (final c in [_name, _addr, _phone, _email]) c.dispose();
    super.dispose();
  }

  void _save() {
    appState.clinicName    = _name.text;
    appState.clinicAddress = _addr.text;
    appState.clinicPhone   = _phone.text;
    appState.clinicEmail   = _email.text;
    appState.saveClinicProfile();
    appState.touch();
    toast(context, 'Settings saved');
  }

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    return ScreenScaffold(
      title: 'SYSTEM SETTINGS',
      subtitle: 'Configure clinic profile, branch, payment, POS and all system settings.',
      actions: [
        GoldButton(label: 'Save Changes', icon: Icons.save_outlined, onTap: _save),
        const SizedBox(width: 12),
        SizedBox(
          width: 500, height: 42,
          child: DecoratedBox(
            decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: p.border)),
            child: TabBar(
              controller: _tab, isScrollable: true, dividerColor: Colors.transparent,
              indicatorColor: p.gold, indicatorSize: TabBarIndicatorSize.label,
              labelStyle: p.body(12.5, weight: FontWeight.w600), unselectedLabelStyle: p.body(12.5),
              labelColor: p.gold, unselectedLabelColor: p.textMuted, tabAlignment: TabAlignment.start,
              tabs: const [Tab(text: 'General'), Tab(text: 'Company'), Tab(text: 'Branch'), Tab(text: 'Payment'), Tab(text: 'Notification'), Tab(text: 'Tax'), Tab(text: 'Membership'), Tab(text: 'POS'), Tab(text: 'Mobile App'), Tab(text: 'Website')],
            ),
          ),
        ),
      ],
      child: EagerTabBarView(controller: _tab, children: [
        _GeneralTab(p: p, name: _name, addr: _addr, phone: _phone, email: _email, schedule: _schedule, onSave: _save),
        _CompanyTab(p: p),
        _BranchTab(p: p),
        _PaymentTab(p: p),
        _NotificationTab(p: p),
        _TaxTab(p: p),
        _MembershipSettingsTab(p: p),
        _PosTab(p: p),
        _MobileAppTab(p: p),
        _WebsiteTab(p: p),
      ]),
    );
  }
}

// ─── General Tab ─────────────────────────────────────────────────────────────

class _GeneralTab extends StatefulWidget {
  final AppPalette p;
  final TextEditingController name, addr, phone, email;
  final Map<String, Set<int>> schedule;
  final VoidCallback onSave;
  const _GeneralTab({required this.p, required this.name, required this.addr, required this.phone, required this.email, required this.schedule, required this.onSave});
  @override
  State<_GeneralTab> createState() => _GeneralTabState();
}

class _GeneralTabState extends State<_GeneralTab> {
  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    return ScrollArea(builder: (sc) => SingleChildScrollView(
      controller: sc,
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        MetricRow([
          MetricCard(title: 'System Version', value: '2026.1', delta: 'Stable', icon: Icons.verified_outlined),
          MetricCard(title: 'Database', value: 'Connected', delta: 'Local Mock', icon: Icons.storage_outlined),
          MetricCard(title: 'Active Users', value: '4', delta: 'Online', icon: Icons.people_alt_outlined),
          MetricCard(title: 'Backup Status', value: 'Safe', delta: 'Synced', icon: Icons.cloud_done_outlined),
        ]),
        const SizedBox(height: 18),
        LayoutBuilder(builder: (_, c) {
          final wide = c.maxWidth > 900;
          final profile = _profileCard(p);
          final sched   = _scheduleCard(p);
          if (wide) return IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Expanded(child: profile), const SizedBox(width: 18), Expanded(child: sched)]));
          return Column(children: [profile, const SizedBox(height: 18), sched]);
        }),
        const SizedBox(height: 18),
        _accentCard(p),
        const SizedBox(height: 28),
      ]),
    ));
  }

  Widget _profileCard(AppPalette p) => Panel(
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SectionTitle('CLINIC PROFILE'),
      const SizedBox(height: 16),
      FormField2(label: 'Clinic Name',  controller: widget.name),
      const SizedBox(height: 14),
      FormField2(label: 'Address',      controller: widget.addr, maxLines: 2),
      const SizedBox(height: 14),
      Row(children: [Expanded(child: FormField2(label: 'Phone', controller: widget.phone)), const SizedBox(width: 14), Expanded(child: FormField2(label: 'Email', controller: widget.email))]),
    ]),
  );

  Widget _scheduleCard(AppPalette p) {
    const dows = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return Panel(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SectionTitle('DOCTOR ASSIGNMENT SCHEDULES', sub: 'Toggle working days per surgeon'),
        const SizedBox(height: 16),
        ...appState.surgeons.map((s) {
          final days = widget.schedule[s] ?? <int>{};
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(s, style: p.body(13, weight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(spacing: 6, runSpacing: 6, children: List.generate(7, (i) {
                final on = days.contains(i);
                return GestureDetector(
                  onTap: () => setState(() { on ? days.remove(i) : days.add(i); widget.schedule[s] = days; }),
                  child: Container(width: 42, padding: const EdgeInsets.symmetric(vertical: 8), alignment: Alignment.center, decoration: BoxDecoration(color: on ? p.gold.withValues(alpha: 0.16) : p.surfaceAlt, borderRadius: BorderRadius.circular(8), border: Border.all(color: on ? p.gold : p.border)), child: Text(dows[i], style: p.body(11, color: on ? p.gold : p.textMuted, weight: FontWeight.w600))),
                );
              })),
            ]),
          );
        }),
      ]),
    );
  }

  Widget _accentCard(AppPalette p) => Panel(
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SectionTitle('GENERAL UI CUSTOMIZATION', sub: 'Theme mode & accent color'),
      const SizedBox(height: 16),
      Row(children: [Text('Appearance', style: p.body(13, weight: FontWeight.w600)), const SizedBox(width: 16), const ThemeToggle(), const SizedBox(width: 12), Text(appState.isDark ? 'Obsidian & Gold (Dark)' : 'Clinical Minimalist (Light)', style: p.body(12.5, color: p.textMuted))]),
      const SizedBox(height: 20),
      Text('Accent Color', style: p.body(13, weight: FontWeight.w600)),
      const SizedBox(height: 12),
      Wrap(spacing: 12, runSpacing: 12, children: List.generate(AppState.accents.length, (i) {
        final a = AppState.accents[i];
        final sel = appState.accentIndex == i;
        return GestureDetector(
          onTap: () => appState.setAccent(i),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(8), border: Border.all(color: sel ? a.color : p.border, width: sel ? 1.6 : 1)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [Container(width: 18, height: 18, decoration: BoxDecoration(color: a.color, borderRadius: BorderRadius.circular(6))), const SizedBox(width: 10), Text(a.name, style: p.body(12.5, weight: FontWeight.w600, color: sel ? p.text : p.textMuted)), if (sel) ...[const SizedBox(width: 8), Icon(Icons.check_circle, size: 15, color: a.color)]]),
          ),
        );
      })),
    ]),
  );
}

// ─── Company Tab ─────────────────────────────────────────────────────────────

class _CompanyTab extends StatefulWidget {
  final AppPalette p;
  const _CompanyTab({required this.p});
  @override
  State<_CompanyTab> createState() => _CompanyTabState();
}

class _CompanyTabState extends State<_CompanyTab> {
  final _regNo   = TextEditingController(text: 'RC-2021-45678');
  final _ntn     = TextEditingController(text: '1234567-8');
  final _strn    = TextEditingController(text: 'SRN-9876543');
  final _ceo     = TextEditingController(text: 'Dr. Ahmed Rehman');
  final _founded = TextEditingController(text: '2015');
  final _web     = TextEditingController(text: 'www.hairagain.pk');
  final _social  = TextEditingController(text: '@hairagain_pk');
  final _desc    = TextEditingController(text: 'Hair Again is a premier hair restoration clinic specializing in FUE transplants, PRP therapy, and advanced hair care treatments.');

  @override
  void dispose() { for (final c in [_regNo, _ntn, _strn, _ceo, _founded, _web, _social, _desc]) c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    return ScrollArea(builder: (sc) => SingleChildScrollView(
      controller: sc,
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SectionTitle('COMPANY LEGAL INFORMATION'),
          const SizedBox(height: 16),
          Row(children: [Expanded(child: FormField2(label: 'Registration No.', controller: _regNo)), const SizedBox(width: 14), Expanded(child: FormField2(label: 'NTN Number', controller: _ntn))]),
          const SizedBox(height: 14),
          Row(children: [Expanded(child: FormField2(label: 'STRN Number', controller: _strn)), const SizedBox(width: 14), Expanded(child: FormField2(label: 'Year Founded', controller: _founded))]),
          const SizedBox(height: 14),
          FormField2(label: 'CEO / Owner Name', controller: _ceo),
        ])),
        const SizedBox(height: 18),
        Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SectionTitle('DIGITAL PRESENCE'),
          const SizedBox(height: 16),
          FormField2(label: 'Official Website', controller: _web),
          const SizedBox(height: 14),
          FormField2(label: 'Social Media Handle', controller: _social),
          const SizedBox(height: 14),
          FormField2(label: 'Company Description', controller: _desc, maxLines: 3),
        ])),
        const SizedBox(height: 18),
        Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SectionTitle('COMPLIANCE STATUS'),
          const SizedBox(height: 16),
          ...[
            ('PMDC Registration', 'Active — Expires Dec 2026', p.success),
            ('Tax Compliance', 'Filer — FY 2025-26', p.success),
            ('Health Authority License', 'Active — PHSRP Certified', p.success),
            ('Data Protection', 'PDPA Compliant', p.success),
          ].map((e) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(children: [
            Icon(Icons.verified_outlined, size: 16, color: e.$3),
            const SizedBox(width: 10),
            Expanded(child: Text(e.$1, style: p.body(13, weight: FontWeight.w600))),
            Text(e.$2, style: p.body(12.5, color: e.$3)),
          ]))),
        ])),
        const SizedBox(height: 18),
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [GoldButton(label: 'Save Company Info', icon: Icons.save_outlined, onTap: () => toast(context, 'Company info saved'))]),
        const SizedBox(height: 28),
      ]),
    ));
  }
}

// ─── Branch Tab ───────────────────────────────────────────────────────────────

class _Branch {
  final String name, address, phone, manager, status;
  _Branch({required this.name, required this.address, required this.phone, required this.manager, required this.status});
}

class _BranchTab extends StatefulWidget {
  final AppPalette p;
  const _BranchTab({required this.p});
  @override
  State<_BranchTab> createState() => _BranchTabState();
}

class _BranchTabState extends State<_BranchTab> {
  final _branches = [
    _Branch(name: 'Main Branch — Gulberg', address: '45-A, Main Blvd, Gulberg III, Lahore', phone: '042-35761234', manager: 'Dr. Ahmed Rehman', status: 'Active'),
    _Branch(name: 'DHA Branch', address: 'Phase 5, DHA, Lahore', phone: '042-35892345', manager: 'Dr. Sara Iqbal', status: 'Active'),
    _Branch(name: 'Islamabad Branch', address: 'F-7 Markaz, Islamabad', phone: '051-2893456', manager: 'Dr. Bilal Khan', status: 'Planned'),
  ];

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    return ScrollArea(builder: (sc) => SingleChildScrollView(
      controller: sc,
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        MetricRow([
          MetricCard(title: 'Total Branches', value: '${_branches.length}', delta: 'All locations', icon: Icons.location_city_outlined),
          MetricCard(title: 'Active', value: '${_branches.where((b) => b.status == "Active").length}', delta: 'Operational', icon: Icons.check_circle_outline),
          MetricCard(title: 'Planned', value: '${_branches.where((b) => b.status == "Planned").length}', delta: 'Coming soon', icon: Icons.pending_outlined),
          MetricCard(title: 'Staff Across', value: '18', delta: 'Total staff', icon: Icons.people_outlined),
        ]),
        const SizedBox(height: 18),
        Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Expanded(child: SectionTitle('BRANCH MANAGEMENT')),
            GoldButton(label: 'Add Branch', icon: Icons.add_business_outlined, onTap: () => toast(context, 'Add branch coming soon')),
          ]),
          const SizedBox(height: 14),
          ..._branches.map((b) {
            final sc = b.status == 'Active' ? p.success : p.warning;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(10), border: Border.all(color: p.border)),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: p.gold.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(10)), child: Icon(Icons.store_outlined, color: p.gold, size: 22)),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text(b.name, style: p.body(14, weight: FontWeight.w700))),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: sc.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(4)), child: Text(b.status, style: p.body(11, color: sc, weight: FontWeight.w600))),
                  ]),
                  const SizedBox(height: 6),
                  _infoRow(Icons.location_on_outlined, b.address, p),
                  const SizedBox(height: 4),
                  _infoRow(Icons.phone_outlined, b.phone, p),
                  const SizedBox(height: 4),
                  _infoRow(Icons.person_outlined, 'Manager: ${b.manager}', p),
                ])),
                IconButton(icon: Icon(Icons.edit_outlined, size: 16, color: p.textMuted), onPressed: () {}),
              ]),
            );
          }),
        ])),
        const SizedBox(height: 18),
        Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SectionTitle('BRANCH SETTINGS'),
          const SizedBox(height: 14),
          _SettingRow(p: p, icon: Icons.sync_outlined, label: 'Cross-branch Data Sync', sub: 'Share patient data across all branches', value: true, onChanged: (_) {}),
          const Divider(height: 20),
          _SettingRow(p: p, icon: Icons.inventory_outlined, label: 'Shared Inventory', sub: 'View and transfer stock between branches', value: false, onChanged: (_) {}),
          const Divider(height: 20),
          _SettingRow(p: p, icon: Icons.calendar_month_outlined, label: 'Cross-branch Appointments', sub: 'Allow booking at any branch', value: true, onChanged: (_) {}),
        ])),
        const SizedBox(height: 28),
      ]),
    ));
  }

  Widget _infoRow(IconData icon, String text, AppPalette p) => Row(children: [Icon(icon, size: 13, color: p.textMuted), const SizedBox(width: 6), Expanded(child: Text(text, style: p.body(12, color: p.textMuted)))]);
}

// ─── Payment Tab ──────────────────────────────────────────────────────────────

class _PaymentTab extends StatefulWidget {
  final AppPalette p;
  const _PaymentTab({required this.p});
  @override
  State<_PaymentTab> createState() => _PaymentTabState();
}

class _PaymentTabState extends State<_PaymentTab> {
  final _jazz  = TextEditingController(text: 'JC-MERCH-84729');
  final _easy  = TextEditingController(text: '0300-1234567');
  final _bank  = TextEditingController(text: 'MCB — 1234-5678-9012-3456');

  @override
  void dispose() { _jazz.dispose(); _easy.dispose(); _bank.dispose(); super.dispose(); }

  final _methods = {
    'Cash': true,
    'Credit / Debit Card': true,
    'Bank Transfer': true,
    'JazzCash': true,
    'EasyPaisa': true,
    'Cheque': false,
    'Installment Plan': false,
    'Insurance': false,
  };

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    return ScrollArea(builder: (sc) => SingleChildScrollView(
      controller: sc,
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SectionTitle('ACCEPTED PAYMENT METHODS'),
          const SizedBox(height: 14),
          Wrap(spacing: 10, runSpacing: 10, children: _methods.entries.map((e) {
            final on = e.value;
            return GestureDetector(
              onTap: () => setState(() => _methods[e.key] = !on),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(color: on ? p.gold.withValues(alpha: 0.10) : p.surfaceAlt, borderRadius: BorderRadius.circular(8), border: Border.all(color: on ? p.gold : p.border)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(on ? Icons.check_box_outlined : Icons.check_box_outline_blank, size: 16, color: on ? p.gold : p.textMuted),
                  const SizedBox(width: 8),
                  Text(e.key, style: p.body(12.5, color: on ? p.text : p.textMuted, weight: on ? FontWeight.w600 : FontWeight.w500)),
                ]),
              ),
            );
          }).toList()),
        ])),
        const SizedBox(height: 18),
        Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SectionTitle('INVOICE SETTINGS'),
          const SizedBox(height: 14),
          _SettingRow(p: p, icon: Icons.receipt_long_outlined, label: 'Auto-generate Invoice Number', sub: 'Prefix: INV — Format: INV-YYYY-####', value: true, onChanged: (_) {}),
          const Divider(height: 20),
          _SettingRow(p: p, icon: Icons.print_outlined, label: 'Auto-print Invoice', sub: 'Print immediately after payment', value: false, onChanged: (_) {}),
          const Divider(height: 20),
          _SettingRow(p: p, icon: Icons.email_outlined, label: 'Email Invoice to Patient', sub: 'Send PDF copy after payment', value: true, onChanged: (_) {}),
          const Divider(height: 20),
          _SettingRow(p: p, icon: Icons.currency_exchange_outlined, label: 'Allow Partial Payments', sub: 'Record advance and balance due', value: true, onChanged: (_) {}),
        ])),
        const SizedBox(height: 18),
        Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SectionTitle('GATEWAY CONFIGURATION'),
          const SizedBox(height: 14),
          FormField2(label: 'JazzCash Merchant ID', controller: _jazz),
          const SizedBox(height: 14),
          FormField2(label: 'EasyPaisa Account No.', controller: _easy),
          const SizedBox(height: 14),
          FormField2(label: 'Bank Account (Transfer)', controller: _bank),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [GoldButton(label: 'Save Payment Settings', icon: Icons.save_outlined, onTap: () => toast(context, 'Payment settings saved'))]),
        ])),
        const SizedBox(height: 28),
      ]),
    ));
  }
}

// ─── Notification Tab ─────────────────────────────────────────────────────────

class _NotificationTab extends StatelessWidget {
  final AppPalette p;
  const _NotificationTab({required this.p});

  @override
  Widget build(BuildContext context) {
    return ScrollArea(builder: (sc) => SingleChildScrollView(
      controller: sc,
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SectionTitle('IN-APP NOTIFICATION PREFERENCES', sub: 'Control which alerts appear in the system'),
          const SizedBox(height: 16),
          Wrap(spacing: 16, runSpacing: 12, children: const [
            _NotifChip(label: 'Appointment Reminders', enabled: true),
            _NotifChip(label: 'Low Stock Alerts', enabled: true),
            _NotifChip(label: 'Payment Received', enabled: true),
            _NotifChip(label: 'New Lead Assigned', enabled: true),
            _NotifChip(label: 'Leave Approvals', enabled: false),
            _NotifChip(label: 'Daily Summary', enabled: true),
            _NotifChip(label: 'Staff Attendance', enabled: false),
            _NotifChip(label: 'Campaign Reports', enabled: true),
          ]),
        ])),
        const SizedBox(height: 18),
        Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SectionTitle('SMS NOTIFICATION RULES'),
          const SizedBox(height: 14),
          _SettingRow(p: p, icon: Icons.sms_outlined, label: 'Appointment Confirmation SMS', sub: 'Send on new booking', value: true, onChanged: (_) {}),
          const Divider(height: 20),
          _SettingRow(p: p, icon: Icons.sms_outlined, label: 'Appointment Reminder SMS', sub: '24 hours before appointment', value: true, onChanged: (_) {}),
          const Divider(height: 20),
          _SettingRow(p: p, icon: Icons.sms_outlined, label: 'Payment Receipt SMS', sub: 'On invoice payment', value: true, onChanged: (_) {}),
          const Divider(height: 20),
          _SettingRow(p: p, icon: Icons.sms_outlined, label: 'Follow-up Reminder SMS', sub: '7 days after treatment', value: false, onChanged: (_) {}),
        ])),
        const SizedBox(height: 18),
        Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SectionTitle('EMAIL NOTIFICATION RULES'),
          const SizedBox(height: 14),
          _SettingRow(p: p, icon: Icons.email_outlined, label: 'Invoice Email', sub: 'PDF invoice after payment', value: true, onChanged: (_) {}),
          const Divider(height: 20),
          _SettingRow(p: p, icon: Icons.email_outlined, label: 'Monthly Statement', sub: 'Patient visit summary each month', value: false, onChanged: (_) {}),
          const Divider(height: 20),
          _SettingRow(p: p, icon: Icons.email_outlined, label: 'Treatment Plan Email', sub: 'Send plan PDF to patient', value: true, onChanged: (_) {}),
          const Divider(height: 20),
          _SettingRow(p: p, icon: Icons.email_outlined, label: 'Admin Daily Digest', sub: 'Summary email at 09:00 AM', value: true, onChanged: (_) {}),
        ])),
        const SizedBox(height: 28),
      ]),
    ));
  }
}

// ─── Tax Tab ──────────────────────────────────────────────────────────────────

class _TaxTab extends StatefulWidget {
  final AppPalette p;
  const _TaxTab({required this.p});
  @override
  State<_TaxTab> createState() => _TaxTabState();
}

class _TaxTabState extends State<_TaxTab> {
  bool _taxEnabled = true;
  double _gstRate = 17.0;
  double _sst = 0.0;
  bool _inclusivePricing = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    return ScrollArea(builder: (sc) => SingleChildScrollView(
      controller: sc,
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SectionTitle('TAX CONFIGURATION'),
          const SizedBox(height: 14),
          _SettingRow(p: p, icon: Icons.percent_outlined, label: 'Enable Tax on Invoices', sub: 'Apply configured tax rate to all sales', value: _taxEnabled, onChanged: (v) => setState(() => _taxEnabled = v)),
          const Divider(height: 20),
          _SettingRow(p: p, icon: Icons.money_outlined, label: 'Tax-Inclusive Pricing', sub: 'Display prices with tax included', value: _inclusivePricing, onChanged: (v) => setState(() => _inclusivePricing = v)),
        ])),
        const SizedBox(height: 18),
        Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SectionTitle('TAX RATES'),
          const SizedBox(height: 14),
          _RateRow(p: p, label: 'General Sales Tax (GST)', sub: 'Federal — Standard rate', rate: _gstRate, onChanged: (v) => setState(() => _gstRate = v)),
          const Divider(height: 24),
          _RateRow(p: p, label: 'Sindh Sales Tax (SST)', sub: 'Provincial — Services only (if applicable)', rate: _sst, onChanged: (v) => setState(() => _sst = v)),
          const Divider(height: 24),
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Combined Effective Rate', style: p.body(13, weight: FontWeight.w600)),
              Text('GST + SST applied to taxable invoices', style: p.body(12, color: p.textMuted)),
            ])),
            Text('${(_gstRate + _sst).toStringAsFixed(1)}%', style: p.body(18, weight: FontWeight.w800, color: p.gold)),
          ]),
        ])),
        const SizedBox(height: 18),
        Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SectionTitle('TAX EXEMPTIONS'),
          const SizedBox(height: 14),
          ...[('Consultation Fee', false), ('PRP Therapy', false), ('Hair Transplant (FUE)', true), ('Product Sales', false), ('Membership Plans', true)].map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(item.$1, style: p.body(13, weight: FontWeight.w600)),
                Text(item.$2 ? 'Tax Exempt' : 'Taxable', style: p.body(12, color: item.$2 ? p.success : p.textMuted)),
              ])),
              Switch(value: item.$2, onChanged: (_) {}, activeThumbColor: p.gold, activeTrackColor: p.gold.withValues(alpha: 0.3)),
            ]),
          )),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [GoldButton(label: 'Save Tax Settings', icon: Icons.save_outlined, onTap: () => toast(context, 'Tax settings saved'))]),
        ])),
        const SizedBox(height: 28),
      ]),
    ));
  }
}

class _RateRow extends StatefulWidget {
  final AppPalette p;
  final String label, sub;
  final double rate;
  final ValueChanged<double> onChanged;
  const _RateRow({required this.p, required this.label, required this.sub, required this.rate, required this.onChanged});
  @override
  State<_RateRow> createState() => _RateRowState();
}

class _RateRowState extends State<_RateRow> {
  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    return Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(widget.label, style: p.body(13, weight: FontWeight.w600)),
        Text(widget.sub, style: p.body(12, color: p.textMuted)),
      ])),
      QtyButton(Icons.remove, () => widget.onChanged((widget.rate - 0.5).clamp(0, 100))),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text('${widget.rate.toStringAsFixed(1)}%', style: p.body(15, weight: FontWeight.w700))),
      QtyButton(Icons.add, () => widget.onChanged((widget.rate + 0.5).clamp(0, 100))),
    ]);
  }
}

// ─── Membership Settings Tab ──────────────────────────────────────────────────

class _MembershipSettingsTab extends StatefulWidget {
  final AppPalette p;
  const _MembershipSettingsTab({required this.p});
  @override
  State<_MembershipSettingsTab> createState() => _MembershipSettingsTabState();
}

class _MembershipSettingsTabState extends State<_MembershipSettingsTab> {
  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    return ScrollArea(builder: (sc) => SingleChildScrollView(
      controller: sc,
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SectionTitle('MEMBERSHIP RULES'),
          const SizedBox(height: 14),
          _SettingRow(p: p, icon: Icons.card_membership_outlined, label: 'Auto-Renewal', sub: 'Renew membership automatically on expiry', value: false, onChanged: (_) {}),
          const Divider(height: 20),
          _SettingRow(p: p, icon: Icons.notifications_outlined, label: 'Expiry Reminder', sub: 'Notify patient 7 days before expiry', value: true, onChanged: (_) {}),
          const Divider(height: 20),
          _SettingRow(p: p, icon: Icons.transfer_within_a_station_outlined, label: 'Session Transfer', sub: 'Allow unused sessions to carry forward', value: true, onChanged: (_) {}),
          const Divider(height: 20),
          _SettingRow(p: p, icon: Icons.people_outlined, label: 'Family Membership', sub: 'Allow one plan to cover family members', value: false, onChanged: (_) {}),
        ])),
        const SizedBox(height: 18),
        Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SectionTitle('PLAN DEFAULTS'),
          const SizedBox(height: 14),
          ...appState.membershipPlans.take(4).map((plan) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(children: [
              Container(width: 10, height: 10, decoration: BoxDecoration(color: p.gold, shape: BoxShape.circle)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(plan.name, style: p.body(13, weight: FontWeight.w600)),
                Text('PKR ${plan.price.toStringAsFixed(0)} · ${plan.maxSessions} sessions', style: p.body(12, color: p.textMuted)),
              ])),
              Icon(Icons.edit_outlined, size: 15, color: p.textMuted),
            ]),
          )),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [GoldButton(label: 'Save Membership Settings', icon: Icons.save_outlined, onTap: () => toast(context, 'Saved'))]),
        ])),
        const SizedBox(height: 28),
      ]),
    ));
  }
}

// ─── POS Tab ─────────────────────────────────────────────────────────────────

class _PosTab extends StatefulWidget {
  final AppPalette p;
  const _PosTab({required this.p});
  @override
  State<_PosTab> createState() => _PosTabState();
}

class _PosTabState extends State<_PosTab> {
  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    return ScrollArea(builder: (sc) => SingleChildScrollView(
      controller: sc,
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SectionTitle('TREATMENT MASTER PRICING', sub: 'Adjust prices used across POS & booking'),
          const SizedBox(height: 16),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Row(children: [
            Expanded(flex: 5, child: _th(p, 'TREATMENT')),
            Expanded(flex: 2, child: _th(p, 'CATEGORY')),
            Expanded(flex: 3, child: _th(p, 'PRICE (PKR)')),
          ])),
          const SizedBox(height: 6),
          Divider(height: 1, color: p.border),
          ...appState.treatments.map((t) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Row(children: [
              Expanded(flex: 5, child: Text(t.name, style: p.body(13, weight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
              Expanded(flex: 2, child: Text(t.category, style: p.body(12.5, color: p.textMuted))),
              Expanded(flex: 3, child: Row(children: [
                QtyButton(Icons.remove, () => appState.setTreatmentPrice(t, (t.price - 1000).clamp(0, double.infinity))),
                Expanded(child: Container(alignment: Alignment.center, child: Text(money(t.price), style: p.body(13, weight: FontWeight.w700)))),
                QtyButton(Icons.add, () => appState.setTreatmentPrice(t, t.price + 1000)),
              ])),
            ]),
          )),
        ])),
        const SizedBox(height: 18),
        Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SectionTitle('POS BEHAVIOR SETTINGS'),
          const SizedBox(height: 14),
          _SettingRow(p: p, icon: Icons.discount_outlined, label: 'Allow Discount Override', sub: 'Receptionist can manually set discounts', value: true, onChanged: (_) {}),
          const Divider(height: 20),
          _SettingRow(p: p, icon: Icons.loyalty_outlined, label: 'Apply Loyalty Points', sub: 'Redeem points at checkout', value: true, onChanged: (_) {}),
          const Divider(height: 20),
          _SettingRow(p: p, icon: Icons.receipt_outlined, label: 'Show Tax Breakdown', sub: 'Display GST separately on receipt', value: true, onChanged: (_) {}),
          const Divider(height: 20),
          _SettingRow(p: p, icon: Icons.inventory_outlined, label: 'Auto-deduct Stock on Sale', sub: 'Update inventory on product sale', value: true, onChanged: (_) {}),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [GoldButton(label: 'Save POS Settings', icon: Icons.save_outlined, onTap: () => toast(context, 'POS settings saved'))]),
        ])),
        const SizedBox(height: 28),
      ]),
    ));
  }

  Widget _th(AppPalette p, String t) => Text(t, style: p.body(11, color: p.textMuted, weight: FontWeight.w700, spacing: 0.8));
}

// ─── Mobile App Tab ───────────────────────────────────────────────────────────

class _MobileAppTab extends StatefulWidget {
  final AppPalette p;
  const _MobileAppTab({required this.p});
  @override
  State<_MobileAppTab> createState() => _MobileAppTabState();
}

class _MobileAppTabState extends State<_MobileAppTab> {
  final _appName    = TextEditingController(text: 'Hair Again');
  final _supportPh  = TextEditingController(text: '+92-300-1234567');
  final _supportEm  = TextEditingController(text: 'support@hairagain.pk');

  @override
  void dispose() { _appName.dispose(); _supportPh.dispose(); _supportEm.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    return ScrollArea(builder: (sc) => SingleChildScrollView(
      controller: sc,
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(gradient: LinearGradient(colors: [p.gold.withValues(alpha: 0.08), p.gold.withValues(alpha: 0.03)]), borderRadius: BorderRadius.circular(12), border: Border.all(color: p.gold.withValues(alpha: 0.2))), child: Row(children: [
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: p.gold.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)), child: Icon(Icons.phone_android_outlined, color: p.gold, size: 36)),
          const SizedBox(width: 20),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Hair Again Mobile App', style: p.body(16, weight: FontWeight.w800)),
            Text('Customer-facing app for iOS & Android — appointments, plans, loyalty.', style: p.body(13, color: p.textMuted)),
            const SizedBox(height: 8),
            Row(children: [
              _AppBadge('Android', p.success, p),
              const SizedBox(width: 8),
              _AppBadge('iOS', p.info, p),
            ]),
          ])),
        ])),
        const SizedBox(height: 18),
        Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SectionTitle('APP FEATURES CONTROL'),
          const SizedBox(height: 14),
          _SettingRow(p: p, icon: Icons.calendar_month_outlined, label: 'Online Appointment Booking', sub: 'Allow patients to book from the app', value: true, onChanged: (_) {}),
          const Divider(height: 20),
          _SettingRow(p: p, icon: Icons.assignment_outlined, label: 'View Treatment Plans', sub: 'Patient can see their plans and progress', value: true, onChanged: (_) {}),
          const Divider(height: 20),
          _SettingRow(p: p, icon: Icons.receipt_long_outlined, label: 'Invoice History', sub: 'Show past invoices and payments', value: true, onChanged: (_) {}),
          const Divider(height: 20),
          _SettingRow(p: p, icon: Icons.stars_outlined, label: 'Loyalty & Rewards', sub: 'Show points balance and redemption', value: true, onChanged: (_) {}),
          const Divider(height: 20),
          _SettingRow(p: p, icon: Icons.chat_outlined, label: 'In-App Chat Support', sub: 'Patient can chat with clinic staff', value: false, onChanged: (_) {}),
          const Divider(height: 20),
          _SettingRow(p: p, icon: Icons.photo_library_outlined, label: 'Before / After Gallery', sub: 'Show patient photo progress', value: true, onChanged: (_) {}),
        ])),
        const SizedBox(height: 18),
        Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SectionTitle('APP CONFIGURATION'),
          const SizedBox(height: 14),
          FormField2(label: 'App Name', controller: _appName),
          const SizedBox(height: 14),
          FormField2(label: 'Support Phone (shown in app)', controller: _supportPh),
          const SizedBox(height: 14),
          FormField2(label: 'Support Email (shown in app)', controller: _supportEm),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [GoldButton(label: 'Save App Settings', icon: Icons.save_outlined, onTap: () => toast(context, 'Mobile app settings saved'))]),
        ])),
        const SizedBox(height: 28),
      ]),
    ));
  }
}

class _AppBadge extends StatelessWidget {
  final String label;
  final Color color;
  final AppPalette p;
  const _AppBadge(this.label, this.color, this.p);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(4)),
    child: Text(label, style: p.body(11, color: color, weight: FontWeight.w700)),
  );
}

// ─── Website Tab ──────────────────────────────────────────────────────────────

class _WebsiteTab extends StatefulWidget {
  final AppPalette p;
  const _WebsiteTab({required this.p});
  @override
  State<_WebsiteTab> createState() => _WebsiteTabState();
}

class _WebsiteTabState extends State<_WebsiteTab> {
  final _url     = TextEditingController(text: 'https://www.hairagain.pk');
  final _gaId    = TextEditingController(text: 'G-XXXXXXXXXX');
  final _fbPixel = TextEditingController(text: '123456789012345');
  final _waNum   = TextEditingController(text: '+92-300-1234567');
  final _title   = TextEditingController(text: 'Hair Again — Expert Hair Restoration in Pakistan');
  final _meta    = TextEditingController(text: 'Leading hair transplant and PRP therapy clinic in Lahore. Advanced FUE & DHI procedures by expert surgeons.');
  final _kw      = TextEditingController(text: 'hair transplant lahore, PRP therapy, FUE, hair loss treatment');

  @override
  void dispose() { for (final c in [_url, _gaId, _fbPixel, _waNum, _title, _meta, _kw]) c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    return ScrollArea(builder: (sc) => SingleChildScrollView(
      controller: sc,
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SectionTitle('WEBSITE INTEGRATION', sub: 'Sync clinic data with your public website'),
          const SizedBox(height: 14),
          _SettingRow(p: p, icon: Icons.sync_outlined, label: 'Live Availability Sync', sub: 'Show real-time appointment slots on website', value: true, onChanged: (_) {}),
          const Divider(height: 20),
          _SettingRow(p: p, icon: Icons.book_online_outlined, label: 'Online Booking Widget', sub: 'Embed booking form on your website', value: true, onChanged: (_) {}),
          const Divider(height: 20),
          _SettingRow(p: p, icon: Icons.rate_review_outlined, label: 'Auto-publish Reviews', sub: 'Display patient feedback on website', value: false, onChanged: (_) {}),
          const Divider(height: 20),
          _SettingRow(p: p, icon: Icons.inventory_outlined, label: 'Product Catalogue Sync', sub: 'Show available products for purchase', value: false, onChanged: (_) {}),
        ])),
        const SizedBox(height: 18),
        Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SectionTitle('WEBSITE DETAILS'),
          const SizedBox(height: 14),
          FormField2(label: 'Website URL', controller: _url),
          const SizedBox(height: 14),
          FormField2(label: 'Google Analytics ID', controller: _gaId),
          const SizedBox(height: 14),
          FormField2(label: 'Facebook Pixel ID', controller: _fbPixel),
          const SizedBox(height: 14),
          FormField2(label: 'WhatsApp Chat Number (widget)', controller: _waNum),
        ])),
        const SizedBox(height: 18),
        Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SectionTitle('SEO & META SETTINGS'),
          const SizedBox(height: 14),
          FormField2(label: 'Page Title', controller: _title),
          const SizedBox(height: 14),
          FormField2(label: 'Meta Description', controller: _meta, maxLines: 3),
          const SizedBox(height: 14),
          FormField2(label: 'Keywords (comma-separated)', controller: _kw),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [GoldButton(label: 'Save Website Settings', icon: Icons.save_outlined, onTap: () => toast(context, 'Website settings saved'))]),
        ])),
        const SizedBox(height: 28),
      ]),
    ));
  }
}

// ─── Shared helpers ───────────────────────────────────────────────────────────

class _SettingRow extends StatefulWidget {
  final AppPalette p;
  final IconData icon;
  final String label, sub;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SettingRow({required this.p, required this.icon, required this.label, required this.sub, required this.value, required this.onChanged});
  @override
  State<_SettingRow> createState() => _SettingRowState();
}
class _SettingRowState extends State<_SettingRow> {
  late bool _val = widget.value;
  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(widget.icon, size: 18, color: widget.p.textMuted),
    const SizedBox(width: 12),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(widget.label, style: widget.p.body(13, weight: FontWeight.w600)),
      Text(widget.sub, style: widget.p.body(11.5, color: widget.p.textMuted)),
    ])),
    Switch(value: _val, onChanged: (v) { setState(() => _val = v); widget.onChanged(v); }, activeThumbColor: widget.p.gold, activeTrackColor: widget.p.gold.withValues(alpha: 0.3)),
  ]);
}

class _NotifChip extends StatefulWidget {
  final String label;
  final bool enabled;
  const _NotifChip({required this.label, required this.enabled});
  @override
  State<_NotifChip> createState() => _NotifChipState();
}
class _NotifChipState extends State<_NotifChip> {
  late bool _on = widget.enabled;
  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    return GestureDetector(
      onTap: () => setState(() => _on = !_on),
      child: MouseRegion(cursor: SystemMouseCursors.click, child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(color: _on ? p.gold.withValues(alpha: 0.10) : p.surfaceAlt, borderRadius: BorderRadius.circular(8), border: Border.all(color: _on ? p.gold : p.border)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(_on ? Icons.notifications_active_outlined : Icons.notifications_off_outlined, size: 15, color: _on ? p.gold : p.textMuted),
          const SizedBox(width: 7),
          Text(widget.label, style: p.body(12.5, color: _on ? p.text : p.textMuted, weight: _on ? FontWeight.w600 : FontWeight.w500)),
        ]),
      )),
    );
  }
}
