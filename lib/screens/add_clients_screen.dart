import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freelancer_business_os/models/client.dart';
import 'package:freelancer_business_os/providers/repositories_provider/client_repo_provider.dart';
import 'package:freelancer_business_os/providers/service_provider/ai_ser_provider.dart';

const _primaryIndigo = Color(0xFF4F46E5);

class AddClientsScreen extends ConsumerStatefulWidget {
  final Client? clientToEdit;

  const AddClientsScreen({
    super.key,
    this.clientToEdit,
  });

  @override
  ConsumerState<AddClientsScreen> createState() => _AddClientsScreenState();
}

class _AddClientsScreenState extends ConsumerState<AddClientsScreen> {
  final _formKey = GlobalKey<FormState>();

  final _clientNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _aiInputController = TextEditingController();

  bool _isAiProcessing = false;
  bool _isSaving = false;

  bool get _isEditing => widget.clientToEdit != null;

  @override
  void initState() {
    super.initState();

    
    final client = widget.clientToEdit;
    if (client != null) {
      _clientNameController.text = client.name;
      _phoneNumberController.text = client.phoneNumber;
      _emailController.text = client.email;
      _companyNameController.text = client.companyName ?? '';
    }
  }

  @override
  void dispose() {
    _clientNameController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    _companyNameController.dispose();
    _aiInputController.dispose();
    super.dispose();
  }

  
  
  
  Map<String, String> _parseTextLocally(String input) {
    var name = '';
    var company = '';
    var email = '';
    var phone = '';

    final emailMatch = RegExp(
      r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}',
    ).firstMatch(input);

    if (emailMatch != null) {
      email = emailMatch.group(0) ?? '';
    }

    final phoneText = input.replaceAll(RegExp(r'[\s-]'), '');
    final phoneMatch = RegExp(r'\+?[0-9]{7,15}').firstMatch(phoneText);

    if (phoneMatch != null) {
      phone = phoneMatch.group(0) ?? '';
    }

    final chunks = input.split(RegExp(r'[,|]'));

    if (chunks.isNotEmpty) {
      name = chunks.first.trim();

      for (final chunk in chunks.skip(1)) {
        final candidate = chunk.trim();

        if (candidate.isEmpty ||
            candidate.contains('@') ||
            RegExp(r'^[\s+\-\d]+$').hasMatch(candidate)) {
          continue;
        }

        company = candidate;
        break;
      }
    }

    return {
      'name': name,
      'company': company,
      'email': email,
      'phone': phone,
    };
  }

  
  
  
  Future<void> _runAiAutofill(String rawInputText) async {
    if (_isAiProcessing || rawInputText.trim().isEmpty) {
      return;
    }

    setState(() => _isAiProcessing = true);

    try {
      final aiService = ref.read(aiServiceProvider);
      final extractedData = await aiService.parseClientInformation(rawInputText);

      if (!mounted) return;

      setState(() {
        _clientNameController.text = (extractedData['name'] ?? '').toString().trim();
        _companyNameController.text = (extractedData['company'] ?? '').toString().trim();
        _emailController.text = (extractedData['email'] ?? '').toString().trim();
        _phoneNumberController.text = (extractedData['phone'] ?? '').toString().trim();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Client details filled successfully.'),
          backgroundColor: _primaryIndigo,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      debugPrint('AI autofill failed; falling back to local regex: $error');

      if (!mounted) return;

      final localData = _parseTextLocally(rawInputText);

      setState(() {
        _clientNameController.text = localData['name'] ?? '';
        _companyNameController.text = localData['company'] ?? '';
        _emailController.text = localData['email'] ?? '';
        _phoneNumberController.text = localData['phone'] ?? '';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('AI unavailable. Basic local parsing was used.'),
          backgroundColor: Colors.orange,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isAiProcessing = false);
      }
    }
  }

  
  
  
  Future<void> _saveClient() async {
    if (_isSaving || !(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      FocusScope.of(context).unfocus();

      final repository = ref.read(clientRepositoryProvider);
      final existingClient = widget.clientToEdit;
      final company = _companyNameController.text.trim();

      
      final client = Client(
        id: existingClient?.id ?? repository.newClientId(),
        name: _clientNameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneNumberController.text.trim(),
        companyName: company.isEmpty ? null : company,
      );

      if (existingClient == null) {
        await repository.addClient(client);
      } else {
        await repository.updateClient(client);
      }

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (error) {
      debugPrint('Failed to save client: $error');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save the client. Please try again.'),
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
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
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: isDarkMode ? Colors.white70 : Colors.black87,
          ),
        ),
        title: Text(
          _isEditing ? 'Edit Client' : 'Add Client',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
                              'Smart AI Workspace Autofill',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: _primaryIndigo,
                              ),
                            ),
                          ),
                          if (_isAiProcessing)
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
                      const SizedBox(height: 6),
                      const Text(
                        'Paste an email signature or client information below to pre-fill the form.',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _aiInputController,
                        enabled: !_isAiProcessing,
                        style: TextStyle(color: textColor),
                        textInputAction: TextInputAction.done,
                        onSubmitted: _runAiAutofill,
                        decoration: InputDecoration(
                          hintText: _isAiProcessing
                              ? 'Processing text...'
                              : 'Paste notes here and press enter...',
                          hintStyle: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                          filled: true,
                          fillColor: cardColor,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey.withValues(alpha: 0.2),
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: _primaryIndigo.withValues(alpha: 0.4),
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                
                CustomTextField(
                  controller: _clientNameController,
                  label: 'Client Name',
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  isDark: isDarkMode,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Name cannot be empty'
                      : null,
                ),
                CustomTextField(
                  controller: _companyNameController,
                  label: 'Company Name (Optional)',
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  isDark: isDarkMode,
                ),
                CustomTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  isDark: isDarkMode,
                  validator: (value) {
                    final email = value?.trim() ?? '';
                    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                    return emailRegex.hasMatch(email)
                        ? null
                        : 'Enter a valid email address';
                  },
                ),
                CustomTextField(
                  controller: _phoneNumberController,
                  label: 'Phone Number',
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  isDark: isDarkMode,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9\s+\-]')),
                  ],
                  validator: (value) {
                    final digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
                    if (digits.length < 7 || digits.length > 15) {
                      return 'Enter a valid phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                
                ElevatedButton(
                  onPressed: _isSaving ? null : _saveClient,
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
                          _isEditing ? 'Save Changes' : 'Save Client Profile',
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
  final List<TextInputFormatter> inputFormatters;
  final TextInputAction textInputAction;
  final bool isDark;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.validator,
    this.keyboardType,
    this.inputFormatters = const [],
    required this.textInputAction,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        inputFormatters: inputFormatters,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
          floatingLabelStyle: const TextStyle(color: _primaryIndigo),
          filled: true,
          fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey.withValues(alpha: 0.15),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: _primaryIndigo,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Colors.redAccent,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Colors.redAccent,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}