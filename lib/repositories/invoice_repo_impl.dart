import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freelancer_business_os/models/invoice.dart';
import 'package:freelancer_business_os/repositories/invoice_repository.dart';

class FirebaseInvoiceRepository implements InvoiceRepository {
  final CollectionReference _invoiceCollection = FirebaseFirestore.instance
      .collection('invoices');
  @override
  Future<void> addInvoice(Invoice invoice) async {
    await _invoiceCollection.add(invoice.toMap());
  }

  @override
  Future<void> deleteInvoice(String id) async {
    await _invoiceCollection.doc(id).delete();
  }

  @override
  Future<List<Invoice>> getAllInvoices() async {
    final snapshot = await _invoiceCollection.get();
    return snapshot.docs
        .map((doc) => Invoice.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<Invoice>> getInvoicesForProject(String projectId) async {
    final snapshot = await _invoiceCollection
        .where('projectId', isEqualTo: projectId)
        .get();
    return snapshot.docs
        .map((doc) => Invoice.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> updateInvoice(Invoice invoice) async {
    await _invoiceCollection.doc(invoice.id).update(invoice.toMap());
  }

  @override
  Stream<List<Invoice>> watchInvoices() {
    return _invoiceCollection.snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => Invoice.fromMap((doc.data() as Map<String, dynamic>)))
          .toList(),
    );
  }
}
