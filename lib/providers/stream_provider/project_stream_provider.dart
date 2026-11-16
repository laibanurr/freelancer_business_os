import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freelancer_business_os/models/project.dart';
import 'package:freelancer_business_os/providers/auth_state_provider.dart';
import 'package:freelancer_business_os/providers/repositories_provider/project_repo_provider.dart';

final projectsStreamProvider = StreamProvider.autoDispose<List<Project>>((ref) {
  ref.watch(authStateProvider);
  final repository = ref.watch(projectRepositoryProvider);
  return repository.watchProjects();
});