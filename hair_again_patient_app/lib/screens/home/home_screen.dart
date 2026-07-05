import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../../../core/widgets.dart';
import '../../../core/profile_notifier.dart';
import '../../../core/app_data_service.dart';

// ──────────────────────────────────────────────────────────────────────────────
//  HomeScreen
// ──────────────────────────────────────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _gradCtrl;
  bool _loading = true;

  static const _quickActions = [
    (Icons.calendar_month_rounded, 'Book', '/book'),
    (Icons.history_rounded,        'History', '/appointments'),
    (Icons.auto_awesome_rounded,   'Gallery', '/gallery'),
    (Icons.chat_bubble_rounded,    'Support', '/chat'),
  ];

  @override
  void initState() {
    super.initState();
    _gradCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 6))
      ..repeat(reverse: true);
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (mounted) setState(() => _loading = false);
    });
    profileNotifier.addListener(_onProfileChange);
    appData.addListener(_onDataChange);
  }

  void _onProfileChange() { if (mounted) setState(() {}); }
  void _onDataChange()    { if (mounted) setState(() {}); }

  @override
  void dispose() {
    profileNotifier.removeListener(_onProfileChange);
    appData.removeListener(_onDataChange);
    _gradCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = HaTheme.of(context);
    final topPad = MediaQuery.of(context).padding.top;

    final heroContent = _HeroContent(
      p: p, topPad: topPad, quickActions: _quickActions,
      profileName: profileNotifier.name,
      profileInitials: profileNotifier.initials,
      avatarBytes: profileNotifier.avatarBytes,
      appointmentCount: appData.upcomingCount,
      loyaltyPoints: appData.loyaltyPoints,
      membershipTier: appData.membershipTier,
    );

    return Scaffold(
      backgroundColor: p.bg,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        switchInCurve: Curves.easeOut,
        child: _loading
          ? _ShimmerBody(key: const ValueKey('shimmer'), p: p, topPad: topPad)
          : CustomScrollView(key: const ValueKey('content'),
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Animated gradient hero ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: AnimatedBuilder(
              animation: _gradCtrl,
              child: heroContent,            // built once, no rebuild each frame
              builder: (_, child) {
                final t = _gradCtrl.value;
                final shift = math.sin(t * math.pi) * 0.15;
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(-1.0 + shift, -1.0),
                      end:   Alignment(1.0 - shift,  1.0),
                      colors: p.isDark
                          ? [
                              const Color(0xFF0E0E12),
                              Color.lerp(const Color(0xFF1A1200), const Color(0xFF221800), t)!,
                              const Color(0xFF0E0E12),
                            ]
                          : [
                              const Color(0xFFFBF9F5),
                              Color.lerp(const Color(0xFFF5EDD8), const Color(0xFFFDF6E8), t)!,
                              const Color(0xFFFBF9F5),
                            ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                  child: child!,
                );
              },
            ),
          ),

          // ── Scrollable content ──────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
            sliver: SliverList(delegate: SliverChildListDelegate([

              // Upcoming appointment
              SectionHeader(
                title: 'Upcoming Appointment',
                action: 'View All',
                onAction: () => context.push('/appointments'),
              ),
              const SizedBox(height: 14),
              PressableCard(
                onTap: () => context.push('/appointments'),
                child: _UpcomingCard(p: p, appt: appData.nextAppointment),
              ).animate().fadeIn(delay: 80.ms, duration: 350.ms).slideY(begin: 0.05, end: 0),
              const SizedBox(height: 28),

              // Promo carousel
              SectionHeader(title: 'Offers & Promotions'),
              const SizedBox(height: 14),
              _PromoCarousel(p: p)
                .animate().fadeIn(delay: 160.ms, duration: 350.ms).slideY(begin: 0.05, end: 0),
              const SizedBox(height: 28),

              // Popular services
              SectionHeader(
                title: 'Popular Services',
                action: 'See All',
                onAction: () => context.go('/services'),
              ),
              const SizedBox(height: 14),

              ...[
                (Icons.content_cut_rounded,  'Hair Transplant',  'FUE / FUT Technique',   'From Rs 80,000', const Color(0xFFE8A94A)),
                (Icons.water_drop_rounded,   'PRP Therapy',      'Platelet Rich Plasma',   'From Rs 12,000', const Color(0xFF5B8DEF)),
                (Icons.spa_rounded,          'Scalp Treatment',  'Deep cleanse & nourish', 'From Rs 4,500',  const Color(0xFF3FA787)),
              ].indexed.map((e) {
                final (idx, s) = e;
                return PressableCard(
                  onTap: () => context.push('/book'),
                  child: _ServiceTile(icon: s.$1, name: s.$2, subtitle: s.$3, price: s.$4, accent: s.$5, p: p),
                ).animate().fadeIn(delay: (200 + idx * 80).ms, duration: 350.ms).slideY(begin: 0.06, end: 0);
              }),
            ])),
          ),
        ],
      ), // end CustomScrollView
      ), // end AnimatedSwitcher
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
//  Hero content — static, passed as AnimatedBuilder.child so it builds once
// ──────────────────────────────────────────────────────────────────────────────
class _HeroContent extends StatelessWidget {
  final AppPalette p;
  final double topPad;
  final List<(IconData, String, String)> quickActions;
  final String profileName;
  final String profileInitials;
  final dynamic avatarBytes; // Uint8List?
  final int appointmentCount, loyaltyPoints;
  final String membershipTier;
  const _HeroContent({required this.p, required this.topPad, required this.quickActions,
    required this.profileName, required this.profileInitials, required this.avatarBytes,
    required this.appointmentCount, required this.loyaltyPoints, required this.membershipTier});

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(20, topPad + 18, 20, 28),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

      // Top row — greeting + avatar
      Row(children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Good Morning,', style: p.body(13, color: p.textMuted))
              .animate().fadeIn(duration: 400.ms).slideX(begin: -0.04, end: 0),
          Text(profileName, style: p.display(26))
              .animate().fadeIn(delay: 80.ms, duration: 400.ms).slideX(begin: -0.04, end: 0),
        ]),
        const Spacer(),
        PressableCard(
          onTap: () => context.go('/notif-tab'),
          child: Stack(children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: kGold.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(color: kGold.withValues(alpha: 0.25)),
              ),
              child: const Icon(Icons.notifications_rounded, color: kGold, size: 22),
            ),
            Positioned(top: 9, right: 9, child: Container(
              width: 8, height: 8,
              decoration: const BoxDecoration(color: kDanger, shape: BoxShape.circle),
            )),
          ]),
        ).animate().fadeIn(delay: 120.ms, duration: 350.ms),
        const SizedBox(width: 10),
        PressableCard(
          onTap: () => context.go('/profile-tab'),
          child: avatarBytes != null
            ? Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: kGold, width: 2),
                  boxShadow: [BoxShadow(color: kGold.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 3))],
                  image: DecorationImage(image: MemoryImage(avatarBytes), fit: BoxFit.cover),
                ),
              )
            : Container(
                width: 44, height: 44,
                decoration: BoxDecoration(gradient: kGoldGradient, shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: kGold.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 3))]),
                child: Center(child: Text(profileInitials, style: p.body(14, color: Colors.black87, weight: FontWeight.w800))),
              ),
        ).animate().fadeIn(delay: 160.ms, duration: 350.ms),
      ]),
      const SizedBox(height: 22),

      // Glass stat row
      Row(children: [
        Expanded(child: _GlassStat(label: 'Upcoming', value: appointmentCount, formatter: (v) => '$v', p: p)),
        const SizedBox(width: 10),
        Expanded(child: _GlassStat(label: 'Loyalty Pts', value: loyaltyPoints, formatter: (v) => v >= 1000 ? '${(v / 1000).toStringAsFixed(1)}k' : '$v', p: p)),
        const SizedBox(width: 10),
        Expanded(child: _GlassStat(label: 'Member', value: 0, formatter: (_) => membershipTier, p: p)),
      ]).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.05, end: 0),
      const SizedBox(height: 22),

      // Quick-action row
      Row(children: quickActions.map((a) => Expanded(child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: _QuickAction(icon: a.$1, label: a.$2, route: a.$3, p: p),
      ))).toList()).animate().fadeIn(delay: 280.ms, duration: 380.ms).slideY(begin: 0.05, end: 0),
    ]),
  );
}

// ──────────────────────────────────────────────────────────────────────────────
//  Glass stat pill with animated counter
// ──────────────────────────────────────────────────────────────────────────────
class _GlassStat extends StatelessWidget {
  final String label;
  final int value;
  final String Function(int) formatter;
  final AppPalette p;
  const _GlassStat({required this.label, required this.value, required this.formatter, required this.p});

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(14),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: p.isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: p.isDark ? Colors.white.withValues(alpha: 0.10) : kGold.withValues(alpha: 0.20)),
          boxShadow: [
            if (p.isDark) BoxShadow(color: kGold.withValues(alpha: 0.05), blurRadius: 12),
            if (!p.isDark) BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(children: [
          AnimatedCounter(
            value: value,
            style: p.body(17, color: kGold, weight: FontWeight.w800),
            formatter: formatter,
          ),
          const SizedBox(height: 3),
          Text(label, style: p.body(11, color: p.isDark ? Colors.white60 : p.textMuted), textAlign: TextAlign.center),
        ]),
      ),
    ),
  );
}

// ──────────────────────────────────────────────────────────────────────────────
//  Quick action button
// ──────────────────────────────────────────────────────────────────────────────
class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label, route;
  final AppPalette p;
  const _QuickAction({required this.icon, required this.label, required this.route, required this.p});

  @override
  Widget build(BuildContext context) => PressableCard(
    onTap: () => context.push(route),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 58, height: 58,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [kGold.withValues(alpha: 0.18), kGold.withValues(alpha: 0.06)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: kGold.withValues(alpha: 0.30)),
          boxShadow: [BoxShadow(color: kGold.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Icon(icon, color: kGold, size: 24),
      ),
      const SizedBox(height: 8),
      Text(label, style: p.body(12, weight: FontWeight.w600, color: p.isDark ? Colors.white70 : p.textMuted), textAlign: TextAlign.center),
    ]),
  );
}

// ──────────────────────────────────────────────────────────────────────────────
//  Upcoming appointment card — live data
// ──────────────────────────────────────────────────────────────────────────────
class _UpcomingCard extends StatelessWidget {
  final AppPalette p;
  final HaAppointment? appt;
  const _UpcomingCard({required this.p, this.appt});

  @override
  Widget build(BuildContext context) {
    if (appt == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: p.surface, borderRadius: BorderRadius.circular(18),
          border: Border.all(color: p.border),
        ),
        child: Row(children: [
          Container(width: 52, height: 52, decoration: BoxDecoration(color: kGold.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(15), border: Border.all(color: kGold.withValues(alpha: 0.2))),
            child: const Icon(Icons.calendar_today_outlined, color: kGold, size: 22)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('No upcoming appointments', style: p.body(14, weight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text('Book your next session today', style: p.body(12, color: p.textMuted)),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(gradient: kGoldGradient, borderRadius: BorderRadius.circular(10)),
            child: Text('Book', style: p.body(12, color: Colors.black87, weight: FontWeight.w700)),
          ),
        ]),
      );
    }
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [kGold.withValues(alpha: p.isDark ? 0.12 : 0.08), p.surface], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kGold.withValues(alpha: 0.28)),
        boxShadow: [
          BoxShadow(color: kGold.withValues(alpha: 0.10), blurRadius: 20, offset: const Offset(0, 6)),
          if (!p.isDark) BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(children: [
        Container(width: 52, height: 52,
          decoration: BoxDecoration(gradient: kGoldGradient, borderRadius: BorderRadius.circular(15),
            boxShadow: [BoxShadow(color: kGold.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 3))]),
          child: const Icon(Icons.event_rounded, color: Colors.black87, size: 24)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(appt!.title, style: p.body(14, weight: FontWeight.w700), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 3),
          Text(appt!.doctor, style: p.body(12, color: p.textMuted)),
          const SizedBox(height: 3),
          Row(children: [
            const Icon(Icons.schedule_rounded, size: 13, color: kGold),
            const SizedBox(width: 4),
            Flexible(child: Text('${appt!.shortDate} • ${appt!.slot}', style: p.body(12, color: kGold, weight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
          ]),
        ])),
        StatusBadge(label: appt!.status, color: appt!.statusColor),
      ]),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
//  Promo carousel — auto-scroll + dot indicator
// ──────────────────────────────────────────────────────────────────────────────
class _PromoCarousel extends StatefulWidget {
  final AppPalette p;
  const _PromoCarousel({required this.p});
  @override
  State<_PromoCarousel> createState() => _PromoCarouselState();
}

class _PromoCarouselState extends State<_PromoCarousel> {
  final _ctrl = PageController();
  Timer? _timer;
  int _page = 0;

  static const _slides = [
    _Slide(badge: 'LIMITED OFFER', title: '20% off PRP\nTherapy', sub: 'This month only — book now',
        cta: 'Book Now', route: '/book', icon: Icons.water_drop_rounded,
        colors: [Color(0xFF1A1300), Color(0xFF0D0800)]),
    _Slide(badge: 'NEW SERVICE', title: 'Stem Cell\nHair Therapy', sub: 'Cutting-edge follicle regeneration',
        cta: 'Learn More', route: '/services', icon: Icons.biotech_rounded,
        colors: [Color(0xFF0A1520), Color(0xFF061018)]),
    _Slide(badge: 'FREE TODAY', title: 'Free Scalp\nConsultation', sub: 'Walk in or book online',
        cta: 'Claim Offer', route: '/book', icon: Icons.spa_rounded,
        colors: [Color(0xFF120A1A), Color(0xFF0A0612)]),
    _Slide(badge: 'LOYALTY BONUS', title: '2x Points on\nAll Treatments', sub: 'This weekend only',
        cta: 'Book Now', route: '/book', icon: Icons.stars_rounded,
        colors: [Color(0xFF1A1400), Color(0xFF0E0B00)]),
  ];

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      final next = (_page + 1) % _slides.length;
      _ctrl.animateToPage(next, duration: const Duration(milliseconds: 500), curve: Curves.easeInOutCubic);
    });
  }

  @override
  void dispose() { _timer?.cancel(); _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    return Column(children: [
      SizedBox(
        height: 160,
        child: PageView.builder(
          controller: _ctrl,
          onPageChanged: (i) => setState(() => _page = i),
          itemCount: _slides.length,
          itemBuilder: (ctx, i) {
            final s = _slides[i];
            return GestureDetector(
              onTap: () => ctx.push(s.route),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: s.colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: kGold.withValues(alpha: 0.22)),
                  boxShadow: [BoxShadow(color: kGold.withValues(alpha: 0.10), blurRadius: 20, offset: const Offset(0, 6))],
                ),
                child: Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(gradient: kGoldGradient, borderRadius: BorderRadius.circular(5)),
                      child: Text(s.badge, style: const TextStyle(fontSize: 9, color: Colors.black87, fontWeight: FontWeight.w800, letterSpacing: 0.9)),
                    ),
                    const SizedBox(height: 10),
                    Text(s.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white, height: 1.25)),
                    const SizedBox(height: 6),
                    Text(s.sub, style: p.body(11, color: Colors.white60)),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(gradient: kGoldGradient, borderRadius: BorderRadius.circular(10),
                        boxShadow: [BoxShadow(color: kGold.withValues(alpha: 0.35), blurRadius: 8, offset: const Offset(0, 3))]),
                      child: Text(s.cta, style: const TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w700)),
                    ),
                  ])),
                  const SizedBox(width: 12),
                  Container(width: 70, height: 70,
                    decoration: BoxDecoration(color: kGold.withValues(alpha: 0.10), shape: BoxShape.circle,
                      border: Border.all(color: kGold.withValues(alpha: 0.22)),
                      boxShadow: [BoxShadow(color: kGold.withValues(alpha: 0.12), blurRadius: 14)]),
                    child: Icon(s.icon, color: kGold, size: 32)),
                ]),
              ),
            );
          },
        ),
      ),
      const SizedBox(height: 10),
      // Dot indicators
      Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(_slides.length, (i) {
        final active = i == _page;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 20 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: active ? kGold : kGold.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      })),
    ]);
  }
}

class _Slide {
  final String badge, title, sub, cta, route;
  final IconData icon;
  final List<Color> colors;
  const _Slide({required this.badge, required this.title, required this.sub, required this.cta, required this.route, required this.icon, required this.colors});
}

// ──────────────────────────────────────────────────────────────────────────────
//  Service tile — gradient icon box
// ──────────────────────────────────────────────────────────────────────────────
class _ServiceTile extends StatelessWidget {
  final IconData icon;
  final String name, subtitle, price;
  final Color accent;
  final AppPalette p;
  const _ServiceTile({required this.icon, required this.name, required this.subtitle, required this.price, required this.accent, required this.p});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: p.surface,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: p.border),
      boxShadow: [
        if (!p.isDark) BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3)),
        BoxShadow(color: accent.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 4)),
      ],
    ),
    child: Row(children: [
      Container(
        width: 48, height: 48,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [accent.withValues(alpha: 0.18), accent.withValues(alpha: 0.06)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: accent.withValues(alpha: 0.20)),
        ),
        child: Icon(icon, color: accent, size: 23),
      ),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(name, style: p.body(15, weight: FontWeight.w700)),
        const SizedBox(height: 3),
        Text(subtitle, style: p.body(12, color: p.textMuted)),
      ])),
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text(price, style: p.body(12, color: kGold, weight: FontWeight.w700)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(color: kGold.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
          child: const Icon(Icons.arrow_forward_ios_rounded, size: 10, color: kGold),
        ),
      ]),
    ]),
  );
}

// ──────────────────────────────────────────────────────────────────────────────
//  Shimmer skeleton — shown for ~1.6 s before real content fades in
// ──────────────────────────────────────────────────────────────────────────────
class _ShimmerBody extends StatelessWidget {
  final AppPalette p;
  final double topPad;
  const _ShimmerBody({super.key, required this.p, required this.topPad});

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    physics: const NeverScrollableScrollPhysics(),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Hero skeleton
      Container(
        padding: EdgeInsets.fromLTRB(20, topPad + 18, 20, 28),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ShimmerBox(width: 100, height: 12, radius: 6),
              const SizedBox(height: 8),
              ShimmerBox(width: 160, height: 22, radius: 8),
            ]),
            const Spacer(),
            ShimmerBox(width: 44, height: 44, radius: 22),
            const SizedBox(width: 10),
            ShimmerBox(width: 44, height: 44, radius: 22),
          ]),
          const SizedBox(height: 22),
          Row(children: [
            Expanded(child: ShimmerBox(height: 62, radius: 14)),
            const SizedBox(width: 10),
            Expanded(child: ShimmerBox(height: 62, radius: 14)),
            const SizedBox(width: 10),
            Expanded(child: ShimmerBox(height: 62, radius: 14)),
          ]),
          const SizedBox(height: 22),
          Row(children: List.generate(4, (i) => Expanded(child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(children: [
              ShimmerBox(width: 58, height: 58, radius: 18),
              const SizedBox(height: 8),
              ShimmerBox(width: 40, height: 10, radius: 5),
            ]),
          )))),
        ]),
      ),
      // Body skeleton
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ShimmerBox(width: 180, height: 14, radius: 7),
          const SizedBox(height: 14),
          const ShimmerCard(height: 86),
          const SizedBox(height: 28),
          ShimmerBox(width: 160, height: 14, radius: 7),
          const SizedBox(height: 14),
          const ShimmerCard(height: 110),
          const SizedBox(height: 28),
          Row(children: [
            ShimmerBox(width: 140, height: 14, radius: 7),
            const Spacer(),
            ShimmerBox(width: 50, height: 12, radius: 6),
          ]),
          const SizedBox(height: 14),
          const ShimmerTile(),
          const ShimmerTile(),
          const ShimmerTile(),
        ]),
      ),
    ]),
  );
}
