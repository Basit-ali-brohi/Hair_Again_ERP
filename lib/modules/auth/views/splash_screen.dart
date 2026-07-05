import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/state/app_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _progressCtrl;
  late final AnimationController _fadeCtrl;
  late final Animation<double> _progressAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _progressCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800));
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _progressAnim = CurvedAnimation(parent: _progressCtrl, curve: Curves.easeInOut);
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    _fadeCtrl.forward();
    _progressCtrl.forward();
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) appState.splashComplete();
    });
  }

  @override
  void dispose() {
    _progressCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF0E0E12);
    const gold = Color(0xFFC9A24B);
    const goldLight = Color(0xFFE8C96A);

    return Scaffold(
      backgroundColor: bg,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo container
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [gold, goldLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: gold.withValues(alpha: 0.35), blurRadius: 32, spreadRadius: 4)],
                ),
                child: const Icon(Icons.spa_outlined, size: 52, color: Colors.black87),
              ),
              const SizedBox(height: 32),
              // App name
              Text(
                'HAIR AGAIN',
                style: GoogleFonts.bebasNeue(
                  fontSize: 52,
                  color: gold,
                  letterSpacing: 6,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'CLINIC ERP  •  KARACHI',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.45),
                  letterSpacing: 3.5,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 52),
              // Progress bar
              SizedBox(
                width: 260,
                child: AnimatedBuilder(
                  animation: _progressAnim,
                  builder: (_, __) => ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _progressAnim.value,
                      backgroundColor: Colors.white.withValues(alpha: 0.08),
                      valueColor: const AlwaysStoppedAnimation<Color>(gold),
                      minHeight: 3,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Loading…',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.25),
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
