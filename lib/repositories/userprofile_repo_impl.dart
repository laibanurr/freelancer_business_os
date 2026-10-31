import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:freelancer_business_os/models/user_profile.dart';
import 'package:freelancer_business_os/repositories/userprofile_repo.dart';

class FirebaseUserProfileRepository implements UserProfileRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirebaseUserProfileRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _profileCollection =>
      _firestore.collection('user_profiles');

  String get _userId {
    final uid = _auth.currentUser?.uid ?? FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw StateError('No signed in user yet');
    }
    return uid;
  }

  @override
  Future<UserProfile> fetchProfile(String userId) async {
    final uid = _userId;

    if (userId != uid) {
      throw StateError('Security violation: Cannot access another user profile.');
    }

    final doc = await _profileCollection.doc(uid).get();
    final data = doc.data();

    if (data == null) {
      return UserProfile.defaultProfile(uid);
    }

    return UserProfile.fromMap({
      ...data,
      'id': doc.id,
    });
  }

  @override
  Future<void> saveProfile(UserProfile userProfile) async {
    final uid = _userId;

    // Uses merge: true so updating one field doesn't wipe other profile settings
    await _profileCollection.doc(uid).set(
      {
        ...userProfile.toMap(),
        'id': uid,
        'ownerUid': uid,
      },
      SetOptions(merge: true),
    );
  }

  @override
  Stream<UserProfile> watchUserProfile(String userId) {
    final uid = _userId;

    if (userId != uid) {
      throw StateError('Security violation: Cannot access another user profile.');
    }

    return _profileCollection.doc(uid).snapshots().map((doc) {
      final data = doc.data();

      if (data == null) {
        return UserProfile.defaultProfile(uid);
      }

      return UserProfile.fromMap({
        ...data,
        'id': doc.id,
      });
    });
  }
}