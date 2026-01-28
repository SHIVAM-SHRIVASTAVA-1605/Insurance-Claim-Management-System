import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/claim_provider.dart';
import '../models/claim.dart';
import '../models/claim_status.dart';

class AddEditClaimScreen extends StatefulWidget {
  final Claim? claim;

  const AddEditClaimScreen({super.key, this.claim});

  @override
  State<AddEditClaimScreen> createState() => _AddEditClaimScreenState();
}

class _AddEditClaimScreenState extends State<AddEditClaimScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _patientNameController;
  late TextEditingController _patientIdController;
  late TextEditingController _hospitalNameController;
  DateTime? _admissionDate;
  DateTime? _dischargeDate;

  @override
  void initState() {
    super.initState();
    _patientNameController = TextEditingController(
      text: widget.claim?.patientName ?? '',
    );
    _patientIdController = TextEditingController(
      text: widget.claim?.patientId ?? '',
    );
    _hospitalNameController = TextEditingController(
      text: widget.claim?.hospitalName ?? '',
    );
    _admissionDate = widget.claim?.admissionDate;
    _dischargeDate = widget.claim?.dischargeDate;
  }

  @override
  void dispose() {
    _patientNameController.dispose();
    _patientIdController.dispose();
    _hospitalNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.claim != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Claim' : 'New Claim'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _patientNameController,
              decoration: const InputDecoration(
                labelText: 'Patient Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter patient name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _patientIdController,
              decoration: const InputDecoration(
                labelText: 'Patient ID',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.badge),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter patient ID';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _hospitalNameController,
              decoration: const InputDecoration(
                labelText: 'Hospital Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.local_hospital),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter hospital name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Admission Date'),
              subtitle: Text(
                _admissionDate == null
                    ? 'Not selected'
                    : '${_admissionDate!.day}/${_admissionDate!.month}/${_admissionDate!.year}',
              ),
              trailing: const Icon(Icons.calendar_today),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey[400]!),
              ),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _admissionDate ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() {
                    _admissionDate = date;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Discharge Date (Optional)'),
              subtitle: Text(
                _dischargeDate == null
                    ? 'Not selected'
                    : '${_dischargeDate!.day}/${_dischargeDate!.month}/${_dischargeDate!.year}',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_dischargeDate != null)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _dischargeDate = null;
                        });
                      },
                    ),
                  const Icon(Icons.calendar_today),
                ],
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey[400]!),
              ),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _dischargeDate ?? DateTime.now(),
                  firstDate: _admissionDate ?? DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() {
                    _dischargeDate = date;
                  });
                }
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveClaim,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              child: Text(
                isEditing ? 'Update Claim' : 'Create Claim',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveClaim() {
    if (_formKey.currentState!.validate()) {
      if (_admissionDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select admission date'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final claimProvider = Provider.of<ClaimProvider>(context, listen: false);
      
      if (widget.claim == null) {
        // Create new claim
        final newClaim = Claim(
          patientName: _patientNameController.text,
          patientId: _patientIdController.text,
          hospitalName: _hospitalNameController.text,
          admissionDate: _admissionDate!,
          dischargeDate: _dischargeDate,
          status: ClaimStatus.draft,
        );
        claimProvider.addClaim(newClaim);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Claim created successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Update existing claim
        final updatedClaim = widget.claim!.copyWith(
          patientName: _patientNameController.text,
          patientId: _patientIdController.text,
          hospitalName: _hospitalNameController.text,
          admissionDate: _admissionDate,
          dischargeDate: _dischargeDate,
        );
        claimProvider.updateClaim(updatedClaim);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Claim updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
      
      Navigator.pop(context);
    }
  }
}
