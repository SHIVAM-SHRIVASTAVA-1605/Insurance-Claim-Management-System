import 'package:uuid/uuid.dart';

class Bill {
  final String id;
  final String description;
  final double amount;
  final DateTime date;
  final String category;

  Bill({
    String? id,
    required this.description,
    required this.amount,
    required this.date,
    required this.category,
  }) : id = id ?? const Uuid().v4();

  Bill copyWith({
    String? description,
    double? amount,
    DateTime? date,
    String? category,
  }) {
    return Bill(
      id: id,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      category: category ?? this.category,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category,
    };
  }

  factory Bill.fromJson(Map<String, dynamic> json) {
    return Bill(
      id: json['id'],
      description: json['description'],
      amount: json['amount'],
      date: DateTime.parse(json['date']),
      category: json['category'],
    );
  }
}
