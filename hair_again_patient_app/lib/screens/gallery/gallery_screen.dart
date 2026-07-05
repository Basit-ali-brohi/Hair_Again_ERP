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
    _Case('FUE Transplant', 'Male, 45', '8 months', '2,800 grafts — hairline restoration', kSuccess),
    _Case('PRP Therapy', 'Female, 32', '6 months', '4 sessions — density increase', kInfo),
    _Case('Hair Transplant', 'Male, 29', '14 months', '3,500 grafts — full crown', kGold),
    _Case('Scalp Micropigmentation', 'Male, 41', 'Immediate', 'Shaved head effect', kWarning),
    _Case('PRP Therapy', 'Female, 28', '4 months', '3 sessions — postpartum hair loss', kInfo),
  ];

  List<_Case> get _filtered => _filter == 'All' ? _cases : _cases.where((c) => c.treatment == _filter).toList();

  @override
  Widget build(BuildContext context) {
    final p = HaTheme.of(context);
    final list = _filtered;
    return Scaffold(
      backgroundColor: p.bg,
      appBar: const KAppBar(title: 'Before & After Gallery'),
      body: Column(children: [
        // Filter chips
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: SizedBox(height: 36, child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 20), children: _filters.map((f) {
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
                child: Text(f, style: p.body(13, color: sel ? Colors.black87 : p.textMuted, weight: sel ? FontWeight.w600 : FontWeight.w400)),
              ),
            );
          }).toList())),
        ),
        Container(height: 1, color: p.border),

        Expanded(child: list.isEmpty
          ? const EmptyState(icon: Icons.photo_library_outlined, title: 'No Results', subtitle: 'Try a different filter.')
          : GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.75),
              itemCount: list.length,
              itemBuilder: (_, i) => _GalleryCard(case_: list[i], index: i),
            ),
        ),
      ]),
    );
  }
}

class _Case {
  final String treatment, patient, timeline, description;
  final Color color;
  const _Case(this.treatment, this.patient, this.timeline, this.description, this.color);
}

class _GalleryCard extends StatelessWidget {
  final _Case case_;
  final int index;
  const _GalleryCard({super.key, required this.case_, required this.index});

  @override
  Widget build(BuildContext context) {
    final p = HaTheme.of(context);
    return GestureDetector(
      onTap: () => _showDetail(context, p),
      child: Container(
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: p.border),
          boxShadow: [if (!p.isDark) BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Photo placeholder with before/after split
          Expanded(child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Stack(children: [
              Row(children: [
                Expanded(child: Container(
                  color: case_.color.withValues(alpha: p.isDark ? 0.08 : 0.05),
                  child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.face_outlined, color: case_.color.withValues(alpha: 0.4), size: 32),
                    const SizedBox(height: 4),
                    Text('Before', style: p.body(10, color: p.textMuted)),
                  ])),
                )),
                Container(width: 1, color: p.border),
                Expanded(child: Container(
                  color: case_.color.withValues(alpha: p.isDark ? 0.18 : 0.1),
                  child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.face_retouching_natural_outlined, color: case_.color, size: 32),
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
        GoldButton(label: 'Book Same Treatment', onTap: () { Navigator.pop(context); }),
        const SizedBox(height: 12),
      ]),
    ),
  );
}
