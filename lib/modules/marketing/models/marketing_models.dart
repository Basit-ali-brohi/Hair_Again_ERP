enum CampaignType { sms, whatsapp, email, push, social }

extension CampaignTypeX on CampaignType {
  String get label => switch (this) {
    CampaignType.sms => 'SMS',
    CampaignType.whatsapp => 'WhatsApp',
    CampaignType.email => 'Email',
    CampaignType.push => 'Push Notification',
    CampaignType.social => 'Social Media',
  };
}

enum CampaignStatus { draft, scheduled, active, completed, paused, cancelled }

extension CampaignStatusX on CampaignStatus {
  String get label => switch (this) {
    CampaignStatus.draft => 'Draft',
    CampaignStatus.scheduled => 'Scheduled',
    CampaignStatus.active => 'Active',
    CampaignStatus.completed => 'Completed',
    CampaignStatus.paused => 'Paused',
    CampaignStatus.cancelled => 'Cancelled',
  };
}

enum CampaignTarget {
  allPatients, activePatients, hotLeads, coldLeads, memberships, dormantCustomers, specific
}

extension CampaignTargetX on CampaignTarget {
  String get label => switch (this) {
    CampaignTarget.allPatients => 'All Patients',
    CampaignTarget.activePatients => 'Active Patients',
    CampaignTarget.hotLeads => 'Hot Leads',
    CampaignTarget.coldLeads => 'Cold Leads',
    CampaignTarget.memberships => 'Membership Holders',
    CampaignTarget.dormantCustomers => 'Dormant (>60 days)',
    CampaignTarget.specific => 'Specific List',
  };
}

enum DiscountType { percentage, fixed }

extension DiscountTypeX on DiscountType {
  String get label => switch (this) {
    DiscountType.percentage => 'Percentage (%)',
    DiscountType.fixed => 'Fixed Amount (PKR)',
  };
}

class Campaign {
  final String id;
  String name;
  CampaignType type;
  CampaignStatus status;
  CampaignTarget target;
  String message;
  double budget;
  int sentCount;
  int deliveredCount;
  int readCount;
  int responseCount;
  DateTime? scheduledAt;
  final DateTime createdAt;

  Campaign({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    required this.target,
    required this.message,
    required this.budget,
    this.sentCount = 0,
    this.deliveredCount = 0,
    this.readCount = 0,
    this.responseCount = 0,
    this.scheduledAt,
    required this.createdAt,
  });

  double get deliveryRate => sentCount == 0 ? 0 : deliveredCount / sentCount;
  double get readRate => deliveredCount == 0 ? 0 : readCount / deliveredCount;
  double get responseRate => deliveredCount == 0 ? 0 : responseCount / deliveredCount;
}

class Coupon {
  final String id;
  String code;
  String description;
  DiscountType discountType;
  double discountValue;
  double minimumOrderAmount;
  double? maximumDiscountAmount;
  DateTime expiryDate;
  int usageLimit;
  int usageCount;
  bool isActive;

  Coupon({
    required this.id,
    required this.code,
    required this.description,
    required this.discountType,
    required this.discountValue,
    this.minimumOrderAmount = 0,
    this.maximumDiscountAmount,
    required this.expiryDate,
    required this.usageLimit,
    this.usageCount = 0,
    this.isActive = true,
  });

  bool get isExpired => DateTime.now().isAfter(expiryDate);
  bool get isUsageLimitReached => usageCount >= usageLimit;
  bool get isValid => isActive && !isExpired && !isUsageLimitReached;

  String get discountLabel => discountType == DiscountType.percentage
      ? '${discountValue.toInt()}% Off'
      : 'PKR ${discountValue.toInt()} Off';
}

class Promotion {
  final String id;
  String name;
  String description;
  DiscountType discountType;
  double discountValue;
  List<String> applicableServices;
  DateTime startDate;
  DateTime endDate;
  bool isActive;
  String createdBy;
  final DateTime createdAt;

  Promotion({
    required this.id,
    required this.name,
    required this.description,
    required this.discountType,
    required this.discountValue,
    required this.applicableServices,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
    required this.createdBy,
    required this.createdAt,
  });

  bool get isExpired => DateTime.now().isAfter(endDate);

  String get discountLabel => discountType == DiscountType.percentage
      ? '${discountValue.toInt()}%'
      : 'PKR ${discountValue.toInt()}';
}
