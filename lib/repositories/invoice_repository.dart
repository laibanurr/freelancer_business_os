import 'package:freelancer_business_os/models/invoice.dart';

abstract class InvoiceRepository {
  Future<void> addInvoice(Invoice invoice);
  Future<void> deleteInvoice(String id);
  Future<void> updateInvoice(Invoice invoice);
  Future<List<Invoice>> getAllInvoices();
  Future<List<Invoice>> getInvoicesForProject(String projectId);
}
