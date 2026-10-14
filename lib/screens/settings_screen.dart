
import 'dart:typed_data';

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
  Uint8List? _memoryImageBytes; 
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
        final Uint8List imageBytes = await pickedFile.readAsBytes();
        setState(() {
          _memoryImageBytes = imageBytes;
        });
      }
    } catch (e) {
      debugPrint('Media Picker Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentFirebaseUser = FirebaseAuth.instance.currentUser;
    final uid = currentFirebaseUser?.uid ?? 'unknown_user';

    final isDarkMode = ref.watch(themeProvider);
    
    final backgroundColor = isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF3F4F6);
    final cardColor = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF1F2937);
    final textSubColor = isDarkMode ? Colors.white60 : Colors.grey.shade600;
    const primaryIndigo = Color(0xFF4F46E5);

    final profileAsync = ref.watch(userProfileStreamProvider(uid));

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Workspace Profile',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 24, letterSpacing: -0.8),
        ),
      ),
      body: SafeArea(
        child: profileAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: primaryIndigo)),
          error: (err, stack) => Center(child: Text('Stream Sync Error: $err', style: const TextStyle(color: Colors.redAccent))),
          data: (profile) {
            if (!_isInitialized) {
              _nameController.text = profile.fullName;
              _businessController.text = profile.businessName;
              _emailController.text = profile.accountEmail;
              _currentCurrency = profile.selectedCurrencySymbol;
              _isInitialized = true;
            }

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // BLOCK 1: FLOATING HERO USER HEADER
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.04),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          )
                        ],
                      ),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: _pickProfileImageFromGallery,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 104,
                                  height: 104,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const LinearGradient(
                                      colors: [primaryIndigo, Color(0xFF818CF8)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 96,
                                  height: 96,
                                  decoration: BoxDecoration(
                                    color: cardColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: CircleAvatar(
                                    radius: 46,
                                    backgroundColor: primaryIndigo.withValues(alpha: 0.05),
                                    backgroundImage: _memoryImageBytes != null ? MemoryImage(_memoryImageBytes!) : null,
                                    child: _memoryImageBytes == null 
                                      ? Text(
                                          _nameController.text.isNotEmpty ? _nameController.text.substring(0, 2).toUpperCase() : 'OS',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 26, color: primaryIndigo, letterSpacing: -0.5),
                                        )
                                      : null,
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: primaryIndigo,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: cardColor, width: 2),
                                    ),
                                    child: const Icon(Icons.edit_rounded, color: Colors.white, size: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _nameController.text.isNotEmpty ? _nameController.text : 'New Freelancer',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: textColor, letterSpacing: -0.5),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _businessController.text.isNotEmpty ? _businessController.text : 'Independent Studio',
                            style: TextStyle(fontSize: 13, color: textSubColor, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 28),
                    Text('ACCOUNT PARAMETERS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textSubColor, letterSpacing: 1.2)),
                    const SizedBox(height: 12),

                    // BLOCK 2: UNIFIED FIELD FORMS DECK
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDarkMode ? 0.1 : 0.02),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          )
                        ],
                      ),
                      child: Column(
                        children: [
                          _SettingsInputTextField(controller: _nameController, label: 'Full Display Name', icon: Icons.person_outline_rounded, isDark: isDarkMode),
                          Divider(height: 24, color: Colors.grey.withValues(alpha: 0.15)),
                          _SettingsInputTextField(controller: _businessController, label: 'Studio Branding', icon: Icons.business_center_outlined, isDark: isDarkMode),
                          Divider(height: 24, color: Colors.grey.withValues(alpha: 0.15)),
_SettingsInputTextField(controller: _emailController, label: 'Billing Email', icon: Icons.mail_outline_rounded, keyboardType: TextInputType.emailAddress, isDark: isDarkMode),
],
),
),
const SizedBox(height: 28),
Text('SYSTEM UTILITIES', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textSubColor, letterSpacing: 1.2)),
const SizedBox(height: 12),
// BLOCK 3: INTEGRATED UTILITY SETTINGS SWITCH
Container(
decoration: BoxDecoration(
color: cardColor,
borderRadius: BorderRadius.circular(20),
boxShadow: [
BoxShadow(
color: Colors.black.withValues(alpha: isDarkMode ? 0.1 : 0.02),
blurRadius: 16,
offset: const Offset(0, 8),
)
],
),
child: SwitchListTile(
value: isDarkMode,
onChanged: (val) => ref.read(themeProvider.notifier).toggleTheme(),
secondary: Container(
padding: const EdgeInsets.all(8),
decoration: BoxDecoration(color: primaryIndigo.withValues(alpha: 0.08), shape: BoxShape.circle),
child: Icon(isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded, color: primaryIndigo, size: 20),
),
title: Text('Dark Interface Core', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor)),
subtitle: Text('Invert global canvas stylesheets', style: TextStyle(fontSize: 12, color: textSubColor)),
activeThumbColor: primaryIndigo,
),
),
const SizedBox(height: 28),
Text('GLOBAL CURRENCY MATRICES', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textSubColor, letterSpacing: 1.2)),
const SizedBox(height: 12),
// BLOCK 4: PREMIUM CHIPS SELECTOR DECK (FLAG CHIPS!)
Container(
padding: const EdgeInsets.all(12),
decoration: BoxDecoration(
color: cardColor,
borderRadius: BorderRadius.circular(24),
boxShadow: [
BoxShadow(
color: Colors.black.withValues(alpha: isDarkMode ? 0.1 : 0.02),
blurRadius: 16,
offset: const Offset(0, 8),
)
],
),
child: Row(
children: [
_buildCurrencyFlagChip('\$', 'USD', '🇺🇸', isDarkMode, primaryIndigo),
_buildCurrencyFlagChip('€', 'EUR', '🇪🇺', isDarkMode, primaryIndigo),
_buildCurrencyFlagChip('£', 'GBP', '🇬🇧', isDarkMode, primaryIndigo),
_buildCurrencyFlagChip('₨', 'PKR', '🇵🇰', isDarkMode, primaryIndigo),
],
),
),
const SizedBox(height: 36),
// BLOCK 5: SYSTEM CONFIGURATIONS SAVE BUTTON
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
content: Text('✨ Workspace Profile settings updated cleanly!'),
backgroundColor: primaryIndigo,
behavior: SnackBarBehavior.floating,
),
);
},
style: ElevatedButton.styleFrom(
backgroundColor: primaryIndigo,
foregroundColor: Colors.white,
elevation: 0,
padding: const EdgeInsets.symmetric(vertical: 18),
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
),
child: const Text('Save Profile Settings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: -0.2)),
),
const SizedBox(height: 24),
],
),
),
);
},
),
),
);
}
Widget _buildCurrencyFlagChip(String symbol, String code, String flag, bool isDark, Color indigo) {
final isSelected = _currentCurrency == symbol;
return Expanded(
child: GestureDetector(
onTap: () => setState(() => _currentCurrency = symbol),
child: AnimatedContainer(
duration: const Duration(milliseconds: 200),
margin: const EdgeInsets.symmetric(horizontal: 4),
padding: const EdgeInsets.symmetric(vertical: 14),
decoration: BoxDecoration(
gradient: isSelected
? const LinearGradient(colors: [Color(0xFF4F46E5), Color(0xFF6366F1)])
: null,
color: isSelected ? null : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF9FAFB)),
borderRadius: BorderRadius.circular(16),
border: Border.all(
color: isSelected ? Colors.transparent : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.withValues(alpha: 0.1)),
),
),
child: Column(
children: [
Text(flag, style: const TextStyle(fontSize: 18)),
const SizedBox(height: 6),
Text(
code,
style: TextStyle(
fontSize: 12,
fontWeight: FontWeight.bold,
color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87)
)
),
const SizedBox(height: 2),
Text(
symbol,
style: TextStyle(
fontSize: 11,
color: isSelected ? Colors.white70 : Colors.grey,
fontWeight: FontWeight.bold
)
),
],
),
),
),
);
}
}
class _SettingsInputTextField extends StatelessWidget {
final TextEditingController controller;
final String label;
final IconData icon;
final TextInputType? keyboardType;
final bool isDark;
const _SettingsInputTextField({
required this.controller,
required this.label,
required this.icon,
this.keyboardType,
required this.isDark,
});
@override
Widget build(BuildContext context) {
return TextFormField(
controller: controller,
keyboardType: keyboardType,
style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 14, fontWeight: FontWeight.w500),
validator: (v) => (v == null || v.trim().isEmpty) ? '$label cannot be empty' : null,
decoration: InputDecoration(
labelText: label,
labelStyle: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w400),
floatingLabelStyle: const TextStyle(color: Color(0xFF4F46E5), fontWeight: FontWeight.bold),
prefixIcon: Icon(icon, color: const Color(0xFF4F46E5).withValues(alpha: 0.7), size: 18),
// 🌟 FIXED PROPERTY EXPRESSIONS: Removed brackets entirely to follow clean token definitions!
border: InputBorder.none,
enabledBorder: InputBorder.none,
focusedBorder: InputBorder.none,
contentPadding: const EdgeInsets.symmetric(vertical: 4),
),
);
}
}