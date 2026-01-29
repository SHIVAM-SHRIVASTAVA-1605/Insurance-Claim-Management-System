import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../providers/claim_provider.dart';
import '../models/claim_status.dart';
import '../models/claim.dart';
import '../services/export_service.dart';
import '../utils/web_helper.dart'
    if (dart.library.html) '../utils/web_helper_web.dart'
    if (dart.library.io) '../utils/web_helper_io.dart';
import 'claim_detail_screen.dart';
import 'add_edit_claim_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  String _sortBy = 'date'; // 'date', 'amount', 'name'

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Insurance Claims Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort by',
            onSelected: (value) {
              setState(() {
                _sortBy = value;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'date',
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 18,
                      color: _sortBy == 'date'
                          ? const Color(0xFF6366F1)
                          : Colors.grey[600],
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Date (Newest first)',
                      style: TextStyle(
                        color: _sortBy == 'date'
                            ? const Color(0xFF6366F1)
                            : Colors.black87,
                        fontWeight: _sortBy == 'date'
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'amount',
                child: Row(
                  children: [
                    Icon(
                      Icons.currency_rupee,
                      size: 18,
                      color: _sortBy == 'amount'
                          ? const Color(0xFF6366F1)
                          : Colors.grey[600],
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Amount (Highest first)',
                      style: TextStyle(
                        color: _sortBy == 'amount'
                            ? const Color(0xFF6366F1)
                            : Colors.black87,
                        fontWeight: _sortBy == 'amount'
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'name',
                child: Row(
                  children: [
                    Icon(
                      Icons.sort_by_alpha,
                      size: 18,
                      color: _sortBy == 'name'
                          ? const Color(0xFF6366F1)
                          : Colors.grey[600],
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Patient Name (A-Z)',
                      style: TextStyle(
                        color: _sortBy == 'name'
                            ? const Color(0xFF6366F1)
                            : Colors.black87,
                        fontWeight: _sortBy == 'name'
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.file_download),
            tooltip: 'Export',
            onSelected: (value) => _handleExport(context, value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'pdf',
                child: Row(
                  children: [
                    Icon(Icons.picture_as_pdf, size: 18, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Export All to PDF'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'csv',
                child: Row(
                  children: [
                    Icon(Icons.table_chart, size: 18, color: Colors.green),
                    SizedBox(width: 12),
                    Text('Export All to CSV'),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              setState(() {
                _searchQuery = '';
                _searchController.clear();
              });
              _showSearchDialog();
            },
            tooltip: 'Search claims',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: Colors.white,
            child: Consumer<ClaimProvider>(
              builder: (context, claimProvider, child) {
                final claims = claimProvider.claims;
                final partialCount = claims
                    .where((c) => c.status == ClaimStatus.partiallySettled)
                    .length;
                final settledCount =
                    claims.where((c) => c.status == ClaimStatus.settled).length;
                final approvedCount = claims
                    .where((c) => c.status == ClaimStatus.approved)
                    .length;
                final rejectedCount = claims
                    .where((c) => c.status == ClaimStatus.rejected)
                    .length;

                return TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  indicatorColor: const Color(0xFF6366F1),
                  indicatorWeight: 3,
                  labelColor: const Color(0xFF6366F1),
                  unselectedLabelColor: const Color(0xFF6B7280),
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  tabs: [
                    Tab(text: 'All (${claims.length})'),
                    Tab(text: 'Partial ($partialCount)'),
                    Tab(text: 'Settled ($settledCount)'),
                    Tab(text: 'Approved ($approvedCount)'),
                    Tab(text: 'Rejected ($rejectedCount)'),
                  ],
                );
              },
            ),
          ),
        ),
      ),
      body: Consumer<ClaimProvider>(
        builder: (context, claimProvider, child) {
          final claims = claimProvider.claims;

          return TabBarView(
            controller: _tabController,
            children: [
              // All Claims Tab
              _buildClaimsList(context, claimProvider, claims),
              // Partially Settled Tab
              _buildClaimsList(
                context,
                claimProvider,
                claims
                    .where((c) => c.status == ClaimStatus.partiallySettled)
                    .toList(),
              ),
              // Settled Tab
              _buildClaimsList(
                context,
                claimProvider,
                claims.where((c) => c.status == ClaimStatus.settled).toList(),
              ),
              // Approved Tab
              _buildClaimsList(
                context,
                claimProvider,
                claims.where((c) => c.status == ClaimStatus.approved).toList(),
              ),
              // Rejected Tab
              _buildClaimsList(
                context,
                claimProvider,
                claims.where((c) => c.status == ClaimStatus.rejected).toList(),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditClaimScreen(),
            ),
          );
        },
        backgroundColor: const Color(0xFF6366F1),
        elevation: 4,
        icon: const Icon(Icons.add, size: 24),
        label: const Text(
          'New Claim',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildClaimsList(
      BuildContext context, ClaimProvider claimProvider, List<Claim> claims) {
    // Create mutable copy for filtering and sorting
    List<Claim> filteredClaims = List.from(claims);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filteredClaims = filteredClaims.where((claim) {
        final query = _searchQuery.toLowerCase();
        return claim.patientName.toLowerCase().contains(query) ||
            claim.patientId.toLowerCase().contains(query) ||
            claim.hospitalName.toLowerCase().contains(query);
      }).toList();
    }

    // Apply sorting
    switch (_sortBy) {
      case 'date':
        filteredClaims.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'amount':
        filteredClaims
            .sort((a, b) => b.totalBillAmount.compareTo(a.totalBillAmount));
        break;
      case 'name':
        filteredClaims.sort((a, b) =>
            a.patientName.toLowerCase().compareTo(b.patientName.toLowerCase()));
        break;
    }

    if (filteredClaims.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _searchQuery.isNotEmpty
                  ? Icons.search_off
                  : Icons.assignment_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No matching claims'
                  : 'No claims found',
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Try a different search term'
                  : 'Tap the + button to create a new claim',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
            if (_searchQuery.isNotEmpty) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _searchQuery = '';
                    _searchController.clear();
                  });
                },
                child: const Text('Clear Search'),
              ),
            ],
          ],
        ),
      );
    }

    return Column(
      children: [
        // Statistics Cards
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Claims',
                  claimProvider.totalClaims.toString(),
                  Icons.assignment,
                  const Color(0xFF6366F1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Pending',
                  claimProvider
                      .getClaimCountByStatus(ClaimStatus.submitted)
                      .toString(),
                  Icons.pending_actions,
                  const Color(0xFFF59E0B),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Approved',
                  claimProvider
                      .getClaimCountByStatus(ClaimStatus.approved)
                      .toString(),
                  Icons.check_circle,
                  const Color(0xFF10B981),
                ),
              ),
            ],
          ),
        ),

        // Amount Summary
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Claim Amount',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\u20b9${NumberFormat('#,##,###').format(claimProvider.totalClaimAmount)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Pending Amount',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\u20b9${NumberFormat('#,##,###').format(claimProvider.totalPendingAmount)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Claims List
        Expanded(
          child: filteredClaims.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.folder_open,
                            size: 64,
                            color: const Color(0xFF6366F1),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'No Claims Yet',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'No claims match your search \"$_searchQuery\"'
                              : 'Start by creating your first insurance claim',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (_searchQuery.isEmpty) ...[
                          const SizedBox(height: 32),
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.blue[200]!,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.lightbulb_outline,
                                        color: Colors.blue[700], size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Quick Start Guide',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.blue[900],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                _buildQuickStartStep(
                                    '1',
                                    'Tap the + button below',
                                    Icons.add_circle_outline),
                                const SizedBox(height: 8),
                                _buildQuickStartStep(
                                    '2',
                                    'Enter patient details',
                                    Icons.person_outline),
                                const SizedBox(height: 8),
                                _buildQuickStartStep('3', 'Add medical bills',
                                    Icons.receipt_long_outlined),
                                const SizedBox(height: 8),
                                _buildQuickStartStep(
                                    '4',
                                    'Submit for processing',
                                    Icons.send_outlined),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredClaims.length,
                  itemBuilder: (context, index) {
                    final claim = filteredClaims[index];
                    return _buildClaimCard(context, claim);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, color.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildClaimCard(BuildContext context, Claim claim) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final statusColor = _getStatusColor(claim.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ClaimDetailScreen(claimId: claim.id),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
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
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'ID: ${claim.patientId}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6B7280),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        claim.status.displayName,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.local_hospital,
                        size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        claim.hospitalName,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today,
                        size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Text(
                      'Admitted: ${dateFormat.format(claim.admissionDate)}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildAmountInfo(
                      'Total',
                      claim.totalBillAmount,
                      const Color(0xFF3B82F6),
                    ),
                    _buildAmountInfo(
                      'Paid',
                      claim.totalPaid,
                      const Color(0xFF10B981),
                    ),
                    _buildAmountInfo(
                      'Pending',
                      claim.pendingAmount,
                      const Color(0xFFF59E0B),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAmountInfo(String label, double amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF9CA3AF),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '₹${NumberFormat('#,##,###').format(amount)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Claims'),
        content: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Patient name, ID, or hospital',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _searchQuery = '';
                _searchController.clear();
              });
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStartStep(String number, String text, IconData icon) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.blue[700],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Icon(icon, size: 18, color: Colors.blue[700]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleExport(BuildContext context, String exportType) async {
    final claimProvider = Provider.of<ClaimProvider>(context, listen: false);
    final claims = claimProvider.allClaims;

    if (claims.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No claims to export'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      // Show loading indicator
      if (!context.mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Generating export...'),
                ],
              ),
            ),
          ),
        ),
      );

      if (exportType == 'pdf') {
        await ExportService.exportAllClaimsToPdf(claims);
      } else if (exportType == 'csv') {
        final csv = await ExportService.exportAllClaimsToCsv(claims);
        final filename =
            'all_claims_${DateTime.now().millisecondsSinceEpoch}.csv';

        if (kIsWeb) {
          // For web, download using blob
          WebHelper.downloadFile(csv, filename);
        } else {
          // For mobile/desktop, save to file
          final file = await ExportService.saveCsvToFile(csv, filename);
          if (!context.mounted) return;
          Navigator.pop(context); // Close loading
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('CSV saved to ${file.path}'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 4),
            ),
          );
          return;
        }
      }

      if (!context.mounted) return;
      Navigator.pop(context); // Close loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${exportType.toUpperCase()} exported successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // Close loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }
}
