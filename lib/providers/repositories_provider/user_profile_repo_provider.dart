import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freelancer_business_os/repositories/userprofile_repo.dart';
import 'package:freelancer_business_os/repositories/userprofile_repo_impl.dart';

final userProfileRepositoryProvider = Provider<UserProfileRepository>((ref) {
  return FirebaseUserProfileRepository();
});
