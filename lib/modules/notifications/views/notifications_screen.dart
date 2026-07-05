import 'package:flutter/material.dart';
import '../../../core/core.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 4, vsync: this);
  }
  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    return ScreenScaffold(
      title: 'NOTIFICATIONS',
      subtitle: 'Manage alerts, SMS, Email and WhatsApp communication logs.',
      actions: [
        Container(
          height: 42,
          decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: p.border)),
          child: TabBar(
            controller: _tab, isScrollable: true, dividerColor: Colors.transparent,
            indicatorColor: p.gold, indicatorSize: TabBarIndicatorSize.label,
            labelStyle: p.body(12.5, weight: FontWeight.w600), unselectedLabelStyle: p.body(12.5),
            labelColor: p.gold, unselectedLabelColor: p.textMuted, tabAlignment: TabAlignment.start,
            tabs: const [Tab(text: 'Notification Center'), Tab(text: 'SMS Logs'), Tab(text: 'Email Logs'), Tab(text: 'WhatsApp Logs')],
          ),
        ),
      ],
      child: EagerTabBarView(controller: _tab, children: [
        _NotifCenterTab(p: p),
        _SmsLogsTab(p: p),
        _EmailLogsTab(p: p),
        _WhatsAppLogsTab(p: p),
      ]),
    );
  }
}

// ─── Notification Center ──────────────────────────────────────────────────────

class _NotifCenterTab extends StatefulWidget {
  final AppPalette p;
  const _NotifCenterTab({required this.p});
  @override
  State<_NotifCenterTab> createState() => _NotifCenterTabState();
}

class _NotifCenterTabState extends State<_NotifCenterTab> {
  String _filter = 'All';
  final _filters = ['All', 'Unread', 'Appointment', 'Finance', 'Stock', 'Staff', 'System'];

  final _notifs = [
    _Notif(type: 'Appointment', title: 'Appointment Reminder', body: 'Dr. Rehman has 3 appointments tomorrow. Confirm patient attendance.', time: DateTime.now().subtract(const Duration(minutes: 8)), isRead: false),
    _Notif(type: 'Finance', title: 'Invoice Payment Received', body: 'Invoice #INV-1042 — PKR 45,000 received from Muhammad Arif.', time: DateTime.now().subtract(const Duration(minutes: 22)), isRead: false),
    _Notif(type: 'Stock', title: 'Low Stock Alert', body: 'Minoxidil 5% is below minimum threshold (3 units remaining).', time: DateTime.now().subtract(const Duration(hours: 1)), isRead: false),
    _Notif(type: 'Staff', title: 'Leave Request', body: 'Sana Butt has submitted a leave request for 2026-07-10 to 2026-07-12.', time: DateTime.now().subtract(const Duration(hours: 2)), isRead: true),
    _Notif(type: 'Appointment', title: 'New Appointment Booked', body: 'Online booking: Zainab Malik — Hair PRP Session — 2026-07-05 at 11:00 AM.', time: DateTime.now().subtract(const Duration(hours: 3)), isRead: true),
    _Notif(type: 'System', title: 'Daily Backup Complete', body: 'System backup completed successfully at 02:00 AM. All data secured.', time: DateTime.now().subtract(const Duration(hours: 8)), isRead: true),
    _Notif(type: 'Finance', title: 'Expense Recorded', body: 'New expense: PKR 12,500 — Clinic Supplies (Medical Consumables).', time: DateTime.now().subtract(const Duration(days: 1)), isRead: true),
    _Notif(type: 'Stock', title: 'Product Restock Complete', body: 'PRP Tubes stock updated: 100 units added by admin on 2026-07-02.', time: DateTime.now().subtract(const Duration(days: 1)), isRead: true),
    _Notif(type: 'System', title: 'User Login Alert', body: 'New login detected from Dr. Sara Iqbal at 09:15 AM on Windows Desktop.', time: DateTime.now().subtract(const Duration(days: 2)), isRead: true),
    _Notif(type: 'Appointment', title: 'Appointment Cancelled', body: 'Patient Tariq Hassan cancelled appointment scheduled for 2026-07-01.', time: DateTime.now().subtract(const Duration(days: 2)), isRead: true),
  ];

  List<_Notif> get _filtered {
    if (_filter == 'All') return _notifs;
    if (_filter == 'Unread') return _notifs.where((n) => !n.isRead).toList();
    return _notifs.where((n) => n.type == _filter).toList();
  }

  IconData _icon(String t) => switch (t) {
    'Appointment' => Icons.calendar_month_outlined,
    'Finance'     => Icons.payments_outlined,
    'Stock'       => Icons.inventory_outlined,
    'Staff'       => Icons.badge_outlined,
    _             => Icons.info_outlined,
  };

  Color _color(String t, AppPalette p) => switch (t) {
    'Appointment' => p.info,
    'Finance'     => p.success,
    'Stock'       => p.warning,
    'Staff'       => p.gold,
    _             => p.textMuted,
  };

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final unread = _notifs.where((n) => !n.isRead).length;
    final items = _filtered;
    return ScrollArea(builder: (sc) => SingleChildScrollView(
      controller: sc,
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        MetricRow([
          MetricCard(title: 'Total', value: '${_notifs.length}', delta: 'All time', icon: Icons.notifications_outlined),
          MetricCard(title: 'Unread', value: '$unread', delta: unread > 0 ? 'Action needed' : 'All clear', icon: Icons.mark_chat_unread_outlined),
          MetricCard(title: 'Sent Today', value: '12', delta: 'SMS + Email', icon: Icons.send_outlined),
          MetricCard(title: 'Failed', value: '0', delta: 'No errors', icon: Icons.error_outline),
        ]),
        const SizedBox(height: 18),
        Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: const SectionTitle('NOTIFICATION CENTER')),
            TextButton.icon(onPressed: () => setState(() { for (final n in _notifs) n.isRead = true; }), icon: Icon(Icons.done_all, size: 15, color: p.gold), label: Text('Mark all read', style: p.body(12.5, color: p.gold))),
          ]),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 6, children: _filters.map((f) {
            final sel = _filter == f;
            return GestureDetector(
              onTap: () => setState(() => _filter = f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(color: sel ? p.gold.withValues(alpha: 0.12) : p.surfaceAlt, borderRadius: BorderRadius.circular(20), border: Border.all(color: sel ? p.gold : p.border)),
                child: Text(f, style: p.body(12, color: sel ? p.gold : p.textMuted, weight: sel ? FontWeight.w600 : FontWeight.w500)),
              ),
            );
          }).toList()),
          const SizedBox(height: 16),
          if (items.isEmpty) _Empty('No ${ _filter.toLowerCase()} notifications')
          else ...items.map((n) {
            final c = _color(n.type, p);
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: n.isRead ? p.surfaceAlt : c.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: n.isRead ? p.border : c.withValues(alpha: 0.35)),
              ),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: c.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)), child: Icon(_icon(n.type), color: c, size: 16)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text(n.title, style: p.body(13, weight: n.isRead ? FontWeight.w500 : FontWeight.w700))),
                    if (!n.isRead) Container(width: 7, height: 7, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
                  ]),
                  const SizedBox(height: 4),
                  Text(n.body, style: p.body(12.5, color: p.textMuted)),
                  const SizedBox(height: 6),
                  Row(children: [
                    _Chip(n.type, c, p),
                    const Spacer(),
                    Text(_ago(n.time), style: p.body(11, color: p.textMuted)),
                    const SizedBox(width: 10),
                    if (!n.isRead) GestureDetector(onTap: () => setState(() => n.isRead = true), child: Text('Mark read', style: p.body(11, color: p.gold))),
                  ]),
                ])),
              ]),
            );
          }),
        ])),
      ]),
    ));
  }
}

String _ago(DateTime t) {
  final diff = DateTime.now().difference(t);
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  return '${diff.inDays}d ago';
}

class _Notif {
  final String type, title, body;
  final DateTime time;
  bool isRead;
  _Notif({required this.type, required this.title, required this.body, required this.time, required this.isRead});
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  final AppPalette p;
  const _Chip(this.label, this.color, this.p);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: color.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(4)),
    child: Text(label, style: p.body(10.5, color: color, weight: FontWeight.w600)),
  );
}

class _Empty extends StatelessWidget {
  final String msg;
  const _Empty(this.msg);
  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    return Padding(padding: const EdgeInsets.symmetric(vertical: 32), child: Center(child: Text(msg, style: p.body(13, color: p.textMuted))));
  }
}

// ─── SMS Logs ─────────────────────────────────────────────────────────────────

class _SmsLogsTab extends StatefulWidget {
  final AppPalette p;
  const _SmsLogsTab({required this.p});
  @override
  State<_SmsLogsTab> createState() => _SmsLogsTabState();
}

class _SmsLogsTabState extends State<_SmsLogsTab> {
  String _search = '';
  final _ctrl = TextEditingController();

  final _logs = [
    _MsgLog(to: 'Muhammad Arif', number: '+92-300-1234567', msg: 'Your appointment with Dr. Rehman is confirmed for 2026-07-05 at 10:00 AM. Hair Again Clinic.', status: 'Delivered', time: DateTime.now().subtract(const Duration(minutes: 15)), channel: 'SMS'),
    _MsgLog(to: 'Zainab Malik', number: '+92-321-9876543', msg: 'Reminder: Your PRP session is tomorrow at 11:00 AM. Please arrive 15 minutes early.', status: 'Delivered', time: DateTime.now().subtract(const Duration(hours: 1)), channel: 'SMS'),
    _MsgLog(to: 'Tariq Hassan', number: '+92-333-5556789', msg: 'Your invoice #INV-1042 of PKR 45,000 has been received. Thank you for your payment.', status: 'Failed', time: DateTime.now().subtract(const Duration(hours: 3)), channel: 'SMS'),
    _MsgLog(to: 'Sara Butt', number: '+92-311-2223344', msg: 'Thank you for your visit. Please rate your experience by replying 1-5.', status: 'Delivered', time: DateTime.now().subtract(const Duration(hours: 5)), channel: 'SMS'),
    _MsgLog(to: 'Ali Raza', number: '+92-345-6677889', msg: 'Your follow-up appointment has been scheduled for 2026-07-08. Call 021-1234567 to reschedule.', status: 'Delivered', time: DateTime.now().subtract(const Duration(days: 1)), channel: 'SMS'),
    _MsgLog(to: 'Nadia Khan', number: '+92-300-9998877', msg: 'Reminder: Membership renewal due on 2026-07-15. Contact us to continue enjoying benefits.', status: 'Pending', time: DateTime.now().subtract(const Duration(days: 1)), channel: 'SMS'),
    _MsgLog(to: 'Hassan Imam', number: '+92-321-1112233', msg: 'Your hair transplant procedure is confirmed for 2026-07-10. Please fast for 6 hours prior.', status: 'Delivered', time: DateTime.now().subtract(const Duration(days: 2)), channel: 'SMS'),
  ];

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => _LogTab(p: widget.p, logs: _logs, search: _search, ctrl: _ctrl, onSearch: (v) => setState(() => _search = v), channel: 'SMS', stats: const {'Sent': '247', 'Delivered': '231', 'Failed': '8', 'Pending': '8'});
}

// ─── Email Logs ───────────────────────────────────────────────────────────────

class _EmailLogsTab extends StatefulWidget {
  final AppPalette p;
  const _EmailLogsTab({required this.p});
  @override
  State<_EmailLogsTab> createState() => _EmailLogsTabState();
}

class _EmailLogsTabState extends State<_EmailLogsTab> {
  String _search = '';
  final _ctrl = TextEditingController();

  final _logs = [
    _MsgLog(to: 'Muhammad Arif', number: 'm.arif@gmail.com', msg: 'Invoice #INV-1042 — PKR 45,000. Please find your detailed invoice attached.', status: 'Delivered', time: DateTime.now().subtract(const Duration(minutes: 30)), channel: 'Email'),
    _MsgLog(to: 'Zainab Malik', number: 'z.malik@yahoo.com', msg: 'Appointment Confirmation — PRP Session on 2026-07-05 at 11:00 AM with Dr. Sara Iqbal.', status: 'Delivered', time: DateTime.now().subtract(const Duration(hours: 2)), channel: 'Email'),
    _MsgLog(to: 'Tariq Hassan', number: 'tariq.h@outlook.com', msg: 'Treatment Plan Summary — Hair Transplant (FUE) — Post-procedure care instructions attached.', status: 'Failed', time: DateTime.now().subtract(const Duration(hours: 4)), channel: 'Email'),
    _MsgLog(to: 'Nadia Khan', number: 'nadia.k@gmail.com', msg: 'Membership Renewal Notice — Your Gold Membership expires on 2026-07-15. Renew now for 20% off.', status: 'Delivered', time: DateTime.now().subtract(const Duration(days: 1)), channel: 'Email'),
    _MsgLog(to: 'Ali Raza', number: 'ali.raza@hotmail.com', msg: 'Welcome to Hair Again — Your patient profile is active. Book your first consultation today.', status: 'Delivered', time: DateTime.now().subtract(const Duration(days: 2)), channel: 'Email'),
    _MsgLog(to: 'Hassan Imam', number: 'hassan.i@gmail.com', msg: 'Pre-Op Instructions — FUE Hair Transplant on 2026-07-10. Please review all requirements carefully.', status: 'Delivered', time: DateTime.now().subtract(const Duration(days: 3)), channel: 'Email'),
  ];

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => _LogTab(p: widget.p, logs: _logs, search: _search, ctrl: _ctrl, onSearch: (v) => setState(() => _search = v), channel: 'Email', stats: const {'Sent': '134', 'Delivered': '128', 'Failed': '4', 'Pending': '2'});
}

// ─── WhatsApp Logs ────────────────────────────────────────────────────────────

class _WhatsAppLogsTab extends StatefulWidget {
  final AppPalette p;
  const _WhatsAppLogsTab({required this.p});
  @override
  State<_WhatsAppLogsTab> createState() => _WhatsAppLogsTabState();
}

class _WhatsAppLogsTabState extends State<_WhatsAppLogsTab> {
  String _search = '';
  final _ctrl = TextEditingController();

  final _logs = [
    _MsgLog(to: 'Muhammad Arif', number: '+92-300-1234567', msg: '📅 Your appointment is confirmed! Dr. Rehman, 2026-07-05 at 10:00 AM. Reply CANCEL to cancel.', status: 'Read', time: DateTime.now().subtract(const Duration(minutes: 5)), channel: 'WhatsApp'),
    _MsgLog(to: 'Zainab Malik', number: '+92-321-9876543', msg: '⏰ Reminder: PRP Session tomorrow at 11:00 AM. Please avoid washing hair 24 hours before.', status: 'Delivered', time: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)), channel: 'WhatsApp'),
    _MsgLog(to: 'Sara Butt', number: '+92-311-2223344', msg: '🌟 Thank you for your visit! How was your experience today? Rate us: Excellent / Good / Average', status: 'Read', time: DateTime.now().subtract(const Duration(hours: 2)), channel: 'WhatsApp'),
    _MsgLog(to: 'Tariq Hassan', number: '+92-333-5556789', msg: '💰 Payment received: PKR 45,000. Your receipt is attached. Thank you for choosing Hair Again!', status: 'Sent', time: DateTime.now().subtract(const Duration(hours: 6)), channel: 'WhatsApp'),
    _MsgLog(to: 'Ali Raza', number: '+92-345-6677889', msg: '📋 Your treatment plan has been updated. Please visit the clinic to review your progress report.', status: 'Read', time: DateTime.now().subtract(const Duration(days: 1)), channel: 'WhatsApp'),
    _MsgLog(to: 'Nadia Khan', number: '+92-300-9998877', msg: '🎁 Membership benefit: You have 3 free sessions remaining. Book now before expiry on 2026-07-15.', status: 'Failed', time: DateTime.now().subtract(const Duration(days: 1)), channel: 'WhatsApp'),
    _MsgLog(to: 'Hassan Imam', number: '+92-321-1112233', msg: '🏥 Pre-surgery checklist sent. Please review and confirm your preparation. See you on July 10!', status: 'Read', time: DateTime.now().subtract(const Duration(days: 2)), channel: 'WhatsApp'),
  ];

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => _LogTab(p: widget.p, logs: _logs, search: _search, ctrl: _ctrl, onSearch: (v) => setState(() => _search = v), channel: 'WhatsApp', stats: const {'Sent': '389', 'Delivered': '361', 'Read': '298', 'Failed': '12'});
}

// ─── Shared Log Tab ───────────────────────────────────────────────────────────

class _MsgLog {
  final String to, number, msg, status, channel;
  final DateTime time;
  const _MsgLog({required this.to, required this.number, required this.msg, required this.status, required this.time, required this.channel});
}

class _LogTab extends StatelessWidget {
  final AppPalette p;
  final List<_MsgLog> logs;
  final String search, channel;
  final TextEditingController ctrl;
  final ValueChanged<String> onSearch;
  final Map<String, String> stats;
  const _LogTab({required this.p, required this.logs, required this.search, required this.ctrl, required this.onSearch, required this.channel, required this.stats});

  Color _statusColor(String s) => switch (s) {
    'Delivered' || 'Read' => p.success,
    'Failed'              => p.danger,
    'Pending' || 'Sent'   => p.warning,
    _                     => p.textMuted,
  };

  IconData _chanIcon() => switch (channel) {
    'SMS'      => Icons.sms_outlined,
    'Email'    => Icons.email_outlined,
    _          => Icons.chat_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final filtered = search.isEmpty ? logs : logs.where((l) => l.to.toLowerCase().contains(search.toLowerCase()) || l.number.contains(search) || l.msg.toLowerCase().contains(search.toLowerCase())).toList();
    return ScrollArea(builder: (sc) => SingleChildScrollView(
      controller: sc,
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        MetricRow(stats.entries.map((e) => MetricCard(title: e.key, value: e.value, delta: 'This month', icon: _chanIcon())).toList()),
        const SizedBox(height: 18),
        Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: SectionTitle('$channel DELIVERY LOGS')),
            SizedBox(width: 220, child: SearchBox(controller: ctrl, hint: 'Search logs...', onChanged: onSearch)),
          ]),
          const SizedBox(height: 14),
          if (filtered.isEmpty) const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('No logs found'))),
          ...filtered.map((l) {
            final sc = _statusColor(l.status);
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(10), border: Border.all(color: p.border)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Icon(_chanIcon(), size: 15, color: p.textMuted),
                  const SizedBox(width: 8),
                  Expanded(child: Text(l.to, style: p.body(13, weight: FontWeight.w600))),
                  _Chip(l.status, sc, p),
                  const SizedBox(width: 8),
                  Text(_ago(l.time), style: p.body(11, color: p.textMuted)),
                ]),
                const SizedBox(height: 4),
                Text(l.number, style: p.body(11.5, color: p.textMuted)),
                const SizedBox(height: 8),
                Text(l.msg, style: p.body(12.5, color: p.text), maxLines: 2, overflow: TextOverflow.ellipsis),
              ]),
            );
          }),
        ])),
      ]),
    ));
  }
}
