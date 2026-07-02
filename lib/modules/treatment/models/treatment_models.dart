// modules/treatment/models — Treatment plans, sessions, progress & follow-up models.

enum TreatmentPlanStatus { active, completed, paused, cancelled }
extension TreatmentPlanStatusX on TreatmentPlanStatus {
  String get label => switch (this) {
    TreatmentPlanStatus.active => 'Active', TreatmentPlanStatus.completed => 'Completed',
    TreatmentPlanStatus.paused => 'Paused', TreatmentPlanStatus.cancelled => 'Cancelled',
  };
}

enum SessionStatus { scheduled, completed, missed, rescheduled }
extension SessionStatusX on SessionStatus {
  String get label => switch (this) {
    SessionStatus.scheduled => 'Scheduled', SessionStatus.completed => 'Completed',
    SessionStatus.missed => 'Missed', SessionStatus.rescheduled => 'Rescheduled',
  };
}

class TreatmentSession {
  final String id, planId, patientName;
  String doctorName, notes, outcome;
  final int sessionNumber;
  DateTime scheduledDate;
  DateTime? actualDate;
  SessionStatus status;
  double cost;
  TreatmentSession({required this.id, required this.planId, required this.patientName,
    required this.doctorName, required this.sessionNumber, required this.scheduledDate,
    required this.cost, this.actualDate, this.notes = '', this.outcome = '',
    this.status = SessionStatus.scheduled});
}

class TreatmentPlan {
  final String id, patientId, patientName;
  String treatmentName, doctorName, planDetails;
  final int totalSessions;
  DateTime startDate;
  DateTime? endDate;
  TreatmentPlanStatus status;
  List<TreatmentSession> sessions;
  String beforePhotoPath, progressNotes;
  TreatmentPlan({required this.id, required this.patientId, required this.patientName,
    required this.treatmentName, required this.doctorName, required this.planDetails,
    required this.totalSessions, required this.startDate, required this.sessions,
    this.endDate, this.status = TreatmentPlanStatus.active,
    this.beforePhotoPath = '', this.progressNotes = ''});

  int get completedSessions => sessions.where((s) => s.status == SessionStatus.completed).length;
  double get progressPct => totalSessions == 0 ? 0 : completedSessions / totalSessions;
  TreatmentSession? get nextSession => sessions.where((s) => s.status == SessionStatus.scheduled).isNotEmpty
      ? (sessions.where((s) => s.status == SessionStatus.scheduled).toList()..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate))).first
      : null;
  double get totalCost => sessions.fold(0, (s, ss) => s + ss.cost);
}
