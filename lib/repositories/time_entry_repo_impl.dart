import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freelancer_business_os/models/time_entry.dart';
import 'package:freelancer_business_os/repositories/time_entry_repository.dart';

class FirebaseTimeEntryRepository implements TimeEntryRepository {
  final CollectionReference _timeEntryCollection = FirebaseFirestore.instance
      .collection('timeEntries');

  @override
  Future<void> addTimeEntry(TimeEntry entry) async {
    await _timeEntryCollection.add(entry.toMap());
  }

  @override
  Future<void> deleteTimeEntry(String id) async {
    await _timeEntryCollection.doc(id).delete();
  }

  @override
  Future<List<TimeEntry>> getTimeEntriesForProject(String projectId) async {
    final snapshot = await _timeEntryCollection
        .where('projectId', isEqualTo: projectId)
        .get();
    return snapshot.docs
        .map((doc) => TimeEntry.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> updateTimeEntry(TimeEntry entry) async {
    await _timeEntryCollection.doc(entry.id).update(entry.toMap());
  }
}
