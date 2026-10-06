
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freelancer_business_os/providers/state_provider/theme_provider.dart';
import 'package:freelancer_business_os/providers/stream_provider/client_stream_provider.dart';
import 'package:freelancer_business_os/providers/stream_provider/project_stream_provider.dart';
import 'package:freelancer_business_os/providers/stream_provider/user_profile_stream_provider.dart';
import 'package:freelancer_business_os/screens/add_projects_screen.dart';
import 'package:freelancer_business_os/screens/time_entries_screen.dart'; 
class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectsStreamProvider);
    final clientsAsync = ref.watch(clientsStreamProvider);

    
    final isDarkMode = ref.watch(themeProvider);
    final backgroundColor = isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cardColor = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    const primaryIndigo = Color(0xFF4F46E5);

    
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'unknown_user';
    final profileAsync = ref.watch(userProfileStreamProvider(uid));
    final currency = profileAsync.value?.selectedCurrencySymbol ?? '\$';

    final projects = projectsAsync.value ?? [];
    final clients = clientsAsync.value ?? [];

    final Map<String, String> clientNames = {
      for (final client in clients) client.id: client.name
    };

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false, 
        title: Text(
          'Projects Ledger',
          style: TextStyle(
            color: textColor, 
            fontWeight: FontWeight.bold, 
            fontSize: 22,
            letterSpacing: -0.5,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'projects_fab_tag', 
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddProjectsScreen()),
          );
        },
        backgroundColor: primaryIndigo,
        foregroundColor: Colors.white,
        elevation: 0,
        icon: const Icon(Icons.add_task_rounded, size: 20),
        label: const Text(
          'Add Project', 
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
      body: (projectsAsync.isLoading || clientsAsync.isLoading)
          ? const Center(child: CircularProgressIndicator(color: primaryIndigo))
          : projects.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isDarkMode ? const Color(0xFF1E293B) : Colors.grey.withValues(alpha: 0.05),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.work_off_outlined, color: Colors.grey.withValues(alpha: 0.5), size: 48),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No Active Project Contracts',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor.withValues(alpha: 0.7)),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Tap the button below to initialize your first technical scope ledger.',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 90), 
                  itemCount: projects.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final project = projects[index];
                    final clientName = clientNames[project.clientId] ?? 'Unknown Client';
                    
                    
                    final rateText = '$currency${(project.rateInCents / 100).toStringAsFixed(2)}/hr';
                    
                    final isActive = project.projectStatus.toLowerCase() == 'active';

                    return Container(
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDarkMode ? Colors.white.withValues(alpha: 0.08) : Colors.grey.withValues(alpha: 0.15), 
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.015),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Theme(
                        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          tilePadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: primaryIndigo.withValues(alpha: 0.06),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.folder_open_rounded, color: primaryIndigo, size: 20),
                          ),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  project.projectName,
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: textColor),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                rateText,
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textColor),
                              ),
                            ],
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: Row(
                              children: [
                                const Icon(Icons.people_outline, size: 14, color: Colors.grey),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Client: $clientName',
                                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 18, right: 18, bottom: 16, top: 4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const Divider(height: 1),
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: isDarkMode ? const Color(0xFF0F172A) : Colors.grey.withValues(alpha: 0.04),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Row(
                                          children: [
                                            Icon(Icons.assignment_turned_in_outlined, size: 14, color: primaryIndigo),

SizedBox(width: 6),
Text(
'ACTIVE CONTRACT ROADMAP SPECIFICATIONS:',
style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: primaryIndigo, letterSpacing: 0.5),
),
],
),
const SizedBox(height: 10),
Text(
project.projectDescription ?? 'No technical specifications roadmap logged for this project contract workspace.',
style: TextStyle(color: textColor.withValues(alpha: 0.8), fontSize: 13, height: 1.5),
),
],
),
),
const SizedBox(height: 14),
Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
Container(
padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
decoration: BoxDecoration(
color: isActive ? primaryIndigo.withValues(alpha: 0.08) : Colors.grey.withValues(alpha: 0.1),
borderRadius: BorderRadius.circular(8),
border: Border.all(
color: isActive ? primaryIndigo.withValues(alpha: 0.15) : Colors.grey.withValues(alpha: 0.2),
),
),
child: Text(
project.projectStatus.toUpperCase(),
style: TextStyle(
color: isActive ? primaryIndigo : Colors.grey,
fontSize: 11,
fontWeight: FontWeight.bold,
letterSpacing: 0.5,
),
),
),
InkWell(
onTap: () {
Navigator.push(
context,
MaterialPageRoute(
builder: (_) => TimeEntriesScreen(project: project),
),
);
},
borderRadius: BorderRadius.circular(8),
child: Container(
padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
decoration: BoxDecoration(
color: primaryIndigo,
borderRadius: BorderRadius.circular(8),
),
child: const Row(
children: [
Text(
'Track Time',
style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
),
SizedBox(width: 4),
Icon(Icons.arrow_forward_rounded, size: 14, color: Colors.white),
],
),
),
),
],
),
],
),
),
],
),
),
);
},
),
);
}
}




