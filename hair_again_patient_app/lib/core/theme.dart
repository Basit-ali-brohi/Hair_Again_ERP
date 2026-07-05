import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Brand constants (same in all modes) ────────────────────────────────────────
const kGold      = Color(0xFFC9A24B);
const kGoldDark  = Color(0xFF9A7A35);
const kDanger    = Color(0xFFE05555);
const kSuccess   = Color(0xFF4CAF50);
const kWarning   = Color(0xFFFFB74D);
const kInfo      = Color(0xFF42A5F5);

const kGoldGradient = LinearGradient(
  colors: [Color(0xFFD4AF5B), Color(0xFF9A7A35)],
  begin: Alignment.topLeft, end: Alignment.bottomRight,
);

// ── Palette ────────────────────────────────────────────────────────────────────
class AppPalette {
  final bool isDark;
  const AppPalette(this.isDark);

  Color get bg          => isDark ? const Color(0xFF0E0E12) : const Color(0xFFFBF9F5);
  Color get surface     => isDark ? const Color(0xFF16161C) : const Color(0xFFFFFFFF);
  Color get surfaceAlt  => isDark ? const Color(0xFF1C1C24) : const Color(0xFFF4F1EC);
  Color get card        => isDark ? const Color(0xFF1A1A22) : const Color(0xFFFFFFFF);
  Color get border      => isDark ? const Color(0xFF2A2A36) : const Color(0xFFE5E0D8);
  Color get text        => isDark ? const Color(0xFFE8E8F0) : const Color(0xFF1C1A17);
  Color get textMuted   => isDark ? const Color(0xFF9A9AA6) : const Color(0xFF8A8070);
  Color get gold        => kGold;

  LinearGradient get heroGradient => isDark
      ? const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF0E0E12), Color(0xFF1A1500), Color(0xFF0E0E12)], stops: [0.0, 0.5, 1.0])
      : const LinearGradient(colors: [Color(0xFFFBF9F5), Color(0xFFFBF9F5)]);

  TextStyle display(double size, {Color? color, double spacing = 0}) =>
      GoogleFonts.inter(fontSize: size, fontWeight: FontWeight.w800, color: color ?? text, letterSpacing: spacing, height: 1.1);

  TextStyle body(double size, {Color? color, FontWeight weight = FontWeight.w400, double spacing = 0}) =>
      GoogleFonts.inter(fontSize: size, fontWeight: weight, color: color ?? text, letterSpacing: spacing);

  TextStyle label(double size, {Color? color}) =>
      GoogleFonts.inter(fontSize: size, fontWeight: FontWeight.w600, color: color ?? textMuted, letterSpacing: 0.8);
}

// ── Global notifier ────────────────────────────────────────────────────────────
final appNotifier = _AppNotifier();

class _AppNotifier extends ChangeNotifier {
  bool _isDark = true;
  bool get isDark => _isDark;
  AppPalette get palette => AppPalette(_isDark);

  void toggleTheme() { _isDark = !_isDark; notifyListeners(); }
  void setDark(bool v) { if (_isDark == v) return; _isDark = v; notifyListeners(); }
}

// ── InheritedWidget to pass palette down ───────────────────────────────────────
class HaTheme extends InheritedWidget {
  final AppPalette palette;
  const HaTheme({super.key, required this.palette, required super.child});

  static AppPalette of(BuildContext context) {
    final w = context.dependOnInheritedWidgetOfExactType<HaTheme>();
    return w?.palette ?? AppPalette(true);
  }

  @override
  bool updateShouldNotify(HaTheme old) => palette.isDark != old.palette.isDark;
}

// ── MaterialApp ThemeData (used for system widgets) ───────────────────────────
class AppTheme {
  static ThemeData forPalette(AppPalette p) => ThemeData(
    brightness: p.isDark ? Brightness.dark : Brightness.light,
    scaffoldBackgroundColor: p.bg,
    colorScheme: ColorScheme(
      brightness: p.isDark ? Brightness.dark : Brightness.light,
      primary: kGold, onPrimary: Colors.black87,
      secondary: kGold, onSecondary: Colors.black87,
      surface: p.surface, onSurface: p.text,
      error: kDanger, onError: Colors.white,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: p.surface, elevation: 0, centerTitle: true,
      titleTextStyle: p.body(17, weight: FontWeight.w700),
      iconTheme: IconThemeData(color: p.text, size: 22),
    ),
    tabBarTheme: TabBarThemeData(
      indicatorColor: kGold, labelColor: kGold, unselectedLabelColor: p.textMuted,
      dividerColor: p.border,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true, fillColor: p.surfaceAlt,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: p.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: p.border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kGold, width: 1.5)),
      hintStyle: p.body(14, color: p.textMuted),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    dividerTheme: DividerThemeData(color: p.border, thickness: 1),
    cardTheme: CardThemeData(
      color: p.card, elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: p.border)),
      margin: EdgeInsets.zero,
    ),
    useMaterial3: true,
  );
}

// ── Legacy helpers (for code that still uses kBody/kDisplay/kLabel) ────────────
// Keep for backwards compatibility; prefer palette.body() in new code
TextStyle kBody(double size, {Color? color, FontWeight weight = FontWeight.w400, double spacing = 0}) =>
    GoogleFonts.inter(fontSize: size, fontWeight: weight, color: color ?? const Color(0xFFE8E8F0), letterSpacing: spacing);

TextStyle kDisplay(double size, {Color? color, double spacing = 0}) =>
    GoogleFonts.inter(fontSize: size, fontWeight: FontWeight.w800, color: color ?? const Color(0xFFE8E8F0), letterSpacing: spacing, height: 1.1);

TextStyle kLabel(double size, {Color? color}) =>
    GoogleFonts.inter(fontSize: size, fontWeight: FontWeight.w600, color: color ?? const Color(0xFF9A9AA6), letterSpacing: 0.8);

// Legacy color constants
const kBg         = Color(0xFF0E0E12);
const kSurface    = Color(0xFF16161C);
const kSurfaceAlt = Color(0xFF1C1C24);
const kCard       = Color(0xFF1A1A22);
const kBorder     = Color(0xFF2A2A36);
const kText       = Color(0xFFE8E8F0);
const kTextMuted  = Color(0xFF9A9AA6);
const kHeroGradient = LinearGradient(
  begin: Alignment.topLeft, end: Alignment.bottomRight,
  colors: [Color(0xFF0E0E12), Color(0xFF1A1500), Color(0xFF0E0E12)], stops: [0.0, 0.5, 1.0],
);
