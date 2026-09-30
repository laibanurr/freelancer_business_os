import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freelancer_business_os/models/project.dart';
import 'package:freelancer_business_os/models/time_entry.dart';
import 'package:freelancer_business_os/providers/repositories_provider/time_entry_repo_provider.dart';
import 'package:freelancer_business_os/providers/stream_provider/entries_for_project_provider.dart';

class TimeEntriesScreen extends ConsumerStatefulWidget {
  final Project project;
  const TimeEntriesScreen({super.key, required this.project});

  @override
  ConsumerState<TimeEntriesScreen> createState() => _TimeEntriesscreenState();
}

class _TimeEntriesscreenState extends ConsumerState<TimeEntriesScreen> {
  Timer? _ticker;
  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _ensureTicking(bool shoulsTick) {
    if (shoulsTick && _ticker == null) {
      _ticker = Timer.periodic(Duration(seconds: 1), (_) => setState(() {}));
    } else if (!shoulsTick && _ticker != null) {
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
    final entriesAsync = ref.watch(
      timeEntriesForProjectProvider(widget.project.id),
    );
    return Scaffold(
      appBar: AppBar(title: Text(widget.project.projectName)),
      body: entriesAsync.when(
        data: (entries) {
          TimeEntry? runningEntry;
          for (final e in entries) {
            if (e.endTime == null) runningEntry = e;
          }
          _ensureTicking(runningEntry != null);
          final pastEntries = entries.where((e) => e.endTime != null).toList();
          return Column(
            children: [
              Padding(
                padding: EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Text(
                      runningEntry != null
                          ? formatDuration(
                              DateTime.now().difference(runningEntry.startTime),
                            )
                          : '00:00:00',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () async {
                        final repo = ref.read(timeEntryRepositoryProvider);
                        if (runningEntry != null) {
                          final updated = TimeEntry(
                            startTime: runningEntry.startTime,
                            id: runningEntry.id,
                            projectId: runningEntry.projectId,
                            endTime: DateTime.now(),
                          );
                          repo.updateTimeEntry(updated);
                        } else {
                          final newId = FirebaseFirestore.instance
                              .collection('entries')
                              .doc()
                              .id;
                          final entry = TimeEntry(
                            startTime: DateTime.now(),
                            id: newId,
                            projectId: widget.project.id,
                            endTime: null,
                          );
                          repo.addTimeEntry(entry);
                        }
                      },
                      child: Text(runningEntry != null ? 'Stop' : 'Start'),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.separated(
                  separatorBuilder: (context, index) => const Divider(),
                  itemCount: pastEntries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    final duration = entry.endTime!.difference(entry.startTime);
                    return ListTile(
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
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
