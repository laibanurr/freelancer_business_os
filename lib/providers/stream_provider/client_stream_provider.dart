import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freelancer_business_os/models/client.dart';
import 'package:freelancer_business_os/providers/repositories_provider/client_repo_provider.dart';

final clientsStreamProvider = 
StreamProvider<List<Client>>((ref){
    final repository = ref.watch(clientRepositoryProvider);
    return repository.watchClients();

});