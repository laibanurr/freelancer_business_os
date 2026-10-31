import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:freelancer_business_os/models/time_entry.dart';
import 'package:freelancer_business_os/repositories/time_entry_repository.dart';

class FirebaseTimeEntryRepository implements TimeEntryRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  
  FirebaseTimeEntryRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _timeEntryCollection =>
      _firestore.collection('timeEntries');

  
  String get _userId {
    final uid = _auth.currentUser?.uid ?? FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw StateError('No user is signed in.');
    }
    return uid;
  }

  @override
  String newTimeEntryId() => _timeEntryCollection.doc().id;

  @override
  Future<void> addTimeEntry(TimeEntry entry) async {
    final uid = _userId;
    await _timeEntryCollection.doc(entry.id).set({
      ...entry.toMap(),
      'ownerUid': uid,
    });
  }

  @override
  Future<void> deleteTimeEntry(String id) async {
    await _timeEntryCollection.doc(id).delete();
  }

  @override
  Future<void> updateTimeEntry(TimeEntry entry) async {
    final uid = _userId;
    
    await _timeEntryCollection.doc(entry.id).set(
      {
        ...entry.toMap(),
        'ownerUid': uid,
      },
      SetOptions(merge: true),
    );
  }

  @override
  Future<List<TimeEntry>> getTimeEntriesForProject(String projectId) async {
    final snapshot = await _timeEntryCollection
        .where('ownerUid', isEqualTo: _userId)
        .where('projectId', isEqualTo: projectId)
        .get();

    return snapshot.docs
        .map((doc) => TimeEntry.fromMap({...doc.data(), 'id': doc.id}))
        .toList();
  }

  @override
  Stream<List<TimeEntry>> watchTimeEntries() {
    return _timeEntryCollection
        .where('ownerUid', isEqualTo: _userId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => TimeEntry.fromMap({...doc.data(), 'id': doc.id}))
              .toList(),
        );
  }

  @override
  Stream<List<TimeEntry>> watchTimeEntriesForProject(String projectId) {
    return _timeEntryCollection
        .where('ownerUid', isEqualTo: _userId)
        .where('projectId', isEqualTo: projectId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => TimeEntry.fromMap({...doc.data(), 'id': doc.id}))
              .toList(),
        );
  }
}