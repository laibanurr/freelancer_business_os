import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freelancer_business_os/models/invoice.dart';
import 'package:freelancer_business_os/providers/stream_provider/invoice_stream_provider.dart';
import 'package:freelancer_business_os/providers/stream_provider/project_stream_provider.dart';
import 'package:freelancer_business_os/providers/stream_provider/client_stream_provider.dart';
import 'package:freelancer_business_os/providers/stream_provider/entries_for_project_provider.dart';
import 'package:freelancer_business_os/providers/repositories_provider/invoice_repo_provider.dart';
import 'package:freelancer_business_os/providers/state_provider/theme_provider.dart';
import 'package:freelancer_business_os/providers/stream_provider/user_profile_stream_provider.dart'; 

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
    final currentClient = currentProject == null
        ? null
        : clients.where((c) => c.id == currentProject.clientId).firstOrNull;
        
    const primaryIndigo = Color(0xFF4F46E5);

    
    final isDarkMode = ref.watch(themeProvider);
    final backgroundColor = isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9); 
    final cardColor = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final textSubColor = isDarkMode ? Colors.white70 : Colors.black54;

    
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'unknown_user';
    final profileAsync = ref.watch(userProfileStreamProvider(uid));
    final currency = profileAsync.value?.selectedCurrencySymbol ?? '\$';

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new, size: 20, color: isDarkMode ? Colors.white70 : Colors.black87),
        ),
        title: Text('Invoice Receipt', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 20)),
      ),
      
      
      
      
      bottomNavigationBar: invoice.status == InvoiceStatus.paid 
          ? null 
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: ElevatedButton(
                onPressed: () async {
                  final nextStatus = invoice.status == InvoiceStatus.draft 
                      ? InvoiceStatus.sent 
                      : InvoiceStatus.paid;

                  await ref.read(invoiceRepositoryProvider).updateInvoice(
                        Invoice(
                          id: invoice.id,
                          projectId: invoice.projectId,
                          status: nextStatus, 
                          timeEntryIds: invoice.timeEntryIds,
                          createdDate: invoice.createdDate,
                          totalAmountInCents: invoice.totalAmountInCents,
                          invoiceDescription: invoice.invoiceDescription,
                        ),
                      );
                  if (context.mounted) Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryIndigo,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(
                  invoice.status == InvoiceStatus.draft ? 'Mark as Sent' : 'Record Payment', 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                ),
              ),
            ),
            
      body: invoiceAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: primaryIndigo)),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
        data: (invoices) {
          final statusColor = getStatusColor(invoice.status);
          final formattedDate = '${invoice.createdDate.month}/${invoice.createdDate.day}/${invoice.createdDate.year}';
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            child: ClipPath(
              clipper: TicketStubClipper(), 
              child: Container(
                color: cardColor, 
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 32, left: 24, right: 24, bottom: 20),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: primaryIndigo.withValues(alpha: 0.06), shape: BoxShape.circle),
                            child: const Icon(Icons.receipt_long_outlined, color: primaryIndigo, size: 32),
                          ),
                          const SizedBox(height: 16),
                          Text('INV-${invoice.id.substring(0, 6).toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey, fontSize: 14, letterSpacing: 0.5)),
                          const SizedBox(height: 8),
                          Text('$currency${(invoice.totalAmountInCents / 100).toStringAsFixed(2)}', style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold, color: textColor, letterSpacing: -1)),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: statusColor.withValues(alpha: 0.2), width: 1),
                            ),
                            child: Text(getStatusText(invoice.status), style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 0.5)),
                          ),
                        ],
                      ),
                    ),
                    _buildTicketDivider(isDarkMode),
                    Padding(
                      padding: const EdgeInsets.only(top: 20, left: 24, right: 24, bottom: 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('BILLING METADATA', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.0)),
                          const SizedBox(height: 16),
                          _buildMetadataRow('Project Work', currentProject?.projectName ?? '...', textColor),
                          _buildMetadataRow('Target Client', currentClient?.name ?? '...', textColor),
                          _buildMetadataRow('Issue Date', formattedDate, textColor),
                          _buildMetadataRow('Rate Class', '$currency${((currentProject?.rateInCents ?? 0) / 100).toStringAsFixed(2)}/hr', textColor),
                          
                          if (invoice.invoiceDescription != null && invoice.invoiceDescription!.isNotEmpty) ...[
                            const SizedBox(height: 20),
                            Divider(color: Colors.grey.withValues(alpha: 0.2)),
                            const SizedBox(height: 14),
                            const Row(
                              children: [
                                Icon(Icons.auto_awesome, size: 14, color: primaryIndigo),
                                SizedBox(width: 6),
                                Text('AI OPTIMIZED BILLING SUMMARY STATEMENT:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: primaryIndigo, letterSpacing: 0.5)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              invoice.invoiceDescription!,
                              style: TextStyle(color: textColor.withValues(alpha: 0.7), fontSize: 12.5, height: 1.5, fontStyle: FontStyle.italic),
                            ),
                          ],
                          
                          const SizedBox(height: 24),
                          Divider(color: Colors.grey.withValues(alpha: 0.2)),
                          const SizedBox(height: 16),
                          const Text('ITEMISED BILLABLE HISTORY', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.0)),
 SizedBox(height: 12),
entriesAsync.when(
loading: () => const Center(child: CircularProgressIndicator()),
error: (e, st) => Text('Error: $e'),
data: (allEntries) {
final billedEntries = allEntries.where((entry) => invoice.timeEntryIds.contains(entry.id)).toList();
return ListView.separated(
shrinkWrap: true,
physics: const NeverScrollableScrollPhysics(),
itemCount: billedEntries.length,
separatorBuilder: (_, __) => const SizedBox(height: 8),
itemBuilder: (context, index) {
final entry = billedEntries[index];
final duration = entry.endTime != null ? entry.endTime!.difference(entry.startTime) : Duration.zero;
final dayString = '${entry.startTime.month}/${entry.startTime.day}';
final rowCash = ((duration.inMinutes / 60) * (currentProject?.rateInCents ?? 0) / 100);
return Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
Text('📅  $dayString (${(duration.inMinutes / 60).toStringAsFixed(1)} hrs)', style: TextStyle(color: textSubColor, fontSize: 14)),
Text('$currency${rowCash.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: textColor)),
],
);
},
);
},
),
],
),
),
],
),
),
),
);
},
),
);
}
Widget _buildMetadataRow(String label, String value, Color textCol) {
return Padding(
padding: const EdgeInsets.symmetric(vertical: 6.0),
child: Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [ Text(label, style: TextStyle(color: Colors.grey, fontSize: 14)),
Text(value, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: textCol)),
],
),
);
}
Widget _buildTicketDivider(bool isDark) {
return Row(
children: [
const SizedBox(width: 14),
Expanded(
child: LayoutBuilder(
builder: (context, constraints) {
return Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: List.generate(
(constraints.constrainWidth() / 8).floor(),
(index) => SizedBox(width: 4, height: 1, child: DecoratedBox(decoration: BoxDecoration(color: isDark ? Colors.white.withValues(alpha: 0.15) : Colors.grey.withValues(alpha: 0.3)))),
),
);
},
),
),
const SizedBox(width: 14),
],
);
}
}
class TicketStubClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    const radius = 14.0;
    final cutTop = size.height * 0.38;
    path.lineTo(0.0, cutTop);
    path.arcToPoint(
      Offset(0.0, cutTop + (radius * 2)),
      radius: const Radius.circular(radius),
      clockwise: true,
    );
    path.lineTo(0.0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, cutTop + (radius * 2));
    path.arcToPoint(
      Offset(size.width, cutTop),
      radius: const Radius.circular(radius),
      clockwise: true,
    );
    path.lineTo(size.width, 0.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
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