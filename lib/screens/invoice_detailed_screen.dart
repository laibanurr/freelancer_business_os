import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freelancer_business_os/models/invoice.dart';
import 'package:freelancer_business_os/providers/repositories_provider/client_repo_provider.dart';
import 'package:freelancer_business_os/providers/repositories_provider/invoice_repo_provider.dart';
import 'package:freelancer_business_os/providers/state_provider/theme_provider.dart';
import 'package:freelancer_business_os/providers/stream_provider/client_stream_provider.dart';
import 'package:freelancer_business_os/providers/stream_provider/entries_for_project_provider.dart';
import 'package:freelancer_business_os/providers/stream_provider/invoice_stream_provider.dart';
import 'package:freelancer_business_os/providers/stream_provider/project_stream_provider.dart';
import 'package:freelancer_business_os/providers/stream_provider/user_profile_stream_provider.dart';
import 'package:freelancer_business_os/services/invoice_pdf_service.dart';
const _primaryIndigo = Color(0xFF4F46E5);
class InvoiceDetailedScreen extends ConsumerWidget {
  final Invoice invoice;
  const InvoiceDetailedScreen({super.key, required this.invoice});
  String _safeShortId(String id) {
    final clean = id.trim();
    if (clean.length <= 6) return clean.toUpperCase();
    return clean.substring(0, 6).toUpperCase();
  }
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoiceAsync = ref.watch(invoicesStreamProvider);
    final projectAsync = ref.watch(projectsStreamProvider);
    final clientAsync = ref.watch(clientsStreamProvider);
    final entriesAsync =
        ref.watch(timeEntriesForProjectProvider(invoice.projectId));
    final isDarkMode = ref.watch(themeProvider);
    final backgroundColor =
        isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cardColor = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF1F2937);
    final auth = ref.watch(authProvider);
    final uid = auth.currentUser?.uid ?? 'unknown_user';
    final profileAsync = ref.watch(userProfileStreamProvider(uid));
    final currency = profileAsync.value?.selectedCurrencySymbol ?? '\$';
    final projects = projectAsync.value ?? [];
    final clients = clientAsync.value ?? [];
    final currentProject =
        projects.where((p) => p.id == invoice.projectId).firstOrNull;
    final currentClient = currentProject == null
        ? null
        : clients.where((c) => c.id == currentProject.clientId).firstOrNull;
    final totalAmountText =
        '$currency${(invoice.totalAmountInCents / 100).toStringAsFixed(2)}';
    final formattedDate =
        '${invoice.createdDate.day}/${invoice.createdDate.month}/${invoice.createdDate.year}';
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: isDarkMode ? Colors.white70 : const Color(0xFF1F2937),
          ),
        ),
        title: Text(
          'Invoice Receipt',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: invoiceAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: _primaryIndigo),
        ),
        error: (error, stackTrace) => Center(
          child: Text(
            'Error: $error',
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
        data: (_) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(26),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDarkMode
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.grey.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'INV-${_safeShortId(invoice.id)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          fontSize: 13,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        totalAmountText,
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          invoice.status.name.toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFF10B981),
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDarkMode
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.grey.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ACCOUNT INFORMATION',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _rowLine(
                        'Client',
                        currentClient?.name ?? 'Corporate Partner',
                        textColor,
                      ),
                      _rowLine(
                        'Project Reference',
                        currentProject?.projectName ?? 'Scope Contract',
                        textColor,
                      ),
                      _rowLine('Issue Date', formattedDate, textColor),
                      _rowLine(
                        'Rate Tier',
                        '$currency${((currentProject?.rateInCents ?? 0) / 100).toStringAsFixed(0)}/hr',
                        textColor,
                      ),
                      if (invoice.invoiceDescription != null) ...[
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 12),
                        const Text(
                          'AI WORK AUDIT STATEMENT',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _primaryIndigo,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          invoice.invoiceDescription!,
                          style: TextStyle(
                            color: textColor.withValues(alpha: 0.8),
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      const Text(
                        'ITEMIZED TIME ENTRIES',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 14),
                      entriesAsync.when(
                        loading: () => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        error: (e, st) => Text(
                          'Error loading sessions: $e',
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                        data: (allEntries) {
                          final billedEntries = allEntries
                              .where((entry) =>
                                  invoice.timeEntryIds.contains(entry.id))
                              .toList();
                          if (billedEntries.isEmpty) {
                            return const Text(
                              'Standard project retainer delivery.',
                              style: TextStyle(color: Colors.grey, fontSize: 13),
                            );
                          }
                          return ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: billedEntries.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final entry = billedEntries[index];
                              final duration = entry.endTime != null
                                  ? entry.endTime!.difference(entry.startTime)
                                  : Duration.zero;
                              final hourUnits = (duration.inMinutes / 60.0);
                              final itemCash = (hourUnits *
                                  (currentProject?.rateInCents ?? 0) /
                                  100.0);
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '📅  ${entry.startTime.month}/${entry.startTime.day} (${hourUnits.toStringAsFixed(1)} hrs)',
                                    style: TextStyle(
                                      color: isDarkMode
                                          ? Colors.white70
                                          : Colors.black54,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    '$currency${itemCash.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: textColor,
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await InvoicePdfService.compileAndDownloadInvoicePdf(
                            invoice: invoice,
                            project: currentProject,
                            client: currentClient,
                            currencySymbol: currency,
                          );
                        },
                        icon: const Icon(Icons.file_download_outlined, size: 16),
                        label: const Text(
                          'Download PDF',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: textColor,
                          side: BorderSide(
                            color: isDarkMode
                                ? Colors.white.withValues(alpha: 0.2)
                                : Colors.grey.withValues(alpha: 0.2),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: invoice.status == InvoiceStatus.paid
                            ? null
                            : () async {
                                final next =
                                    invoice.status == InvoiceStatus.draft
                                        ? InvoiceStatus.sent
                                        : InvoiceStatus.paid;
                                final updated = invoice.copyWith(status: next);
                                await ref
                                    .read(invoiceRepositoryProvider)
                                    .updateInvoice(updated);
                                if (context.mounted) Navigator.pop(context);
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryIndigo,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: Text(
                          invoice.status == InvoiceStatus.draft
                              ? 'Share Invoice'
                              : (invoice.status == InvoiceStatus.sent
                                  ? 'Record Payment'
                                  : 'Payment Collected'),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  Widget _rowLine(String left, String right, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            left,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            right,
            style: TextStyle(
              color: textColor,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}