import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freelancer_business_os/models/project.dart';
import 'package:freelancer_business_os/providers/repositories_provider/project_repo_provider.dart';
import 'package:freelancer_business_os/providers/stream_provider/client_stream_provider.dart';

class AddProjectsScreen extends ConsumerStatefulWidget {
  const AddProjectsScreen({super.key});

  @override
  ConsumerState<AddProjectsScreen> createState() =>
      _AddProjectsScreenState();
}

class _AddProjectsScreenState extends ConsumerState<AddProjectsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _projectNameController = TextEditingController();
  final _projectRateController = TextEditingController();
  String? selectedClientId;
  @override
  void dispose() {
    _projectNameController.dispose();
    _projectRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clientAsync = ref.watch(clientsStreamProvider);
    return Scaffold(
      appBar: AppBar(title: Text('Add Project')),
      body: Padding(
        padding: EdgeInsets.all(24.0),
        child: Form(
          key:_formKey,
          child: Column(
            children: [
              clientAsync.when(
                data: (clients) => DropdownButtonFormField(
                  initialValue: selectedClientId,
                  decoration: const InputDecoration(labelText: 'Client'),
                  items: clients
                      .map(
                        (c) =>
                            DropdownMenuItem(value: c.id, child: Text(c.name)),
                      )
                      .toList(),
                  onChanged: (value) => setState(() {
                    selectedClientId = value;
                  }),
                  validator: (value) => value == null ? 'Pick a Client' : null,
                ),
                loading: () => const CircularProgressIndicator(),
                error: (e, st) => Text('Error loading clients: $e'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _projectNameController,
                decoration: const InputDecoration(labelText: 'Project name'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _projectRateController,
                decoration: const InputDecoration(
                  labelText: 'Hourly rate (\$)',
                ),
                keyboardType: TextInputType.number,
                validator: (v) => (v == null || double.tryParse(v) == null)
                    ? 'Enter a valid number'
                    : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;
                    final newId = FirebaseFirestore.instance
                        .collection('projects')
                        .doc()
                        .id;
                    final rateDollars = double.parse(
                      _projectRateController.text.trim(),
                    );
                    final project = Project(
                      clientId: selectedClientId!,
                      endDate: DateTime.now(),
                      projectName: _projectNameController.text.trim(),
                      projectStatus: 'active',
                      rateInCents: (rateDollars * 100).round(),
                      startDate: DateTime.now(),
                      id: newId,
                    );
                    await ref
                        .read(projectRepositoryProvider)
                        .addProject(project);
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
