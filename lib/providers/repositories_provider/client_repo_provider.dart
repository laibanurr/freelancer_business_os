
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freelancer_business_os/repositories/client_repo_impl.dart';
import 'package:freelancer_business_os/repositories/client_repository.dart';
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});
final authProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});
final clientRepositoryProvider = Provider<ClientRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final auth = ref.watch(authProvider);
  return FirebaseClientRepository(
    firestore: firestore,
    auth: auth,
  );
});