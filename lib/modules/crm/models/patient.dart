// modules/crm/models — Patient onboarding & Norwood-scale domain models.
import 'dart:math' as math;

enum PatientStatus { lead, active, completed }

extension PatientStatusX on PatientStatus {
  String get label => switch (this) {
        PatientStatus.lead => 'Lead',
        PatientStatus.active => 'Active Patient',
        PatientStatus.completed => 'Transplant Completed',
      };
}

class JourneyStep {
  String title;
  String detail;
  String date;
  bool done;
  JourneyStep({required this.title, required this.detail, required this.date, this.done = false});

  Map<String, dynamic> toJson() => {'title': title, 'detail': detail, 'date': date, 'done': done};
  factory JourneyStep.fromJson(Map<String, dynamic> j) => JourneyStep(title: j['title'] as String, detail: j['detail'] as String, date: j['date'] as String, done: j['done'] as bool? ?? false);
}

class Patient {
  final String id;
  String name;
  String phone;
  String email;
  String city;
  int age;
  String gender;
  PatientStatus status;
  int norwood; // Norwood scale 1–7
  List<JourneyStep> journey;
  Patient({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.city,
    required this.age,
    required this.gender,
    required this.status,
    required this.norwood,
    required this.journey,
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'phone': phone, 'email': email, 'city': city,
    'age': age, 'gender': gender, 'status': status.name, 'norwood': norwood,
    'journey': journey.map((j) => j.toJson()).toList(),
  };

  factory Patient.fromJson(Map<String, dynamic> j) => Patient(
    id: j['id'] as String, name: j['name'] as String, phone: j['phone'] as String,
    email: j['email'] as String, city: j['city'] as String, age: j['age'] as int,
    gender: j['gender'] as String,
    status: PatientStatus.values.byName(j['status'] as String? ?? 'active'),
    norwood: j['norwood'] as int? ?? 1,
    journey: (j['journey'] as List<dynamic>? ?? []).map((e) => JourneyStep.fromJson(e as Map<String, dynamic>)).toList(),
  );

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, math.min(2, parts.first.length)).toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}
