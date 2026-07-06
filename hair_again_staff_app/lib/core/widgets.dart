import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'theme.dart';

// ── App bar ────────────────────────────────────────────────────────────────────
class StaffAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBack;
  final List<Widget>? actions;
  final VoidCallback? onBack;
  const StaffAppBar({super.key, required this.title, this.showBack = true, this.actions, this.onBack});

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final p = HaTheme.of(context);
    return AppBar(
      backgroundColor: p.surface,
      elevation: 0,
      centerTitle: true,
      bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height: 1, color: p.border)),
      leading: showBack
          ? IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: p.text),
              onPressed: onBack ?? () { if (context.canPop()) context.pop(); },
            )
          : null,
      title: Text(title, style: p.body(17, weight: FontWeight.w700)),
      actions: actions,
    );
  }
}

// ── Gold button ────────────────────────────────────────────────────────────────
class GoldButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool loading;
  final IconData? icon;
  const GoldButton({super.key, required this.label, this.onTap, this.loading = false, this.icon});

  @override
  Widget build(BuildContext context) {
    final p = HaTheme.of(context);
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        width: double.infinity, height: 52,
        decoration: BoxDecoration(
          gradient: loading ? null : kGoldGradient,
          color: loading ? p.surfaceAlt : null,
          borderRadius: BorderRadius.circular(14),
          boxShadow: loading ? null : [BoxShadow(color: kGold.withValues(alpha: 0.30), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: loading
            ? const Center(child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: kGold, strokeWidth: 2.5)))
            : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                if (icon != null) ...[Icon(icon, size: 18, color: Colors.black87), const SizedBox(width: 8)],
                Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black87, letterSpacing: 0.5)),
              ]),
      ),
    );
  }
}

// ── Outline button ─────────────────────────────────────────────────────────────
class OutlineBtn extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final Color? color;
  final IconData? icon;
  const OutlineBtn({super.key, required this.label, this.onTap, this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    final p = HaTheme.of(context);
    final c = color ?? p.textMuted;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity, height: 52,
        decoration: BoxDecoration(
          border: Border.all(color: c.withValues(alpha: 0.5), width: 1.5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          if (icon != null) ...[Icon(icon, size: 16, color: c), const SizedBox(width: 6)],
          Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c)),
        ]),
      ),
    );
  }
}

// ── Status badge ───────────────────────────────────────────────────────────────
class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const StatusBadge({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
    child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
  );
}

// ── Section header ─────────────────────────────────────────────────────────────
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
      if (action != null)
        GestureDetector(
          onTap: onAction,
          child: Text(action!, style: p.body(13, color: kGold, weight: FontWeight.w600)),
        ),
    ]);
  }
}

// ── Empty state ────────────────────────────────────────────────────────────────
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  const EmptyState({super.key, required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final p = HaTheme.of(context);
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(color: kGold.withValues(alpha: 0.08), shape: BoxShape.circle),
          child: Icon(icon, size: 36, color: kGold.withValues(alpha: 0.6)),
        ),
        const SizedBox(height: 16),
        Text(title, style: p.body(16, weight: FontWeight.w700)),
        const SizedBox(height: 6),
        Text(subtitle, style: p.body(13, color: p.textMuted), textAlign: TextAlign.center),
      ]),
    );
  }
}

// ── Pressable card wrapper ─────────────────────────────────────────────────────
class PressableCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  const PressableCard({super.key, required this.child, this.onTap});
  @override
  State<PressableCard> createState() => _PressableCardState();
}
class _PressableCardState extends State<PressableCard> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 80), lowerBound: 0.96, upperBound: 1.0)..value = 1.0;
  @override
  void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTapDown: (_) => _c.reverse(),
    onTapUp:   (_) { _c.forward(); widget.onTap?.call(); },
    onTapCancel: () => _c.forward(),
    child: ScaleTransition(scale: _c, child: widget.child),
  );
}

// ── Stat card ──────────────────────────────────────────────────────────────────
class StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  const StatCard({super.key, required this.label, required this.value, required this.icon, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = HaTheme.of(context);
    return PressableCard(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: p.border),
          boxShadow: [if (!p.isDark) BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(value, style: p.display(22, color: color)),
          const SizedBox(height: 4),
          Text(label, style: p.body(12, color: p.textMuted)),
        ]),
      ),
    );
  }
}

// ── Search bar ─────────────────────────────────────────────────────────────────
class SearchBar2 extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  const SearchBar2({super.key, required this.controller, required this.hint, this.onChanged});

  @override
  Widget build(BuildContext context) {
    final p = HaTheme.of(context);
    return Container(
      height: 48,
      decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: p.border)),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: p.body(14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: p.body(14, color: p.textMuted),
          prefixIcon: Icon(Icons.search_rounded, color: p.textMuted, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

// ── Info banner ────────────────────────────────────────────────────────────────
class InfoBanner extends StatelessWidget {
  final String text;
  final Color color;
  final IconData icon;
  const InfoBanner({super.key, required this.text, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    final p = HaTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: p.body(13, color: p.textMuted))),
      ]),
    );
  }
}
