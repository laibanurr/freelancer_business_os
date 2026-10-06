
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freelancer_business_os/models/invoice.dart';
import 'package:freelancer_business_os/providers/state_provider/theme_provider.dart';
import 'package:freelancer_business_os/providers/stream_provider/invoice_stream_provider.dart';
import 'package:freelancer_business_os/providers/stream_provider/project_stream_provider.dart';
import 'package:freelancer_business_os/providers/stream_provider/user_profile_stream_provider.dart';
import 'package:freelancer_business_os/screens/generate_invoice_screen.dart';
import 'package:freelancer_business_os/screens/invoice_detailed_screen.dart'; 
class InvoicesScreen extends ConsumerWidget {
  const InvoicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoicesAsync = ref.watch(invoicesStreamProvider);
    final projectsAsync = ref.watch(projectsStreamProvider);
    const primaryIndigo = Color(0xFF4F46E5);

    
    final isDarkMode = ref.watch(themeProvider);
    final backgroundColor = isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cardColor = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'unknown_user';
    final profileAsync = ref.watch(userProfileStreamProvider(uid));
    final currency = profileAsync.value?.selectedCurrencySymbol ?? '\$';

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false, 
        title: Text(
          'Invoices Ledger',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: textColor),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'invoices_fab_tag',
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const GenerateInvoiceScreen()),
        ),
        backgroundColor: primaryIndigo,
        foregroundColor: Colors.white,
        elevation: 2,
        icon: const Icon(Icons.receipt_long_outlined),
        label: const Text('New Invoice', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: invoicesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: primaryIndigo)),
        error: (error, stack) => Center(child: Text('Error: $error', style: const TextStyle(color: Colors.redAccent))),
        data: (invoices) {
          if (invoices.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: primaryIndigo.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.receipt_outlined, size: 64, color: primaryIndigo),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No Invoices Discovered',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Automate your collections. Track hours on an active project first, then tap the button down below to run billing metrics scripts.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.4),
                    ),
                  ],
                ),
              ),
            );
          }
          final projectNames = projectsAsync.maybeWhen(
            data: (projects) => {for (final p in projects) p.id: p.projectName},
            orElse: () => <String, String>{},
          );
          final lifetimeEarningsCents = invoices
              .where((inv) => inv.status == InvoiceStatus.paid)
              .fold<int>(0, (sum, inv) => sum + inv.totalAmountInCents);

          return ListView.separated(
            padding: const EdgeInsets.only(top: 12, bottom: 96, left: 20, right: 20),
            itemCount: invoices.length + 1, 
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (index == 0) {
                
                
                
                return Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [primaryIndigo, Color(0xFF6366F1)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('TOTAL PAID REVENUE', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                      const SizedBox(height: 6),
                      Text(
                        
                        '$currency${(lifetimeEarningsCents / 100).toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                      ),
                    ],
                  ),
                );
              }
              final invoice = invoices[index - 1];
              final projectName = projectNames[invoice.projectId] ?? '...';
              
              
              final amountText = '$currency${(invoice.totalAmountInCents / 100).toStringAsFixed(2)}';
              final dateString = '${invoice.createdDate.month}/${invoice.createdDate.day}/${invoice.createdDate.year}';

              return Container(
                decoration: BoxDecoration(
                  color: cardColor, 
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDarkMode ? Colors.white.withValues(alpha: 0.08) : Colors.grey.withValues(alpha: 0.15), 
                    width: 1
                  ),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => InvoiceDetailedScreen(invoice: invoice)),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                projectName,
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey),
                                  const SizedBox(width: 6),
                                  Text(dateString, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                                  const SizedBox(width: 12),
                                  const Icon(Icons.payments_outlined, size: 14, color: Colors.grey),
                                  const SizedBox(width: 6),
                                  Text(amountText, style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black87, fontSize: 13, fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        _StatusPill(status: invoice.status),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final InvoiceStatus status;

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status) {
      InvoiceStatus.draft => (Colors.grey, 'Draft'),
      InvoiceStatus.sent => (Colors.orange, 'Sent'),
      InvoiceStatus.paid => (const Color(0xFF10B981), 'Paid'),
      InvoiceStatus.overdue => (Colors.redAccent, 'Overdue'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.15), width: 1),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}



