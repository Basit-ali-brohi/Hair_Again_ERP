// modules/pos_inventory/models — Treatment, Invoice & Inventory domain models.

class Treatment {
  final String id;
  String name;
  double price;
  String category;
  Treatment(this.id, this.name, this.price, this.category);
}

class InvoiceLine {
  final String name;
  int qty;
  final double price;
  InvoiceLine({required this.name, required this.qty, required this.price});
  double get total => qty * price;

  Map<String, dynamic> toJson() => {'name': name, 'qty': qty, 'price': price};
  factory InvoiceLine.fromJson(Map<String, dynamic> j) => InvoiceLine(name: j['name'] as String, qty: j['qty'] as int, price: (j['price'] as num).toDouble());
}

class Invoice {
  final String id;
  final String patientName;
  final List<InvoiceLine> lines;
  double advance;
  double paidExtra;
  final DateTime date;
  Invoice({required this.id, required this.patientName, required this.lines, required this.advance, this.paidExtra = 0, required this.date});
  double get subtotal => lines.fold(0, (s, l) => s + l.total);
  double get totalPaid => advance + paidExtra;
  double get balance => (subtotal - totalPaid).clamp(0, double.infinity);
  bool get isPaid => balance <= 0;

  Map<String, dynamic> toJson() => {
    'id': id, 'patientName': patientName,
    'lines': lines.map((l) => l.toJson()).toList(),
    'advance': advance, 'paidExtra': paidExtra,
    'date': date.toIso8601String(),
  };

  factory Invoice.fromJson(Map<String, dynamic> j) => Invoice(
    id: j['id'] as String, patientName: j['patientName'] as String,
    lines: (j['lines'] as List<dynamic>).map((e) => InvoiceLine.fromJson(e as Map<String, dynamic>)).toList(),
    advance: (j['advance'] as num).toDouble(),
    paidExtra: (j['paidExtra'] as num? ?? 0).toDouble(),
    date: DateTime.parse(j['date'] as String),
  );
}

class InventoryItem {
  final String id;
  String name;
  String category;
  int stock;
  int reorderLevel;
  double price;
  InventoryItem({required this.id, required this.name, required this.category, required this.stock, required this.reorderLevel, required this.price});
  bool get isLow => stock <= reorderLevel;
}
