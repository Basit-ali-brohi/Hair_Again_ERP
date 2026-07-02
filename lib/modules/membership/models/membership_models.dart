// modules/membership/models — Membership plans & customer memberships.

enum MembershipStatus { active, expired, suspended, cancelled }
extension MembershipStatusX on MembershipStatus {
  String get label => switch (this) {
    MembershipStatus.active => 'Active', MembershipStatus.expired => 'Expired',
    MembershipStatus.suspended => 'Suspended', MembershipStatus.cancelled => 'Cancelled',
  };
}

class MembershipPlan {
  String id, name, description;
  double price;
  int durationMonths, maxSessions;
  double discountPercentage;
  List<String> benefits;
  bool isActive;
  String colorTag;
  MembershipPlan({required this.id, required this.name, required this.description,
    required this.price, required this.durationMonths, required this.maxSessions,
    required this.discountPercentage, required this.benefits, required this.colorTag,
    this.isActive = true});
}

class CustomerMembership {
  final String id, customerId, customerName, customerPhone;
  String planId, planName;
  DateTime startDate, endDate;
  MembershipStatus status;
  int sessionsUsed, sessionsTotal;
  double amountPaid;
  String notes;
  CustomerMembership({required this.id, required this.customerId,
    required this.customerName, required this.customerPhone,
    required this.planId, required this.planName,
    required this.startDate, required this.endDate,
    required this.sessionsTotal, required this.amountPaid,
    this.status = MembershipStatus.active, this.sessionsUsed = 0, this.notes = ''});

  int get sessionsRemaining => sessionsTotal - sessionsUsed;
  bool get isExpired => DateTime.now().isAfter(endDate);
  double get usagePct => sessionsTotal == 0 ? 0 : sessionsUsed / sessionsTotal;
}
