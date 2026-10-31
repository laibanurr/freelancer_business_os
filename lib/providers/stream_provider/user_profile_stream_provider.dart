import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freelancer_business_os/models/user_profile.dart';
import 'package:freelancer_business_os/providers/repositories_provider/user_profile_repo_provider.dart';
final userProfileStreamProvider =
    StreamProvider.autoDispose.family<UserProfile, String>((ref, userId) {
  final repo = ref.watch(userProfileRepositoryProvider);
  return repo.watchUserProfile(userId);
});