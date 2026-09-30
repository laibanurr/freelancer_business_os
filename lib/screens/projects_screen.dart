import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freelancer_business_os/providers/stream_provider/client_stream_provider.dart';
import 'package:freelancer_business_os/providers/stream_provider/project_stream_provider.dart';
import 'package:freelancer_business_os/screens/add_projects_screen.dart';
import 'package:freelancer_business_os/screens/time_entries_screen.dart';

class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectsStreamProvider);
    final clientAsync = ref.watch(clientsStreamProvider);
    return Scaffold(
      appBar: AppBar(title: Text('Projects')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddProjectsScreen()),
          );
        },
        child: Icon(Icons.add),
      ),
      body: projectsAsync.when(
        data: (projects) {
          final clientNames = clientAsync.maybeWhen(
            data: (clients) => {for (final c in clients) c.id: c.name},

            orElse: () => <String, String>{},
          );
          return ListView.separated(
            separatorBuilder: (context, index) => const Divider(),
            itemCount: projects.length,
            itemBuilder: (context, index) {
              final project = projects[index];
              final clientName = clientNames[project.clientId] ?? '...';
              final rateText =
                  '\$${(project.rateInCents / 100).toStringAsFixed(2)}/hr';
              return ListTile(
                title: Text(
                  project.projectName,
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(clientName),
                trailing: Text(rateText),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TimeEntriesScreen(project:project ),
                    ),
                  );
                },
              );
            },
          );
        },

        error: (error, stackTrace)=> Center(child: Text('Error : $error'),),
        loading: ()=> Center(child: CircularProgressIndicator(),),
      ),
    );
  }
}
