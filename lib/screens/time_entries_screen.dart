import 'dart:async';import 'package:cloud_firestore/cloud_firestore.dart';import 'package:flutter/material.dart';import 'package:flutter_riverpod/flutter_riverpod.dart';import 'package:freelancer_business_os/models/project.dart';import 'package:freelancer_business_os/models/time_entry.dart';import 'package:freelancer_business_os/providers/repositories_provider/time_entry_repo_provider.dart';import 'package:freelancer_business_os/providers/stream_provider/entries_for_project_provider.dart';import 'package:freelancer_business_os/providers/state_provider/theme_provider.dart'; 
class TimeEntriesScreen extends ConsumerStatefulWidget {
  final Project project;
  const TimeEntriesScreen({super.key, required this.project});
  @override
  ConsumerState<TimeEntriesScreen> createState() => _TimeEntriesScreenState();
}
class _TimeEntriesScreenState extends ConsumerState<TimeEntriesScreen> {
  Timer? _ticker;
  @override
  void dispose() {
    _ticker?.cancel(); 
    super.dispose();
  }
  void _ensureTicking(bool shouldTick) {
    if (shouldTick && _ticker == null) {
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
    } else if (!shouldTick && _ticker != null) {
      _ticker!.cancel();
      _ticker = null;
    }
  }
  String formatDuration(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inHours)}:${two(d.inMinutes % 60)}:${two(d.inSeconds % 60)}';
  }
  @override
  Widget build(BuildContext context) {
    final entriesAsync = ref.watch(timeEntriesForProjectProvider(widget.project.id));
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
          widget.project.projectName,
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: entriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: primaryIndigo)),
        error: (error, stack) => Center(child: Text('Error: $error', style: const TextStyle(color: Colors.redAccent))),
        data: (entries) {
          TimeEntry? runningEntry;
          for (final e in entries) {
            if (e.endTime == null) runningEntry = e;
          }
          _ensureTicking(runningEntry != null);
          final pastEntries = entries.where((e) => e.endTime != null).toList();
          final isTimerRunning = runningEntry != null;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                decoration: BoxDecoration(
                  color: isTimerRunning ? primaryIndigo.withValues(alpha: 0.03) : cardColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isTimerRunning ? primaryIndigo.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.15),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      isTimerRunning ? 'ACTIVE TRACKING SESSION' : 'TIMER DISENGAGED',
                      style: TextStyle(
                        color: isTimerRunning ? primaryIndigo : Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isTimerRunning
                          ? formatDuration(DateTime.now().difference(runningEntry.startTime))
                          : '00:00:00',
                      style: TextStyle(
                        fontSize: 42, 
                        fontWeight: FontWeight.bold,
                        color: isTimerRunning ? primaryIndigo : textColor,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: 160,
                      child: ElevatedButton(
                        onPressed: () async {
                          final repo = ref.read(timeEntryRepositoryProvider);
                          if (runningEntry != null) {
                            final updated = TimeEntry(
                              startTime: runningEntry.startTime,
                              id: runningEntry.id,
                              projectId: runningEntry.projectId,
                              endTime: DateTime.now(),
                            );
                            await repo.updateTimeEntry(updated); 
                          } else {
                            final newId = FirebaseFirestore.instance.collection('entries').doc().id;
                            final entry = TimeEntry(
                              startTime: DateTime.now(),
                              id: newId,
                              projectId: widget.project.id,
                              endTime: null,
                            );
                            await repo.addTimeEntry(entry); 
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isTimerRunning ? Colors.redAccent : primaryIndigo,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)), 
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(isTimerRunning ? Icons.stop_rounded : Icons.play_arrow_rounded, size: 20),
                            const SizedBox(width: 6),
                            Text(isTimerRunning ? 'Stop' : 'Start', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: Text(
                  'Completed Sessions History',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
                ),
              ),
              Expanded(
                child: pastEntries.isEmpty
                    ? Center(
                        child: Text(
                          'No history recorded yet.',
                          style: TextStyle(color: Colors.grey.withValues(alpha: 0.8), fontSize: 14),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 24),
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemCount: pastEntries.length,
                        itemBuilder: (context, index) {
                          final entry = pastEntries[index]; 
                          final duration = entry.endTime!.difference(entry.startTime);
                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDarkMode ? Colors.white.withValues(alpha: 0.08) : Colors.grey.withValues(alpha: 0.15), 
                                width: 1
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.grey.withValues(alpha: 0.05),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.history_toggle_off, color: isDarkMode ? Colors.grey : Colors.grey.shade600, size: 20),
                                ),
                                const SizedBox(width: 16),
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
'${entry.startTime.month}/${entry.startTime.day}/${entry.startTime.year}',
style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textColor),
),
const SizedBox(height: 4),
Text(
'${(duration.inMinutes / 60).toStringAsFixed(1)} hrs logged',
style: const TextStyle(color: Colors.grey, fontSize: 13),
),
],
),
),
IconButton(
icon: const Icon(Icons.auto_awesome, color: primaryIndigo, size: 18),
tooltip: 'Generate AI Work Description Summary',
onPressed: () {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text('✨ AI optimization is tracking your ${(duration.inMinutes / 60).toStringAsFixed(1)} hr log!'),
behavior: SnackBarBehavior.floating,
),
);
},
),
],
),
);
},
),
),
],
);
},
),
);
}
}
