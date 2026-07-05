import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core.dart';
import '../../modules/auth/models/auth_models.dart';
import '../../modules/crm/models/patient.dart';
import '../../modules/pos_inventory/models/pos_models.dart';
import '../../modules/dashboard/views/dashboard_screen.dart';
import '../../modules/crm/views/crm_screen.dart';
import '../../modules/pos_inventory/views/pos_screen.dart';
import '../../modules/appointments/views/appointments_screen.dart';
import '../../modules/reports/views/reports_screen.dart';
import '../../modules/settings/views/settings_screen.dart';
import '../../modules/invoices/views/invoices_screen.dart';
import '../../modules/staff/views/staff_screen.dart';
import '../../modules/hr/views/hr_screen.dart';
import '../../modules/leads/views/leads_screen.dart';
import '../../modules/consultation/views/consultation_screen.dart';
import '../../modules/finance/views/finance_screen.dart';
import '../../modules/marketing/views/marketing_screen.dart';
import '../../modules/user_roles/views/user_roles_screen.dart';
import '../../modules/company/views/company_screen.dart';
import '../../modules/treatment/views/treatment_screen.dart';
import '../../modules/transplant/views/transplant_screen.dart';
import '../../modules/membership/views/membership_screen.dart';
import '../../modules/loyalty/views/loyalty_screen.dart';
import '../../modules/vendors/views/vendors_screen.dart';
import '../../modules/products/views/products_screen.dart';
import '../../modules/hair_patch/views/hair_patch_screen.dart';
import '../../modules/inventory/views/inventory_screen.dart';
import '../../modules/notifications/views/notifications_screen.dart';
import '../../modules/security/views/security_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Constants
// ─────────────────────────────────────────────────────────────────────────────
const _kRail = 64.0;
const _kNav  = 214.0;
const _kRailBg = Color(0xFF2A1E00);

List<BoxShadow> get _shadow => [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 20, offset: const Offset(0, 6))];

// ─────────────────────────────────────────────────────────────────────────────
// Nav data
// ─────────────────────────────────────────────────────────────────────────────
class _Group {
  final IconData icon;
  final String label;
  final List<int> indices;
  const _Group(this.icon, this.label, this.indices);
}

const _kGroups = [
  _Group(Icons.home_rounded,                   'Overview',   [0]),
  _Group(Icons.groups_outlined,                'Patients',   [1, 3, 10]),
  _Group(Icons.medical_services_outlined,      'Clinical',   [15, 16, 21]),
  _Group(Icons.shopping_bag_outlined,          'Commerce',   [2, 6, 17, 18]),
  _Group(Icons.account_balance_outlined,       'Finance',    [11, 4]),
  _Group(Icons.badge_outlined,                 'Staff & HR', [7, 8]),
  _Group(Icons.trending_up_rounded,            'Growth',     [9, 12]),
  _Group(Icons.inventory_2_outlined,           'Inventory',  [19, 20, 22]),
  _Group(Icons.admin_panel_settings_outlined,  'Admin',      [5, 13, 14]),
  _Group(Icons.notifications_outlined,          'Comms & Sec', [23, 24]),
];

const _kModLabel = {
  0:  (icon: Icons.home_outlined,                label: 'Dashboard'),
  1:  (icon: Icons.groups_outlined,              label: 'CRM & Patients'),
  2:  (icon: Icons.point_of_sale_outlined,       label: 'POS & Inventory'),
  3:  (icon: Icons.calendar_month_outlined,      label: 'Appointments'),
  4:  (icon: Icons.insights_outlined,            label: 'Reports'),
  5:  (icon: Icons.tune_outlined,                label: 'Settings'),
  6:  (icon: Icons.receipt_long_outlined,        label: 'Invoices'),
  7:  (icon: Icons.badge_outlined,               label: 'Staff & Doctors'),
  8:  (icon: Icons.people_outlined,              label: 'HR & Payroll'),
  9:  (icon: Icons.leaderboard_outlined,         label: 'Lead Management'),
  10: (icon: Icons.medical_services_outlined,    label: 'Consultation'),
  11: (icon: Icons.payments_outlined,            label: 'Finance'),
  12: (icon: Icons.campaign_outlined,            label: 'Marketing'),
  13: (icon: Icons.shield_outlined,              label: 'Users & Roles'),
  14: (icon: Icons.business_outlined,            label: 'Company Setup'),
  15: (icon: Icons.spa_outlined,                 label: 'Treatment Plans'),
  16: (icon: Icons.content_cut_outlined,         label: 'Hair Transplant'),
  17: (icon: Icons.card_membership_outlined,     label: 'Membership'),
  18: (icon: Icons.stars_outlined,               label: 'Loyalty & Rewards'),
  19: (icon: Icons.storefront_outlined,          label: 'Vendors'),
  20: (icon: Icons.inventory_outlined,           label: 'Products'),
  21: (icon: Icons.face_outlined,               label: 'Hair Patch'),
  22: (icon: Icons.warehouse_outlined,          label: 'Stock Management'),
  23: (icon: Icons.notifications_outlined,      label: 'Notifications'),
  24: (icon: Icons.security_outlined,           label: 'Security Center'),
};

// ─────────────────────────────────────────────────────────────────────────────
// Shell
// ─────────────────────────────────────────────────────────────────────────────
class Shell extends StatefulWidget {
  const Shell({super.key});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int _group = 0;

  final _crmKey      = GlobalKey<CrmScreenState>();
  final _posKey      = GlobalKey<PosScreenState>();
  final _apptKey     = GlobalKey<AppointmentsScreenState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  int _groupFor(int idx) {
    for (int i = 0; i < _kGroups.length; i++) {
      if (_kGroups[i].indices.contains(idx)) return i;
    }
    return 0;
  }

  void _registerPatient() {
    appState.go(1);
    WidgetsBinding.instance.addPostFrameCallback((_) => _crmKey.currentState?.openAddPatient());
  }

  void _bookAppointment() {
    appState.go(3);
    WidgetsBinding.instance.addPostFrameCallback((_) => _apptKey.currentState?.openAddAppointment());
  }

  void _createInvoice() {
    appState.go(2);
    WidgetsBinding.instance.addPostFrameCallback((_) => _posKey.currentState?.focusBilling());
  }

  void _lowStock() {
    appState.go(2);
    WidgetsBinding.instance.addPostFrameCallback((_) => _posKey.currentState?.showLowStock());
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final p = state.palette;
    final idx = state.activeIndex;
    final accessible = state.currentUser?.role.accessibleIndices ?? <int>{0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24};

    // auto-sync group when module navigated externally
    final computed = _groupFor(idx);
    if (_group != computed) _group = computed;

    final isMobile = defaultTargetPlatform == TargetPlatform.android ||
                      defaultTargetPlatform == TargetPlatform.iOS;
    if (isMobile) {
      return _buildMobile(context, p, idx, accessible);
    }

    return Material(
      color: p.bg,
      child: SafeArea(
        child: Row(
          children: [
          // ── Icon Rail ──────────────────────────────────────────────
          _IconRail(
            group: _group,
            accessible: accessible,
            state: state,
            onGroupTap: (g) {
              final first = _kGroups[g].indices.firstWhere((i) => accessible.contains(i), orElse: () => -1);
              if (first >= 0) {
                setState(() => _group = g);
                appState.go(first);
              }
            },
          ),

          // ── Nav Panel ──────────────────────────────────────────────
          _NavPanel(
            group: _group,
            activeIndex: idx,
            accessible: accessible,
            state: state,
          ),

          // ── Main Content ───────────────────────────────────────────
          Expanded(
            child: Column(
              children: [
                _TopBar(
                  group: _group,
                  activeIndex: idx,
                  onSelectPatient: (pt) {
                    appState.go(1);
                    WidgetsBinding.instance.addPostFrameCallback((_) => _crmKey.currentState?.selectPatient(pt));
                  },
                ),
                Expanded(
                  child: _buildActiveScreen(idx),
                ),
              ],
            ),
          ),
        ],
        ),
      ),
    );

  }

  Widget _buildActiveScreen(int idx) {
    return switch (idx) {
      0  => DashboardScreen(onRegisterPatient: _registerPatient, onBookAppointment: _bookAppointment, onCreateInvoice: _createInvoice, onLowStock: _lowStock),
      1  => CrmScreen(key: _crmKey),
      2  => PosScreen(key: _posKey),
      3  => AppointmentsScreen(key: _apptKey),
      4  => const ReportsScreen(),
      5  => const SettingsScreen(),
      6  => const InvoicesScreen(),
      7  => const StaffScreen(),
      8  => const HrScreen(),
      9  => const LeadsScreen(),
      10 => const ConsultationScreen(),
      11 => const FinanceScreen(),
      12 => const MarketingScreen(),
      13 => const UserRolesScreen(),
      14 => const CompanyScreen(),
      15 => const TreatmentScreen(),
      16 => const TransplantScreen(),
      17 => const MembershipScreen(),
      18 => const LoyaltyScreen(),
      19 => const VendorsScreen(),
      20 => const ProductsScreen(),
      21 => const HairPatchScreen(),
      22 => const InventoryScreen(),
      23 => const NotificationsScreen(),
      24 => const SecurityScreen(),
      _  => const SizedBox.shrink(),
    };
  }

  Widget _buildMobile(BuildContext context, AppPalette p, int idx, Set<int> accessible) {
    final group = _kGroups[_group];
    final mod   = _kModLabel[idx];

    final int bottomTab = switch (idx) {
      0 => 0, 3 => 1, 1 => 2, 2 => 3, _ => 4,
    };

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: p.bg,
      floatingActionButton: null,
      floatingActionButtonLocation: null,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Container(
          color: p.sidebar,
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              height: 56,
              child: Row(children: [
                const SizedBox(width: 4),
                IconButton(
                  icon: Icon(Icons.menu_rounded, color: p.text),
                  onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(mod?.label ?? 'Dashboard',
                          style: p.body(14, weight: FontWeight.w700),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text(group.label, style: p.body(10.5, color: p.textMuted)),
                    ],
                  ),
                ),
                Stack(clipBehavior: Clip.none, children: [
                  IconButton(
                    icon: Icon(Icons.notifications_none_rounded, color: p.text),
                    onPressed: () => appState.go(23),
                  ),
                  if (appState.unreadCount > 0) Positioned(
                    right: 8, top: 8,
                    child: Container(
                      width: 8, height: 8,
                      decoration: BoxDecoration(color: p.danger, shape: BoxShape.circle),
                    ),
                  ),
                ]),
                const ThemeToggle(),
                const SizedBox(width: 4),
              ]),
            ),
          ),
        ),
      ),
      drawer: _MobileDrawer(activeIndex: idx, accessible: accessible),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: bottomTab,
        type: BottomNavigationBarType.fixed,
        backgroundColor: p.sidebar,
        selectedItemColor: p.gold,
        unselectedItemColor: p.textMuted,
        selectedFontSize: 10,
        unselectedFontSize: 10,
        elevation: 8,
        onTap: (i) {
          if (i == 4) {
            _scaffoldKey.currentState?.openDrawer();
          } else {
            const targets = [0, 3, 1, 2];
            appState.go(targets[i]);
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined), label: 'Appts'),
          BottomNavigationBarItem(icon: Icon(Icons.groups_outlined), label: 'Patients'),
          BottomNavigationBarItem(icon: Icon(Icons.point_of_sale_outlined), label: 'POS'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_rounded), label: 'Menu'),
        ],
      ),
      body: SafeArea(
        child: _buildActiveScreen(idx),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Icon Rail (64px, always dark green)
// ─────────────────────────────────────────────────────────────────────────────
class _IconRail extends StatelessWidget {
  final int group;
  final Set<int> accessible;
  final AppState state;
  final ValueChanged<int> onGroupTap;
  const _IconRail({required this.group, required this.accessible, required this.state, required this.onGroupTap});

  @override
  Widget build(BuildContext context) {
    final p = AppScope.of(context).palette;
    return Container(
      width: _kRail,
      color: _kRailBg,
      child: Column(
        children: [
          const SizedBox(height: 18),
          // Logo
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(6)),
            child: const Icon(Icons.spa_outlined, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 26),
          // Group icons
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: List.generate(_kGroups.length, (i) {
                  final g = _kGroups[i];
                  final hasAccess = g.indices.any(accessible.contains);
                  if (!hasAccess) return const SizedBox.shrink();
                  return _RailIcon(
                    icon: g.icon,
                    tooltip: g.label,
                    active: group == i,
                    onTap: () => onGroupTap(i),
                  );
                }),
              ),
            ),
          ),
          // Theme toggle
          _RailIcon(
            icon: p.isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            tooltip: p.isDark ? 'Light Mode' : 'Dark Mode',
            active: false,
            onTap: () => appState.toggleTheme(),
          ),
          const SizedBox(height: 10),
          // User avatar / logout
          GestureDetector(
            onTap: () => appState.logout(),
            child: Tooltip(
              message: '${state.currentUser?.name ?? 'User'} — Sign Out',
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.white.withValues(alpha: 0.22),
                child: Text(
                  state.currentUser?.initials ?? 'HA',
                  style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
        ],
      ),
    );
  }
}

class _RailIcon extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final bool active;
  final VoidCallback onTap;
  const _RailIcon({required this.icon, required this.tooltip, required this.active, required this.onTap});
  @override
  State<_RailIcon> createState() => _RailIconState();
}

class _RailIconState extends State<_RailIcon> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    final active = widget.active;
    return Tooltip(
      message: widget.tooltip,
      preferBelow: false,
      child: GestureDetector(
        onTap: widget.onTap,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _hover = true),
          onExit: (_) => setState(() => _hover = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 44, height: 44,
            margin: const EdgeInsets.symmetric(vertical: 3),
            decoration: BoxDecoration(
              color: active
                  ? Colors.white.withValues(alpha: 0.22)
                  : (_hover ? Colors.white.withValues(alpha: 0.10) : Colors.transparent),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Stack(alignment: Alignment.center, children: [
              Icon(widget.icon, size: 20, color: Colors.white.withValues(alpha: active ? 1.0 : 0.55)),
              if (active) Positioned(right: 0, child: Container(width: 3, height: 20, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)))),
            ]),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Nav Panel (214px, white background)
// ─────────────────────────────────────────────────────────────────────────────
class _NavPanel extends StatefulWidget {
  final int group;
  final int activeIndex;
  final Set<int> accessible;
  final AppState state;
  const _NavPanel({required this.group, required this.activeIndex, required this.accessible, required this.state});
  @override
  State<_NavPanel> createState() => _NavPanelState();
}

class _NavPanelState extends State<_NavPanel> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = AppScope.of(context).palette;
    final g = _kGroups[widget.group];
    final bool isSearching = _searchQuery.trim().isNotEmpty;

    // When searching: scan ALL accessible modules across all groups
    final List<int> filteredMods;
    final String sectionLabel;
    if (isSearching) {
      final q = _searchQuery.toLowerCase();
      filteredMods = _kModLabel.entries
          .where((e) => widget.accessible.contains(e.key) && e.value.label.toLowerCase().contains(q))
          .map((e) => e.key)
          .toList()..sort();
      sectionLabel = filteredMods.isEmpty ? 'NO RESULTS' : '${filteredMods.length} MODULE${filteredMods.length == 1 ? '' : 'S'} FOUND';
    } else {
      filteredMods = g.indices.where(widget.accessible.contains).toList();
      sectionLabel = g.label.toUpperCase();
    }

    return Container(
      width: _kNav,
      decoration: BoxDecoration(
        color: p.sidebar,
        border: Border(right: BorderSide(color: p.border)),
        boxShadow: p.isDark ? [] : [BoxShadow(color: const Color(0xFF6B4500).withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(2, 0))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('HAIR AGAIN', style: p.display(22, spacing: 2.0, color: p.gold)),
              Text('CLINIC ERP • KARACHI', style: p.body(9, color: p.textMuted, weight: FontWeight.w700, spacing: 1.5)),
            ]),
          ),

          // ── Search (functional) ───────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              height: 36,
              decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(10), border: Border.all(color: p.border)),
              child: Row(children: [
                const SizedBox(width: 11),
                Icon(Icons.search, size: 16, color: p.textMuted),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: p.body(12.5),
                    cursorColor: p.gold,
                    decoration: InputDecoration(
                      isCollapsed: true,
                      border: InputBorder.none,
                      hintText: 'Search modules…',
                      hintStyle: p.body(12.5, color: p.textMuted.withValues(alpha: 0.7)),
                    ),
                    onChanged: (v) => setState(() => _searchQuery = v),
                  ),
                ),
                if (_searchQuery.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                    child: Icon(Icons.close, size: 15, color: p.textMuted),
                  ),
                const SizedBox(width: 10),
              ]),
            ),
          ),

          const SizedBox(height: 18),

          // ── Section label ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
            child: Text(sectionLabel, style: p.body(10, color: p.textMuted, weight: FontWeight.w700, spacing: 1.4)),
          ),

          // ── Module list ───────────────────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              children: filteredMods.map((i) {
                final mod = _kModLabel[i]!;
                return GestureDetector(
                  onTap: isSearching ? () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                    appState.go(i);
                  } : null,
                  child: _NavItem(index: i, icon: mod.icon, label: mod.label, active: widget.activeIndex == i),
                );
              }).toList(),
            ),
          ),

          // ── Bottom card + user ────────────────────────────────────
          _buildBottom(p),
        ],
      ),
    );
  }

  Widget _buildBottom(AppPalette p) {
    return Column(
      children: [
        // Promo card (matches reference's "Upgrade to Unlock Premium Feature")
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF3D2B00), Color(0xFF6B4500)],
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: Colors.amber.withValues(alpha: 0.25), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.auto_awesome, color: Colors.amber, size: 16),
                ),
              ]),
              const SizedBox(height: 10),
              const Text('Upgrade to Unlock', style: TextStyle(fontSize: 13.5, color: Colors.white, fontWeight: FontWeight.w700, height: 1.3)),
              const Text('Premium Features', style: TextStyle(fontSize: 13.5, color: Colors.white, fontWeight: FontWeight.w700, height: 1.3)),
              const SizedBox(height: 4),
              const Text('Multi-branch, advanced analytics & AI insights', style: TextStyle(fontSize: 10.5, color: Colors.white60, height: 1.4)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                child: const Text('Upgrade', style: TextStyle(fontSize: 12.5, color: Color(0xFF3D2B00), fontWeight: FontWeight.w800)),
              ),
            ]),
          ),
        ),

        // User profile row
        Container(
          margin: const EdgeInsets.fromLTRB(10, 0, 10, 14),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(10), border: Border.all(color: p.border)),
          child: Row(children: [
            CircleAvatar(
              radius: 15,
              backgroundColor: p.gold.withValues(alpha: 0.18),
              child: Text(widget.state.currentUser?.initials ?? 'HA', style: p.body(10.5, color: p.gold, weight: FontWeight.w700)),
            ),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.state.currentUser?.name ?? 'Hair Again', style: p.body(12, weight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
              Text(widget.state.currentUser?.role.label ?? 'System', style: p.body(10, color: p.textMuted), maxLines: 1),
            ])),
            GestureDetector(
              onTap: () => appState.logout(),
              child: Tooltip(message: 'Sign Out', child: Icon(Icons.logout, size: 15, color: p.textMuted)),
            ),
          ]),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Nav Item
// ─────────────────────────────────────────────────────────────────────────────
class _NavItem extends StatefulWidget {
  final int index;
  final IconData icon;
  final String label;
  final bool active;
  const _NavItem({required this.index, required this.icon, required this.label, required this.active});
  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final active = widget.active;
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: () => appState.go(widget.index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
            decoration: BoxDecoration(
              color: active
                  ? p.gold.withValues(alpha: p.isDark ? 0.15 : 0.10)
                  : (_hover ? p.surfaceAlt : Colors.transparent),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(children: [
              Icon(widget.icon, size: 18, color: active ? p.gold : (_hover ? p.text : p.textMuted)),
              const SizedBox(width: 11),
              Expanded(child: Text(widget.label,
                style: p.body(13, color: active ? p.gold : (_hover ? p.text : p.textMuted), weight: active ? FontWeight.w700 : FontWeight.w500),
                maxLines: 1, overflow: TextOverflow.ellipsis,
              )),
              if (active) Container(width: 7, height: 7, decoration: BoxDecoration(color: p.gold, shape: BoxShape.circle)),
            ]),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Mobile Drawer
// ─────────────────────────────────────────────────────────────────────────────
class _MobileDrawer extends StatelessWidget {
  final int activeIndex;
  final Set<int> accessible;
  const _MobileDrawer({required this.activeIndex, required this.accessible});

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final p = scope.palette;
    return Drawer(
      backgroundColor: p.sidebar,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('HAIR AGAIN', style: p.display(22, spacing: 2.0, color: p.gold)),
                Text('CLINIC ERP • KARACHI', style: p.body(9, color: p.textMuted, weight: FontWeight.w700, spacing: 1.5)),
              ]),
            ),
            Divider(height: 1, color: p.border),
            const SizedBox(height: 4),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                children: _buildItems(context, p),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: p.surfaceAlt,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: p.border),
              ),
              child: Row(children: [
                CircleAvatar(
                  radius: 15,
                  backgroundColor: p.gold.withValues(alpha: 0.18),
                  child: Text(scope.currentUser?.initials ?? 'HA',
                      style: p.body(10.5, color: p.gold, weight: FontWeight.w700)),
                ),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(scope.currentUser?.name ?? 'Hair Again',
                      style: p.body(12, weight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(scope.currentUser?.role.label ?? 'System',
                      style: p.body(10, color: p.textMuted), maxLines: 1),
                ])),
                GestureDetector(
                  onTap: () => appState.logout(),
                  child: Tooltip(message: 'Sign Out', child: Icon(Icons.logout, size: 15, color: p.textMuted)),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildItems(BuildContext context, AppPalette p) {
    final items = <Widget>[];
    for (final g in _kGroups) {
      final mods = g.indices.where(accessible.contains).toList();
      if (mods.isEmpty) continue;
      items.add(Padding(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 6),
        child: Text(g.label.toUpperCase(),
            style: p.body(10, color: p.textMuted, weight: FontWeight.w700, spacing: 1.4)),
      ));
      for (final i in mods) {
        final mod = _kModLabel[i]!;
        final isActive = activeIndex == i;
        items.add(GestureDetector(
          onTap: () {
            appState.go(i);
            Navigator.of(context).pop();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.only(bottom: 2),
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
            decoration: BoxDecoration(
              color: isActive ? p.gold.withValues(alpha: 0.13) : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(children: [
              Icon(mod.icon, size: 18, color: isActive ? p.gold : p.textMuted),
              const SizedBox(width: 11),
              Expanded(child: Text(mod.label,
                  style: p.body(13, color: isActive ? p.gold : p.text,
                      weight: isActive ? FontWeight.w700 : FontWeight.w500),
                  maxLines: 1, overflow: TextOverflow.ellipsis)),
              if (isActive) Container(width: 7, height: 7, decoration: BoxDecoration(color: p.gold, shape: BoxShape.circle)),
            ]),
          ),
        ));
      }
    }
    return items;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Top Bar (breadcrumb + search + actions)
// ─────────────────────────────────────────────────────────────────────────────
class _TopBar extends StatefulWidget {
  final int group;
  final int activeIndex;
  final ValueChanged<Patient> onSelectPatient;
  const _TopBar({required this.group, required this.activeIndex, required this.onSelectPatient});
  @override
  State<_TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<_TopBar> {
  final _ctrl = TextEditingController();
  final _searchPortal = OverlayPortalController();
  final _notifPortal  = OverlayPortalController();
  final _searchLink = LayerLink();
  final _notifLink  = LayerLink();
  String _q = '';

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  List<Patient> get _mp {
    if (_q.trim().isEmpty) return const [];
    final q = _q.toLowerCase();
    return appState.patients.where((p) => p.name.toLowerCase().contains(q) || p.phone.contains(q)).take(5).toList();
  }

  List<Treatment> get _mt {
    if (_q.trim().isEmpty) return const [];
    final q = _q.toLowerCase();
    return appState.treatments.where((t) => t.name.toLowerCase().contains(q)).take(4).toList();
  }

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final group = _kGroups[widget.group];
    final mod = _kModLabel[widget.activeIndex];

    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: p.sidebar,
        border: Border(bottom: BorderSide(color: p.border)),
      ),
      child: Row(children: [
        // ── Breadcrumb ────────────────────────────────────────────
        Text(group.label, style: p.body(13.5, color: p.textMuted, weight: FontWeight.w500)),
        Icon(Icons.chevron_right_rounded, size: 18, color: p.textMuted),
        Text(mod?.label ?? 'Dashboard', style: p.body(13.5, color: p.text, weight: FontWeight.w700)),

        const Spacer(),

        // ── Search ────────────────────────────────────────────────
        CompositedTransformTarget(
          link: _searchLink,
          child: OverlayPortal(
            controller: _searchPortal,
            overlayChildBuilder: (_) => _searchOverlay(p),
            child: Container(
              width: 340, height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 13),
              decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(10), border: Border.all(color: p.border)),
              child: Row(children: [
                Icon(Icons.search, size: 17, color: p.textMuted),
                const SizedBox(width: 9),
                Expanded(
                  child: TextField(
                    controller: _ctrl, style: p.body(13), cursorColor: p.gold,
                    decoration: InputDecoration(isCollapsed: true, border: InputBorder.none, hintText: 'Search patients, treatments…', hintStyle: p.body(13, color: p.textMuted.withValues(alpha: 0.7))),
                    onChanged: (v) { setState(() => _q = v); v.trim().isEmpty ? _searchPortal.hide() : _searchPortal.show(); },
                  ),
                ),
                if (_q.isNotEmpty) GestureDetector(onTap: () { _ctrl.clear(); setState(() => _q = ''); _searchPortal.hide(); }, child: Icon(Icons.close, size: 15, color: p.textMuted)),
              ]),
            ),
          ),
        ),

        const SizedBox(width: 14),

        // ── Date pill ─────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
          decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(9), border: Border.all(color: p.border)),
          child: Row(children: [
            Icon(Icons.calendar_today_outlined, size: 14, color: p.gold),
            const SizedBox(width: 7),
            Text(prettyDate(DateTime.now()), style: p.body(12, weight: FontWeight.w500)),
          ]),
        ),

        const SizedBox(width: 12),

        // ── Notifications ─────────────────────────────────────────
        CompositedTransformTarget(
          link: _notifLink,
          child: OverlayPortal(
            controller: _notifPortal,
            overlayChildBuilder: (_) => _notifOverlay(p),
            child: _ActionIcon(icon: Icons.notifications_none_rounded, badge: appState.unreadCount, onTap: () => _notifPortal.toggle()),
          ),
        ),

        const SizedBox(width: 10),
        const ThemeToggle(),
      ]),
    );
  }

  Widget _searchOverlay(AppPalette p) {
    final patients = _mp; final treatments = _mt;
    final empty = patients.isEmpty && treatments.isEmpty;
    return Stack(children: [
      Positioned.fill(child: GestureDetector(behavior: HitTestBehavior.translucent, onTap: () => _searchPortal.hide())),
      CompositedTransformFollower(
        link: _searchLink, targetAnchor: Alignment.bottomLeft, followerAnchor: Alignment.topLeft, offset: const Offset(0, 8),
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 340, constraints: const BoxConstraints(maxHeight: 380),
            decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: p.border), boxShadow: _shadow),
            child: empty
                ? Padding(padding: const EdgeInsets.all(20), child: Text('No matches for "$_q"', style: p.body(13, color: p.textMuted)))
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(8),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      if (patients.isNotEmpty) _shead(p, 'PATIENTS'),
                      ...patients.map((pt) => _srow(p, Icons.person_outline, pt.name, '${pt.phone} • ${pt.status.label}', () {
                        _searchPortal.hide(); _ctrl.clear(); setState(() => _q = '');
                        widget.onSelectPatient(pt);
                      })),
                      if (treatments.isNotEmpty) _shead(p, 'TREATMENTS'),
                      ...treatments.map((t) => _srow(p, Icons.medical_services_outlined, t.name, money(t.price), () {
                        _searchPortal.hide(); _ctrl.clear(); setState(() => _q = '');
                        appState.go(2);
                      })),
                    ]),
                  ),
          ),
        ),
      ),
    ]);
  }

  Widget _shead(AppPalette p, String t) =>
      Padding(padding: const EdgeInsets.fromLTRB(10, 10, 10, 6), child: Text(t, style: p.body(10.5, color: p.textMuted, weight: FontWeight.w700, spacing: 1.2)));

  Widget _srow(AppPalette p, IconData ic, String title, String sub, VoidCallback onTap) =>
      InkWell(
        borderRadius: BorderRadius.circular(8), onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(children: [
            Icon(ic, size: 18, color: p.gold), const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: p.body(13, weight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
              Text(sub, style: p.body(11.5, color: p.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
            ])),
            Icon(Icons.arrow_outward, size: 14, color: p.textMuted),
          ]),
        ),
      );

  Widget _notifOverlay(AppPalette p) => Stack(children: [
    Positioned.fill(child: GestureDetector(behavior: HitTestBehavior.translucent, onTap: () => _notifPortal.hide())),
    CompositedTransformFollower(
      link: _notifLink, targetAnchor: Alignment.bottomRight, followerAnchor: Alignment.topRight, offset: const Offset(0, 8),
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 340, constraints: const BoxConstraints(maxHeight: 420),
          decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(6), border: Border.all(color: p.border), boxShadow: _shadow),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 12, 10),
              child: Row(children: [
                Text('NOTIFICATIONS', style: p.display(20, spacing: 1.2)),
                const Spacer(),
                TextButton(onPressed: () => appState.markAllRead(), child: Text('Mark all read', style: p.body(12, color: p.gold, weight: FontWeight.w600))),
              ]),
            ),
            Divider(height: 1, color: p.border),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true, padding: const EdgeInsets.all(8),
                itemCount: appState.notifications.length,
                separatorBuilder: (_, i) => const SizedBox(height: 4),
                itemBuilder: (_, i) {
                  final n = appState.notifications[i];
                  return Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: n.read ? Colors.transparent : p.gold.withValues(alpha: 0.07), borderRadius: BorderRadius.circular(8)),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(8)), child: Icon(n.icon, size: 16, color: p.gold)),
                      const SizedBox(width: 11),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(n.title, style: p.body(12.5, weight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text(n.subtitle, style: p.body(11.5, color: p.textMuted)),
                      ])),
                      if (!n.read) Container(width: 7, height: 7, margin: const EdgeInsets.only(top: 4), decoration: BoxDecoration(color: p.gold, shape: BoxShape.circle)),
                    ]),
                  );
                },
              ),
            ),
          ]),
        ),
      ),
    ),
  ]);
}

// ─────────────────────────────────────────────────────────────────────────────
// Action Icon button (topbar)
// ─────────────────────────────────────────────────────────────────────────────
class _ActionIcon extends StatefulWidget {
  final IconData icon;
  final int badge;
  final VoidCallback onTap;
  const _ActionIcon({required this.icon, this.badge = 0, required this.onTap});
  @override
  State<_ActionIcon> createState() => _ActionIconState();
}

class _ActionIconState extends State<_ActionIcon> {
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
        child: Stack(clipBehavior: Clip.none, children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: _hover ? p.surfaceAlt : p.surfaceAlt,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: p.border),
            ),
            child: Icon(widget.icon, size: 20, color: p.text),
          ),
          if (widget.badge > 0) Positioned(
            right: -3, top: -3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              constraints: const BoxConstraints(minWidth: 18),
              decoration: BoxDecoration(color: p.danger, borderRadius: BorderRadius.circular(8), border: Border.all(color: p.sidebar, width: 1.5)),
              child: Text('${widget.badge}', textAlign: TextAlign.center, style: p.body(9.5, color: Colors.white, weight: FontWeight.w700)),
            ),
          ),
        ]),
      ),
    );
  }
}
