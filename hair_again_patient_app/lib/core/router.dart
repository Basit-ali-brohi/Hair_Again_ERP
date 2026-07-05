import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/splash_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/otp_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/reset_password_screen.dart';
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
import '../screens/settings/sessions_screen.dart';
import '../screens/settings/language_screen.dart';
import '../screens/settings/terms_screen.dart';
import '../screens/settings/privacy_screen.dart';
import '../screens/settings/help_screen.dart';
import 'theme.dart';

bool _isLoggedIn = false;
bool _hasSeenOnboarding = false;

// ── Transition helpers ─────────────────────────────────────────────────────────

/// Subtle fade + micro-slide up — standard push transition.
Page<void> _fadePage(Widget child) => CustomTransitionPage<void>(
  child: child,
  transitionDuration: const Duration(milliseconds: 280),
  reverseTransitionDuration: const Duration(milliseconds: 220),
  transitionsBuilder: (_, anim, __, child) => FadeTransition(
    opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
    child: SlideTransition(
      position: Tween(begin: const Offset(0, 0.04), end: Offset.zero)
          .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
      child: child,
    ),
  ),
);

/// Full slide-up from bottom — modal / detail screens.
Page<void> _slideUpPage(Widget child) => CustomTransitionPage<void>(
  child: child,
  transitionDuration: const Duration(milliseconds: 380),
  reverseTransitionDuration: const Duration(milliseconds: 300),
  transitionsBuilder: (_, anim, __, child) => SlideTransition(
    position: Tween(begin: const Offset(0, 1), end: Offset.zero)
        .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
    child: FadeTransition(
      opacity: Tween(begin: 0.0, end: 1.0)
          .animate(CurvedAnimation(parent: anim, curve: const Interval(0, 0.45))),
      child: child,
    ),
  ),
);

// ── Router ─────────────────────────────────────────────────────────────────────

final appRouter = GoRouter(
  initialLocation: '/splash',
  redirect: (context, state) {
    final path = state.matchedLocation;
    if (path == '/splash' || path == '/onboarding') return null;
    final authPaths = {'/login', '/register', '/otp', '/forgot-password', '/reset-password'};
    if (!_isLoggedIn && !authPaths.contains(path)) return '/login';
    return null;
  },
  routes: [
    GoRoute(path: '/splash',     builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),

    // Auth — fade transition
    GoRoute(path: '/login',    pageBuilder: (_, __) => _fadePage(const LoginScreen())),
    GoRoute(path: '/register', pageBuilder: (_, __) => _fadePage(const RegisterScreen())),
    GoRoute(path: '/otp', pageBuilder: (c, s) {
      final extra = s.extra;
      if (extra is Map<String, String>) {
        return _fadePage(OtpScreen(email: extra['email'] ?? '', mode: extra['mode'] ?? 'register'));
      }
      return _fadePage(OtpScreen(email: extra as String? ?? ''));
    }),
    GoRoute(path: '/forgot-password', pageBuilder: (_, __) => _fadePage(const ForgotPasswordScreen())),
    GoRoute(path: '/reset-password',  pageBuilder: (_, __) => _slideUpPage(const ResetPasswordScreen())),

    // Booking & history — slide up (modal feel)
    GoRoute(path: '/book',         pageBuilder: (_, __) => _slideUpPage(const BookAppointmentScreen())),
    GoRoute(path: '/appointments', pageBuilder: (_, __) => _fadePage(const AppointmentHistoryScreen())),
    GoRoute(path: '/treatments',   pageBuilder: (_, __) => _fadePage(const th.TreatmentHistoryScreen())),
    GoRoute(path: '/gallery',      pageBuilder: (_, __) => _fadePage(const GalleryScreen())),

    // Account screens — fade
    GoRoute(path: '/membership', pageBuilder: (_, __) => _fadePage(const MembershipScreen())),
    GoRoute(path: '/loyalty',    pageBuilder: (_, __) => _fadePage(const LoyaltyScreen())),
    GoRoute(path: '/payments',   pageBuilder: (_, __) => _fadePage(const PaymentsScreen())),
    GoRoute(path: '/reviews',    pageBuilder: (_, __) => _fadePage(const ReviewsScreen())),
    GoRoute(path: '/settings',   pageBuilder: (_, __) => _fadePage(const SettingsScreen())),
    GoRoute(path: '/sessions',   pageBuilder: (_, __) => _fadePage(const SessionsScreen())),
    GoRoute(path: '/language',   pageBuilder: (_, __) => _fadePage(const LanguageScreen())),
    GoRoute(path: '/terms',      pageBuilder: (_, __) => _fadePage(const TermsScreen())),
    GoRoute(path: '/privacy',    pageBuilder: (_, __) => _fadePage(const PrivacyScreen())),
    GoRoute(path: '/help',       pageBuilder: (_, __) => _fadePage(const HelpScreen())),

    // Chat — slide up
    GoRoute(path: '/chat', pageBuilder: (_, __) => _slideUpPage(const ChatScreen())),

    // Bottom-nav shell
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => _AppShell(shell: shell),
      branches: [
        StatefulShellBranch(routes: [GoRoute(path: '/home',        builder: (_, __) => const HomeScreen())]),
        StatefulShellBranch(routes: [GoRoute(path: '/services',    builder: (_, __) => const ServicesScreen())]),
        StatefulShellBranch(routes: [GoRoute(path: '/appt-tab',    builder: (_, __) => const AppointmentHistoryScreen())]),
        StatefulShellBranch(routes: [GoRoute(path: '/notif-tab',   builder: (_, __) => const NotificationsScreen())]),
        StatefulShellBranch(routes: [GoRoute(path: '/profile-tab', builder: (_, __) => const ProfileScreen())]),
      ],
    ),
  ],
);

void markLoggedIn()  { _isLoggedIn = true; }
void markLoggedOut() { _isLoggedIn = false; }
void markOnboarded() { _hasSeenOnboarding = true; }
bool get hasSeenOnboarding => _hasSeenOnboarding;

// ── Glassmorphism bottom nav shell ─────────────────────────────────────────────
class _AppShell extends StatelessWidget {
  final StatefulNavigationShell shell;
  const _AppShell({required this.shell});

  static const _items = [
    BottomNavigationBarItem(icon: Icon(Icons.home_outlined),          activeIcon: Icon(Icons.home_rounded),         label: 'Home'),
    BottomNavigationBarItem(icon: Icon(Icons.spa_outlined),            activeIcon: Icon(Icons.spa_rounded),           label: 'Services'),
    BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined), activeIcon: Icon(Icons.calendar_month_rounded),label: 'Bookings'),
    BottomNavigationBarItem(icon: Icon(Icons.notifications_outlined),  activeIcon: Icon(Icons.notifications_rounded), label: 'Alerts'),
    BottomNavigationBarItem(icon: Icon(Icons.person_outline),          activeIcon: Icon(Icons.person_rounded),        label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final p = HaTheme.of(context);
    return Scaffold(
      extendBody: true,        // body renders behind the glass nav
      body: shell,
      bottomNavigationBar: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
          child: Container(
            decoration: BoxDecoration(
              color: p.isDark
                  ? Colors.black.withValues(alpha: 0.60)
                  : Colors.white.withValues(alpha: 0.82),
              border: Border(top: BorderSide(
                color: p.isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.06),
                width: 0.5,
              )),
            ),
            child: BottomNavigationBar(
              currentIndex: shell.currentIndex,
              onTap: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
              items: _items,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: kGold,
              unselectedItemColor: p.textMuted,
              type: BottomNavigationBarType.fixed,
              selectedFontSize: 10,
              unselectedFontSize: 10,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.2),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
            ),
          ),
        ),
      ),
    );
  }
}
