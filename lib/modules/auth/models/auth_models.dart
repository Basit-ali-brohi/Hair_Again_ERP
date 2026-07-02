enum UserRole {
  superAdmin, owner, branchManager, hr, accountant,
  inventoryManager, salesManager, marketingManager, receptionist, doctor, nurse,
}

extension UserRoleX on UserRole {
  String get label => switch (this) {
    UserRole.superAdmin => 'Super Admin',
    UserRole.owner => 'Owner',
    UserRole.branchManager => 'Branch Manager',
    UserRole.hr => 'HR Manager',
    UserRole.accountant => 'Accountant',
    UserRole.inventoryManager => 'Inventory Manager',
    UserRole.salesManager => 'Sales Manager',
    UserRole.marketingManager => 'Marketing Manager',
    UserRole.receptionist => 'Receptionist',
    UserRole.doctor => 'Doctor',
    UserRole.nurse => 'Nurse',
  };

  String get initials => switch (this) {
    UserRole.superAdmin => 'SA',
    UserRole.owner => 'OW',
    UserRole.branchManager => 'BM',
    UserRole.hr => 'HR',
    UserRole.accountant => 'AC',
    UserRole.inventoryManager => 'IV',
    UserRole.salesManager => 'SM',
    UserRole.marketingManager => 'MK',
    UserRole.receptionist => 'RC',
    UserRole.doctor => 'DR',
    UserRole.nurse => 'NR',
  };

  // Sidebar module indices this role can access
  // 0=Dashboard,1=CRM,2=POS,3=Appts,4=Reports,5=Settings,6=Invoices,7=Staff,
  // 8=HR,9=Leads,10=Consultation,11=Finance,12=Marketing,13=UserRoles,
  // 14=Company,15=Treatment,16=Transplant,17=Membership,18=Loyalty,
  // 19=Vendors,20=Products,21=HairPatch,22=StockMgmt
  Set<int> get accessibleIndices => switch (this) {
    UserRole.superAdmin || UserRole.owner =>
        {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22},
    UserRole.branchManager =>
        {0, 1, 2, 3, 4, 6, 7, 8, 9, 10, 11, 12, 14, 15, 16, 17, 18, 19, 20, 21, 22},
    UserRole.hr => {0, 7, 8},
    UserRole.accountant => {0, 6, 11, 19},
    UserRole.inventoryManager => {0, 2, 6, 19, 20, 22},
    UserRole.salesManager => {0, 1, 2, 3, 4, 6, 9, 12, 17, 18},
    UserRole.marketingManager => {0, 9, 12, 17, 18},
    UserRole.receptionist => {0, 1, 3, 9, 17},
    UserRole.doctor => {0, 1, 3, 10, 15, 16, 21},
    UserRole.nurse => {0, 1, 3, 10, 15, 16, 21},
  };
}

class AppUser {
  final String id;
  String name;
  String email;
  String password;
  String phone;
  UserRole role;
  String? branch;
  String? department;
  bool isActive;
  final DateTime createdAt;
  DateTime? lastLogin;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    required this.role,
    this.branch,
    this.department,
    this.isActive = true,
    required this.createdAt,
    this.lastLogin,
  });

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    final s = name.trim();
    return s.length >= 2 ? s.substring(0, 2).toUpperCase() : s.toUpperCase();
  }
}

class ActivityLog {
  final String id;
  final String userId;
  final String userName;
  final UserRole userRole;
  final String action;
  final String module;
  final DateTime timestamp;
  final String? detail;

  ActivityLog({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userRole,
    required this.action,
    required this.module,
    required this.timestamp,
    this.detail,
  });
}

class LoginHistoryEntry {
  final String id;
  final String userId;
  final String userName;
  final UserRole role;
  final DateTime loginTime;
  DateTime? logoutTime;
  final String ipAddress;
  final String device;
  final bool success;

  LoginHistoryEntry({
    required this.id,
    required this.userId,
    required this.userName,
    required this.role,
    required this.loginTime,
    this.logoutTime,
    required this.ipAddress,
    required this.device,
    this.success = true,
  });

  String get duration {
    if (logoutTime == null) return 'Active';
    final diff = logoutTime!.difference(loginTime);
    if (diff.inHours > 0) return '${diff.inHours}h ${diff.inMinutes.remainder(60)}m';
    return '${diff.inMinutes}m';
  }
}

final List<AppUser> demoUsers = [
  AppUser(
    id: 'U-001', name: 'Ahmad Raza', email: 'admin@hairagain.pk',
    password: 'Admin@123', phone: '+92 300 0000001',
    role: UserRole.superAdmin, branch: 'Clifton Branch',
    department: 'Administration', createdAt: DateTime(2024, 1, 1),
    lastLogin: DateTime.now().subtract(const Duration(hours: 2)),
  ),
  AppUser(
    id: 'U-002', name: 'Tariq Mahmood', email: 'owner@hairagain.pk',
    password: 'Owner@123', phone: '+92 300 0000002',
    role: UserRole.owner, branch: 'Clifton Branch',
    department: 'Management', createdAt: DateTime(2024, 1, 1),
  ),
  AppUser(
    id: 'U-003', name: 'Nadia Aslam', email: 'manager@hairagain.pk',
    password: 'Mgr@123', phone: '+92 311 5556667',
    role: UserRole.branchManager, branch: 'Clifton Branch',
    department: 'Operations', createdAt: DateTime(2024, 3, 15),
  ),
  AppUser(
    id: 'U-004', name: 'Zara Khan', email: 'hr@hairagain.pk',
    password: 'Hr@123', phone: '+92 300 0000004',
    role: UserRole.hr, branch: 'Clifton Branch',
    department: 'Human Resources', createdAt: DateTime(2024, 2, 1),
  ),
  AppUser(
    id: 'U-005', name: 'Kamran Ali', email: 'accounts@hairagain.pk',
    password: 'Acct@123', phone: '+92 300 0000005',
    role: UserRole.accountant, branch: 'Clifton Branch',
    department: 'Finance', createdAt: DateTime(2024, 2, 1),
  ),
  AppUser(
    id: 'U-006', name: 'Fahad Mirza', email: 'inventory@hairagain.pk',
    password: 'Inv@123', phone: '+92 300 0000006',
    role: UserRole.inventoryManager, branch: 'Clifton Branch',
    department: 'Operations', createdAt: DateTime(2024, 4, 1),
  ),
  AppUser(
    id: 'U-007', name: 'Sara Ahmed', email: 'sales@hairagain.pk',
    password: 'Sales@123', phone: '+92 300 0000007',
    role: UserRole.salesManager, branch: 'Clifton Branch',
    department: 'Sales', createdAt: DateTime(2024, 3, 1),
  ),
  AppUser(
    id: 'U-008', name: 'Ali Raza', email: 'reception@hairagain.pk',
    password: 'Rec@123', phone: '+92 345 9876543',
    role: UserRole.receptionist, branch: 'Clifton Branch',
    department: 'Front Desk', createdAt: DateTime(2024, 1, 15),
  ),
  AppUser(
    id: 'U-009', name: 'Dr. Rehman', email: 'doctor@hairagain.pk',
    password: 'Doc@123', phone: '+92 300 1112223',
    role: UserRole.doctor, branch: 'Clifton Branch',
    department: 'Medical', createdAt: DateTime(2024, 1, 1),
  ),
  AppUser(
    id: 'U-010', name: 'Hira Saleem', email: 'nurse@hairagain.pk',
    password: 'Nurse@123', phone: '+92 333 1234567',
    role: UserRole.nurse, branch: 'Clifton Branch',
    department: 'Medical', createdAt: DateTime(2024, 1, 1),
  ),
];
