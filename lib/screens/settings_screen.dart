import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freelancer_business_os/models/user_profile.dart';
import 'package:freelancer_business_os/providers/repositories_provider/client_repo_provider.dart';
import 'package:freelancer_business_os/providers/repositories_provider/user_profile_repo_provider.dart';
import 'package:freelancer_business_os/providers/state_provider/theme_provider.dart';
import 'package:freelancer_business_os/providers/stream_provider/user_profile_stream_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _primaryIndigo = Color(0xFF4F46E5);
const _luxuryRose = Color(0xFFE11D48);

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TextEditingController _nameController;
  late TextEditingController _businessController;

  Uint8List? _memoryImageBytes;
  bool _isInitialized = false;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _businessController = TextEditingController();
    _loadSavedProfileImage();
  }

  Future<void> _loadSavedProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final base64String = prefs.getString('saved_profile_avatar');
    if (base64String != null && mounted) {
      setState(() {
        _memoryImageBytes = base64Decode(base64String);
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _businessController.dispose();
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
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('saved_profile_avatar', base64Encode(imageBytes));

        if (!mounted) return;
        setState(() => _memoryImageBytes = imageBytes);
      }
    } catch (e) {
      debugPrint('Media Picker Error: $e');
    }
  }

  void _openEditProfileDialog(UserProfile profile, String uid) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Edit Workspace Info',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Display Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _businessController,
              decoration:
                  const InputDecoration(labelText: 'Studio / Brand Name'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final updated = profile.copyWith(
                fullName: _nameController.text.trim(),
                businessName: _businessController.text.trim(),
              );
              await ref.read(userProfileRepositoryProvider).saveProfile(updated);
              if (!mounted) return;
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryIndigo,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _openChangePasswordDialog() {
    final email = ref.read(authProvider).currentUser?.email ?? '';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Reset Password',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: Text('Send a secure password reset link to:\n$email?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (email.isNotEmpty) {
                await ref
                    .read(authProvider)
                    .sendPasswordResetEmail(email: email);
                if (!mounted) return;
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content:
                          Text('Password reset link sent to your email!')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: _primaryIndigo, foregroundColor: Colors.white),
            child: const Text('Send Link'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSignOut() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Log out of workspace?'),
        content: const Text(
            'You will need to sign back in with your email and password.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: _primaryIndigo, foregroundColor: Colors.white),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await ref.read(authProvider).signOut();
    }
  }

  Future<void> _handleDeleteAccount() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete your account?'),
        content: const Text(
          'This action is irreversible. All your contracts, time logs, and invoices will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _luxuryRose,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete Permanently'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      final auth = ref.read(authProvider);

      try {
        
        await auth.currentUser?.delete();
        
      } catch (e) {
        if (!mounted) return;

        
        
        await showDialog(
          context: context,
          builder: (dialogCtx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Security Verification Required'),
            content: const Text(
              'For your security, deleting an account requires recent credentials.\n\nYou will now be logged out. Please log in once more, and then you can confirm permanent deletion.',
            ),
            actions: [
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(dialogCtx);
                  await auth.signOut(); 
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryIndigo,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Proceed to Login'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final uid = auth.currentUser?.uid ?? 'unknown_user';
    final userEmail = auth.currentUser?.email ?? 'user@example.com';

    final isDarkMode = ref.watch(themeProvider);

    final backgroundColor =
        isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF3F4F6);
    final cardColor = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF1F2937);
    final textSubColor = isDarkMode ? Colors.white60 : Colors.grey.shade600;

    final profileAsync = ref.watch(userProfileStreamProvider(uid));

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Settings',
          style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 24,
              letterSpacing: -0.5),
        ),
      ),
      body: SafeArea(
        child: profileAsync.when(
          loading: () => const Center(
              child: CircularProgressIndicator(color: _primaryIndigo)),
          error: (err, stack) => Center(
              child: Text('Sync Error: $err',
                  style: const TextStyle(color: _luxuryRose))),
          data: (profile) {
            if (!_isInitialized) {
              _nameController.text = profile.fullName;
              _businessController.text = profile.businessName;
              _isInitialized = true;
            }

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  
                  GestureDetector(
                    onTap: _pickProfileImageFromGallery,
                    child: Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 44,
                            backgroundColor:
                                _primaryIndigo.withValues(alpha: 0.1),
                            backgroundImage: _memoryImageBytes != null
                                ? MemoryImage(_memoryImageBytes!)
                                : null,
                            child: _memoryImageBytes == null
                                ? Text(
                                    profile.fullName.isNotEmpty
                                        ? profile.fullName
                                            .substring(0, 1)
                                            .toUpperCase()
                                        : 'F',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 32,
                                        color: _primaryIndigo),
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                  color: _primaryIndigo,
                                  shape: BoxShape.circle),
                              child: const Icon(Icons.camera_alt_rounded,
                                  color: Colors.white, size: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    profile.fullName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: textColor),
                  ),
                  Text(
                    profile.businessName,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: textSubColor),
                  ),

                  const SizedBox(height: 28),

                  
                  _buildSectionHeader('ACCOUNT', textSubColor),
                  _buildCardContainer(
                    cardColor,
                    isDarkMode,
                    children: [
                      _buildSettingsTile(
                        icon: Icons.person_outline_rounded,
                        title: 'Display & Studio Name',
                        subtitle:
                            '${profile.fullName} • ${profile.businessName}',
                        onTap: () => _openEditProfileDialog(profile, uid),
                        textColor: textColor,
                        textSubColor: textSubColor,
                      ),
                      _buildDivider(isDarkMode),
                      _buildSettingsTile(
                        icon: Icons.mail_outline_rounded,
                        title: 'Email Address',
                        subtitle: userEmail,
                        onTap: null,
                        textColor: textColor,
                        textSubColor: textSubColor,
                        trailing: null,
                      ),
                      _buildDivider(isDarkMode),
                      _buildSettingsTile(
                        icon: Icons.lock_outline_rounded,
                        title: 'Change Password',
                        subtitle: 'Send password reset link to your email',
                        onTap: _openChangePasswordDialog,
                        textColor: textColor,
                        textSubColor: textSubColor,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  
                  _buildSectionHeader('PREFERENCES', textSubColor),
                  _buildCardContainer(
                    cardColor,
                    isDarkMode,
                    children: [
                      SwitchListTile(
                        value: isDarkMode,
                        onChanged: (val) =>
                            ref.read(themeProvider.notifier).toggleTheme(),
                        secondary: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: Colors.grey.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(10)),
                          child: Icon(
                              isDarkMode
                                  ? Icons.dark_mode_rounded
                                  : Icons.light_mode_rounded,
                              size: 20,
                              color: _primaryIndigo),
                        ),
                        title: Text('Appearance',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: textColor)),
                        subtitle: Text(
                            isDarkMode
                                ? 'Dark Interface'
                                : 'Light Interface',
                            style: TextStyle(
                                fontSize: 12, color: textSubColor)),
                        activeThumbColor: _primaryIndigo,
                      ),
                      _buildDivider(isDarkMode),
                      SwitchListTile(
                        value: _notificationsEnabled,
                        onChanged: (val) =>
                            setState(() => _notificationsEnabled = val),
                        secondary: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: Colors.grey.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.notifications_none_rounded,
                              size: 20, color: _primaryIndigo),
                        ),
                        title: Text('Notifications',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: textColor)),
                        subtitle: Text(
                            'Background timer alerts & invoice reminders',
                            style: TextStyle(
                                fontSize: 12, color: textSubColor)),
                        activeThumbColor: _primaryIndigo,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  
                  _buildSectionHeader('ABOUT & SESSIONS', textSubColor),
                  _buildCardContainer(
                    cardColor,
                    isDarkMode,
                    children: [
                      _buildSettingsTile(
                        icon: Icons.info_outline_rounded,
                        title: 'Version',
                        subtitle: 'v1.0.0 (Production Release)',
                        onTap: null,
                        textColor: textColor,
                        textSubColor: textSubColor,
                        trailing: null,
                      ),
                      _buildDivider(isDarkMode),
                      _buildSettingsTile(
                        icon: Icons.logout_rounded,
                        title: 'Log Out',
                        subtitle: 'Safely sign out of this device',
                        onTap: _handleSignOut,
                        textColor: textColor,
                        textSubColor: textSubColor,
                        iconColor: _primaryIndigo,
                      ),
                      _buildDivider(isDarkMode),
                      _buildSettingsTile(
                        icon: Icons.delete_forever_rounded,
                        title: 'Delete Account',
                        subtitle: 'Permanently purge all data and contracts',
                        onTap: _handleDeleteAccount,
                        textColor: _luxuryRose,
                        textSubColor: textSubColor,
                        iconColor: _luxuryRose,
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: color,
            letterSpacing: 1.0),
      ),
    );
  }

  Widget _buildCardContainer(Color bgColor, bool isDark,
      {required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.grey.withValues(alpha: 0.12),
        ),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
    required Color textColor,
    required Color textSubColor,
    Color? iconColor,
    Widget? trailing = const Icon(Icons.arrow_forward_ios_rounded,
        size: 14, color: Colors.grey),
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (iconColor ?? _primaryIndigo).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: iconColor ?? _primaryIndigo),
      ),
      title: Text(title,
          style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.bold, color: textColor)),
      subtitle: Text(subtitle,
          style: TextStyle(fontSize: 12, color: textSubColor)),
      trailing: trailing,
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      indent: 52,
      color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.withValues(alpha: 0.1),
    );
  }
}