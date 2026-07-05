import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../core/widgets.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _filter = 'All';
  static const _filters = ['All', 'Appointments', 'Payments', 'Promotions', 'System'];

  final _notifs = [
    _Notif(Icons.calendar_month_outlined, kGold, 'Appointment Reminder', 'Your appointment with Dr. Bilal Khan is tomorrow at 11:00 AM.', '2h ago', 'Appointments', false),
    _Notif(Icons.check_circle_outline, kSuccess, 'Booking Confirmed', 'Your PRP Therapy session has been confirmed for 18 Jul 2026.', '1 day ago', 'Appointments', true),
    _Notif(Icons.payment_outlined, kInfo, 'Payment Received', 'Rs 12,000 payment for PRP Therapy has been received.', '2 days ago', 'Payments', true),
    _Notif(Icons.local_offer_outlined, kWarning, '20% Off This Week', 'Book a PRP session this week and get 20% off. Limited slots!', '3 days ago', 'Promotions', true),
    _Notif(Icons.star_outline, kGold, 'Points Credited', '150 loyalty points added for your last visit.', '4 days ago', 'System', true),
    _Notif(Icons.workspace_premium_outlined, kGold, 'Membership Renewed', 'Your Gold membership has been renewed for another month.', '5 days ago', 'Payments', true),
    _Notif(Icons.info_outline, kInfo, 'New Services Available', 'Check out our new Scalp Micropigmentation treatment.', '1 week ago', 'Promotions', true),
  ];

  List<_Notif> get _filtered => _filter == 'All' ? _notifs : _notifs.where((n) => n.category == _filter).toList();

  int get _unread => _notifs.where((n) => !n.isRead).length;

  @override
  Widget build(BuildContext context) {
    final p = HaTheme.of(context);
    final list = _filtered;
    return Scaffold(
      backgroundColor: p.bg,
      appBar: KAppBar(
        title: 'Notifications',
        showBack: false,
        actions: [
          if (_unread > 0)
            TextButton(onPressed: () => setState(() { for (final n in _notifs) n.isRead = true; }), child: Text('Mark All Read', style: p.body(12, color: kGold, weight: FontWeight.w600))),
        ],
      ),
      body: Column(children: [
        if (_unread > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            color: kGold.withValues(alpha: 0.08),
            child: Row(children: [
              const Icon(Icons.notifications_active, color: kGold, size: 16),
              const SizedBox(width: 8),
              Text('$_unread unread notification${_unread > 1 ? 's' : ''}', style: p.body(13, color: kGold, weight: FontWeight.w600)),
            ]),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: SizedBox(height: 34, child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 20), children: _filters.map((f) {
            final sel = f == _filter;
            return GestureDetector(
              onTap: () => setState(() => _filter = f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(color: sel ? kGold : p.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: sel ? kGold : p.border)),
                alignment: Alignment.center,
                child: Text(f, style: p.body(12, color: sel ? Colors.black87 : p.textMuted, weight: sel ? FontWeight.w600 : FontWeight.w400)),
              ),
            );
          }).toList())),
        ),
        Container(height: 1, color: p.border),
        Expanded(child: list.isEmpty
          ? const EmptyState(icon: Icons.notifications_none, title: 'No Notifications', subtitle: 'You\'re all caught up!')
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: list.length,
              separatorBuilder: (_, __) => Divider(height: 1, color: p.border, indent: 72),
              itemBuilder: (_, i) => _NotifTile(notif: list[i], p: p, onTap: () => setState(() => list[i].isRead = true)),
            ),
        ),
      ]),
    );
  }
}

class _Notif {
  final IconData icon;
  final Color color;
  final String title, body, time, category;
  bool isRead;
  _Notif(this.icon, this.color, this.title, this.body, this.time, this.category, this.isRead);
}

class _NotifTile extends StatelessWidget {
  final _Notif notif;
  final VoidCallback onTap;
  final AppPalette p;
  const _NotifTile({required this.notif, required this.onTap, required this.p});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      color: notif.isRead ? Colors.transparent : kGold.withValues(alpha: 0.04),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Stack(children: [
          Container(width: 44, height: 44, decoration: BoxDecoration(color: notif.color.withValues(alpha: 0.12), shape: BoxShape.circle), child: Icon(notif.icon, color: notif.color, size: 20)),
          if (!notif.isRead) Positioned(top: 0, right: 0, child: Container(width: 10, height: 10, decoration: const BoxDecoration(color: kGold, shape: BoxShape.circle))),
        ]),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(notif.title, style: p.body(14, weight: notif.isRead ? FontWeight.w500 : FontWeight.w700))),
            Text(notif.time, style: p.body(11, color: p.textMuted)),
          ]),
          const SizedBox(height: 4),
          Text(notif.body, style: p.body(13, color: p.textMuted), maxLines: 2, overflow: TextOverflow.ellipsis),
        ])),
      ]),
    ),
  );
}
