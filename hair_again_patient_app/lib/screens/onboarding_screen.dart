import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../core/router.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _ctrl = PageController();
  int _page = 0;

  static const _pages = [
    _OnbData(
      icon: Icons.spa_outlined,
      title: 'Premium Hair\nCare at Your\nFingertips',
      subtitle: 'Book consultations, track your treatment journey, and stay connected with your specialist.',
      color: kGold,
    ),
    _OnbData(
      icon: Icons.calendar_month_outlined,
      title: 'Book\nAppointments\nInstantly',
      subtitle: 'Choose your preferred doctor, pick a time slot, and confirm in under 60 seconds.',
      color: kInfo,
    ),
    _OnbData(
      icon: Icons.auto_awesome_outlined,
      title: 'Track Your\nTransformation',
      subtitle: 'View before/after results, treatment history, and earn loyalty rewards along the way.',
      color: kSuccess,
    ),
  ];

  void _next() {
    if (_page < _pages.length - 1) {
      _ctrl.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
    } else {
      _finish();
    }
  }

  void _finish() {
    markOnboarded();
    context.go('/login');
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          // Skip
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(onPressed: _finish, child: Text('Skip', style: kBody(14, color: kTextMuted, weight: FontWeight.w600))),
          ),

          // Pages
          Expanded(
            child: PageView.builder(
              controller: _ctrl,
              itemCount: _pages.length,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (_, i) => _OnbPage(data: _pages[i]),
            ),
          ),

          // Dots + button
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 16, 28, 32),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(_pages.length, (i) =>
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: i == _page ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: i == _page ? kGold : kBorder,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              )),
              const SizedBox(height: 28),
              GoldButton(
                label: _page == _pages.length - 1 ? 'Get Started' : 'Next',
                icon: _page == _pages.length - 1 ? Icons.check : Icons.arrow_forward,
                onTap: _next,
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _OnbData {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  const _OnbData({required this.icon, required this.title, required this.subtitle, required this.color});
}

class _OnbPage extends StatelessWidget {
  final _OnbData data;
  const _OnbPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 40),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
        width: 120, height: 120,
        decoration: BoxDecoration(
          color: data.color.withValues(alpha: 0.12),
          shape: BoxShape.circle,
          border: Border.all(color: data.color.withValues(alpha: 0.3), width: 1.5),
        ),
        child: Icon(data.icon, size: 52, color: data.color),
      ),
      const SizedBox(height: 40),
      Text(data.title, style: kDisplay(34, spacing: -0.5), textAlign: TextAlign.center),
      const SizedBox(height: 16),
      Text(data.subtitle, style: kBody(15, color: kTextMuted), textAlign: TextAlign.center),
    ]),
  );
}
