import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freelancer_business_os/models/invoice.dart';
import 'package:freelancer_business_os/providers/stream_provider/invoice_stream_provider.dart';
import 'package:freelancer_business_os/providers/stream_provider/project_stream_provider.dart';
import 'package:freelancer_business_os/providers/state_provider/theme_provider.dart';
import 'package:freelancer_business_os/providers/stream_provider/user_profile_stream_provider.dart';
import 'package:freelancer_business_os/screens/generate_invoice_screen.dart';
import 'package:freelancer_business_os/screens/invoice_detailed_screen.dart';

class InvoicesScreen extends ConsumerStatefulWidget {
  const InvoicesScreen({super.key});

  @override
  ConsumerState<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends ConsumerState<InvoicesScreen> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final invoicesAsync = ref.watch(invoicesStreamProvider);
    final projectsAsync = ref.watch(projectsStreamProvider);
    const primaryIndigo = Color(0xFF4F46E5);

    // Global Theming Tokens Lookup (100% Preserved)
    final isDarkMode = ref.watch(themeProvider);
    final backgroundColor =
        isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cardColor = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF1F2937);

    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'unknown_user';
    final profileAsync = ref.watch(userProfileStreamProvider(uid));
    final currency = profileAsync.value?.selectedCurrencySymbol ?? '£';

    final invoices = invoicesAsync.value ?? [];
    final projectNames = projectsAsync.maybeWhen(
      data: (projects) => {for (final p in projects) p.id: p.projectName},
      orElse: () => <String, String>{},
    );

    final filteredInvoices = invoices.where((inv) {
      if (_selectedFilter == 'All') return true;
      return inv.status.name.toLowerCase() == _selectedFilter.toLowerCase();
    }).toList();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Invoices',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 26,
                    color: textColor,
                    letterSpacing: -0.8)),
            const SizedBox(height: 2),
            Text('${invoices.length} Invoices total',
                style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
      // 🌟 UPGRADED FLOATING ACTION BUTTON: Converted to a professional extended layout
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'invoices_fab_tag',
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const GenerateInvoiceScreen())),
        backgroundColor: primaryIndigo,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.receipt_long_outlined, size: 20),
        label: const Text('Generate Invoice',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Horizontal Status Filter Chips Row
            Container(
              height: 40,
              margin: const EdgeInsets.symmetric(vertical: 12),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                physics: const BouncingScrollPhysics(),
                children:
                    ['All', 'Draft', 'Sent', 'Paid', 'Overdue'].map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedFilter = filter),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isSelected ? primaryIndigo : cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: isSelected
                                ? Colors.transparent
                                : Colors.grey.withValues(alpha: 0.15)),
                      ),
                      child: Center(
                        child: Text(
                          filter,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Colors.white
                                : (isDarkMode
                                    ? Colors.white70
                                    : Colors.grey.shade700),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            // Ledger Invoice Feed list
            Expanded(
              child: invoicesAsync.when(
                loading: () => const Center(
                    child: CircularProgressIndicator(color: primaryIndigo)),
                error: (error, stack) => Center(child: Text('Error: $error')),
                data: (_) {
                  if (filteredInvoices.isEmpty) {
                    return Center(
                        child: Text('No $_selectedFilter invoices discovered.',
                            style: const TextStyle(color: Colors.grey)));
                  }
                  return ListView.separated(
                    // Roomy bottom margin spacing padding so list rows scroll completely clear of taskbar
                    padding: const EdgeInsets.only(
                        left: 20, right: 20, top: 4, bottom: 100),
                    itemCount: filteredInvoices.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final invoice = filteredInvoices[index];
                      final projectName = projectNames[invoice.projectId] ??
                          'Project Asset Workspace';
                      final amountText =
                          '$currency${(invoice.totalAmountInCents / 100).toStringAsFixed(0)}';
                      final dateString =
                          '${invoice.createdDate.day} ${_getMonthName(invoice.createdDate.month)}, ${invoice.createdDate.year}';

                      return Container(
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black
                                    .withValues(alpha: isDarkMode ? 0.1 : 0.02),
                                blurRadius: 10,
                                offset: const Offset(0, 4))
                          ],
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      InvoiceDetailedScreen(invoice: invoice))),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                              color: primaryIndigo
                                                  .withValues(alpha: 0.06),
                                              borderRadius:
                                                  BorderRadius.circular(12)),
                                          child: const Icon(
                                              Icons.business_center_outlined,
                                              color: primaryIndigo,
                                              size: 18),
                                        ),
                                        const SizedBox(width: 14),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(projectName,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15,
                                                    color: textColor),
                                                maxLines: 1,
                                                overflow:
                                                    TextOverflow.ellipsis),
                                            const SizedBox(height: 2),
                                            Text('Consulting Services',
                                                style: TextStyle(
                                                    color: Colors.grey.shade500,
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.w500)),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Text(amountText,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 17,
                                            color: textColor)),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                const Divider(height: 1),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.receipt_outlined,
                                            size: 12, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text(
                                            'INV-${invoice.id.substring(0, 6).toUpperCase()}',
                                            style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600)),
                                        const SizedBox(width: 8),
                                        _StatusPill(status: invoice.status),
                                      ],
                                    ),
                                    Text(dateString,
                                        style: TextStyle(
                                            color: Colors.grey.shade400,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }
}

class _StatusPill extends StatelessWidget {
  final InvoiceStatus status;
  const _StatusPill({required this.status});
  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status) {
      InvoiceStatus.draft => (Colors.grey, 'Draft'),
      InvoiceStatus.sent => (Colors.orange, 'Sent'),
      InvoiceStatus.paid => (const Color(0xFF10B981), 'Paid'),
      InvoiceStatus.overdue => (Colors.redAccent, 'Overdue'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12)),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
