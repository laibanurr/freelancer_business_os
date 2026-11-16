import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freelancer_business_os/models/invoice.dart';
import 'package:freelancer_business_os/providers/auth_state_provider.dart';
import 'package:freelancer_business_os/providers/repositories_provider/invoice_repo_provider.dart';

final invoicesStreamProvider = StreamProvider.autoDispose<List<Invoice>>((ref) {
  
  ref.watch(authStateProvider);
  final repo = ref.watch(invoiceRepositoryProvider);
  return repo.watchInvoices();
});