import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freelancer_business_os/models/project.dart';
import 'package:freelancer_business_os/providers/repositories_provider/project_repo_provider.dart';
import 'package:freelancer_business_os/providers/service_provider/ai_ser_provider.dart';
import 'package:freelancer_business_os/providers/state_provider/theme_provider.dart';
import 'package:freelancer_business_os/providers/stream_provider/client_stream_provider.dart';
const _primaryIndigo = Color(0xFF4F46E5);
class AddProjectsScreen extends ConsumerStatefulWidget {
  final Project? projectToEdit;
  const AddProjectsScreen({
    super.key,
    this.projectToEdit,
  });
  @override
  ConsumerState<AddProjectsScreen> createState() => _AddProjectsScreenState();
}
class _AddProjectsScreenState extends ConsumerState<AddProjectsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _projectNameController = TextEditingController();
  final _projectRateController = TextEditingController();
  final _aiScopeInputController = TextEditingController();
  String? selectedClientId;
  bool _isAiScopeProcessing = false;
  bool _isSaving = false;
  String _aiGeneratedScopeText = '';
  bool get _isEditing => widget.projectToEdit != null;
  @override
  void initState() {
    super.initState();
    final project = widget.projectToEdit;
    if (project != null) {
      _projectNameController.text = project.projectName;
      _projectRateController.text =
          (project.rateInCents / 100).toStringAsFixed(2);
      selectedClientId = project.clientId;
      _aiGeneratedScopeText = project.projectDescription ?? '';
    }
  }
  @override
  void dispose() {
    _projectNameController.dispose();
    _projectRateController.dispose();
    _aiScopeInputController.dispose();
    super.dispose();
  }
  Future<void> _runAiScopeBuilder(String rawInput) async {
    final input = rawInput.trim();
    if (input.isEmpty || _isAiScopeProcessing) return;
    setState(() => _isAiScopeProcessing = true);
    try {
      final aiService = ref.read(aiServiceProvider);
      final generatedScope = await aiService.generateProjectScope(
        input,
        projectName: _projectNameController.text.trim().isNotEmpty
            ? _projectNameController.text.trim()
            : null,
        hourlyRate: _projectRateController.text.trim().isNotEmpty
            ? _projectRateController.text.trim()
            : null,
      );
      if (!mounted) return;
      setState(() {
        _aiGeneratedScopeText = generatedScope;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Project scope specifications compiled with AI.'),
          backgroundColor: _primaryIndigo,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      debugPrint('Gemini failed or unavailable; using local generator: $e');
      if (!mounted) return;
      final summary = input
          .split(RegExp(r'\s+'))
          .where((word) => word.isNotEmpty)
          .take(12)
          .join(' ');
      final fallbackScope = [
        'Project Scope Overview:',
        '- Core objective: ${summary.isNotEmpty ? summary : "General project delivery"}',
        '- Deliverables: Requirements gathering, implementation, testing, and deployment readiness.',
        '- Technical constraints: Validate dependencies, confirm integrations, and document acceptance criteria.',
        '- Timeline: Establish milestones, baseline review, and final handoff checkpoints.',
        '- Risk controls: Track change requests, maintain client feedback loops, and record signoff milestones.',
      ].join('\n');
      setState(() {
        _aiGeneratedScopeText = fallbackScope;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Contract specifications compiled successfully.'),
          backgroundColor: _primaryIndigo,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isAiScopeProcessing = false);
      }
    }
  }
  Future<void> _saveProject() async {
    if (_isSaving || !(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    setState(() => _isSaving = true);
    FocusScope.of(context).unfocus();
    try {
      final repository = ref.read(projectRepositoryProvider);
      final existingProject = widget.projectToEdit;
      final rateDollars = double.parse(_projectRateController.text.trim());
      final projectId = existingProject?.id ??
          FirebaseFirestore.instance.collection('projects').doc().id;
      final project = Project(
        id: projectId,
        clientId: selectedClientId!,
        projectName: _projectNameController.text.trim(),
        projectStatus: existingProject?.projectStatus ?? 'active',
        rateInCents: (rateDollars * 100).round(),
        startDate: existingProject?.startDate ?? DateTime.now(),
        endDate: existingProject?.endDate,
        projectDescription: _aiGeneratedScopeText.isEmpty
            ? 'Standard freelance project contract initialized.'
            : _aiGeneratedScopeText,
      );
      if (existingProject == null) {
        await repository.addProject(project);
      } else {
        await repository.updateProject(project);
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (dbError) {
      debugPrint('Project Save Error: $dbError');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Save error: $dbError'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    final clientAsync = ref.watch(clientsStreamProvider);
    final isDarkMode = ref.watch(themeProvider);
    final backgroundColor =
        isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cardColor = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: isDarkMode ? Colors.white70 : Colors.black87,
          ),
        ),
        title: Text(
          _isEditing ? 'Edit Project' : 'Add Project',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          physics: const BouncingScrollPhysics(),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _primaryIndigo.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _primaryIndigo.withValues(alpha: 0.15),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.auto_awesome,
                            color: _primaryIndigo,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'AI Contract & Scope Specifications Builder',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: _primaryIndigo,
                              ),
                            ),
                          ),
                          if (_isAiScopeProcessing)
                            const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: _primaryIndigo,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Input rough assignment summaries to compile explicit roadmaps and technical boundaries.',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _aiScopeInputController,
                        enabled: !_isAiScopeProcessing,
                        style: TextStyle(color: textColor),
                        textInputAction: TextInputAction.done,
                        onSubmitted: _runAiScopeBuilder,
                        decoration: InputDecoration(
                          hintText: _isAiScopeProcessing
                              ? 'Compiling technical specifications ledger...'
                              : 'Type brief requirements & tap button...',
                          hintStyle: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                          filled: true,
                          fillColor: cardColor,
                          suffixIcon: IconButton(
                            icon: const Icon(
                              Icons.arrow_circle_right_rounded,
                              color: _primaryIndigo,
                              size: 26,
                            ),
                            onPressed: _isAiScopeProcessing
                                ? null
                                : () => _runAiScopeBuilder(
                                      _aiScopeInputController.text,
                                    ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey.withValues(alpha: 0.2),
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder:  OutlineInputBorder(
                            borderSide: BorderSide(
                              color: _primaryIndigo,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      if (_aiGeneratedScopeText.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 12),
                        const Text(
                          'OFFICIAL ENGAGEMENT ROADMAP SPECIFICATIONS:',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: _primaryIndigo,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey.withValues(alpha: 0.15),
                            ),
                          ),
                          child: Text(
                            _aiGeneratedScopeText,
                            style: TextStyle(
                              color: textColor.withValues(alpha: 0.9),
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                clientAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: _primaryIndigo),
                  ),
                  error: (e, st) => Text(
                    'Error loading clients: $e',
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                  data: (clients) {
                    final isIdValid =
                        clients.any((c) => c.id == selectedClientId);
                    return DropdownButtonFormField<String>(
                      dropdownColor: cardColor,
                      style: TextStyle(color: textColor),
                      initialValue: isIdValid ? selectedClientId : null,
                      onTap: () => FocusScope.of(context).unfocus(),
                      decoration: InputDecoration(
                        labelText: 'Select Target Client Account',
                        labelStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                        floatingLabelStyle:
                            const TextStyle(color: _primaryIndigo),
                        filled: true,
                        fillColor: cardColor,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey.withValues(alpha: 0.2),
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder:  OutlineInputBorder(
                          borderSide: BorderSide(
                            color: _primaryIndigo,
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: clients
                          .map((c) => DropdownMenuItem(
                                value: c.id,
                                child: Text(
                                  c.name,
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => selectedClientId = value),
                      validator: (value) => value == null
                          ? 'Please map an operational client account'
                          : null,
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
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Project name is required'
                      : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _projectRateController,
                  label: 'Hourly Billing Rate (\$)',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  textInputAction: TextInputAction.done,
                  isDark: isDarkMode,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  validator: (v) => (v == null || double.tryParse(v) == null)
                      ? 'Enter a valid billing rate'
                      : null,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isSaving ? null : _saveProject,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryIndigo,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _isEditing ? 'Save Changes' : 'Save Project Contract',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
          floatingLabelStyle: const TextStyle(color: _primaryIndigo),
          filled: true,
          fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey.withValues(alpha: 0.15),
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder:  OutlineInputBorder(
            borderSide: BorderSide(color: _primaryIndigo, width: 2.0),
            borderRadius: BorderRadius.circular(12),
          ),
          errorBorder:  OutlineInputBorder(
            borderSide: BorderSide(color: Colors.redAccent, width: 1.0),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.redAccent, width: 2.0),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}