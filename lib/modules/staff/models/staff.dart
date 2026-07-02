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

class Staff {
  final String id;
  String name;
  StaffRole role;
  String specialty;
  String phone;
  String email;
  bool active;
  Staff({
    required this.id,
    required this.name,
    required this.role,
    this.specialty = '',
    required this.phone,
    required this.email,
    this.active = true,
  });

  String get initials {
    final parts = name.replaceAll('Dr. ', '').trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, parts.first.length >= 2 ? 2 : 1).toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'role': role.name, 'specialty': specialty, 'phone': phone, 'email': email, 'active': active};

  factory Staff.fromJson(Map<String, dynamic> j) => Staff(
    id: j['id'] as String, name: j['name'] as String,
    role: StaffRole.values.byName(j['role'] as String? ?? 'receptionist'),
    specialty: j['specialty'] as String? ?? '',
    phone: j['phone'] as String, email: j['email'] as String,
    active: j['active'] as bool? ?? true,
  );
}
