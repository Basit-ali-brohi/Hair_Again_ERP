import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme.dart';

// ── Gold CTA button ─────────────────────────────────────────────────────────────
class GoldButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool fullWidth;
  final IconData? icon;
  final bool loading;
  const GoldButton({super.key, required this.label, required this.onTap, this.fullWidth = true, this.icon, this.loading = false});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: loading ? null : onTap,
    child: Container(
      height: 52, width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(gradient: kGoldGradient, borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: kGold.withValues(alpha: 0.25), blurRadius: 12, offset: const Offset(0, 4))]),
      child: loading
          ? const Center(child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.black87, strokeWidth: 2.5)))
          : Row(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min, children: [
              if (icon != null) ...[Icon(icon, size: 18, color: Colors.black87), const SizedBox(width: 8)],
              Text(label, style: kBody(15, color: Colors.black87, weight: FontWeight.w700)),
            ]),
    ),
  );
}

// ── Outline button ──────────────────────────────────────────────────────────────
class OutlineBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color? color;
  const OutlineBtn({super.key, required this.label, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final p = HaTheme.of(context);
    final c = color ?? p.textMuted;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52, width: double.infinity, alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: color?.withValues(alpha: 0.4) ?? p.border),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(label, style: p.body(15, weight: FontWeight.w600, color: c)),
      ),
    );
  }
}

// ── Section header row ──────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  const SectionHeader({super.key, required this.title, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    final p = HaTheme.of(context);
    return Row(children: [
      Text(title, style: p.body(16, weight: FontWeight.w700)),
      const Spacer(),
      if (action != null) GestureDetector(onTap: onAction, child: Text(action!, style: p.body(13, color: kGold, weight: FontWeight.w600))),
    ]);
  }
}

// ── Custom app bar ──────────────────────────────────────────────────────────────
class KAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBack;
  final VoidCallback? onBack;
  const KAppBar({super.key, required this.title, this.actions, this.showBack = true, this.onBack});

  @override
  Size get preferredSize => const Size.fromHeight(57);

  @override
  Widget build(BuildContext context) {
    final p = HaTheme.of(context);
    return Column(mainAxisSize: MainAxisSize.min, children: [
      AppBar(
        backgroundColor: p.surface,
        elevation: 0, centerTitle: true,
        automaticallyImplyLeading: false,
        leading: showBack ? IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 18, color: p.text),
          onPressed: onBack ?? () => Navigator.of(context).maybePop(),
        ) : null,
        title: Text(title, style: p.body(17, weight: FontWeight.w700)),
        actions: actions,
      ),
      Container(height: 1, color: p.border),
    ]);
  }
}

// ── Status badge ────────────────────────────────────────────────────────────────
class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const StatusBadge({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
    child: Text(label, style: kBody(11, color: color, weight: FontWeight.w600)),
  );
}

// ── Empty state ─────────────────────────────────────────────────────────────────
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const EmptyState({super.key, required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final p = HaTheme.of(context);
    return Center(child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, size: 64, color: p.textMuted.withValues(alpha: 0.4)),
        const SizedBox(height: 20),
        Text(title, style: p.body(18, weight: FontWeight.w700), textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text(subtitle, style: p.body(13, color: p.textMuted), textAlign: TextAlign.center),
      ]),
    ));
  }
}

// ── Divider with label ──────────────────────────────────────────────────────────
class DividerLabel extends StatelessWidget {
  final String text;
  const DividerLabel({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final p = HaTheme.of(context);
    return Row(children: [
      Expanded(child: Divider(color: p.border)),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text(text, style: p.body(12, color: p.textMuted))),
      Expanded(child: Divider(color: p.border)),
    ]);
  }
}

// ── Info row ────────────────────────────────────────────────────────────────────
class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const InfoRow({super.key, required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final p = HaTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(children: [
        Icon(icon, size: 18, color: kGold),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: p.body(13, color: p.textMuted))),
        Text(value, style: p.body(13, weight: FontWeight.w600)),
      ]),
    );
  }
}

// ── Pressable card — spring scale on tap ────────────────────────────────────────
class PressableCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double pressScale;
  const PressableCard({super.key, required this.child, this.onTap, this.pressScale = 0.97});
  @override
  State<PressableCard> createState() => _PressableCardState();
}

class _PressableCardState extends State<PressableCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () {
      HapticFeedback.lightImpact();
      widget.onTap?.call();
    },
    onTapDown: (_) => setState(() => _pressed = true),
    onTapUp: (_) => setState(() => _pressed = false),
    onTapCancel: () => setState(() => _pressed = false),
    child: AnimatedScale(
      scale: _pressed ? widget.pressScale : 1.0,
      duration: const Duration(milliseconds: 110),
      curve: Curves.easeOut,
      child: widget.child,
    ),
  );
}

// ── Animated counter — counts up from 0 on widget mount ────────────────────────
class AnimatedCounter extends StatelessWidget {
  final int value;
  final TextStyle style;
  final String Function(int)? formatter;
  const AnimatedCounter({super.key, required this.value, required this.style, this.formatter});

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<int>(
    tween: IntTween(begin: 0, end: value),
    duration: const Duration(milliseconds: 1400),
    curve: Curves.easeOutCubic,
    builder: (_, v, __) => Text(
      formatter != null ? formatter!(v) : v.toString(),
      style: style,
    ),
  );
}

// ── Shimmer loading block ───────────────────────────────────────────────────────
class ShimmerBox extends StatefulWidget {
  final double? width;
  final double? height;
  final double radius;
  const ShimmerBox({super.key, this.width, this.height, this.radius = 10});

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final p = HaTheme.of(context);
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final t = _ctrl.value;
        return Container(
          width: widget.width,
          height: widget.height ?? 14,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              begin: Alignment(-2.0 + t * 4, 0),
              end:   Alignment(-1.0 + t * 4, 0),
              colors: p.isDark
                  ? [
                      Colors.white.withValues(alpha: 0.04),
                      Colors.white.withValues(alpha: 0.12),
                      Colors.white.withValues(alpha: 0.04),
                    ]
                  : [
                      const Color(0xFFECE6DA),
                      kGold.withValues(alpha: 0.18),
                      const Color(0xFFECE6DA),
                    ],
            ),
          ),
        );
      },
    );
  }
}

// Skeleton card matching the home-screen appointment/promo card shape
class ShimmerCard extends StatelessWidget {
  final double height;
  const ShimmerCard({super.key, this.height = 90});

  @override
  Widget build(BuildContext context) {
    final p = HaTheme.of(context);
    return Container(
      height: height,
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: p.border),
      ),
      child: Row(children: [
        ShimmerBox(width: 52, height: 52, radius: 15),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
          ShimmerBox(width: double.infinity, height: 13, radius: 7),
          const SizedBox(height: 10),
          ShimmerBox(width: 110, height: 11, radius: 6),
          const SizedBox(height: 8),
          ShimmerBox(width: 160, height: 10, radius: 6),
        ])),
      ]),
    );
  }
}

// Skeleton tile matching service list items
class ShimmerTile extends StatelessWidget {
  const ShimmerTile({super.key});

  @override
  Widget build(BuildContext context) {
    final p = HaTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: p.border),
      ),
      child: Row(children: [
        ShimmerBox(width: 48, height: 48, radius: 14),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ShimmerBox(width: 140, height: 13, radius: 7),
          const SizedBox(height: 9),
          ShimmerBox(width: double.infinity, height: 11, radius: 6),
          const SizedBox(height: 9),
          ShimmerBox(width: 80, height: 10, radius: 6),
        ])),
      ]),
    );
  }
}

// ── Before/After drag slider ────────────────────────────────────────────────────
class BeforeAfterSlider extends StatefulWidget {
  final Widget before;
  final Widget after;
  final double height;
  final double initialSplit;
  const BeforeAfterSlider({
    super.key,
    required this.before,
    required this.after,
    this.height = 300,
    this.initialSplit = 0.40,
  });

  @override
  State<BeforeAfterSlider> createState() => _BeforeAfterSliderState();
}

class _BeforeAfterSliderState extends State<BeforeAfterSlider> {
  late double _split;

  @override
  void initState() { super.initState(); _split = widget.initialSplit; }

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(20),
    child: SizedBox(
      height: widget.height,
      child: LayoutBuilder(builder: (_, constraints) {
        final w = constraints.maxWidth;
        final divX = w * _split;
        return GestureDetector(
          onHorizontalDragUpdate: (d) {
            HapticFeedback.selectionClick();
            setState(() => _split = (_split + d.delta.dx / w).clamp(0.05, 0.95));
          },
          behavior: HitTestBehavior.opaque,
          child: Stack(children: [
            // After — full background
            Positioned.fill(child: widget.after),
            // Before — left clip
            Positioned.fill(
              child: ClipRect(
                clipper: _FractionClipper(_split),
                child: widget.before,
              ),
            ),
            // Divider line
            Positioned(left: divX - 0.75, top: 0, bottom: 0, width: 1.5,
              child: Container(color: Colors.white.withValues(alpha: 0.9))),
            // Handle
            Positioned(
              left: divX - 20, top: 0, bottom: 0,
              child: Center(
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: kGoldGradient,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.35), blurRadius: 10, offset: const Offset(0, 2)),
                      BoxShadow(color: kGold.withValues(alpha: 0.45), blurRadius: 14),
                    ],
                  ),
                  child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.chevron_left_rounded, color: Colors.black87, size: 16),
                    Icon(Icons.chevron_right_rounded, color: Colors.black87, size: 16),
                  ]),
                ),
              ),
            ),
            // Labels
            Positioned(left: 12, bottom: 12,
              child: _SliderLabel(text: 'Before', dark: true)),
            Positioned(right: 12, bottom: 12,
              child: _SliderLabel(text: 'After', gold: true)),
          ]),
        );
      }),
    ),
  );
}

class _SliderLabel extends StatelessWidget {
  final String text;
  final bool dark;
  final bool gold;
  const _SliderLabel({required this.text, this.dark = false, this.gold = false});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      gradient: gold ? kGoldGradient : null,
      color: dark ? Colors.black.withValues(alpha: 0.55) : null,
      borderRadius: BorderRadius.circular(7),
    ),
    child: Text(text, style: TextStyle(
      color: gold ? Colors.black87 : Colors.white,
      fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.3,
    )),
  );
}

class _FractionClipper extends CustomClipper<Rect> {
  final double fraction;
  const _FractionClipper(this.fraction);
  @override
  Rect getClip(Size size) => Rect.fromLTWH(0, 0, size.width * fraction, size.height);
  @override
  bool shouldReclip(_FractionClipper old) => old.fraction != fraction;
}

// ── Gold confetti burst ─────────────────────────────────────────────────────────
class _Particle {
  final double startX, speed, swing, phase, freq, spin, w, h;
  final Color color;
  const _Particle({
    required this.startX, required this.speed, required this.swing,
    required this.phase, required this.freq, required this.spin,
    required this.w, required this.h, required this.color,
  });
}

class ConfettiOverlay extends StatefulWidget {
  final VoidCallback? onDone;
  const ConfettiOverlay({super.key, this.onDone});

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<_Particle> _particles;

  static const _palette = [
    kGold, Color(0xFFFFE168), Colors.white, Color(0xFFD4AF5B),
    Color(0xFFFFF0A0), Color(0xFFE8C76A),
  ];

  @override
  void initState() {
    super.initState();
    final rng = math.Random();
    _particles = List.generate(90, (_) => _Particle(
      startX: rng.nextDouble(),
      speed:  0.55 + rng.nextDouble() * 0.85,
      swing:  18 + rng.nextDouble() * 32,
      phase:  rng.nextDouble() * math.pi * 2,
      freq:   2.0 + rng.nextDouble() * 3.5,
      spin:   (rng.nextBool() ? 1 : -1) * (4 + rng.nextDouble() * 8),
      w:      5 + rng.nextDouble() * 6,
      h:      3 + rng.nextDouble() * 4,
      color:  _palette[rng.nextInt(_palette.length)],
    ));
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 3200))
      ..forward().whenComplete(() => widget.onDone?.call());
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => CustomPaint(
        size: MediaQuery.of(context).size,
        painter: _ConfettiPainter(_ctrl.value, _particles),
      ),
    ),
  );
}

class _ConfettiPainter extends CustomPainter {
  final double progress;
  final List<_Particle> particles;
  const _ConfettiPainter(this.progress, this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (final pt in particles) {
      final rawY = progress * size.height * (1.1 + pt.speed) - size.height * 0.12;
      if (rawY < -24 || rawY > size.height + 24) continue;
      final x = pt.startX * size.width + math.sin(progress * pt.freq + pt.phase) * pt.swing;
      final fadeIn  = (rawY / (size.height * 0.12)).clamp(0.0, 1.0);
      final fadeOut = 1.0 - ((rawY - size.height * 0.62) / (size.height * 0.38)).clamp(0.0, 1.0);
      final opacity = (fadeIn * fadeOut).clamp(0.0, 1.0);
      if (opacity <= 0.01) continue;
      paint.color = pt.color.withValues(alpha: opacity);
      canvas.save();
      canvas.translate(x, rawY);
      canvas.rotate(progress * pt.spin);
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: pt.w, height: pt.h), const Radius.circular(1)),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.progress != progress;
}

// ── Google sign-in button ───────────────────────────────────────────────────────
class GoogleButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool loading;
  const GoogleButton({super.key, required this.onTap, this.loading = false});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: loading ? null : () { HapticFeedback.lightImpact(); onTap(); },
    child: Container(
      height: 52,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDDDDDD)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: loading
        ? const Center(child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFF4285F4))))
        : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            SizedBox(width: 22, height: 22, child: CustomPaint(painter: _GoogleGPainter())),
            const SizedBox(width: 12),
            const Text('Continue with Google', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1F1F1F), letterSpacing: 0.1)),
          ]),
    ),
  );
}

class _GoogleGPainter extends CustomPainter {
  const _GoogleGPainter();

  void _arc(Canvas canvas, Rect rect, Color color, double startDeg, double sweepDeg) =>
    canvas.drawArc(
      rect,
      startDeg * math.pi / 180,
      sweepDeg * math.pi / 180,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = rect.width * 0.185
        ..strokeCap = StrokeCap.butt
        ..color = color,
    );

  @override
  void paint(Canvas canvas, Size sz) {
    final cx = sz.width / 2, cy = sz.height / 2;
    final r  = math.min(cx, cy);
    final sw = r * 0.37;
    final ar = r - sw / 2;
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: ar);

    // Four colored arcs of the G (0°=right, clockwise)
    _arc(canvas, rect, const Color(0xFFEA4335), -28, 82);   // Red  — top-right
    _arc(canvas, rect, const Color(0xFF4285F4),  54, 152);  // Blue — left
    _arc(canvas, rect, const Color(0xFFFBBC05), 206, 72);   // Yellow — bottom
    _arc(canvas, rect, const Color(0xFF34A853), 278, 54);   // Green — bottom-right

    // Blue G-bar: horizontal from center to right edge
    canvas.drawLine(
      Offset(cx, cy),
      Offset(cx + ar + sw / 2, cy),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = sw
        ..strokeCap = StrokeCap.butt
        ..color = const Color(0xFF4285F4),
    );
  }

  @override
  bool shouldRepaint(_GoogleGPainter o) => false;
}
