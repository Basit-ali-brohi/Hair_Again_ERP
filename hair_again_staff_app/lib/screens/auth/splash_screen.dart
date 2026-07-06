import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) context.go('/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0E0E12), Color(0xFF1A1500), Color(0xFF0E0E12)],
            stops: [0.0, 0.5, 1.0],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              width: 90, height: 90,
              decoration: BoxDecoration(
                gradient: kGoldGradient,
                borderRadius: BorderRadius.circular(26),
                boxShadow: [BoxShadow(color: kGold.withValues(alpha: 0.4), blurRadius: 32, offset: const Offset(0, 8))],
              ),
              child: const Icon(Icons.spa_outlined, color: Colors.black87, size: 44),
            )
                .animate().scale(begin: const Offset(0.6, 0.6), end: const Offset(1, 1), duration: 600.ms, curve: Curves.elasticOut)
                .fadeIn(duration: 400.ms),
            const SizedBox(height: 24),
            const Text('HAIR AGAIN', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: kGold, letterSpacing: 3))
                .animate().fadeIn(delay: 400.ms, duration: 500.ms).slideY(begin: 0.3, end: 0),
            const SizedBox(height: 8),
            const Text('Staff Portal', style: TextStyle(fontSize: 14, color: Colors.white54, letterSpacing: 1))
                .animate().fadeIn(delay: 600.ms, duration: 400.ms),
            const SizedBox(height: 60),
            SizedBox(
              width: 32, height: 32,
              child: CircularProgressIndicator(color: kGold.withValues(alpha: 0.5), strokeWidth: 2),
            ).animate().fadeIn(delay: 900.ms),
          ]),
        ),
      ),
    );
  }
}
