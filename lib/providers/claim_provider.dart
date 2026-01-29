import 'package:flutter/foundation.dart';
import '../models/claim.dart';
import '../models/bill.dart';
import '../models/claim_status.dart';

class ClaimProvider extends ChangeNotifier {
  final List<Claim> _claims = [];

  List<Claim> get claims => List.unmodifiable(_claims);

  Claim? getClaimById(String id) {
    try {
      return _claims.firstWhere((claim) => claim.id == id);
    } catch (e) {
      return null;
    }
  }

  void addClaim(Claim claim) {
    _claims.add(claim);
    notifyListeners();
  }

  void updateClaim(Claim updatedClaim) {
    final index = _claims.indexWhere((claim) => claim.id == updatedClaim.id);
    if (index != -1) {
      _claims[index] = updatedClaim;
      notifyListeners();
    }
  }

  void deleteClaim(String claimId) {
    _claims.removeWhere((claim) => claim.id == claimId);
    notifyListeners();
  }

  // Bill operations
  void addBillToClaim(String claimId, Bill bill) {
    final claim = getClaimById(claimId);
    if (claim != null) {
      final updatedBills = [...claim.bills, bill];
      updateClaim(claim.copyWith(bills: updatedBills));
    }
  }

  void updateBillInClaim(String claimId, Bill updatedBill) {
    final claim = getClaimById(claimId);
    if (claim != null) {
      final updatedBills = claim.bills.map((bill) {
        return bill.id == updatedBill.id ? updatedBill : bill;
      }).toList();
      updateClaim(claim.copyWith(bills: updatedBills));
    }
  }

  void deleteBillFromClaim(String claimId, String billId) {
    final claim = getClaimById(claimId);
    if (claim != null) {
      final updatedBills =
          claim.bills.where((bill) => bill.id != billId).toList();
      updateClaim(claim.copyWith(bills: updatedBills));
    }
  }

  // Status transitions - Following insurance claim workflow
  bool canTransitionTo(Claim claim, ClaimStatus newStatus) {
    switch (claim.status) {
      case ClaimStatus.draft:
        // Draft can only be submitted
        return newStatus == ClaimStatus.submitted;
      case ClaimStatus.submitted:
        // Submitted can be approved, rejected, or partially settled by insurance
        return newStatus == ClaimStatus.approved ||
            newStatus == ClaimStatus.rejected ||
            newStatus == ClaimStatus.partiallySettled;
      case ClaimStatus.approved:
        // Approved can be settled (full or partial)
        return newStatus == ClaimStatus.partiallySettled ||
            newStatus == ClaimStatus.settled;
      case ClaimStatus.rejected:
        // Rejected is final - cannot change
        return false;
      case ClaimStatus.partiallySettled:
        // Partially settled can only move to fully settled
        return newStatus == ClaimStatus.settled;
      case ClaimStatus.settled:
        // Settled is final - cannot change
        return false;
    }
  }

  // Check if claim can be edited (bills, patient info, etc.)
  bool canEditClaim(Claim claim) {
    // Only draft claims can be edited
    return claim.status == ClaimStatus.draft;
  }

  // Check if financial updates (advances, settlements) are allowed
  bool canUpdateFinancials(Claim claim) {
    // Can update financials for approved or partially settled claims
    return claim.status == ClaimStatus.approved ||
        claim.status == ClaimStatus.partiallySettled;
  }

  void updateClaimStatus(String claimId, ClaimStatus newStatus) {
    final claim = getClaimById(claimId);
    if (claim != null && canTransitionTo(claim, newStatus)) {
      updateClaim(claim.copyWith(status: newStatus));
    }
  }

  void updateAdvances(String claimId, double advances) {
    final claim = getClaimById(claimId);
    if (claim != null) {
      updateClaim(claim.copyWith(advances: advances));
    }
  }

  void updateSettlements(String claimId, double settlements) {
    final claim = getClaimById(claimId);
    if (claim != null) {
      updateClaim(claim.copyWith(settlements: settlements));
    }
  }

  // Statistics
  int get totalClaims => _claims.length;

  int getClaimCountByStatus(ClaimStatus status) {
    return _claims.where((claim) => claim.status == status).length;
  }

  double get totalClaimAmount {
    return _claims.fold(0.0, (sum, claim) => sum + claim.totalBillAmount);
  }

  double get totalPendingAmount {
    return _claims.fold(0.0, (sum, claim) => sum + claim.pendingAmount);
  }

  // Initialize with sample data for demo
  void initializeSampleData() {
    final sampleClaim1 = Claim(
      patientName: 'John Doe',
      patientId: 'P001',
      hospitalName: 'City General Hospital',
      admissionDate: DateTime.now().subtract(const Duration(days: 10)),
      dischargeDate: DateTime.now().subtract(const Duration(days: 3)),
      status: ClaimStatus.submitted,
      bills: [
        Bill(
          description: 'Room Charges',
          amount: 15000,
          date: DateTime.now().subtract(const Duration(days: 9)),
          category: 'Accommodation',
        ),
        Bill(
          description: 'Laboratory Tests',
          amount: 5000,
          date: DateTime.now().subtract(const Duration(days: 8)),
          category: 'Diagnostics',
        ),
        Bill(
          description: 'Consultation Fee',
          amount: 2000,
          date: DateTime.now().subtract(const Duration(days: 10)),
          category: 'Doctor Fee',
        ),
      ],
      advances: 10000,
      settlements: 0,
    );

    final sampleClaim2 = Claim(
      patientName: 'Jane Smith',
      patientId: 'P002',
      hospitalName: 'Metro Care Hospital',
      admissionDate: DateTime.now().subtract(const Duration(days: 5)),
      dischargeDate: DateTime.now().subtract(const Duration(days: 1)),
      status: ClaimStatus.approved,
      bills: [
        Bill(
          description: 'Surgery Charges',
          amount: 50000,
          date: DateTime.now().subtract(const Duration(days: 4)),
          category: 'Surgery',
        ),
        Bill(
          description: 'Anesthesia',
          amount: 8000,
          date: DateTime.now().subtract(const Duration(days: 4)),
          category: 'Surgery',
        ),
        Bill(
          description: 'Post-op Care',
          amount: 12000,
          date: DateTime.now().subtract(const Duration(days: 2)),
          category: 'Treatment',
        ),
      ],
      advances: 20000,
      settlements: 30000,
    );

    final sampleClaim3 = Claim(
      patientName: 'Robert Johnson',
      patientId: 'P003',
      hospitalName: 'Sunshine Medical Center',
      admissionDate: DateTime.now().subtract(const Duration(days: 2)),
      status: ClaimStatus.draft,
      bills: [
        Bill(
          description: 'Emergency Room',
          amount: 8000,
          date: DateTime.now().subtract(const Duration(days: 2)),
          category: 'Emergency',
        ),
      ],
      advances: 0,
      settlements: 0,
    );

    _claims.addAll([sampleClaim1, sampleClaim2, sampleClaim3]);
    notifyListeners();
  }
}
