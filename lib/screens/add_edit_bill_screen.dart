import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/claim_provider.dart';
import '../models/bill.dart';

class AddEditBillScreen extends StatefulWidget {
  final String claimId;
  final Bill? bill;

  const AddEditBillScreen({super.key, required this.claimId, this.bill});

  @override
  State<AddEditBillScreen> createState() => _AddEditBillScreenState();
}

class _AddEditBillScreenState extends State<AddEditBillScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descriptionController;
  late TextEditingController _amountController;
  String _selectedCategory = 'Accommodation';
  DateTime? _billDate;

  final List<String> _categories = [
    'Accommodation',
    'Consultation',
    'Doctor Fee',
    'Diagnostics',
    'Laboratory',
    'Pharmacy',
    'Surgery',
    'Treatment',
    'Emergency',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(
      text: widget.bill?.description ?? '',
    );
    _amountController = TextEditingController(
      text: widget.bill?.amount.toString() ?? '',
    );
    _selectedCategory = widget.bill?.category ?? 'Accommodation';
    _billDate = widget.bill?.date;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.bill != null;
    final claimProvider = Provider.of<ClaimProvider>(context);
    final claim = claimProvider.getClaimById(widget.claimId);

    if (claim == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Add Bill')),
        body: const Center(child: Text('Claim not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Bill' : 'Add Bill'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
                helperText: 'Brief description of the bill',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.currency_rupee),
                helperText: 'Enter the bill amount (positive values only)',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp(r'[-]')),
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Please enter a valid positive amount';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Bill Date'),
              subtitle: Text(
                _billDate == null
                    ? 'Not selected (must be on or after admission date)'
                    : '${_billDate!.day}/${_billDate!.month}/${_billDate!.year}',
              ),
              trailing: const Icon(Icons.calendar_today),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey[400]!),
              ),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _billDate ?? DateTime.now(),
                  firstDate: claim.admissionDate,
                  lastDate: DateTime.now(),
                  helpText: 'Select bill date (on or after admission)',
                );
                if (date != null) {
                  setState(() {
                    _billDate = date;
                  });
                }
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveBill,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              child: Text(
                isEditing ? 'Update Bill' : 'Add Bill',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveBill() {
    if (_formKey.currentState!.validate()) {
      if (_billDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select bill date'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final claimProvider = Provider.of<ClaimProvider>(context, listen: false);
      final amount = double.parse(_amountController.text);

      if (widget.bill == null) {
        // Add new bill
        final newBill = Bill(
          description: _descriptionController.text,
          amount: amount,
          date: _billDate!,
          category: _selectedCategory,
        );
        claimProvider.addBillToClaim(widget.claimId, newBill);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bill added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Update existing bill
        final updatedBill = widget.bill!.copyWith(
          description: _descriptionController.text,
          amount: amount,
          date: _billDate,
          category: _selectedCategory,
        );
        claimProvider.updateBillInClaim(widget.claimId, updatedBill);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bill updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }

      Navigator.pop(context);
    }
  }
}
