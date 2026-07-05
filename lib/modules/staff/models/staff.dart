// modules/staff/models — clinic staff & doctors domain model.

enum StaffRole { doctor, nurse, receptionist, manager }

extension StaffRoleX on StaffRole {
  String get label => switch (this) {
        StaffRole.doctor => 'Doctor',
        StaffRole.nurse => 'Nurse',
        StaffRole.receptionist => 'Receptionist',
        StaffRole.manager => 'Manager',
      };
}

class StaffDocument {
  final String id;
  String title, docType, uploadDate;
  String? notes;
  StaffDocument({required this.id, required this.title, required this.docType, required this.uploadDate, this.notes});
  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'docType': docType, 'uploadDate': uploadDate, 'notes': notes};
  factory StaffDocument.fromJson(Map<String, dynamic> j) => StaffDocument(id: j['id'] as String, title: j['title'] as String, docType: j['docType'] as String? ?? 'Other', uploadDate: j['uploadDate'] as String, notes: j['notes'] as String?);
}

class StaffContract {
  final String id;
  String type, startDate, endDate;
  double salary;
  bool active;
  String? notes;
  StaffContract({required this.id, required this.type, required this.startDate, required this.endDate, required this.salary, this.active = true, this.notes});
  Map<String, dynamic> toJson() => {'id': id, 'type': type, 'startDate': startDate, 'endDate': endDate, 'salary': salary, 'active': active, 'notes': notes};
  factory StaffContract.fromJson(Map<String, dynamic> j) => StaffContract(id: j['id'] as String, type: j['type'] as String, startDate: j['startDate'] as String, endDate: j['endDate'] as String, salary: (j['salary'] as num).toDouble(), active: j['active'] as bool? ?? true, notes: j['notes'] as String?);
}

class StaffIncentive {
  final String id;
  String month, reason, status;
  double amount;
  StaffIncentive({required this.id, required this.month, required this.reason, required this.amount, this.status = 'Pending'});
  Map<String, dynamic> toJson() => {'id': id, 'month': month, 'reason': reason, 'amount': amount, 'status': status};
  factory StaffIncentive.fromJson(Map<String, dynamic> j) => StaffIncentive(id: j['id'] as String, month: j['month'] as String, reason: j['reason'] as String, amount: (j['amount'] as num).toDouble(), status: j['status'] as String? ?? 'Pending');
}

class StaffWarning {
  final String id;
  String date, reason, severity, issuedBy;
  StaffWarning({required this.id, required this.date, required this.reason, required this.severity, required this.issuedBy});
  Map<String, dynamic> toJson() => {'id': id, 'date': date, 'reason': reason, 'severity': severity, 'issuedBy': issuedBy};
  factory StaffWarning.fromJson(Map<String, dynamic> j) => StaffWarning(id: j['id'] as String, date: j['date'] as String, reason: j['reason'] as String, severity: j['severity'] as String? ?? 'Minor', issuedBy: j['issuedBy'] as String? ?? '');
}

class StaffExitRecord {
  String exitType, lastWorkingDay, reason, handoverStatus;
  bool settled;
  String? notes;
  StaffExitRecord({required this.exitType, required this.lastWorkingDay, required this.reason, this.handoverStatus = 'Pending', this.settled = false, this.notes});
  Map<String, dynamic> toJson() => {'exitType': exitType, 'lastWorkingDay': lastWorkingDay, 'reason': reason, 'handoverStatus': handoverStatus, 'settled': settled, 'notes': notes};
  factory StaffExitRecord.fromJson(Map<String, dynamic> j) => StaffExitRecord(exitType: j['exitType'] as String? ?? 'Resignation', lastWorkingDay: j['lastWorkingDay'] as String? ?? '', reason: j['reason'] as String? ?? '', handoverStatus: j['handoverStatus'] as String? ?? 'Pending', settled: j['settled'] as bool? ?? false, notes: j['notes'] as String?);
}

class Staff {
  final String id;
  String name;
  StaffRole role;
  String specialty;
  String phone;
  String email;
  bool active;
  List<StaffDocument> documents;
  List<StaffContract> contracts;
  List<StaffIncentive> incentives;
  List<StaffWarning> warnings;
  StaffExitRecord? exitRecord;

  Staff({
    required this.id,
    required this.name,
    required this.role,
    this.specialty = '',
    required this.phone,
    required this.email,
    this.active = true,
    List<StaffDocument>? documents,
    List<StaffContract>? contracts,
    List<StaffIncentive>? incentives,
    List<StaffWarning>? warnings,
    this.exitRecord,
  })  : documents = documents ?? [],
        contracts = contracts ?? [],
        incentives = incentives ?? [],
        warnings = warnings ?? [];

  String get initials {
    final parts = name.replaceAll('Dr. ', '').trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, parts.first.length >= 2 ? 2 : 1).toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  double get salary {
    final activeContract = contracts.where((c) => c.active).firstOrNull;
    return activeContract?.salary ?? 0;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'role': role.name,
        'specialty': specialty,
        'phone': phone,
        'email': email,
        'active': active,
        'documents': documents.map((d) => d.toJson()).toList(),
        'contracts': contracts.map((c) => c.toJson()).toList(),
        'incentives': incentives.map((i) => i.toJson()).toList(),
        'warnings': warnings.map((w) => w.toJson()).toList(),
        'exitRecord': exitRecord?.toJson(),
      };

  factory Staff.fromJson(Map<String, dynamic> j) => Staff(
        id: j['id'] as String,
        name: j['name'] as String,
        role: StaffRole.values.byName(j['role'] as String? ?? 'receptionist'),
        specialty: j['specialty'] as String? ?? '',
        phone: j['phone'] as String,
        email: j['email'] as String,
        active: j['active'] as bool? ?? true,
        documents: (j['documents'] as List<dynamic>? ?? []).map((e) => StaffDocument.fromJson(e as Map<String, dynamic>)).toList(),
        contracts: (j['contracts'] as List<dynamic>? ?? []).map((e) => StaffContract.fromJson(e as Map<String, dynamic>)).toList(),
        incentives: (j['incentives'] as List<dynamic>? ?? []).map((e) => StaffIncentive.fromJson(e as Map<String, dynamic>)).toList(),
        warnings: (j['warnings'] as List<dynamic>? ?? []).map((e) => StaffWarning.fromJson(e as Map<String, dynamic>)).toList(),
        exitRecord: j['exitRecord'] != null ? StaffExitRecord.fromJson(j['exitRecord'] as Map<String, dynamic>) : null,
      );
}
