import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../../../core/widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _quickActions = [
    (Icons.calendar_month_outlined, 'Book', '/book'),
    (Icons.history_outlined,        'History', '/appointments'),
    (Icons.auto_awesome_outlined,   'Gallery', '/gallery'),
    (Icons.chat_bubble_outline,     'Support', '/chat'),
  ];

  static const _upcomingAppt = (
    'Hair Transplant Consultation',
    'Dr. Bilal Khan',
    'Mon, 7 Jul 2026 • 11:00 AM',
    'Confirmed',
  );

  @override
  Widget build(BuildContext context) {
    final p = HaTheme.of(context);
    return Scaffold(
      backgroundColor: p.bg,
      body: CustomScrollView(
        slivers: [
          // Hero header
          SliverToBoxAdapter(child: Container(
            decoration: BoxDecoration(
              gradient: p.heroGradient,
              boxShadow: p.isDark ? null : [BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 18, 20, 24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Good Morning,', style: p.body(13, color: p.textMuted)),
                  Text('Ahmad Ali', style: p.display(24)),
                ]),
                const Spacer(),
                GestureDetector(
                  onTap: () {},
                  child: Stack(children: [
                    Container(width: 44, height: 44, decoration: BoxDecoration(color: kGold.withValues(alpha: 0.15), shape: BoxShape.circle), child: const Icon(Icons.notifications_outlined, color: kGold, size: 22)),
                    Positioned(top: 9, right: 9, child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: kDanger, shape: BoxShape.circle))),
                  ]),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => context.go('/profile-tab'),
                  child: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(gradient: kGoldGradient, shape: BoxShape.circle),
                    child: Center(child: Text('AA', style: p.body(14, color: Colors.black87, weight: FontWeight.w800))),
                  ),
                ),
              ]),
              const SizedBox(height: 22),
              // Stats row — Expanded prevents overflow
              Row(children: [
                Expanded(child: _MiniStat('3', 'Appointments', p)),
                const SizedBox(width: 10),
                Expanded(child: _MiniStat('1,250', 'Loyalty Pts', p)),
                const SizedBox(width: 10),
                Expanded(child: _MiniStat('Gold', 'Membership', p)),
              ]),
            ]),
          )),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 110),
            sliver: SliverList(delegate: SliverChildListDelegate([

              // Upcoming appointment
              SectionHeader(title: 'Upcoming Appointment'),
              const SizedBox(height: 14),
              _UpcomingCard(appt: _upcomingAppt, p: p),
              const SizedBox(height: 28),

              // Quick actions
              SectionHeader(title: 'Quick Actions'),
              const SizedBox(height: 14),
              Row(children: _quickActions.map((a) => Expanded(child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _QuickAction(icon: a.$1, label: a.$2, route: a.$3, p: p),
              ))).toList()),
              const SizedBox(height: 28),

              // Promo banner
              SectionHeader(title: 'Offers & Promotions'),
              const SizedBox(height: 14),
              _PromoBanner(p: p),
              const SizedBox(height: 28),

              // Popular services
              SectionHeader(title: 'Popular Services', action: 'See All', onAction: () => context.go('/services')),
              const SizedBox(height: 14),
              ...[
                (Icons.content_cut_outlined, 'Hair Transplant',  'FUE / FUT Technique',    'From Rs 80,000'),
                (Icons.water_drop_outlined,  'PRP Therapy',      'Platelet Rich Plasma',    'From Rs 12,000'),
                (Icons.spa_outlined,         'Scalp Treatment',  'Deep cleanse & nourish',  'From Rs 4,500'),
              ].map((s) => _ServiceTile(icon: s.$1, name: s.$2, subtitle: s.$3, price: s.$4, p: p)),
            ])),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String value, label;
  final AppPalette p;
  const _MiniStat(this.value, this.label, this.p);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 12),
    decoration: BoxDecoration(
      color: p.isDark
          ? Colors.black.withValues(alpha: 0.18)
          : kGold.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: p.isDark
            ? Colors.white.withValues(alpha: 0.08)
            : kGold.withValues(alpha: 0.30),
      ),
    ),
    child: Column(children: [
      Text(value, style: p.body(16, color: kGold, weight: FontWeight.w800)),
      const SizedBox(height: 3),
      Text(label, style: p.body(11, color: p.isDark ? Colors.white70 : p.textMuted), textAlign: TextAlign.center),
    ]),
  );
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label, route;
  final AppPalette p;
  const _QuickAction({required this.icon, required this.label, required this.route, required this.p});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => context.push(route),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 58, height: 58,
        decoration: BoxDecoration(
          color: kGold.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: kGold.withValues(alpha: 0.25)),
        ),
        child: Icon(icon, color: kGold, size: 24),
      ),
      const SizedBox(height: 8),
      Text(label, style: p.body(12, weight: FontWeight.w600, color: p.textMuted), textAlign: TextAlign.center),
    ]),
  );
}

class _UpcomingCard extends StatelessWidget {
  final (String, String, String, String) appt;
  final AppPalette p;
  const _UpcomingCard({required this.appt, required this.p});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: p.surface,
      gradient: LinearGradient(colors: [kGold.withValues(alpha: 0.1), p.surface]),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: kGold.withValues(alpha: 0.25)),
      boxShadow: [BoxShadow(color: kGold.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, 4))],
    ),
    child: Row(children: [
      Container(width: 50, height: 50, decoration: BoxDecoration(gradient: kGoldGradient, borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.event_outlined, color: Colors.black87, size: 24)),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(appt.$1, style: p.body(14, weight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 3),
        Text(appt.$2, style: p.body(12, color: p.textMuted)),
        const SizedBox(height: 3),
        Row(children: [
          const Icon(Icons.schedule, size: 12, color: kGold),
          const SizedBox(width: 4),
          Flexible(child: Text(appt.$3, style: p.body(12, color: kGold, weight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
        ]),
      ])),
      StatusBadge(label: appt.$4, color: kSuccess),
    ]),
  );
}

class _PromoBanner extends StatelessWidget {
  final AppPalette p;
  const _PromoBanner({required this.p});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: [const Color(0xFF1A1500), p.isDark ? const Color(0xFF0E0E12) : const Color(0xFF3D2800)]),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: kGold.withValues(alpha: 0.2)),
    ),
    child: Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: kGold, borderRadius: BorderRadius.circular(4)), child: const Text('LIMITED OFFER', style: TextStyle(fontSize: 9, color: Colors.black87, fontWeight: FontWeight.w800, letterSpacing: 0.8))),
        const SizedBox(height: 10),
        const Text('20% off PRP\nTherapy this month', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white, height: 1.2)),
        const SizedBox(height: 14),
        GestureDetector(
          onTap: () => context.push('/book'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            decoration: BoxDecoration(gradient: kGoldGradient, borderRadius: BorderRadius.circular(10),
              boxShadow: [BoxShadow(color: kGold.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 3))]),
            child: const Text('Book Now', style: TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w700)),
          ),
        ),
      ])),
      Container(width: 80, height: 80, decoration: BoxDecoration(color: kGold.withValues(alpha: 0.12), shape: BoxShape.circle), child: const Icon(Icons.water_drop_outlined, color: kGold, size: 38)),
    ]),
  );
}

class _ServiceTile extends StatelessWidget {
  final IconData icon;
  final String name, subtitle, price;
  final AppPalette p;
  const _ServiceTile({required this.icon, required this.name, required this.subtitle, required this.price, required this.p});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => context.push('/book'),
    child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: p.border),
        boxShadow: [if (!p.isDark) BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(children: [
        Container(width: 46, height: 46, decoration: BoxDecoration(color: kGold.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: kGold, size: 22)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: p.body(15, weight: FontWeight.w700)),
          const SizedBox(height: 3),
          Text(subtitle, style: p.body(12, color: p.textMuted)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(price, style: p.body(13, color: kGold, weight: FontWeight.w600)),
          const SizedBox(height: 4),
          Icon(Icons.arrow_forward_ios, size: 12, color: p.textMuted),
        ]),
      ]),
    ),
  );
}
