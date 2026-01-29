import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/claim_provider.dart';
import '../models/claim_status.dart';
import '../models/claim.dart';
import '../models/bill.dart';
import 'add_edit_claim_screen.dart';
import 'add_edit_bill_screen.dart';

class ClaimDetailScreen extends StatelessWidget {
  final String claimId;

  const ClaimDetailScreen({super.key, required this.claimId});

  Color _getStatusColor(ClaimStatus status) {
    switch (status) {
      case ClaimStatus.draft:
        return const Color(0xFF6B7280); // Slate
      case ClaimStatus.submitted:
        return const Color(0xFF3B82F6); // Blue
      case ClaimStatus.approved:
        return const Color(0xFF10B981); // Emerald
      case ClaimStatus.rejected:
        return const Color(0xFFEF4444); // Red
      case ClaimStatus.partiallySettled:
        return const Color(0xFFF59E0B); // Amber
      case ClaimStatus.settled:
        return const Color(0xFF8B5CF6); // Purple
    }
  }

  List<ClaimStatus> _getAvailableTransitions(ClaimStatus currentStatus) {
    switch (currentStatus) {
      case ClaimStatus.draft:
        // Draft can only be submitted
        return [ClaimStatus.submitted];
      case ClaimStatus.submitted:
        // Insurance reviews and decides: approve, reject, or partial
        return [
          ClaimStatus.approved,
          ClaimStatus.rejected,
          ClaimStatus.partiallySettled
        ];
      case ClaimStatus.approved:
        // After approval, can be settled (full or partial)
        return [ClaimStatus.partiallySettled, ClaimStatus.settled];
      case ClaimStatus.rejected:
        // Rejected is final
        return [];
      case ClaimStatus.partiallySettled:
        // Can only move to fully settled once remaining balance is paid
        return [ClaimStatus.settled];
      case ClaimStatus.settled:
        // Settled is final
        return [];
    }
  }

  String _getStatusDescription(ClaimStatus status) {
    switch (status) {
      case ClaimStatus.draft:
        return 'Claim is being prepared. Add bills and patient information.';
      case ClaimStatus.submitted:
        return 'Claim submitted to insurance. Waiting for review.';
      case ClaimStatus.approved:
        return 'Claim approved by insurance. Ready for settlement.';
      case ClaimStatus.rejected:
        return 'Claim rejected by insurance.';
      case ClaimStatus.partiallySettled:
        return 'Partial amount settled. Remaining balance pending.';
      case ClaimStatus.settled:
        return 'Claim fully settled. All payments completed.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final claimProvider = Provider.of<ClaimProvider>(context);
    final claim = claimProvider.getClaimById(claimId);

    if (claim == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Claim Details')),
        body: const Center(child: Text('Claim not found')),
      );
    }

    final dateFormat = DateFormat('MMM dd, yyyy');
    final statusColor = _getStatusColor(claim.status);
    final canEdit = claimProvider.canEditClaim(claim);
    final canUpdateFinancials = claimProvider.canUpdateFinancials(claim);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Claim Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: canEdit
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddEditClaimScreen(claim: claim),
                      ),
                    );
                  }
                : null,
            tooltip: canEdit ? 'Edit Claim' : 'Cannot edit after submission',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: canEdit
                ? () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Claim'),
                        content: const Text(
                          'Are you sure you want to delete this claim?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              claimProvider.deleteClaim(claimId);
                              Navigator.pop(context); // Close dialog
                              Navigator.pop(context); // Go back to dashboard
                            },
                            child: const Text(
                              'Delete',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                : null,
            tooltip:
                canEdit ? 'Delete Claim' : 'Cannot delete after submission',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Patient Info Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [statusColor, statusColor.withOpacity(0.85)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: statusColor.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              claim.patientName,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Patient ID: ${claim.patientId}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          claim.status.displayName,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    claim.hospitalName,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Status description
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline,
                            size: 16, color: Colors.white),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _getStatusDescription(claim.status),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          size: 16, color: Colors.white70),
                      const SizedBox(width: 6),
                      Text(
                        'Admitted: ${dateFormat.format(claim.admissionDate)}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                  if (claim.dischargeDate != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.exit_to_app,
                            size: 16, color: Colors.white70),
                        const SizedBox(width: 6),
                        Text(
                          'Discharged: ${dateFormat.format(claim.dischargeDate!)}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Financial Summary
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Financial Summary',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _buildFinancialRow(
                          'Total Bill Amount',
                          claim.totalBillAmount,
                          Colors.blue,
                          bold: true,
                        ),
                        const Divider(height: 24),
                        _buildFinancialRow(
                            'Advances Paid', claim.advances, Colors.green),
                        const SizedBox(height: 8),
                        _buildFinancialRow(
                            'Settlements', claim.settlements, Colors.green),
                        const SizedBox(height: 8),
                        _buildFinancialRow(
                            'Total Paid', claim.totalPaid, Colors.green),
                        const Divider(height: 24),
                        _buildFinancialRow(
                          'Pending Amount',
                          claim.pendingAmount,
                          Colors.orange,
                          bold: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: canUpdateFinancials
                              ? () => _showUpdateAdvancesDialog(context, claim)
                              : null,
                          icon: const Icon(Icons.attach_money),
                          label: const Text('Update Advances'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: canUpdateFinancials
                              ? () =>
                                  _showUpdateSettlementsDialog(context, claim)
                              : null,
                          icon: const Icon(Icons.payment),
                          label: const Text('Update Settlements'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (!canUpdateFinancials && claim.status == ClaimStatus.draft)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Submit claim to update financial information',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  if (!canUpdateFinancials && claim.status != ClaimStatus.draft)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Financial updates only available for approved/partially settled claims',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),

            // Status Transitions
            if (_getAvailableTransitions(claim.status).isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status Transitions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _getAvailableTransitions(claim.status)
                          .map((status) => ElevatedButton(
                                onPressed: () {
                                  // Special handling for settled status
                                  if (status == ClaimStatus.settled) {
                                    _handleSettledTransition(
                                        context, claim, claimProvider);
                                  } else {
                                    claimProvider.updateClaimStatus(
                                        claimId, status);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Status updated to ${status.displayName}',
                                        ),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _getStatusColor(status),
                                  foregroundColor: Colors.white,
                                ),
                                child: Text('Mark as ${status.displayName}'),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),

            // Bills Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Bills',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: canEdit
                            ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        AddEditBillScreen(claimId: claimId),
                                  ),
                                );
                              }
                            : null,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add Bill'),
                      ),
                    ],
                  ),
                  if (!canEdit)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Bills cannot be modified after claim submission',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange[700],
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  const SizedBox(height: 12),
                  if (claim.bills.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(Icons.receipt_long,
                                size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 12),
                            Text(
                              'No bills added yet',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...claim.bills
                        .map((bill) => _buildBillCard(context, claim, bill)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialRow(String label, double amount, Color color,
      {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: bold ? 16 : 14,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            color: Colors.grey[800],
          ),
        ),
        Text(
          '₹${NumberFormat('#,##,###').format(amount)}',
          style: TextStyle(
            fontSize: bold ? 18 : 16,
            fontWeight: bold ? FontWeight.bold : FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildBillCard(BuildContext context, Claim claim, Bill bill) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final claimProvider = Provider.of<ClaimProvider>(context, listen: false);
    final canEdit = claimProvider.canEditClaim(claim);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.receipt, color: Colors.blue[700]),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bill.description,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${bill.category} • ${dateFormat.format(bill.date)}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${NumberFormat('#,##,###').format(bill.amount)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                if (canEdit)
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 18),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddEditBillScreen(
                                claimId: claimId,
                                bill: bill,
                              ),
                            ),
                          );
                        },
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete,
                            size: 18, color: Colors.red),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Bill'),
                              content: const Text(
                                  'Are you sure you want to delete this bill?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Provider.of<ClaimProvider>(context,
                                            listen: false)
                                        .deleteBillFromClaim(claimId, bill.id);
                                    Navigator.pop(context);
                                  },
                                  child: const Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showUpdateAdvancesDialog(BuildContext context, Claim claim) {
    final controller = TextEditingController(text: claim.advances.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Advances'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Advance Amount',
            prefixText: '₹',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(controller.text) ?? 0;
              Provider.of<ClaimProvider>(context, listen: false)
                  .updateAdvances(claimId, amount);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Advances updated successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showUpdateSettlementsDialog(BuildContext context, Claim claim) {
    final controller =
        TextEditingController(text: claim.settlements.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Settlements'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Settlement Amount',
            prefixText: '₹',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(controller.text) ?? 0;
              Provider.of<ClaimProvider>(context, listen: false)
                  .updateSettlements(claimId, amount);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Settlements updated successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _handleSettledTransition(
      BuildContext context, Claim claim, ClaimProvider claimProvider) {
    // Check if there's a pending amount
    if (claim.pendingAmount > 0) {
      // Show warning dialog with pending amount
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirm Settlement'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'There is still a pending amount on this claim:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[300]!),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Amount:'),
                        Text(
                          '₹${NumberFormat('#,##,###').format(claim.totalBillAmount)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Paid:'),
                        Text(
                          '₹${NumberFormat('#,##,###').format(claim.totalPaid)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Pending Amount:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '₹${NumberFormat('#,##,###').format(claim.pendingAmount)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Are you sure you want to mark this claim as fully settled?',
                style: TextStyle(color: Colors.black87),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Update settlements to cover pending amount
                final newSettlements = claim.settlements + claim.pendingAmount;
                Provider.of<ClaimProvider>(context, listen: false)
                    .updateSettlements(claimId, newSettlements);

                // Mark as settled
                claimProvider.updateClaimStatus(claimId, ClaimStatus.settled);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Claim settled with ₹${NumberFormat('#,##,###').format(claim.pendingAmount)} added to settlements',
                    ),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 3),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                foregroundColor: Colors.white,
                elevation: 2,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                'Mark as Settled',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // Pending amount is 0, proceed directly without warning
      claimProvider.updateClaimStatus(claimId, ClaimStatus.settled);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Claim marked as settled'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
