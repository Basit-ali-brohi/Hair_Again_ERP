// core/widgets — root widget: wraps the app in AppScope (so theme/accent/nav
// changes rebuild everything) and builds the themed MaterialApp.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../state/app_state.dart';
import '../theme/app_scope.dart';
import 'shell.dart';
import '../../modules/auth/views/login_screen.dart';
import '../../modules/auth/views/splash_screen.dart';

class HairAgainApp extends StatelessWidget {
  const HairAgainApp({super.key});
  @override
  Widget build(BuildContext context) => AppScope(notifier: appState, child: const _Root());
}

class _Root extends StatelessWidget {
  const _Root();
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context); // dependency → rebuild on any notify
    final p = state.palette;
    return MaterialApp(
      title: 'HAIR AGAIN — Clinic ERP',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: p.bg,
        colorScheme: ColorScheme.fromSeed(seedColor: p.gold, brightness: state.isDark ? Brightness.dark : Brightness.light),
        textTheme: GoogleFonts.interTextTheme(state.isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme),
        tooltipTheme: TooltipThemeData(
          decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(8), border: Border.all(color: p.border)),
          textStyle: p.body(12, color: p.text),
        ),
      ),
      home: !state.splashDone ? const SplashScreen() : state.currentUser == null ? const LoginScreen() : const Shell(),
    );
  }
}
