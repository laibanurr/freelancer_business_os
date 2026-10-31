import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:freelancer_business_os/models/project.dart';
import 'package:freelancer_business_os/repositories/project_repository.dart';

class FirebaseProjectRepository implements ProjectRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirebaseProjectRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _projectCollection =>
      _firestore.collection('projects');

  String get _userId {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw StateError('No user is signed in.');
    }
    return uid;
  }

  @override
  String newProjectId() => _projectCollection.doc().id;

  @override
  Future<void> addProject(Project project) async {
    final uid = _userId;
    await _projectCollection.doc(project.id).set({
      ...project.toMap(),
      'ownerUid': uid,
    });
  }

  @override
  Future<void> deleteProject(String id) async {
    await _projectCollection.doc(id).delete();
  }

  @override
  Future<List<Project>> getAllProjects() async {
    final snapshot = await _projectCollection
        .where('ownerUid', isEqualTo: _userId)
        .get();

    return snapshot.docs
        .map((doc) => Project.fromMap({...doc.data(), 'id': doc.id}))
        .toList();
  }

  @override
  Future<List<Project>> getProjectsForClient(String clientId) async {
    final snapshot = await _projectCollection
        .where('ownerUid', isEqualTo: _userId)
        .where('clientId', isEqualTo: clientId)
        .get();

    return snapshot.docs
        .map((doc) => Project.fromMap({...doc.data(), 'id': doc.id}))
        .toList();
  }

  @override
  Future<void> updateProject(Project project) async {
    await _projectCollection.doc(project.id).update(project.toMap());
  }

  @override
  Stream<List<Project>> watchProjects() {
    return _projectCollection
        .where('ownerUid', isEqualTo: _userId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Project.fromMap({...doc.data(), 'id': doc.id}))
              .toList(),
        );
  }
}