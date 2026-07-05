import 'package:flutter/material.dart';
import '../../../core/core.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});
  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 6, vsync: this);
  }
  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    return ScreenScaffold(
      title: 'SECURITY CENTER',
      subtitle: 'Audit logs, backups, API keys, and session management.',
      actions: [
        Container(
          height: 42,
          decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: p.border)),
          child: TabBar(
            controller: _tab, isScrollable: true, dividerColor: Colors.transparent,
            indicatorColor: p.gold, indicatorSize: TabBarIndicatorSize.label,
            labelStyle: p.body(12.5, weight: FontWeight.w600), unselectedLabelStyle: p.body(12.5),
            labelColor: p.gold, unselectedLabelColor: p.textMuted, tabAlignment: TabAlignment.start,
            tabs: const [Tab(text: 'Audit Logs'), Tab(text: 'System Logs'), Tab(text: 'Backup Management'), Tab(text: 'Restore Data'), Tab(text: 'API Keys'), Tab(text: 'Session Management')],
          ),
        ),
      ],
      child: EagerTabBarView(controller: _tab, children: [
        _AuditLogsTab(p: p),
        _SystemLogsTab(p: p),
        _BackupTab(p: p),
        _RestoreTab(p: p),
        _ApiKeysTab(p: p),
        _SessionsTab(p: p),
      ]),
    );
  }
}

// ─── Audit Logs ───────────────────────────────────────────────────────────────

class _AuditEntry {
  final String user, action, module, detail, ip;
  final DateTime time;
  final String level;
  const _AuditEntry({required this.user, required this.action, required this.module, required this.detail, required this.ip, required this.time, required this.level});
}

final _auditData = [
  _AuditEntry(user: 'Admin', action: 'UPDATE', module: 'Settings', detail: 'Clinic profile updated', ip: '192.168.1.10', time: DateTime.now().subtract(const Duration(minutes: 5)), level: 'Info'),
  _AuditEntry(user: 'Dr. Rehman', action: 'CREATE', module: 'Appointments', detail: 'New appointment booked for Muhammad Arif', ip: '192.168.1.12', time: DateTime.now().subtract(const Duration(minutes: 18)), level: 'Info'),
  _AuditEntry(user: 'Admin', action: 'DELETE', module: 'Staff', detail: 'Staff record #STF-009 removed', ip: '192.168.1.10', time: DateTime.now().subtract(const Duration(minutes: 45)), level: 'Warning'),
  _AuditEntry(user: 'Dr. Sara', action: 'CREATE', module: 'Finance', detail: 'Invoice #INV-1043 created — PKR 60,000', ip: '192.168.1.15', time: DateTime.now().subtract(const Duration(hours: 1)), level: 'Info'),
  _AuditEntry(user: 'Admin', action: 'UPDATE', module: 'User Roles', detail: 'Role "Receptionist" permissions modified', ip: '192.168.1.10', time: DateTime.now().subtract(const Duration(hours: 2)), level: 'Warning'),
  _AuditEntry(user: 'Sana Butt', action: 'LOGIN', module: 'Auth', detail: 'Successful login from Windows Desktop', ip: '192.168.1.20', time: DateTime.now().subtract(const Duration(hours: 3)), level: 'Info'),
  _AuditEntry(user: 'Unknown', action: 'LOGIN_FAIL', module: 'Auth', detail: 'Failed login attempt — wrong password (3 attempts)', ip: '192.168.2.55', time: DateTime.now().subtract(const Duration(hours: 4)), level: 'Critical'),
  _AuditEntry(user: 'Admin', action: 'EXPORT', module: 'Reports', detail: 'Monthly finance report exported to PDF', ip: '192.168.1.10', time: DateTime.now().subtract(const Duration(hours: 5)), level: 'Info'),
  _AuditEntry(user: 'Dr. Bilal', action: 'UPDATE', module: 'CRM', detail: 'Patient Zainab Malik medical record updated', ip: '192.168.1.14', time: DateTime.now().subtract(const Duration(hours: 8)), level: 'Info'),
  _AuditEntry(user: 'Admin', action: 'UPDATE', module: 'Inventory', detail: 'Stock adjustment: Minoxidil 5% +50 units', ip: '192.168.1.10', time: DateTime.now().subtract(const Duration(days: 1)), level: 'Info'),
];

class _AuditLogsTab extends StatefulWidget {
  final AppPalette p;
  const _AuditLogsTab({required this.p});
  @override
  State<_AuditLogsTab> createState() => _AuditLogsTabState();
}

class _AuditLogsTabState extends State<_AuditLogsTab> {
  String _search = '';
  String _level = 'All';
  final _ctrl = TextEditingController();

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  Color _levelColor(String l, AppPalette p) => switch (l) {
    'Critical' => p.danger,
    'Warning'  => p.warning,
    _          => p.info,
  };

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final items = _auditData.where((e) {
      final matchSearch = _search.isEmpty || e.user.toLowerCase().contains(_search.toLowerCase()) || e.action.toLowerCase().contains(_search.toLowerCase()) || e.module.toLowerCase().contains(_search.toLowerCase()) || e.detail.toLowerCase().contains(_search.toLowerCase());
      final matchLevel = _level == 'All' || e.level == _level;
      return matchSearch && matchLevel;
    }).toList();

    return ScrollArea(builder: (sc) => SingleChildScrollView(
      controller: sc,
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        MetricRow([
          MetricCard(title: 'Total Events', value: '${_auditData.length}', delta: 'Today', icon: Icons.history_outlined),
          MetricCard(title: 'Critical', value: '${_auditData.where((e) => e.level == "Critical").length}', delta: 'Need review', icon: Icons.warning_amber_outlined),
          MetricCard(title: 'Warnings', value: '${_auditData.where((e) => e.level == "Warning").length}', delta: 'Today', icon: Icons.info_outline),
          MetricCard(title: 'Active Users', value: '4', delta: 'Online now', icon: Icons.people_outlined),
        ]),
        const SizedBox(height: 18),
        Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Expanded(child: SectionTitle('AUDIT TRAIL')),
            SizedBox(width: 200, child: SearchBox(controller: _ctrl, hint: 'Search audit...', onChanged: (v) => setState(() => _search = v))),
            const SizedBox(width: 10),
            ...<String>['All', 'Info', 'Warning', 'Critical'].map((l) {
              final sel = _level == l;
              return Padding(padding: const EdgeInsets.only(left: 6), child: GestureDetector(onTap: () => setState(() => _level = l), child: AnimatedContainer(duration: const Duration(milliseconds: 120), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: sel ? p.gold.withValues(alpha: 0.12) : p.surfaceAlt, borderRadius: BorderRadius.circular(6), border: Border.all(color: sel ? p.gold : p.border)), child: Text(l, style: p.body(12, color: sel ? p.gold : p.textMuted, weight: FontWeight.w600)))));
            }),
          ]),
          const SizedBox(height: 14),
          Table(
            columnWidths: const {0: FixedColumnWidth(140), 1: FixedColumnWidth(90), 2: FixedColumnWidth(110), 3: FlexColumnWidth(), 4: FixedColumnWidth(130), 5: FixedColumnWidth(80)},
            children: [
              TableRow(decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(6)), children: [
                for (final h in ['USER', 'ACTION', 'MODULE', 'DETAIL', 'TIME', 'LEVEL'])
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9), child: Text(h, style: p.body(10.5, color: p.textMuted, weight: FontWeight.w700, spacing: 0.6))),
              ]),
              ...items.map((e) {
                final lc = _levelColor(e.level, p);
                return TableRow(decoration: BoxDecoration(border: Border(bottom: BorderSide(color: p.border, width: 0.5))), children: [
                  _tc(p, e.user),
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11), child: Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3), decoration: BoxDecoration(color: p.info.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(4)), child: Text(e.action, style: p.body(10.5, color: p.info, weight: FontWeight.w600)))),
                  _tc(p, e.module),
                  _tc(p, e.detail),
                  _tc(p, '${e.time.hour.toString().padLeft(2, '0')}:${e.time.minute.toString().padLeft(2, '0')}'),
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11), child: Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3), decoration: BoxDecoration(color: lc.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(4)), child: Text(e.level, style: p.body(10.5, color: lc, weight: FontWeight.w600)))),
                ]);
              }),
            ],
          ),
        ])),
      ]),
    ));
  }

  Widget _tc(AppPalette p, String t) => Padding(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11), child: Text(t, style: p.body(12.5), overflow: TextOverflow.ellipsis));
}

// ─── System Logs ──────────────────────────────────────────────────────────────

class _SysLog {
  final String level, component, message;
  final DateTime time;
  const _SysLog({required this.level, required this.component, required this.message, required this.time});
}

class _SystemLogsTab extends StatefulWidget {
  final AppPalette p;
  const _SystemLogsTab({required this.p});
  @override
  State<_SystemLogsTab> createState() => _SystemLogsTabState();
}

class _SystemLogsTabState extends State<_SystemLogsTab> {
  String _filter = 'All';
  final _logs = [
    _SysLog(level: 'INFO', component: 'Database', message: 'Connection established. 24 tables loaded in 142ms.', time: DateTime.now().subtract(const Duration(seconds: 30))),
    _SysLog(level: 'INFO', component: 'Auth', message: 'Session token issued for user Admin (ID: USR-001).', time: DateTime.now().subtract(const Duration(minutes: 2))),
    _SysLog(level: 'WARN', component: 'Storage', message: 'Disk usage at 78%. Consider clearing old backups.', time: DateTime.now().subtract(const Duration(minutes: 15))),
    _SysLog(level: 'INFO', component: 'PDF Service', message: 'Report exported successfully: finance_report_2026-07.pdf', time: DateTime.now().subtract(const Duration(minutes: 32))),
    _SysLog(level: 'ERROR', component: 'SMS Gateway', message: 'Delivery failed for +92-333-5556789: Network timeout.', time: DateTime.now().subtract(const Duration(hours: 1))),
    _SysLog(level: 'INFO', component: 'Scheduler', message: 'Daily backup started at 02:00 AM. Completed in 4.2s.', time: DateTime.now().subtract(const Duration(hours: 6))),
    _SysLog(level: 'INFO', component: 'Inventory', message: 'Low stock alert triggered for 2 products.', time: DateTime.now().subtract(const Duration(hours: 8))),
    _SysLog(level: 'WARN', component: 'Auth', message: 'Multiple failed login attempts from IP 192.168.2.55. Auto-blocked for 15 minutes.', time: DateTime.now().subtract(const Duration(hours: 4))),
    _SysLog(level: 'INFO', component: 'Cache', message: 'Application cache cleared and rebuilt. 0.8s elapsed.', time: DateTime.now().subtract(const Duration(hours: 12))),
    _SysLog(level: 'INFO', component: 'Migrations', message: 'Schema v2026.1.3 applied successfully.', time: DateTime.now().subtract(const Duration(days: 1))),
  ];

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final filtered = _filter == 'All' ? _logs : _logs.where((l) => l.level == _filter).toList();
    return ScrollArea(builder: (sc) => SingleChildScrollView(
      controller: sc,
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        MetricRow([
          MetricCard(title: 'Total Entries', value: '${_logs.length}', delta: 'Today', icon: Icons.list_alt_outlined),
          MetricCard(title: 'Errors', value: '${_logs.where((l) => l.level == "ERROR").length}', delta: 'Need fix', icon: Icons.error_outline),
          MetricCard(title: 'Warnings', value: '${_logs.where((l) => l.level == "WARN").length}', delta: 'Today', icon: Icons.warning_outlined),
          MetricCard(title: 'Uptime', value: '99.8%', delta: 'Last 30 days', icon: Icons.speed_outlined),
        ]),
        const SizedBox(height: 18),
        Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Expanded(child: SectionTitle('SYSTEM EVENT LOGS')),
            ...<String>['All', 'INFO', 'WARN', 'ERROR'].map((f) {
              final sel = _filter == f;
              final col = f == 'ERROR' ? p.danger : f == 'WARN' ? p.warning : p.info;
              return Padding(padding: const EdgeInsets.only(left: 6), child: GestureDetector(onTap: () => setState(() => _filter = f), child: AnimatedContainer(duration: const Duration(milliseconds: 120), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: sel ? col.withValues(alpha: 0.12) : p.surfaceAlt, borderRadius: BorderRadius.circular(6), border: Border.all(color: sel ? col : p.border)), child: Text(f, style: p.body(12, color: sel ? col : p.textMuted, weight: FontWeight.w600)))));
            }),
          ]),
          const SizedBox(height: 14),
          ...filtered.map((l) {
            final lc = l.level == 'ERROR' ? p.danger : l.level == 'WARN' ? p.warning : p.info;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(color: lc.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(8), border: Border.all(color: lc.withValues(alpha: 0.2))),
              child: Row(children: [
                Container(width: 46, alignment: Alignment.center, child: Text(l.level, style: p.body(10.5, color: lc, weight: FontWeight.w700))),
                Container(width: 1, height: 32, color: p.border, margin: const EdgeInsets.symmetric(horizontal: 10)),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('[${l.component}] ${l.message}', style: p.body(12.5)),
                  const SizedBox(height: 2),
                  Text(_ago(l.time), style: p.body(11, color: p.textMuted)),
                ])),
              ]),
            );
          }),
        ])),
      ]),
    ));
  }
}

// ─── Backup Management ────────────────────────────────────────────────────────

class _Backup {
  final String name, size, status;
  final DateTime time;
  const _Backup({required this.name, required this.size, required this.status, required this.time});
}

class _BackupTab extends StatefulWidget {
  final AppPalette p;
  const _BackupTab({required this.p});
  @override
  State<_BackupTab> createState() => _BackupTabState();
}

class _BackupTabState extends State<_BackupTab> {
  bool _isCreating = false;
  final _backups = [
    _Backup(name: 'auto_backup_2026-07-03_02-00', size: '24.7 MB', status: 'Complete', time: DateTime.now().subtract(const Duration(hours: 8))),
    _Backup(name: 'auto_backup_2026-07-02_02-00', size: '24.3 MB', status: 'Complete', time: DateTime.now().subtract(const Duration(days: 1, hours: 8))),
    _Backup(name: 'manual_backup_2026-07-01', size: '24.1 MB', status: 'Complete', time: DateTime.now().subtract(const Duration(days: 2))),
    _Backup(name: 'auto_backup_2026-07-01_02-00', size: '24.1 MB', status: 'Complete', time: DateTime.now().subtract(const Duration(days: 2, hours: 8))),
    _Backup(name: 'auto_backup_2026-06-30_02-00', size: '23.8 MB', status: 'Complete', time: DateTime.now().subtract(const Duration(days: 3, hours: 8))),
    _Backup(name: 'auto_backup_2026-06-29_02-00', size: '23.5 MB', status: 'Failed', time: DateTime.now().subtract(const Duration(days: 4, hours: 8))),
  ];

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    return ScrollArea(builder: (sc) => SingleChildScrollView(
      controller: sc,
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        MetricRow([
          MetricCard(title: 'Last Backup', value: '8h ago', delta: 'Auto daily', icon: Icons.cloud_done_outlined),
          MetricCard(title: 'Total Backups', value: '${_backups.length}', delta: 'Stored locally', icon: Icons.backup_outlined),
          MetricCard(title: 'Storage Used', value: '142 MB', delta: '2.8 GB free', icon: Icons.storage_outlined),
          MetricCard(title: 'Success Rate', value: '94%', delta: 'Last 30 days', icon: Icons.check_circle_outline),
        ]),
        const SizedBox(height: 18),
        LayoutBuilder(builder: (_, c) {
          final wide = c.maxWidth > 800;
          final cfg = _configCard(p);
          final list = _listCard(p);
          if (wide) return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [SizedBox(width: 320, child: cfg), const SizedBox(width: 18), Expanded(child: list)]);
          return Column(children: [cfg, const SizedBox(height: 18), list]);
        }),
      ]),
    ));
  }

  Widget _configCard(AppPalette p) => Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const SectionTitle('BACKUP CONFIGURATION'),
    const SizedBox(height: 16),
    _CfgRow(p: p, icon: Icons.schedule_outlined, label: 'Auto Backup', sub: 'Daily at 02:00 AM', trailing: Switch(value: true, onChanged: (_) {}, activeThumbColor: p.gold, activeTrackColor: p.gold.withValues(alpha: 0.3))),
    const Divider(height: 20),
    _CfgRow(p: p, icon: Icons.folder_outlined, label: 'Backup Location', sub: 'C:/HairAgain/Backups'),
    const Divider(height: 20),
    _CfgRow(p: p, icon: Icons.compress_outlined, label: 'Compression', sub: 'ZIP — Enabled', trailing: Switch(value: true, onChanged: (_) {}, activeThumbColor: p.gold, activeTrackColor: p.gold.withValues(alpha: 0.3))),
    const Divider(height: 20),
    _CfgRow(p: p, icon: Icons.delete_sweep_outlined, label: 'Retention Policy', sub: 'Keep last 30 backups'),
    const SizedBox(height: 20),
    SizedBox(width: double.infinity, child: GoldButton(
      label: _isCreating ? 'Creating Backup...' : 'Create Backup Now',
      icon: _isCreating ? Icons.hourglass_empty : Icons.backup_outlined,
      onTap: () {
        if (_isCreating) return;
        setState(() => _isCreating = true);
        Future.delayed(const Duration(seconds: 2)).then((_) {
          if (mounted) setState(() => _isCreating = false);
        });
      },
    )),
  ]));

  Widget _listCard(AppPalette p) => Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const SectionTitle('BACKUP HISTORY'),
    const SizedBox(height: 12),
    ..._backups.map((b) {
      final ok = b.status == 'Complete';
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(10), border: Border.all(color: p.border)),
        child: Row(children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: (ok ? p.success : p.danger).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)), child: Icon(ok ? Icons.check_circle_outline : Icons.error_outline, color: ok ? p.success : p.danger, size: 18)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(b.name, style: p.body(12.5, weight: FontWeight.w600), overflow: TextOverflow.ellipsis),
            Text('${b.size} · ${_ago(b.time)}', style: p.body(11.5, color: p.textMuted)),
          ])),
          IconButton(icon: Icon(Icons.download_outlined, size: 18, color: p.textMuted), onPressed: () {}, tooltip: 'Download'),
          IconButton(icon: Icon(Icons.delete_outline, size: 18, color: p.danger), onPressed: () {}, tooltip: 'Delete'),
        ]),
      );
    }),
  ]));
}

class _CfgRow extends StatelessWidget {
  final AppPalette p;
  final IconData icon;
  final String label, sub;
  final Widget? trailing;
  const _CfgRow({required this.p, required this.icon, required this.label, required this.sub, this.trailing});
  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, size: 18, color: p.textMuted),
    const SizedBox(width: 12),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: p.body(13, weight: FontWeight.w600)),
      Text(sub, style: p.body(11.5, color: p.textMuted)),
    ])),
    if (trailing != null) trailing!,
  ]);
}

// ─── Restore Data ─────────────────────────────────────────────────────────────

class _RestoreTab extends StatefulWidget {
  final AppPalette p;
  const _RestoreTab({required this.p});
  @override
  State<_RestoreTab> createState() => _RestoreTabState();
}

class _RestoreTabState extends State<_RestoreTab> {
  int? _selected;
  bool _isRestoring = false;

  final _points = [
    _Backup(name: 'auto_backup_2026-07-03_02-00', size: '24.7 MB', status: 'Complete', time: DateTime.now().subtract(const Duration(hours: 8))),
    _Backup(name: 'auto_backup_2026-07-02_02-00', size: '24.3 MB', status: 'Complete', time: DateTime.now().subtract(const Duration(days: 1, hours: 8))),
    _Backup(name: 'manual_backup_2026-07-01', size: '24.1 MB', status: 'Complete', time: DateTime.now().subtract(const Duration(days: 2))),
    _Backup(name: 'auto_backup_2026-07-01_02-00', size: '24.1 MB', status: 'Complete', time: DateTime.now().subtract(const Duration(days: 2, hours: 8))),
    _Backup(name: 'auto_backup_2026-06-30_02-00', size: '23.8 MB', status: 'Complete', time: DateTime.now().subtract(const Duration(days: 3, hours: 8))),
  ];

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    return ScrollArea(builder: (sc) => SingleChildScrollView(
      controller: sc,
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: p.warning.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10), border: Border.all(color: p.warning.withValues(alpha: 0.3))), child: Row(children: [
          Icon(Icons.warning_amber_outlined, color: p.warning, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text('Restoring will replace ALL current data with the selected backup. This action cannot be undone. Ensure you have a current backup before proceeding.', style: p.body(13, color: p.warning))),
        ])),
        const SizedBox(height: 18),
        Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SectionTitle('SELECT RESTORE POINT'),
          const SizedBox(height: 14),
          ..._points.asMap().entries.map((e) {
            final sel = _selected == e.key;
            return GestureDetector(
              onTap: () => setState(() => _selected = e.key),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: sel ? p.gold.withValues(alpha: 0.08) : p.surfaceAlt, borderRadius: BorderRadius.circular(10), border: Border.all(color: sel ? p.gold : p.border, width: sel ? 1.5 : 1)),
                child: Row(children: [
                  Icon(sel ? Icons.radio_button_checked : Icons.radio_button_unchecked, color: sel ? p.gold : p.textMuted, size: 18),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(e.value.name, style: p.body(13, weight: FontWeight.w600, color: sel ? p.text : p.text)),
                    Text('${e.value.size} · ${_ago(e.value.time)}', style: p.body(11.5, color: p.textMuted)),
                  ])),
                  if (e.key == 0) Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: p.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)), child: Text('Latest', style: p.body(10.5, color: p.success, weight: FontWeight.w600))),
                ]),
              ),
            );
          }),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: OutlinedButton.icon(onPressed: () => setState(() => _selected = null), icon: const Icon(Icons.clear, size: 16), label: const Text('Clear Selection'), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)))),
            const SizedBox(width: 12),
            Expanded(child: GoldButton(
              label: _isRestoring ? 'Restoring...' : 'Restore Selected Backup',
              icon: _isRestoring ? Icons.hourglass_empty : Icons.restore_outlined,
              onTap: () {
                if (_selected == null || _isRestoring) return;
                setState(() => _isRestoring = true);
                Future.delayed(const Duration(seconds: 3)).then((_) {
                  if (mounted) { setState(() => _isRestoring = false); toast(context, 'Restore complete'); }
                });
              },
            )),
          ]),
        ])),
      ]),
    ));
  }
}

// ─── API Keys ─────────────────────────────────────────────────────────────────

class _ApiKey {
  final String name, key, scope, createdBy;
  final DateTime created;
  bool active;
  _ApiKey({required this.name, required this.key, required this.scope, required this.createdBy, required this.created, required this.active});
}

class _ApiKeysTab extends StatefulWidget {
  final AppPalette p;
  const _ApiKeysTab({required this.p});
  @override
  State<_ApiKeysTab> createState() => _ApiKeysTabState();
}

class _ApiKeysTabState extends State<_ApiKeysTab> {
  final _keys = [
    _ApiKey(name: 'Mobile App Access', key: 'ha_live_sk_a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6', scope: 'Read / Write', createdBy: 'Admin', created: DateTime(2026, 1, 15), active: true),
    _ApiKey(name: 'WhatsApp Integration', key: 'ha_live_sk_q7r8s9t0u1v2w3x4y5z6a7b8c9d0e1f2', scope: 'Notifications', createdBy: 'Admin', created: DateTime(2026, 3, 1), active: true),
    _ApiKey(name: 'SMS Gateway', key: 'ha_live_sk_g3h4i5j6k7l8m9n0o1p2q3r4s5t6u7v8', scope: 'SMS Only', createdBy: 'Admin', created: DateTime(2026, 5, 20), active: true),
    _ApiKey(name: 'Reporting Tool', key: 'ha_test_sk_w9x0y1z2a3b4c5d6e7f8g9h0i1j2k3l4', scope: 'Read Only', createdBy: 'Dr. Rehman', created: DateTime(2026, 2, 10), active: false),
  ];

  Set<int> _visible = {};

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    return ScrollArea(builder: (sc) => SingleChildScrollView(
      controller: sc,
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        MetricRow([
          MetricCard(title: 'Total Keys', value: '${_keys.length}', delta: 'All environments', icon: Icons.vpn_key_outlined),
          MetricCard(title: 'Active', value: '${_keys.where((k) => k.active).length}', delta: 'In use', icon: Icons.check_circle_outline),
          MetricCard(title: 'Revoked', value: '${_keys.where((k) => !k.active).length}', delta: 'Disabled', icon: Icons.block_outlined),
          MetricCard(title: 'Last Used', value: '2m ago', delta: 'Mobile App', icon: Icons.access_time_outlined),
        ]),
        const SizedBox(height: 18),
        Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Expanded(child: SectionTitle('API KEY MANAGEMENT')),
            GoldButton(label: 'Generate Key', icon: Icons.add, onTap: () => toast(context, 'API key generated')),
          ]),
          const SizedBox(height: 14),
          ..._keys.asMap().entries.map((e) {
            final k = e.value;
            final show = _visible.contains(e.key);
            final masked = '${k.key.substring(0, 12)}${'•' * 20}${k.key.substring(k.key.length - 4)}';
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(10), border: Border.all(color: k.active ? p.border : p.danger.withValues(alpha: 0.3))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Icon(Icons.vpn_key_outlined, size: 16, color: k.active ? p.gold : p.textMuted),
                  const SizedBox(width: 8),
                  Expanded(child: Text(k.name, style: p.body(13, weight: FontWeight.w700))),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: (k.active ? p.success : p.danger).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)), child: Text(k.active ? 'Active' : 'Revoked', style: p.body(11, color: k.active ? p.success : p.danger, weight: FontWeight.w600))),
                  const SizedBox(width: 8),
                  Switch(value: k.active, onChanged: (v) => setState(() => k.active = v), activeThumbColor: p.gold, activeTrackColor: p.gold.withValues(alpha: 0.3)),
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(6), border: Border.all(color: p.border)), child: Text(show ? k.key : masked, style: p.body(12, color: p.textMuted), overflow: TextOverflow.ellipsis))),
                  const SizedBox(width: 8),
                  IconButton(icon: Icon(show ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 16), color: p.textMuted, onPressed: () => setState(() { if (show) _visible.remove(e.key); else _visible.add(e.key); })),
                  IconButton(icon: Icon(Icons.copy_outlined, size: 16), color: p.textMuted, onPressed: () => toast(context, 'Key copied'), tooltip: 'Copy'),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  _kv(p, 'Scope', k.scope),
                  const SizedBox(width: 20),
                  _kv(p, 'Created by', k.createdBy),
                  const SizedBox(width: 20),
                  _kv(p, 'Created', '${k.created.day}/${k.created.month}/${k.created.year}'),
                ]),
              ]),
            );
          }),
        ])),
      ]),
    ));
  }

  Widget _kv(AppPalette p, String k, String v) => Row(mainAxisSize: MainAxisSize.min, children: [Text('$k: ', style: p.body(11.5, color: p.textMuted)), Text(v, style: p.body(11.5, weight: FontWeight.w600))]);
}

// ─── Session Management ───────────────────────────────────────────────────────

class _Session {
  final String user, device, ip, location;
  final DateTime loginTime;
  final bool isCurrent;
  const _Session({required this.user, required this.device, required this.ip, required this.location, required this.loginTime, required this.isCurrent});
}

class _SessionsTab extends StatefulWidget {
  final AppPalette p;
  const _SessionsTab({required this.p});
  @override
  State<_SessionsTab> createState() => _SessionsTabState();
}

class _SessionsTabState extends State<_SessionsTab> {
  late final List<_Session> _sessions;

  @override
  void initState() {
    super.initState();
    _sessions = [
      _Session(user: 'Admin', device: 'Windows Desktop', ip: '192.168.1.10', location: 'Reception', loginTime: DateTime.now().subtract(const Duration(hours: 2)), isCurrent: true),
      _Session(user: 'Dr. Sara Iqbal', device: 'Windows Laptop', ip: '192.168.1.15', location: 'Consultation Room 1', loginTime: DateTime.now().subtract(const Duration(hours: 1, minutes: 20)), isCurrent: false),
      _Session(user: 'Sana Butt', device: 'Windows Desktop', ip: '192.168.1.20', location: 'Front Desk', loginTime: DateTime.now().subtract(const Duration(minutes: 45)), isCurrent: false),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    return ScrollArea(builder: (sc) => SingleChildScrollView(
      controller: sc,
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        MetricRow([
          MetricCard(title: 'Active Sessions', value: '${_sessions.length}', delta: 'Right now', icon: Icons.people_outlined),
          MetricCard(title: 'Devices', value: '${_sessions.length}', delta: 'Connected', icon: Icons.devices_outlined),
          MetricCard(title: 'Locations', value: '3', delta: 'Clinic network', icon: Icons.location_on_outlined),
          MetricCard(title: 'Session Timeout', value: '30 min', delta: 'Inactivity', icon: Icons.timer_outlined),
        ]),
        const SizedBox(height: 18),
        Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Expanded(child: SectionTitle('ACTIVE SESSIONS')),
            OutlinedButton.icon(onPressed: () { setState(() => _sessions.removeWhere((s) => !s.isCurrent)); toast(context, 'All other sessions terminated'); }, icon: Icon(Icons.logout, size: 16, color: p.danger), label: Text('Terminate All Others', style: p.body(12.5, color: p.danger))),
          ]),
          const SizedBox(height: 14),
          ..._sessions.map((s) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: s.isCurrent ? p.gold.withValues(alpha: 0.05) : p.surfaceAlt, borderRadius: BorderRadius.circular(10), border: Border.all(color: s.isCurrent ? p.gold.withValues(alpha: 0.3) : p.border)),
            child: Row(children: [
              Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: (s.isCurrent ? p.gold : p.textMuted).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)), child: Icon(Icons.computer_outlined, color: s.isCurrent ? p.gold : p.textMuted, size: 22)),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(s.user, style: p.body(14, weight: FontWeight.w700)),
                  const SizedBox(width: 8),
                  if (s.isCurrent) Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: p.gold.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(4)), child: Text('Current', style: p.body(11, color: p.gold, weight: FontWeight.w600))),
                ]),
                const SizedBox(height: 4),
                Text('${s.device} · ${s.ip} · ${s.location}', style: p.body(12, color: p.textMuted)),
                Text('Logged in ${_ago(s.loginTime)}', style: p.body(11.5, color: p.textMuted)),
              ])),
              if (!s.isCurrent) TextButton.icon(
                onPressed: () { setState(() => _sessions.remove(s)); toast(context, 'Session terminated'); },
                icon: Icon(Icons.logout, size: 15, color: p.danger),
                label: Text('Terminate', style: p.body(12.5, color: p.danger)),
              ),
            ]),
          )),
        ])),
        const SizedBox(height: 18),
        Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SectionTitle('SESSION SETTINGS'),
          const SizedBox(height: 14),
          _CfgRow(p: p, icon: Icons.timer_outlined, label: 'Auto Logout Timeout', sub: '30 minutes of inactivity', trailing: Switch(value: true, onChanged: (_) {}, activeThumbColor: p.gold, activeTrackColor: p.gold.withValues(alpha: 0.3))),
          const Divider(height: 20),
          _CfgRow(p: p, icon: Icons.devices_outlined, label: 'Allow Multiple Sessions', sub: 'Same user on different devices', trailing: Switch(value: true, onChanged: (_) {}, activeThumbColor: p.gold, activeTrackColor: p.gold.withValues(alpha: 0.3))),
          const Divider(height: 20),
          _CfgRow(p: p, icon: Icons.lock_outlined, label: 'Force Re-login on IP Change', sub: 'Security: detect network changes', trailing: Switch(value: false, onChanged: (_) {}, activeThumbColor: p.gold, activeTrackColor: p.gold.withValues(alpha: 0.3))),
        ])),
      ]),
    ));
  }
}

String _ago(DateTime t) {
  final diff = DateTime.now().difference(t);
  if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  return '${diff.inDays}d ago';
}
