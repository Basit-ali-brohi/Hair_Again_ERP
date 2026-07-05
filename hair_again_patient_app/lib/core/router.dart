import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/splash_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/otp_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/services/services_screen.dart';
import '../screens/appointments/history_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/appointments/book_screen.dart';
import '../screens/treatments/history_screen.dart' as th;
import '../screens/gallery/gallery_screen.dart';
import '../screens/membership/membership_screen.dart';
import '../screens/loyalty/loyalty_screen.dart';
import '../screens/payments/payments_screen.dart';
import '../screens/chat/chat_screen.dart';
import '../screens/reviews/reviews_screen.dart';
import '../screens/settings/settings_screen.dart';
import 'theme.dart';

// Simple session flag — replace with real auth state (Provider/Riverpod) later
bool _isLoggedIn = false;
bool _hasSeenOnboarding = false;

final appRouter = GoRouter(
  initialLocation: '/splash',
  redirect: (context, state) {
    final path = state.matchedLocation;
    if (path == '/splash' || path == '/onboarding') return null;
    final authPaths = {'/login', '/register', '/otp'};
    if (!_isLoggedIn && !authPaths.contains(path)) return '/login';
    return null;
  },
  routes: [
    GoRoute(path: '/splash',    builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/onboarding',builder: (_, __) => const OnboardingScreen()),
    GoRoute(path: '/login',     builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/register',  builder: (_, __) => const RegisterScreen()),
    GoRoute(path: '/otp',       builder: (c, s) => OtpScreen(email: s.extra as String? ?? '')),
    GoRoute(path: '/book',      builder: (_, __) => const BookAppointmentScreen()),
    GoRoute(path: '/appointments', builder: (_, __) => const AppointmentHistoryScreen()),
    GoRoute(path: '/treatments',   builder: (_, __) => const th.TreatmentHistoryScreen()),
    GoRoute(path: '/gallery',      builder: (_, __) => const GalleryScreen()),
    GoRoute(path: '/membership',   builder: (_, __) => const MembershipScreen()),
    GoRoute(path: '/loyalty',      builder: (_, __) => const LoyaltyScreen()),
    GoRoute(path: '/payments',     builder: (_, __) => const PaymentsScreen()),
    GoRoute(path: '/chat',         builder: (_, __) => const ChatScreen()),
    GoRoute(path: '/reviews',      builder: (_, __) => const ReviewsScreen()),
    GoRoute(path: '/settings',     builder: (_, __) => const SettingsScreen()),
    // Bottom-nav shell
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => _AppShell(shell: shell),
      branches: [
        StatefulShellBranch(routes: [GoRoute(path: '/home',       builder: (_, __) => const HomeScreen())]),
        StatefulShellBranch(routes: [GoRoute(path: '/services',   builder: (_, __) => const ServicesScreen())]),
        StatefulShellBranch(routes: [GoRoute(path: '/appt-tab',   builder: (_, __) => const AppointmentHistoryScreen())]),
        StatefulShellBranch(routes: [GoRoute(path: '/notif-tab',  builder: (_, __) => const NotificationsScreen())]),
        StatefulShellBranch(routes: [GoRoute(path: '/profile-tab',builder: (_, __) => const ProfileScreen())]),
      ],
    ),
  ],
);

void markLoggedIn()  { _isLoggedIn = true; }
void markLoggedOut() { _isLoggedIn = false; }
void markOnboarded() { _hasSeenOnboarding = true; }
bool get hasSeenOnboarding => _hasSeenOnboarding;

// ── Bottom nav shell ───────────────────────────────────────────────────────────
class _AppShell extends StatelessWidget {
  final StatefulNavigationShell shell;
  const _AppShell({required this.shell});

  static const _items = [
    BottomNavigationBarItem(icon: Icon(Icons.home_outlined),          activeIcon: Icon(Icons.home),          label: 'Home'),
    BottomNavigationBarItem(icon: Icon(Icons.spa_outlined),            activeIcon: Icon(Icons.spa),            label: 'Services'),
    BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined), activeIcon: Icon(Icons.calendar_month), label: 'Bookings'),
    BottomNavigationBarItem(icon: Icon(Icons.notifications_outlined),  activeIcon: Icon(Icons.notifications),  label: 'Alerts'),
    BottomNavigationBarItem(icon: Icon(Icons.person_outline),          activeIcon: Icon(Icons.person),         label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final p = HaTheme.of(context);
    return Scaffold(
      body: shell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: p.surface, border: Border(top: BorderSide(color: p.border))),
        child: BottomNavigationBar(
          currentIndex: shell.currentIndex,
          onTap: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
          items: _items,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: kGold,
          unselectedItemColor: p.textMuted,
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 10, unselectedFontSize: 10,
          selectedLabelStyle: p.body(10, weight: FontWeight.w600),
          unselectedLabelStyle: p.body(10),
        ),
      ),
    );
  }
}
