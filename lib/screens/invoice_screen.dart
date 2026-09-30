import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freelancer_business_os/models/invoice.dart';
import 'package:freelancer_business_os/providers/stream_provider/invoice_stream_provider.dart';
import 'package:freelancer_business_os/providers/stream_provider/project_stream_provider.dart';
import 'package:freelancer_business_os/screens/generate_invoice_screen.dart';
import 'package:freelancer_business_os/screens/invoice_detailed_screen.dart';

class InvoicesScreen extends ConsumerWidget {
  const InvoicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoicesAsync = ref.watch(invoicesStreamProvider);
    final projectsAsync = ref.watch(projectsStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Invoices')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const InvoiceGenerationScreen()),
        ),
        child: const Icon(Icons.add),
      ),
      body: invoicesAsync.when(
        data: (invoices) {
          final projectNames = projectsAsync.maybeWhen(
            data: (projects) => {for (final p in projects) p.id: p.projectName},
            orElse: () => <String, String>{},
          );

          return ListView.separated(
            itemCount: invoices.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final invoice = invoices[index];
              final projectName = projectNames[invoice.projectId] ?? '...';
              final amountText =
                  '\$${(invoice.totalAmountInCents / 100).toStringAsFixed(2)}';

              return ListTile(
                title: Text(projectName,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(amountText),
                trailing: _StatusPill(status: invoice.status),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              InvoiceDetailedScreen(invoice: invoice)));
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
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
      InvoiceStatus.paid => (Colors.green, 'Paid'),
      InvoiceStatus.overdue => (Colors.red, 'Overdue'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 12)),
    );
  }
}
