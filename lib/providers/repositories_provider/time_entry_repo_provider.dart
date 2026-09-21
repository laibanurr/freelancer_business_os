import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freelancer_business_os/repositories/time_entry_repo_impl.dart';
import 'package:freelancer_business_os/repositories/time_entry_repository.dart';

final timeEntryRepositoryProvider = Provider<TimeEntryRepository>((ref) {
  return FirebaseTimeEntryRepository();
});
