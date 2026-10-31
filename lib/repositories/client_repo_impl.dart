import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:freelancer_business_os/models/client.dart';
import 'package:freelancer_business_os/repositories/client_repository.dart';
class FirebaseClientRepository implements ClientRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  
  FirebaseClientRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;
  CollectionReference<Map<String, dynamic>> get _clientCollection =>
      _firestore.collection('clients');
  String get _userId {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw StateError('No user is signed in.');
    }
    return uid;
  }
  @override
  Future<void> addClient(Client client) async {
    final uid = _userId;
    await _clientCollection.doc(client.id).set({
      ...client.toMap(),
      'ownerUid': uid,
    });
  }
  @override
  Future<void> deleteClient(String id) async {
    await _clientCollection.doc(id).delete();
  }
  @override
  Future<List<Client>> getAllClients() async {
    final snapshot = await _clientCollection
        .where('ownerUid', isEqualTo: _userId)
        .get();
    return snapshot.docs
        .map((doc) => Client.fromMap({
              ...doc.data(),
              'id': doc.id,
            }))
        .toList();
  }
  @override
  Future<void> updateClient(Client client) async {
    await _clientCollection.doc(client.id).update(client.toMap());
  }
  @override
  Stream<List<Client>> watchClients() {
    return _clientCollection
        .where('ownerUid', isEqualTo: _userId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Client.fromMap({
                    ...doc.data(),
                    'id': doc.id,
                  }))
              .toList(),
        );
  }

  @override
  String newClientId() {
      return _clientCollection.doc().id;

  }
}