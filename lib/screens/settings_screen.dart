import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../models/app_settings.dart';
import '../utils/app_strings.dart';
import '../utils/modern_theme.dart';
import '../services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late String _selectedLanguage;
  late bool _voiceEnabled;
  late bool _notificationsEnabled;

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);
    _selectedLanguage = appState.settings.language;
    _voiceEnabled = appState.settings.voiceEnabled;
    _notificationsEnabled = appState.settings.notificationsEnabled;
  }

  Future<void> _saveSettings() async {
    final appState = Provider.of<AppState>(context, listen: false);
    final newSettings = AppSettings(
      language: _selectedLanguage,
      largeFontMode: false, // Keep default value
      voiceEnabled: _voiceEnabled,
      notificationsEnabled: _notificationsEnabled,
    );
    await appState.updateSettings(newSettings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: ModernTheme.blueBackgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: ModernTheme.elevation2(),
                ),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: ModernTheme.primaryBlue.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_back_rounded,
                          color: ModernTheme.primaryBlue,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.get('settings_title', _selectedLanguage),
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: ModernTheme.primaryBlue,
                            ),
                          ),
                          Text(
                            'Customize your experience',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: ModernTheme.textMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.settings_rounded,
                      color: ModernTheme.primaryBlue,
                      size: 28,
                    ),
                  ],
                ),
              ),

              // Settings List
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader('Language & Accessibility'),
                      const SizedBox(height: 16),

                      // Language Selector
                      _buildLanguageCard(),

                      const SizedBox(height: 32),

                      _buildSectionHeader('Audio Settings'),
                      const SizedBox(height: 16),

                      // Voice Toggle
                      _buildToggleCard(
                        icon: Icons.volume_up_rounded,
                        title: 'HandyBot Voice',
                        subtitle: 'Enable voice guidance and reading',
                        value: _voiceEnabled,
                        onChanged: (value) {
                          setState(() => _voiceEnabled = value);
                          _saveSettings();
                        },
                      ),

                      const SizedBox(height: 32),

                      _buildSectionHeader('Notifications'),
                      const SizedBox(height: 16),

                      // Notifications Toggle
                      _buildToggleCard(
                        icon: Icons.notifications_rounded,
                        title: 'Push Notifications',
                        subtitle: 'Get reminders to practice daily',
                        value: _notificationsEnabled,
                        onChanged: (value) {
                          setState(() => _notificationsEnabled = value);
                          _saveSettings();
                        },
                      ),

                      const SizedBox(height: 32),

                      _buildSectionHeader('Account'),
                      const SizedBox(height: 16),

                      // Clear Data Button
                      _buildActionCard(
                        icon: Icons.delete_outline_rounded,
                        title: 'Clear All Data',
                        subtitle: 'Remove all assessment history',
                        color: ModernTheme.dangerRed,
                        onTap: _showClearDataDialog,
                      ),

                      const SizedBox(height: 12),

                      // Logout Button
                      _buildActionCard(
                        icon: Icons.logout_rounded,
                        title: 'Logout',
                        subtitle: 'Sign out of your account',
                        color: ModernTheme.secondaryPurple,
                        onTap: () async {
                          // Show logout confirmation dialog
                          final shouldLogout = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              title: Text(
                                'Logout',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  color: ModernTheme.primaryBlue,
                                ),
                              ),
                              content: Text(
                                'Are you sure you want to logout?',
                                style: GoogleFonts.inter(
                                  color: ModernTheme.textMedium,
                                  height: 1.5,
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: Text(
                                    'Cancel',
                                    style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: ModernTheme.textMedium,
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        ModernTheme.secondaryPurple,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    'Logout',
                                    style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );

                          if (shouldLogout == true && mounted) {
                            try {
                              await AuthService().signOut();
                              // Navigate to login screen and clear navigation stack
                              if (mounted) {
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                  '/login',
                                  (route) =>
                                      false, // Remove all previous routes
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Logout failed: $e',
                                      style: GoogleFonts.inter(),
                                    ),
                                    backgroundColor: ModernTheme.dangerRed,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                );
                              }
                            }
                          }
                        },
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            gradient: ModernTheme.primaryGradient,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: ModernTheme.textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: ModernTheme.modernCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: ModernTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: ModernTheme.coloredShadow(
                    ModernTheme.primaryBlue,
                    opacity: 0.3,
                  ),
                ),
                child: Icon(
                  Icons.language_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Language',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: ModernTheme.textDark,
                      ),
                    ),
                    Text(
                      'Choose your preferred language',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: ModernTheme.textMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['English', 'Hindi', 'Kannada'].map((lang) {
              final isSelected = _selectedLanguage == lang;
              return InkWell(
                onTap: () {
                  setState(() => _selectedLanguage = lang);
                  _saveSettings();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${AppStrings.get('language_changed', lang)} $lang',
                        style: GoogleFonts.inter(),
                      ),
                      backgroundColor: ModernTheme.primaryBlue,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    gradient: isSelected ? ModernTheme.primaryGradient : null,
                    color: isSelected ? null : ModernTheme.hoverLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? ModernTheme.primaryBlue
                          : ModernTheme.borderLight,
                      width: 2,
                    ),
                    boxShadow: isSelected
                        ? ModernTheme.coloredShadow(
                            ModernTheme.primaryBlue,
                            opacity: 0.2,
                          )
                        : null,
                  ),
                  child: Text(
                    lang,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : ModernTheme.textMedium,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: ModernTheme.modernCard(),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: value
                  ? ModernTheme.primaryBlue.withValues(alpha: 0.1)
                  : ModernTheme.hoverLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: value ? ModernTheme.primaryBlue : ModernTheme.textLight,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: ModernTheme.textDark,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: ModernTheme.textMedium,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: ModernTheme.primaryBlue,
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: ModernTheme.modernCard(),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: ModernTheme.textDark,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: ModernTheme.textMedium,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: color, size: 18),
          ],
        ),
      ),
    );
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Clear All Data?',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: ModernTheme.dangerRed,
          ),
        ),
        content: Text(
          'This will permanently delete all your assessment history and progress. This action cannot be undone.',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: ModernTheme.textMedium,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: ModernTheme.textMedium,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final appState = Provider.of<AppState>(context, listen: false);
              await appState.clearAllData();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'All data cleared successfully',
                      style: GoogleFonts.inter(),
                    ),
                    backgroundColor: ModernTheme.dangerRed,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ModernTheme.dangerRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Clear Data',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
