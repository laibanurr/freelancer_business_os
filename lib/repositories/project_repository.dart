import 'package:freelancer_business_os/models/invoice.dart';
import 'package:freelancer_business_os/models/project.dart';

abstract class ProjectRepository {
  Future<void> addProject(Project project);
  Future<List<Project>> getAllProjects();
  Future<List<Project>> getProjectsForClient(String clientId);
  Future<void> deleteProject(String id);
  Future<void> updateProject(Project project);
  Stream<List<Project>> watchProjects();
}
