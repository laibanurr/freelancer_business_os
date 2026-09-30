import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freelancer_business_os/models/invoice.dart';
import 'package:freelancer_business_os/providers/repositories_provider/invoice_repo_provider.dart';
import 'package:freelancer_business_os/providers/repositories_provider/time_entry_repo_provider.dart';
import 'package:freelancer_business_os/providers/stream_provider/invoice_stream_provider.dart';
import 'package:freelancer_business_os/providers/stream_provider/project_stream_provider.dart';

class InvoiceGenerationScreen extends ConsumerStatefulWidget {
  const InvoiceGenerationScreen({super.key});

  @override
  ConsumerState<InvoiceGenerationScreen> createState() =>
      _InvoiceGenerationScreenState();
}

class _InvoiceGenerationScreenState
    extends ConsumerState<InvoiceGenerationScreen> {
  String? _selectedProjectId;
  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(projectsStreamProvider);
    final existingInvoicesAsync = ref.watch(invoicesStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Generate invoice')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: projectsAsync.when(
          data: (projects) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _selectedProjectId,
                  decoration: const InputDecoration(labelText: 'Projects'),
                  items: projects
                      .map((p) => DropdownMenuItem<String>(
                            value: p.id,
                            child: Text(p.projectName),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedProjectId = value);
                    }
                  },
                ),
                const SizedBox(height: 20),
                if (_selectedProjectId != null)
                  ElevatedButton(
                    onPressed: () async {
                      final project = projects.firstWhere(
                        (p) => p.id == _selectedProjectId,
                      );
                      final timeEntryRepo = ref.read(timeEntryRepositoryProvider);
                      final allEntries = await timeEntryRepo
                          .getTimeEntriesForProject(_selectedProjectId!);
                      final existingInvoices = existingInvoicesAsync.value ?? [];
                      final alreadyBilledIds = existingInvoices
                          .expand((inv) => inv.timeEntryIds)
                          .toSet();
                      final unBilled = allEntries
                          .where((e) =>
                              e.endTime != null &&
                              !alreadyBilledIds.contains(e.id))
                          .toList();

                      if (unBilled.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('No unbilled hours for this project'),
                          ),
                        );
                        return;
                      }

                      final totalHours = unBilled.fold<double>(
                        0,
                        (sum, e) =>
                            sum + e.endTime!.difference(e.startTime).inMinutes / 60,
                      );

                      final totalCents =
                          (totalHours * project.rateInCents).round();
                      final newId = FirebaseFirestore.instance
                          .collection('invoices')
                          .doc()
                          .id;
                      final invoice = Invoice(
                        id: newId,
                        projectId: project.id,
                        status: InvoiceStatus.draft,
                        timeEntryIds: unBilled.map((e) => e.id).toList(),
                        createdDate: DateTime.now(),
                        totalAmountInCents: totalCents,
                      );

                      await ref.read(invoiceRepositoryProvider).addInvoice(invoice);
                      if (context.mounted) Navigator.pop(context);
                    },
                    child: const Text('Generate'),
                  ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(child: Text('Error: $error')),
        ),
      ),
    );
  }
}
