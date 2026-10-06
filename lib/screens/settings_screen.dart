
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freelancer_business_os/providers/stream_provider/user_profile_stream_provider.dart';
import 'package:image_picker/image_picker.dart'; 
import 'package:freelancer_business_os/models/user_profile.dart';
import 'package:freelancer_business_os/providers/repositories_provider/user_profile_repo_provider.dart';
import 'package:freelancer_business_os/providers/state_provider/theme_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _businessController;
  late TextEditingController _emailController;
  
  String _currentCurrency = '\$';
  String? _webPreviewUrl; 
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _businessController = TextEditingController();
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _businessController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickProfileImageFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 75,
      );

      if (pickedFile != null) {
        setState(() {
          _webPreviewUrl = pickedFile.path; 
        });
      }
    } catch (hardwareError) {
      debugPrint('Native Storage Picker Exception: $hardwareError');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentFirebaseUser = FirebaseAuth.instance.currentUser;
    final uid = currentFirebaseUser?.uid ?? 'unknown_user';

    final isDarkMode = ref.watch(themeProvider);
    final profileAsync = ref.watch(userProfileStreamProvider(uid));

    final backgroundColor = isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cardColor = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    const primaryIndigo = Color(0xFF4F46E5);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Workspace Control Panel',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 22, letterSpacing: -0.5),
        ),
      ),
      body: SafeArea(
        child: profileAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: primaryIndigo)),
          error: (err, stack) => Center(child: Text('Pipeline Stream Error: $err', style: const TextStyle(color: Colors.redAccent))),
          data: (profile) {
            if (!_isInitialized) {
              _nameController.text = profile.fullName;
              _businessController.text = profile.businessName;
              _emailController.text = profile.accountEmail;
              _currentCurrency = profile.selectedCurrencySymbol;
              _isInitialized = true;
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: _pickProfileImageFromGallery,
                        child: Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: primaryIndigo.withValues(alpha: 0.2), width: 2),
                              ),
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: primaryIndigo.withValues(alpha: 0.08),
                                
                                backgroundImage: _webPreviewUrl != null ? NetworkImage(_webPreviewUrl!) : null,
                                child: _webPreviewUrl == null 
                                  ? Text(
                                      _nameController.text.isNotEmpty ? _nameController.text.substring(0, 2).toUpperCase() : 'OS',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: primaryIndigo),
                                    )
                                  : null,
                              ),
                            ),
                            Positioned(
                              bottom: 4,
                              right: 4,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(color: primaryIndigo, shape: BoxShape.circle),
                                child: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    const Text('FREELANCER PROFILE CONFIGURATIONS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: primaryIndigo, letterSpacing: 0.5)),
                    const SizedBox(height: 12),

                    _SettingsInputTextField(controller: _nameController, label: 'Full Personal Name', isDark: isDarkMode),
                    const SizedBox(height: 14),
                    _SettingsInputTextField(controller: _businessController, label: 'Agency / Studio Branding Title', isDark: isDarkMode),
                    const SizedBox(height: 14),
                    _SettingsInputTextField(controller: _emailController, label: 'Business Contact Email Account', keyboardType: TextInputType.emailAddress, isDark: isDarkMode),
                    
                    const SizedBox(height: 28),
                    const Text('GLOBAL INTERFACE STYLING', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: primaryIndigo, letterSpacing: 0.5)),
                    const SizedBox(height: 12),

                    Container(
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
                      ),
                      child: SwitchListTile(
                        value: isDarkMode,
                        onChanged: (val) {
                          ref.read(themeProvider.notifier).toggleTheme();
                        },
                        secondary: Icon(isDarkMode ? Icons.dark_mode_outlined : Icons.light_mode_outlined, color: primaryIndigo),
                        title: Text('Activate Dark Mode View', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textColor)),
                        activeThumbColor: primaryIndigo,
                      ),
                    ),

                    const SizedBox(height: 24),
                    const Text('GLOBAL CALCULATOR DISPLAY CURRENCY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: primaryIndigo, letterSpacing: 0.5)),
                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: ['\$', '€', '£', '₨'].map((symbol) {
                        final isSelected = _currentCurrency == symbol;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _currentCurrency = symbol),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: isSelected ? primaryIndigo : cardColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: isSelected ? primaryIndigo : Colors.grey.withValues(alpha: 0.15)),
                              ),
                              child: Center(
                                child: Text(
                                  symbol,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold, 
                                    fontSize: 16, 
                                    color: isSelected ? Colors.white : textColor
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 40),

                    ElevatedButton(
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) return;
FocusScope.of(context).unfocus();
final updatedProfile = UserProfile(
id: uid,
fullName: _nameController.text.trim(),
businessName: _businessController.text.trim(),
accountEmail: _emailController.text.trim(),
selectedCurrencySymbol: _currentCurrency,
);
await ref.read(userProfileRepositoryProvider).saveProfile(updatedProfile);
if (!context.mounted) return;
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text('✨ Command Center profile configurations saved securely to Firestore cloud!'),
backgroundColor: primaryIndigo,
behavior: SnackBarBehavior.floating,
),
);
},
style: ElevatedButton.styleFrom(
backgroundColor: primaryIndigo,
foregroundColor: Colors.white,
elevation: 0,
padding: const EdgeInsets.symmetric(vertical: 16),
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
),
child: const Text('Save Workspace Profile Settings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
),
],
),
),
);
},
),
),
);
}
}

class _SettingsInputTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final bool isDark;

  const _SettingsInputTextField({
    super.key,
    required this.controller,
    required this.label,
    this.keyboardType,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    const primaryIndigo = Color(0xFF4F46E5);

    return Padding(
      
      padding: const EdgeInsets.symmetric(vertical: 8.0), 
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 15),
        validator: (v) => (v == null || v.trim().isEmpty) ? '$label cannot be empty' : null,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey, fontSize: 13),
          floatingLabelStyle: const TextStyle(color: primaryIndigo, fontWeight: FontWeight.bold),
          filled: true,
          
          fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18), 
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.withOpacity(0.15), width: 1.0),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: primaryIndigo, width: 1.5),
            borderRadius: BorderRadius.circular(12),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.redAccent, width: 1.0),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
