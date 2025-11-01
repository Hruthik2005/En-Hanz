import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/child_profile_model.dart';
import '../services/auth_service.dart';
import '../services/child_profile_service.dart';
import '../state/app_state.dart';
import '../utils/modern_theme.dart';

/// Screen for teachers to select or create child profiles
/// Each teacher can manage multiple students
class ChildProfileSelectionScreen extends StatefulWidget {
  final String? targetRoute; // Route to navigate after selection

  const ChildProfileSelectionScreen({super.key, this.targetRoute});

  @override
  State<ChildProfileSelectionScreen> createState() =>
      _ChildProfileSelectionScreenState();
}

class _ChildProfileSelectionScreenState
    extends State<ChildProfileSelectionScreen> {
  final _childProfileService = ChildProfileService();
  final _authService = AuthService();
  List<ChildProfileModel> _childProfiles = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadChildProfiles();
  }

  Future<void> _loadChildProfiles() async {
    try {
      final userId = _authService.currentUserId;
      if (userId != null) {
        final profiles = await _childProfileService.getTeacherChildProfiles(
          userId,
        );
        setState(() {
          _childProfiles = profiles;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading child profiles: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<ChildProfileModel> get _filteredProfiles {
    if (_searchQuery.isEmpty) {
      return _childProfiles;
    }
    return _childProfiles
        .where(
          (profile) => profile.childName.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ),
        )
        .toList();
  }

  void _selectChildProfile(ChildProfileModel profile) {
    final appState = Provider.of<AppState>(context, listen: false);
    appState.selectChildProfile(profile);

    // Navigate to the target route or default to IQ test
    final route = widget.targetRoute ?? '/iq';
    Navigator.pushNamed(context, route);
  }

  void _createNewProfile() {
    Navigator.pushNamed(context, '/profile').then((_) {
      // Reload profiles after creating new one
      _loadChildProfiles();
    });
  }

  Future<void> _deleteProfile(ChildProfileModel profile) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${profile.childName}?'),
        content: Text(
          'This will delete the child profile and all assessment history. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && profile.id != null) {
      try {
        await _childProfileService.deleteChildProfile(profile.id!);
        _loadChildProfiles();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${profile.childName} deleted successfully'),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error deleting profile: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine title based on target route
    String title = 'Select Student';
    String subtitle = 'Choose a student to assess';

    if (widget.targetRoute == '/results') {
      title = 'Select Student';
      subtitle = 'View assessment report for';
    } else if (widget.targetRoute == '/practice') {
      title = 'Select Student';
      subtitle = 'Open practice zone for';
    }

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
                        IconButton(
                          icon: Icon(
                            Icons.arrow_back,
                            color: ModernTheme.textDark,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                title,
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: ModernTheme.textDark,
                                ),
                              ),
                              Text(
                                subtitle,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: ModernTheme.textMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 48), // Balance the back button
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Search bar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: ModernTheme.elevation1(),
                      ),
                      child: TextField(
                        onChanged: (value) =>
                            setState(() => _searchQuery = value),
                        decoration: InputDecoration(
                          hintText: 'Search students...',
                          icon: Icon(
                            Icons.search,
                            color: ModernTheme.primaryBlue,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Children list
              Expanded(
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            ModernTheme.primaryBlue,
                          ),
                        ),
                      )
                    : _filteredProfiles.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: _filteredProfiles.length,
                        itemBuilder: (context, index) {
                          final profile = _filteredProfiles[index];
                          return _buildChildCard(profile);
                        },
                      ),
              ),

              // Add new child button
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: ElevatedButton(
                  onPressed: _createNewProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ModernTheme.primaryBlue,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        'Add New Student',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
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

  Widget _buildChildCard(ChildProfileModel profile) {
    final hasAssessments = profile.lastAssessmentDate != null;
    final daysAgo = hasAssessments
        ? DateTime.now().difference(profile.lastAssessmentDate!).inDays
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: ModernTheme.elevation2(),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _selectChildProfile(profile),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: ModernTheme.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      profile.childName[0].toUpperCase(),
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.childName,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: ModernTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Age: ${profile.age} • Class: ${profile.schoolClass}',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: ModernTheme.textMedium,
                        ),
                      ),
                      if (hasAssessments) ...[
                        const SizedBox(height: 4),
                        Text(
                          daysAgo == 0
                              ? 'Assessed today'
                              : 'Last assessed $daysAgo days ago',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: ModernTheme.successGreen,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ] else ...[
                        const SizedBox(height: 4),
                        Text(
                          'No assessments yet',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: ModernTheme.textLight,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Actions
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'delete') {
                      _deleteProfile(profile);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red, size: 20),
                          const SizedBox(width: 8),
                          Text('Delete'),
                        ],
                      ),
                    ),
                  ],
                  child: Icon(Icons.more_vert, color: ModernTheme.textMedium),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: ModernTheme.textLight),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty ? 'No students yet' : 'No students found',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: ModernTheme.textMedium,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty
                ? 'Add your first student to start assessments'
                : 'Try a different search term',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: ModernTheme.textLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
