import 'package:go_router/go_router.dart';
import '../screens/auth/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/appointments/appointments_screen.dart';
import '../screens/appointments/book_appointment_screen.dart';
import '../screens/patients/patients_screen.dart';
import '../screens/patients/patient_detail_screen.dart';
import '../screens/consultation/consultation_screen.dart';
import '../screens/pos/pos_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../screens/attendance/attendance_screen.dart';
import '../screens/profile/profile_screen.dart';
import 'staff_data.dart';

final staffRouter = GoRouter(
  initialLocation: '/splash',
  redirect: (context, state) {
    final loggedIn = staffData.loggedIn;
    const publicRoutes = {'/splash', '/login'};
    if (!loggedIn && !publicRoutes.contains(state.matchedLocation)) return '/login';
    if (loggedIn && state.matchedLocation == '/login') return '/dashboard';
    return null;
  },
  routes: [
    GoRoute(path: '/splash',   builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/login',    builder: (_, __) => const StaffLoginScreen()),
    GoRoute(path: '/dashboard',builder: (_, __) => const DashboardScreen()),
    GoRoute(path: '/appointments', builder: (_, __) => const AppointmentsScreen()),
    GoRoute(path: '/book-appointment', builder: (_, s) {
      final patientName = s.extra as String?;
      return BookAppointmentScreen(prefillPatient: patientName);
    }),
    GoRoute(path: '/patients', builder: (_, __) => const PatientsScreen()),
    GoRoute(path: '/patient-detail', builder: (_, s) => PatientDetailScreen(patient: s.extra as dynamic)),
    GoRoute(path: '/consultation', builder: (_, s) => ConsultationScreen(appointmentId: s.extra as String?)),
    GoRoute(path: '/pos',          builder: (_, __) => const PosScreen()),
    GoRoute(path: '/notifications',builder: (_, __) => const StaffNotificationsScreen()),
    GoRoute(path: '/attendance',   builder: (_, __) => const AttendanceScreen()),
    GoRoute(path: '/profile',      builder: (_, __) => const StaffProfileScreen()),
  ],
);
