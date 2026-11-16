import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freelancer_business_os/models/time_entry.dart';
import 'package:freelancer_business_os/providers/auth_state_provider.dart';
import 'package:freelancer_business_os/providers/repositories_provider/time_entry_repo_provider.dart';


final timeEntriesStreamProvider =
    StreamProvider.autoDispose<List<TimeEntry>>((ref) {
  ref.watch(authStateProvider); 
  final repository = ref.watch(timeEntryRepositoryProvider);
  return repository.watchTimeEntries();
});