import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../core/widgets.dart';

class SessionsScreen extends StatefulWidget {
  const SessionsScreen({super.key});
  @override
  State<SessionsScreen> createState() => _SessionsScreenState();
}

class _SessionsScreenState extends State<SessionsScreen> {
  final _sessions = [
    _Session('iPhone 14 Pro', 'iOS 17.2', 'Karachi, PK', 'Active now', Icons.phone_iphone_rounded, true),
    _Session('Samsung Galaxy S24', 'Android 14', 'Lahore, PK', '2 days ago', Icons.smartphone_rounded, false),
    _Session('Chrome on Windows', 'Windows 11', 'Karachi, PK', '5 days ago', Icons.laptop_rounded, false),
    _Session('iPad Pro', 'iPadOS 17.1', 'Islamabad, PK', '12 days ago', Icons.tablet_mac_rounded, false),
  ];

  void _revoke(int index) {
    final p = HaTheme.of(context);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: p.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('Remove Session', style: p.body(17, weight: FontWeight.w700)),
        content: Text('Remove "${_sessions[index].name}" from your active sessions?', style: p.body(14, color: p.textMuted)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: p.body(14, color: p.textMuted))),
          TextButton(
            onPressed: () { Navigator.pop(context); setState(() => _sessions.removeAt(index)); },
            child: Text('Remove', style: p.body(14, color: kDanger, weight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _revokeAll() {
    final p = HaTheme.of(context);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: p.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('Remove All Sessions', style: p.body(17, weight: FontWeight.w700)),
        content: Text('This will log you out from all other devices. Continue?', style: p.body(14, color: p.textMuted)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: p.body(14, color: p.textMuted))),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _sessions.removeWhere((s) => !s.isCurrent));
            },
            child: Text('Remove All', style: p.body(14, color: kDanger, weight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = HaTheme.of(context);
    return Scaffold(
      backgroundColor: p.bg,
      appBar: const KAppBar(title: 'Active Sessions'),
      body: ListView(padding: const EdgeInsets.fromLTRB(20, 20, 20, 40), children: [
        // Info banner
        Container(
          padding: const EdgeInsets.all(14),
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: kInfo.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kInfo.withValues(alpha: 0.2)),
          ),
          child: Row(children: [
            const Icon(Icons.info_outline_rounded, color: kInfo, size: 18),
            const SizedBox(width: 10),
            Expanded(child: Text('You are currently logged in on ${_sessions.length} device${_sessions.length != 1 ? 's' : ''}.', style: p.body(13, color: p.textMuted))),
          ]),
        ),

        // Session list
        ..._sessions.asMap().entries.map((e) {
          final i = e.key;
          final s = e.value;
          return _SessionTile(session: s, p: p, onRevoke: s.isCurrent ? null : () => _revoke(i));
        }),

        const SizedBox(height: 24),
        if (_sessions.any((s) => !s.isCurrent))
          OutlineBtn(
            label: 'Remove All Other Sessions',
            onTap: _revokeAll,
            color: kDanger,
          ),
      ]),
    );
  }
}

class _Session {
  final String name, os, location, lastActive;
  final IconData icon;
  final bool isCurrent;
  const _Session(this.name, this.os, this.location, this.lastActive, this.icon, this.isCurrent);
}

class _SessionTile extends StatelessWidget {
  final _Session session;
  final AppPalette p;
  final VoidCallback? onRevoke;
  const _SessionTile({required this.session, required this.p, this.onRevoke});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: p.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: session.isCurrent ? kGold.withValues(alpha: 0.4) : p.border),
      boxShadow: [if (session.isCurrent) BoxShadow(color: kGold.withValues(alpha: 0.06), blurRadius: 12)],
    ),
    child: Row(children: [
      Container(
        width: 46, height: 46,
        decoration: BoxDecoration(
          color: session.isCurrent ? kGold.withValues(alpha: 0.12) : p.surfaceAlt,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: session.isCurrent ? kGold.withValues(alpha: 0.3) : p.border),
        ),
        child: Icon(session.icon, size: 22, color: session.isCurrent ? kGold : p.textMuted),
      ),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(session.name, style: p.body(14, weight: FontWeight.w700))),
          if (session.isCurrent)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: kSuccess.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
              child: Text('This device', style: p.body(11, color: kSuccess, weight: FontWeight.w600)),
            ),
        ]),
        const SizedBox(height: 3),
        Text(session.os, style: p.body(12, color: p.textMuted)),
        const SizedBox(height: 2),
        Row(children: [
          Icon(Icons.location_on_outlined, size: 11, color: p.textMuted),
          const SizedBox(width: 3),
          Text(session.location, style: p.body(11, color: p.textMuted)),
          const SizedBox(width: 10),
          Icon(Icons.access_time_rounded, size: 11, color: p.textMuted),
          const SizedBox(width: 3),
          Text(session.lastActive, style: p.body(11, color: p.textMuted)),
        ]),
      ])),
      if (onRevoke != null) ...[
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onRevoke,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: kDanger.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: kDanger.withValues(alpha: 0.2)),
            ),
            child: Text('Remove', style: p.body(12, color: kDanger, weight: FontWeight.w600)),
          ),
        ),
      ],
    ]),
  );
}
