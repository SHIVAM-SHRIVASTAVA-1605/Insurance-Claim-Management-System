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
        return Colors.grey;
      case ClaimStatus.submitted:
        return Colors.blue;
      case ClaimStatus.approved:
        return Colors.green;
      case ClaimStatus.rejected:
        return Colors.red;
      case ClaimStatus.partiallySettled:
        return Colors.orange;
    }
  }

  List<ClaimStatus> _getAvailableTransitions(ClaimStatus currentStatus) {
    switch (currentStatus) {
      case ClaimStatus.draft:
        return [ClaimStatus.submitted];
      case ClaimStatus.submitted:
        return [ClaimStatus.approved, ClaimStatus.rejected];
      case ClaimStatus.approved:
        return [ClaimStatus.partiallySettled];
      case ClaimStatus.rejected:
      case ClaimStatus.partiallySettled:
        return [];
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Claim Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEditClaimScreen(claim: claim),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
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
            },
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
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [statusColor.withOpacity(0.8), statusColor],
                ),
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
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16, color: Colors.white70),
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
                        const Icon(Icons.exit_to_app, size: 16, color: Colors.white70),
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
                        _buildFinancialRow('Advances Paid', claim.advances, Colors.green),
                        const SizedBox(height: 8),
                        _buildFinancialRow('Settlements', claim.settlements, Colors.green),
                        const SizedBox(height: 8),
                        _buildFinancialRow('Total Paid', claim.totalPaid, Colors.green),
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
                          onPressed: () => _showUpdateAdvancesDialog(context, claim),
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
                          onPressed: () => _showUpdateSettlementsDialog(context, claim),
                          icon: const Icon(Icons.payment),
                          label: const Text('Update Settlements'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(12),
                          ),
                        ),
                      ),
                    ],
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
                                  claimProvider.updateClaimStatus(claimId, status);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Status updated to ${status.displayName}',
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
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
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddEditBillScreen(claimId: claimId),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add Bill'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (claim.bills.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
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
                    ...claim.bills.map((bill) => _buildBillCard(context, claim, bill)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialRow(String label, double amount, Color color, {bool bold = false}) {
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
                      icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Bill'),
                            content: const Text('Are you sure you want to delete this bill?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Provider.of<ClaimProvider>(context, listen: false)
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
    final controller = TextEditingController(text: claim.settlements.toString());
    
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
}
