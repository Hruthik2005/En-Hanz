import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../state/app_state.dart';
import '../utils/modern_theme.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen>
    with SingleTickerProviderStateMixin {
  File? _image;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
        );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource src) async {
    final XFile? file = await ImagePicker().pickImage(
      source: src,
      maxWidth: 1200,
    );
    if (file == null) return;
    setState(() {
      _image = File(file.path);
    });
    if (mounted) {
      final appState = Provider.of<AppState>(context, listen: false);
      appState.saveHandwritingPath(file.path);
    }
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
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: ModernTheme.elevation2(),
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.arrow_back_rounded,
                              color: ModernTheme.primaryBlue,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: ShaderMask(
                              shaderCallback: (bounds) => ModernTheme
                                  .primaryGradient
                                  .createShader(bounds),
                              child: Text(
                                'En-HanZ',
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 48), // Balance the back button
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: ModernTheme.primaryGradient,
                        shape: BoxShape.circle,
                        boxShadow: ModernTheme.coloredShadow(
                          ModernTheme.primaryBlue,
                          opacity: 0.3,
                        ),
                      ),
                      child: Icon(
                        Icons.upload_file_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Upload Handwriting',
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '✍️ Choose how to provide the sample',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: ModernTheme.primaryBlue,
                          letterSpacing: 0.2,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Main Content
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(36),
                          topRight: Radius.circular(36),
                        ),
                        boxShadow: ModernTheme.elevation3(),
                      ),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          children: [
                            // Upload Options
                            Row(
                              children: [
                                Expanded(
                                  child: _OptionCard(
                                    icon: Icons.camera_alt_rounded,
                                    label: 'Camera',
                                    subtitle: 'Take Photo',
                                    gradient: [
                                      ModernTheme.primaryBlue,
                                      ModernTheme.primaryBlueDark,
                                    ],
                                    onTap: () => _pickImage(ImageSource.camera),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _OptionCard(
                                    icon: Icons.photo_library_rounded,
                                    label: 'Gallery',
                                    subtitle: 'Choose Image',
                                    gradient: [
                                      ModernTheme.infoCyan,
                                      ModernTheme.infoCyanDark,
                                    ],
                                    onTap: () =>
                                        _pickImage(ImageSource.gallery),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _OptionCard(
                              icon: Icons.draw_rounded,
                              label: 'Draw with Stylus',
                              subtitle: 'Write directly on screen',
                              gradient: [
                                ModernTheme.accentAmber,
                                ModernTheme.accentAmberDark,
                              ],
                              onTap: () =>
                                  Navigator.pushNamed(context, '/drawing'),
                              isWide: true,
                            ),
                            const SizedBox(height: 26),
                            // Preview Section
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: ModernTheme.primaryBlue.withValues(
                                  alpha: 0.05,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: ModernTheme.primaryBlue.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.tips_and_updates_rounded,
                                    color: ModernTheme.primaryBlue,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Tip: Use clear, well-lit photos with visible handwriting',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: ModernTheme.primaryBlue,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              height: 320,
                              decoration: BoxDecoration(
                                color: ModernTheme.backgroundLight,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: ModernTheme.borderLight,
                                  width: 2,
                                ),
                              ),
                              child: _image != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(18),
                                      child: Stack(
                                        children: [
                                          Center(
                                            child: Image.file(
                                              _image!,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                          Positioned(
                                            top: 12,
                                            right: 12,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withValues(alpha: 0.2),
                                                    blurRadius: 8,
                                                  ),
                                                ],
                                              ),
                                              child: IconButton(
                                                icon: Icon(
                                                  Icons.close_rounded,
                                                  color: Colors.red.shade600,
                                                ),
                                                onPressed: () => setState(
                                                  () => _image = null,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(24),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade100,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.image_outlined,
                                              size: 64,
                                              color: Colors.grey.shade400,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'No Image Selected',
                                            style: GoogleFonts.inter(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Choose an option above to upload',
                                            style: GoogleFonts.inter(
                                              fontSize: 13,
                                              color: Colors.grey.shade500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                            ),

                            const SizedBox(height: 24),

                            // Warning message when no image
                            if (_image == null)
                              Container(
                                padding: const EdgeInsets.all(16),
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.orange.shade300,
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.warning_amber_rounded,
                                      color: Colors.orange.shade700,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Please upload or capture a handwriting sample to continue',
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          color: Colors.orange.shade900,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            // Analyze Button
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.95, end: 1.0),
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOut,
                              builder: (context, value, child) {
                                return Transform.scale(
                                  scale: value,
                                  child: Container(
                                    height: 56,
                                    decoration: BoxDecoration(
                                      gradient: _image != null
                                          ? ModernTheme.primaryGradient
                                          : null,
                                      color: _image == null
                                          ? ModernTheme.borderLight
                                          : null,
                                      borderRadius: BorderRadius.circular(18),
                                      boxShadow: _image != null
                                          ? ModernTheme.coloredShadow(
                                              ModernTheme.primaryBlue,
                                              opacity: 0.5,
                                            )
                                          : null,
                                    ),
                                    child: ElevatedButton(
                                      onPressed: _image == null
                                          ? null
                                          : () {
                                              Navigator.pushReplacementNamed(
                                                context,
                                                '/processing',
                                              );
                                            },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        disabledBackgroundColor:
                                            ModernTheme.borderLight,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.analytics_rounded,
                                            color: Colors.white,
                                            size: 22,
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            'Analyze Handwriting',
                                            style: GoogleFonts.inter(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 20),
                          ],
                        ), // Column
                      ), // SingleChildScrollView
                    ), // Container
                  ), // SlideTransition
                ), // FadeTransition
              ), // Expanded
            ], // SafeArea Column children
          ),
        ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final List<Color> gradient;
  final VoidCallback? onTap;
  final bool isWide;

  const _OptionCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.gradient,
    this.onTap,
    this.isWide = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: isWide ? 100 : 100,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradient[0].withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: isWide
            ? Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          label,
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: Colors.white, size: 24),
                  ),
                  const SizedBox(height: 4),
                  Flexible(
                    child: Text(
                      label,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Flexible(
                    child: Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
