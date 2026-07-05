import 'package:flutter/material.dart';
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
