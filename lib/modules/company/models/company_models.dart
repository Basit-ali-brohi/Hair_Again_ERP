// modules/company/models — Company profile, branches, departments, designations,
// working hours & holiday calendar domain models.

class Branch {
  String id, name, address, city, phone, email, managerName;
  bool isPrimary, isActive;
  int employeeCount;
  Branch({required this.id, required this.name, required this.address, required this.city,
    required this.phone, required this.email, required this.managerName,
    this.isPrimary = false, this.isActive = true, this.employeeCount = 0});
}

class Department {
  String id, name, description, headName;
  bool isActive;
  int employeeCount;
  Department({required this.id, required this.name, required this.description,
    required this.headName, this.isActive = true, this.employeeCount = 0});
}

class Designation {
  String id, title, department, gradeLevel;
  bool isActive;
  Designation({required this.id, required this.title, required this.department,
    this.gradeLevel = 'Grade 1', this.isActive = true});
}

class WorkingDay {
  final String day;
  bool isOpen;
  String openTime, closeTime, breakStart, breakEnd;
  WorkingDay({required this.day, this.isOpen = true,
    this.openTime = '09:00', this.closeTime = '18:00',
    this.breakStart = '13:00', this.breakEnd = '14:00'});
}

class Holiday {
  String id, name, type;
  DateTime date;
  bool isRecurring;
  Holiday({required this.id, required this.name, required this.type,
    required this.date, this.isRecurring = false});

  String get typeLabel => switch (type) {
    'public' => 'Public Holiday', 'optional' => 'Optional Holiday',
    'clinic' => 'Clinic Closure', _ => type,
  };
}
