import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freelancer_business_os/repositories/project_repo_imp.dart';
import 'package:freelancer_business_os/repositories/project_repository.dart';

final projectRepositoryProvider = Provider<ProjectRepository>(
  (ref) => FirebaseProjectRepository(),
);
