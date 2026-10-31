import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:freelancer_business_os/models/invoice.dart';
import 'package:freelancer_business_os/repositories/invoice_repository.dart';

class FirebaseInvoiceRepository implements InvoiceRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirebaseInvoiceRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _invoiceCollection =>
      _firestore.collection('invoices');

  String get _userId {
    final uid = _auth.currentUser?.uid ?? FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw StateError('No user is signed in.');
    }
    return uid;
  }

  @override
  String newInvoiceId() => _invoiceCollection.doc().id;

  @override
  Future<void> addInvoice(Invoice invoice) async {
    final uid = _userId;
    await _invoiceCollection.doc(invoice.id).set({
      ...invoice.toMap(),
      'ownerUid': uid,
    });
  }

  @override
  Future<void> deleteInvoice(String id) async {
    await _invoiceCollection.doc(id).delete();
  }

  @override
  Future<List<Invoice>> getAllInvoices() async {
    final snapshot = await _invoiceCollection
        .where('ownerUid', isEqualTo: _userId)
        .get();

    return snapshot.docs
        .map((doc) => Invoice.fromMap({...doc.data(), 'id': doc.id}))
        .toList();
  }

  @override
  Future<List<Invoice>> getInvoicesForProject(String projectId) async {
    final snapshot = await _invoiceCollection
        .where('ownerUid', isEqualTo: _userId)
        .where('projectId', isEqualTo: projectId)
        .get();

    return snapshot.docs
        .map((doc) => Invoice.fromMap({...doc.data(), 'id': doc.id}))
        .toList();
  }

  @override
  Future<void> updateInvoice(Invoice invoice) async {
    final uid = _userId;
    await _invoiceCollection.doc(invoice.id).set(
      {
        ...invoice.toMap(),
        'ownerUid': uid,
      },
      SetOptions(merge: true),
    );
  }

  @override
  Stream<List<Invoice>> watchInvoices() {
    return _invoiceCollection
        .where('ownerUid', isEqualTo: _userId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Invoice.fromMap({...doc.data(), 'id': doc.id}))
              .toList(),
        );
  }
}