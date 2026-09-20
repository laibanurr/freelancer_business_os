import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freelancer_business_os/models/client.dart';
import 'package:freelancer_business_os/repositories/client_repository.dart';

class FirebaseClientRepository implements ClientRepository {
  final CollectionReference _clientCollection = FirebaseFirestore.instance
      .collection('clients');
  @override
  Future<void> addClient(Client client) async {
    await _clientCollection.add(client.toMap());
  }

  @override
  Future<void> deleteClient(String id) async {
    await _clientCollection.doc(id).delete();
  }

  @override
  Future<List<Client>> getAllClients() async {
    final snapshot = await _clientCollection.get();
    return snapshot.docs
        .map((doc) => Client.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> updateClient(Client client) async {
    await _clientCollection.doc(client.id).update(client.toMap());
  }
}