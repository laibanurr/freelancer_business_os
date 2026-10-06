import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freelancer_business_os/models/user_profile.dart';
import 'package:freelancer_business_os/repositories/userprofile_repo.dart';

class FirebaseUserProfileRepository implements UserProfileRepository {
  final CollectionReference _profile =
      FirebaseFirestore.instance.collection('user_profiles');

  @override
  Future<UserProfile> fetchProfile(String userId) async {
    final doc = await _profile.doc(userId).get();
    if (!doc.exists) return UserProfile.defaultProfile(userId);
    return UserProfile.fromMap(doc.data() as Map<String, dynamic>);
  }

  @override
  Future<void> saveProfile(UserProfile userProfile) async {
    await _profile.doc(userProfile.id).set(userProfile.toMap());
  }

  @override
  Stream<UserProfile> watchUserProfile(String userId) {
    return _profile.doc(userId).snapshots().map((doc) => doc.exists
        ? UserProfile.fromMap(doc.data() as Map<String, dynamic>)
        : UserProfile.defaultProfile(userId));
  }
}
