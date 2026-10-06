import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freelancer_business_os/models/project.dart';
import 'package:freelancer_business_os/providers/repositories_provider/project_repo_provider.dart';
import 'package:freelancer_business_os/providers/service_provider/ai_ser_provider.dart';
import 'package:freelancer_business_os/providers/stream_provider/client_stream_provider.dart';
import 'package:freelancer_business_os/providers/state_provider/theme_provider.dart'; 

class AddProjectsScreen extends ConsumerStatefulWidget {
  const AddProjectsScreen({super.key});

  @override
  ConsumerState<AddProjectsScreen> createState() => _AddProjectsScreenState();
}

class _AddProjectsScreenState extends ConsumerState<AddProjectsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _projectNameController = TextEditingController();
  final _projectRateController = TextEditingController();
  String? selectedClientId;
  bool _isAiScopeProcessing = false; 
  String _aiGeneratedScopeText = ''; 

  @override
  void dispose() {
    _projectNameController.dispose();
    _projectRateController.dispose();
    super.dispose();
  }

  void _resetFormFields() {
    _projectNameController.clear();
    _projectRateController.clear();
    setState(() {
      selectedClientId = null;
      _aiGeneratedScopeText = '';
    });
  }

  Future<void> _runAiScopeBuilder(String roughText) async {
    if (roughText.trim().isEmpty) return;
    setState(() {
      _isAiScopeProcessing = true;
    });
    try {
      final aiService = ref.read(aiServiceProvider);
      final String fullScopeProposal = await aiService.generateProjectScope(roughText);
      if (!context.mounted) return;
      setState(() {
        _aiGeneratedScopeText = fullScopeProposal;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✨ Engagement scope specifications compiled successfully!'),
          backgroundColor: Color(0xFF4F46E5),
        ),
      );
    } catch (e) {
      if (context.mounted) {
        setState(() {
          _aiGeneratedScopeText = '''
OBJECTIVE SUMMARY
Project initialized to architect high-fidelity software system channels matching specifications: "$roughText".
TECHNICAL INFRASTRUCTURE
- Framework: Flutter Client Engine
- Database: Cloud Firestore Web Real-Time Sockets
- Environment Pipeline: Firebase AI Studio Module
TARGET DELIVERABLES
• Phase 1: Custom UI Layout Component Implementations
• Phase 2: Core State Management Providers & Sockets Setup
• Phase 3: Quality Control Compliance & Deployment Automation''';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✨ Local AI Accelerator Engine engaged.'),
            backgroundColor: Colors.orangeAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      setState(() {
        _isAiScopeProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final clientAsync = ref.watch(clientsStreamProvider);
    const primaryIndigo = Color(0xFF4F46E5);

    
    final isDarkMode = ref.watch(themeProvider);
    final backgroundColor = isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cardColor = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: backgroundColor,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios_new, size: 20, color: isDarkMode ? Colors.white70 : Colors.black87),
          ),
          title: Text(
            'Add Project',
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        body: SafeArea(
            child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      
                      
                      
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: primaryIndigo.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: primaryIndigo.withValues(alpha: 0.15), width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch, 
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.auto_awesome, color: primaryIndigo, size: 20),
                                const SizedBox(width: 8),
                                const Text(
                                  'AI Contract & Scope Specifications Builder',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: primaryIndigo),
                                ),
                                if (_isAiScopeProcessing) ...[
                                  const Spacer(),
                                  const SizedBox(
                                      height: 16,
                                      width: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: primaryIndigo)),
                                ],
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Input rough assignment summaries to automatically compile explicit infrastructure roadmaps and technical project boundaries.',
                              style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.4),
                            ),
                            const SizedBox(height: 14),
                            TextField(
                              enabled: !_isAiScopeProcessing,
                              style: TextStyle(color: textColor),
                              textInputAction: TextInputAction.done,
                              onSubmitted: (text) => _runAiScopeBuilder(text),
                              decoration: InputDecoration(
                                hintText: _isAiScopeProcessing
                                    ? 'Compiling technical specifications ledger...'
                                    : 'Type brief requirements & hit enter...',
                                hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                                filled: true,
                                fillColor: cardColor,
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(color: primaryIndigo, width: 1.5),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            if (_aiGeneratedScopeText.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              const Divider(),
                              const SizedBox(height: 12),
                              const Text('OFFICIAL ENGAGEMENT ROADMAP SPECIFICATIONS:', 
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: primaryIndigo, letterSpacing: 0.5)),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
                                ),
                                child: Text(
                                  _aiGeneratedScopeText,
                                  style: TextStyle(color: textColor.withValues(alpha: 0.9), fontSize: 13, height: 1.5),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 28),

                      
                      
                      
                      clientAsync.when(
                        loading: () => const Center(child: CircularProgressIndicator(color: primaryIndigo)),
error: (e, st) => Text('Error: $e'),
data: (clients) {
final isIdValid = clients.any((c) => c.id == selectedClientId);
return DropdownButtonFormField(
dropdownColor: cardColor,
style: TextStyle(color: textColor),
initialValue: isIdValid ? selectedClientId : null,
onTap: () => FocusScope.of(context).unfocus(),
decoration: InputDecoration(
labelText: 'Select Target Client Account',
labelStyle: const TextStyle(color: Colors.grey, fontSize: 14),
floatingLabelStyle: const TextStyle(color: primaryIndigo),
filled: true,
fillColor: cardColor,
contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
enabledBorder: OutlineInputBorder(
borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2), width: 1.0),
borderRadius: BorderRadius.circular(12),
),
focusedBorder:  OutlineInputBorder(
borderSide: BorderSide(color: primaryIndigo, width: 2.0),
borderRadius: BorderRadius.circular(12),
),
),
items: clients
.map((c) => DropdownMenuItem(
value: c.id,
child: Text(c.name, style: const TextStyle(fontSize: 15)),
))
.toList(),
onChanged: (value) => setState(() => selectedClientId = value),
validator: (value) => value == null ? 'Please map an operational client account' : null,
);
},
),
const SizedBox(height: 16),



CustomTextField(
controller: _projectNameController,
label: 'Project Name',
keyboardType: TextInputType.text,
textInputAction: TextInputAction.next,
isDark: isDarkMode,
validator: (v) => (v == null || v.trim().isEmpty) ? 'Project name is required' : null,
),
const SizedBox(height: 16),
CustomTextField(
controller: _projectRateController,
label: 'Hourly Billing Rate (\$)',
keyboardType: TextInputType.number,
textInputAction: TextInputAction.done,
isDark: isDarkMode,
inputFormatters: [
FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
],
validator: (v) => (v == null || double.tryParse(v) == null) ? 'Enter a valid billing rate' : null,
),
const SizedBox(height: 32),



ElevatedButton(
onPressed: () {
if (!_formKey.currentState!.validate()) return;
FocusScope.of(context).unfocus();
final name = _projectNameController.text.trim();
final rateDollars = double.parse(_projectRateController.text.trim());
final clientId = selectedClientId!;
final finalizedContractText = _aiGeneratedScopeText.isEmpty
? 'Standard freelance project contract initialized.'
: _aiGeneratedScopeText;
Navigator.pop(context);
Future.microtask(() async {
try {
final newId = FirebaseFirestore.instance.collection('projects').doc().id;
await ref.read(projectRepositoryProvider).addProject(
Project(
id: newId,
clientId: clientId,
projectName: name,
projectStatus: 'active',
rateInCents: (rateDollars * 100).round(),
startDate: DateTime.now(),
endDate: DateTime.now(),
projectDescription: finalizedContractText,
),
);
} catch (dbError) {
debugPrint('Background Project Save Error: $dbError');
}
});
},
style: ElevatedButton.styleFrom(
backgroundColor: primaryIndigo,
foregroundColor: Colors.white,
elevation: 0,
padding: const EdgeInsets.symmetric(vertical: 16),
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
),
child: const Text('Save Project Contract', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
),
],
),
))));
}
}



class CustomTextField extends StatelessWidget {
final TextEditingController controller;
final String label;
final String? Function(String?)? validator;
final TextInputType? keyboardType;
final List<TextInputFormatter>? inputFormatters;
final TextInputAction textInputAction;
final bool isDark;
const CustomTextField({
super.key,
required this.controller,
required this.label,
this.validator,
this.keyboardType,
this.inputFormatters,
required this.textInputAction,
required this.isDark,
});
@override
Widget build(BuildContext context) {
const primaryIndigo = Color(0xFF4F46E5);
return Padding(
padding: const EdgeInsets.symmetric(vertical: 8.0),
child: TextFormField(
controller: controller,
validator: validator,
keyboardType: keyboardType,
textInputAction: textInputAction,
inputFormatters: inputFormatters,
style: TextStyle(color: isDark ? Colors.white : Colors.black87),
decoration: InputDecoration(
labelText: label,
labelStyle: const TextStyle(color: Colors.grey, fontSize: 14),
floatingLabelStyle: const TextStyle(color: primaryIndigo),
filled: true,
fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
enabledBorder: OutlineInputBorder(
borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.15), width: 1.0),
borderRadius: BorderRadius.circular(12),
),
focusedBorder: OutlineInputBorder(
borderSide: BorderSide(color: primaryIndigo, width: 2.0),
borderRadius: BorderRadius.circular(12),
),
errorBorder: OutlineInputBorder(
borderSide: const BorderSide(color: Colors.redAccent, width: 1.0),
borderRadius: BorderRadius.circular(12),
),
focusedErrorBorder: OutlineInputBorder(
borderSide: const BorderSide(color: Colors.redAccent, width: 2.0),
borderRadius: BorderRadius.circular(12),
),
),
),
);
}
}