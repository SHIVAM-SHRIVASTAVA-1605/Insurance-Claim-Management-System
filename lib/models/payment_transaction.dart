import 'package:uuid/uuid.dart';

enum PaymentType { advance, settlement }

enum PaymentMethod { cash, card, bankTransfer, insurance, cheque, other }

extension PaymentMethodExtension on PaymentMethod {
  String get displayName {
    switch (this) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.card:
        return 'Card';
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
      case PaymentMethod.insurance:
        return 'Insurance';
      case PaymentMethod.cheque:
        return 'Cheque';
      case PaymentMethod.other:
        return 'Other';
    }
  }
}

class PaymentTransaction {
  final String id;
  final double amount;
  final PaymentType type;
  final PaymentMethod method;
  final DateTime date;
  final String? notes;

  PaymentTransaction({
    String? id,
    required this.amount,
    required this.type,
    required this.method,
    DateTime? date,
    this.notes,
  })  : id = id ?? const Uuid().v4(),
        date = date ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'type': type.name,
      'method': method.name,
      'date': date.toIso8601String(),
      'notes': notes,
    };
  }

  factory PaymentTransaction.fromJson(Map<String, dynamic> json) {
    return PaymentTransaction(
      id: json['id'],
      amount: json['amount'],
      type: PaymentType.values.firstWhere((e) => e.name == json['type']),
      method: PaymentMethod.values.firstWhere((e) => e.name == json['method']),
      date: DateTime.parse(json['date']),
      notes: json['notes'],
    );
  }
}
