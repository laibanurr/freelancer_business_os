import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freelancer_business_os/models/time_entry.dart';
import 'package:freelancer_business_os/providers/repositories_provider/time_entry_repo_provider.dart';

final timeEntriesStreamProvider = StreamProvider<List<TimeEntry>>((ref) {
  final repository = ref.watch(timeEntryRepositoryProvider);
  return repository.watchTimeEntries();
});
