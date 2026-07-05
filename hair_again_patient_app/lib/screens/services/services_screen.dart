import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../../../core/widgets.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});
  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  String _selected = 'All';
  String _search = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _loading = false);
    });
  }

  static const _categories = ['All', 'Transplant', 'PRP', 'Scalp', 'Laser', 'Consultation'];

  static const _services = [
    _Svc('FUE Hair Transplant', 'Follicular Unit Extraction — minimum scarring, natural results.', Icons.content_cut_outlined, 'Transplant', 'From Rs 80,000', '4.9', 92),
    _Svc('FUT Hair Transplant', 'Strip harvesting for maximum graft density.', Icons.content_cut_outlined, 'Transplant', 'From Rs 60,000', '4.8', 67),
    _Svc('PRP Therapy', 'Platelet Rich Plasma — stimulates follicle growth naturally.', Icons.water_drop_outlined, 'PRP', 'From Rs 12,000', '4.7', 134),
    _Svc('Mesotherapy', 'Microinjections of nutrients directly into the scalp.', Icons.medical_services_outlined, 'PRP', 'From Rs 8,000', '4.6', 88),
    _Svc('Scalp Micropigmentation', 'Cosmetic tattooing that mimics hair follicles.', Icons.brush_outlined, 'Scalp', 'From Rs 25,000', '4.9', 45),
    _Svc('Deep Scalp Cleanse', 'Detox treatment removing buildup and excess oil.', Icons.spa_outlined, 'Scalp', 'From Rs 4,500', '4.5', 210),
    _Svc('Low-Level Laser Therapy', 'LLLT caps to stimulate hair regrowth.', Icons.flash_on_outlined, 'Laser', 'From Rs 6,000', '4.4', 56),
    _Svc('Hair & Scalp Analysis', 'Trichoscopy and digital scalp assessment.', Icons.biotech_outlined, 'Consultation', 'Rs 2,500', '4.8', 175),
    _Svc('Hair Loss Consultation', 'One-on-one with our specialist to plan your treatment.', Icons.person_outlined, 'Consultation', 'Rs 1,500', '5.0', 320),
  ];

  List<_Svc> get _filtered => _services.where((s) {
    final matchCat = _selected == 'All' || s.category == _selected;
    final matchQ = _search.isEmpty || s.name.toLowerCase().contains(_search.toLowerCase());
    return matchCat && matchQ;
  }).toList();

  @override
  Widget build(BuildContext context) {
    final p = HaTheme.of(context);
    final list = _filtered;
    return Scaffold(
      backgroundColor: p.bg,
      appBar: KAppBar(title: 'Our Services', showBack: false),
      body: Column(children: [
        // Search
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: TextField(
            style: p.body(14),
            onChanged: (v) => setState(() => _search = v),
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search, size: 20, color: p.textMuted),
              hintText: 'Search services…',
              hintStyle: p.body(14, color: p.textMuted),
              filled: true,
              fillColor: p.surfaceAlt,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: p.border)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: p.border)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kGold, width: 1.5)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
        // Category chips
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: SizedBox(height: 36, child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 20), children: _categories.map((c) {
            final sel = c == _selected;
            return GestureDetector(
              onTap: () => setState(() => _selected = c),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: sel ? kGold : p.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: sel ? kGold : p.border),
                ),
                alignment: Alignment.center,
                child: Text(c, style: p.body(13, color: sel ? Colors.black87 : p.textMuted, weight: sel ? FontWeight.w600 : FontWeight.w400)),
              ),
            );
          }).toList())),
        ),
        Container(height: 1, color: p.border),

        // List
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 450),
            child: _loading
              ? ListView(key: const ValueKey('shimmer'), padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                  children: List.generate(5, (_) => const ShimmerTile()))
              : list.isEmpty
                ? const EmptyState(icon: Icons.search_off, title: 'No Services Found', subtitle: 'Try a different search or category.')
                : ListView.separated(
                    key: const ValueKey('list'),
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _ServiceCard(svc: list[i]),
                  ),
          ),
        ),
      ]),
    );
  }
}

class _Svc {
  final String name, description, category, price, rating;
  final IconData icon;
  final int reviews;
  const _Svc(this.name, this.description, this.icon, this.category, this.price, this.rating, this.reviews);
}

class _ServiceCard extends StatelessWidget {
  final _Svc svc;
  const _ServiceCard({super.key, required this.svc});

  @override
  Widget build(BuildContext context) {
    final p = HaTheme.of(context);
    return GestureDetector(
      onTap: () => context.push('/book'),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: p.border),
          boxShadow: [if (!p.isDark) BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 52, height: 52, decoration: BoxDecoration(color: kGold.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)), child: Icon(svc.icon, color: kGold, size: 24)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(svc.name, style: p.body(15, weight: FontWeight.w700))),
              StatusBadge(label: svc.category, color: kGold),
            ]),
            const SizedBox(height: 5),
            Text(svc.description, style: p.body(12, color: p.textMuted), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 10),
            Row(children: [
              Icon(Icons.star_rounded, color: Colors.amber.shade400, size: 16),
              const SizedBox(width: 4),
              Text('${svc.rating} (${svc.reviews})', style: p.body(12, color: p.textMuted)),
              const Spacer(),
              Text(svc.price, style: p.body(14, color: kGold, weight: FontWeight.w700)),
            ]),
          ])),
        ]),
      ),
    );
  }
}
