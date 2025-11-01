import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/profile.dart';
import '../models/child_profile_model.dart';
import '../services/auth_service.dart';
import '../services/child_profile_service.dart';
import '../state/app_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  String _age = '3';
  String _class = '1';
  String _gender = 'Male';
  String _handedness = 'Right';
  final Map<String, bool> _disabilities = {
    'Motor issues': false,
    'Speech impairment': false,
    'Visual impairment': false,
    'None': false,
  };
  bool _showValidationError = false;

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
    _nameCtrl.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFE3F2FD), // Light blue
              Color(0xFFB3E5FC), // Sky blue
              Color(0xFFE1F5FE), // Cyan tint
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF1565C0), Color(0xFF0288D1)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF1565C0).withValues(alpha: 0.3),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.person_outline_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [
                          Color(0xFF1565C0), // Deep blue
                          Color(0xFF0288D1), // Vibrant blue
                        ],
                      ).createShader(bounds),
                      child: Text(
                        'En-HanZ',
                        style: GoogleFonts.poppins(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Child Profile',
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
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
                        '✨ Help us understand your child better',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Color(0xFF1565C0),
                          letterSpacing: 0.2,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Form Card
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(36),
                          topRight: Radius.circular(36),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 30,
                            offset: const Offset(0, -8),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: ListView(
                          physics: const BouncingScrollPhysics(),
                          children: [
                            const SizedBox(height: 4),
                            _buildSectionHeader(
                              'Basic Information',
                              Icons.info_outline,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _nameCtrl,
                              label: 'Child Name',
                              icon: Icons.person_outline,
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? '⚠️ Please enter the child\'s name'
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            _buildDropdown(
                              value: _age,
                              label: 'Age',
                              icon: Icons.cake_outlined,
                              items: List.generate(
                                13,
                                (i) => (i + 3).toString(),
                              ), // Ages 3-15
                              onChanged: (v) => setState(() => _age = v ?? '3'),
                            ),
                            const SizedBox(height: 16),
                            _buildDropdown(
                              value: _class,
                              label: 'Class',
                              icon: Icons.school_outlined,
                              items: [
                                '1',
                                '2',
                                '3',
                                '4',
                                '5',
                                '6',
                                '7',
                                '8',
                                '9',
                                '10',
                                '11',
                                '12',
                              ],
                              onChanged: (v) =>
                                  setState(() => _class = v ?? '1'),
                            ),
                            const SizedBox(height: 16),
                            _buildDropdown(
                              value: _gender,
                              label: 'Gender',
                              icon: Icons.wc_outlined,
                              items: ['Male', 'Female', 'Other'],
                              onChanged: (v) =>
                                  setState(() => _gender = v ?? 'Male'),
                            ),
                            const SizedBox(height: 24),
                            _buildSectionHeader(
                              'Health Information',
                              Icons.favorite_outline,
                            ),
                            const SizedBox(height: 12),
                            const SizedBox(height: 8),
                            Text(
                              'Disability (if any)',
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ..._disabilities.keys.map((k) {
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                  gradient: _disabilities[k]!
                                      ? LinearGradient(
                                          colors: [
                                            Color(
                                              0xFF1565C0,
                                            ).withValues(alpha: 0.1),
                                            Color(
                                              0xFF0288D1,
                                            ).withValues(alpha: 0.1),
                                          ],
                                        )
                                      : null,
                                  color: _disabilities[k]!
                                      ? null
                                      : Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: _disabilities[k]!
                                        ? Color(0xFF1565C0)
                                        : Colors.grey.shade200,
                                    width: 2,
                                  ),
                                  boxShadow: _disabilities[k]!
                                      ? [
                                          BoxShadow(
                                            color: Color(
                                              0xFF1565C0,
                                            ).withValues(alpha: 0.2),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : [],
                                ),
                                child: CheckboxListTile(
                                  title: Text(
                                    k,
                                    style: GoogleFonts.inter(
                                      fontSize: 15,
                                      color: _disabilities[k]!
                                          ? Color(0xFF1565C0)
                                          : Colors.grey.shade800,
                                      fontWeight: _disabilities[k]!
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                    ),
                                  ),
                                  value: _disabilities[k],
                                  activeColor: Color(0xFF1565C0),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 6,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  onChanged: (v) {
                                    setState(() {
                                      if (k == 'None' && v == true) {
                                        _disabilities.updateAll(
                                          (key, value) => false,
                                        );
                                        _disabilities['None'] = true;
                                      } else {
                                        _disabilities['None'] = false;
                                        _disabilities[k] = v ?? false;
                                      }
                                    });
                                  },
                                ),
                              );
                            }),
                            const SizedBox(height: 20),
                            _buildSectionHeader(
                              'Writing Preference',
                              Icons.edit_outlined,
                            ),
                            const SizedBox(height: 16),
                            _buildDropdown(
                              value: _handedness,
                              label: 'Handedness',
                              icon: Icons.back_hand_outlined,
                              items: ['Left', 'Right'],
                              onChanged: (v) =>
                                  setState(() => _handedness = v ?? 'Right'),
                            ),
                            const SizedBox(height: 30),

                            // Validation Error Banner
                            if (_showValidationError)
                              Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.red.shade300,
                                    width: 2,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.error_outline_rounded,
                                      color: Colors.red.shade700,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Please enter the child\'s name to continue',
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.red.shade700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

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
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xFF1565C0), // Deep blue
                                          Color(0xFF0288D1), // Vibrant blue
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(18),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color(
                                            0xFF1565C0,
                                          ).withValues(alpha: 0.5),
                                          blurRadius: 20,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        // Explicit check for empty name
                                        if (_nameCtrl.text.trim().isEmpty) {
                                          // Show validation error banner
                                          setState(() {
                                            _showValidationError = true;
                                          });

                                          // Trigger form validation to show field error
                                          _formKey.currentState?.validate();

                                          // Show error snackbar with more prominent styling
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Row(
                                                children: [
                                                  Icon(
                                                    Icons.warning_amber_rounded,
                                                    color: Colors.white,
                                                    size: 24,
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: Text(
                                                      'Please enter the child\'s name',
                                                      style: GoogleFonts.inter(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              backgroundColor:
                                                  Colors.red.shade600,
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              margin: const EdgeInsets.all(16),
                                              duration: const Duration(
                                                seconds: 3,
                                              ),
                                              action: SnackBarAction(
                                                label: 'OK',
                                                textColor: Colors.white,
                                                onPressed: () {},
                                              ),
                                            ),
                                          );

                                          // Don't proceed
                                          return;
                                        }

                                        // Clear validation error if name is provided
                                        setState(() {
                                          _showValidationError = false;
                                        });

                                        // Create child profile and save to Firebase
                                        final authService = AuthService();
                                        final childProfileService =
                                            ChildProfileService();
                                        final userId =
                                            authService.currentUserId;

                                        if (userId != null) {
                                          final childProfile =
                                              ChildProfileModel(
                                                teacherId: userId,
                                                childName: _nameCtrl.text
                                                    .trim(),
                                                age: int.parse(_age),
                                                schoolClass: _class,
                                                gender: _gender,
                                                disabilities: _disabilities
                                                    .entries
                                                    .where((e) => e.value)
                                                    .map((e) => e.key)
                                                    .toList(),
                                                handedness: _handedness,
                                                createdAt: DateTime.now(),
                                              );

                                          try {
                                            final profileId =
                                                await childProfileService
                                                    .createChildProfile(
                                                      childProfile,
                                                    );
                                            // Set the created profile as selected
                                            appState.selectChildProfile(
                                              childProfile.copyWith(
                                                id: profileId,
                                              ),
                                            );

                                            // Also save to legacy profile for compatibility
                                            final profile = Profile(
                                              name: _nameCtrl.text.trim(),
                                              age: int.parse(_age),
                                              schoolClass: _class,
                                              gender: _gender,
                                              disabilities: _disabilities
                                                  .entries
                                                  .where((e) => e.value)
                                                  .map((e) => e.key)
                                                  .toList(),
                                              handedness: _handedness,
                                            );
                                            appState.saveProfile(profile);

                                            Navigator.pushNamed(context, '/iq');
                                          } catch (e) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Error saving profile: $e',
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
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
                                          Text(
                                            'Continue',
                                            style: GoogleFonts.inter(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Icon(
                                            Icons.arrow_forward_rounded,
                                            color: Colors.white,
                                            size: 22,
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
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        style: GoogleFonts.inter(
          fontSize: 16,
          color: Colors.grey.shade900,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.inter(
            color: Colors.grey.shade600,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF0288D1)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 20,
          ),
          errorStyle: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.red.shade700,
          ),
          errorMaxLines: 2,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1565C0), Color(0xFF0288D1)],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1565C0),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF1565C0).withValues(alpha: 0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String value,
    required String label,
    required IconData icon,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        items: items
            .map(
              (e) => DropdownMenuItem(
                value: e,
                child: Text(
                  e,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Colors.grey.shade900,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
            .toList(),
        onChanged: onChanged,
        style: GoogleFonts.inter(fontSize: 16, color: Colors.grey.shade900),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.inter(
            color: Colors.grey.shade600,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF0288D1)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 20,
          ),
        ),
        dropdownColor: Colors.white,
        icon: Icon(
          Icons.arrow_drop_down_rounded,
          color: Color(0xFF1565C0),
          size: 28,
        ),
        isExpanded: true,
        isDense: true,
        menuMaxHeight: 250, // Shows ~5 items with scrolling for more
      ),
    );
  }
}
