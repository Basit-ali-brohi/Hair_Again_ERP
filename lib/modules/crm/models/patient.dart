// modules/crm/models — Patient onboarding & Norwood-scale domain models.
import 'dart:math' as math;

class MedicalNote {
  String id, condition, date, notes;
  MedicalNote({required this.id, required this.condition, required this.date, required this.notes});
  Map<String, dynamic> toJson() => {'id': id, 'condition': condition, 'date': date, 'notes': notes};
  factory MedicalNote.fromJson(Map<String, dynamic> j) => MedicalNote(id: j['id'] as String, condition: j['condition'] as String, date: j['date'] as String, notes: j['notes'] as String? ?? '');
}

class PatientNote {
  String id, content, date, author, category;
  PatientNote({required this.id, required this.content, required this.date, required this.author, this.category = 'General'});
  Map<String, dynamic> toJson() => {'id': id, 'content': content, 'date': date, 'author': author, 'category': category};
  factory PatientNote.fromJson(Map<String, dynamic> j) => PatientNote(id: j['id'] as String, content: j['content'] as String, date: j['date'] as String, author: j['author'] as String? ?? '', category: j['category'] as String? ?? 'General');
}

class PatientDocument {
  String id, name, docType, date;
  String? notes;
  PatientDocument({required this.id, required this.name, required this.docType, required this.date, this.notes});
  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'docType': docType, 'date': date, 'notes': notes};
  factory PatientDocument.fromJson(Map<String, dynamic> j) => PatientDocument(id: j['id'] as String, name: j['name'] as String, docType: j['docType'] as String? ?? 'Other', date: j['date'] as String, notes: j['notes'] as String?);
}

class PatientPhoto {
  String label;
  String date;
  String path;
  PatientPhoto({required this.label, required this.date, required this.path});
  Map<String, dynamic> toJson() => {'label': label, 'date': date, 'path': path};
  factory PatientPhoto.fromJson(Map<String, dynamic> j) => PatientPhoto(
    label: j['label'] as String, date: j['date'] as String, path: j['path'] as String,
  );
}

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
  List<PatientPhoto> photos;
  List<MedicalNote> medicalNotes;
  List<PatientNote> notes;
  List<PatientDocument> docsList;
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
    List<PatientPhoto>? photos,
    List<MedicalNote>? medicalNotes,
    List<PatientNote>? notes,
    List<PatientDocument>? docsList,
  }) : photos = photos ?? [],
       medicalNotes = medicalNotes ?? [],
       notes = notes ?? [],
       docsList = docsList ?? [];

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'phone': phone, 'email': email, 'city': city,
    'age': age, 'gender': gender, 'status': status.name, 'norwood': norwood,
    'journey': journey.map((j) => j.toJson()).toList(),
    'photos': photos.map((ph) => ph.toJson()).toList(),
    'medicalNotes': medicalNotes.map((m) => m.toJson()).toList(),
    'notes': notes.map((n) => n.toJson()).toList(),
    'docsList': docsList.map((d) => d.toJson()).toList(),
  };

  factory Patient.fromJson(Map<String, dynamic> j) => Patient(
    id: j['id'] as String, name: j['name'] as String, phone: j['phone'] as String,
    email: j['email'] as String, city: j['city'] as String, age: j['age'] as int,
    gender: j['gender'] as String,
    status: PatientStatus.values.byName(j['status'] as String? ?? 'active'),
    norwood: j['norwood'] as int? ?? 1,
    journey: (j['journey'] as List<dynamic>? ?? []).map((e) => JourneyStep.fromJson(e as Map<String, dynamic>)).toList(),
    photos: (j['photos'] as List<dynamic>? ?? []).map((e) => PatientPhoto.fromJson(e as Map<String, dynamic>)).toList(),
    medicalNotes: (j['medicalNotes'] as List<dynamic>? ?? []).map((e) => MedicalNote.fromJson(e as Map<String, dynamic>)).toList(),
    notes: (j['notes'] as List<dynamic>? ?? []).map((e) => PatientNote.fromJson(e as Map<String, dynamic>)).toList(),
    docsList: (j['docsList'] as List<dynamic>? ?? []).map((e) => PatientDocument.fromJson(e as Map<String, dynamic>)).toList(),
  );

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, math.min(2, parts.first.length)).toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}
