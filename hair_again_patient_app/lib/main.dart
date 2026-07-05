import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme.dart';
import 'core/router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const HairAgainPatientApp());
}

class HairAgainPatientApp extends StatefulWidget {
  const HairAgainPatientApp({super.key});
  @override
  State<HairAgainPatientApp> createState() => _HairAgainPatientAppState();
}

class _HairAgainPatientAppState extends State<HairAgainPatientApp> {
  @override
  void initState() {
    super.initState();
    appNotifier.addListener(_onThemeChange);
    _applySystemUI(appNotifier.palette);
  }

  @override
  void dispose() {
    appNotifier.removeListener(_onThemeChange);
    super.dispose();
  }

  void _onThemeChange() {
    _applySystemUI(appNotifier.palette);
    setState(() {});
  }

  void _applySystemUI(AppPalette p) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: p.isDark ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: p.surface,
      systemNavigationBarIconBrightness: p.isDark ? Brightness.light : Brightness.dark,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final p = appNotifier.palette;
    return HaTheme(
      palette: p,
      child: MaterialApp.router(
        title: 'Hair Again',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.forPalette(AppPalette(false)),
        darkTheme: AppTheme.forPalette(AppPalette(true)),
        themeMode: p.isDark ? ThemeMode.dark : ThemeMode.light,
        routerConfig: appRouter,
      ),
    );
  }
}
