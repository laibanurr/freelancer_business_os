import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freelancer_business_os/models/invoice.dart';
import 'package:freelancer_business_os/providers/stream_provider/invoice_stream_provider.dart';
import 'package:freelancer_business_os/providers/stream_provider/project_stream_provider.dart';
import 'package:freelancer_business_os/providers/stream_provider/client_stream_provider.dart';
import 'package:freelancer_business_os/providers/stream_provider/entries_for_project_provider.dart';
import 'package:freelancer_business_os/providers/repositories_provider/invoice_repo_provider.dart';
import 'package:freelancer_business_os/services/invoice_pdf_service.dart';

class InvoiceDetailedScreen extends ConsumerWidget {
  final Invoice invoice;
  const InvoiceDetailedScreen({super.key, required this.invoice});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoiceAsync = ref.watch(invoicesStreamProvider);
    final projectAsync = ref.watch(projectsStreamProvider);
    final clientAsync = ref.watch(clientsStreamProvider);
    final entriesAsync = ref.watch(timeEntriesForProjectProvider(invoice.projectId));
    
    final projects = projectAsync.value ?? [];
    final clients = clientAsync.value ?? [];
    final currentProject = projects.where((p) => p.id == invoice.projectId).firstOrNull;
    final currentClient = currentProject == null ? null : clients.where((c) => c.id == currentProject.clientId).firstOrNull;
        
    const primaryIndigo = Color(0xFF4F46E5);
    const backgroundColor = Color(0xFFF8FAFC);

    final totalAmountText = '\$${(invoice.totalAmountInCents / 100).toStringAsFixed(2)}';
    final formattedDate = '${invoice.createdDate.day}/${invoice.createdDate.month}/${invoice.createdDate.year}';

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Color(0xFF1F2937)),
        ),
        title: const Text('Invoice Receipt', style: TextStyle(color: Color(0xFF1F2937), fontWeight: FontWeight.bold, fontSize: 20, letterSpacing: -0.5)),
      ),
      body: invoiceAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: primaryIndigo)),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
        data: (_) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // MAIN HEADER CARD
                Container(
                  padding: const EdgeInsets.all(26),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.grey.withValues(alpha: 0.06)),
                  ),
                  child: Column(
                    children: [
                      Text('INV-${invoice.id.substring(0, 6).toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 13, letterSpacing: 1.0)),
                      const SizedBox(height: 8),
                      Text(totalAmountText, style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Color(0xFF1F2937), letterSpacing: -1)),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFF10B981).withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)),
                        child: Text(invoice.status.name.toUpperCase(), style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 0.5)),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 14),
                
                // ITEMIZED LEDGER DETAILS CARD
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.grey.withValues(alpha: 0.06)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('ACCOUNT INFORMATION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.0)),
                      const SizedBox(height: 16),
                      _rowLine('Client', currentClient?.name ?? 'Corporate Partner'),
                      _rowLine('Project Reference', currentProject?.projectName ?? 'Scope Contract'),
                      _rowLine('Issue Date', formattedDate),
                      _rowLine('Rate Tier', '\$${((currentProject?.rateInCents ?? 0) / 100).toStringAsFixed(0)}/hr'),
                      
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      
                      const Text('ITEM DETAILS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.0)),
                      const SizedBox(height: 14),
                      entriesAsync.when(
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (e, st) => Text('Error: $e'),
                        data: (allEntries) {
                          final billedEntries = allEntries.where((entry) => invoice.timeEntryIds.contains(entry.id)).toList();
                          return ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: billedEntries.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final entry = billedEntries[index];
                              final duration = entry.endTime != null ? entry.endTime!.difference(entry.startTime) : Duration.zero;
                              final hourUnits = (duration.inMinutes / 60);
                              final itemCash = (hourUnits * (currentProject?.rateInCents ?? 0) / 100);
                              
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('📅  ${entry.startTime.month}/${entry.startTime.day} (${hourUnits.toStringAsFixed(1)} hrs)', style: const TextStyle(color: Colors.black54, fontSize: 13, fontWeight: FontWeight.w500)),
                                  Text('\$${itemCash.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1F2937))),
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
                
                // ACTION LAYER BUTTONS ROW
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await InvoicePdfService.compileAndDownloadInvoicePdf(
                            invoice: invoice, project: currentProject, client: currentClient, currencySymbol: '\$',
                          );
                        },
                        icon: const Icon(Icons.file_download_outlined, size: 16),
                        label: const Text('Download PDF', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF1F2937),
                          side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: invoice.status == InvoiceStatus.paid ? null : () async {
                          final next = invoice.status == InvoiceStatus.draft ? InvoiceStatus.sent : InvoiceStatus.paid;
                          await ref.read(invoiceRepositoryProvider).updateInvoice(
                            Invoice(
                              id: invoice.id, projectId: invoice.projectId, status: next,
                              timeEntryIds: invoice.timeEntryIds, createdDate: invoice.createdDate, totalAmountInCents: invoice.totalAmountInCents,
                              invoiceDescription: invoice.invoiceDescription,
                            ),
                          );
                          if (context.mounted) Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryIndigo, foregroundColor: Colors.white, elevation: 0,
padding: const EdgeInsets.symmetric(vertical: 16),
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
),
child: Text(invoice.status == InvoiceStatus.draft ? 'Share Invoice' : 'Record Payment', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
),
),
],
)
],
),
);
},
),
);
}
Widget _rowLine(String left, String right) {
return Padding(
padding: const EdgeInsets.symmetric(vertical: 6),
child: Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
Text(left, style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
Text(right, style: const TextStyle(color: Color(0xFF1F2937), fontSize: 13, fontWeight: FontWeight.bold)),
],
),
);
}
}