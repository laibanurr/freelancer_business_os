import 'package:freelancer_business_os/models/user_profile.dart';

abstract class UserProfileRepository {
  Future<UserProfile> fetchProfile(String userId);
  Future<void> saveProfile(UserProfile userProfile);
  Stream<UserProfile> watchUserProfile(String userId);
}