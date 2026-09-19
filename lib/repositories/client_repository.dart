import 'package:freelancer_business_os/models/client.dart';

abstract class ClientRepository {
  Future<void> addClient(Client client);
  Future<void> deleteClient(String id);
  Future<void> updateClient(Client client);
  Future<List<Client>> getAllClients();
}
