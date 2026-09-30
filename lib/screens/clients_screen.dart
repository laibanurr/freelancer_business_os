import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freelancer_business_os/providers/stream_provider/client_stream_provider.dart';
import 'package:freelancer_business_os/screens/add_clients_screen.dart';

class ClientsScreen extends ConsumerWidget {
  const ClientsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientAsync = ref.watch(clientsStreamProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Clients')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddClientsScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),

      body: clientAsync.when(
        data: (clients) => ListView.separated(
          itemCount: clients.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            final client = clients[index];
            return ListTile(
              leading: CircleAvatar(child: Text(_getInitials(client.name))),
              title: Text(client.name),
              subtitle: Text(client.companyName),
            );
          },
        ),

        error: (error, stackTrace) => Center(child: Text('Error : $error')),
        loading: () => Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

String _getInitials(String name) {
  final parts = name.trim().split(' ');
  if (parts.length >= 2) {
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
  return parts[0][0].toUpperCase();
}
