import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freelancer_business_os/providers/repositories_provider/client_repo_provider.dart';
import 'package:freelancer_business_os/repositories/invoice_repo_impl.dart';
import 'package:freelancer_business_os/repositories/invoice_repository.dart';

final invoiceRepositoryProvider = Provider<InvoiceRepository>((ref) {
  return FirebaseInvoiceRepository(
    firestore: ref.watch(firestoreProvider),
    auth: ref.watch(authProvider),
  );
});