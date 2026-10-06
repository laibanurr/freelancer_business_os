
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freelancer_business_os/models/client.dart';
import 'package:freelancer_business_os/providers/repositories_provider/client_repo_provider.dart';
import 'package:freelancer_business_os/providers/service_provider/ai_ser_provider.dart';
import 'package:freelancer_business_os/providers/state_provider/theme_provider.dart'; 
class AddClientsScreen extends ConsumerStatefulWidget {
  const AddClientsScreen({super.key});

  @override
  ConsumerState<AddClientsScreen> createState() => _AddClientsScreenState();
}
class _AddClientsScreenState extends ConsumerState<AddClientsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _clientNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _companyNameController = TextEditingController();
  
  bool isAiProcessing = false;
  bool isSaving = false; 

  @override
  void dispose() {
    _emailController.dispose();
    _phoneNumberController.dispose();
    _clientNameController.dispose();
    _companyNameController.dispose();
    super.dispose();
  }

  void _resetFormFields() {
    _clientNameController.clear();
    _companyNameController.clear();
    _emailController.clear();
    _phoneNumberController.clear();
  }

  Future<void> _runAiAutofill(String rawInputText) async {
    if (rawInputText.trim().isEmpty) return;
    setState(() {
      isAiProcessing = true;
    });
    try {
      final aiService = ref.read(aiServiceProvider);
      final Map<String,dynamic> extractedData =
          await aiService.parseClientInformation(rawInputText);
      if (!context.mounted) return;
      setState(() {
        _clientNameController.text = extractedData['name'] ?? '';
        _companyNameController.text = extractedData['company'] ?? '';
        _emailController.text = extractedData['email'] ?? '';
        _phoneNumberController.text = extractedData['phone'] ?? '';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✨ Form autofilled successfully by Firebase AI!'),
          backgroundColor: Color(0xFF4F46E5),
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('AI Autofill Failed: $e')),
        );
      }
    } finally {
      setState(() {
        isAiProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
              icon: Icon(
                Icons.arrow_back_ios_new,
                size: 20,
                color: isDarkMode ? Colors.white70 : Colors.black87,
              )),
          title: Text('Add Client',
              style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 20))),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  
                  
                  
                  Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: primaryIndigo.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: primaryIndigo.withValues(alpha: 0.15),
                            width: 1,
                          )),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.auto_awesome, color: primaryIndigo, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Smart AI Workspace Autofill',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: primaryIndigo.withValues(alpha: 0.9)),
                              ),
                              if (isAiProcessing) ...[
                                const Spacer(),
                                const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: primaryIndigo),
                                )
                              ]
                            ],
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Paste an email signature, business notes text, or client profile info below to instantly pre-fill all form slots.',
                            style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.4),
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            enabled: !isAiProcessing,
                            style: TextStyle(color: textColor),
                            textInputAction: TextInputAction.done,
                            onSubmitted: (text) => _runAiAutofill(text),
                            decoration: InputDecoration(
                              hintText: isAiProcessing
                                  ? 'Evaluating text structure parameters...'
                                  : 'Paste raw client notes text here & hit enter...',
                              hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                              filled: true,
                              fillColor: cardColor,
                              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: primaryIndigo.withValues(alpha: 0.4), width: 1.5),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      )),
                  
                  const SizedBox(height: 28),
                  
                  
                  
                  
                  CustomTextField(
                    controller: _clientNameController,
                    label: 'Client Name',
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    isDark: isDarkMode,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Name cannot be empty';
                      }
                      if (value.trim().length < 2) return 'Too short';
                      return null;
                    },
                  ),
                  
                  CustomTextField(
                    controller: _companyNameController,
                    label: 'Company Name (Optional)',
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    isDark: isDarkMode,
                    validator: (value) => null, 
                  ),
                  
                  CustomTextField(
                    controller: _emailController,
                    label: 'Email Address',
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    isDark: isDarkMode,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Email is required';
                      }
                      final emailRegex = RegExp(
                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                      );
                      if (!emailRegex.hasMatch(value.trim())) {

return 'Enter a valid email address';
}
return null;
},
),
                  CustomTextField(
                    controller: _phoneNumberController,
                    label: 'Phone Number',
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.done,
                    isDark: isDarkMode,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9\s-+]')),
                    ],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Phone number is required';
                      }
                      // 🌟 FIXED: Added the backslash \ to turn it into a literal plus sign character!
                      final phoneRegex = RegExp(r'^\+?[0-9\s-]{7,15}$'); 
                      
                      if (!phoneRegex.hasMatch(value.trim())) {
                        return 'Enter a valid phone number';
                      }
                      return null;
                    },
                  ),

const SizedBox(height: 32),



ElevatedButton(
onPressed: isSaving ? null : () async {
if (!_formKey.currentState!.validate()) return;
setState(() {
isSaving = true;
});
try {
FocusScope.of(context).unfocus();
final freshId = FirebaseFirestore.instance.collection('clients').doc().id;
final companyText = _companyNameController.text.trim();
await ref.read(clientRepositoryProvider).addClient(
Client(
id: freshId,
name: _clientNameController.text.trim(),
companyName: companyText.isEmpty ? 'Independent Freelancer' : companyText,
email: _emailController.text.trim(),
phoneNumber: _phoneNumberController.text.trim(),
),
);
await Future.delayed(const Duration(milliseconds: 100));
if (!context.mounted) return;
_resetFormFields();
Navigator.pop(context);
} catch (dbError) {
if (context.mounted) {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text('Database Save Error: $dbError'),
backgroundColor: Colors.redAccent
),
);
}
} finally {
setState(() {
isSaving = false;
});
}
},
style: ElevatedButton.styleFrom(
backgroundColor: primaryIndigo,
foregroundColor: Colors.white,
elevation: 0,
padding: const EdgeInsets.symmetric(vertical: 16),
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
),
child: isSaving
? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
: const Text('Save Client Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
)
],
),
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
  final bool isDark; // 🌟 Ensure this parameter is fully enabled

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
          // 🌟 Expands the internal text containers footprint so your entries never feel squashed
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.withOpacity(0.15), width: 1.0),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: primaryIndigo, width: 2.0),
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
