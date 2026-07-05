// modules/appointments/models — Clinic appointment slot domain model.

enum ApptStatus { confirmed, pending, cancelled, checkedIn, completed }

extension ApptStatusX on ApptStatus {
  String get label => switch (this) {
        ApptStatus.confirmed => 'Confirmed',
        ApptStatus.pending => 'Pending',
        ApptStatus.cancelled => 'Cancelled',
        ApptStatus.checkedIn => 'Checked In',
        ApptStatus.completed => 'Completed',
      };
}

class Appointment {
  final String id;
  String patientName;
  String treatment;
  String surgeon;
  DateTime when;
  ApptStatus status;
  Appointment({required this.id, required this.patientName, required this.treatment, required this.surgeon, required this.when, this.status = ApptStatus.pending});

  Map<String, dynamic> toJson() => {
    'id': id, 'patientName': patientName, 'treatment': treatment,
    'surgeon': surgeon, 'when': when.toIso8601String(), 'status': status.name,
  };

  factory Appointment.fromJson(Map<String, dynamic> j) => Appointment(
    id: j['id'] as String, patientName: j['patientName'] as String,
    treatment: j['treatment'] as String, surgeon: j['surgeon'] as String,
    when: DateTime.parse(j['when'] as String),
    status: ApptStatus.values.byName(j['status'] as String? ?? 'pending'),
  );
}
