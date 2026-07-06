import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme.dart';
import 'core/router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(const StaffApp());
}

class StaffApp extends StatefulWidget {
  const StaffApp({super.key});
  @override
  State<StaffApp> createState() => _StaffAppState();
}

class _StaffAppState extends State<StaffApp> {
  @override
  void initState() {
    super.initState();
    appNotifier.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final palette = appNotifier.palette;
    return HaTheme(
      palette: palette,
      child: MaterialApp.router(
        title: 'Hair Again Staff',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.forPalette(palette),
        routerConfig: staffRouter,
      ),
    );
  }
}
