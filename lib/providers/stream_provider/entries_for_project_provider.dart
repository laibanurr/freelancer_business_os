import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freelancer_business_os/models/time_entry.dart';
import 'package:freelancer_business_os/providers/repositories_provider/time_entry_repo_provider.dart';

final timeEntriesForProjectProvider =
    StreamProvider.family<List<TimeEntry>, String>((ref, projectId) {
  final repo = ref.watch(timeEntryRepositoryProvider);
  return repo.watchTimeEntriesForProject(projectId);
});