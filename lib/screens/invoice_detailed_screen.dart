import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freelancer_business_os/models/invoice.dart';
import 'package:freelancer_business_os/providers/repositories_provider/invoice_repo_provider.dart';
import 'package:freelancer_business_os/providers/stream_provider/client_stream_provider.dart';
import 'package:freelancer_business_os/providers/stream_provider/entries_for_project_provider.dart';
import 'package:freelancer_business_os/providers/stream_provider/invoice_stream_provider.dart';
import 'package:freelancer_business_os/providers/stream_provider/project_stream_provider.dart';

class InvoiceDetailedScreen extends ConsumerWidget {
  final Invoice invoice;
  const InvoiceDetailedScreen({super.key, required this.invoice});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoiceAsync = ref.watch(invoicesStreamProvider);
    final projectAsync = ref.watch(projectsStreamProvider);
    final clientAsync = ref.watch(clientsStreamProvider);
    final entriesAsync = ref.watch(
      timeEntriesForProjectProvider(invoice.projectId),
    );
    final projects = projectAsync.value ?? [];
    final clients = clientAsync.value ?? [];
    final currentProject =
        projects.where((p) => p.id == invoice.projectId).firstOrNull;
    final currentClient = currentProject == null
        ? null
        : clients.where((c) => c.id == currentProject.clientId).firstOrNull;

    return Scaffold(
      appBar: AppBar(title: Text('INVOICE DETAILS')),
      bottomNavigationBar: switch (invoice.status) {
        InvoiceStatus.paid => null,
        _ => Padding(
            padding: EdgeInsets.all(16.0),
            child: ElevatedButton(
                onPressed: () async {
                  final next = invoice.status == InvoiceStatus.draft
                      ? InvoiceStatus.sent
                      : InvoiceStatus.paid;
                  await ref.read(invoiceRepositoryProvider).updateInvoice(
                      Invoice(
                          id: invoice.id,
                          projectId: invoice.projectId,
                          status: next,
                          timeEntryIds: invoice.timeEntryIds,
                          createdDate: invoice.createdDate,
                          totalAmountInCents: invoice.totalAmountInCents));
                  if (context.mounted) Navigator.pop(context);
                },
                child: Text(invoice.status == InvoiceStatus.draft ?
                'Mark as sent' : 'Record payment')),
          )
      },
      body: invoiceAsync.when(
        data: (invoices) {
          final statusColor = getStatusColor(invoice.status);
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14.0),
            ),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text(
                    'INV-${(invoice.id).substring(0, 6).toUpperCase()}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 8),
                Text('TOTAL DUE '),
                SizedBox(height: 10),
                Text('\$${invoice.totalAmountInCents / 100}'),
                SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor, width: 1.5),
                  ),
                  child: Text(
                    getStatusText(invoice.status),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 12),
                const Divider(height: 1),
                Text(' CLIENT & PROJECT  ', style: TextStyle(fontSize: 22)),
                Text(
                  'Project :${currentProject?.projectName ?? 'loading project...'}',
                ),
                SizedBox(height: 5),
                Text('Client : ${currentClient?.name ?? 'loading client....'}'),
                SizedBox(height: 10),
                Text(
                  'Billed At: \$${((currentProject?.rateInCents ?? 0) / 100).toStringAsFixed(2)}/hr',
                ),
                const Divider(height: 1),
                entriesAsync.when(
                  error: (err, stackTrace) =>
                      Center(child: Text('Error loading work log $err')),
                  loading: () => Center(child: CircularProgressIndicator()),
                  data: (allEntries) {
                    final billedEntries = allEntries
                        .where(
                          (entry) => invoice.timeEntryIds.contains(entry.id),
                        )
                        .toList();
                    if (billedEntries.isEmpty) {
                      return const Center(child: Text('No entries found '));
                    }
                    final totalHours = billedEntries.fold<double>(0, (
                      sum,
                      entry,
                    ) {
                      final duration = entry.endTime != null
                          ? entry.endTime!.difference(entry.startTime)
                          : Duration.zero;
                      return sum + (duration.inMinutes / 60);
                    });

                    return Expanded(
                      child: Column(
                        children: [
                          Expanded(
                            child: ListView.separated(
                              separatorBuilder: (context, index) =>
                                  const Divider(),
                              itemCount: billedEntries.length,
                              itemBuilder: (BuildContext context, int index) {
                                final entry = billedEntries[index];
                                final duration = entry.endTime != null
                                    ? entry.endTime!.difference(entry.startTime)
                                    : Duration.zero;
                                return ListTile(
                                  leading: Icon(Icons.calendar_today, size: 18),
                                  title: Text(
                                    '${entry.startTime.month}/${entry.startTime.day}/${entry.startTime.year}',
                                  ),
                                  subtitle: Text(
                                    '${(duration.inMinutes / 60).toStringAsFixed(1)}hrs',
                                  ),
                                );
                              },
                            ),
                          ),
                          const Divider(height: 20),
                          const Text(
                            '============ TOTAL SUMMARY ============',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Total Tracked Time: ${totalHours.toStringAsFixed(1)} hrs',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Gross Amount Due: \$${(invoice.totalAmountInCents / 100).toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  String getStatusText(InvoiceStatus status) {
    return switch (status) {
      InvoiceStatus.draft => 'DRAFT',
      InvoiceStatus.paid => 'PAID',
      InvoiceStatus.sent => 'SENT',
      InvoiceStatus.overdue => 'OVERDUE',
    };
  }

  Color getStatusColor(InvoiceStatus status) {
    return switch (status) {
      InvoiceStatus.draft => Colors.orange,
      InvoiceStatus.sent => Colors.blue,
      InvoiceStatus.paid => Colors.green,
      InvoiceStatus.overdue => Colors.red,
    };
  }
}
