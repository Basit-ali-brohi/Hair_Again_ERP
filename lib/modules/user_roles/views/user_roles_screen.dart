import 'package:flutter/material.dart';

import '../../../core/core.dart';
import '../../auth/models/auth_models.dart';

class UserRolesScreen extends StatefulWidget {
  const UserRolesScreen({super.key});
  @override
  State<UserRolesScreen> createState() => _UserRolesScreenState();
}

class _UserRolesScreenState extends State<UserRolesScreen> with SingleTickerProviderStateMixin {
  late final TabController _tab;
  @override
  void initState() { super.initState(); _tab = TabController(length: 4, vsync: this); }
  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    return ScreenScaffold(
      title: 'USERS & ROLES',
      subtitle: 'System users, roles, permissions, activity logs & login history',
      actions: [
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
            tabs: const [Tab(text: 'System Users'), Tab(text: 'Roles & Permissions'), Tab(text: 'Activity Logs'), Tab(text: 'Login History')],
          ),
        ),
      ],
      child: EagerTabBarView(controller: _tab, children: [
        _UsersTab(onUpdate: () => setState(() {})),
        const _RolesTab(),
        const _ActivityTab(),
        const _LoginHistoryTab(),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SYSTEM USERS TAB
// ══════════════════════════════════════════════════════════════════════════════
class _UsersTab extends StatefulWidget {
  final VoidCallback onUpdate;
  const _UsersTab({required this.onUpdate});
  @override
  State<_UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends State<_UsersTab> {
  String _q = '';

  List<AppUser> get _filtered {
    if (_q.isEmpty) return appState.systemUsers;
    final q = _q.toLowerCase();
    return appState.systemUsers.where((u) => u.name.toLowerCase().contains(q) || u.email.toLowerCase().contains(q) || u.role.label.toLowerCase().contains(q)).toList();
  }

  void _addUser() {
    final p = appState.palette;
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    var role = UserRole.receptionist;
    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, ss) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 560, padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: p.border)),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('ADD SYSTEM USER', style: p.display(22, spacing: 1.0)),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: FormField2(label: 'Full Name *', controller: nameCtrl, hint: 'e.g. Umer Farooq')),
            const SizedBox(width: 16),
            Expanded(child: FormField2(label: 'Email *', controller: emailCtrl, hint: 'user@hairagain.pk', keyboard: TextInputType.emailAddress)),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: FormField2(label: 'Password *', controller: passCtrl, hint: '••••••••', obscure: true)),
            const SizedBox(width: 16),
            Expanded(child: FormField2(label: 'Phone', controller: phoneCtrl, hint: '+92 3XX XXXXXXX', keyboard: TextInputType.phone)),
          ]),
          const SizedBox(height: 16),
          Dropdown2<UserRole>(label: 'Role *', value: role, items: UserRole.values.map((r) => DropdownMenuItem(value: r, child: Text(r.label))).toList(), onChanged: (v) => ss(() => role = v ?? role)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(8)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('ACCESS PREVIEW', style: p.body(10.5, color: p.textMuted, weight: FontWeight.w700, spacing: 1.0)),
              const SizedBox(height: 8),
              Wrap(spacing: 6, runSpacing: 6, children: [
                ...['Dashboard','HR','Leads','Finance','Marketing','Consultation','Users','Company','Appointments','Treatment','Inventory','POS'].asMap().entries.map((e) {
                  final hasAccess = role == UserRole.superAdmin || role == UserRole.owner || (role.accessibleIndices.contains(e.key));
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: (hasAccess ? p.success : p.danger).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6), border: Border.all(color: (hasAccess ? p.success : p.danger).withValues(alpha: 0.3))),
                    child: Text(e.value, style: p.body(10.5, color: hasAccess ? p.success : p.danger)),
                  );
                }),
              ]),
            ]),
          ),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            GhostButton(label: 'Cancel', onTap: () => Navigator.pop(ctx)),
            const SizedBox(width: 12),
            GoldButton(label: 'Create User', onTap: () {
              if (nameCtrl.text.isEmpty || emailCtrl.text.isEmpty || passCtrl.text.isEmpty) return;
              appState.systemUsers.add(AppUser(id: 'USR-${appState.systemUsers.length + 1}', name: nameCtrl.text, email: emailCtrl.text, password: passCtrl.text, phone: phoneCtrl.text, role: role, isActive: true, createdAt: DateTime.now()));
              Navigator.pop(ctx); setState(() {}); widget.onUpdate();
            }),
          ]),
        ]),
      ),
    )));
  }

  void _editUser(AppUser u) {
    final p = appState.palette;
    var role = u.role;
    var active = u.isActive;
    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, ss) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 480, padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: p.border)),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('EDIT USER', style: p.display(22, spacing: 1.0)),
          const SizedBox(height: 6),
          Text(u.name, style: p.body(15, weight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(u.email, style: p.body(12.5, color: p.textMuted)),
          const SizedBox(height: 20),
          Dropdown2<UserRole>(label: 'Role', value: role, items: UserRole.values.map((r) => DropdownMenuItem(value: r, child: Text(r.label))).toList(), onChanged: (v) => ss(() => role = v ?? role)),
          const SizedBox(height: 16),
          Row(children: [
            Text('Account Status', style: p.body(12.5, color: p.textMuted, weight: FontWeight.w600)),
            const Spacer(),
            Switch(value: active, onChanged: (v) => ss(() => active = v), activeColor: p.gold),
            const SizedBox(width: 8),
            Text(active ? 'Active' : 'Inactive', style: p.body(13, color: active ? p.success : p.textMuted, weight: FontWeight.w600)),
          ]),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            GhostButton(label: 'Cancel', onTap: () => Navigator.pop(ctx)),
            const SizedBox(width: 12),
            GoldButton(label: 'Save Changes', onTap: () { u.role = role; u.isActive = active; appState.touch(); Navigator.pop(ctx); setState(() {}); }),
          ]),
        ]),
      ),
    )));
  }

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final list = _filtered;
    return Column(children: [
      FilterBar(searchHint: 'Search by name, email or role…', onSearch: (v) => setState(() => _q = v), filters: const [], countText: '${list.length} users', trailing: [GoldButton(label: 'Add User', icon: Icons.person_add_outlined, onTap: _addUser)]),
      const SizedBox(height: 12),
      Expanded(child: ScrollArea(builder: (sc) => SingleChildScrollView(controller: sc, child: Wrap(spacing: 16, runSpacing: 16, children: list.map((u) => SizedBox(width: 360, child: Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(radius: 24, backgroundColor: p.gold.withValues(alpha: 0.15), child: Text(u.initials, style: p.body(14, color: p.gold, weight: FontWeight.w700))),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(u.name, style: p.body(14, weight: FontWeight.w700)),
              const Spacer(),
              StatusChip(label: u.isActive ? 'Active' : 'Inactive', color: u.isActive ? p.success : p.danger),
            ]),
            Text(u.email, style: p.body(12, color: p.textMuted)),
            if (u.phone.isNotEmpty) Text(u.phone, style: p.body(12, color: p.textMuted)),
          ])),
        ]),
        const SizedBox(height: 14),
        Divider(height: 1, color: p.border),
        const SizedBox(height: 14),
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: p.gold.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6), border: Border.all(color: p.gold.withValues(alpha: 0.3))),
            child: Text(u.role.label, style: p.body(12, color: p.gold, weight: FontWeight.w700)),
          ),
          const Spacer(),
          if (u.lastLogin != null) Row(children: [
            Icon(Icons.login_outlined, size: 13, color: p.textMuted),
            const SizedBox(width: 4),
            Text(prettyShort(u.lastLogin!), style: p.body(11.5, color: p.textMuted)),
          ]),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          GhostButton(label: 'Edit', icon: Icons.edit_outlined, onTap: () => _editUser(u)),
          const Spacer(),
          if (u.id != appState.currentUser?.id)
            GhostButton(label: u.isActive ? 'Suspend' : 'Reinstate', onTap: () { u.isActive = !u.isActive; appState.touch(); setState(() {}); }),
        ]),
      ])))).toList())))),
    ]);
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// ROLES & PERMISSIONS TAB
// ══════════════════════════════════════════════════════════════════════════════
class _RolesTab extends StatelessWidget {
  const _RolesTab();

  static const _modules = [
    'Dashboard', 'Company', 'Customers', 'HR', 'Leads', 'Appointments',
    'Consultation', 'Treatment', 'Hair Patch', 'Finance', 'Marketing',
    'Inventory', 'Vendors', 'POS', 'Reports', 'Users & Roles',
  ];

  bool _hasAccess(UserRole r, int moduleIndex) {
    if (r == UserRole.superAdmin || r == UserRole.owner) return true;
    return r.accessibleIndices.contains(moduleIndex);
  }

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final roles = UserRole.values;
    return Panel(padding: EdgeInsets.zero, child: ScrollArea(builder: (sc) => SingleChildScrollView(controller: sc, child: FullWidthDataTable(child: DataTable(
        headingRowColor: WidgetStateProperty.all(p.surfaceAlt),
        columnSpacing: 0, horizontalMargin: 20,
        columns: [
          DataColumn(label: SizedBox(width: 160, child: Text('Module', style: p.body(12, weight: FontWeight.w700)))),
          ...roles.map((r) => DataColumn(label: SizedBox(
            width: 100, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(r.initials, style: p.body(11, color: p.gold, weight: FontWeight.w700)),
              Text(r.label.split(' ').first, style: p.body(9.5, color: p.textMuted), textAlign: TextAlign.center),
            ]),
          ))),
        ],
        rows: _modules.asMap().entries.map((entry) {
          final i = entry.key;
          final module = entry.value;
          return DataRow(cells: [
            DataCell(Text(module, style: p.body(13, weight: FontWeight.w500))),
            ...roles.map((r) {
              final has = _hasAccess(r, i);
              return DataCell(Center(child: Icon(has ? Icons.check_circle_outline : Icons.remove, size: 18, color: has ? p.success : p.border)));
            }),
          ]);
        }).toList(),
      ),
    ))));
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// ACTIVITY LOGS TAB
// ══════════════════════════════════════════════════════════════════════════════
class _ActivityTab extends StatelessWidget {
  const _ActivityTab();
  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final logs = appState.activityLogs.reversed.toList();
    return logs.isEmpty
      ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.history_outlined, size: 56, color: p.textMuted),
          const SizedBox(height: 12),
          Text('No activity logs yet', style: p.body(14, color: p.textMuted)),
        ]))
      : Panel(padding: EdgeInsets.zero, child: ScrollArea(builder: (sc) => ListView.builder(
        controller: sc, itemCount: logs.length, itemBuilder: (_, i) {
          final log = logs[i];
          final moduleColor = _moduleColor(log.module, p);
          return Padding(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), child: Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: moduleColor.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(_actionIcon(log.action), size: 16, color: moduleColor),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(log.userName, style: p.body(13.5, weight: FontWeight.w600)),
                const SizedBox(width: 8),
                StatusChip(label: log.userRole.label, color: p.textMuted),
              ]),
              const SizedBox(height: 3),
              RichText(text: TextSpan(children: [
                TextSpan(text: log.action, style: p.body(12.5, color: p.text).copyWith(fontWeight: FontWeight.w500)),
                TextSpan(text: ' in ', style: p.body(12.5, color: p.textMuted)),
                TextSpan(text: log.module, style: p.body(12.5, color: moduleColor, weight: FontWeight.w600)),
                if (log.detail != null) TextSpan(text: ' — ${log.detail}', style: p.body(12.5, color: p.textMuted)),
              ])),
            ])),
            Text(prettyShort(log.timestamp), style: p.body(11.5, color: p.textMuted)),
          ]));
        })));
  }

  Color _moduleColor(String module, AppPalette p) => switch (module.toLowerCase()) {
    'auth' || 'login' => p.gold, 'hr' => p.info, 'finance' => p.success,
    'leads' => p.warning, 'marketing' => const Color(0xFF9B59B6), _ => p.textMuted,
  };
  IconData _actionIcon(String action) => switch (action.toLowerCase()) {
    final s when s.contains('login') => Icons.login_outlined,
    final s when s.contains('created') || s.contains('add') => Icons.add_circle_outline,
    final s when s.contains('updated') || s.contains('edit') => Icons.edit_outlined,
    final s when s.contains('deleted') || s.contains('remove') => Icons.delete_outline,
    final s when s.contains('approved') => Icons.check_circle_outline,
    final s when s.contains('rejected') => Icons.cancel_outlined,
    _ => Icons.info_outline,
  };
}

// ══════════════════════════════════════════════════════════════════════════════
// LOGIN HISTORY TAB
// ══════════════════════════════════════════════════════════════════════════════
class _LoginHistoryTab extends StatelessWidget {
  const _LoginHistoryTab();
  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final history = appState.loginHistory.reversed.toList();
    return Panel(padding: EdgeInsets.zero, child: ScrollArea(builder: (sc) => SingleChildScrollView(controller: sc, child: FullWidthDataTable(child: DataTable(
      headingRowColor: WidgetStateProperty.all(p.surfaceAlt),
      columnSpacing: 16, horizontalMargin: 20,
      columns: [
        DataColumn(label: Text('User', style: p.body(12, weight: FontWeight.w700))),
        DataColumn(label: Text('Role', style: p.body(12, weight: FontWeight.w700))),
        DataColumn(label: Text('Login Time', style: p.body(12, weight: FontWeight.w700))),
        DataColumn(label: Text('Logout Time', style: p.body(12, weight: FontWeight.w700))),
        DataColumn(label: Text('Duration', style: p.body(12, weight: FontWeight.w700))),
        DataColumn(label: Text('Device', style: p.body(12, weight: FontWeight.w700))),
        DataColumn(label: Text('IP Address', style: p.body(12, weight: FontWeight.w700))),
        DataColumn(label: Text('Status', style: p.body(12, weight: FontWeight.w700))),
      ],
      rows: history.map((h) => DataRow(cells: [
        DataCell(Row(children: [
          CircleAvatar(radius: 14, backgroundColor: p.gold.withValues(alpha: 0.15), child: Text(h.userName.substring(0, 1), style: p.body(10, color: p.gold, weight: FontWeight.w700))),
          const SizedBox(width: 8),
          Text(h.userName, style: p.body(13, weight: FontWeight.w600)),
        ])),
        DataCell(StatusChip(label: h.role.label, color: p.info)),
        DataCell(Text(prettyShort(h.loginTime), style: p.body(12.5))),
        DataCell(Text(h.logoutTime != null ? prettyShort(h.logoutTime!) : '—', style: p.body(12.5, color: p.textMuted))),
        DataCell(Text(h.duration, style: p.body(12.5))),
        DataCell(Text(h.device, style: p.body(12.5, color: p.textMuted))),
        DataCell(Text(h.ipAddress, style: p.body(12, color: p.textMuted))),
        DataCell(StatusChip(label: h.success ? 'Success' : 'Failed', color: h.success ? p.success : p.danger)),
      ])).toList(),
    )))));
  }
}
