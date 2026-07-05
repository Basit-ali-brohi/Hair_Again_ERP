// core/theme — Premium "Obsidian & Gold" (dark) / "Clinical Minimalist" (light)
// palette + typography (Bebas Neue headings, Inter body). Every surface colour,
// border and text colour resolves from here so the theme flips atomically.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../modules/crm/models/patient.dart';
import '../../modules/appointments/models/appointment.dart';

class AppPalette {
  final bool isDark;
  final Color accent;
  const AppPalette(this.isDark, this.accent);

  Color get bg => isDark ? const Color(0xFF0E0E12) : const Color(0xFFFBF9F5);
  Color get sidebar => isDark ? const Color(0xFF121217) : const Color(0xFFFFFFFF);
  Color get surface => isDark ? const Color(0xFF17171D) : const Color(0xFFFFFFFF);
  Color get surfaceAlt => isDark ? const Color(0xFF1E1E26) : const Color(0xFFF5F0E8);
  Color get border => isDark ? const Color(0xFF2A2A33) : const Color(0xFFE5DDD0);
  Color get text => isDark ? const Color(0xFFF3F2EE) : const Color(0xFF1C1A17);
  Color get textMuted => isDark ? const Color(0xFF9A9AA6) : const Color(0xFF8A8070);
  Color get success => const Color(0xFF3FA787);
  Color get info => const Color(0xFF5B8DEF);
  Color get warning => const Color(0xFFE0A23F);
  Color get danger => const Color(0xFFE05A5A);

  Color get gold => accent;
  Color get goldBright => Color.lerp(accent, Colors.white, isDark ? 0.22 : 0.12)!;

  LinearGradient get goldGradient =>
      LinearGradient(colors: [goldBright, gold], begin: Alignment.topLeft, end: Alignment.bottomRight);

  Color statusColor(PatientStatus s) => switch (s) {
        PatientStatus.lead => info,
        PatientStatus.active => gold,
        PatientStatus.completed => success,
      };

  Color apptColor(ApptStatus s) => switch (s) {
        ApptStatus.confirmed => success,
        ApptStatus.pending => warning,
        ApptStatus.cancelled => danger,
        ApptStatus.checkedIn => info,
        ApptStatus.completed => gold,
      };

  TextStyle display(double size, {Color? color, double spacing = 1.0}) =>
      GoogleFonts.bebasNeue(fontSize: size, color: color ?? text, letterSpacing: spacing, height: 1.0);

  TextStyle body(double size, {Color? color, FontWeight weight = FontWeight.w400, double spacing = 0}) =>
      GoogleFonts.inter(fontSize: size, color: color ?? text, fontWeight: weight, letterSpacing: spacing);
}
