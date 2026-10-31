import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freelancer_business_os/models/project.dart';
import 'package:freelancer_business_os/providers/repositories_provider/project_repo_provider.dart';
import 'package:freelancer_business_os/providers/state_provider/theme_provider.dart';
import 'package:freelancer_business_os/providers/stream_provider/client_stream_provider.dart';
import 'package:freelancer_business_os/providers/stream_provider/project_stream_provider.dart';
import 'package:freelancer_business_os/screens/add_projects_screen.dart';
import 'package:freelancer_business_os/screens/time_entries_screen.dart'; 
const _primaryIndigo = Color(0xFF4F46E5);
class ProjectsScreen extends ConsumerStatefulWidget {
  const ProjectsScreen({super.key});
  @override
  ConsumerState<ProjectsScreen> createState() => _ProjectsScreenState();
}
class _ProjectsScreenState extends ConsumerState<ProjectsScreen> {
  final Set<String> _expandedProjectIds = {};
  void _toggleExpanded(String projectId) {
    setState(() {
      if (_expandedProjectIds.contains(projectId)) {
        _expandedProjectIds.remove(projectId);
      } else {
        _expandedProjectIds.add(projectId);
      }
    });
  }
  Future<void> _confirmDeleteProject(Project project) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete project?'),
        content: Text(
          'Are you sure you want to delete "${project.projectName}"? '
          'Related time entries and invoices will remain intact.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
    if (shouldDelete != true) return;
    try {
      await ref.read(projectRepositoryProvider).deleteProject(project.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${project.projectName} was deleted.')),
      );
    } catch (error) {
      debugPrint('Failed to delete project: $error');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not delete this project. Please try again.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }
  void _openEditProject(Project project) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddProjectsScreen(projectToEdit: project),
      ),
    );
  }
  void _openTrackTime(Project project) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TimeEntriesScreen(project: project),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(projectsStreamProvider);
    final clientsAsync = ref.watch(clientsStreamProvider);
    final isDark = ref.watch(themeProvider);
    final backgroundColor =
        isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final Map<String, String> clientMap = {};
    clientsAsync.whenData((clients) {
      for (final client in clients) {
        clientMap[client.id] = client.name;
      }
    });
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Projects Directory',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: textColor,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'projects_fab_tag',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddProjectsScreen(),
            ),
          );
        },
        backgroundColor: _primaryIndigo,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_task_outlined),
        label: const Text(
          'Add Project',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: projectsAsync.when(
        data: (projects) {
          if (projects.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: const BoxDecoration(
                        color: _primaryIndigo,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.business_center_outlined,
                        size: 64,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No Projects Found',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Create your first contract to begin tracking hours.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            itemCount: projects.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final project = projects[index];
              final isExpanded = _expandedProjectIds.contains(project.id);
              final clientName = clientMap[project.clientId] ?? 'Client Account';
              final rateFormatted =
                  '\$${(project.rateInCents / 100).toStringAsFixed(2)}/hr';
              final hasDescription = project.projectDescription != null &&
                  project.projectDescription!.trim().isNotEmpty;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.grey.withValues(alpha: 0.15),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Container(
                            height: 48,
                            width: 48,
                            decoration: BoxDecoration(
                              color: _primaryIndigo.withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _primaryIndigo.withValues(alpha: 0.15),
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.folder_open_rounded,
                                color: _primaryIndigo,
                                size: 22,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  project.projectName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
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
                                      Icons.person_outline_rounded,
                                      size: 14,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        clientName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      rateFormatted,
                                      style: const TextStyle(
                                        color: _primaryIndigo,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.green.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        project.projectStatus.toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.green,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: 'Track time for this project',
                            visualDensity: VisualDensity.compact,
                            onPressed: () => _openTrackTime(project),
                            icon: const Icon(
                              Icons.timer_outlined,
                              size: 20,
                              color: _primaryIndigo,
                            ),
                          ),
                          IconButton(
                            tooltip: 'Edit project',
                            visualDensity: VisualDensity.compact,
                            onPressed: () => _openEditProject(project),
                            icon: const Icon(
                              Icons.edit_outlined,
                              size: 20,
                              color: Colors.blueGrey,
                            ),
                          ),
                          IconButton(
                            tooltip: 'Delete project',
                            visualDensity: VisualDensity.compact,
                            onPressed: () => _confirmDeleteProject(project),
                            icon: const Icon(
                              Icons.delete_outline,
                              size: 20,
                              color: Colors.redAccent,
                            ),
                          ),
                          if (hasDescription)
                            IconButton(
                              tooltip: isExpanded
                                  ? 'Hide contract'
                                  : 'View contract roadmap',
                              visualDensity: VisualDensity.compact,
                              onPressed: () => _toggleExpanded(project.id),
                              icon: Icon(
                                isExpanded
                                    ? Icons.keyboard_arrow_up_rounded
                                    : Icons.keyboard_arrow_down_rounded,
                                color: Colors.grey,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (isExpanded && hasDescription) ...[
                      const Divider(height: 1),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.black.withValues(alpha: 0.2)
                              : Colors.grey.withValues(alpha: 0.05),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.auto_awesome,
                                  size: 14,
                                  color: _primaryIndigo,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'CONTRACT & SCOPE SPECIFICATIONS',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: _primaryIndigo,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              project.projectDescription!,
                              style: TextStyle(
                                color: textColor.withValues(alpha: 0.85),
                                fontSize: 13,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
        error: (error, stackTrace) => Center(
          child: Text(
            'Could not load projects: $error',
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(color: _primaryIndigo),
        ),
      ),
    );
  }
}