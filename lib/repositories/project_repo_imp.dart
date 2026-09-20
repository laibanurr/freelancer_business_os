import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freelancer_business_os/models/project.dart';
import 'package:freelancer_business_os/repositories/project_repository.dart';

class FirebaseProjectRepository implements ProjectRepository {
  final CollectionReference _projectCollection = FirebaseFirestore.instance
      .collection('projects');
  @override
  Future<void> addProject(Project project) async {
    await _projectCollection.add(project.toMap());
  }

  @override
  Future<void> deleteProject(String id) async {
    await _projectCollection.doc(id).delete();
  }

  @override
  Future<List<Project>> getAllProjects() async {
    final snapshot = await _projectCollection.get();
    return snapshot.docs
        .map((doc) => Project.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<Project>> getProjectsForClient(String clientId) async {
    final snapshot = await _projectCollection
        .where('clientId', isEqualTo: clientId)
        .get();
    return snapshot.docs
        .map((doc) => Project.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> updateProject(Project project) async {
    await _projectCollection.doc(project.id).update(project.toMap());
  }
}
