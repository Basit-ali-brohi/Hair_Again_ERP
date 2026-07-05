import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../core/widgets.dart';
import '../../../core/app_data_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _filter = 'All';
  static const _filters = ['All', 'Appointments', 'Payments', 'Promotions', 'System'];

  @override
  void initState() {
    super.initState();
    appData.addListener(_onDataChange);
  }

  void _onDataChange() { if (mounted) setState(() {}); }

  @override
  void dispose() { appData.removeListener(_onDataChange); super.dispose(); }

  List<HaNotification> get _filtered {
    final all = appData.notifications;
    return _filter == 'All' ? all.toList() : all.where((n) => n.category == _filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final p = HaTheme.of(context);
    final list = _filtered;
    final unread = appData.unreadCount;

    return Scaffold(
      backgroundColor: p.bg,
      appBar: KAppBar(
        title: 'Notifications',
        showBack: false,
        actions: [
          if (unread > 0)
            TextButton(
              onPressed: appData.markAllNotifsRead,
              child: Text('Mark All Read', style: p.body(12, color: kGold, weight: FontWeight.w600)),
            ),
        ],
      ),
      body: Column(children: [
        // Unread banner
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: unread > 0 ? 40 : 0,
          color: kGold.withValues(alpha: 0.08),
          child: unread > 0 ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              const Icon(Icons.notifications_active, color: kGold, size: 16),
              const SizedBox(width: 8),
              Text('$unread unread notification${unread > 1 ? 's' : ''}', style: p.body(13, color: kGold, weight: FontWeight.w600)),
            ]),
          ) : null,
        ),

        // Filter chips
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: SizedBox(height: 34, child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: _filters.map((f) {
              final sel = f == _filter;
              final count = f == 'All' ? appData.notifications.length : appData.notifications.where((n) => n.category == f).length;
              return GestureDetector(
                onTap: () => setState(() => _filter = f),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: sel ? kGold : p.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: sel ? kGold : p.border),
                  ),
                  alignment: Alignment.center,
                  child: Text('$f${f != 'All' ? ' ($count)' : ''}',
                      style: p.body(12, color: sel ? Colors.black87 : p.textMuted, weight: sel ? FontWeight.w600 : FontWeight.w400)),
                ),
              );
            }).toList(),
          )),
        ),
        Container(height: 1, color: p.border),

        Expanded(child: list.isEmpty
          ? const EmptyState(icon: Icons.notifications_none, title: 'No Notifications', subtitle: 'You\'re all caught up!')
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: list.length,
              separatorBuilder: (_, __) => Divider(height: 1, color: p.border.withValues(alpha: 0.5), indent: 74),
              itemBuilder: (_, i) => _NotifTile(notif: list[i], p: p,
                  onTap: () => appData.markNotifRead(list[i].id)),
            ),
        ),
      ]),
    );
  }
}

class _NotifTile extends StatelessWidget {
  final HaNotification notif;
  final VoidCallback onTap;
  final AppPalette p;
  const _NotifTile({required this.notif, required this.onTap, required this.p});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      color: notif.isRead ? Colors.transparent : kGold.withValues(alpha: 0.04),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Stack(children: [
          Container(width: 44, height: 44,
            decoration: BoxDecoration(color: notif.color.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: Icon(notif.icon, color: notif.color, size: 20)),
          if (!notif.isRead)
            Positioned(top: 0, right: 0, child: Container(
              width: 10, height: 10,
              decoration: const BoxDecoration(color: kGold, shape: BoxShape.circle),
            )),
        ]),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(notif.title, style: p.body(14, weight: notif.isRead ? FontWeight.w500 : FontWeight.w700))),
            const SizedBox(width: 8),
            Text(notif.timeStr, style: p.body(11, color: p.textMuted)),
          ]),
          const SizedBox(height: 4),
          Text(notif.body, style: p.body(13, color: p.textMuted), maxLines: 2, overflow: TextOverflow.ellipsis),
        ])),
      ]),
    ),
  );
}
