enum HairTexture { fine, medium, coarse }

extension HairTextureX on HairTexture {
  String get label => switch (this) {
    HairTexture.fine => 'Fine',
    HairTexture.medium => 'Medium',
    HairTexture.coarse => 'Coarse',
  };
}

enum HairType { straight, wavy, curly, coily }

extension HairTypeX on HairType {
  String get label => switch (this) {
    HairType.straight => 'Straight',
    HairType.wavy => 'Wavy',
    HairType.curly => 'Curly',
    HairType.coily => 'Coily',
  };
}

enum ScalpCondition { healthy, dry, oily, dandruff, inflamed, sensitive, psoriasis, seborrheic }

extension ScalpConditionX on ScalpCondition {
  String get label => switch (this) {
    ScalpCondition.healthy => 'Healthy',
    ScalpCondition.dry => 'Dry',
    ScalpCondition.oily => 'Oily',
    ScalpCondition.dandruff => 'Dandruff',
    ScalpCondition.inflamed => 'Inflamed',
    ScalpCondition.sensitive => 'Sensitive',
    ScalpCondition.psoriasis => 'Psoriasis',
    ScalpCondition.seborrheic => 'Seborrheic Dermatitis',
  };
}

enum MiniaturationLevel { none, mild, moderate, severe }

extension MiniaturationLevelX on MiniaturationLevel {
  String get label => switch (this) {
    MiniaturationLevel.none => 'None (0%)',
    MiniaturationLevel.mild => 'Mild (< 25%)',
    MiniaturationLevel.moderate => 'Moderate (25–50%)',
    MiniaturationLevel.severe => 'Severe (> 50%)',
  };
}

enum TreatmentPriority { essential, recommended, optional }

extension TreatmentPriorityX on TreatmentPriority {
  String get label => switch (this) {
    TreatmentPriority.essential => 'Essential',
    TreatmentPriority.recommended => 'Recommended',
    TreatmentPriority.optional => 'Optional',
  };
}

class HairAnalysis {
  int norwoodScale; // 1–7
  int? ludwigScale; // 1–3 (female patients)
  HairTexture texture;
  HairType type;
  int density; // 1–5 (1=very sparse, 5=very dense)
  MiniaturationLevel miniaturation;
  String? donorAreaCondition;
  String? hairlineNotes;
  bool hasFamilyHistory;
  String? otherObservations;

  HairAnalysis({
    required this.norwoodScale,
    this.ludwigScale,
    required this.texture,
    required this.type,
    required this.density,
    required this.miniaturation,
    this.donorAreaCondition,
    this.hairlineNotes,
    this.hasFamilyHistory = false,
    this.otherObservations,
  });
}

class ScalpAnalysis {
  ScalpCondition condition;
  int scaliness; // 1–5
  int sebumLevel; // 1=very dry, 5=very oily
  bool hasInfection;
  bool hasScarring;
  bool hasAlopeciaAreata;
  String? bloodCirculationNotes;
  String? otherObservations;

  ScalpAnalysis({
    required this.condition,
    required this.scaliness,
    required this.sebumLevel,
    this.hasInfection = false,
    this.hasScarring = false,
    this.hasAlopeciaAreata = false,
    this.bloodCirculationNotes,
    this.otherObservations,
  });
}

class TreatmentRecommendationItem {
  String treatmentName;
  String description;
  int sessions;
  String interval;
  double estimatedCost;
  TreatmentPriority priority;
  String? notes;

  TreatmentRecommendationItem({
    required this.treatmentName,
    required this.description,
    required this.sessions,
    required this.interval,
    required this.estimatedCost,
    required this.priority,
    this.notes,
  });
}

class ConsultationRecord {
  final String id;
  final String patientId;
  final String patientName;
  final String patientPhone;
  final String patientGender;
  final int? patientAge;
  String doctorName;
  DateTime consultationDate;
  String? chiefComplaint;
  String? medicalHistory;
  String? currentMedications;
  String? allergies;
  HairAnalysis? hairAnalysis;
  ScalpAnalysis? scalpAnalysis;
  final List<TreatmentRecommendationItem> recommendations;
  String? doctorNotes;
  DateTime? followUpDate;
  bool isConverted;
  String? convertedToPatientId;

  ConsultationRecord({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.patientPhone,
    required this.patientGender,
    this.patientAge,
    required this.doctorName,
    required this.consultationDate,
    this.chiefComplaint,
    this.medicalHistory,
    this.currentMedications,
    this.allergies,
    this.hairAnalysis,
    this.scalpAnalysis,
    required this.recommendations,
    this.doctorNotes,
    this.followUpDate,
    this.isConverted = false,
    this.convertedToPatientId,
  });

  double get totalEstimatedCost =>
      recommendations.fold(0.0, (s, r) => s + r.estimatedCost);
}
