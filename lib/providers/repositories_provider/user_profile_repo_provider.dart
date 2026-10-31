import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freelancer_business_os/providers/repositories_provider/client_repo_provider.dart';
import 'package:freelancer_business_os/repositories/userprofile_repo.dart';
import 'package:freelancer_business_os/repositories/userprofile_repo_impl.dart';

final userProfileRepositoryProvider = Provider<UserProfileRepository>((ref) {
  return FirebaseUserProfileRepository(
    firestore: ref.watch(firestoreProvider),
    auth: ref.watch(authProvider),
  );
});