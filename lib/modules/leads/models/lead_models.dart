enum LeadSource {
  instagram, facebook, whatsapp, referral, walkIn, google, youtube, tiktok, phone, event, other
}

extension LeadSourceX on LeadSource {
  String get label => switch (this) {
    LeadSource.instagram => 'Instagram',
    LeadSource.facebook => 'Facebook',
    LeadSource.whatsapp => 'WhatsApp',
    LeadSource.referral => 'Referral',
    LeadSource.walkIn => 'Walk-in',
    LeadSource.google => 'Google',
    LeadSource.youtube => 'YouTube',
    LeadSource.tiktok => 'TikTok',
    LeadSource.phone => 'Phone Call',
    LeadSource.event => 'Event / Expo',
    LeadSource.other => 'Other',
  };
}

enum LeadPriority { hot, warm, cold }

extension LeadPriorityX on LeadPriority {
  String get label => switch (this) {
    LeadPriority.hot => 'Hot',
    LeadPriority.warm => 'Warm',
    LeadPriority.cold => 'Cold',
  };
}

enum LeadStage {
  newLead, contacted, consultationBooked, proposalSent, negotiation, converted, lost
}

extension LeadStageX on LeadStage {
  String get label => switch (this) {
    LeadStage.newLead => 'New Lead',
    LeadStage.contacted => 'Contacted',
    LeadStage.consultationBooked => 'Consultation Booked',
    LeadStage.proposalSent => 'Proposal Sent',
    LeadStage.negotiation => 'Negotiation',
    LeadStage.converted => 'Converted',
    LeadStage.lost => 'Lost',
  };
}

enum CallType { inbound, outbound }

extension CallTypeX on CallType {
  String get label => this == CallType.inbound ? 'Inbound' : 'Outbound';
}

enum CallStatus { answered, missed, voicemail, busy }

extension CallStatusX on CallStatus {
  String get label => switch (this) {
    CallStatus.answered => 'Answered',
    CallStatus.missed => 'Missed',
    CallStatus.voicemail => 'Voicemail',
    CallStatus.busy => 'Busy',
  };
}

class CallLog {
  final String id;
  final String leadId;
  final DateTime dateTime;
  final CallType type;
  final CallStatus status;
  final int durationSeconds;
  final String calledBy;
  String? notes;

  String get durationLabel {
    if (durationSeconds <= 0) return '--';
    final m = durationSeconds ~/ 60;
    final s = durationSeconds % 60;
    return m > 0 ? '${m}m ${s}s' : '${s}s';
  }

  CallLog({
    required this.id,
    required this.leadId,
    required this.dateTime,
    required this.type,
    required this.status,
    required this.durationSeconds,
    required this.calledBy,
    this.notes,
  });
}

class FollowUp {
  final String id;
  final String leadId;
  DateTime scheduledAt;
  String type; // Call, WhatsApp, Email, Visit
  String notes;
  bool completed;
  String? outcome;

  FollowUp({
    required this.id,
    required this.leadId,
    required this.scheduledAt,
    required this.type,
    required this.notes,
    this.completed = false,
    this.outcome,
  });
}

class Lead {
  final String id;
  String name;
  String phone;
  String? whatsapp;
  String? email;
  String? city;
  int? age;
  String? gender;
  LeadSource source;
  String serviceInterest;
  String? budgetRange;
  LeadPriority priority;
  LeadStage stage;
  String? assignedTo;
  DateTime? followUpDate;
  String? notes;
  final DateTime createdAt;
  DateTime updatedAt;
  final List<CallLog> callLogs;
  final List<FollowUp> followUps;
  String? lostReason;

  Lead({
    required this.id,
    required this.name,
    required this.phone,
    this.whatsapp,
    this.email,
    this.city,
    this.age,
    this.gender,
    required this.source,
    required this.serviceInterest,
    this.budgetRange,
    required this.priority,
    required this.stage,
    this.assignedTo,
    this.followUpDate,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    required this.callLogs,
    required this.followUps,
    this.lostReason,
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'phone': phone, 'whatsapp': whatsapp, 'email': email,
    'city': city, 'age': age, 'gender': gender, 'source': source.name,
    'serviceInterest': serviceInterest, 'budgetRange': budgetRange,
    'priority': priority.name, 'stage': stage.name, 'assignedTo': assignedTo,
    'followUpDate': followUpDate?.toIso8601String(), 'notes': notes,
    'createdAt': createdAt.toIso8601String(), 'updatedAt': updatedAt.toIso8601String(),
    'lostReason': lostReason,
  };

  factory Lead.fromJson(Map<String, dynamic> j) => Lead(
    id: j['id'] as String, name: j['name'] as String, phone: j['phone'] as String,
    whatsapp: j['whatsapp'] as String?, email: j['email'] as String?,
    city: j['city'] as String?, age: j['age'] as int?, gender: j['gender'] as String?,
    source: LeadSource.values.byName(j['source'] as String? ?? 'other'),
    serviceInterest: j['serviceInterest'] as String,
    budgetRange: j['budgetRange'] as String?,
    priority: LeadPriority.values.byName(j['priority'] as String? ?? 'warm'),
    stage: LeadStage.values.byName(j['stage'] as String? ?? 'newLead'),
    assignedTo: j['assignedTo'] as String?,
    followUpDate: j['followUpDate'] != null ? DateTime.parse(j['followUpDate'] as String) : null,
    notes: j['notes'] as String?,
    createdAt: DateTime.parse(j['createdAt'] as String),
    updatedAt: DateTime.parse(j['updatedAt'] as String),
    callLogs: const [], followUps: const [],
    lostReason: j['lostReason'] as String?,
  );
}
