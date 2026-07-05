import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../utils/formatters.dart';
import '../utils/storage_service.dart';
import '../../modules/auth/models/auth_models.dart';
import '../../modules/crm/models/patient.dart';
import '../../modules/pos_inventory/models/pos_models.dart';
import '../../modules/appointments/models/appointment.dart';
import '../../modules/staff/models/staff.dart';
import '../../modules/hr/models/hr_models.dart';
import '../../modules/leads/models/lead_models.dart';
import '../../modules/finance/models/finance_models.dart';
import '../../modules/marketing/models/marketing_models.dart';
import '../../modules/consultation/models/consultation_models.dart';
import '../../modules/company/models/company_models.dart';
import '../../modules/treatment/models/treatment_models.dart';
import '../../modules/transplant/models/transplant_models.dart';
import '../../modules/membership/models/membership_models.dart';
import '../../modules/loyalty/models/loyalty_models.dart';
import '../../modules/vendors/models/vendor_models.dart';
import '../../modules/products/models/product_models.dart';
import '../../modules/hair_patch/models/hair_patch_models.dart';
import '../../modules/inventory/models/inventory_models.dart';

final AppState appState = AppState();

class AppNotification {
  final String title;
  final String subtitle;
  final IconData icon;
  bool read;
  AppNotification({required this.title, required this.subtitle, required this.icon, this.read = false});
}

class AppState extends ChangeNotifier {
  // ── Persistence helpers ──────────────────────────────────────────────────────
  List<T> _loadOrSeed<T>(String key, List<T> Function() seeder, T Function(Map<String, dynamic>) fromJson) {
    final stored = StorageService.loadList(key);
    if (stored.isNotEmpty) return stored.map(fromJson).toList();
    return seeder();
  }

  // ── Theme / Accent ──────────────────────────────────────────────────────────
  bool isDark = StorageService.getBool('isDark', true);
  int accentIndex = StorageService.getInt('accentIndex', 0);

  static const List<({String name, Color color})> accents = [
    (name: 'Brushed Gold', color: Color(0xFFC9A24B)),
    (name: 'Forest Green', color: Color(0xFF16A34A)),
    (name: 'Emerald', color: Color(0xFF3FA787)),
    (name: 'Sapphire', color: Color(0xFF4F7BE0)),
    (name: 'Rose', color: Color(0xFFD16A8A)),
  ];

  Color get accent => accents[accentIndex].color;
  AppPalette get palette => AppPalette(isDark, accent);

  void toggleTheme() { isDark = !isDark; StorageService.setBool('isDark', isDark); notifyListeners(); }
  void setAccent(int i) { accentIndex = i; StorageService.setInt('accentIndex', i); notifyListeners(); }

  // ── Splash ──────────────────────────────────────────────────────────────────
  bool splashDone = false;
  void splashComplete() { splashDone = true; notifyListeners(); }

  // ── Auth ────────────────────────────────────────────────────────────────────
  AppUser? currentUser;
  late final List<AppUser> systemUsers = List.from(demoUsers);
  final List<ActivityLog> activityLogs = [];
  final List<LoginHistoryEntry> loginHistory = [];

  void login(AppUser user) {
    currentUser = user;
    user.lastLogin = DateTime.now();
    loginHistory.insert(0, LoginHistoryEntry(
      id: 'LH-${loginHistory.length + 1}',
      userId: user.id, userName: user.name, role: user.role,
      loginTime: DateTime.now(), ipAddress: '192.168.1.${(loginHistory.length % 50) + 10}',
      device: 'Windows 10 — Chrome',
    ));
    _log(user, 'Logged in', 'Authentication');
    activeIndex = 0;
    notifyListeners();
  }

  void logout() {
    if (loginHistory.isNotEmpty) loginHistory.first.logoutTime = DateTime.now();
    currentUser = null;
    activeIndex = 0;
    notifyListeners();
  }

  void addSystemUser(AppUser u) {
    systemUsers.insert(0, u);
    _log(currentUser!, 'Created user ${u.name}', 'User Management');
    notifyListeners();
  }

  void toggleUserActive(AppUser u) {
    u.isActive = !u.isActive;
    _log(currentUser!, '${u.isActive ? "Activated" : "Deactivated"} user ${u.name}', 'User Management');
    notifyListeners();
  }

  void _log(AppUser user, String action, String module, {String? detail}) {
    activityLogs.insert(0, ActivityLog(
      id: 'AL-${activityLogs.length + 1}',
      userId: user.id, userName: user.name, userRole: user.role,
      action: action, module: module,
      timestamp: DateTime.now(), detail: detail,
    ));
  }

  // ── Navigation ───────────────────────────────────────────────────────────────
  int activeIndex = 0;
  void go(int i) {
    if (currentUser != null && !currentUser!.role.accessibleIndices.contains(i)) return;
    if (activeIndex == i) return;
    activeIndex = i;
    notifyListeners();
  }

  // ── ID helpers ───────────────────────────────────────────────────────────────
  int _id = 1000;
  String _newId(String p) => '$p-${_id++}';
  String createPatientId() => _newId('PT');
  String createInvoiceId() => _newId('INV');
  String createInventoryId() => _newId('SKU');
  String createAppointmentId() => _newId('AP');
  String createLeadId() => _newId('LD');
  String createIncomeId() => _newId('INC');
  String createExpenseId() => _newId('EXP');
  String createCampaignId() => _newId('CAM');
  String createConsultationId() => _newId('CON');
  String createPayrollId() => _newId('PAY');
  String createJobPostId() => _newId('JP');
  String createApplicantId() => _newId('JA');
  String createCouponId() => _newId('CPN');
  String createPromoId() => _newId('PRO');
  String createBranchId() => _newId('BR');
  String createDeptId() => _newId('DP');
  String createDesigId() => _newId('DG');
  String createHolidayId() => _newId('HOL');
  String createTreatId() => _newId('TP');
  String createTransplantId() => _newId('TC');
  String createPlanId() => _newId('MP');
  String createMembershipId() => _newId('CM');
  String createRewardId() => _newId('RW');
  String createReferralId() => _newId('RF');
  String createVendorId() => _newId('VN');
  String createPOId() => _newId('PO');
  String createProductId() => _newId('PR');
  String createCategoryId() => _newId('CAT');
  String createBrandId() => _newId('BRD');
  String createHairPatchId()   => _newId('HP');
  String createPatchOrderId()  => _newId('PO2');
  String createFittingId()     => _newId('FIT');
  String createMaintenanceId() => _newId('MNT');
  String createStockItemId()   => _newId('STK');
  String createMovementId()    => _newId('MV');
  String createAuditId()       => _newId('AUD');

  // ── Clinic Profile ────────────────────────────────────────────────────────────
  String clinicName    = StorageService.getString('clinicName',    'Hair Again — Transplant & Care');
  String clinicAddress = StorageService.getString('clinicAddress', 'Clifton Block 5, Karachi, Pakistan');
  String clinicPhone   = StorageService.getString('clinicPhone',   '+92 21 111 444 555');
  String clinicEmail   = StorageService.getString('clinicEmail',   'care@hairagain.pk');

  List<String> get surgeons =>
      staff.where((s) => s.role == StaffRole.doctor && s.active).map((s) => s.name).toList();

  // ── Notifications ─────────────────────────────────────────────────────────────
  final List<AppNotification> notifications = [
    AppNotification(title: 'Low stock alert', subtitle: 'PRP Kits below reorder level', icon: Icons.inventory_2_outlined),
    AppNotification(title: 'Follow-up due', subtitle: 'Bilal Ahmed — Day-7 post-op review', icon: Icons.event_available_outlined),
    AppNotification(title: 'New lead captured', subtitle: 'Instagram campaign — Sana Tariq', icon: Icons.person_add_alt_1_outlined),
    AppNotification(title: 'Leave request pending', subtitle: 'Hira Saleem — Sick Leave (2 days)', icon: Icons.event_note_outlined),
    AppNotification(title: 'Payroll due', subtitle: 'June 2026 payroll not yet processed', icon: Icons.payments_outlined),
  ];

  int get unreadCount => notifications.where((n) => !n.read).length;
  void markAllRead() { for (final n in notifications) n.read = true; notifyListeners(); }
  void _notify(String t, String s, IconData i) =>
      notifications.insert(0, AppNotification(title: t, subtitle: s, icon: i));
  void touch() => notifyListeners();

  // ── Existing module data ──────────────────────────────────────────────────────
  late final List<Staff>      staff      = _loadOrSeed('staff',    _seedStaff,    Staff.fromJson);
  late final List<Treatment>  treatments = _seedTreatments();
  late final List<Patient>    patients   = _loadOrSeed('patients', _seedPatients, Patient.fromJson);
  late final List<InventoryItem> inventory = _seedInventory();
  late final List<Appointment>   appointments = _loadOrSeed('appointments', _seedAppointments, Appointment.fromJson);
  late final List<Invoice>       invoices     = _loadOrSeed('invoices', () => [], Invoice.fromJson);

  // ── Save helpers ──────────────────────────────────────────────────────────────
  void _savePatients()     => StorageService.saveObjects('patients',     patients);
  void _saveAppointments() => StorageService.saveObjects('appointments', appointments);
  void _saveInvoices()     => StorageService.saveObjects('invoices',     invoices);
  void _saveStaff()        => StorageService.saveObjects('staff',        staff);
  void _saveLeads()        => StorageService.saveObjects('leads',        leads);
  void _saveIncome()       => StorageService.saveObjects('income',       incomeEntries);
  void _saveExpenses()     => StorageService.saveObjects('expenses',     expenseEntries);
  void saveClinicProfile() {
    StorageService.setString('clinicName',    clinicName);
    StorageService.setString('clinicAddress', clinicAddress);
    StorageService.setString('clinicPhone',   clinicPhone);
    StorageService.setString('clinicEmail',   clinicEmail);
  }

  // CRM CRUD
  void addPatient(Patient p) { patients.insert(0, p); _savePatients(); _notify('Patient registered', '${p.name} • ${p.status.label}', Icons.person_add_alt_1_outlined); notifyListeners(); }
  void deletePatient(Patient p) { patients.remove(p); _savePatients(); notifyListeners(); }

  // Appointment CRUD
  void addAppointment(Appointment a) { appointments.add(a); _saveAppointments(); _notify('Appointment booked', '${a.patientName} • ${a.treatment}', Icons.calendar_month_outlined); notifyListeners(); }
  void setApptStatus(Appointment a, ApptStatus s) { a.status = s; _saveAppointments(); notifyListeners(); }
  void deleteAppointment(Appointment a) { appointments.remove(a); _saveAppointments(); notifyListeners(); }

  // Staff CRUD
  void addStaff(Staff s) { staff.insert(0, s); _saveStaff(); _notify('Staff added', '${s.name} • ${s.role.label}', Icons.badge_outlined); notifyListeners(); }
  void deleteStaff(Staff s) { staff.remove(s); _saveStaff(); notifyListeners(); }

  // POS / Invoice
  void addInvoice(Invoice inv) { invoices.insert(0, inv); _saveInvoices(); _notify('Invoice generated', '${inv.id} • ${money(inv.subtotal)}', Icons.receipt_long_outlined); notifyListeners(); }
  void deleteInvoice(Invoice inv) { invoices.remove(inv); _saveInvoices(); notifyListeners(); }

  // Inventory CRUD
  void addInventory(InventoryItem i) { inventory.insert(0, i); notifyListeners(); }
  void adjustStock(InventoryItem i, int d) { i.stock = (i.stock + d).clamp(0, 999999); notifyListeners(); }
  void deleteInventory(InventoryItem i) { inventory.remove(i); notifyListeners(); }
  void updateInventory(InventoryItem i) { notifyListeners(); }
  void setTreatmentPrice(Treatment t, double price) { t.price = price; notifyListeners(); }

  // ── HR Module ─────────────────────────────────────────────────────────────────
  late final List<AttendanceRecord> attendanceRecords = _seedAttendance();
  late final List<LeaveRequest> leaveRequests = _seedLeaveRequests();
  late final List<LeaveBalance> leaveBalances = _seedLeaveBalances();
  late final List<SalaryStructure> salaryStructures = _seedSalaryStructures();
  final List<PayrollRecord> payrollRecords = [];
  late final List<OvertimeRecord> overtimeRecords = _seedOvertimes();
  late final List<Shift> shifts = _seedShifts();
  late final List<JobPost> jobPosts = _seedJobPosts();

  void setAttendance(String empId, DateTime date, AttendanceStatus status) {
    final existing = attendanceRecords.where((r) => r.employeeId == empId && _sameDay(r.date, date)).toList();
    if (existing.isNotEmpty) {
      existing.first.status = status;
    } else {
      final emp = staff.firstWhere((s) => s.id == empId, orElse: () => staff.first);
      attendanceRecords.add(AttendanceRecord(employeeId: empId, employeeName: emp.name, date: date, status: status));
    }
    notifyListeners();
  }

  void addLeaveRequest(LeaveRequest r) { leaveRequests.insert(0, r); _notify('Leave request', '${r.employeeName} — ${r.type.label} (${r.days} days)', Icons.event_note_outlined); notifyListeners(); }
  void approveLeave(LeaveRequest r, String by) { r.status = LeaveStatus.approved; r.approvedBy = by; notifyListeners(); }
  void rejectLeave(LeaveRequest r, String reason) { r.status = LeaveStatus.rejected; r.rejectionReason = reason; notifyListeners(); }

  void processPayroll(int month, int year) {
    for (final ss in salaryStructures) {
      final presents = attendanceRecords.where((a) => a.employeeId == ss.employeeId && a.date.month == month && a.date.year == year && a.status == AttendanceStatus.present).length;
      final leaves = attendanceRecords.where((a) => a.employeeId == ss.employeeId && a.date.month == month && a.date.year == year && a.status == AttendanceStatus.leave).length;
      final absents = attendanceRecords.where((a) => a.employeeId == ss.employeeId && a.date.month == month && a.date.year == year && a.status == AttendanceStatus.absent).length;
      final ot = overtimeRecords.where((o) => o.employeeId == ss.employeeId && o.date.month == month && o.date.year == year && o.approved).fold(0.0, (s, o) => s + o.amount);
      payrollRecords.add(PayrollRecord(
        id: createPayrollId(),
        employeeId: ss.employeeId, employeeName: ss.employeeName, designation: ss.designation,
        month: month, year: year, workingDays: 26,
        presentDays: presents, leaveDays: leaves, absentDays: absents,
        basicSalary: ss.basicSalary,
        allowances: ss.components.where((c) => c.type == SalaryComponentType.earning).fold(0.0, (s, c) => s + (c.isPercentage ? ss.basicSalary * c.amount / 100 : c.amount)),
        overtime: ot,
        deductions: ss.components.where((c) => c.type == SalaryComponentType.deduction).fold(0.0, (s, c) => s + (c.isPercentage ? ss.basicSalary * c.amount / 100 : c.amount)),
        status: PayrollStatus.processed,
      ));
    }
    notifyListeners();
  }

  void addJobPost(JobPost jp) { jobPosts.insert(0, jp); notifyListeners(); }
  void addApplicant(JobPost jp, JobApplicant a) { jp.applicants.insert(0, a); notifyListeners(); }
  void updateApplicantStatus(JobApplicant a, ApplicantStatus s) { a.status = s; notifyListeners(); }

  // ── Leads Module ──────────────────────────────────────────────────────────────
  late final List<Lead> leads = _loadOrSeed('leads', _seedLeads, Lead.fromJson);

  void addLead(Lead l) {
    leads.insert(0, l);
    _saveLeads();
    _notify('New lead', '${l.name} — ${l.source.label}', Icons.person_add_alt_1_outlined);
    notifyListeners();
  }

  void updateLead(Lead l) { l.updatedAt = DateTime.now(); _saveLeads(); notifyListeners(); }

  void updateLeadStage(Lead l, LeadStage stage) {
    l.stage = stage;
    l.updatedAt = DateTime.now();
    _saveLeads();
    if (stage == LeadStage.converted) _notify('Lead converted!', '${l.name} is now a patient', Icons.celebration_outlined);
    notifyListeners();
  }

  void addCallLog(Lead l, CallLog c) { l.callLogs.insert(0, c); l.updatedAt = DateTime.now(); _saveLeads(); notifyListeners(); }
  void addFollowUp(Lead l, FollowUp f) { l.followUps.insert(0, f); l.updatedAt = DateTime.now(); _saveLeads(); notifyListeners(); }
  void deleteLead(Lead l) { leads.remove(l); _saveLeads(); notifyListeners(); }

  // ── Finance Module ────────────────────────────────────────────────────────────
  late final List<IncomeEntry>  incomeEntries  = _loadOrSeed('income',   _seedIncome,    IncomeEntry.fromJson);
  late final List<ExpenseEntry> expenseEntries = _loadOrSeed('expenses', _seedExpenses,  ExpenseEntry.fromJson);
  late final List<BankAccount> bankAccounts = _seedBankAccounts();
  final List<BankTransaction> bankTransactions = [];
  late final List<CashBookEntry> cashBookEntries = _seedCashBook();
  final List<JournalEntry> journalEntries = [];

  void addIncomeEntry(IncomeEntry e) { incomeEntries.insert(0, e); _saveIncome(); notifyListeners(); }
  void addExpenseEntry(ExpenseEntry e) { expenseEntries.insert(0, e); _saveExpenses(); notifyListeners(); }
  void addJournalEntry(JournalEntry e) { journalEntries.insert(0, e); notifyListeners(); }
  void deleteIncomeEntry(IncomeEntry e) { incomeEntries.remove(e); _saveIncome(); notifyListeners(); }
  void deleteExpenseEntry(ExpenseEntry e) { expenseEntries.remove(e); _saveExpenses(); notifyListeners(); }
  void updateIncomeEntry(IncomeEntry e) { _saveIncome(); notifyListeners(); }
  void updateExpenseEntry(ExpenseEntry e) { _saveExpenses(); notifyListeners(); }

  double get cashBalance => cashBookEntries.isEmpty ? 0 : cashBookEntries.first.runningBalance;
  double get totalBankBalance => bankAccounts.fold(0.0, (s, b) => s + b.currentBalance);

  double get thisMonthIncome {
    final now = DateTime.now();
    return incomeEntries.where((e) => e.date.month == now.month && e.date.year == now.year).fold(0.0, (s, e) => s + e.amount);
  }

  double get thisMonthExpense {
    final now = DateTime.now();
    return expenseEntries.where((e) => e.date.month == now.month && e.date.year == now.year).fold(0.0, (s, e) => s + e.amount);
  }

  // ── Marketing Module ──────────────────────────────────────────────────────────
  late final List<Campaign> campaigns = _seedCampaigns();
  late final List<Coupon> coupons = _seedCoupons();
  late final List<Promotion> promotions = _seedPromotions();

  void addCampaign(Campaign c) { campaigns.insert(0, c); notifyListeners(); }
  void addCoupon(Coupon c) { coupons.insert(0, c); notifyListeners(); }
  void addPromotion(Promotion p) { promotions.insert(0, p); notifyListeners(); }
  void toggleCoupon(Coupon c) { c.isActive = !c.isActive; notifyListeners(); }
  void togglePromotion(Promotion p) { p.isActive = !p.isActive; notifyListeners(); }
  void deleteCoupon(Coupon c) { coupons.remove(c); notifyListeners(); }
  void deletePromotion(Promotion p) { promotions.remove(p); notifyListeners(); }
  void updateCampaign(Campaign c) { notifyListeners(); }
  void updateCoupon(Coupon c) { notifyListeners(); }
  void updatePromotion(Promotion p) { notifyListeners(); }

  // ── Consultation Module ───────────────────────────────────────────────────────
  late final List<ConsultationRecord> consultationRecords = _seedConsultations();

  void addConsultation(ConsultationRecord r) { consultationRecords.insert(0, r); notifyListeners(); }
  void deleteConsultation(ConsultationRecord r) { consultationRecords.remove(r); notifyListeners(); }
  void updateConsultation(ConsultationRecord r) { notifyListeners(); }

  // ── Derived Metrics (existing) ────────────────────────────────────────────────
  bool _today(DateTime d) { final n = DateTime.now(); return d.year == n.year && d.month == n.month && d.day == n.day; }
  bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  int get totalPatients => patients.length;
  int get todaysAppointments => appointments.where((a) => _today(a.when)).length;
  int get activeLeads => patients.where((p) => p.status == PatientStatus.lead).length;
  double get invoiceRevenue => invoices.fold(0.0, (s, i) => s + i.subtotal);
  double get monthlyRevenue => invoiceRevenue + 2480000;
  int get scheduledProcedures => appointments.where((a) => a.status != ApptStatus.cancelled && a.when.isAfter(DateTime.now().subtract(const Duration(days: 1)))).length;
  int get completedSessions => patients.fold(0, (s, p) => s + p.journey.where((j) => j.done).length);
  int get followUpAlerts => patients.where((p) => p.journey.any((j) => !j.done)).length;
  double get todaysSales => invoices.where((i) => _today(i.date)).fold(0.0, (s, i) => s + i.subtotal);
  double get pendingInstallments => invoices.fold(0.0, (s, i) => s + i.balance);
  int get inventoryCount => inventory.length;
  int get lowStockCount => inventory.where((i) => i.isLow).length;
  int apptCount(ApptStatus s) => appointments.where((a) => a.status == s).length;
  double get grossRevenue => monthlyRevenue;
  double get operationalCost => grossRevenue * 0.38;
  double get netMarginPct => grossRevenue == 0 ? 0 : (grossRevenue - operationalCost) / grossRevenue * 100;

  // HR derived
  int get pendingLeaveCount => leaveRequests.where((r) => r.status == LeaveStatus.pending).length;
  int get presentTodayCount => attendanceRecords.where((r) => _today(r.date) && r.status == AttendanceStatus.present).length;
  double get totalPayrollThisMonth {
    final now = DateTime.now();
    return payrollRecords.where((r) => r.month == now.month && r.year == now.year).fold(0.0, (s, r) => s + r.netSalary);
  }

  // Lead derived
  int get totalLeadsCount => leads.length;
  int get hotLeadsCount => leads.where((l) => l.priority == LeadPriority.hot && l.stage != LeadStage.converted && l.stage != LeadStage.lost).length;
  int get convertedLeadsCount => leads.where((l) => l.stage == LeadStage.converted).length;
  int get todayFollowUpsCount => leads.where((l) => l.followUpDate != null && _today(l.followUpDate!)).length;

  List<({String label, double value, Color color})> distribution(AppPalette p) => [
        (label: 'Hair Transplant', value: 54, color: p.gold),
        (label: 'PRP Therapy', value: 28, color: p.goldBright),
        (label: 'Laser / Other', value: 18, color: p.textMuted),
      ];

  final List<double> weeklyRevenue = [180, 240, 205, 330, 290, 380, 445];
  final List<String> weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  final List<({String month, double revenue, int procedures})> monthlySales = [
    (month: 'January', revenue: 1850000, procedures: 18),
    (month: 'February', revenue: 2120000, procedures: 21),
    (month: 'March', revenue: 1980000, procedures: 19),
    (month: 'April', revenue: 2460000, procedures: 24),
    (month: 'May', revenue: 2310000, procedures: 22),
    (month: 'June', revenue: 2680000, procedures: 27),
  ];

  // ── Seeds (existing) ──────────────────────────────────────────────────────────
  List<Staff> _seedStaff() => [
        Staff(id: 'ST-1', name: 'Dr. Rehman', role: StaffRole.doctor, specialty: 'FUE Transplant Surgeon', phone: '+92 300 1112223', email: 'rehman@hairagain.pk'),
        Staff(id: 'ST-2', name: 'Dr. Sara Iqbal', role: StaffRole.doctor, specialty: 'Trichologist / PRP', phone: '+92 301 4445556', email: 'sara@hairagain.pk'),
        Staff(id: 'ST-3', name: 'Dr. Bilal Khan', role: StaffRole.doctor, specialty: 'Dermatologist', phone: '+92 302 7778889', email: 'bilal@hairagain.pk'),
        Staff(id: 'ST-4', name: 'Hira Saleem', role: StaffRole.nurse, specialty: 'OT Assistant', phone: '+92 333 1234567', email: 'hira@hairagain.pk'),
        Staff(id: 'ST-5', name: 'Ali Raza', role: StaffRole.receptionist, specialty: 'Front Desk', phone: '+92 345 9876543', email: 'ali@hairagain.pk'),
        Staff(id: 'ST-6', name: 'Nadia Aslam', role: StaffRole.manager, specialty: 'Clinic Operations', phone: '+92 311 5556667', email: 'nadia@hairagain.pk'),
      ];

  List<Treatment> _seedTreatments() => [
        Treatment('TX-1', 'FUE Hair Transplant — 1500 Grafts', 250000, 'Transplant'),
        Treatment('TX-2', 'FUE Hair Transplant — 3000 Grafts', 450000, 'Transplant'),
        Treatment('TX-3', 'FUE Hair Transplant — 4500 Grafts', 620000, 'Transplant'),
        Treatment('TX-4', 'PRP Therapy — Single Session', 18000, 'PRP'),
        Treatment('TX-5', 'PRP Therapy — 4 Session Package', 60000, 'PRP'),
        Treatment('TX-6', 'Low-Level Laser Therapy', 22000, 'Laser'),
        Treatment('TX-7', 'Anti-Hairloss Serum (Premium)', 8500, 'Retail'),
        Treatment('TX-8', 'Mesotherapy Session', 15000, 'PRP'),
        Treatment('TX-9', 'Scalp Micropigmentation', 95000, 'Other'),
        Treatment('TX-10', 'Dermatology Consultation', 5000, 'Consult'),
      ];

  List<Patient> _seedPatients() => [
        Patient(id: 'PT-001', name: 'Bilal Ahmed', phone: '+92 300 1234567', email: 'bilal.ahmed@gmail.com', city: 'Karachi', age: 34, gender: 'Male', status: PatientStatus.active, norwood: 4, journey: [
          JourneyStep(title: 'Consultation', detail: 'Norwood IV • 3000 grafts advised', date: '02 Jun', done: true),
          JourneyStep(title: 'Session 1 — FUE', detail: '3000 grafts extracted & implanted', date: '09 Jun', done: true),
          JourneyStep(title: 'PRP — Session 1', detail: 'Post-op recovery support', date: '23 Jun', done: false),
          JourneyStep(title: 'Day-90 Review', detail: 'Growth tracking photos', date: '09 Sep', done: false),
        ]),
        Patient(id: 'PT-002', name: 'Sana Tariq', phone: '+92 321 9988776', email: 'sana.tariq@outlook.com', city: 'Karachi', age: 29, gender: 'Female', status: PatientStatus.lead, norwood: 2, journey: [
          JourneyStep(title: 'Lead Captured', detail: 'Instagram campaign enquiry', date: '18 Jun', done: true),
          JourneyStep(title: 'Consultation', detail: 'Scheduled — diffuse thinning', date: '24 Jun', done: false),
        ]),
        Patient(id: 'PT-003', name: 'Hamza Sheikh', phone: '+92 333 4455667', email: 'hamza.sheikh@gmail.com', city: 'Hyderabad', age: 41, gender: 'Male', status: PatientStatus.completed, norwood: 6, journey: [
          JourneyStep(title: 'Consultation', detail: 'Norwood VI • 4500 grafts plan', date: '04 Mar', done: true),
          JourneyStep(title: 'Session 1 — FUE', detail: '2500 grafts (crown)', date: '11 Mar', done: true),
          JourneyStep(title: 'Session 2 — FUE', detail: '2000 grafts (hairline)', date: '18 Mar', done: true),
          JourneyStep(title: 'PRP — 4 Pack', detail: 'All sessions complete', date: '20 May', done: true),
          JourneyStep(title: 'Day-90 Review', detail: 'Excellent density achieved', date: '16 Jun', done: true),
        ]),
        Patient(id: 'PT-004', name: 'Ayesha Khan', phone: '+92 345 1122334', email: 'ayesha.khan@gmail.com', city: 'Karachi', age: 37, gender: 'Female', status: PatientStatus.active, norwood: 3, journey: [
          JourneyStep(title: 'Consultation', detail: 'PRP + Mesotherapy plan', date: '30 May', done: true),
          JourneyStep(title: 'PRP — Session 1', detail: 'Completed', date: '06 Jun', done: true),
          JourneyStep(title: 'PRP — Session 2', detail: 'Upcoming', date: '27 Jun', done: false),
        ]),
        Patient(id: 'PT-005', name: 'Usman Malik', phone: '+92 301 7766554', email: 'usman.malik@yahoo.com', city: 'Lahore', age: 45, gender: 'Male', status: PatientStatus.lead, norwood: 5, journey: [
          JourneyStep(title: 'Lead Captured', detail: 'Referral — friend of patient', date: '19 Jun', done: true),
        ]),
        Patient(id: 'PT-006', name: 'Fatima Noor', phone: '+92 312 6655443', email: 'fatima.noor@gmail.com', city: 'Karachi', age: 31, gender: 'Female', status: PatientStatus.active, norwood: 2, journey: [
          JourneyStep(title: 'Consultation', detail: 'Laser therapy course', date: '12 Jun', done: true),
          JourneyStep(title: 'Laser — Session 1', detail: 'Completed', date: '19 Jun', done: true),
          JourneyStep(title: 'Laser — Session 2', detail: 'Scheduled', date: '26 Jun', done: false),
        ]),
      ];

  List<InventoryItem> _seedInventory() => [
        InventoryItem(id: 'SKU-101', name: 'PRP Centrifuge Kits', category: 'Consumables', stock: 6, reorderLevel: 10, price: 4500),
        InventoryItem(id: 'SKU-102', name: 'FUE Punch Tips (0.8mm)', category: 'Surgical', stock: 42, reorderLevel: 20, price: 1200),
        InventoryItem(id: 'SKU-103', name: 'Anti-Hairloss Serum', category: 'Retail', stock: 3, reorderLevel: 8, price: 8500),
        InventoryItem(id: 'SKU-104', name: 'Local Anaesthetic Vials', category: 'Pharmacy', stock: 75, reorderLevel: 30, price: 650),
        InventoryItem(id: 'SKU-105', name: 'Sterile Graft Trays', category: 'Surgical', stock: 18, reorderLevel: 15, price: 900),
        InventoryItem(id: 'SKU-106', name: 'Mesotherapy Ampoules', category: 'Consumables', stock: 9, reorderLevel: 12, price: 2200),
        InventoryItem(id: 'SKU-107', name: 'Post-Op Care Packs', category: 'Retail', stock: 24, reorderLevel: 10, price: 3500),
      ];

  List<Appointment> _seedAppointments() {
    final now = DateTime.now();
    DateTime at(int d, int h, int m) => DateTime(now.year, now.month, now.day, h, m).add(Duration(days: d));
    return [
      Appointment(id: 'AP-001', patientName: 'Bilal Ahmed', treatment: 'PRP Therapy — Single Session', surgeon: 'Dr. Rehman', when: at(0, 10, 30), status: ApptStatus.confirmed),
      Appointment(id: 'AP-002', patientName: 'Ayesha Khan', treatment: 'PRP Therapy — Single Session', surgeon: 'Dr. Sara Iqbal', when: at(0, 12, 0), status: ApptStatus.confirmed),
      Appointment(id: 'AP-003', patientName: 'Sana Tariq', treatment: 'Dermatology Consultation', surgeon: 'Dr. Rehman', when: at(0, 15, 30), status: ApptStatus.pending),
      Appointment(id: 'AP-004', patientName: 'Fatima Noor', treatment: 'Low-Level Laser Therapy', surgeon: 'Dr. Bilal Khan', when: at(0, 17, 0), status: ApptStatus.pending),
      Appointment(id: 'AP-005', patientName: 'Usman Malik', treatment: 'Dermatology Consultation', surgeon: 'Dr. Sara Iqbal', when: at(2, 11, 0), status: ApptStatus.cancelled),
      Appointment(id: 'AP-006', patientName: 'Hamza Sheikh', treatment: 'FUE Hair Transplant — 3000 Grafts', surgeon: 'Dr. Rehman', when: at(1, 9, 0), status: ApptStatus.confirmed),
    ];
  }

  // ── HR Seeds ──────────────────────────────────────────────────────────────────
  List<AttendanceRecord> _seedAttendance() {
    final records = <AttendanceRecord>[];
    final now = DateTime.now();
    final empIds = ['ST-1', 'ST-2', 'ST-3', 'ST-4', 'ST-5', 'ST-6'];
    final empNames = ['Dr. Rehman', 'Dr. Sara Iqbal', 'Dr. Bilal Khan', 'Hira Saleem', 'Ali Raza', 'Nadia Aslam'];
    final statuses = [AttendanceStatus.present, AttendanceStatus.present, AttendanceStatus.present, AttendanceStatus.absent, AttendanceStatus.late];
    for (int d = 1; d < now.day; d++) {
      final date = DateTime(now.year, now.month, d);
      if (date.weekday == DateTime.friday) continue;
      for (int i = 0; i < empIds.length; i++) {
        final s = statuses[(i + d) % statuses.length];
        records.add(AttendanceRecord(
          employeeId: empIds[i], employeeName: empNames[i], date: date,
          status: s, checkIn: s == AttendanceStatus.present ? '09:00' : (s == AttendanceStatus.late ? '10:15' : null),
          checkOut: (s == AttendanceStatus.present || s == AttendanceStatus.late) ? '18:00' : null,
        ));
      }
    }
    return records;
  }

  List<LeaveRequest> _seedLeaveRequests() => [
        LeaveRequest(id: 'LR-001', employeeId: 'ST-4', employeeName: 'Hira Saleem', department: 'Medical', type: LeaveType.sick, fromDate: DateTime.now().add(const Duration(days: 1)), toDate: DateTime.now().add(const Duration(days: 2)), reason: 'Fever and throat infection', status: LeaveStatus.pending, appliedAt: DateTime.now().subtract(const Duration(hours: 3))),
        LeaveRequest(id: 'LR-002', employeeId: 'ST-5', employeeName: 'Ali Raza', department: 'Front Desk', type: LeaveType.casual, fromDate: DateTime.now().add(const Duration(days: 5)), toDate: DateTime.now().add(const Duration(days: 5)), reason: 'Family function', status: LeaveStatus.approved, approvedBy: 'Nadia Aslam', appliedAt: DateTime.now().subtract(const Duration(days: 2))),
        LeaveRequest(id: 'LR-003', employeeId: 'ST-2', employeeName: 'Dr. Sara Iqbal', department: 'Medical', type: LeaveType.annual, fromDate: DateTime.now().add(const Duration(days: 10)), toDate: DateTime.now().add(const Duration(days: 14)), reason: 'Annual family vacation', status: LeaveStatus.pending, appliedAt: DateTime.now().subtract(const Duration(days: 1))),
        LeaveRequest(id: 'LR-004', employeeId: 'ST-6', employeeName: 'Nadia Aslam', department: 'Operations', type: LeaveType.casual, fromDate: DateTime.now().subtract(const Duration(days: 5)), toDate: DateTime.now().subtract(const Duration(days: 5)), reason: 'Medical appointment', status: LeaveStatus.approved, approvedBy: 'Ahmad Raza', appliedAt: DateTime.now().subtract(const Duration(days: 6))),
      ];

  List<LeaveBalance> _seedLeaveBalances() => [
        LeaveBalance(employeeId: 'ST-1', annual: 15, annualUsed: 2, sick: 10, sickUsed: 0, casual: 7, casualUsed: 1),
        LeaveBalance(employeeId: 'ST-2', annual: 15, annualUsed: 4, sick: 10, sickUsed: 1, casual: 7, casualUsed: 0),
        LeaveBalance(employeeId: 'ST-3', annual: 15, annualUsed: 1, sick: 10, sickUsed: 3, casual: 7, casualUsed: 2),
        LeaveBalance(employeeId: 'ST-4', annual: 15, annualUsed: 0, sick: 10, sickUsed: 2, casual: 7, casualUsed: 0),
        LeaveBalance(employeeId: 'ST-5', annual: 15, annualUsed: 3, sick: 10, sickUsed: 0, casual: 7, casualUsed: 1),
        LeaveBalance(employeeId: 'ST-6', annual: 15, annualUsed: 1, sick: 10, sickUsed: 0, casual: 7, casualUsed: 1),
      ];

  List<SalaryStructure> _seedSalaryStructures() => [
        SalaryStructure(employeeId: 'ST-1', employeeName: 'Dr. Rehman', designation: 'Lead Surgeon', basicSalary: 300000, components: [
          SalaryComponent(name: 'House Rent', type: SalaryComponentType.earning, amount: 40, isPercentage: true),
          SalaryComponent(name: 'Medical Allowance', type: SalaryComponentType.earning, amount: 15000),
          SalaryComponent(name: 'Transport', type: SalaryComponentType.earning, amount: 8000),
          SalaryComponent(name: 'EOBI', type: SalaryComponentType.deduction, amount: 1680),
          SalaryComponent(name: 'Income Tax', type: SalaryComponentType.deduction, amount: 18000),
        ]),
        SalaryStructure(employeeId: 'ST-2', employeeName: 'Dr. Sara Iqbal', designation: 'Trichologist', basicSalary: 220000, components: [
          SalaryComponent(name: 'House Rent', type: SalaryComponentType.earning, amount: 40, isPercentage: true),
          SalaryComponent(name: 'Medical Allowance', type: SalaryComponentType.earning, amount: 12000),
          SalaryComponent(name: 'Transport', type: SalaryComponentType.earning, amount: 6000),
          SalaryComponent(name: 'EOBI', type: SalaryComponentType.deduction, amount: 1680),
          SalaryComponent(name: 'Income Tax', type: SalaryComponentType.deduction, amount: 9000),
        ]),
        SalaryStructure(employeeId: 'ST-3', employeeName: 'Dr. Bilal Khan', designation: 'Dermatologist', basicSalary: 200000, components: [
          SalaryComponent(name: 'House Rent', type: SalaryComponentType.earning, amount: 40, isPercentage: true),
          SalaryComponent(name: 'Medical Allowance', type: SalaryComponentType.earning, amount: 10000),
          SalaryComponent(name: 'Transport', type: SalaryComponentType.earning, amount: 5000),
          SalaryComponent(name: 'EOBI', type: SalaryComponentType.deduction, amount: 1680),
          SalaryComponent(name: 'Income Tax', type: SalaryComponentType.deduction, amount: 7000),
        ]),
        SalaryStructure(employeeId: 'ST-4', employeeName: 'Hira Saleem', designation: 'OT Nurse', basicSalary: 65000, components: [
          SalaryComponent(name: 'House Rent', type: SalaryComponentType.earning, amount: 40, isPercentage: true),
          SalaryComponent(name: 'Medical Allowance', type: SalaryComponentType.earning, amount: 3000),
          SalaryComponent(name: 'EOBI', type: SalaryComponentType.deduction, amount: 1680),
        ]),
        SalaryStructure(employeeId: 'ST-5', employeeName: 'Ali Raza', designation: 'Receptionist', basicSalary: 45000, components: [
          SalaryComponent(name: 'House Rent', type: SalaryComponentType.earning, amount: 40, isPercentage: true),
          SalaryComponent(name: 'Transport', type: SalaryComponentType.earning, amount: 2500),
          SalaryComponent(name: 'EOBI', type: SalaryComponentType.deduction, amount: 1680),
        ]),
        SalaryStructure(employeeId: 'ST-6', employeeName: 'Nadia Aslam', designation: 'Clinic Manager', basicSalary: 120000, components: [
          SalaryComponent(name: 'House Rent', type: SalaryComponentType.earning, amount: 40, isPercentage: true),
          SalaryComponent(name: 'Medical Allowance', type: SalaryComponentType.earning, amount: 8000),
          SalaryComponent(name: 'Transport', type: SalaryComponentType.earning, amount: 5000),
          SalaryComponent(name: 'EOBI', type: SalaryComponentType.deduction, amount: 1680),
          SalaryComponent(name: 'Income Tax', type: SalaryComponentType.deduction, amount: 3000),
        ]),
      ];

  List<OvertimeRecord> _seedOvertimes() {
    final now = DateTime.now();
    return [
      OvertimeRecord(id: 'OT-001', employeeId: 'ST-1', employeeName: 'Dr. Rehman', date: DateTime(now.year, now.month, 10), hours: 3, ratePerHour: 2500, approved: true, approvedBy: 'Nadia Aslam'),
      OvertimeRecord(id: 'OT-002', employeeId: 'ST-4', employeeName: 'Hira Saleem', date: DateTime(now.year, now.month, 12), hours: 2, ratePerHour: 800, approved: true, approvedBy: 'Nadia Aslam'),
      OvertimeRecord(id: 'OT-003', employeeId: 'ST-5', employeeName: 'Ali Raza', date: DateTime(now.year, now.month, 15), hours: 1.5, ratePerHour: 600, approved: false),
    ];
  }

  List<Shift> _seedShifts() => [
        Shift(id: 'SH-1', name: 'Morning Shift', startTime: '08:00', endTime: '14:00', workDays: ['Mon', 'Tue', 'Wed', 'Thu', 'Sat'], assignedEmployeeIds: ['ST-5']),
        Shift(id: 'SH-2', name: 'Standard Shift', startTime: '09:00', endTime: '18:00', workDays: ['Mon', 'Tue', 'Wed', 'Thu', 'Sat'], assignedEmployeeIds: ['ST-1', 'ST-2', 'ST-3', 'ST-4', 'ST-6']),
        Shift(id: 'SH-3', name: 'Evening Shift', startTime: '14:00', endTime: '21:00', workDays: ['Mon', 'Tue', 'Wed', 'Thu', 'Sat'], assignedEmployeeIds: []),
      ];

  List<JobPost> _seedJobPosts() => [
        JobPost(
          id: 'JP-001', title: 'Registered Nurse (OT)', department: 'Medical',
          type: 'Full-time', openings: 2, isActive: true,
          description: 'We are looking for experienced registered nurses to join our operating theatre team for hair transplant procedures.',
          requirements: 'RN qualification required. Minimum 2 years OT experience. Knowledge of surgical procedures preferred.',
          salaryRange: 'PKR 60,000 – 80,000', location: 'Clifton, Karachi',
          postedOn: DateTime.now().subtract(const Duration(days: 10)),
          closingDate: DateTime.now().add(const Duration(days: 20)),
          applicants: [
            JobApplicant(id: 'JA-001', name: 'Sadia Hussain', email: 'sadia@gmail.com', phone: '+92 333 1111222', position: 'Registered Nurse (OT)', experience: '3 years', expectedSalary: 'PKR 70,000', currentCompany: 'Aga Khan Hospital', status: ApplicantStatus.shortlisted, appliedOn: DateTime.now().subtract(const Duration(days: 7)), interviews: [InterviewSchedule(scheduledAt: DateTime.now().add(const Duration(days: 2)), interviewer: 'Dr. Rehman', status: 'scheduled')]),
            JobApplicant(id: 'JA-002', name: 'Rabia Malik', email: 'rabia.m@gmail.com', phone: '+92 345 2223334', position: 'Registered Nurse (OT)', experience: '1.5 years', expectedSalary: 'PKR 62,000', status: ApplicantStatus.received, appliedOn: DateTime.now().subtract(const Duration(days: 3)), interviews: []),
          ],
        ),
        JobPost(
          id: 'JP-002', title: 'Front Desk Coordinator', department: 'Operations',
          type: 'Full-time', openings: 1, isActive: true,
          description: 'Looking for a professional and presentable individual for front desk operations.',
          requirements: 'Minimum graduation. Fluent in Urdu & English. Computer skills required. Previous clinic experience preferred.',
          salaryRange: 'PKR 40,000 – 55,000', location: 'Clifton, Karachi',
          postedOn: DateTime.now().subtract(const Duration(days: 5)),
          applicants: [],
        ),
      ];

  // ── Lead Seeds ────────────────────────────────────────────────────────────────
  List<Lead> _seedLeads() => [
        Lead(id: 'LD-001', name: 'Waqas Ahmed', phone: '+92 300 5566778', email: 'waqas.a@gmail.com', city: 'Karachi', age: 32, gender: 'Male', source: LeadSource.instagram, serviceInterest: 'FUE Hair Transplant', budgetRange: 'PKR 300,000 – 500,000', priority: LeadPriority.hot, stage: LeadStage.consultationBooked, assignedTo: 'Ali Raza', followUpDate: DateTime.now().add(const Duration(days: 1)), createdAt: DateTime.now().subtract(const Duration(days: 5)), updatedAt: DateTime.now().subtract(const Duration(days: 1)), callLogs: [CallLog(id: 'CL-001', leadId: 'LD-001', dateTime: DateTime.now().subtract(const Duration(days: 3)), type: CallType.outbound, status: CallStatus.answered, durationSeconds: 420, calledBy: 'Ali Raza', notes: 'Patient interested. Consultation booked for 2nd July.')], followUps: [FollowUp(id: 'FU-001', leadId: 'LD-001', scheduledAt: DateTime.now().add(const Duration(days: 1)), type: 'Call', notes: 'Confirm consultation appointment', completed: false)]),
        Lead(id: 'LD-002', name: 'Mehwish Siddiqui', phone: '+92 321 6677889', email: 'mehwish.s@yahoo.com', city: 'Karachi', age: 27, gender: 'Female', source: LeadSource.facebook, serviceInterest: 'PRP Therapy', budgetRange: 'PKR 50,000 – 80,000', priority: LeadPriority.warm, stage: LeadStage.contacted, assignedTo: 'Sara Ahmed', followUpDate: DateTime.now().add(const Duration(days: 3)), createdAt: DateTime.now().subtract(const Duration(days: 8)), updatedAt: DateTime.now().subtract(const Duration(days: 2)), callLogs: [CallLog(id: 'CL-002', leadId: 'LD-002', dateTime: DateTime.now().subtract(const Duration(days: 6)), type: CallType.outbound, status: CallStatus.answered, durationSeconds: 180, calledBy: 'Sara Ahmed', notes: 'Sent treatment brochure on WhatsApp.')], followUps: []),
        Lead(id: 'LD-003', name: 'Kamran Hussain', phone: '+92 333 7788990', city: 'Lahore', age: 38, gender: 'Male', source: LeadSource.referral, serviceInterest: 'FUE Hair Transplant', budgetRange: 'PKR 400,000 – 600,000', priority: LeadPriority.hot, stage: LeadStage.proposalSent, assignedTo: 'Ali Raza', followUpDate: DateTime.now(), createdAt: DateTime.now().subtract(const Duration(days: 12)), updatedAt: DateTime.now().subtract(const Duration(days: 1)), callLogs: [CallLog(id: 'CL-003', leadId: 'LD-003', dateTime: DateTime.now().subtract(const Duration(days: 10)), type: CallType.inbound, status: CallStatus.answered, durationSeconds: 600, calledBy: 'Ali Raza', notes: 'Referred by Hamza Sheikh. Very interested. Wants 4500 graft procedure.')], followUps: [FollowUp(id: 'FU-002', leadId: 'LD-003', scheduledAt: DateTime.now(), type: 'WhatsApp', notes: 'Share final proposal and pricing', completed: false)]),
        Lead(id: 'LD-004', name: 'Amna Farooq', phone: '+92 345 8899001', email: 'amna.f@gmail.com', city: 'Karachi', age: 34, gender: 'Female', source: LeadSource.google, serviceInterest: 'Scalp Micropigmentation', budgetRange: 'PKR 80,000 – 120,000', priority: LeadPriority.warm, stage: LeadStage.newLead, assignedTo: 'Sara Ahmed', createdAt: DateTime.now().subtract(const Duration(days: 1)), updatedAt: DateTime.now().subtract(const Duration(days: 1)), callLogs: [], followUps: []),
        Lead(id: 'LD-005', name: 'Shahid Qureshi', phone: '+92 301 9900112', city: 'Karachi', age: 50, gender: 'Male', source: LeadSource.walkIn, serviceInterest: 'Dermatology Consultation', budgetRange: 'PKR 5,000 – 20,000', priority: LeadPriority.cold, stage: LeadStage.contacted, assignedTo: 'Ali Raza', createdAt: DateTime.now().subtract(const Duration(days: 15)), updatedAt: DateTime.now().subtract(const Duration(days: 10)), callLogs: [CallLog(id: 'CL-004', leadId: 'LD-005', dateTime: DateTime.now().subtract(const Duration(days: 12)), type: CallType.outbound, status: CallStatus.missed, durationSeconds: 0, calledBy: 'Ali Raza')], followUps: []),
        Lead(id: 'LD-006', name: 'Zainab Mirza', phone: '+92 312 1122334', email: 'zainab.m@gmail.com', city: 'Karachi', age: 25, gender: 'Female', source: LeadSource.instagram, serviceInterest: 'PRP Therapy', budgetRange: 'PKR 60,000 – 80,000', priority: LeadPriority.hot, stage: LeadStage.converted, assignedTo: 'Sara Ahmed', createdAt: DateTime.now().subtract(const Duration(days: 20)), updatedAt: DateTime.now().subtract(const Duration(days: 5)), callLogs: [], followUps: []),
        Lead(id: 'LD-007', name: 'Asad Nawaz', phone: '+92 300 2233445', city: 'Islamabad', age: 42, gender: 'Male', source: LeadSource.youtube, serviceInterest: 'FUE Hair Transplant', budgetRange: 'PKR 250,000 – 350,000', priority: LeadPriority.warm, stage: LeadStage.negotiation, assignedTo: 'Ali Raza', followUpDate: DateTime.now().add(const Duration(days: 2)), createdAt: DateTime.now().subtract(const Duration(days: 18)), updatedAt: DateTime.now().subtract(const Duration(days: 3)), callLogs: [], followUps: []),
        Lead(id: 'LD-008', name: 'Nazia Baig', phone: '+92 321 3344556', city: 'Karachi', age: 30, gender: 'Female', source: LeadSource.tiktok, serviceInterest: 'Mesotherapy', budgetRange: 'Under PKR 30,000', priority: LeadPriority.cold, stage: LeadStage.lost, assignedTo: 'Sara Ahmed', lostReason: 'Budget constraint — redirected to a cheaper clinic', createdAt: DateTime.now().subtract(const Duration(days: 25)), updatedAt: DateTime.now().subtract(const Duration(days: 7)), callLogs: [], followUps: []),
      ];

  // ── Finance Seeds ─────────────────────────────────────────────────────────────
  List<IncomeEntry> _seedIncome() {
    final now = DateTime.now();
    return [
      IncomeEntry(id: 'INC-001', date: DateTime(now.year, now.month, 5), category: IncomeCategory.treatmentRevenue, amount: 450000, paymentMethod: PaymentMethod.bankTransfer, receivedFrom: 'Hamza Sheikh', description: 'FUE Transplant — 3000 Grafts', isVerified: true),
      IncomeEntry(id: 'INC-002', date: DateTime(now.year, now.month, 8), category: IncomeCategory.treatmentRevenue, amount: 18000, paymentMethod: PaymentMethod.cash, receivedFrom: 'Bilal Ahmed', description: 'PRP Therapy Session 1'),
      IncomeEntry(id: 'INC-003', date: DateTime(now.year, now.month, 10), category: IncomeCategory.productSales, amount: 42500, paymentMethod: PaymentMethod.card, receivedFrom: 'Walk-in Customer', description: 'Serum + Care Pack'),
      IncomeEntry(id: 'INC-004', date: DateTime(now.year, now.month, 12), category: IncomeCategory.membership, amount: 120000, paymentMethod: PaymentMethod.bankTransfer, receivedFrom: 'Ayesha Khan', description: 'Gold Membership — 1 Year'),
      IncomeEntry(id: 'INC-005', date: DateTime(now.year, now.month, 15), category: IncomeCategory.treatmentRevenue, amount: 22000, paymentMethod: PaymentMethod.card, receivedFrom: 'Fatima Noor', description: 'Low-Level Laser — 2 Sessions'),
      IncomeEntry(id: 'INC-006', date: DateTime(now.year, now.month, 18), category: IncomeCategory.consultationFee, amount: 15000, paymentMethod: PaymentMethod.cash, receivedFrom: 'Walk-in', description: 'Dermatology Consultation'),
      IncomeEntry(id: 'INC-007', date: DateTime(now.year, now.month, 20), category: IncomeCategory.treatmentRevenue, amount: 620000, paymentMethod: PaymentMethod.bankTransfer, receivedFrom: 'Usman Malik', description: 'FUE Transplant — 4500 Grafts', isVerified: true),
      IncomeEntry(id: 'INC-008', date: DateTime(now.year, now.month, 22), category: IncomeCategory.treatmentRevenue, amount: 60000, paymentMethod: PaymentMethod.card, receivedFrom: 'Waqas Ahmed', description: 'PRP Therapy — 4 Pack'),
    ];
  }

  List<ExpenseEntry> _seedExpenses() {
    final now = DateTime.now();
    return [
      ExpenseEntry(id: 'EXP-001', date: DateTime(now.year, now.month, 1), category: ExpenseCategory.rent, amount: 180000, paymentMethod: PaymentMethod.cheque, vendor: 'Property Owner', description: 'Monthly Clinic Rent — Clifton', isApproved: true, approvedBy: 'Tariq Mahmood'),
      ExpenseEntry(id: 'EXP-002', date: DateTime(now.year, now.month, 3), category: ExpenseCategory.supplies, amount: 85000, paymentMethod: PaymentMethod.bankTransfer, vendor: 'MedStar Supplies', invoiceNo: 'MS-4521', description: 'PRP Kits + Surgical Supplies', isApproved: true, approvedBy: 'Nadia Aslam'),
      ExpenseEntry(id: 'EXP-003', date: DateTime(now.year, now.month, 7), category: ExpenseCategory.utilities, amount: 45000, paymentMethod: PaymentMethod.online, vendor: 'KESC / Sui Gas', description: 'Electricity + Gas Bill', isApproved: true, approvedBy: 'Kamran Ali'),
      ExpenseEntry(id: 'EXP-004', date: DateTime(now.year, now.month, 10), category: ExpenseCategory.marketing, amount: 120000, paymentMethod: PaymentMethod.bankTransfer, vendor: 'Digital Agency Karachi', invoiceNo: 'DA-892', description: 'Social Media Campaigns — June', isApproved: true, approvedBy: 'Tariq Mahmood'),
      ExpenseEntry(id: 'EXP-005', date: DateTime(now.year, now.month, 15), category: ExpenseCategory.maintenance, amount: 28000, paymentMethod: PaymentMethod.cash, vendor: 'TechServ', description: 'AC Maintenance + Equipment Calibration', isApproved: false),
      ExpenseEntry(id: 'EXP-006', date: DateTime(now.year, now.month, 20), category: ExpenseCategory.computerIT, amount: 35000, paymentMethod: PaymentMethod.card, vendor: 'Software House', description: 'Annual Software License', isApproved: true, approvedBy: 'Nadia Aslam'),
    ];
  }

  List<BankAccount> _seedBankAccounts() => [
        BankAccount(id: 'BA-001', bankName: 'HBL', accountTitle: 'Hair Again Clinic (Pvt)', accountNumber: '0001234567890', branchName: 'Clifton Branch, Karachi', iban: 'PK12HABB0001234567890000', openingBalance: 1500000, currentBalance: 2840000, isPrimary: true),
        BankAccount(id: 'BA-002', bankName: 'Meezan Bank', accountTitle: 'Hair Again Clinic — Savings', accountNumber: '5566778899001', branchName: 'DHA Phase 2, Karachi', iban: 'PK36MEZN0005566778899001', openingBalance: 500000, currentBalance: 780000),
      ];

  List<CashBookEntry> _seedCashBook() {
    final now = DateTime.now();
    final entries = <CashBookEntry>[];
    double balance = 125000;
    final transactions = [
      (type: 'receipt', amount: 18000.0, desc: 'PRP Session — Bilal Ahmed', party: 'Bilal Ahmed', day: 1),
      (type: 'payment', amount: 4500.0, desc: 'Office Supplies', party: 'Stationery Shop', day: 2),
      (type: 'receipt', amount: 42500.0, desc: 'Product Sales', party: 'Walk-in', day: 3),
      (type: 'payment', amount: 28000.0, desc: 'Maintenance Work', party: 'TechServ', day: 5),
      (type: 'receipt', amount: 15000.0, desc: 'Consultation Fee', party: 'Walk-in', day: 7),
      (type: 'payment', amount: 12000.0, desc: 'Petty Cash — Staff Meal', party: 'Internal', day: 8),
      (type: 'receipt', amount: 60000.0, desc: 'PRP Package — Waqas Ahmed', party: 'Waqas Ahmed', day: 10),
    ];
    for (final t in transactions) {
      if (t.day >= now.day) continue;
      if (t.type == 'receipt') {
        balance += t.amount;
      } else {
        balance -= t.amount;
      }
      entries.add(CashBookEntry(id: 'CB-${entries.length + 1}', date: DateTime(now.year, now.month, t.day), type: t.type, amount: t.amount, description: t.desc, party: t.party, runningBalance: balance));
    }
    return entries.reversed.toList();
  }

  // ── Marketing Seeds ───────────────────────────────────────────────────────────
  List<Campaign> _seedCampaigns() => [
        Campaign(id: 'CAM-001', name: 'Eid Mubarak — Special Offer', type: CampaignType.whatsapp, status: CampaignStatus.completed, target: CampaignTarget.allPatients, message: 'Eid Mubarak from Hair Again! Enjoy 20% off on all PRP sessions this Eid. Book now: +92 21 111 444 555', sentCount: 847, deliveredCount: 812, readCount: 634, responseCount: 58, scheduledAt: DateTime.now().subtract(const Duration(days: 16)), createdAt: DateTime.now().subtract(const Duration(days: 16)), budget: 8500),
        Campaign(id: 'CAM-002', name: 'Instagram Leads — FUE June', type: CampaignType.sms, status: CampaignStatus.active, target: CampaignTarget.hotLeads, message: 'Hi, Hair Again Clinic invites you for a FREE hair transplant consultation. Call: +92 21 111 444 555. Visit: hairagain.pk', sentCount: 220, deliveredCount: 215, readCount: 0, responseCount: 28, createdAt: DateTime.now().subtract(const Duration(days: 5)), budget: 15000),
        Campaign(id: 'CAM-003', name: 'Dormant Patient Re-engagement', type: CampaignType.email, status: CampaignStatus.scheduled, target: CampaignTarget.dormantCustomers, message: 'Dear Valued Patient,\n\nWe miss you at Hair Again! It\'s been a while since your last visit. Book a complimentary consultation today.\n\nHair Again Clinic Team', sentCount: 0, deliveredCount: 0, readCount: 0, responseCount: 0, scheduledAt: DateTime.now().add(const Duration(days: 3)), createdAt: DateTime.now().subtract(const Duration(days: 1)), budget: 0),
      ];

  List<Coupon> _seedCoupons() => [
        Coupon(id: 'CPN-001', code: 'HAIREID25', description: 'Eid Special — 25% off on Transplant', discountType: DiscountType.percentage, discountValue: 25, minimumOrderAmount: 200000, expiryDate: DateTime.now().add(const Duration(days: 10)), usageLimit: 30, usageCount: 12, isActive: true),
        Coupon(id: 'CPN-002', code: 'PRP4FREE', description: 'Get 4th PRP session free', discountType: DiscountType.percentage, discountValue: 100, minimumOrderAmount: 54000, expiryDate: DateTime.now().add(const Duration(days: 30)), usageLimit: 50, usageCount: 23, isActive: true),
        Coupon(id: 'CPN-003', code: 'NEWCUSTOMER5K', description: 'New customer PKR 5,000 off', discountType: DiscountType.fixed, discountValue: 5000, minimumOrderAmount: 20000, expiryDate: DateTime.now().add(const Duration(days: 60)), usageLimit: 100, usageCount: 8, isActive: true),
        Coupon(id: 'CPN-004', code: 'SUMMER20', description: 'Summer sale 20% discount', discountType: DiscountType.percentage, discountValue: 20, expiryDate: DateTime.now().subtract(const Duration(days: 5)), usageLimit: 200, usageCount: 45, isActive: false),
      ];

  List<Promotion> _seedPromotions() => [
        Promotion(id: 'PR-001', name: 'FUE + PRP Bundle Deal', description: 'Get a FREE PRP session with every FUE Hair Transplant booked this month', discountType: DiscountType.fixed, discountValue: 18000, applicableServices: ['FUE Hair Transplant — 1500 Grafts', 'FUE Hair Transplant — 3000 Grafts', 'FUE Hair Transplant — 4500 Grafts'], startDate: DateTime.now(), endDate: DateTime.now().add(const Duration(days: 30)), isActive: true, createdBy: 'Sara Ahmed', createdAt: DateTime.now().subtract(const Duration(days: 5))),
        Promotion(id: 'PR-002', name: 'PRP Package Discount', description: '15% off on PRP 4-Session Package', discountType: DiscountType.percentage, discountValue: 15, applicableServices: ['PRP Therapy — 4 Session Package'], startDate: DateTime.now(), endDate: DateTime.now().add(const Duration(days: 45)), isActive: true, createdBy: 'Sara Ahmed', createdAt: DateTime.now().subtract(const Duration(days: 15))),
      ];

  // ── Company Module ────────────────────────────────────────────────────────────
  late final List<Branch> branches = _seedBranches();
  late final List<Department> departments = _seedDepartments();
  late final List<Designation> designations = _seedDesignations();
  late final List<WorkingDay> workingDays = _seedWorkingDays();
  late final List<Holiday> holidays = _seedHolidays();

  void addBranch(Branch b) { branches.add(b); notifyListeners(); }
  void deleteBranch(Branch b) { branches.remove(b); notifyListeners(); }
  void addDepartment(Department d) { departments.add(d); notifyListeners(); }
  void deleteDepartment(Department d) { departments.remove(d); notifyListeners(); }
  void addDesignation(Designation d) { designations.add(d); notifyListeners(); }
  void deleteDesignation(Designation d) { designations.remove(d); notifyListeners(); }
  void addHoliday(Holiday h) { holidays.add(h); notifyListeners(); }
  void deleteHoliday(Holiday h) { holidays.remove(h); notifyListeners(); }

  // ── Treatment Module ──────────────────────────────────────────────────────────
  late final List<TreatmentPlan> treatmentPlans = _seedTreatmentPlans();

  void addTreatmentPlan(TreatmentPlan p) { treatmentPlans.insert(0, p); notifyListeners(); }
  void deleteTreatmentPlan(TreatmentPlan p) { treatmentPlans.remove(p); notifyListeners(); }

  // ── Transplant Module ─────────────────────────────────────────────────────────
  late final List<TransplantCase> transplantCases = _seedTransplantCases();

  void addTransplantCase(TransplantCase c) { transplantCases.insert(0, c); _notify('Surgery case created', '${c.patientName} — ${c.technique.label}', Icons.content_cut_outlined); notifyListeners(); }
  void deleteTransplantCase(TransplantCase c) { transplantCases.remove(c); notifyListeners(); }

  // ── Membership Module ─────────────────────────────────────────────────────────
  late final List<MembershipPlan> membershipPlans = _seedMembershipPlans();
  late final List<CustomerMembership> customerMemberships = _seedCustomerMemberships();

  void addMembershipPlan(MembershipPlan p) { membershipPlans.add(p); notifyListeners(); }
  void addCustomerMembership(CustomerMembership m) { customerMemberships.insert(0, m); _notify('Membership enrolled', '${m.customerName} — ${m.planName}', Icons.card_membership_outlined); notifyListeners(); }

  // ── Loyalty Module ────────────────────────────────────────────────────────────
  late final List<LoyaltyAccount> loyaltyAccounts = _seedLoyaltyAccounts();
  late final List<Reward> rewards = _seedRewards();
  late final List<Referral> referrals = _seedReferrals();

  void addReward(Reward r) { rewards.add(r); notifyListeners(); }
  void addReferral(Referral r) { referrals.insert(0, r); notifyListeners(); }

  // ── Vendors Module ────────────────────────────────────────────────────────────
  late final List<Vendor> vendors = _seedVendors();
  late final List<PurchaseOrder> purchaseOrders = _seedPurchaseOrders();
  late final List<GoodsReceiving> goodsReceivings = _seedGoodsReceivings();

  void addVendor(Vendor v) { vendors.insert(0, v); notifyListeners(); }
  void addPurchaseOrder(PurchaseOrder po) { purchaseOrders.insert(0, po); _notify('Purchase Order created', 'PO #${po.id} — ${po.vendorName}', Icons.receipt_long_outlined); notifyListeners(); }
  void addGoodsReceiving(GoodsReceiving gr) { goodsReceivings.insert(0, gr); notifyListeners(); }

  // ── Products Module ───────────────────────────────────────────────────────────
  late final List<ProductCategory> productCategories = _seedProductCategories();
  late final List<Brand> brands = _seedBrands();
  late final List<Product> products = _seedProducts();

  void addProductCategory(ProductCategory c) { productCategories.add(c); notifyListeners(); }
  void addBrand(Brand b) { brands.add(b); notifyListeners(); }
  void addProduct(Product p) { products.insert(0, p); notifyListeners(); }
  void deleteProduct(Product p) { products.remove(p); notifyListeners(); }

  // ── Hair Patch Module ─────────────────────────────────────────────────────────
  late final List<HairPatchItem> hairPatchItems = _seedHairPatchItems();
  late final List<PatchOrder>    patchOrders    = _seedPatchOrders();
  late final List<PatchFitting>  patchFittings  = _seedPatchFittings();
  late final List<PatchMaintenance> patchMaintenances = _seedPatchMaintenances();

  void addHairPatchItem(HairPatchItem i) { hairPatchItems.add(i); notifyListeners(); }
  void updateHairPatchItem(HairPatchItem i) { notifyListeners(); }
  void addPatchOrder(PatchOrder o) { patchOrders.insert(0, o); _notify('New Patch Order', 'Order #${o.id} — ${o.patientName}', Icons.shopping_bag_outlined); notifyListeners(); }
  void updatePatchOrder(PatchOrder o) { notifyListeners(); }
  void addPatchFitting(PatchFitting f) { patchFittings.insert(0, f); notifyListeners(); }
  void updatePatchFitting(PatchFitting f) { notifyListeners(); }
  void addPatchMaintenance(PatchMaintenance m) { patchMaintenances.insert(0, m); notifyListeners(); }
  void updatePatchMaintenance(PatchMaintenance m) { notifyListeners(); }

  // ── Inventory Module ──────────────────────────────────────────────────────────
  late final List<StockItem>     stockItems     = _seedStockItems();
  late final List<StockMovement> stockMovements = _seedStockMovements();
  late final List<StockAudit>    stockAudits    = _seedStockAudits();

  void addStockItem(StockItem s) { stockItems.add(s); notifyListeners(); }
  void updateStockItem(StockItem s) { notifyListeners(); }
  void recordMovement(StockMovement m) {
    stockMovements.insert(0, m);
    final idx = stockItems.indexWhere((s) => s.id == m.itemId);
    if (idx != -1) {
      if (m.type.isIn) {
        stockItems[idx].currentQty += m.qty;
      } else {
        stockItems[idx].currentQty = (stockItems[idx].currentQty - m.qty).clamp(0, 99999);
      }
      stockItems[idx].lastUpdated = DateTime.now();
    }
    notifyListeners();
  }
  void addStockAudit(StockAudit a) { stockAudits.insert(0, a); notifyListeners(); }
  void completeStockAudit(StockAudit a) {
    for (final line in a.lines) {
      final idx = stockItems.indexWhere((s) => s.id == line.itemId);
      if (idx != -1) {
        stockItems[idx].currentQty = line.physicalQty;
        stockItems[idx].lastUpdated = DateTime.now();
      }
    }
    a.completed = true;
    notifyListeners();
  }

  // ── Consultation Seeds ────────────────────────────────────────────────────────
  List<ConsultationRecord> _seedConsultations() => [
        ConsultationRecord(
          id: 'CON-001', patientId: 'PT-001', patientName: 'Bilal Ahmed',
          patientPhone: '+92 300 1234567', patientGender: 'Male', patientAge: 34,
          doctorName: 'Dr. Rehman', consultationDate: DateTime.now().subtract(const Duration(days: 25)),
          chiefComplaint: 'Severe hair loss on crown and frontal area for past 4 years',
          medicalHistory: 'Hypertension (controlled). No previous surgeries.',
          currentMedications: 'Amlodipine 5mg daily', allergies: 'None known',
          hairAnalysis: HairAnalysis(norwoodScale: 4, texture: HairTexture.medium, type: HairType.straight, density: 2, miniaturation: MiniaturationLevel.moderate, donorAreaCondition: 'Good — sufficient density for 3000 grafts', hairlineNotes: 'Receding frontal hairline, vertex thinning', hasFamilyHistory: true),
          scalpAnalysis: ScalpAnalysis(condition: ScalpCondition.dry, scaliness: 2, sebumLevel: 2, hasInfection: false, hasScarring: false),
          recommendations: [TreatmentRecommendationItem(treatmentName: 'FUE Hair Transplant — 3000 Grafts', description: 'Primary procedure to restore frontal and crown density', sessions: 1, interval: 'One-time', estimatedCost: 450000, priority: TreatmentPriority.essential), TreatmentRecommendationItem(treatmentName: 'PRP Therapy', description: 'Post-transplant PRP to accelerate healing and density', sessions: 4, interval: 'Monthly', estimatedCost: 60000, priority: TreatmentPriority.recommended)],
          doctorNotes: 'Excellent candidate for FUE. Donor area sufficient. Realistic expectations discussed. Proceed with procedure.',
          followUpDate: DateTime.now().add(const Duration(days: 60)),
        ),
        ConsultationRecord(
          id: 'CON-002', patientId: 'PT-004', patientName: 'Ayesha Khan',
          patientPhone: '+92 345 1122334', patientGender: 'Female', patientAge: 37,
          doctorName: 'Dr. Sara Iqbal', consultationDate: DateTime.now().subtract(const Duration(days: 32)),
          chiefComplaint: 'Diffuse hair thinning, especially on the central parting',
          medicalHistory: 'Hypothyroidism (on medication). Iron deficiency in past.',
          currentMedications: 'Euthyrox 50mcg', allergies: 'Penicillin',
          hairAnalysis: HairAnalysis(norwoodScale: 3, ludwigScale: 2, texture: HairTexture.fine, type: HairType.wavy, density: 2, miniaturation: MiniaturationLevel.moderate, hasFamilyHistory: true, otherObservations: 'Miniaturization visible on central scalp. Thyroid levels to be confirmed.'),
          scalpAnalysis: ScalpAnalysis(condition: ScalpCondition.oily, scaliness: 3, sebumLevel: 4, hasInfection: false, hasScarring: false),
          recommendations: [TreatmentRecommendationItem(treatmentName: 'PRP Therapy — 4 Session Package', description: 'Stimulate dormant follicles and improve scalp health', sessions: 4, interval: 'Monthly', estimatedCost: 60000, priority: TreatmentPriority.essential), TreatmentRecommendationItem(treatmentName: 'Mesotherapy Session', description: 'Scalp nutrient infusion for hair strengthening', sessions: 6, interval: 'Bi-weekly', estimatedCost: 90000, priority: TreatmentPriority.recommended)],
          doctorNotes: 'Female pattern hair loss (Ludwig II). Address thyroid levels with GP first. Start PRP course immediately.',
          followUpDate: DateTime.now().add(const Duration(days: 28)),
          isConverted: true,
        ),
      ];

  // ── Company Seeds ─────────────────────────────────────────────────────────────
  List<Branch> _seedBranches() => [
    Branch(id: 'BR-001', name: 'Hair Again — Clifton (Main)', address: 'Block 5, Clifton', city: 'Karachi', phone: '+92 21 111 444 555', email: 'care@hairagain.pk', managerName: 'Nadia Aslam', isPrimary: true),
  ];

  List<Department> _seedDepartments() => [
    Department(id: 'DP-001', name: 'Medical', description: 'Surgeons, trichologists and OT team', headName: 'Dr. Rehman', employeeCount: 3),
    Department(id: 'DP-002', name: 'Operations', description: 'Front desk, admin and clinic management', headName: 'Nadia Aslam', employeeCount: 2),
    Department(id: 'DP-003', name: 'Finance', description: 'Accounts, billing and payroll', headName: '', employeeCount: 1),
  ];

  List<Designation> _seedDesignations() => [
    Designation(id: 'DG-001', title: 'Lead Surgeon', department: 'Medical', gradeLevel: 'Grade A'),
    Designation(id: 'DG-002', title: 'Trichologist', department: 'Medical', gradeLevel: 'Grade A'),
    Designation(id: 'DG-003', title: 'Dermatologist', department: 'Medical', gradeLevel: 'Grade A'),
    Designation(id: 'DG-004', title: 'OT Nurse', department: 'Medical', gradeLevel: 'Grade C'),
    Designation(id: 'DG-005', title: 'Receptionist', department: 'Operations', gradeLevel: 'Grade D'),
    Designation(id: 'DG-006', title: 'Clinic Manager', department: 'Operations', gradeLevel: 'Grade B'),
  ];

  List<WorkingDay> _seedWorkingDays() => [
    WorkingDay(day: 'Mon', isOpen: true, openTime: '09:00', closeTime: '18:00', breakStart: '13:00', breakEnd: '14:00'),
    WorkingDay(day: 'Tue', isOpen: true, openTime: '09:00', closeTime: '18:00', breakStart: '13:00', breakEnd: '14:00'),
    WorkingDay(day: 'Wed', isOpen: true, openTime: '09:00', closeTime: '18:00', breakStart: '13:00', breakEnd: '14:00'),
    WorkingDay(day: 'Thu', isOpen: true, openTime: '09:00', closeTime: '18:00', breakStart: '13:00', breakEnd: '14:00'),
    WorkingDay(day: 'Fri', isOpen: false, openTime: '09:00', closeTime: '18:00', breakStart: '12:30', breakEnd: '14:30'),
    WorkingDay(day: 'Sat', isOpen: true, openTime: '10:00', closeTime: '17:00', breakStart: '13:00', breakEnd: '14:00'),
    WorkingDay(day: 'Sun', isOpen: false, openTime: '09:00', closeTime: '18:00', breakStart: '13:00', breakEnd: '14:00'),
  ];

  List<Holiday> _seedHolidays() => [
    Holiday(id: 'HOL-001', name: 'Eid ul Fitr', type: 'public', date: DateTime(2026, 3, 31), isRecurring: true),
    Holiday(id: 'HOL-002', name: 'Eid ul Adha', type: 'public', date: DateTime(2026, 6, 7), isRecurring: true),
    Holiday(id: 'HOL-003', name: 'Independence Day', type: 'public', date: DateTime(2026, 8, 14), isRecurring: true),
    Holiday(id: 'HOL-004', name: 'Clinic Annual Closure', type: 'clinic', date: DateTime(2026, 12, 25), isRecurring: false),
  ];

  // ── Treatment Seeds ───────────────────────────────────────────────────────────
  List<TreatmentPlan> _seedTreatmentPlans() {
    final now = DateTime.now();
    return [
      TreatmentPlan(
        id: 'TP-001', patientId: 'PT-001', patientName: 'Bilal Ahmed',
        treatmentName: 'PRP Therapy — 4 Session Plan', doctorName: 'Dr. Sara Iqbal',
        totalSessions: 4, startDate: DateTime(now.year, now.month - 1, 10),
        planDetails: 'Monthly PRP sessions to support post-transplant recovery and follicle stimulation.',
        progressNotes: 'Patient responding well. Session 2 showed marked improvement in scalp oiliness.',
        sessions: [
          TreatmentSession(id: 'TS-001', planId: 'TP-001', patientName: 'Bilal Ahmed', doctorName: 'Dr. Sara Iqbal', sessionNumber: 1, scheduledDate: DateTime(now.year, now.month - 1, 10), cost: 18000, status: SessionStatus.completed, actualDate: DateTime(now.year, now.month - 1, 10)),
          TreatmentSession(id: 'TS-002', planId: 'TP-001', patientName: 'Bilal Ahmed', doctorName: 'Dr. Sara Iqbal', sessionNumber: 2, scheduledDate: DateTime(now.year, now.month, 10), cost: 18000, status: SessionStatus.completed, actualDate: DateTime(now.year, now.month, 10)),
          TreatmentSession(id: 'TS-003', planId: 'TP-001', patientName: 'Bilal Ahmed', doctorName: 'Dr. Sara Iqbal', sessionNumber: 3, scheduledDate: DateTime(now.year, now.month + 1, 10), cost: 18000, status: SessionStatus.scheduled),
          TreatmentSession(id: 'TS-004', planId: 'TP-001', patientName: 'Bilal Ahmed', doctorName: 'Dr. Sara Iqbal', sessionNumber: 4, scheduledDate: DateTime(now.year, now.month + 2, 10), cost: 18000, status: SessionStatus.scheduled),
        ],
      ),
      TreatmentPlan(
        id: 'TP-002', patientId: 'PT-004', patientName: 'Ayesha Khan',
        treatmentName: 'Mesotherapy + PRP Combo', doctorName: 'Dr. Sara Iqbal',
        totalSessions: 6, startDate: DateTime(now.year, now.month, 1),
        planDetails: 'Alternating PRP and Mesotherapy sessions for diffuse hair thinning (Ludwig II).',
        sessions: [
          TreatmentSession(id: 'TS-005', planId: 'TP-002', patientName: 'Ayesha Khan', doctorName: 'Dr. Sara Iqbal', sessionNumber: 1, scheduledDate: DateTime(now.year, now.month, 6), cost: 15000, status: SessionStatus.completed, actualDate: DateTime(now.year, now.month, 6)),
          TreatmentSession(id: 'TS-006', planId: 'TP-002', patientName: 'Ayesha Khan', doctorName: 'Dr. Sara Iqbal', sessionNumber: 2, scheduledDate: DateTime(now.year, now.month, 20), cost: 18000, status: SessionStatus.scheduled),
          TreatmentSession(id: 'TS-007', planId: 'TP-002', patientName: 'Ayesha Khan', doctorName: 'Dr. Sara Iqbal', sessionNumber: 3, scheduledDate: DateTime(now.year, now.month + 1, 5), cost: 15000, status: SessionStatus.scheduled),
          TreatmentSession(id: 'TS-008', planId: 'TP-002', patientName: 'Ayesha Khan', doctorName: 'Dr. Sara Iqbal', sessionNumber: 4, scheduledDate: DateTime(now.year, now.month + 1, 20), cost: 18000, status: SessionStatus.scheduled),
          TreatmentSession(id: 'TS-009', planId: 'TP-002', patientName: 'Ayesha Khan', doctorName: 'Dr. Sara Iqbal', sessionNumber: 5, scheduledDate: DateTime(now.year, now.month + 2, 5), cost: 15000, status: SessionStatus.scheduled),
          TreatmentSession(id: 'TS-010', planId: 'TP-002', patientName: 'Ayesha Khan', doctorName: 'Dr. Sara Iqbal', sessionNumber: 6, scheduledDate: DateTime(now.year, now.month + 2, 20), cost: 18000, status: SessionStatus.scheduled),
        ],
      ),
    ];
  }

  // ── Transplant Seeds ──────────────────────────────────────────────────────────
  List<TransplantCase> _seedTransplantCases() {
    final now = DateTime.now();
    return [
      TransplantCase(
        id: 'TC-001', patientId: 'PT-003', patientName: 'Hamza Sheikh', patientPhone: '+92 333 4455667',
        surgeonName: 'Dr. Rehman', assistantName: 'Hira Saleem',
        technique: TransplantTechnique.fue, graftsExtracted: 3100, graftsImplanted: 3000,
        norwoodScale: 6, surgeryDate: DateTime(now.year, now.month - 3, 11),
        status: SurgeryStatus.completed, procedureCost: 450000,
        preOpNotes: 'Norwood VI. Two-session plan. Crown first, then frontal.',
        postOpNotes: 'Procedure completed without complications. Excellent graft yield.',
        followUps: [
          PostOpVisit(id: 'POV-001', caseId: 'TC-001', label: 'Day-7 Check', scheduledDate: DateTime(now.year, now.month - 3, 18), doctorName: 'Dr. Rehman', completed: true, actualDate: DateTime(now.year, now.month - 3, 18), outcome: 'Healing well. No signs of infection.'),
          PostOpVisit(id: 'POV-002', caseId: 'TC-001', label: 'Day-30 Review', scheduledDate: DateTime(now.year, now.month - 2, 11), doctorName: 'Dr. Rehman', completed: true, actualDate: DateTime(now.year, now.month - 2, 11), outcome: 'Shedding phase normal. Patient reassured.'),
          PostOpVisit(id: 'POV-003', caseId: 'TC-001', label: 'Day-90 Photo Review', scheduledDate: DateTime(now.year, now.month, 9), doctorName: 'Dr. Rehman', completed: true, actualDate: DateTime(now.year, now.month, 9), outcome: 'Excellent growth. 80% density visible.'),
        ],
      ),
      TransplantCase(
        id: 'TC-002', patientId: 'PT-001', patientName: 'Bilal Ahmed', patientPhone: '+92 300 1234567',
        surgeonName: 'Dr. Rehman', assistantName: 'Hira Saleem',
        technique: TransplantTechnique.fue, graftsExtracted: 3100, graftsImplanted: 3000,
        norwoodScale: 4, surgeryDate: DateTime(now.year, now.month, 9),
        status: SurgeryStatus.completed, procedureCost: 450000,
        preOpNotes: 'Norwood IV. Frontal hairline restoration and crown fill.',
        postOpNotes: 'Smooth procedure. 3000 grafts implanted in 6 hours.',
        followUps: [
          PostOpVisit(id: 'POV-004', caseId: 'TC-002', label: 'Day-7 Check', scheduledDate: DateTime(now.year, now.month, 16), doctorName: 'Dr. Rehman', completed: false),
          PostOpVisit(id: 'POV-005', caseId: 'TC-002', label: 'Day-30 Review', scheduledDate: DateTime(now.year, now.month + 1, 9), doctorName: 'Dr. Rehman', completed: false),
          PostOpVisit(id: 'POV-006', caseId: 'TC-002', label: 'Day-90 Photo Review', scheduledDate: DateTime(now.year, now.month + 3, 9), doctorName: 'Dr. Rehman', completed: false),
        ],
      ),
    ];
  }

  // ── Membership Seeds ──────────────────────────────────────────────────────────
  List<MembershipPlan> _seedMembershipPlans() => [
    MembershipPlan(id: 'MP-001', name: 'Silver Care', description: 'Entry-level plan with basic session allowance', price: 15000, durationMonths: 3, maxSessions: 4, discountPercentage: 10, benefits: ['10% off all treatments', '4 sessions included', 'Priority booking'], colorTag: '#C0C0C0'),
    MembershipPlan(id: 'MP-002', name: 'Gold Wellness', description: 'Best value — includes premium sessions and discount', price: 35000, durationMonths: 6, maxSessions: 10, discountPercentage: 15, benefits: ['15% off all treatments', '10 sessions included', 'Free consultation', 'Priority booking'], colorTag: '#DAA520'),
    MembershipPlan(id: 'MP-003', name: 'Platinum Elite', description: 'Unlimited access with maximum benefits', price: 80000, durationMonths: 12, maxSessions: 30, discountPercentage: 25, benefits: ['25% off all treatments', '30 sessions included', 'Free consultations', 'Free PRP session', 'Dedicated coordinator'], colorTag: '#00D4FF'),
  ];

  List<CustomerMembership> _seedCustomerMemberships() {
    final now = DateTime.now();
    return [
      CustomerMembership(id: 'CM-001', customerId: 'PT-004', customerName: 'Ayesha Khan', customerPhone: '+92 345 1122334', planId: 'MP-002', planName: 'Gold Wellness', startDate: DateTime(now.year, now.month - 1, 1), endDate: DateTime(now.year, now.month + 5, 1), sessionsTotal: 10, amountPaid: 35000, sessionsUsed: 3),
      CustomerMembership(id: 'CM-002', customerId: 'PT-006', customerName: 'Fatima Noor', customerPhone: '+92 312 6655443', planId: 'MP-001', planName: 'Silver Care', startDate: DateTime(now.year, now.month - 2, 15), endDate: DateTime(now.year, now.month + 1, 15), sessionsTotal: 4, amountPaid: 15000, sessionsUsed: 3),
    ];
  }

  // ── Loyalty Seeds ─────────────────────────────────────────────────────────────
  List<LoyaltyAccount> _seedLoyaltyAccounts() => [
    LoyaltyAccount(id: 'LA-001', customerId: 'PT-001', customerName: 'Bilal Ahmed', customerPhone: '+92 300 1234567', totalPoints: 4800, redeemedPoints: 500, tier: LoyaltyTier.gold, transactions: [
      PointTransaction(id: 'PT-T001', type: 'earned', description: 'FUE Transplant — 3000 Grafts', points: 4500, date: DateTime.now().subtract(const Duration(days: 23))),
      PointTransaction(id: 'PT-T002', type: 'earned', description: 'PRP Session 1', points: 180, date: DateTime.now().subtract(const Duration(days: 16))),
      PointTransaction(id: 'PT-T003', type: 'redeemed', description: 'Voucher redemption', points: 500, date: DateTime.now().subtract(const Duration(days: 5))),
      PointTransaction(id: 'PT-T004', type: 'earned', description: 'PRP Session 2', points: 180, date: DateTime.now().subtract(const Duration(days: 2))),
    ]),
    LoyaltyAccount(id: 'LA-002', customerId: 'PT-003', customerName: 'Hamza Sheikh', customerPhone: '+92 333 4455667', totalPoints: 6200, redeemedPoints: 1000, tier: LoyaltyTier.platinum, transactions: [
      PointTransaction(id: 'PT-T005', type: 'earned', description: 'FUE Transplant — 4500 Grafts', points: 6200, date: DateTime.now().subtract(const Duration(days: 90))),
      PointTransaction(id: 'PT-T006', type: 'redeemed', description: 'Free PRP session', points: 1000, date: DateTime.now().subtract(const Duration(days: 30))),
    ]),
    LoyaltyAccount(id: 'LA-003', customerId: 'PT-004', customerName: 'Ayesha Khan', customerPhone: '+92 345 1122334', totalPoints: 830, redeemedPoints: 0, tier: LoyaltyTier.silver, transactions: [
      PointTransaction(id: 'PT-T007', type: 'earned', description: 'Gold Membership purchase', points: 350, date: DateTime.now().subtract(const Duration(days: 30))),
      PointTransaction(id: 'PT-T008', type: 'earned', description: 'PRP Session 1', points: 180, date: DateTime.now().subtract(const Duration(days: 6))),
      PointTransaction(id: 'PT-T009', type: 'earned', description: 'PRP Session 2', points: 300, date: DateTime.now().subtract(const Duration(days: 1))),
    ]),
  ];

  List<Reward> _seedRewards() => [
    Reward(id: 'RW-001', name: '10% Off Voucher', description: 'Get 10% discount on any single treatment', rewardType: 'discount', pointsRequired: 500, value: 10),
    Reward(id: 'RW-002', name: 'Free PRP Session', description: 'One complimentary PRP therapy session (value PKR 18,000)', rewardType: 'free_service', pointsRequired: 1000, value: 18000),
    Reward(id: 'RW-003', name: 'Haircare Gift Pack', description: 'Premium haircare gift set from our retail range', rewardType: 'gift', pointsRequired: 800, value: 3500),
  ];

  List<Referral> _seedReferrals() => [
    Referral(id: 'RF-001', referrerId: 'PT-003', referrerName: 'Hamza Sheikh', refereeName: 'Usman Malik', refereePhone: '+92 301 7766554', status: ReferralStatus.qualified, pointsEarned: 200, createdAt: DateTime.now().subtract(const Duration(days: 12)), qualifiedAt: DateTime.now().subtract(const Duration(days: 5))),
    Referral(id: 'RF-002', referrerId: 'PT-001', referrerName: 'Bilal Ahmed', refereeName: 'Waqas Ahmed', refereePhone: '+92 300 5566778', status: ReferralStatus.rewarded, pointsEarned: 200, createdAt: DateTime.now().subtract(const Duration(days: 20)), qualifiedAt: DateTime.now().subtract(const Duration(days: 15))),
  ];

  // ── Vendor Seeds ──────────────────────────────────────────────────────────────
  List<Vendor> _seedVendors() => [
    Vendor(id: 'VN-001', name: 'MedStar Supplies', contactPerson: 'Asif Karim', phone: '+92 21 3456789', email: 'asif@medstar.pk', address: 'SITE Area', city: 'Karachi', category: 'Medical Supplies', totalPurchases: 850000, paymentTerms: 'Net 30'),
    Vendor(id: 'VN-002', name: 'PharmaLink Karachi', contactPerson: 'Tariq Butt', phone: '+92 21 9876543', email: 'tariq@pharmalink.pk', address: 'Korangi Industrial', city: 'Karachi', category: 'Pharmacy', totalPurchases: 320000, paymentTerms: 'Net 15'),
    Vendor(id: 'VN-003', name: 'Digital Agency KHI', contactPerson: 'Saima Khan', phone: '+92 300 1234567', email: 'saima@dagency.pk', address: 'Zamzama', city: 'Karachi', category: 'Marketing Services', totalPurchases: 240000, paymentTerms: 'Advance'),
  ];

  List<PurchaseOrder> _seedPurchaseOrders() {
    final now = DateTime.now();
    return [
      PurchaseOrder(id: 'PO-001', vendorId: 'VN-001', vendorName: 'MedStar Supplies', createdBy: 'Nadia Aslam', orderDate: DateTime(now.year, now.month, 3), expectedDate: DateTime(now.year, now.month, 10), status: POStatus.received,
        items: [POItem(name: 'PRP Centrifuge Kits', unit: 'box', qty: 10, unitPrice: 4500), POItem(name: 'FUE Punch Tips (0.8mm)', unit: 'pack', qty: 5, unitPrice: 1200), POItem(name: 'Sterile Graft Trays', unit: 'pack', qty: 20, unitPrice: 900)]),
      PurchaseOrder(id: 'PO-002', vendorId: 'VN-002', vendorName: 'PharmaLink Karachi', createdBy: 'Nadia Aslam', orderDate: DateTime(now.year, now.month, 15), status: POStatus.sent,
        items: [POItem(name: 'Local Anaesthetic Vials', unit: 'box', qty: 50, unitPrice: 650), POItem(name: 'Mesotherapy Ampoules', unit: 'box', qty: 10, unitPrice: 2200)]),
    ];
  }

  List<GoodsReceiving> _seedGoodsReceivings() {
    final now = DateTime.now();
    return [
      GoodsReceiving(id: 'GR-001', poId: 'PO-001', vendorName: 'MedStar Supplies', receivedBy: 'Ali Raza', receivedDate: DateTime(now.year, now.month, 10),
        items: [ReceivedItem(name: 'PRP Centrifuge Kits', orderedQty: 10, receivedQty: 10), ReceivedItem(name: 'FUE Punch Tips (0.8mm)', orderedQty: 5, receivedQty: 5), ReceivedItem(name: 'Sterile Graft Trays', orderedQty: 20, receivedQty: 18, condition: 'partial')],
        notes: '2 sterile trays missing — supplier to deliver remainder.'),
    ];
  }

  // ── Product Seeds ─────────────────────────────────────────────────────────────
  List<ProductCategory> _seedProductCategories() => [
    ProductCategory(id: 'CAT-001', name: 'Hair Care', description: 'Serums, shampoos and topical treatments', productCount: 3),
    ProductCategory(id: 'CAT-002', name: 'Surgical Consumables', description: 'OT and surgical use items', productCount: 2),
    ProductCategory(id: 'CAT-003', name: 'Retail Gift Sets', description: 'Packaged retail products for patients', productCount: 1),
  ];

  List<Brand> _seedBrands() => [
    Brand(id: 'BRD-001', name: 'HairMax', description: 'Premium hair restoration brand', origin: 'Pakistan'),
    Brand(id: 'BRD-002', name: 'Kérastase', description: 'Luxury French hair care', origin: 'France'),
  ];

  List<Product> _seedProducts() => [
    Product(id: 'PR-001', name: 'Anti-Hairloss Serum', categoryId: 'CAT-001', categoryName: 'Hair Care', brandId: 'BRD-001', brandName: 'HairMax', description: 'Daily topical serum for hair follicle strengthening', sku: 'HM-SER-001', unit: 'bottle', costPrice: 4500, sellingPrice: 8500, stockQty: 3, reorderLevel: 8, variants: []),
    Product(id: 'PR-002', name: 'Post-Op Care Pack', categoryId: 'CAT-001', categoryName: 'Hair Care', brandId: 'BRD-001', brandName: 'HairMax', description: 'Complete post-transplant care kit (shampoo + spray + instructions)', sku: 'HM-PKG-001', unit: 'pack', costPrice: 1800, sellingPrice: 3500, stockQty: 24, reorderLevel: 10, variants: []),
    Product(id: 'PR-003', name: 'PRP Centrifuge Kit', categoryId: 'CAT-002', categoryName: 'Surgical Consumables', brandId: 'BRD-001', brandName: 'HairMax', description: 'Single-use PRP preparation kit', sku: 'HM-PRP-001', unit: 'kit', costPrice: 3000, sellingPrice: 4500, stockQty: 6, reorderLevel: 10, variants: []),
    Product(id: 'PR-004', name: 'Kérastase Densifique', categoryId: 'CAT-001', categoryName: 'Hair Care', brandId: 'BRD-002', brandName: 'Kérastase', description: 'Professional density-boosting treatment range', sku: 'KS-DNS-001', unit: 'bottle', costPrice: 6500, sellingPrice: 12000, stockQty: 8, reorderLevel: 5, variants: []),
  ];

  // ── Hair Patch Seeds ──────────────────────────────────────────────────────────
  List<HairPatchItem> _seedHairPatchItems() => [
    HairPatchItem(id: 'HP-001', name: 'French Lace Natural', sku: 'HP-FL-001', type: PatchType.lace, hairOrigin: HairOrigin.remyHuman, baseColor: '#1B1B1B', hairDensity: 'Medium', hairTexture: 'Straight', lengthCm: 20, widthCm: 16, price: 45000, stockQty: 3, description: 'Ultra-thin French lace base with Remy human hair. Natural-looking hairline.', features: ['Ultra-thin base', 'Natural hairline', '6-8 month lifespan'], addedOn: DateTime(2026, 1, 15)),
    HairPatchItem(id: 'HP-002', name: 'Mono Classic', sku: 'HP-MC-001', type: PatchType.monofilament, hairOrigin: HairOrigin.human, baseColor: '#3B2314', hairDensity: 'Light-Medium', hairTexture: 'Wavy', lengthCm: 22, widthCm: 17, price: 38000, stockQty: 5, description: 'Breathable monofilament base with natural human hair. Comfortable daily wear.', features: ['Breathable', 'Durable base', 'Easy maintenance'], addedOn: DateTime(2026, 1, 20)),
    HairPatchItem(id: 'HP-003', name: 'Poly Skin Elite', sku: 'HP-PS-001', type: PatchType.polyurethane, hairOrigin: HairOrigin.remyHuman, baseColor: '#1B1B1B', hairDensity: 'Heavy', hairTexture: 'Straight', lengthCm: 18, widthCm: 14, price: 32000, stockQty: 8, description: 'Polyurethane skin base for secure adhesive bonding. Excellent scalp replication.', features: ['Secure adhesive bond', 'Easy to clean', '3-4 month lifespan'], addedOn: DateTime(2026, 2, 5)),
    HairPatchItem(id: 'HP-004', name: 'Hybrid Pro Max', sku: 'HP-HB-001', type: PatchType.hybrid, hairOrigin: HairOrigin.europeanHuman, baseColor: '#8B6914', hairDensity: 'Medium', hairTexture: 'Curly', lengthCm: 24, widthCm: 18, price: 75000, stockQty: 2, description: 'Premium hybrid base combining French lace front with poly perimeter. Top-of-line product.', features: ['Hybrid construction', 'European hair', 'Maximum comfort', 'Custom fit'], addedOn: DateTime(2026, 2, 20)),
    HairPatchItem(id: 'HP-005', name: 'Silicon Comfort Base', sku: 'HP-SB-001', type: PatchType.silicon, hairOrigin: HairOrigin.human, baseColor: '#1B1B1B', hairDensity: 'Light', hairTexture: 'Straight', lengthCm: 16, widthCm: 12, price: 28000, stockQty: 4, description: 'Soft silicon base for sensitive scalps. Hypoallergenic and lightweight.', features: ['Hypoallergenic', 'Lightweight', 'Sensitive scalp safe'], addedOn: DateTime(2026, 3, 1)),
  ];

  List<PatchOrder> _seedPatchOrders() {
    final now = DateTime.now();
    return [
      PatchOrder(id: 'PO2-001', patientId: 'PT-001', patientName: 'Bilal Ahmed', patientPhone: '+92 300 1234567',
        patchId: 'HP-001', patchName: 'French Lace Natural', isCustom: false,
        measurement: PatchMeasurement(frontToBack: 19.5, earToEar: 15.8, circumference: 56.0, hairlineShape: 'Natural', colorCode: '#1B1B1B', textureMatch: 'Straight', densityPreference: 'Medium'),
        advancePaid: 22500, totalCost: 45000, orderDate: DateTime(now.year, now.month - 1, 10),
        expectedDelivery: DateTime(now.year, now.month, 10), status: PatchOrderStatus.ready,
        notes: 'Patient post-transplant, coverage for crown while grafts grow.', assignedTo: 'Dr. Rehman'),
      PatchOrder(id: 'PO2-002', patientId: 'PT-003', patientName: 'Hamza Sheikh', patientPhone: '+92 333 4455667',
        isCustom: true, patchName: 'Custom European Curl',
        measurement: PatchMeasurement(frontToBack: 22.0, earToEar: 17.5, circumference: 58.5, hairlineShape: 'Receded-Natural', colorCode: '#3B2314', textureMatch: 'Wavy', densityPreference: 'Medium-Heavy', additionalNotes: 'Patient wants slightly wavy texture matching his natural hair'),
        advancePaid: 30000, totalCost: 80000, orderDate: DateTime(now.year, now.month - 2, 5),
        expectedDelivery: DateTime(now.year, now.month + 1, 5), status: PatchOrderStatus.production,
        assignedTo: 'Dr. Sara Iqbal'),
      PatchOrder(id: 'PO2-003', patientId: 'PT-005', patientName: 'Kamran Ali', patientPhone: '+92 301 3344556',
        patchId: 'HP-003', patchName: 'Poly Skin Elite', isCustom: false,
        measurement: PatchMeasurement(frontToBack: 17.0, earToEar: 13.5, circumference: 55.0, hairlineShape: 'Mature', colorCode: '#1B1B1B', textureMatch: 'Straight', densityPreference: 'Heavy'),
        advancePaid: 16000, totalCost: 32000, orderDate: DateTime(now.year, now.month, 2),
        expectedDelivery: DateTime(now.year, now.month, 20), status: PatchOrderStatus.measuring,
        assignedTo: 'Hira Saleem'),
    ];
  }

  List<PatchFitting> _seedPatchFittings() {
    final now = DateTime.now();
    return [
      PatchFitting(id: 'FIT-001', patientId: 'PT-001', patientName: 'Bilal Ahmed', patientPhone: '+92 300 1234567',
        orderId: 'PO2-001', patchName: 'French Lace Natural',
        scheduledDate: DateTime(now.year, now.month, now.day + 3, 11, 0),
        status: FittingStatus.scheduled, technicianName: 'Hira Saleem',
        notes: 'First fitting. Bring mirror for patient review. Apply adhesive tape method.'),
      PatchFitting(id: 'FIT-002', patientId: 'PT-003', patientName: 'Hamza Sheikh', patientPhone: '+92 333 4455667',
        patchName: 'Previous Mono Classic',
        scheduledDate: DateTime(now.year, now.month - 1, 18, 14, 0),
        status: FittingStatus.completed, technicianName: 'Hira Saleem',
        notes: 'Completed fitting. Patient satisfied with natural look.',
        followUpNeeded: false, completedAt: DateTime(now.year, now.month - 1, 18, 15, 30)),
      PatchFitting(id: 'FIT-003', patientId: 'PT-006', patientName: 'Fatima Noor', patientPhone: '+92 312 6655443',
        patchName: 'Poly Skin Custom',
        scheduledDate: DateTime(now.year, now.month, now.day - 1, 10, 0),
        status: FittingStatus.rescheduled, technicianName: 'Hira Saleem',
        notes: 'Patient called to reschedule. New slot pending confirmation.', followUpNeeded: true),
      PatchFitting(id: 'FIT-004', patientId: 'PT-005', patientName: 'Kamran Ali', patientPhone: '+92 301 3344556',
        orderId: 'PO2-003', patchName: 'Poly Skin Elite',
        scheduledDate: DateTime(now.year, now.month, now.day + 10, 12, 0),
        status: FittingStatus.scheduled, technicianName: 'Hira Saleem',
        notes: 'Post-delivery fitting session.'),
    ];
  }

  List<PatchMaintenance> _seedPatchMaintenances() {
    final now = DateTime.now();
    return [
      PatchMaintenance(id: 'MNT-001', patientId: 'PT-003', patientName: 'Hamza Sheikh', patientPhone: '+92 333 4455667',
        patchName: 'Mono Classic', type: MaintenanceType.adhesiveReplacement,
        scheduledDate: DateTime(now.year, now.month, now.day + 5, 11, 0),
        completed: false, technicianName: 'Hira Saleem',
        notes: 'Regular adhesive refresh — 6-week cycle.', cost: 2500),
      PatchMaintenance(id: 'MNT-002', patientId: 'PT-003', patientName: 'Hamza Sheikh', patientPhone: '+92 333 4455667',
        patchName: 'Mono Classic', type: MaintenanceType.cleaning,
        scheduledDate: DateTime(now.year, now.month - 1, 20, 11, 0),
        completed: true, technicianName: 'Hira Saleem',
        notes: 'Deep clean and condition. Patch in excellent shape.', cost: 1500,
        completedAt: DateTime(now.year, now.month - 1, 20, 12, 0)),
      PatchMaintenance(id: 'MNT-003', patientId: 'PT-001', patientName: 'Bilal Ahmed', patientPhone: '+92 300 1234567',
        patchName: 'French Lace Natural', type: MaintenanceType.restyling,
        scheduledDate: DateTime(now.year, now.month, now.day + 14, 10, 0),
        completed: false, technicianName: 'Hira Saleem',
        notes: 'Patient requested lighter trim to match his natural hair growth.', cost: 2000),
      PatchMaintenance(id: 'MNT-004', patientId: 'PT-006', patientName: 'Fatima Noor', patientPhone: '+92 312 6655443',
        patchName: 'Silicon Comfort', type: MaintenanceType.adjustment,
        scheduledDate: DateTime(now.year, now.month - 2, 12, 14, 0),
        completed: true, technicianName: 'Hira Saleem',
        notes: 'Slight size adjustment after weight change. Refit successful.', cost: 1800,
        completedAt: DateTime(now.year, now.month - 2, 12, 15, 0)),
    ];
  }

  // ── Inventory Seeds ───────────────────────────────────────────────────────────
  List<StockItem> _seedStockItems() {
    final now = DateTime.now();
    return [
      StockItem(id: 'STK-001', name: 'PRP Centrifuge Kit', sku: 'STK-PRP-001', unit: 'kit', category: StockCategory.consumable, costPrice: 3000, sellingPrice: 4500, currentQty: 6, reorderLevel: 10, maxLevel: 50, location: 'OT Store — Shelf A1', vendorId: 'VN-001', vendorName: 'MedStar Supplies', lastUpdated: DateTime(now.year, now.month, 10)),
      StockItem(id: 'STK-002', name: 'FUE Punch Tips (0.8mm)', sku: 'STK-FUE-001', unit: 'pack', category: StockCategory.equipment, costPrice: 1200, sellingPrice: 2000, currentQty: 12, reorderLevel: 5, maxLevel: 30, location: 'OT Store — Shelf A2', vendorId: 'VN-001', vendorName: 'MedStar Supplies', lastUpdated: DateTime(now.year, now.month, 10)),
      StockItem(id: 'STK-003', name: 'Sterile Graft Trays', sku: 'STK-GT-001', unit: 'pack', category: StockCategory.consumable, costPrice: 900, sellingPrice: 1500, currentQty: 18, reorderLevel: 10, maxLevel: 60, location: 'OT Store — Shelf A3', vendorId: 'VN-001', vendorName: 'MedStar Supplies', lastUpdated: DateTime(now.year, now.month, 10)),
      StockItem(id: 'STK-004', name: 'Local Anaesthetic Vials', sku: 'STK-LA-001', unit: 'vial', category: StockCategory.medicine, costPrice: 650, sellingPrice: 0, currentQty: 4, reorderLevel: 15, maxLevel: 80, location: 'Pharmacy Cabinet', vendorId: 'VN-002', vendorName: 'PharmaLink Karachi', lastUpdated: DateTime(now.year, now.month, 15)),
      StockItem(id: 'STK-005', name: 'Mesotherapy Ampoules', sku: 'STK-MT-001', unit: 'box', category: StockCategory.medicine, costPrice: 2200, sellingPrice: 0, currentQty: 8, reorderLevel: 5, maxLevel: 30, location: 'Pharmacy Cabinet', vendorId: 'VN-002', vendorName: 'PharmaLink Karachi', lastUpdated: DateTime(now.year, now.month, 15)),
      StockItem(id: 'STK-006', name: 'Anti-Hairloss Serum (HairMax)', sku: 'STK-SER-001', unit: 'bottle', category: StockCategory.hairProduct, costPrice: 4500, sellingPrice: 8500, currentQty: 3, reorderLevel: 8, maxLevel: 30, location: 'Retail Display', vendorId: 'VN-001', vendorName: 'MedStar Supplies', lastUpdated: DateTime(now.year, now.month - 1, 20)),
      StockItem(id: 'STK-007', name: 'Post-Op Care Pack', sku: 'STK-POP-001', unit: 'pack', category: StockCategory.hairProduct, costPrice: 1800, sellingPrice: 3500, currentQty: 24, reorderLevel: 10, maxLevel: 60, location: 'Retail Display', vendorId: 'VN-001', vendorName: 'MedStar Supplies', lastUpdated: DateTime(now.year, now.month - 1, 20)),
      StockItem(id: 'STK-008', name: 'Surgical Gloves (M)', sku: 'STK-GL-001', unit: 'box', category: StockCategory.consumable, costPrice: 350, sellingPrice: 0, currentQty: 0, reorderLevel: 5, maxLevel: 20, location: 'OT Store — Shelf B1', vendorId: 'VN-001', vendorName: 'MedStar Supplies', lastUpdated: DateTime(now.year, now.month - 2, 5)),
      StockItem(id: 'STK-009', name: 'Kérastase Densifique', sku: 'STK-KS-001', unit: 'bottle', category: StockCategory.hairProduct, costPrice: 6500, sellingPrice: 12000, currentQty: 8, reorderLevel: 5, maxLevel: 20, location: 'Retail Display', vendorId: 'VN-003', vendorName: 'Digital Agency KHI', lastUpdated: DateTime(now.year, now.month - 1, 18)),
      StockItem(id: 'STK-010', name: 'Adhesive Tape Roll (Patch)', sku: 'STK-ADH-001', unit: 'roll', category: StockCategory.patch, costPrice: 800, sellingPrice: 1500, currentQty: 15, reorderLevel: 6, maxLevel: 40, location: 'Hair Patch Room', vendorId: 'VN-001', vendorName: 'MedStar Supplies', lastUpdated: DateTime(now.year, now.month, 1)),
    ];
  }

  List<StockMovement> _seedStockMovements() {
    final now = DateTime.now();
    return [
      StockMovement(id: 'MV-001', itemId: 'STK-001', itemName: 'PRP Centrifuge Kit', unit: 'kit', type: StockMovementType.purchase, qty: 10, unitCost: 3000, reference: 'PO-001', performedBy: 'Nadia Aslam', date: DateTime(now.year, now.month, 10), notes: 'Received against PO-001 from MedStar'),
      StockMovement(id: 'MV-002', itemId: 'STK-001', itemName: 'PRP Centrifuge Kit', unit: 'kit', type: StockMovementType.consumption, qty: 4, unitCost: 3000, reference: 'Session Use', performedBy: 'Hira Saleem', date: DateTime(now.year, now.month, 12), notes: 'Used in PRP sessions this week'),
      StockMovement(id: 'MV-003', itemId: 'STK-004', itemName: 'Local Anaesthetic Vials', unit: 'vial', type: StockMovementType.purchase, qty: 50, unitCost: 650, reference: 'PO-002', performedBy: 'Nadia Aslam', date: DateTime(now.year, now.month, 15), notes: 'Partial delivery. Full order was 80 vials.'),
      StockMovement(id: 'MV-004', itemId: 'STK-004', itemName: 'Local Anaesthetic Vials', unit: 'vial', type: StockMovementType.consumption, qty: 46, unitCost: 650, reference: 'OT Use', performedBy: 'Dr. Rehman', date: DateTime(now.year, now.month, 20), notes: 'Surgery + PRP sessions consumed'),
      StockMovement(id: 'MV-005', itemId: 'STK-008', itemName: 'Surgical Gloves (M)', unit: 'box', type: StockMovementType.consumption, qty: 3, unitCost: 350, reference: 'OT Use', performedBy: 'Hira Saleem', date: DateTime(now.year, now.month - 1, 28), notes: 'Last 3 boxes used. Need reorder urgently.'),
      StockMovement(id: 'MV-006', itemId: 'STK-006', itemName: 'Anti-Hairloss Serum (HairMax)', unit: 'bottle', type: StockMovementType.sale, qty: 2, unitCost: 4500, reference: 'POS-Sale', performedBy: 'Ali Raza', date: DateTime(now.year, now.month, 8), notes: 'Retail sale at front desk'),
      StockMovement(id: 'MV-007', itemId: 'STK-010', itemName: 'Adhesive Tape Roll (Patch)', unit: 'roll', type: StockMovementType.opening, qty: 15, unitCost: 800, reference: 'Opening', performedBy: 'Nadia Aslam', date: DateTime(now.year, 1, 1), notes: 'Opening stock entry for new module'),
    ];
  }

  List<StockAudit> _seedStockAudits() {
    final now = DateTime.now();
    return [
      StockAudit(
        id: 'AUD-001', conductedBy: 'Nadia Aslam', auditDate: DateTime(now.year, now.month - 1, 30),
        completed: true, notes: 'End-of-month stock audit. Minor variances in consumables.',
        lines: [
          AuditLine(itemId: 'STK-001', itemName: 'PRP Centrifuge Kit', unit: 'kit', systemQty: 6, physicalQty: 6),
          AuditLine(itemId: 'STK-003', itemName: 'Sterile Graft Trays', unit: 'pack', systemQty: 20, physicalQty: 18, notes: '2 trays damaged — written off'),
          AuditLine(itemId: 'STK-006', itemName: 'Anti-Hairloss Serum', unit: 'bottle', systemQty: 5, physicalQty: 5),
          AuditLine(itemId: 'STK-007', itemName: 'Post-Op Care Pack', unit: 'pack', systemQty: 26, physicalQty: 24, notes: '2 missing — investigation needed'),
        ],
      ),
    ];
  }
}
