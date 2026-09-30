import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:freelancer_business_os/models/invoice.dart';
import 'package:freelancer_business_os/providers/stream_provider/invoice_stream_provider.dart';
import 'package:freelancer_business_os/providers/stream_provider/project_stream_provider.dart';
import 'package:freelancer_business_os/providers/stream_provider/time_entry_stream_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        .where((inv) =>
            inv.status == InvoiceStatus.sent ||
            inv.status == InvoiceStatus.overdue)
        .fold<int>(0, (sum, inv) => sum + inv.totalAmountInCents);

    final now = DateTime.now();
    final hoursThisMonth = entries
        .where((e) =>
            e.endTime != null &&
            e.startTime.month == now.month &&
            e.startTime.year == now.year)
        .fold<double>(
            0,
            (sum, e) =>
                sum + e.endTime!.difference(e.startTime).inMinutes / 60);

    final activeProjects =
        projects.where((p) => p.projectStatus == 'active').length;

    // last 4 months, revenue from paid invoices, bucketed by createdDate
    final monthlyTotals = List<double>.filled(4, 0);
    for (final inv in invoices.where((i) => i.status == InvoiceStatus.paid)) {
      final monthsAgo = (now.year - inv.createdDate.year) * 12 +
          (now.month - inv.createdDate.month);
      if (monthsAgo >= 0 && monthsAgo < 4) {
        monthlyTotals[3 - monthsAgo] += inv.totalAmountInCents / 100;
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: (invoicesAsync.isLoading ||
              projectsAsync.isLoading ||
              entriesAsync.isLoading)
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: _MetricCard(
                              label: 'Revenue',
                              value:
                                  '\$${(revenueCents / 100).toStringAsFixed(0)}')),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _MetricCard(
                              label: 'Outstanding',
                              value:
                                  '\$${(outstandingCents / 100).toStringAsFixed(0)}')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                          child: _MetricCard(
                              label: 'Hours this month',
                              value: hoursThisMonth.toStringAsFixed(1))),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _MetricCard(
                              label: 'Active projects',
                              value: '$activeProjects')),
                    ],
                  ),
                  const SizedBox(height: 28),
                  const Text('Revenue, last 4 months',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 160,
                    child: BarChart(
                      BarChartData(
                        borderData: FlBorderData(show: false),
                        gridData: const FlGridData(show: false),
                        titlesData: const FlTitlesData(
                          leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                        ),
                        barGroups: List.generate(4, (i) {
                          return BarChartGroupData(x: i, barRods: [
                            BarChartRodData(
                              toY: monthlyTotals[i],
                              width: 28,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ]);
                        }),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  const _MetricCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 6),
          Text(value,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
