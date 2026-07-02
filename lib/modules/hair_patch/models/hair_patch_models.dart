enum PatchType {
  lace, monofilament, silicon, polyurethane, hybrid;
  String get label => switch (this) {
    PatchType.lace           => 'Lace Base',
    PatchType.monofilament   => 'Monofilament',
    PatchType.silicon        => 'Silicon Base',
    PatchType.polyurethane   => 'Polyurethane',
    PatchType.hybrid         => 'Hybrid Base',
  };
}

enum HairOrigin {
  synthetic, human, remyHuman, europeanHuman;
  String get label => switch (this) {
    HairOrigin.synthetic      => 'Synthetic',
    HairOrigin.human          => 'Human Hair',
    HairOrigin.remyHuman      => 'Remy Human',
    HairOrigin.europeanHuman  => 'European Human',
  };
}

enum PatchOrderStatus {
  pending, measuring, production, qualityCheck, ready, delivered, cancelled;
  String get label => switch (this) {
    PatchOrderStatus.pending       => 'Pending',
    PatchOrderStatus.measuring     => 'Measuring',
    PatchOrderStatus.production    => 'In Production',
    PatchOrderStatus.qualityCheck  => 'Quality Check',
    PatchOrderStatus.ready         => 'Ready to Deliver',
    PatchOrderStatus.delivered     => 'Delivered',
    PatchOrderStatus.cancelled     => 'Cancelled',
  };
}

enum FittingStatus {
  scheduled, completed, rescheduled, noShow;
  String get label => switch (this) {
    FittingStatus.scheduled   => 'Scheduled',
    FittingStatus.completed   => 'Completed',
    FittingStatus.rescheduled => 'Rescheduled',
    FittingStatus.noShow      => 'No Show',
  };
}

enum MaintenanceType {
  cleaning, adhesiveReplacement, adjustment, restyling, fullReplacement;
  String get label => switch (this) {
    MaintenanceType.cleaning             => 'Cleaning & Wash',
    MaintenanceType.adhesiveReplacement  => 'Adhesive Replacement',
    MaintenanceType.adjustment           => 'Size Adjustment',
    MaintenanceType.restyling            => 'Restyling / Cut',
    MaintenanceType.fullReplacement      => 'Full Replacement',
  };
}

class HairPatchItem {
  String id, name, sku, description;
  PatchType type;
  HairOrigin hairOrigin;
  String baseColor, hairDensity, hairTexture;
  double lengthCm, widthCm, price;
  int stockQty;
  bool isActive;
  List<String> features;
  DateTime addedOn;

  HairPatchItem({
    required this.id, required this.name, required this.sku,
    this.description = '', required this.type, required this.hairOrigin,
    required this.baseColor, this.hairDensity = 'Medium',
    this.hairTexture = 'Straight',
    required this.lengthCm, required this.widthCm,
    required this.price, this.stockQty = 0, this.isActive = true,
    this.features = const [], required this.addedOn,
  });
}

class PatchMeasurement {
  double frontToBack, earToEar, circumference;
  String hairlineShape, colorCode, textureMatch, densityPreference, additionalNotes;

  PatchMeasurement({
    this.frontToBack = 0, this.earToEar = 0, this.circumference = 0,
    this.hairlineShape = 'Natural', this.colorCode = '#1B1B1B',
    this.textureMatch = 'Straight', this.densityPreference = 'Medium',
    this.additionalNotes = '',
  });
}

class PatchOrder {
  String id, patientId, patientName, patientPhone;
  String? patchId, patchName;
  bool isCustom;
  PatchMeasurement measurement;
  double advancePaid, totalCost;
  DateTime orderDate;
  DateTime? expectedDelivery;
  PatchOrderStatus status;
  String notes, assignedTo;

  PatchOrder({
    required this.id, required this.patientId, required this.patientName,
    required this.patientPhone, this.patchId, this.patchName,
    this.isCustom = false, required this.measurement,
    this.advancePaid = 0, required this.totalCost,
    required this.orderDate, this.expectedDelivery,
    this.status = PatchOrderStatus.pending,
    this.notes = '', this.assignedTo = '',
  });
}

class PatchFitting {
  String id, patientId, patientName, patientPhone;
  String? orderId, patchName;
  DateTime scheduledDate;
  FittingStatus status;
  String technicianName, notes;
  bool followUpNeeded;
  DateTime? completedAt;

  PatchFitting({
    required this.id, required this.patientId, required this.patientName,
    required this.patientPhone, this.orderId, this.patchName,
    required this.scheduledDate, this.status = FittingStatus.scheduled,
    this.technicianName = '', this.notes = '',
    this.followUpNeeded = false, this.completedAt,
  });
}

class PatchMaintenance {
  String id, patientId, patientName, patientPhone;
  String? patchName;
  MaintenanceType type;
  DateTime scheduledDate;
  bool completed;
  String technicianName, notes;
  double cost;
  DateTime? completedAt;

  PatchMaintenance({
    required this.id, required this.patientId, required this.patientName,
    required this.patientPhone, this.patchName,
    required this.type, required this.scheduledDate,
    this.completed = false, this.technicianName = '',
    this.notes = '', this.cost = 0, this.completedAt,
  });
}
