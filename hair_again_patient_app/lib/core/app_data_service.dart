import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'theme.dart';

// ── Models ──────────────────────────────────────────────────────────────────────

class HaAppointment {
  final String id, title, doctor, slot;
  final DateTime dateTime;
  String status; // Confirmed | Pending | Cancelled | Completed

  HaAppointment({
    required this.id, required this.title, required this.doctor,
    required this.dateTime, required this.slot, this.status = 'Confirmed',
  });

  bool get isUpcoming => dateTime.isAfter(DateTime.now()) && status != 'Cancelled' && status != 'Completed';

  String get dateStr => DateFormat('EEE, d MMM yyyy').format(dateTime);

  String get shortDate => DateFormat('d MMM').format(dateTime);

  Color get statusColor {
    switch (status) {
      case 'Confirmed':  return kSuccess;
      case 'Pending':    return kWarning;
      case 'Cancelled':  return kDanger;
      case 'Completed':  return kInfo;
      default:           return kInfo;
    }
  }
}

class HaNotification {
  final String id, title, body, timeStr, category;
  final IconData icon;
  final Color color;
  bool isRead;

  HaNotification({
    required this.id, required this.title, required this.body,
    required this.timeStr, required this.category,
    required this.icon, required this.color, this.isRead = false,
  });
}

// ── Service ──────────────────────────────────────────────────────────────────────

class AppDataService extends ChangeNotifier {
  // ── Appointments ────────────────────────────────────────────────────────────
  final List<HaAppointment> _appointments = [
    HaAppointment(id: 'a1', title: 'Hair Transplant Consultation', doctor: 'Dr. Bilal Khan',
        dateTime: DateTime.now().add(const Duration(days: 2, hours: 11)), slot: '11:00 AM', status: 'Confirmed'),
    HaAppointment(id: 'a2', title: 'PRP Therapy', doctor: 'Dr. Sara Malik',
        dateTime: DateTime.now().add(const Duration(days: 13, hours: 14)), slot: '02:00 PM', status: 'Pending'),
    HaAppointment(id: 'a3', title: 'Scalp Analysis', doctor: 'Dr. Omar Farooq',
        dateTime: DateTime.now().subtract(const Duration(days: 21, hours: 10)), slot: '10:00 AM', status: 'Completed'),
    HaAppointment(id: 'a4', title: 'Hair Loss Consultation', doctor: 'Dr. Bilal Khan',
        dateTime: DateTime.now().subtract(const Duration(days: 33, hours: 11, minutes: 30)), slot: '11:30 AM', status: 'Completed'),
    HaAppointment(id: 'a5', title: 'LLLT Session', doctor: 'Dr. Sara Malik',
        dateTime: DateTime.now().subtract(const Duration(days: 45, hours: 15)), slot: '03:00 PM', status: 'Cancelled'),
    HaAppointment(id: 'a6', title: 'PRP Therapy', doctor: 'Dr. Bilal Khan',
        dateTime: DateTime.now().subtract(const Duration(days: 63, hours: 9)), slot: '09:00 AM', status: 'Completed'),
  ];

  List<HaAppointment> get upcoming => _appointments.where((a) => a.isUpcoming).toList()
    ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

  List<HaAppointment> get past => _appointments.where((a) => !a.isUpcoming).toList()
    ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

  HaAppointment? get nextAppointment => upcoming.isNotEmpty ? upcoming.first : null;

  int get upcomingCount => upcoming.length;

  void bookAppointment(HaAppointment appt) {
    _appointments.add(appt);
    addNotification(HaNotification(
      id: 'n_${appt.id}',
      title: 'Booking Confirmed',
      body: '${appt.title} with ${appt.doctor} on ${appt.shortDate} at ${appt.slot}.',
      timeStr: 'Just now',
      category: 'Appointments',
      icon: Icons.check_circle_outline,
      color: kSuccess,
      isRead: false,
    ));
    notifyListeners();
  }

  void cancelAppointment(String id) {
    final idx = _appointments.indexWhere((a) => a.id == id);
    if (idx != -1) {
      _appointments[idx].status = 'Cancelled';
      addNotification(HaNotification(
        id: 'nc_$id',
        title: 'Appointment Cancelled',
        body: '${_appointments[idx].title} on ${_appointments[idx].shortDate} has been cancelled.',
        timeStr: 'Just now',
        category: 'Appointments',
        icon: Icons.cancel_outlined,
        color: kDanger,
        isRead: false,
      ));
      notifyListeners();
    }
  }

  // ── Notifications ────────────────────────────────────────────────────────────
  final List<HaNotification> _notifications = [
    HaNotification(id: 'n0', icon: Icons.calendar_month_outlined, color: kGold,
      title: 'Appointment Reminder', body: 'Your appointment with Dr. Bilal Khan is in 2 days at 11:00 AM.',
      timeStr: '1h ago', category: 'Appointments', isRead: false),
    HaNotification(id: 'n1', icon: Icons.check_circle_outline, color: kSuccess,
      title: 'Booking Confirmed', body: 'Your PRP Therapy session has been confirmed for the 18th.',
      timeStr: '1 day ago', category: 'Appointments', isRead: true),
    HaNotification(id: 'n2', icon: Icons.payment_outlined, color: kInfo,
      title: 'Payment Received', body: 'Rs 12,000 payment for PRP Therapy received.',
      timeStr: '2 days ago', category: 'Payments', isRead: true),
    HaNotification(id: 'n3', icon: Icons.local_offer_outlined, color: kWarning,
      title: '20% Off This Week', body: 'Book a PRP session this week and get 20% off. Limited slots!',
      timeStr: '3 days ago', category: 'Promotions', isRead: true),
    HaNotification(id: 'n4', icon: Icons.star_outline, color: kGold,
      title: 'Points Credited', body: '150 loyalty points added for your last visit.',
      timeStr: '4 days ago', category: 'System', isRead: true),
    HaNotification(id: 'n5', icon: Icons.workspace_premium_outlined, color: kGold,
      title: 'Membership Renewed', body: 'Your Gold membership has been renewed.',
      timeStr: '5 days ago', category: 'Payments', isRead: true),
    HaNotification(id: 'n6', icon: Icons.info_outline, color: kInfo,
      title: 'New Services Available', body: 'Check out our new Stem Cell Therapy treatment.',
      timeStr: '1 week ago', category: 'Promotions', isRead: true),
  ];

  List<HaNotification> get notifications => List.unmodifiable(_notifications);
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void addNotification(HaNotification n) {
    _notifications.insert(0, n);
    notifyListeners();
  }

  void markNotifRead(String id) {
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx != -1 && !_notifications[idx].isRead) {
      _notifications[idx].isRead = true;
      notifyListeners();
    }
  }

  void markAllNotifsRead() {
    bool changed = false;
    for (final n in _notifications) { if (!n.isRead) { n.isRead = true; changed = true; } }
    if (changed) notifyListeners();
  }

  // ── Stats ─────────────────────────────────────────────────────────────────────
  int loyaltyPoints = 1250;
  String membershipTier = 'Gold';

  void addLoyaltyPoints(int pts) {
    loyaltyPoints += pts;
    notifyListeners();
  }
}

final appData = AppDataService();
