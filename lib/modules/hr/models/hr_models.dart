enum AttendanceStatus { present, absent, late, halfDay, leave, holiday, off }

extension AttendanceStatusX on AttendanceStatus {
  String get label => switch (this) {
    AttendanceStatus.present => 'Present',
    AttendanceStatus.absent => 'Absent',
    AttendanceStatus.late => 'Late',
    AttendanceStatus.halfDay => 'Half Day',
    AttendanceStatus.leave => 'Leave',
    AttendanceStatus.holiday => 'Holiday',
    AttendanceStatus.off => 'Day Off',
  };
  String get code => switch (this) {
    AttendanceStatus.present => 'P',
    AttendanceStatus.absent => 'A',
    AttendanceStatus.late => 'L',
    AttendanceStatus.halfDay => 'HD',
    AttendanceStatus.leave => 'LV',
    AttendanceStatus.holiday => 'H',
    AttendanceStatus.off => '—',
  };
}

enum LeaveType { annual, sick, casual, maternity, paternity, unpaid, hajj }

extension LeaveTypeX on LeaveType {
  String get label => switch (this) {
    LeaveType.annual => 'Annual Leave',
    LeaveType.sick => 'Sick Leave',
    LeaveType.casual => 'Casual Leave',
    LeaveType.maternity => 'Maternity Leave',
    LeaveType.paternity => 'Paternity Leave',
    LeaveType.unpaid => 'Unpaid Leave',
    LeaveType.hajj => 'Hajj Leave',
  };
}

enum LeaveStatus { pending, approved, rejected, cancelled }

extension LeaveStatusX on LeaveStatus {
  String get label => switch (this) {
    LeaveStatus.pending => 'Pending',
    LeaveStatus.approved => 'Approved',
    LeaveStatus.rejected => 'Rejected',
    LeaveStatus.cancelled => 'Cancelled',
  };
}

enum SalaryComponentType { earning, deduction }

enum PayrollStatus { draft, processed, paid }

extension PayrollStatusX on PayrollStatus {
  String get label => switch (this) {
    PayrollStatus.draft => 'Draft',
    PayrollStatus.processed => 'Processed',
    PayrollStatus.paid => 'Paid',
  };
}

enum ApplicantStatus { received, shortlisted, interviewed, selected, rejected, withdrawn }

extension ApplicantStatusX on ApplicantStatus {
  String get label => switch (this) {
    ApplicantStatus.received => 'Received',
    ApplicantStatus.shortlisted => 'Shortlisted',
    ApplicantStatus.interviewed => 'Interviewed',
    ApplicantStatus.selected => 'Selected',
    ApplicantStatus.rejected => 'Rejected',
    ApplicantStatus.withdrawn => 'Withdrawn',
  };
}

class AttendanceRecord {
  final String employeeId;
  final String employeeName;
  final DateTime date;
  AttendanceStatus status;
  String? checkIn;
  String? checkOut;
  String? notes;

  AttendanceRecord({
    required this.employeeId,
    required this.employeeName,
    required this.date,
    this.status = AttendanceStatus.present,
    this.checkIn,
    this.checkOut,
    this.notes,
  });
}

class LeaveRequest {
  final String id;
  final String employeeId;
  final String employeeName;
  final String department;
  final LeaveType type;
  final DateTime fromDate;
  final DateTime toDate;
  final String reason;
  LeaveStatus status;
  String? approvedBy;
  String? rejectionReason;
  final DateTime appliedAt;

  int get days => toDate.difference(fromDate).inDays + 1;

  LeaveRequest({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.department,
    required this.type,
    required this.fromDate,
    required this.toDate,
    required this.reason,
    this.status = LeaveStatus.pending,
    this.approvedBy,
    this.rejectionReason,
    required this.appliedAt,
  });
}

class LeaveBalance {
  final String employeeId;
  int annual;
  int annualUsed;
  int sick;
  int sickUsed;
  int casual;
  int casualUsed;

  LeaveBalance({
    required this.employeeId,
    this.annual = 15, this.annualUsed = 0,
    this.sick = 10, this.sickUsed = 0,
    this.casual = 7, this.casualUsed = 0,
  });

  int get annualRemaining => annual - annualUsed;
  int get sickRemaining => sick - sickUsed;
  int get casualRemaining => casual - casualUsed;
}

class SalaryComponent {
  String name;
  SalaryComponentType type;
  double amount;
  bool isPercentage;

  SalaryComponent({
    required this.name,
    required this.type,
    required this.amount,
    this.isPercentage = false,
  });
}

class SalaryStructure {
  final String employeeId;
  final String employeeName;
  final String designation;
  double basicSalary;
  final List<SalaryComponent> components;

  SalaryStructure({
    required this.employeeId,
    required this.employeeName,
    required this.designation,
    required this.basicSalary,
    required this.components,
  });

  double _resolve(SalaryComponent c) =>
      c.isPercentage ? basicSalary * c.amount / 100 : c.amount;

  double get totalEarnings =>
      basicSalary +
      components
          .where((c) => c.type == SalaryComponentType.earning)
          .fold(0.0, (s, c) => s + _resolve(c));

  double get totalDeductions =>
      components
          .where((c) => c.type == SalaryComponentType.deduction)
          .fold(0.0, (s, c) => s + _resolve(c));

  double get netSalary => totalEarnings - totalDeductions;
}

class PayrollRecord {
  final String id;
  final String employeeId;
  final String employeeName;
  final String designation;
  final int month;
  final int year;
  final int workingDays;
  int presentDays;
  int leaveDays;
  int absentDays;
  final double basicSalary;
  final double allowances;
  final double overtime;
  final double deductions;
  PayrollStatus status;
  String? paidOn;
  String? paymentMethod;
  String? remarks;

  double get grossSalary => basicSalary + allowances + overtime;
  double get netSalary => grossSalary - deductions;

  PayrollRecord({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.designation,
    required this.month,
    required this.year,
    required this.workingDays,
    required this.presentDays,
    required this.leaveDays,
    required this.absentDays,
    required this.basicSalary,
    required this.allowances,
    required this.overtime,
    required this.deductions,
    this.status = PayrollStatus.draft,
    this.paidOn,
    this.paymentMethod,
    this.remarks,
  });
}

class OvertimeRecord {
  final String id;
  final String employeeId;
  final String employeeName;
  final DateTime date;
  final double hours;
  final double ratePerHour;
  bool approved;
  String? approvedBy;

  double get amount => hours * ratePerHour;

  OvertimeRecord({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.date,
    required this.hours,
    required this.ratePerHour,
    this.approved = false,
    this.approvedBy,
  });
}

class Shift {
  final String id;
  String name;
  String startTime;
  String endTime;
  List<String> workDays;
  List<String> assignedEmployeeIds;

  Shift({
    required this.id,
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.workDays,
    required this.assignedEmployeeIds,
  });
}

class InterviewSchedule {
  DateTime scheduledAt;
  String interviewer;
  String status; // scheduled, completed, no-show, cancelled
  String? notes;
  int? rating;

  InterviewSchedule({
    required this.scheduledAt,
    required this.interviewer,
    this.status = 'scheduled',
    this.notes,
    this.rating,
  });
}

class JobApplicant {
  final String id;
  String name;
  String email;
  String phone;
  String position;
  String experience;
  String expectedSalary;
  String? currentCompany;
  ApplicantStatus status;
  final DateTime appliedOn;
  final List<InterviewSchedule> interviews;
  String? notes;

  JobApplicant({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.position,
    required this.experience,
    required this.expectedSalary,
    this.currentCompany,
    this.status = ApplicantStatus.received,
    required this.appliedOn,
    required this.interviews,
    this.notes,
  });
}

class JobPost {
  final String id;
  String title;
  String department;
  String type; // Full-time, Part-time, Contract, Internship
  int openings;
  String description;
  String requirements;
  String? salaryRange;
  String? location;
  bool isActive;
  final DateTime postedOn;
  DateTime? closingDate;
  final List<JobApplicant> applicants;

  int get totalApplicants => applicants.length;
  int get shortlistedCount =>
      applicants.where((a) => a.status == ApplicantStatus.shortlisted || a.status == ApplicantStatus.interviewed || a.status == ApplicantStatus.selected).length;

  JobPost({
    required this.id,
    required this.title,
    required this.department,
    required this.type,
    required this.openings,
    required this.description,
    required this.requirements,
    this.salaryRange,
    this.location,
    this.isActive = true,
    required this.postedOn,
    this.closingDate,
    required this.applicants,
  });
}
