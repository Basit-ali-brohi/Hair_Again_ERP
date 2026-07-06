import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'theme.dart';

enum StaffRole { receptionist, doctor, manager, admin }

extension StaffRoleX on StaffRole {
  String get label => switch (this) {
    StaffRole.receptionist => 'Receptionist',
    StaffRole.doctor       => 'Doctor',
    StaffRole.manager      => 'Branch Manager',
    StaffRole.admin        => 'Admin',
  };
  IconData get icon => switch (this) {
    StaffRole.receptionist => Icons.support_agent_rounded,
    StaffRole.doctor       => Icons.medical_services_rounded,
    StaffRole.manager      => Icons.manage_accounts_rounded,
    StaffRole.admin        => Icons.admin_panel_settings_rounded,
  };

  // Permission flags
  bool get canViewRevenue  => this == StaffRole.admin || this == StaffRole.manager;
  bool get canAccessPOS    => this != StaffRole.doctor;
  bool get canConsult      => this == StaffRole.doctor || this == StaffRole.admin;
  bool get canBookAppt     => this != StaffRole.doctor;
  bool get isAdmin         => this == StaffRole.admin;
}

// ── Models ─────────────────────────────────────────────────────────────────────
class StaffAppointment {
  final String id, patientName, service, doctor, slot;
  final DateTime dateTime;
  String status;

  StaffAppointment({required this.id, required this.patientName, required this.service,
    required this.doctor, required this.dateTime, required this.slot, required this.status});

  bool get isToday {
    final n = DateTime.now();
    return dateTime.year == n.year && dateTime.month == n.month && dateTime.day == n.day;
  }
  String get timeStr  => DateFormat('hh:mm a').format(dateTime);
  String get dateStr  => DateFormat('EEE, d MMM').format(dateTime);
  String get fullDate => DateFormat('EEE, d MMM yyyy').format(dateTime);

  Color get statusColor => switch (status) {
    'Scheduled'  => kInfo,
    'Checked In' => kWarning,
    'Completed'  => kSuccess,
    'Cancelled'  => kDanger,
    'No Show'    => const Color(0xFF9E9E9E),
    _            => kInfo,
  };
  IconData get statusIcon => switch (status) {
    'Scheduled'  => Icons.schedule_rounded,
    'Checked In' => Icons.login_rounded,
    'Completed'  => Icons.check_circle_rounded,
    'Cancelled'  => Icons.cancel_rounded,
    'No Show'    => Icons.person_off_rounded,
    _            => Icons.schedule_rounded,
  };
}

class StaffPatient {
  final String id, name, phone, email, bloodGroup, initials, age;
  final int visitCount;
  final String lastVisit, membershipTier;
  final int loyaltyPoints;
  final List<String> conditions;

  const StaffPatient({required this.id, required this.name, required this.phone,
    required this.email, required this.bloodGroup, required this.initials,
    required this.age, required this.visitCount, required this.lastVisit,
    required this.membershipTier, required this.loyaltyPoints, required this.conditions});
}

class StaffNotification {
  final String id, title, body, timeStr, category;
  final IconData icon;
  final Color color;
  bool isRead;

  StaffNotification({required this.id, required this.title, required this.body,
    required this.timeStr, required this.category, required this.icon,
    required this.color, this.isRead = false});
}

class AttendanceRecord {
  final DateTime date;
  final String? clockIn, clockOut;
  final String status;
  final double hoursWorked;

  const AttendanceRecord({required this.date, this.clockIn, this.clockOut,
    required this.status, required this.hoursWorked});

  String get dateStr => DateFormat('EEE, d MMM').format(date);
  Color get statusColor => switch (status) {
    'Present'  => kSuccess,
    'Absent'   => kDanger,
    'Half Day' => kWarning,
    'Leave'    => kInfo,
    _          => kInfo,
  };
}

class PosItem {
  final String id, name, category;
  final double price;
  final IconData icon;
  final Color color;
  int qty;

  PosItem({required this.id, required this.name, required this.category,
    required this.price, required this.icon, required this.color, this.qty = 0});

  PosItem copyWith({int? qty}) => PosItem(
    id: id, name: name, category: category, price: price,
    icon: icon, color: color, qty: qty ?? this.qty,
  );
}

// ── Central data service ───────────────────────────────────────────────────────
class StaffDataService extends ChangeNotifier {
  bool _loggedIn = false;
  StaffRole _role = StaffRole.receptionist;
  String _staffName = 'Sana Iqbal';

  bool get loggedIn => _loggedIn;
  StaffRole get role => _role;
  String get staffName => _staffName;
  String get staffInitials {
    final parts = _staffName.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts[0][0].toUpperCase();
  }

  void login(String name, StaffRole role) {
    _loggedIn = true; _staffName = name; _role = role; notifyListeners();
  }
  void logout() { _loggedIn = false; notifyListeners(); }

  // Attendance clock
  bool _clockedIn = false;
  DateTime? _clockInTime;
  bool get clockedIn => _clockedIn;
  DateTime? get clockInTime => _clockInTime;

  void clockIn() {
    _clockedIn = true; _clockInTime = DateTime.now();
    _addNotif('Clocked In', 'You clocked in at ${DateFormat('hh:mm a').format(DateTime.now())}',
        'Attendance', Icons.login_rounded, kSuccess);
    notifyListeners();
  }
  void clockOut() {
    _clockedIn = false;
    _addNotif('Clocked Out', 'You clocked out at ${DateFormat('hh:mm a').format(DateTime.now())}',
        'Attendance', Icons.logout_rounded, kWarning);
    notifyListeners();
  }

  // Appointments
  late List<StaffAppointment> _appointments;
  List<StaffAppointment> get allAppointments => List.unmodifiable(_appointments);

  List<StaffAppointment> get todayAppointments =>
      _appointments.where((a) => a.isToday).toList()
        ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

  int get todayCount         => todayAppointments.length;
  int get checkedInCount     => todayAppointments.where((a) => a.status == 'Checked In').length;
  int get completedTodayCount=> todayAppointments.where((a) => a.status == 'Completed').length;
  int get pendingCount       => todayAppointments.where((a) => a.status == 'Scheduled').length;

  void checkIn(String id) {
    final a = _appointments.firstWhere((x) => x.id == id);
    a.status = 'Checked In';
    _addNotif('Patient Checked In', '${a.patientName} checked in for ${a.service}',
        'Appointments', Icons.login_rounded, kSuccess);
    notifyListeners();
  }
  void checkOut(String id) {
    final a = _appointments.firstWhere((x) => x.id == id);
    a.status = 'Completed'; notifyListeners();
  }
  void cancelAppt(String id) {
    final a = _appointments.firstWhere((x) => x.id == id);
    a.status = 'Cancelled'; notifyListeners();
  }
  void addAppointment(StaffAppointment a) {
    _appointments.add(a);
    _addNotif('New Appointment', '${a.patientName} booked for ${a.service} on ${a.dateStr}',
        'Appointments', Icons.calendar_today_rounded, kGold);
    notifyListeners();
  }

  // Patients
  late List<StaffPatient> _patients;
  List<StaffPatient> get patients => List.unmodifiable(_patients);
  List<StaffPatient> searchPatients(String q) {
    if (q.trim().isEmpty) return _patients;
    final l = q.toLowerCase();
    return _patients.where((p) =>
      p.name.toLowerCase().contains(l) || p.phone.contains(l)).toList();
  }

  // Notifications
  late List<StaffNotification> _notifications;
  List<StaffNotification> get notifications => List.unmodifiable(_notifications);
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void markRead(String id) {
    _notifications.firstWhere((n) => n.id == id).isRead = true; notifyListeners();
  }
  void markAllRead() {
    for (final n in _notifications) { n.isRead = true; } notifyListeners();
  }
  void _addNotif(String title, String body, String cat, IconData icon, Color color) {
    _notifications.insert(0, StaffNotification(
      id: 'n_${DateTime.now().millisecondsSinceEpoch}',
      title: title, body: body, timeStr: 'Just now',
      category: cat, icon: icon, color: color,
    ));
  }

  // Attendance
  late List<AttendanceRecord> _attendance;
  List<AttendanceRecord> get attendance => List.unmodifiable(_attendance);

  // Revenue
  final List<_Sale> _sales = [];
  double get todayRevenue {
    final t = DateTime.now();
    return _sales.where((s) => s.date.year == t.year && s.date.month == t.month && s.date.day == t.day)
        .fold(0.0, (sum, s) => sum + s.total);
  }
  void recordSale(double total) { _sales.add(_Sale(DateTime.now(), total)); notifyListeners(); }

  // POS catalog (fresh list each time so qty starts at 0)
  List<PosItem> get posServices => [
    PosItem(id: 's1', name: 'Hair Transplant Consult', category: 'Consultation', price: 1500,  icon: Icons.person_rounded,       color: kGold),
    PosItem(id: 's2', name: 'PRP Therapy Session',     category: 'Treatment',    price: 12000, icon: Icons.water_drop_rounded,    color: kInfo),
    PosItem(id: 's3', name: 'Scalp Micropigmentation', category: 'Treatment',    price: 25000, icon: Icons.brush_rounded,         color: const Color(0xFF9B59B6)),
    PosItem(id: 's4', name: 'LLLT Laser Session',      category: 'Treatment',    price: 6000,  icon: Icons.flash_on_rounded,      color: kWarning),
    PosItem(id: 's5', name: 'Scalp Deep Treatment',    category: 'Service',      price: 4500,  icon: Icons.spa_rounded,           color: const Color(0xFF3FA787)),
    PosItem(id: 's6', name: 'Hair Analysis Report',    category: 'Consultation', price: 800,   icon: Icons.biotech_rounded,       color: kSuccess),
    PosItem(id: 's7', name: 'Post-Surgery Follow-up',  category: 'Consultation', price: 2000,  icon: Icons.health_and_safety_rounded, color: kDanger),
  ];

  StaffDataService() { _seed(); }

  void _seed() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    _appointments = [
      StaffAppointment(id: 'a1', patientName: 'Ahmad Ali',      service: 'Hair Transplant Consult', doctor: 'Dr. Bilal Khan',
          dateTime: today.add(const Duration(hours: 9)),  slot: '09:00 AM', status: 'Completed'),
      StaffAppointment(id: 'a2', patientName: 'Zara Siddiqui',  service: 'PRP Therapy',             doctor: 'Dr. Sara Malik',
          dateTime: today.add(const Duration(hours: 10)), slot: '10:00 AM', status: 'Checked In'),
      StaffAppointment(id: 'a3', patientName: 'Usman Tariq',    service: 'Scalp Micropigmentation', doctor: 'Dr. Omar Farooq',
          dateTime: today.add(const Duration(hours: 11)), slot: '11:00 AM', status: 'Scheduled'),
      StaffAppointment(id: 'a4', patientName: 'Fatima Khan',    service: 'LLLT Laser Therapy',      doctor: 'Dr. Bilal Khan',
          dateTime: today.add(const Duration(hours: 13)), slot: '01:00 PM', status: 'Scheduled'),
      StaffAppointment(id: 'a5', patientName: 'Hamza Malik',    service: 'Hair Consult',            doctor: 'Dr. Sara Malik',
          dateTime: today.add(const Duration(hours: 14)), slot: '02:00 PM', status: 'Scheduled'),
      StaffAppointment(id: 'a6', patientName: 'Ayesha Raza',    service: 'Scalp Deep Treatment',    doctor: 'Dr. Omar Farooq',
          dateTime: today.add(const Duration(hours: 15)), slot: '03:00 PM', status: 'Scheduled'),
      StaffAppointment(id: 'a7', patientName: 'Bilal Ahmed',    service: 'PRP Therapy',             doctor: 'Dr. Bilal Khan',
          dateTime: now.add(const Duration(days: 1, hours: 2)), slot: '09:00 AM', status: 'Scheduled'),
      StaffAppointment(id: 'a8', patientName: 'Sara Noor',      service: 'Hair Analysis',           doctor: 'Dr. Sara Malik',
          dateTime: now.add(const Duration(days: 1, hours: 4)), slot: '11:00 AM', status: 'Scheduled'),
      StaffAppointment(id: 'a9', patientName: 'Kamran Iqbal',   service: 'Scalp Treatment',         doctor: 'Dr. Omar Farooq',
          dateTime: now.add(const Duration(days: 2, hours: 3)), slot: '10:00 AM', status: 'Scheduled'),
    ];

    _patients = const [
      StaffPatient(id: 'p1', name: 'Ahmad Ali',     phone: '+92 300 1234567', email: 'ahmad@gmail.com',
          bloodGroup: 'O+',  initials: 'AA', age: '32 yrs', visitCount: 8,  lastVisit: '2 days ago',
          membershipTier: 'Gold',     loyaltyPoints: 1250, conditions: ['Male Pattern Baldness']),
      StaffPatient(id: 'p2', name: 'Zara Siddiqui', phone: '+92 321 9876543', email: 'zara@gmail.com',
          bloodGroup: 'A+',  initials: 'ZS', age: '27 yrs', visitCount: 3,  lastVisit: 'Today',
          membershipTier: 'Silver',   loyaltyPoints: 380,  conditions: ['Hair Thinning']),
      StaffPatient(id: 'p3', name: 'Usman Tariq',   phone: '+92 333 5556677', email: 'usman@gmail.com',
          bloodGroup: 'B+',  initials: 'UT', age: '41 yrs', visitCount: 5,  lastVisit: '1 week ago',
          membershipTier: 'Gold',     loyaltyPoints: 820,  conditions: ['Alopecia Areata']),
      StaffPatient(id: 'p4', name: 'Fatima Khan',   phone: '+92 345 1122334', email: 'fatima@gmail.com',
          bloodGroup: 'AB+', initials: 'FK', age: '29 yrs', visitCount: 2,  lastVisit: '3 days ago',
          membershipTier: 'Basic',    loyaltyPoints: 120,  conditions: ['Scalp Psoriasis']),
      StaffPatient(id: 'p5', name: 'Hamza Malik',   phone: '+92 300 9988776', email: 'hamza@gmail.com',
          bloodGroup: 'O-',  initials: 'HM', age: '38 yrs', visitCount: 11, lastVisit: 'Yesterday',
          membershipTier: 'Platinum', loyaltyPoints: 3200, conditions: ['Male Pattern Baldness', 'Seborrheic Dermatitis']),
      StaffPatient(id: 'p6', name: 'Ayesha Raza',   phone: '+92 311 4455667', email: 'ayesha@gmail.com',
          bloodGroup: 'A-',  initials: 'AR', age: '33 yrs', visitCount: 6,  lastVisit: '5 days ago',
          membershipTier: 'Silver',   loyaltyPoints: 640,  conditions: ['Post-partum Hair Loss']),
    ];

    _notifications = [
      StaffNotification(id: 'n1', title: 'Usman Tariq — Due Soon',    body: 'Appointment at 11:00 AM in 20 minutes',
          timeStr: '10:40 AM', category: 'Appointments', icon: Icons.schedule_rounded,       color: kWarning),
      StaffNotification(id: 'n2', title: 'Zara Siddiqui Checked In',  body: 'Patient checked in for PRP Therapy',
          timeStr: '10:02 AM', category: 'Appointments', icon: Icons.login_rounded,           color: kSuccess),
      StaffNotification(id: 'n3', title: 'Low Stock Alert',           body: 'PRP Solution — only 3 units left',
          timeStr: '9:30 AM',  category: 'Inventory',    icon: Icons.inventory_2_rounded,     color: kDanger),
      StaffNotification(id: 'n4', title: 'Payment Received',          body: 'Rs 12,000 from Zara Siddiqui — PRP Therapy',
          timeStr: '9:15 AM',  category: 'POS',          icon: Icons.payments_rounded,        color: kSuccess, isRead: true),
      StaffNotification(id: 'n5', title: 'New Booking',               body: 'Hamza Malik booked Hair Consult tomorrow',
          timeStr: 'Yesterday',category: 'Appointments', icon: Icons.calendar_today_rounded,  color: kGold,    isRead: true),
      StaffNotification(id: 'n6', title: 'Shift Reminder',            body: 'Your shift starts at 9:00 AM',
          timeStr: 'Yesterday',category: 'Attendance',   icon: Icons.access_time_rounded,     color: kInfo,    isRead: true),
    ];

    _attendance = List.generate(14, (i) {
      final d = today.subtract(Duration(days: i + 1));
      final isWeekend = d.weekday == 6 || d.weekday == 7;
      final status = isWeekend ? 'Leave' : (i == 3 ? 'Absent' : (i == 7 ? 'Half Day' : 'Present'));
      return AttendanceRecord(
        date: d,
        clockIn:  (!isWeekend && status != 'Absent') ? '09:0${i % 3} AM' : null,
        clockOut: (!isWeekend && status != 'Absent') ? '0${5 + (i % 3)}:00 PM' : null,
        status: status,
        hoursWorked: isWeekend || status == 'Absent' ? 0 : (status == 'Half Day' ? 4.0 : 8.5),
      );
    });

    _sales
      ..add(_Sale(today.add(const Duration(hours: 9, minutes: 30)), 1500))
      ..add(_Sale(today.add(const Duration(hours: 10, minutes: 15)), 12000));
  }
}

class _Sale {
  final DateTime date;
  final double total;
  _Sale(this.date, this.total);
}

final staffData = StaffDataService();
