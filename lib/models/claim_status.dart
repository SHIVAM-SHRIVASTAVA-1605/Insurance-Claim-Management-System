enum ClaimStatus {
  draft,
  submitted,
  approved,
  rejected,
  partiallySettled,
  settled;

  String get displayName {
    switch (this) {
      case ClaimStatus.draft:
        return 'Draft';
      case ClaimStatus.submitted:
        return 'Submitted';
      case ClaimStatus.approved:
        return 'Approved';
      case ClaimStatus.rejected:
        return 'Rejected';
      case ClaimStatus.partiallySettled:
        return 'Partially Settled';
      case ClaimStatus.settled:
        return 'Settled';
    }
  }

  String get description {
    switch (this) {
      case ClaimStatus.draft:
        return 'Claim is being prepared';
      case ClaimStatus.submitted:
        return 'Claim has been submitted for review';
      case ClaimStatus.approved:
        return 'Claim has been approved';
      case ClaimStatus.rejected:
        return 'Claim has been rejected';
      case ClaimStatus.partiallySettled:
        return 'Claim is partially settled';
      case ClaimStatus.settled:
        return 'Claim is fully settled';
    }
  }
}
