import 'package:uuid/uuid.dart';
import 'bill.dart';
import 'claim_status.dart';

class Claim {
  final String id;
  final String patientName;
  final String patientId;
  final String hospitalName;
  final DateTime admissionDate;
  final DateTime? dischargeDate;
  final ClaimStatus status;
  final List<Bill> bills;
  final double advances;
  final double settlements;
  final DateTime createdAt;
  final DateTime updatedAt;

  Claim({
    String? id,
    required this.patientName,
    required this.patientId,
    required this.hospitalName,
    required this.admissionDate,
    this.dischargeDate,
    this.status = ClaimStatus.draft,
    List<Bill>? bills,
    this.advances = 0.0,
    this.settlements = 0.0,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        bills = bills ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Calculated fields
  double get totalBillAmount {
    return bills.fold(0.0, (sum, bill) => sum + bill.amount);
  }

  double get pendingAmount {
    return totalBillAmount - advances - settlements;
  }

  double get totalPaid {
    return advances + settlements;
  }

  Claim copyWith({
    String? patientName,
    String? patientId,
    String? hospitalName,
    DateTime? admissionDate,
    DateTime? dischargeDate,
    ClaimStatus? status,
    List<Bill>? bills,
    double? advances,
    double? settlements,
  }) {
    return Claim(
      id: id,
      patientName: patientName ?? this.patientName,
      patientId: patientId ?? this.patientId,
      hospitalName: hospitalName ?? this.hospitalName,
      admissionDate: admissionDate ?? this.admissionDate,
      dischargeDate: dischargeDate ?? this.dischargeDate,
      status: status ?? this.status,
      bills: bills ?? this.bills,
      advances: advances ?? this.advances,
      settlements: settlements ?? this.settlements,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientName': patientName,
      'patientId': patientId,
      'hospitalName': hospitalName,
      'admissionDate': admissionDate.toIso8601String(),
      'dischargeDate': dischargeDate?.toIso8601String(),
      'status': status.name,
      'bills': bills.map((bill) => bill.toJson()).toList(),
      'advances': advances,
      'settlements': settlements,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Claim.fromJson(Map<String, dynamic> json) {
    return Claim(
      id: json['id'],
      patientName: json['patientName'],
      patientId: json['patientId'],
      hospitalName: json['hospitalName'],
      admissionDate: DateTime.parse(json['admissionDate']),
      dischargeDate: json['dischargeDate'] != null
          ? DateTime.parse(json['dischargeDate'])
          : null,
      status: ClaimStatus.values.firstWhere((e) => e.name == json['status']),
      bills: (json['bills'] as List).map((b) => Bill.fromJson(b)).toList(),
      advances: json['advances'],
      settlements: json['settlements'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
