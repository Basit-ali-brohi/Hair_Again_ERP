enum StockMovementType {
  purchase, sale, adjustment, transfer, stockReturn, consumption, opening;
  String get label => switch (this) {
    StockMovementType.purchase    => 'Purchase',
    StockMovementType.sale        => 'Sale',
    StockMovementType.adjustment  => 'Adjustment',
    StockMovementType.transfer    => 'Transfer',
    StockMovementType.stockReturn => 'Return',
    StockMovementType.consumption => 'Consumption',
    StockMovementType.opening     => 'Opening Stock',
  };
  bool get isIn => this == StockMovementType.purchase ||
      this == StockMovementType.stockReturn ||
      this == StockMovementType.opening ||
      this == StockMovementType.adjustment;
}

enum StockCategory {
  hairProduct, chemical, equipment, consumable, patch, medicine, office, other;
  String get label => switch (this) {
    StockCategory.hairProduct  => 'Hair Product',
    StockCategory.chemical     => 'Chemical / Solution',
    StockCategory.equipment    => 'Equipment / Tool',
    StockCategory.consumable   => 'Consumable',
    StockCategory.patch        => 'Patch / Prosthetic',
    StockCategory.medicine     => 'Medicine',
    StockCategory.office       => 'Office Supply',
    StockCategory.other        => 'Other',
  };
}

class StockItem {
  String id, name, sku, unit, location, vendorId, vendorName;
  StockCategory category;
  double costPrice, sellingPrice;
  int currentQty, reorderLevel, maxLevel;
  bool isActive;
  DateTime lastUpdated;

  StockItem({
    required this.id, required this.name, required this.sku,
    required this.unit, required this.category,
    this.costPrice = 0, this.sellingPrice = 0,
    required this.currentQty, this.reorderLevel = 5, this.maxLevel = 100,
    this.location = '', this.isActive = true,
    required this.lastUpdated, this.vendorId = '', this.vendorName = '',
  });

  bool get isLow => currentQty > 0 && currentQty <= reorderLevel;
  bool get isOut  => currentQty <= 0;
  double get stockValue => currentQty * costPrice;
}

class StockMovement {
  String id, itemId, itemName, unit, reference, performedBy, notes;
  StockMovementType type;
  int qty;
  double unitCost;
  DateTime date;

  StockMovement({
    required this.id, required this.itemId, required this.itemName,
    required this.unit, required this.type, required this.qty,
    this.unitCost = 0, this.reference = '',
    required this.performedBy, this.notes = '',
    required this.date,
  });
}

class AuditLine {
  String itemId, itemName, unit;
  int systemQty, physicalQty;
  String notes;

  AuditLine({
    required this.itemId, required this.itemName, required this.unit,
    required this.systemQty, this.physicalQty = 0, this.notes = '',
  });
  int get variance => physicalQty - systemQty;
}

class StockAudit {
  String id, conductedBy, notes;
  DateTime auditDate;
  List<AuditLine> lines;
  bool completed;

  StockAudit({
    required this.id, required this.conductedBy, this.notes = '',
    required this.auditDate, required this.lines, this.completed = false,
  });
}
