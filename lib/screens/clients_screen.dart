import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freelancer_business_os/providers/stream_provider/client_stream_provider.dart';
import 'package:freelancer_business_os/screens/add_clients_screen.dart';

class ClientsScreen extends ConsumerWidget {
  const ClientsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientAsync = ref.watch(clientsStreamProvider);
    const primaryIndigo = Color(0xFF4F46E5);

    // Global Theming Tokens Lookup (100% Preserved)
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false, 
        title: Text(
          'Clients Directory',
          style: TextStyle(
            fontWeight: FontWeight.bold, 
            fontSize: 22, 
            color: textColor, 
          ),
        ),
      ),
      // 🌟 FIXED POSITION: Normal Scaffold FAB parameters automatically anchor your 
      // extended text button perfectly right to the bottom-right corner area!
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'clients_fab_tag',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddClientsScreen()),
          );
        },
        backgroundColor: primaryIndigo,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_alt_1_outlined),
        label: const Text('Add Client', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: clientAsync.when(
        data: (clients) {
          if (clients.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: const BoxDecoration(
                        color: primaryIndigo, 
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.people_outline,
                        size: 64,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No Clients Found',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.separated(
            // Roomy padding so items roll up completely past your navbar bounds
            padding: const EdgeInsets.only(top: 16, bottom: 100, left: 20, right: 20),
            itemCount: clients.length,
            separatorBuilder: (context, index) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final client = clients[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor, 
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey.withValues(alpha: 0.15), 
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      height: 52,
                      width: 52,
                      decoration: BoxDecoration(
                        color: primaryIndigo.withValues(alpha: 0.08), 
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: primaryIndigo.withValues(alpha: 0.15),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _getInitials(client.name),
                          style: const TextStyle(
                            color: primaryIndigo, 
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            client.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: textColor, 
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.business_center_outlined,
                                size: 16, 
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  client.companyName.isEmpty
                                      ? 'Independent Freelancer'
                                      : client.companyName,
                                  style: const TextStyle(
                                    color: Colors.grey, 
                                    fontSize: 13,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: Colors.grey,
                      size: 20,
                    )
                  ],
                ),
              );
            },
          );
        },
        error: (error, stackTrace) => Center(
          child: Text(
            'Error : $error',
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: primaryIndigo,
          ),
        ),
      ),
    );
  }
}

String _getInitials(String name) {
  final parts = name.trim().split(' ');
  final cleanParts = parts.where((element) => element.isNotEmpty).toList();
  if (cleanParts.isEmpty) {
    return '?';
  }
  if (cleanParts.length >= 2) {
    return '${cleanParts[0][0]}${cleanParts[1][0]}'.toUpperCase();
  }
  return cleanParts[0][0].toUpperCase();
}
