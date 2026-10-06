import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freelancer_business_os/models/invoice.dart';
import 'package:freelancer_business_os/providers/repositories_provider/invoice_repo_provider.dart';
import 'package:freelancer_business_os/providers/repositories_provider/time_entry_repo_provider.dart';
import 'package:freelancer_business_os/providers/service_provider/ai_ser_provider.dart';
import 'package:freelancer_business_os/providers/stream_provider/project_stream_provider.dart';
import 'package:freelancer_business_os/providers/stream_provider/invoice_stream_provider.dart';
import 'package:freelancer_business_os/providers/stream_provider/client_stream_provider.dart';
import 'package:freelancer_business_os/providers/state_provider/theme_provider.dart'; 

class GenerateInvoiceScreen extends ConsumerStatefulWidget {
  const GenerateInvoiceScreen({super.key});

  @override
  ConsumerState<GenerateInvoiceScreen> createState() => _GenerateInvoiceScreenState();
}

class _GenerateInvoiceScreenState extends ConsumerState<GenerateInvoiceScreen> {
  String? _selectedProjectId;
  bool _isAiAuditing = false;
  String _generatedBillingSummary = '';

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(projectsStreamProvider);
    final existingInvoicesAsync = ref.watch(invoicesStreamProvider);
    final clientsAsync = ref.watch(clientsStreamProvider);
    const primaryIndigo = Color(0xFF4F46E5);

    
    final isDarkMode = ref.watch(themeProvider);
    final backgroundColor = isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cardColor = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new, size: 20, color: isDarkMode ? Colors.white70 : Colors.black87),
        ),
        title: Text(
          'Generate Invoice',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: projectsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator(color: primaryIndigo)),
            error: (error, stackTrace) => Center(child: Text('Error: $error', style: const TextStyle(color: Colors.redAccent))),
            data: (projects) {
              final isIdValid = projects.any((p) => p.id == _selectedProjectId);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  
                  
                  
                  DropdownButtonFormField<String>(
                    dropdownColor: cardColor,
                    style: TextStyle(color: textColor),
                    initialValue: isIdValid ? _selectedProjectId : null,
                    onTap: () => FocusScope.of(context).unfocus(),
                    decoration: InputDecoration(
                      labelText: 'Select Project Workspace',
                      labelStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                      floatingLabelStyle: const TextStyle(color: primaryIndigo),
                      filled: true,
                      fillColor: cardColor,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2), width: 1.0),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder:  OutlineInputBorder(
                        borderSide: BorderSide(color: primaryIndigo, width: 2.0),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: projects
                        .map((p) => DropdownMenuItem<String>(
                              value: p.id,
                              child: Text(p.projectName, style: const TextStyle(fontSize: 15)),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedProjectId = value;
                          _generatedBillingSummary = '';
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  
                  
                  
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: primaryIndigo.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: primaryIndigo.withValues(alpha: 0.15), width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.auto_awesome, color: primaryIndigo, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'AI Invoice Optimization Auditor',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: primaryIndigo.withValues(alpha: 0.9)),
                            ),
                            if (_isAiAuditing) ...[
                              const Spacer(),
                              const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: primaryIndigo),
                              ),
                            ]
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Select a project contract workspace. Gemini will automatically analyze your log metrics data and generate a professional, corporate billing statement summary description.',
                          style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.4),
                        ),
                        if (_selectedProjectId != null) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.check_circle_outline, size: 14, color: primaryIndigo.withValues(alpha: 0.6)),
                              const SizedBox(width: 6),
                              const Text('Unbilled hour logs captured safely', style: TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        ],
                        if (_generatedBillingSummary.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          const Divider(),
                          const SizedBox(height: 10),
                          const Text('COMPILED LINE-ITEM ACCOUNTING STATEMENT:',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: primaryIndigo, letterSpacing: 0.5)),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
                            ),
                            child: Text(
                              _generatedBillingSummary,
                              style: TextStyle(
                                  color: textColor.withValues(alpha: 0.9),
                                  fontSize: 13,
                                  height: 1.4,
                                  fontStyle: FontStyle.italic),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  
                  
                  
                  if (_selectedProjectId != null)
                    ElevatedButton(
                      onPressed: _isAiAuditing
                          ? null
                          : () async {
                              setState(() {
                                _isAiAuditing = true;
                              });
                              try {
                                final project = projects.firstWhere((p) => p.id == _selectedProjectId);
                                final clients = clientsAsync.value ?? [];
                                final client = clients.any((c) => c.id == project.clientId)
                                    ? clients.firstWhere((c) => c.id == project.clientId)
                                    : null;
                                final targetClientName = client?.name ?? 'Corporate Partner';

                                final timeEntryRepo = ref.read(timeEntryRepositoryProvider);
                                final allEntries = await timeEntryRepo.getTimeEntriesForProject(_selectedProjectId!);

                                final existingInvoices = existingInvoicesAsync.value ?? [];
                                final alreadyBilledIds = existingInvoices.expand((inv) => inv.timeEntryIds).toSet();

                                final unBilled = allEntries
                                    .where((e) => e.endTime != null && !alreadyBilledIds.contains(e.id))
                                    .toList();

                                if (!context.mounted) return;
                                if (unBilled.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('No unbilled hours discovered for this project contract workspace.'),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                  return;
                                }

                                final totalHours = unBilled.fold<double>(
                                  0.0,
                                  (total, e) => total + e.endTime!.difference(e.startTime).inMinutes / 60,
                                );
                                final totalCents = (totalHours * project.rateInCents).round();

                                String finalBillSummary = '';
                                try {
                                  finalBillSummary = await ref.read(aiServiceProvider).auditInvoiceSummary(
                                    totalHours.toStringAsFixed(1),
                                    targetClientName,
                                  );
                                } catch (aiError) {
                                  finalBillSummary =
                                      'Professional consulting services rendered for project execution parameters ledger. Total billable volume calculates to ${totalHours.toStringAsFixed(1)} operational hours allocated toward milestone integrations, system deployment protocols, and core quality assurance validation check routines.';
                                }

                                setState(() {
                                  _generatedBillingSummary = finalBillSummary;
                                });

                                await Future.delayed(const Duration(milliseconds: 1500));
                                if (!context.mounted) return;

                                final newId = FirebaseFirestore.instance.collection('invoices').doc().id;

                                await ref.read(invoiceRepositoryProvider).addInvoice(
                                  Invoice(
                                    id: newId,
                                    projectId: project.id,
                                    status: InvoiceStatus.draft,
                                    timeEntryIds: unBilled.map((e) => e.id).toList(),
                                    createdDate: DateTime.now(),
                                    totalAmountInCents: totalCents,
                                    invoiceDescription: finalBillSummary,
                                  ),
                                );

                                if (context.mounted) Navigator.pop(context);
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Invoice Generation Failed: $e'),
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                                }
                              } finally {
                                setState(() {
                                  _isAiAuditing = false;
                                });
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryIndigo,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isAiAuditing
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text(
                              'Compile & Generate Invoice',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
