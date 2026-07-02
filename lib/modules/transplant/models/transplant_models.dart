// modules/transplant/models — Hair transplant surgery cases, scheduling & follow-up.

enum TransplantTechnique { fue, fut, dhi }
extension TransplantTechniqueX on TransplantTechnique {
  String get label => switch (this) {
    TransplantTechnique.fue => 'FUE', TransplantTechnique.fut => 'FUT',
    TransplantTechnique.dhi => 'DHI',
  };
  String get fullLabel => switch (this) {
    TransplantTechnique.fue => 'Follicular Unit Extraction',
    TransplantTechnique.fut => 'Follicular Unit Transplantation',
    TransplantTechnique.dhi => 'Direct Hair Implantation',
  };
}

enum SurgeryStatus { scheduled, inProgress, completed, postponed, cancelled }
extension SurgeryStatusX on SurgeryStatus {
  String get label => switch (this) {
    SurgeryStatus.scheduled => 'Scheduled', SurgeryStatus.inProgress => 'In Progress',
    SurgeryStatus.completed => 'Completed', SurgeryStatus.postponed => 'Postponed',
    SurgeryStatus.cancelled => 'Cancelled',
  };
}

class PostOpVisit {
  final String id, caseId;
  String label, notes, outcome;
  DateTime scheduledDate;
  DateTime? actualDate;
  bool completed;
  String doctorName;
  PostOpVisit({required this.id, required this.caseId, required this.label,
    required this.scheduledDate, required this.doctorName, this.notes = '',
    this.outcome = '', this.completed = false, this.actualDate});
}

class TransplantCase {
  final String id, patientId, patientName, patientPhone;
  String surgeonName, assistantName;
  TransplantTechnique technique;
  int graftsExtracted, graftsImplanted;
  String donorArea, recipientArea;
  DateTime surgeryDate;
  SurgeryStatus status;
  String preOpNotes, intraOpNotes, postOpNotes;
  int? extractionMinutes, implantationMinutes;
  double procedureCost;
  List<PostOpVisit> followUps;
  int norwoodScale;

  TransplantCase({required this.id, required this.patientId, required this.patientName,
    required this.patientPhone, required this.surgeonName, this.assistantName = '',
    required this.technique, required this.graftsExtracted, required this.graftsImplanted,
    this.donorArea = 'Occipital Region', this.recipientArea = 'Frontal & Crown',
    required this.surgeryDate, this.status = SurgeryStatus.scheduled,
    this.preOpNotes = '', this.intraOpNotes = '', this.postOpNotes = '',
    this.extractionMinutes, this.implantationMinutes, required this.procedureCost,
    required this.followUps, this.norwoodScale = 3});

  double get survivalRateEstimate => 96.0 + (graftsExtracted < 2000 ? 1.5 : 0);
}
