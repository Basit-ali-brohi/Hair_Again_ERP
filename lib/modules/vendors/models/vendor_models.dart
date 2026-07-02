// modules/vendors/models — Vendor directory, purchase orders & goods receiving.

enum POStatus { draft, sent, received, partial, cancelled }
extension POStatusX on POStatus {
  String get label => switch (this) {
    POStatus.draft => 'Draft', POStatus.sent => 'Sent',
    POStatus.received => 'Received', POStatus.partial => 'Partial',
    POStatus.cancelled => 'Cancelled',
  };
}

class Vendor {
  String id, name, contactPerson, phone, email, address, city, category;
  double totalPurchases, outstandingBalance;
  bool isActive;
  String paymentTerms, taxId, notes;
  Vendor({required this.id, required this.name, required this.contactPerson,
    required this.phone, required this.email, required this.address,
    required this.city, required this.category,
    this.totalPurchases = 0, this.outstandingBalance = 0,
    this.isActive = true, this.paymentTerms = 'Net 30',
    this.taxId = '', this.notes = ''});
}

class POItem {
  String name, unit;
  int qty, receivedQty;
  double unitPrice;
  POItem({required this.name, required this.unit, required this.qty,
    required this.unitPrice, this.receivedQty = 0});
  double get total => qty * unitPrice;
}

class PurchaseOrder {
  final String id;
  String vendorId, vendorName, notes, createdBy;
  final List<POItem> items;
  DateTime orderDate;
  DateTime? expectedDate;
  POStatus status;
  PurchaseOrder({required this.id, required this.vendorId, required this.vendorName,
    required this.items, required this.orderDate, required this.createdBy,
    this.expectedDate, this.status = POStatus.draft, this.notes = ''});
  double get totalAmount => items.fold(0, (s, i) => s + i.total);
}

class ReceivedItem {
  final String name;
  final int orderedQty, receivedQty;
  final String condition; // 'good', 'damaged', 'missing'
  ReceivedItem({required this.name, required this.orderedQty,
    required this.receivedQty, this.condition = 'good'});
}

class GoodsReceiving {
  final String id, poId, vendorName, receivedBy;
  final DateTime receivedDate;
  final List<ReceivedItem> items;
  String notes;
  GoodsReceiving({required this.id, required this.poId, required this.vendorName,
    required this.receivedBy, required this.receivedDate,
    required this.items, this.notes = ''});
}
