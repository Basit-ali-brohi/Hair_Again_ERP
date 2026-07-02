// modules/loyalty/models — Loyalty points, rewards & referral program models.

enum LoyaltyTier { bronze, silver, gold, platinum }
extension LoyaltyTierX on LoyaltyTier {
  String get label => switch (this) {
    LoyaltyTier.bronze => 'Bronze', LoyaltyTier.silver => 'Silver',
    LoyaltyTier.gold => 'Gold', LoyaltyTier.platinum => 'Platinum',
  };
  int get minPoints => switch (this) {
    LoyaltyTier.bronze => 0, LoyaltyTier.silver => 500,
    LoyaltyTier.gold => 2000, LoyaltyTier.platinum => 5000,
  };
}

enum ReferralStatus { pending, qualified, rewarded, expired }
extension ReferralStatusX on ReferralStatus {
  String get label => switch (this) {
    ReferralStatus.pending => 'Pending', ReferralStatus.qualified => 'Qualified',
    ReferralStatus.rewarded => 'Rewarded', ReferralStatus.expired => 'Expired',
  };
}

class PointTransaction {
  final String id, type, description;
  final int points;
  final DateTime date;
  final String? referenceId;
  PointTransaction({required this.id, required this.type, required this.description,
    required this.points, required this.date, this.referenceId});
  bool get isEarned => type == 'earned';
}

class LoyaltyAccount {
  final String id, customerId, customerName, customerPhone;
  int totalPoints, redeemedPoints;
  LoyaltyTier tier;
  final List<PointTransaction> transactions;
  LoyaltyAccount({required this.id, required this.customerId,
    required this.customerName, required this.customerPhone,
    this.totalPoints = 0, this.redeemedPoints = 0,
    this.tier = LoyaltyTier.bronze, required this.transactions});

  int get availablePoints => totalPoints - redeemedPoints;

  void recalcTier() {
    if (totalPoints >= LoyaltyTier.platinum.minPoints) {
      tier = LoyaltyTier.platinum;
    } else if (totalPoints >= LoyaltyTier.gold.minPoints) {
      tier = LoyaltyTier.gold;
    } else if (totalPoints >= LoyaltyTier.silver.minPoints) {
      tier = LoyaltyTier.silver;
    } else {
      tier = LoyaltyTier.bronze;
    }
  }
}

class Reward {
  String id, name, description, rewardType;
  int pointsRequired;
  double value;
  bool isActive;
  Reward({required this.id, required this.name, required this.description,
    required this.rewardType, required this.pointsRequired,
    required this.value, this.isActive = true});
  String get typeLabel => switch (rewardType) {
    'discount' => 'Discount', 'free_service' => 'Free Service',
    'gift' => 'Gift Item', 'cashback' => 'Cashback', _ => rewardType,
  };
}

class Referral {
  final String id, referrerId, referrerName, refereePhone;
  String refereeName;
  ReferralStatus status;
  int pointsEarned;
  final DateTime createdAt;
  DateTime? qualifiedAt;
  Referral({required this.id, required this.referrerId, required this.referrerName,
    required this.refereeName, required this.refereePhone,
    this.status = ReferralStatus.pending, this.pointsEarned = 0,
    required this.createdAt, this.qualifiedAt});
}
