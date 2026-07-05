// core/widgets — shared UI building blocks used across every module
// (scaffold, panels, buttons, metric cards, inputs, chips, theme toggle).
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../theme/app_scope.dart';

class ScreenScaffold extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> actions;
  final Widget child;
  const ScreenScaffold({super.key, required this.title, required this.subtitle, this.actions = const [], required this.child});
  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final isMobile = defaultTargetPlatform == TargetPlatform.android ||
                      defaultTargetPlatform == TargetPlatform.iOS;
    if (isMobile) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: p.display(22, spacing: 0.5)),
            const SizedBox(height: 2),
            Text(subtitle, style: p.body(12, color: p.textMuted)),
          ]),
        ),
        if (actions.isNotEmpty) ...[
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: actions),
          ),
        ],
        const SizedBox(height: 10),
        Divider(height: 1, thickness: 1, color: p.border),
        const SizedBox(height: 8),
        Expanded(child: child),
      ]);
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 16, 28, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: p.display(34, spacing: 1.0)),
            const SizedBox(height: 2),
            Text(subtitle, style: p.body(13, color: p.textMuted)),
          ])),
          const SizedBox(width: 16),
          ...actions,
        ]),
        const SizedBox(height: 14),
        Divider(height: 1, thickness: 1, color: p.border),
        const SizedBox(height: 12),
        Expanded(child: child),
      ]),
    );
  }
}

class Panel extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const Panel({super.key, required this.child, this.padding = const EdgeInsets.all(20)});
  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: p.border),
        boxShadow: p.isDark ? [] : [BoxShadow(color: const Color(0xFF6B4500).withValues(alpha: 0.07), blurRadius: 20, offset: const Offset(0, 4))],
      ),
      child: child,
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String text;
  final String? sub;
  const SectionTitle(this.text, {super.key, this.sub});
  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(text, style: p.display(22, spacing: 1.0)), if (sub != null) Text(sub!, style: p.body(12.5, color: p.textMuted))]);
  }
}

class GoldButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;
  final bool dense;
  const GoldButton({super.key, required this.label, this.icon, required this.onTap, this.dense = false});
  @override
  State<GoldButton> createState() => _GoldButtonState();
}

class _GoldButtonState extends State<GoldButton> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _hover ? 1.02 : 1.0, duration: const Duration(milliseconds: 140),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: widget.dense ? 14 : 20, vertical: widget.dense ? 10 : 13),
            decoration: BoxDecoration(gradient: p.goldGradient, borderRadius: BorderRadius.circular(5), boxShadow: _hover ? [BoxShadow(color: p.gold.withValues(alpha: 0.4), blurRadius: 16, offset: const Offset(0, 4))] : []),
            child: Row(mainAxisSize: MainAxisSize.min, children: [if (widget.icon != null) ...[Icon(widget.icon, size: 18, color: Colors.black87), const SizedBox(width: 8)], Text(widget.label, style: p.body(widget.dense ? 12.5 : 13.5, color: Colors.black87, weight: FontWeight.w700))]),
          ),
        ),
      ),
    );
  }
}

class GhostButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;
  final bool dense;
  const GhostButton({super.key, required this.label, this.icon, required this.onTap, this.dense = false});
  @override
  State<GhostButton> createState() => _GhostButtonState();
}

class _GhostButtonState extends State<GhostButton> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: EdgeInsets.symmetric(horizontal: widget.dense ? 12 : 16, vertical: widget.dense ? 9 : 12),
          decoration: BoxDecoration(color: _hover ? p.surfaceAlt : Colors.transparent, borderRadius: BorderRadius.circular(5), border: Border.all(color: _hover ? p.gold : p.border)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [if (widget.icon != null) ...[Icon(widget.icon, size: widget.dense ? 16 : 17, color: p.text), const SizedBox(width: 7)], Text(widget.label, style: p.body(widget.dense ? 12.5 : 13, weight: FontWeight.w600))]),
        ),
      ),
    );
  }
}

class MetricCard extends StatefulWidget {
  final String title;
  final String value;
  final String delta;
  final bool deltaUp;
  final IconData icon;
  const MetricCard({super.key, required this.title, required this.value, required this.delta, required this.icon, this.deltaUp = true});
  @override
  State<MetricCard> createState() => _MetricCardState();
}

class _MetricCardState extends State<MetricCard> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final deltaColor = widget.deltaUp ? p.success : p.danger;

    // Split "±X% description" → badge part + trailing description
    final parts = widget.delta.split(' ');
    final badgeText = parts.first;
    final descText = parts.length > 1 ? parts.sublist(1).join(' ') : 'vs last month';

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: _hover ? p.gold.withValues(alpha: 0.45) : p.border),
          boxShadow: p.isDark
              ? (_hover ? [BoxShadow(color: Colors.black.withValues(alpha: 0.22), blurRadius: 18, offset: const Offset(0, 8))] : [])
              : [BoxShadow(color: const Color(0xFF6B4500).withValues(alpha: _hover ? 0.10 : 0.06), blurRadius: _hover ? 24 : 16, offset: const Offset(0, 4))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: p.gold.withValues(alpha: p.isDark ? 0.15 : 0.11),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Icon(widget.icon, size: 18, color: p.gold),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
              decoration: BoxDecoration(
                color: deltaColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(widget.deltaUp ? Icons.trending_up_rounded : Icons.trending_down_rounded, size: 12, color: deltaColor),
                const SizedBox(width: 3),
                Text(badgeText, style: p.body(11, color: deltaColor, weight: FontWeight.w700)),
              ]),
            ),
          ]),

          const SizedBox(height: 10),

          Text(
            widget.title,
            style: p.body(12.5, color: p.textMuted, weight: FontWeight.w600),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 4),

          Text(
            widget.value,
            style: p.body(24, weight: FontWeight.w700),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 8),

          Divider(height: 1, thickness: 1, color: p.border),

          const SizedBox(height: 6),

          Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.access_time_outlined, size: 11, color: p.textMuted.withValues(alpha: 0.7)),
            const SizedBox(width: 4),
            Flexible(
              fit: FlexFit.loose,
              child: Text(
                descText,
                style: p.body(11.5, color: p.textMuted),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ]),
        ]),
      ),
    );
  }
}

/// Responsive row of metric cards (4 / 2 / 1 per row by width).
class MetricRow extends StatelessWidget {
  final List<Widget> cards;
  const MetricRow(this.cards, {super.key});
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final w = c.maxWidth > 1000 ? (c.maxWidth - 54) / 4 : (c.maxWidth - 18) / 2;
      return Wrap(spacing: 18, runSpacing: 18, children: cards.map((e) => SizedBox(width: w, child: e)).toList());
    });
  }
}

class StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  const StatusChip({super.key, required this.label, required this.color});
  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    return Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: color.withValues(alpha: 0.13), borderRadius: BorderRadius.circular(4), border: Border.all(color: color.withValues(alpha: 0.35))), child: Text(label, style: p.body(11.5, color: color, weight: FontWeight.w600)));
  }
}

class FormField2 extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  final TextInputType? keyboard;
  final int maxLines;
  final bool obscure;
  final ValueChanged<String>? onChanged;
  const FormField2({super.key, required this.label, required this.controller, this.hint, this.keyboard, this.maxLines = 1, this.obscure = false, this.onChanged});
  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: p.body(12, color: p.textMuted, weight: FontWeight.w600)),
      const SizedBox(height: 7),
      TextField(
        controller: controller, keyboardType: keyboard, maxLines: obscure ? 1 : maxLines,
        obscureText: obscure, style: p.body(13.5), cursorColor: p.gold, onChanged: onChanged,
        decoration: InputDecoration(
          isDense: true, hintText: hint, hintStyle: p.body(13, color: p.textMuted.withValues(alpha: 0.7)), filled: true, fillColor: p.surfaceAlt,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: BorderSide(color: p.border)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: BorderSide(color: p.gold, width: 1.5)),
        ),
      ),
    ]);
  }
}

class Dropdown2<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  const Dropdown2({super.key, required this.label, required this.value, required this.items, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: p.body(12, color: p.textMuted, weight: FontWeight.w600)),
      const SizedBox(height: 7),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(5), border: Border.all(color: p.border)),
        child: DropdownButtonHideUnderline(child: DropdownButton<T>(value: value, isExpanded: true, dropdownColor: p.surfaceAlt, borderRadius: BorderRadius.circular(5), icon: Icon(Icons.keyboard_arrow_down, color: p.textMuted), style: p.body(13.5), items: items, onChanged: onChanged)),
      ),
    ]);
  }
}

class SearchBox extends StatelessWidget {
  final String hint;
  final ValueChanged<String> onChanged;
  final TextEditingController? controller;
  const SearchBox({super.key, required this.hint, required this.onChanged, this.controller});
  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    return Container(
      height: 42, padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(5), border: Border.all(color: p.border)),
      child: Row(children: [Icon(Icons.search, size: 18, color: p.textMuted), const SizedBox(width: 10), Expanded(child: TextField(controller: controller, style: p.body(13.5), cursorColor: p.gold, decoration: InputDecoration(isCollapsed: true, border: InputBorder.none, hintText: hint, hintStyle: p.body(13.5, color: p.textMuted)), onChanged: onChanged))]),
    );
  }
}

/// Compact inline dropdown for the FilterBar (no floating label), styled like a
/// pill — e.g. "All Categories ▾", "All Statuses ▾", "Name A–Z ▾".
class FilterDropdown<T> extends StatelessWidget {
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final IconData? icon;
  const FilterDropdown({super.key, required this.value, required this.items, required this.onChanged, this.icon});
  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(5), border: Border.all(color: p.border)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) ...[Icon(icon, size: 15, color: p.textMuted), const SizedBox(width: 8)],
        DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: value,
            isDense: true,
            menuWidth: 240,
            dropdownColor: p.surfaceAlt,
            borderRadius: BorderRadius.circular(5),
            icon: Icon(Icons.keyboard_arrow_down, color: p.textMuted, size: 18),
            style: p.body(12.5, weight: FontWeight.w600),
            items: items,
            onChanged: onChanged,
          ),
        ),
      ]),
    );
  }
}

/// A professional filter strip: [filters…] [search] [Showing x of y] [Clear].
/// Reused across every list section for a consistent look.
class FilterBar extends StatefulWidget {
  final String searchHint;
  final ValueChanged<String> onSearch;
  final List<Widget> filters;
  final String? countText;
  final VoidCallback? onClear;
  final List<Widget> trailing;
  const FilterBar({super.key, required this.searchHint, required this.onSearch, this.filters = const [], this.countText, this.onClear, this.trailing = const []});
  @override
  State<FilterBar> createState() => _FilterBarState();
}

class _FilterBarState extends State<FilterBar> {
  final _ctrl = TextEditingController();
  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final children = <Widget>[];
    for (final f in widget.filters) {
      children.add(f);
      children.add(const SizedBox(width: 10));
    }
    children.add(Expanded(child: SearchBox(controller: _ctrl, hint: widget.searchHint, onChanged: widget.onSearch)));
    if (widget.countText != null) children.add(Padding(padding: const EdgeInsets.only(left: 14), child: Text(widget.countText!, style: p.body(12, color: p.textMuted, weight: FontWeight.w500))));
    for (final t in widget.trailing) {
      children.add(Padding(padding: const EdgeInsets.only(left: 8), child: t));
    }
    if (widget.onClear != null) {
      children.add(Padding(
        padding: const EdgeInsets.only(left: 8),
        child: GhostButton(label: 'Clear', icon: Icons.refresh, onTap: () { _ctrl.clear(); widget.onSearch(''); widget.onClear!(); }),
      ));
    }
    return Panel(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12), child: Row(children: children));
  }
}

/// Always-visible scrollbar wrapper for desktop lists/grids (easier scrolling).
class ScrollArea extends StatefulWidget {
  final Widget Function(ScrollController controller) builder;
  const ScrollArea({super.key, required this.builder});
  @override
  State<ScrollArea> createState() => _ScrollAreaState();
}

class _ScrollAreaState extends State<ScrollArea> {
  final _c = ScrollController();
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(controller: _c, thumbVisibility: true, child: widget.builder(_c));
  }
}

class QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const QtyButton(this.icon, this.onTap, {super.key});
  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(cursor: SystemMouseCursors.click, child: Container(width: 28, height: 28, decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(4), border: Border.all(color: p.border)), child: Icon(icon, size: 15, color: p.text))),
    );
  }
}

/// Wraps a DataTable so it always fills the full available width while still
/// allowing horizontal scroll (with a visible scrollbar) when content overflows.
class FullWidthDataTable extends StatefulWidget {
  final Widget child;
  const FullWidthDataTable({super.key, required this.child});
  @override
  State<FullWidthDataTable> createState() => _FullWidthDataTableState();
}

class _FullWidthDataTableState extends State<FullWidthDataTable> {
  final _sc = ScrollController();
  @override
  void dispose() { _sc.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, cst) => Scrollbar(
      controller: _sc,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: _sc,
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: cst.maxWidth),
          child: widget.child,
        ),
      ),
    ));
  }
}

/// Drop-in replacement for [TabBarView] that uses [IndexedStack] internally.
/// Unlike [TabBarView], all children are always laid out (not lazily), which
/// prevents the "Cannot hit test a render box with no size" error on Windows
/// that occurs when the mouse pointer moves over un-rendered off-screen pages.
class EagerTabBarView extends StatefulWidget {
  final TabController controller;
  final List<Widget> children;
  const EagerTabBarView({super.key, required this.controller, required this.children});
  @override
  State<EagerTabBarView> createState() => _EagerTabBarViewState();
}

class _EagerTabBarViewState extends State<EagerTabBarView> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTabChange);
  }

  @override
  void didUpdateWidget(EagerTabBarView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onTabChange);
      widget.controller.addListener(_onTabChange);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTabChange);
    super.dispose();
  }

  // Defer setState to post-frame so TabController listener callbacks that fire
  // during the animation ticker (mid-layout) never trigger a synchronous build.
  void _onTabChange() {
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final active = widget.controller.index;
    // Offstage keeps every tab laid out (preserving State) without painting or
    // hit-testing inactive tabs. TickerMode pauses animations in inactive tabs.
    // Stack + StackFit.expand ensures each child receives the same tight,
    // bounded constraints regardless of Offstage status — eliminating the
    // unbounded-width assertion that IndexedStack + Opacity triggered on first
    // layout when constraints hadn't settled yet.
    return Stack(
      fit: StackFit.expand,
      children: widget.children.asMap().entries.map((entry) {
        final isActive = entry.key == active;
        return Offstage(
          offstage: !isActive,
          child: TickerMode(
            enabled: isActive,
            child: entry.value,
          ),
        );
      }).toList(),
    );
  }
}

/// Global Dark ↔ Light switch (used in the top bar and in Settings).
class ThemeToggle extends StatelessWidget {
  const ThemeToggle({super.key});
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final p = state.palette;
    final dark = state.isDark;
    return GestureDetector(
      onTap: () => appState.toggleTheme(),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: 78, height: 42, padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(5), border: Border.all(color: p.border)),
          child: Stack(children: [
            AnimatedAlign(duration: const Duration(milliseconds: 220), curve: Curves.easeOutCubic, alignment: dark ? Alignment.centerLeft : Alignment.centerRight, child: Container(width: 34, height: 34, decoration: BoxDecoration(gradient: p.goldGradient, borderRadius: BorderRadius.circular(5)), child: Icon(dark ? Icons.dark_mode : Icons.light_mode, size: 18, color: Colors.black87))),
            Align(alignment: dark ? Alignment.centerRight : Alignment.centerLeft, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 9), child: Icon(dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined, size: 17, color: p.textMuted))),
          ]),
        ),
      ),
    );
  }
}
