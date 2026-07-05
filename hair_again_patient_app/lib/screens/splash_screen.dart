import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../core/router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _scale = Tween<double>(begin: 0.7, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _fade  = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0, 0.5)));
    _ctrl.forward();
    Future.delayed(const Duration(milliseconds: 2400), _navigate);
  }

  void _navigate() {
    if (!mounted) return;
    if (hasSeenOnboarding) {
      context.go('/login');
    } else {
      context.go('/onboarding');
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: kHeroGradient),
        child: Center(
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) => FadeTransition(
              opacity: _fade,
              child: ScaleTransition(
                scale: _scale,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    width: 96, height: 96,
                    decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFD4AF5B), Color(0xFF9A7A35)]), borderRadius: BorderRadius.circular(28)),
                    child: const Icon(Icons.spa_outlined, color: Colors.black87, size: 48),
                  ),
                  const SizedBox(height: 24),
                  Text('HAIR AGAIN', style: kDisplay(32, color: kGold, spacing: 3.0)),
                  const SizedBox(height: 6),
                  Text('CLINIC', style: kBody(14, color: kTextMuted, spacing: 4.0)),
                  const SizedBox(height: 48),
                  SizedBox(
                    width: 24, height: 24,
                    child: CircularProgressIndicator(color: kGold.withValues(alpha: 0.5), strokeWidth: 2),
                  ),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
