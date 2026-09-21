import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freelancer_business_os/repositories/client_repo_impl.dart';
import 'package:freelancer_business_os/repositories/client_repository.dart';

final clientRepositoryProvider = Provider<ClientRepository>((ref) {
  return FirebaseClientRepository();
});
