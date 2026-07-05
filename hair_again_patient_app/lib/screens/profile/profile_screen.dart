import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../../../core/widgets.dart';
import '../../../core/router.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _editing = false;

  final _nameCtrl    = TextEditingController(text: 'Ahmed Khan');
  final _emailCtrl   = TextEditingController(text: 'ahmed.khan@email.com');
  final _phoneCtrl   = TextEditingController(text: '+92 312 345 6789');
  final _dobCtrl     = TextEditingController(text: '15 March 1988');
  final _bloodCtrl   = TextEditingController(text: 'B+');
  final _allergiesCtrl = TextEditingController(text: 'None');

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose(); _phoneCtrl.dispose();
    _dobCtrl.dispose(); _bloodCtrl.dispose(); _allergiesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = HaTheme.of(context);
    return Scaffold(
      backgroundColor: p.bg,
      appBar: AppBar(
        backgroundColor: p.surface,
        elevation: 0,
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height: 1, color: p.border)),
        automaticallyImplyLeading: false,
        title: Text('My Profile', style: p.display(20)),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: () {
              if (_editing) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Profile updated.'), backgroundColor: kSuccess, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
              setState(() => _editing = !_editing);
            },
            child: Text(_editing ? 'Save' : 'Edit', style: p.body(14, color: kGold, weight: FontWeight.w700)),
          ),
          IconButton(icon: Icon(Icons.settings_outlined, color: p.textMuted, size: 22), onPressed: () => context.push('/settings')),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 40),
        child: Column(children: [
          // Avatar
          Center(child: Stack(children: [
            Container(width: 96, height: 96, decoration: BoxDecoration(gradient: kGoldGradient, shape: BoxShape.circle),
              child: Center(child: Text('AK', style: p.display(34, color: Colors.black87)))),
            if (_editing) Positioned(bottom: 0, right: 0, child: Container(width: 28, height: 28,
              decoration: BoxDecoration(color: kGold, shape: BoxShape.circle, border: Border.all(color: p.bg, width: 2)),
              child: const Icon(Icons.camera_alt_outlined, size: 14, color: Colors.black87))),
          ])),
          const SizedBox(height: 14),
          Text('Ahmed Khan', style: p.display(22)),
          const SizedBox(height: 4),
          Text('Patient ID: #HA-2024-0042', style: p.body(13, color: p.textMuted)),
          const SizedBox(height: 8),
          const StatusBadge(label: 'Gold Member', color: kGold),
          const SizedBox(height: 28),

          _Section(p: p, title: 'Personal Information', children: [
            _Field(p: p, label: 'Full Name',       ctrl: _nameCtrl,     icon: Icons.person_outline,     editable: _editing),
            _Field(p: p, label: 'Email Address',   ctrl: _emailCtrl,    icon: Icons.email_outlined,     editable: _editing),
            _Field(p: p, label: 'Phone Number',    ctrl: _phoneCtrl,    icon: Icons.phone_outlined,     editable: _editing),
            _Field(p: p, label: 'Date of Birth',   ctrl: _dobCtrl,      icon: Icons.cake_outlined,      editable: _editing),
          ]),
          const SizedBox(height: 16),

          _Section(p: p, title: 'Medical Information', children: [
            _Field(p: p, label: 'Blood Group',      ctrl: _bloodCtrl,    icon: Icons.bloodtype_outlined,         editable: _editing),
            _Field(p: p, label: 'Known Allergies',  ctrl: _allergiesCtrl,icon: Icons.warning_amber_outlined,    editable: _editing),
          ]),
          const SizedBox(height: 16),

          _Section(p: p, title: 'Treatment Summary', children: [
            _StatRow(p: p, label: 'Total Visits',       value: '12'),
            _StatRow(p: p, label: 'Active Treatment',   value: 'PRP Therapy'),
            _StatRow(p: p, label: 'Next Appointment',   value: '18 Jul 2026'),
            _StatRow(p: p, label: 'Member Since',       value: 'March 2024'),
          ]),
          const SizedBox(height: 24),

          // ── My Account ──────────────────────────────────────────────────
          SectionHeader(title: 'My Account'),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: p.border),
              boxShadow: [if (!p.isDark) BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]),
            child: Column(children: [
              _NavTile(p: p, icon: Icons.card_membership_outlined, color: kGold,               label: 'Membership Plan',    sub: 'Gold Member · active',             onTap: () => context.push('/membership')),
              _NavTile(p: p, icon: Icons.stars_outlined,           color: const Color(0xFFFFB74D), label: 'Loyalty Points',     sub: '1,250 pts available',              onTap: () => context.push('/loyalty')),
              _NavTile(p: p, icon: Icons.credit_card_outlined,     color: const Color(0xFF5B8DEF), label: 'Payment History',    sub: 'View invoices & receipts',         onTap: () => context.push('/payments')),
              _NavTile(p: p, icon: Icons.rate_review_outlined,     color: const Color(0xFF3FA787), label: 'My Reviews',         sub: 'Rate your experience',             onTap: () => context.push('/reviews'), last: true),
            ]),
          ),
          const SizedBox(height: 16),

          // ── My Treatment ─────────────────────────────────────────────────
          SectionHeader(title: 'My Treatment'),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: p.border),
              boxShadow: [if (!p.isDark) BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]),
            child: Column(children: [
              _NavTile(p: p, icon: Icons.timeline_outlined,        color: kGold,               label: 'Treatment History',  sub: 'Progress & session records',       onTap: () => context.push('/treatments')),
              _NavTile(p: p, icon: Icons.photo_library_outlined,   color: const Color(0xFF9C6FDE), label: 'Before/After Gallery', sub: 'See your transformation',      onTap: () => context.push('/gallery')),
              _NavTile(p: p, icon: Icons.chat_bubble_outline,      color: const Color(0xFF3FA787), label: 'Chat Support',       sub: 'Talk to our team',                 onTap: () => context.push('/chat'), last: true),
            ]),
          ),
          const SizedBox(height: 24),

          _ActionTile(p: p, icon: Icons.settings_outlined, label: 'Settings', onTap: () => context.push('/settings')),
          const SizedBox(height: 8),
          OutlineBtn(label: 'Change Password', onTap: () => _changePasswordDialog(context, p)),
          const SizedBox(height: 10),
          OutlineBtn(
            label: 'Sign Out',
            color: kDanger,
            onTap: () {
              markLoggedOut();
              context.go('/login');
            },
          ),
          const SizedBox(height: 10),
          OutlineBtn(label: 'Delete Account', onTap: () {}, color: kDanger),
        ]),
      ),
    );
  }

  void _changePasswordDialog(BuildContext context, AppPalette p) {
    final cur = TextEditingController(), nw = TextEditingController(), conf = TextEditingController();
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: p.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Text('Change Password', style: p.body(18, weight: FontWeight.w700)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        _DialogField(p: p, hint: 'Current Password', ctrl: cur),
        const SizedBox(height: 12),
        _DialogField(p: p, hint: 'New Password', ctrl: nw),
        const SizedBox(height: 12),
        _DialogField(p: p, hint: 'Confirm Password', ctrl: conf),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: p.body(14, color: p.textMuted))),
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Save', style: p.body(14, color: kGold, weight: FontWeight.w700))),
      ],
    ));
  }
}

class _Section extends StatelessWidget {
  final AppPalette p;
  final String title;
  final List<Widget> children;
  const _Section({required this.p, required this.title, required this.children});

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    SectionHeader(title: title),
    const SizedBox(height: 10),
    Container(
      decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: p.border),
        boxShadow: [if (!p.isDark) BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Column(children: children),
    ),
  ]);
}

class _Field extends StatelessWidget {
  final AppPalette p;
  final String label;
  final TextEditingController ctrl;
  final IconData icon;
  final bool editable;
  const _Field({required this.p, required this.label, required this.ctrl, required this.icon, required this.editable});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(border: Border(bottom: BorderSide(color: p.border, width: 0.5))),
    child: Row(children: [
      Icon(icon, size: 18, color: p.textMuted),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: p.body(11, color: p.textMuted)),
        const SizedBox(height: 2),
        editable
          ? TextField(controller: ctrl, style: p.body(14), decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.zero, border: InputBorder.none))
          : Text(ctrl.text, style: p.body(14)),
      ])),
      if (editable) Icon(Icons.edit_outlined, size: 14, color: p.textMuted),
    ]),
  );
}

class _StatRow extends StatelessWidget {
  final AppPalette p;
  final String label, value;
  const _StatRow({required this.p, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(border: Border(bottom: BorderSide(color: p.border, width: 0.5))),
    child: Row(children: [
      Expanded(child: Text(label, style: p.body(13, color: p.textMuted))),
      Text(value, style: p.body(13, weight: FontWeight.w600)),
    ]),
  );
}

class _NavTile extends StatelessWidget {
  final AppPalette p;
  final IconData icon;
  final Color color;
  final String label;
  final String sub;
  final VoidCallback onTap;
  final bool last;
  const _NavTile({required this.p, required this.icon, required this.color, required this.label, required this.sub, required this.onTap, this.last = false});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(border: last ? null : Border(bottom: BorderSide(color: p.border, width: 0.5))),
      child: Row(children: [
        Container(width: 40, height: 40, decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, size: 20, color: color)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: p.body(14, weight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(sub, style: p.body(12, color: p.textMuted)),
        ])),
        Icon(Icons.chevron_right, size: 18, color: p.textMuted),
      ]),
    ),
  );
}

class _ActionTile extends StatelessWidget {
  final AppPalette p;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionTile({required this.p, required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      margin: const EdgeInsets.only(bottom: 0),
      decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: p.border)),
      child: Row(children: [
        Icon(icon, size: 20, color: p.textMuted),
        const SizedBox(width: 14),
        Expanded(child: Text(label, style: p.body(14, weight: FontWeight.w600))),
        Icon(Icons.chevron_right, size: 18, color: p.textMuted),
      ]),
    ),
  );
}

class _DialogField extends StatelessWidget {
  final AppPalette p;
  final String hint;
  final TextEditingController ctrl;
  const _DialogField({required this.p, required this.hint, required this.ctrl});

  @override
  Widget build(BuildContext context) => TextField(
    controller: ctrl, obscureText: true,
    style: p.body(14),
    decoration: InputDecoration(
      hintText: hint, hintStyle: p.body(14, color: p.textMuted),
      filled: true, fillColor: p.surfaceAlt,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: p.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: p.border)),
      focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: kGold)),
    ),
  );
}
