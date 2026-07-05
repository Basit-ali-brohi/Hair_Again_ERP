import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../core/widgets.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});
  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> with SingleTickerProviderStateMixin {
  late final TabController _tab;
  double _myRating = 0;
  final _reviewCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void initState() { super.initState(); _tab = TabController(length: 2, vsync: this); }
  @override
  void dispose() { _tab.dispose(); _reviewCtrl.dispose(); super.dispose(); }

  static const _reviews = [
    _Review('Ahmed K.', 5, 'Exceptional results! My FUE transplant exceeded all expectations. Dr. Bilal is highly skilled and the staff is incredibly supportive.', 'FUE Hair Transplant', '12 Mar 2026'),
    _Review('Sara M.', 5, 'PRP therapy made a significant difference in hair density. Visible improvement after just 3 sessions. Highly recommend!', 'PRP Therapy', '5 Feb 2026'),
    _Review('Imran T.', 4, 'Professional team and clean facility. The treatment process was smooth, though I\'d appreciate more post-treatment follow-up.', 'Scalp Micropigmentation', '20 Jan 2026'),
    _Review('Fatima R.', 5, 'Life-changing experience. Lost hope of regaining my hair but Hair Again gave me confidence back. Thank you!', 'FUE Hair Transplant', '15 Dec 2025'),
    _Review('Zain A.', 4, 'Good service and friendly staff. Results are coming in slowly but the team assured me this is normal for PRP.', 'PRP Therapy', '8 Nov 2025'),
  ];

  double get _avgRating => _reviews.fold(0, (s, r) => s + r.rating) / _reviews.length;

  Map<int, int> get _distribution {
    final map = <int, int>{5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (final r in _reviews) map[r.rating] = (map[r.rating] ?? 0) + 1;
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final p = HaTheme.of(context);
    return Scaffold(
      backgroundColor: p.bg,
      appBar: const KAppBar(title: 'Reviews'),
      body: Column(children: [
        TabBar(
          controller: _tab,
          indicatorColor: kGold, labelColor: kGold, unselectedLabelColor: p.textMuted,
          labelStyle: p.body(14, weight: FontWeight.w600), unselectedLabelStyle: p.body(14),
          dividerColor: p.border,
          tabs: const [Tab(text: 'All Reviews'), Tab(text: 'Write a Review')],
        ),
        Expanded(child: TabBarView(controller: _tab, children: [_buildList(p), _buildForm(p)])),
      ]),
    );
  }

  Widget _buildList(AppPalette p) => ListView(padding: const EdgeInsets.fromLTRB(20, 20, 20, 40), children: [
    // Rating summary
    Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: p.border),
        boxShadow: [if (!p.isDark) BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(children: [
        Column(children: [
          Text(_avgRating.toStringAsFixed(1), style: p.display(48, color: kGold)),
          _StarRow(_avgRating.round()),
          const SizedBox(height: 4),
          Text('${_reviews.length} reviews', style: p.body(12, color: p.textMuted)),
        ]),
        const SizedBox(width: 24),
        Expanded(child: Column(children: [5, 4, 3, 2, 1].map((star) {
          final count = _distribution[star] ?? 0;
          final frac = _reviews.isEmpty ? 0.0 : count / _reviews.length;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(children: [
              Text('$star', style: p.body(12, color: p.textMuted)),
              const SizedBox(width: 6),
              const Icon(Icons.star_rounded, size: 12, color: kGold),
              const SizedBox(width: 6),
              Expanded(child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(value: frac, minHeight: 6, backgroundColor: p.border, valueColor: const AlwaysStoppedAnimation<Color>(kGold)),
              )),
              const SizedBox(width: 8),
              Text('$count', style: p.body(11, color: p.textMuted)),
            ]),
          );
        }).toList())),
      ]),
    ),
    const SizedBox(height: 20),

    ..._reviews.map((r) => _ReviewCard(review: r)),
  ]);

  Widget _buildForm(AppPalette p) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Share Your Experience', style: p.display(22)),
      const SizedBox(height: 6),
      Text('Your feedback helps other patients make informed decisions.', style: p.body(13, color: p.textMuted)),
      const SizedBox(height: 28),

      Text('RATING', style: p.label(11)),
      const SizedBox(height: 10),
      Row(children: List.generate(5, (i) => GestureDetector(
        onTap: () => setState(() => _myRating = i + 1),
        child: Padding(
          padding: const EdgeInsets.only(right: 6),
          child: Icon(i < _myRating ? Icons.star_rounded : Icons.star_outline_rounded, color: kGold, size: 36),
        ),
      ))),
      if (_myRating > 0) ...[
        const SizedBox(height: 6),
        Text([
          '', 'Poor', 'Fair', 'Good', 'Very Good', 'Excellent'
        ][_myRating.toInt()], style: p.body(13, color: kGold, weight: FontWeight.w600)),
      ],
      const SizedBox(height: 24),

      Text('TREATMENT', style: p.label(11)),
      const SizedBox(height: 10),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: p.border)),
        child: DropdownButtonHideUnderline(child: DropdownButton<String>(
          isExpanded: true,
          value: 'PRP Therapy',
          dropdownColor: p.surface,
          style: p.body(14),
          icon: Icon(Icons.keyboard_arrow_down, color: p.textMuted),
          items: ['PRP Therapy', 'FUE Hair Transplant', 'Scalp Micropigmentation', 'Consultation'].map((s) =>
            DropdownMenuItem(value: s, child: Text(s, style: p.body(14)))).toList(),
          onChanged: (_) {},
        )),
      ),
      const SizedBox(height: 20),

      Text('REVIEW', style: p.label(11)),
      const SizedBox(height: 10),
      Container(
        decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: p.border)),
        child: TextField(
          controller: _reviewCtrl,
          style: p.body(14),
          maxLines: 5,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            hintText: 'Tell us about your experience…',
            hintStyle: p.body(14, color: p.textMuted),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ),
      const SizedBox(height: 32),

      GoldButton(
        label: 'Submit Review',
        loading: _submitting,
        onTap: () async {
          if (_myRating == 0 || _reviewCtrl.text.trim().isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add a rating and write your review.'), backgroundColor: kDanger));
            return;
          }
          setState(() => _submitting = true);
          await Future.delayed(const Duration(seconds: 2));
          if (!mounted) return;
          setState(() { _submitting = false; _myRating = 0; _reviewCtrl.clear(); });
          _tab.animateTo(0);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Review submitted. Thank you!'), backgroundColor: kSuccess));
        },
      ),
    ]),
  );
}

class _StarRow extends StatelessWidget {
  final int count;
  const _StarRow(this.count);
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: List.generate(5, (i) => Icon(i < count ? Icons.star_rounded : Icons.star_outline_rounded, color: kGold, size: 14)));
}

class _Review {
  final String author, treatment, date;
  final int rating;
  final String body;
  const _Review(this.author, this.rating, this.body, this.treatment, this.date);
}

class _ReviewCard extends StatelessWidget {
  final _Review review;
  const _ReviewCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    final p = HaTheme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: p.border),
        boxShadow: [if (!p.isDark) BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 38, height: 38, decoration: BoxDecoration(color: kGold.withValues(alpha: 0.15), shape: BoxShape.circle), child: Center(child: Text(review.author[0], style: p.body(16, color: kGold, weight: FontWeight.w700)))),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(review.author, style: p.body(14, weight: FontWeight.w700)),
            Text(review.treatment, style: p.body(11, color: p.textMuted)),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            _StarRow(review.rating),
            const SizedBox(height: 2),
            Text(review.date, style: p.body(11, color: p.textMuted)),
          ]),
        ]),
        const SizedBox(height: 12),
        Text(review.body, style: p.body(13, color: p.text.withValues(alpha: 0.85))),
      ]),
    );
  }
}
