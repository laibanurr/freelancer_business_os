import 'package:freelancer_business_os/models/time_entry.dart';

abstract class TimeEntryRepository {
  Future<void> addTimeEntry(TimeEntry entry);
  Future<void> deleteTimeEntry(String id);
  Future<void> updateTimeEntry(TimeEntry entry);
  Future<List<TimeEntry>> getTimeEntriesForProject(String projectId);
  Stream<List<TimeEntry>> watchEntries();
}
