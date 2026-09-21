import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freelancer_business_os/models/invoice.dart';
import 'package:freelancer_business_os/providers/repositories_provider/invoice_repo_provider.dart';

final invoicesStreamProvider = StreamProvider<List<Invoice>>((ref) {
  final repository = ref.watch(invoiceRepositoryProvider);

  return repository.watchInvoices();
});
