import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import '../models/claim.dart';
import '../models/claim_status.dart';
import '../models/payment_transaction.dart';

class ExportService {
  static final dateFormat = DateFormat('MMM dd, yyyy');
  static final dateTimeFormat = DateFormat('MMM dd, yyyy HH:mm');
  static final currencyFormat = NumberFormat('#,##,###');

  // Export single claim to PDF
  static Future<void> exportClaimToPdf(Claim claim) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: _getPdfStatusColor(claim.status),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'INSURANCE CLAIM REPORT',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Generated: ${dateTimeFormat.format(DateTime.now())}',
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.white,
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 24),

            // Patient Information
            pw.Text(
              'PATIENT INFORMATION',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue900,
              ),
            ),
            pw.SizedBox(height: 12),
            _buildInfoRow('Patient Name', claim.patientName),
            _buildInfoRow('Patient ID', claim.patientId),
            _buildInfoRow('Hospital', claim.hospitalName),
            _buildInfoRow(
                'Admission Date', dateFormat.format(claim.admissionDate)),
            if (claim.dischargeDate != null)
              _buildInfoRow(
                  'Discharge Date', dateFormat.format(claim.dischargeDate!)),
            _buildInfoRow('Status', claim.status.displayName),
            pw.SizedBox(height: 24),

            // Financial Summary
            pw.Text(
              'FINANCIAL SUMMARY',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue900,
              ),
            ),
            pw.SizedBox(height: 12),
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400),
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Column(
                children: [
                  _buildFinancialRow('Total Bill Amount', claim.totalBillAmount,
                      bold: true),
                  pw.Divider(),
                  _buildFinancialRow('Advances Paid', claim.advances),
                  _buildFinancialRow('Settlements', claim.settlements),
                  _buildFinancialRow('Total Paid', claim.totalPaid),
                  pw.Divider(),
                  _buildFinancialRow('Pending Amount', claim.pendingAmount,
                      bold: true),
                ],
              ),
            ),
            pw.SizedBox(height: 24),

            // Bills
            if (claim.bills.isNotEmpty) ...[
              pw.Text(
                'BILLS (${claim.bills.length})',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue900,
                ),
              ),
              pw.SizedBox(height: 12),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey400),
                children: [
                  // Header
                  pw.TableRow(
                    decoration:
                        const pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      _buildTableCell('Description', bold: true),
                      _buildTableCell('Category', bold: true),
                      _buildTableCell('Date', bold: true),
                      _buildTableCell('Amount (Rs.)',
                          bold: true, align: pw.TextAlign.right),
                    ],
                  ),
                  // Data rows
                  ...claim.bills.map((bill) => pw.TableRow(
                        children: [
                          _buildTableCell(bill.description),
                          _buildTableCell(bill.category),
                          _buildTableCell(dateFormat.format(bill.date)),
                          _buildTableCell(
                            currencyFormat.format(bill.amount),
                            align: pw.TextAlign.right,
                          ),
                        ],
                      )),
                ],
              ),
              pw.SizedBox(height: 24),
            ],

            // Payment History
            if (claim.paymentHistory.isNotEmpty) ...[
              pw.Text(
                'PAYMENT HISTORY (${claim.paymentHistory.length} transactions)',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue900,
                ),
              ),
              pw.SizedBox(height: 12),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey400),
                children: [
                  // Header
                  pw.TableRow(
                    decoration:
                        const pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      _buildTableCell('Date & Time', bold: true),
                      _buildTableCell('Type', bold: true),
                      _buildTableCell('Method', bold: true),
                      _buildTableCell('Amount (Rs.)',
                          bold: true, align: pw.TextAlign.right),
                    ],
                  ),
                  // Data rows
                  ...claim.paymentHistory.map((transaction) => pw.TableRow(
                        children: [
                          _buildTableCell(
                              dateTimeFormat.format(transaction.date)),
                          _buildTableCell(
                            transaction.type == PaymentType.advance
                                ? 'Advance'
                                : 'Settlement',
                          ),
                          _buildTableCell(transaction.method.displayName),
                          _buildTableCell(
                            currencyFormat.format(transaction.amount),
                            align: pw.TextAlign.right,
                          ),
                        ],
                      )),
                ],
              ),
            ],
          ];
        },
      ),
    );

    // Share/Print PDF
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name:
          'claim_${claim.patientId}_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }

  // Export all claims to PDF
  static Future<void> exportAllClaimsToPdf(List<Claim> claims) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColors.blue900,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'ALL CLAIMS REPORT',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Generated: ${dateTimeFormat.format(DateTime.now())}',
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.white,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Total Claims: ${claims.length}',
                    style: const pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.white,
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 24),

            // Summary Statistics
            pw.Text(
              'SUMMARY',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue900,
              ),
            ),
            pw.SizedBox(height: 12),
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400),
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Column(
                children: [
                  _buildFinancialRow(
                    'Total Claims Amount',
                    claims.fold(0.0, (sum, c) => sum + c.totalBillAmount),
                    bold: true,
                  ),
                  _buildFinancialRow(
                    'Total Paid',
                    claims.fold(0.0, (sum, c) => sum + c.totalPaid),
                  ),
                  _buildFinancialRow(
                    'Total Pending',
                    claims.fold(0.0, (sum, c) => sum + c.pendingAmount),
                    bold: true,
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 24),

            // Claims Table
            pw.Text(
              'CLAIMS LIST',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue900,
              ),
            ),
            pw.SizedBox(height: 12),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey400),
              columnWidths: {
                0: const pw.FlexColumnWidth(2),
                1: const pw.FlexColumnWidth(2),
                2: const pw.FlexColumnWidth(1.5),
                3: const pw.FlexColumnWidth(1.5),
                4: const pw.FlexColumnWidth(1.5),
                5: const pw.FlexColumnWidth(1.5),
              },
              children: [
                // Header
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                  children: [
                    _buildTableCell('Patient', bold: true),
                    _buildTableCell('Hospital', bold: true),
                    _buildTableCell('Status', bold: true),
                    _buildTableCell('Total (Rs.)',
                        bold: true, align: pw.TextAlign.right),
                    _buildTableCell('Paid (Rs.)',
                        bold: true, align: pw.TextAlign.right),
                    _buildTableCell('Pending (Rs.)',
                        bold: true, align: pw.TextAlign.right),
                  ],
                ),
                // Data rows
                ...claims.map((claim) => pw.TableRow(
                      children: [
                        _buildTableCell(
                            '${claim.patientName}\n${claim.patientId}'),
                        _buildTableCell(claim.hospitalName),
                        _buildTableCell(claim.status.displayName),
                        _buildTableCell(
                          currencyFormat.format(claim.totalBillAmount),
                          align: pw.TextAlign.right,
                        ),
                        _buildTableCell(
                          currencyFormat.format(claim.totalPaid),
                          align: pw.TextAlign.right,
                        ),
                        _buildTableCell(
                          currencyFormat.format(claim.pendingAmount),
                          align: pw.TextAlign.right,
                        ),
                      ],
                    )),
              ],
            ),
          ];
        },
      ),
    );

    // Share/Print PDF
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'all_claims_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }

  // Export single claim to CSV
  static Future<String> exportClaimToCsv(Claim claim) async {
    final List<List<dynamic>> rows = [];

    // Patient Information
    rows.add(['PATIENT INFORMATION']);
    rows.add(['Patient Name', claim.patientName]);
    rows.add(['Patient ID', claim.patientId]);
    rows.add(['Hospital', claim.hospitalName]);
    rows.add(['Admission Date', dateFormat.format(claim.admissionDate)]);
    if (claim.dischargeDate != null) {
      rows.add(['Discharge Date', dateFormat.format(claim.dischargeDate!)]);
    }
    rows.add(['Status', claim.status.displayName]);
    rows.add([]);

    // Financial Summary
    rows.add(['FINANCIAL SUMMARY']);
    rows.add(['Total Bill Amount', claim.totalBillAmount]);
    rows.add(['Advances Paid', claim.advances]);
    rows.add(['Settlements', claim.settlements]);
    rows.add(['Total Paid', claim.totalPaid]);
    rows.add(['Pending Amount', claim.pendingAmount]);
    rows.add([]);

    // Bills
    if (claim.bills.isNotEmpty) {
      rows.add(['BILLS']);
      rows.add(['Description', 'Category', 'Date', 'Amount']);
      for (final bill in claim.bills) {
        rows.add([
          bill.description,
          bill.category,
          dateFormat.format(bill.date),
          bill.amount,
        ]);
      }
      rows.add([]);
    }

    // Payment History
    if (claim.paymentHistory.isNotEmpty) {
      rows.add(['PAYMENT HISTORY']);
      rows.add(['Date & Time', 'Type', 'Method', 'Amount', 'Notes']);
      for (final transaction in claim.paymentHistory) {
        rows.add([
          dateTimeFormat.format(transaction.date),
          transaction.type == PaymentType.advance ? 'Advance' : 'Settlement',
          transaction.method.displayName,
          transaction.amount,
          transaction.notes ?? '',
        ]);
      }
    }

    return const ListToCsvConverter().convert(rows);
  }

  // Export all claims to CSV
  static Future<String> exportAllClaimsToCsv(List<Claim> claims) async {
    final List<List<dynamic>> rows = [];

    // Header
    rows.add([
      'Patient Name',
      'Patient ID',
      'Hospital',
      'Admission Date',
      'Discharge Date',
      'Status',
      'Total Bill Amount',
      'Advances',
      'Settlements',
      'Total Paid',
      'Pending Amount',
      'Bills Count',
    ]);

    // Data
    for (final claim in claims) {
      rows.add([
        claim.patientName,
        claim.patientId,
        claim.hospitalName,
        dateFormat.format(claim.admissionDate),
        claim.dischargeDate != null
            ? dateFormat.format(claim.dischargeDate!)
            : '',
        claim.status.displayName,
        claim.totalBillAmount,
        claim.advances,
        claim.settlements,
        claim.totalPaid,
        claim.pendingAmount,
        claim.bills.length,
      ]);
    }

    return const ListToCsvConverter().convert(rows);
  }

  // Save CSV to file (for mobile/desktop)
  static Future<File> saveCsvToFile(String csv, String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$filename');
    await file.writeAsString(csv);
    return file;
  }

  // Helper methods
  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 150,
            child: pw.Text(
              '$label:',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Expanded(child: pw.Text(value)),
        ],
      ),
    );
  }

  static pw.Widget _buildFinancialRow(String label, double amount,
      {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
          pw.Text(
            'Rs. ${currencyFormat.format(amount)}',
            style: pw.TextStyle(
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildTableCell(String text,
      {bool bold = false, pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
        textAlign: align,
      ),
    );
  }

  static PdfColor _getPdfStatusColor(ClaimStatus status) {
    switch (status) {
      case ClaimStatus.draft:
        return PdfColors.grey700;
      case ClaimStatus.submitted:
        return PdfColors.blue;
      case ClaimStatus.approved:
        return PdfColors.green;
      case ClaimStatus.rejected:
        return PdfColors.red;
      case ClaimStatus.partiallySettled:
        return PdfColors.orange;
      case ClaimStatus.settled:
        return PdfColors.purple;
    }
  }
}
