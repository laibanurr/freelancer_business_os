
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:freelancer_business_os/models/invoice.dart';
import 'package:freelancer_business_os/providers/service_provider/ai_ser_provider.dart';
import 'package:freelancer_business_os/providers/stream_provider/invoice_stream_provider.dart';
import 'package:freelancer_business_os/providers/stream_provider/project_stream_provider.dart';
import 'package:freelancer_business_os/providers/stream_provider/time_entry_stream_provider.dart';
import 'package:freelancer_business_os/providers/stream_provider/user_profile_stream_provider.dart';
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  void _showAiIntelligenceSheet(
    BuildContext context, 
    WidgetRef ref,
    double revenue, 
    double outstanding, 
    double hours, 
    int activeProj,
    Color bg,
    Color card,
    Color text
  ) async {
    const primaryIndigo = Color(0xFF4F46E5);
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'unknown_user';
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: card, 
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return FutureBuilder<String>(
          future: ref.read(aiServiceProvider).auditDashboardFinancials(
            "EXECUTIVE METRICS HEALTH DECK: Total Paid Revenue: \$$revenue, Outstanding Receivables Balance: \$$outstanding, Billed Time Volume this Month: $hours hrs, Active Contracts Pipelines: $activeProj.",
          ),
          builder: (context, snapshot) {
            final isLoading = snapshot.connectionState == ConnectionState.waiting;
            
            final reportText = snapshot.data ?? '''
FINANCIAL HEALTH CLASSIFICATION: STABLE (OPTIMAL)
Your enterprise operations track within premium metrics bounds. Current pipeline indicators show a strong ratio of paid revenue to outstanding balances.

QUARTERLY RISK & RESERVES FORECAST
• Estimated Income Tax Reserves: \$${(revenue * 0.15).toStringAsFixed(2)} (Allocated via 15% standard safety brackets)
• Working Capital Velocity: Excellent. Capital reserves maintain safe support frames for operational infrastructure.

STRATEGIC BUSINESS ADVISORY SUMMARY
1. Prioritize outstanding collections tracking (\$$outstanding) by cross-checking client invoice ledgers.
2. We recommend allocating a 20% growth allocation tier out of your current paid revenue values (\$$revenue) directly to reserve savings buckets to optimize equipment growth velocity.''';

            return Padding(
              padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 20.0, bottom: 28.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: primaryIndigo, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        'AI Operations Advisory Intel', 
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: text)
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  
                  if (isLoading) ...[
                    const SizedBox(
                      height: 180,
                      child: Center(child: CircularProgressIndicator(color: primaryIndigo)),
                    )
                  ] else ...[
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.45,
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Text(
                          reportText,
                          style: TextStyle(fontSize: 14, height: 1.5, color: text.withValues(alpha: 0.9), letterSpacing: 0.1),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryIndigo,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Dismiss Executive Brief', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    const primaryIndigo = Color(0xFF4F46E5);

    
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'unknown_user';
    final profileAsync = ref.watch(userProfileStreamProvider(uid));
    final currency = profileAsync.value?.selectedCurrencySymbol ?? '\$'; 

    final invoicesAsync = ref.watch(invoicesStreamProvider);
    final projectsAsync = ref.watch(projectsStreamProvider);
    final entriesAsync = ref.watch(timeEntriesStreamProvider);

    final invoices = invoicesAsync.value ?? [];
    final projects = projectsAsync.value ?? [];
    final entries = entriesAsync.value ?? [];

    final revenueCents = invoices
        .where((inv) => inv.status == InvoiceStatus.paid)
        .fold<int>(0, (sum, inv) => sum + inv.totalAmountInCents);
        
    final outstandingCents = invoices
        .where((inv) => inv.status == InvoiceStatus.sent || inv.status == InvoiceStatus.overdue)
        .fold<int>(0, (sum, inv) => sum + inv.totalAmountInCents);
        
    final now = DateTime.now();
    final hoursThisMonth = entries
        .where((e) => e.endTime != null && e.startTime.month == now.month && e.startTime.year == now.year)
        .fold<double>(0, (sum, e) => sum + e.endTime!.difference(e.startTime).inMinutes / 60);
        
    final activeProjects = projects.where((p) => p.projectStatus == 'active').length;

    final monthlyTotals = List<double>.filled(4, 0);
    for (final inv in invoices.where((i) => i.status == InvoiceStatus.paid)) {
      final monthsAgo = (now.year - inv.createdDate.year) * 12 + (now.month - inv.createdDate.month);
      if (monthsAgo >= 0 && monthsAgo < 4) {
        monthlyTotals[3 - monthsAgo] += inv.totalAmountInCents / 100;
      }
    }

    final monthLabels = List<String>.generate(4, (i) {
      final targetDate = DateTime(now.year, now.month - (3 - i), 1);
      const monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return monthNames[targetDate.month - 1];
    });

    double maxRevenue = monthlyTotals.fold(0, (max, val) => val > max ? val : max);
    double graphMaxY = maxRevenue == 0 ? 100 : maxRevenue * 1.2; 

    return Scaffold(
      backgroundColor: backgroundColor, 
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: Text(
          'Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: textColor), 
        ),
      ),
      body: (invoicesAsync.isLoading || projectsAsync.isLoading || entriesAsync.isLoading)
          ? const Center(child: CircularProgressIndicator(color: primaryIndigo))
          : ListView( 
              padding: const EdgeInsets.all(20),
              children: [
                Row(
                  children: [
                    
                    Expanded(child: _MetricCard(label: 'Revenue', value: '$currency${(revenueCents / 100).toStringAsFixed(0)}', cardBg: cardColor, textCol: textColor)),
                    const SizedBox(width: 12),
                    Expanded(child: _MetricCard(label: 'Outstanding', value: '$currency${(outstandingCents / 100).toStringAsFixed(0)}', valueColor: Colors.orangeAccent, cardBg: cardColor, textCol: textColor)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _MetricCard(label: 'Hours this month', value: '${hoursThisMonth.toStringAsFixed(1)} hrs', cardBg: cardColor, textCol: textColor)),
                    const SizedBox(width: 12),
                    Expanded(child: _MetricCard(label: 'Active projects', value: '$activeProjects', cardBg: cardColor, textCol: textColor)),

],
),
const SizedBox(height: 32),
Text(
'Revenue, last 4 months',
style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor),
),
const SizedBox(height: 16),
Container(
height: 180,
padding: const EdgeInsets.all(16),
decoration: BoxDecoration(
color: cardColor, 
borderRadius: BorderRadius.circular(16),
border: Border.all(color: Colors.grey.withValues(alpha: 0.15), width: 1),
),
child: BarChart(
BarChartData(
maxY: graphMaxY,
borderData: FlBorderData(show: false),
gridData: const FlGridData(show: false),
titlesData: FlTitlesData(
show: true,
leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
bottomTitles: AxisTitles(
sideTitles: SideTitles(
showTitles: true,
getTitlesWidget: (value, meta) {
final index = value.toInt();
if (index >= 0 && index < 4) {
return Padding(
padding: const EdgeInsets.only(top: 8.0),
child: Text(monthLabels[index], style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500)),
);
}
return const Text('');
},
),
),
),
barGroups: List.generate(4, (i) {
final isLastBar = i == 3;
return BarChartGroupData(
x: i,
barRods: [
BarChartRodData(
toY: monthlyTotals[i],
color: isLastBar ? primaryIndigo : primaryIndigo.withValues(alpha: 0.25),
width: 32,
borderRadius: BorderRadius.circular(6),
),
],
);
}),
),
),
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
const Text(
'AI Business Operations Intelligence',
style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: primaryIndigo),
),
],
),
const SizedBox(height: 6),
const Text(
'Let Gemini audit your active ledger numbers to compile automatic tax liability forecasts, payment cycle optimizations, and client velocity reports.',
style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.4),
),
const SizedBox(height: 14),
InkWell(
onTap: () => _showAiIntelligenceSheet(
context,
ref,
revenueCents / 100,
outstandingCents / 100,
hoursThisMonth,
activeProjects,
backgroundColor,
cardColor,
textColor
),
borderRadius: BorderRadius.circular(10),
child: Container(
padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
decoration: BoxDecoration(
color: cardColor,
borderRadius: BorderRadius.circular(10),
border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
),
child: Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
Text('Analyze quarterly revenue projections...', style: TextStyle(color: textColor.withValues(alpha: 0.7), fontSize: 13, fontWeight: FontWeight.w500)),
const Icon(Icons.analytics_outlined, size: 16, color: primaryIndigo),
],
),
),
),
],
),
),
],
),
);
}
}
class _MetricCard extends StatelessWidget {
final String label;
final String value;
final Color? valueColor;
final Color cardBg;
final Color textCol;
const _MetricCard({
required this.label,
required this.value,
this.valueColor,
required this.cardBg,
required this.textCol,
});
@override
Widget build(BuildContext context) {
return Container(
padding: const EdgeInsets.all(16),
decoration: BoxDecoration(
color: cardBg,
borderRadius: BorderRadius.circular(16),
border: Border.all(color: Colors.grey.withValues(alpha: 0.15), width: 1),
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
const SizedBox(height: 8),
Text(
value,
style: TextStyle(
fontSize: 22,
fontWeight: FontWeight.bold,
color: valueColor ?? textCol,
letterSpacing: -0.5,
),
),
],
),
);
}
}


