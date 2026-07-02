enum IncomeCategory {
  treatmentRevenue, productSales, membership, consultationFee, depositReceived, refundReceived, other
}

extension IncomeCategoryX on IncomeCategory {
  String get label => switch (this) {
    IncomeCategory.treatmentRevenue => 'Treatment Revenue',
    IncomeCategory.productSales => 'Product Sales',
    IncomeCategory.membership => 'Membership Fee',
    IncomeCategory.consultationFee => 'Consultation Fee',
    IncomeCategory.depositReceived => 'Advance Deposit',
    IncomeCategory.refundReceived => 'Refund Received',
    IncomeCategory.other => 'Other Income',
  };
}

enum ExpenseCategory {
  salaries, rent, utilities, supplies, marketing, equipment, maintenance,
  travel, tax, insurance, computerIT, bankCharges, other
}

extension ExpenseCategoryX on ExpenseCategory {
  String get label => switch (this) {
    ExpenseCategory.salaries => 'Salaries & Wages',
    ExpenseCategory.rent => 'Rent',
    ExpenseCategory.utilities => 'Utilities',
    ExpenseCategory.supplies => 'Medical Supplies',
    ExpenseCategory.marketing => 'Marketing & Advertising',
    ExpenseCategory.equipment => 'Equipment Purchase',
    ExpenseCategory.maintenance => 'Repair & Maintenance',
    ExpenseCategory.travel => 'Travel & Transport',
    ExpenseCategory.tax => 'Tax & Government Fees',
    ExpenseCategory.insurance => 'Insurance',
    ExpenseCategory.computerIT => 'IT & Software',
    ExpenseCategory.bankCharges => 'Bank Charges',
    ExpenseCategory.other => 'Other Expense',
  };
}

enum PaymentMethod { cash, bankTransfer, card, cheque, easypaisa, jazzcash, online }

extension PaymentMethodX on PaymentMethod {
  String get label => switch (this) {
    PaymentMethod.cash => 'Cash',
    PaymentMethod.bankTransfer => 'Bank Transfer',
    PaymentMethod.card => 'Card (Debit/Credit)',
    PaymentMethod.cheque => 'Cheque',
    PaymentMethod.easypaisa => 'Easypaisa',
    PaymentMethod.jazzcash => 'JazzCash',
    PaymentMethod.online => 'Online Transfer',
  };
}

class IncomeEntry {
  final String id;
  DateTime date;
  IncomeCategory category;
  double amount;
  PaymentMethod paymentMethod;
  String? referenceNo;
  String? receivedFrom;
  String? description;
  String? invoiceId;
  bool isVerified;

  IncomeEntry({
    required this.id,
    required this.date,
    required this.category,
    required this.amount,
    required this.paymentMethod,
    this.referenceNo,
    this.receivedFrom,
    this.description,
    this.invoiceId,
    this.isVerified = false,
  });

  Map<String, dynamic> toJson() => {'id': id, 'date': date.toIso8601String(), 'category': category.name, 'amount': amount, 'paymentMethod': paymentMethod.name, 'referenceNo': referenceNo, 'receivedFrom': receivedFrom, 'description': description, 'invoiceId': invoiceId, 'isVerified': isVerified};

  factory IncomeEntry.fromJson(Map<String, dynamic> j) => IncomeEntry(
    id: j['id'] as String, date: DateTime.parse(j['date'] as String),
    category: IncomeCategory.values.byName(j['category'] as String? ?? 'other'),
    amount: (j['amount'] as num).toDouble(),
    paymentMethod: PaymentMethod.values.byName(j['paymentMethod'] as String? ?? 'cash'),
    referenceNo: j['referenceNo'] as String?, receivedFrom: j['receivedFrom'] as String?,
    description: j['description'] as String?, invoiceId: j['invoiceId'] as String?,
    isVerified: j['isVerified'] as bool? ?? false,
  );
}

class ExpenseEntry {
  final String id;
  DateTime date;
  ExpenseCategory category;
  double amount;
  PaymentMethod paymentMethod;
  String? vendor;
  String? invoiceNo;
  String? description;
  bool isApproved;
  String? approvedBy;
  String? receiptUrl;

  ExpenseEntry({
    required this.id,
    required this.date,
    required this.category,
    required this.amount,
    required this.paymentMethod,
    this.vendor,
    this.invoiceNo,
    this.description,
    this.isApproved = false,
    this.approvedBy,
    this.receiptUrl,
  });

  Map<String, dynamic> toJson() => {'id': id, 'date': date.toIso8601String(), 'category': category.name, 'amount': amount, 'paymentMethod': paymentMethod.name, 'vendor': vendor, 'invoiceNo': invoiceNo, 'description': description, 'isApproved': isApproved, 'approvedBy': approvedBy};

  factory ExpenseEntry.fromJson(Map<String, dynamic> j) => ExpenseEntry(
    id: j['id'] as String, date: DateTime.parse(j['date'] as String),
    category: ExpenseCategory.values.byName(j['category'] as String? ?? 'other'),
    amount: (j['amount'] as num).toDouble(),
    paymentMethod: PaymentMethod.values.byName(j['paymentMethod'] as String? ?? 'cash'),
    vendor: j['vendor'] as String?, invoiceNo: j['invoiceNo'] as String?,
    description: j['description'] as String?,
    isApproved: j['isApproved'] as bool? ?? false,
    approvedBy: j['approvedBy'] as String?,
  );
}

class BankAccount {
  final String id;
  String bankName;
  String accountTitle;
  String accountNumber;
  String branchName;
  String iban;
  double openingBalance;
  double currentBalance;
  String currency;
  bool isActive;
  bool isPrimary;
  String? notes;

  BankAccount({
    required this.id,
    required this.bankName,
    required this.accountTitle,
    required this.accountNumber,
    required this.branchName,
    required this.iban,
    required this.openingBalance,
    required this.currentBalance,
    this.currency = 'PKR',
    this.isActive = true,
    this.isPrimary = false,
    this.notes,
  });
}

class BankTransaction {
  final String id;
  final String bankAccountId;
  DateTime date;
  String type; // credit, debit
  double amount;
  double balanceAfter;
  String description;
  String? referenceNo;
  String? category;

  BankTransaction({
    required this.id,
    required this.bankAccountId,
    required this.date,
    required this.type,
    required this.amount,
    required this.balanceAfter,
    required this.description,
    this.referenceNo,
    this.category,
  });
}

class CashBookEntry {
  final String id;
  DateTime date;
  String type; // receipt, payment
  double amount;
  String description;
  String? referenceNo;
  String? party;
  double runningBalance;

  CashBookEntry({
    required this.id,
    required this.date,
    required this.type,
    required this.amount,
    required this.description,
    this.referenceNo,
    this.party,
    required this.runningBalance,
  });
}

class JournalLine {
  String account;
  String? description;
  double debit;
  double credit;

  JournalLine({
    required this.account,
    this.description,
    this.debit = 0,
    this.credit = 0,
  });
}

class JournalEntry {
  final String id;
  DateTime date;
  String description;
  String? referenceNo;
  String voucherType; // General, Payment, Receipt, Contra
  final List<JournalLine> lines;
  bool isPosted;
  String createdBy;

  double get totalDebit => lines.fold(0.0, (s, l) => s + l.debit);
  double get totalCredit => lines.fold(0.0, (s, l) => s + l.credit);
  bool get isBalanced => (totalDebit - totalCredit).abs() < 0.01;

  JournalEntry({
    required this.id,
    required this.date,
    required this.description,
    this.referenceNo,
    required this.voucherType,
    required this.lines,
    this.isPosted = false,
    required this.createdBy,
  });
}
