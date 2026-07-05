import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../core/widgets.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});
  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  String _filter = 'All';
  static const _filters = ['All', 'Hair Transplant', 'PRP', 'Scalp', 'Micropigmentation'];

  static const _cases = [
    _Case('Hair Transplant', 'Male, 38', '12 months', '3,200 grafts — FUE', kSuccess),
    _Case('FUE Transplant',  'Male, 45', '8 months',  '2,800 grafts — hairline restoration', kSuccess),
    _Case('PRP Therapy',     'Female, 32', '6 months', '4 sessions — density increase', kInfo),
    _Case('Hair Transplant', 'Male, 29', '14 months', '3,500 grafts — full crown', kGold),
    _Case('Scalp Micropigmentation', 'Male, 41', 'Immediate', 'Shaved head effect', kWarning),
    _Case('PRP Therapy',     'Female, 28', '4 months', '3 sessions — postpartum hair loss', kInfo),
  ];

  List<_Case> get _filtered =>
      _filter == 'All' ? _cases : _cases.where((c) => c.treatment == _filter).toList();

  @override
  Widget build(BuildContext context) {
    final p = HaTheme.of(context);
    final list = _filtered;

    return Scaffold(
      backgroundColor: p.bg,
      appBar: const KAppBar(title: 'Before & After Gallery'),
      body: Column(children: [
        // ── Featured interactive slider ──────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(gradient: kGoldGradient, borderRadius: BorderRadius.circular(6)),
                child: const Text('FEATURED CASE', style: TextStyle(fontSize: 10, color: Colors.black87, fontWeight: FontWeight.w800, letterSpacing: 0.8)),
              ),
              const SizedBox(width: 10),
              Text('Drag to compare', style: p.body(12, color: p.textMuted)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: kSuccess.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                child: Text('14 months', style: p.body(11, color: kSuccess, weight: FontWeight.w700)),
              ),
            ]),
            const SizedBox(height: 10),
            BeforeAfterSlider(
              height: 280,
              initialSplit: 0.40,
              before: _BeforePanel(p: p),
              after:  _AfterPanel(p: p),
            ),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _StatPill(icon: Icons.content_cut_rounded, label: '3,500 Grafts', p: p)),
              const SizedBox(width: 8),
              Expanded(child: _StatPill(icon: Icons.person_rounded, label: 'Male, 29', p: p)),
              const SizedBox(width: 8),
              Expanded(child: _StatPill(icon: Icons.medical_services_rounded, label: 'FUE Technique', p: p)),
            ]),
          ]),
        ),

        // ── Filter chips ─────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: SizedBox(height: 36, child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: _filters.map((f) {
              final sel = f == _filter;
              return GestureDetector(
                onTap: () => setState(() => _filter = f),
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
                  child: Text(f, style: p.body(13,
                    color: sel ? Colors.black87 : p.textMuted,
                    weight: sel ? FontWeight.w600 : FontWeight.w400)),
                ),
              );
            }).toList(),
          )),
        ),
        Container(height: 1, color: p.border),

        // ── Grid ─────────────────────────────────────────────────────────────
        Expanded(child: list.isEmpty
          ? const EmptyState(icon: Icons.photo_library_outlined, title: 'No Results', subtitle: 'Try a different filter.')
          : GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.75),
              itemCount: list.length,
              itemBuilder: (_, i) => _GalleryCard(case_: list[i]),
            ),
        ),
      ]),
    );
  }
}

// ── Featured slider panels ──────────────────────────────────────────────────────
class _BeforePanel extends StatelessWidget {
  final AppPalette p;
  const _BeforePanel({required this.p});

  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xFF1C1208), Color(0xFF2D1E0C), Color(0xFF1A1106)],
        begin: Alignment.topLeft, end: Alignment.bottomRight,
      ),
    ),
    child: Stack(children: [
      // Sparse dot pattern — representing thinning follicles
      for (int row = 0; row < 7; row++)
        for (int col = 0; col < 5; col++)
          if ((row + col) % 2 == 0)
            Positioned(
              left: 28.0 + col * 42,
              top:  36.0 + row * 34,
              child: Container(
                width: (row * col % 3 == 0) ? 3 : 2,
                height: (row * col % 3 == 0) ? 3 : 2,
                decoration: BoxDecoration(
                  color: const Color(0xFF8B6B3D).withValues(alpha: 0.45),
                  shape: BoxShape.circle,
                ),
              ),
            ),
      // Label overlay
      Positioned(top: 16, left: 0, right: 0,
        child: Center(child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text('Thinning — Stage III', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.3)),
        )),
      ),
      // Center icon
      Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.person_outline_rounded, size: 72, color: Colors.white.withValues(alpha: 0.08)),
      ])),
    ]),
  );
}

class _AfterPanel extends StatelessWidget {
  final AppPalette p;
  const _AfterPanel({required this.p});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [const Color(0xFF1A1200), kGoldDark.withValues(alpha: 0.55), const Color(0xFF0E0900)],
        begin: Alignment.topLeft, end: Alignment.bottomRight,
      ),
    ),
    child: Stack(children: [
      // Dense dot pattern — full healthy follicles
      for (int row = 0; row < 8; row++)
        for (int col = 0; col < 7; col++)
          Positioned(
            left: 20.0 + col * 32,
            top:  24.0 + row * 30,
            child: Container(
              width: 3, height: 3,
              decoration: BoxDecoration(
                color: kGold.withValues(alpha: 0.35),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: kGold.withValues(alpha: 0.15), blurRadius: 4)],
              ),
            ),
          ),
      // Glow
      Center(child: Container(
        width: 140, height: 140,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [kGold.withValues(alpha: 0.12), Colors.transparent]),
        ),
      )),
      // Label overlay
      Positioned(top: 16, left: 0, right: 0,
        child: Center(child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(gradient: kGoldGradient, borderRadius: BorderRadius.circular(8)),
          child: const Text('Full Coverage Restored', style: TextStyle(color: Colors.black87, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.3)),
        )),
      ),
      Center(child: Icon(Icons.person_rounded, size: 72, color: kGold.withValues(alpha: 0.18))),
    ]),
  );
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final AppPalette p;
  const _StatPill({required this.icon, required this.label, required this.p});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: BoxDecoration(
      color: p.surface,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: p.border),
    ),
    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(icon, size: 13, color: kGold),
      const SizedBox(width: 5),
      Flexible(child: Text(label, style: p.body(11, color: p.textMuted, weight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
    ]),
  );
}

// ── Data model ──────────────────────────────────────────────────────────────────
class _Case {
  final String treatment, patient, timeline, description;
  final Color color;
  const _Case(this.treatment, this.patient, this.timeline, this.description, this.color);
}

// ── Gallery card ────────────────────────────────────────────────────────────────
class _GalleryCard extends StatelessWidget {
  final _Case case_;
  const _GalleryCard({super.key, required this.case_});

  @override
  Widget build(BuildContext context) {
    final p = HaTheme.of(context);
    return PressableCard(
      onTap: () => _showDetail(context, p),
      child: Container(
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: p.border),
          boxShadow: [if (!p.isDark) BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Stack(children: [
              Row(children: [
                Expanded(child: Container(
                  color: case_.color.withValues(alpha: p.isDark ? 0.07 : 0.05),
                  child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.face_outlined, color: case_.color.withValues(alpha: 0.35), size: 30),
                    const SizedBox(height: 4),
                    Text('Before', style: p.body(10, color: p.textMuted)),
                  ])),
                )),
                Container(width: 1, color: p.border),
                Expanded(child: Container(
                  color: case_.color.withValues(alpha: p.isDark ? 0.18 : 0.10),
                  child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.face_retouching_natural_outlined, color: case_.color, size: 30),
                    const SizedBox(height: 4),
                    Text('After', style: p.body(10, color: case_.color.withValues(alpha: 0.8))),
                  ])),
                )),
              ]),
              Positioned(top: 8, right: 8, child: StatusBadge(label: case_.timeline, color: case_.color)),
            ]),
          )),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(case_.treatment, style: p.body(13, weight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 3),
              Text(case_.patient, style: p.body(11, color: p.textMuted)),
              const SizedBox(height: 4),
              Text(case_.description, style: p.body(10, color: p.textMuted), maxLines: 2, overflow: TextOverflow.ellipsis),
            ]),
          ),
        ]),
      ),
    );
  }

  void _showDetail(BuildContext context, AppPalette p) => showModalBottomSheet(
    context: context, backgroundColor: p.surface, isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (_) => Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(case_.treatment, style: p.display(20)),
          const Spacer(),
          StatusBadge(label: case_.timeline, color: case_.color),
        ]),
        const SizedBox(height: 8),
        Text(case_.patient, style: p.body(13, color: p.textMuted)),
        const SizedBox(height: 16),
        Text(case_.description, style: p.body(14)),
        const SizedBox(height: 24),
        GoldButton(label: 'Book Same Treatment', onTap: () => Navigator.pop(context)),
        const SizedBox(height: 12),
      ]),
    ),
  );
}
