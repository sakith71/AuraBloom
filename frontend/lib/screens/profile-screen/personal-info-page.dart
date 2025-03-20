import 'package:flutter/material.dart';
import 'package:frontend/models/user-model.dart';
import 'package:frontend/services/auth-service.dart';
import 'package:frontend/services/firestore_service.dart';
import 'package:intl/intl.dart';

class PersonalInfoPage extends StatefulWidget {
  const PersonalInfoPage({super.key});

  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _birthdayController = TextEditingController();

  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  UserModel? _userModel;

  DateTime? _selectedDate;
  bool _isLoading = false;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (!mounted) return;

    setState(() {
      _isInitializing = true;
    });

    try {
      // Get email from Firebase Auth
      _emailController.text = _authService.currentUser?.email ?? '';

      // Get user data from Firestore
      if (_authService.currentUserId != null) {
        final userData = await _firestoreService.getUserProfile(
          _authService.currentUserId!,
        );

        // Check if widget is still mounted after async operation
        if (!mounted) return;

        if (userData != null) {
          setState(() {
            _userModel = userData;
            _nameController.text = userData.name;

            // Use lastPeriodDate as a reference point if there's no birthday yet
            // In a real implementation, we should add a birthday field to the UserModel
            // Since we're transitioning to use birthday, we need to handle the case
            // where the existing data doesn't have a birthday field yet
            final DateTime? userBirthday = userData.birthday;
            if (userBirthday != null) {
              _selectedDate = userBirthday;
              _birthdayController.text = _formatDate(_selectedDate!);
            } else {
              // Fallback to calculate from age
              final now = DateTime.now();
              _selectedDate = DateTime(
                now.year - userData.age,
                now.month,
                now.day,
              );
              _birthdayController.text = _formatDate(_selectedDate!);
            }
          });
        }
      }
    } catch (e) {
      // Check if widget is still mounted before showing error
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading user data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      // Final check if widget is still mounted
      if (!mounted) return;

      setState(() {
        _isInitializing = false;
      });
    }
  }

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    _nameController.dispose();
    _emailController.dispose();
    _birthdayController.dispose();
    super.dispose();
  }

  // Format date for display
  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  // Calculate age from birthday
  int _calculateAge(DateTime birthDate) {
    final currentDate = DateTime.now();
    int age = currentDate.year - birthDate.year;

    // Check if birthday has occurred this year
    final bool hasHadBirthdayThisYear =
        currentDate.month > birthDate.month ||
        (currentDate.month == birthDate.month &&
            currentDate.day >= birthDate.day);

    if (!hasHadBirthdayThisYear) {
      age--;
    }

    return age;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Personal Information',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFFE8D5E4), // Light lavender header
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body:
          _isInitializing
              ? Container(
                decoration: const BoxDecoration(
                  color: Color(
                    0xFFFCF0F7,
                  ), // Using the same background color as PrivacyPage
                ),
                child: const Center(child: CircularProgressIndicator()),
              )
              : Container(
                decoration: const BoxDecoration(
                  color: Color(
                    0xFFFCF0F7,
                  ), // Using the same background color as PrivacyPage
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      Expanded(
                        child: Form(
                          key: _formKey,
                          child: ListView(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 20,
                            ),
                            children: [
                              // Form fields
                              _buildFormField(
                                controller: _nameController,
                                label: 'Full Name',
                                icon: Icons.person_outline,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your name';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),

                              _buildFormField(
                                controller: _emailController,
                                label: 'Email',
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                readOnly: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  if (!RegExp(
                                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                  ).hasMatch(value)) {
                                    return 'Please enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),

                              _buildFormField(
                                controller: _birthdayController,
                                label: 'Birthday',
                                icon: Icons.cake_outlined,
                                readOnly: true,
                                onTap: () async {
                                  if (!mounted) return;

                                  final initialDate =
                                      _selectedDate ?? DateTime(1998, 5, 15);
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: initialDate,
                                    firstDate: DateTime(1950),
                                    lastDate: DateTime.now(),
                                    builder: (context, child) {
                                      return Theme(
                                        data: Theme.of(context).copyWith(
                                          colorScheme: const ColorScheme.light(
                                            primary: Color(0xFFE91E63),
                                            onPrimary: Colors.white,
                                            onSurface: Colors.black,
                                          ),
                                          textButtonTheme: TextButtonThemeData(
                                            style: TextButton.styleFrom(
                                              foregroundColor: const Color(
                                                0xFFE91E63,
                                              ),
                                            ),
                                          ),
                                        ),
                                        child: child!,
                                      );
                                    },
                                  );

                                  // Check if widget is still mounted after date picker
                                  if (!mounted) return;

                                  if (date != null) {
                                    setState(() {
                                      _selectedDate = date;
                                      _birthdayController.text = _formatDate(
                                        date,
                                      );
                                    });
                                  }
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please select your birthday';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Save button
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        child: _buildSaveButton(),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF555555),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: readOnly ? Colors.grey.shade100 : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              prefixIcon: Icon(
                icon,
                color: const Color(0xFFE91E63).withOpacity(0.7),
                size: 22,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 18,
              ),
              filled: true,
              fillColor: readOnly ? Colors.grey.shade100 : Colors.white,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 16),
            ),
            style: TextStyle(
              fontSize: 16,
              color: readOnly ? Colors.grey.shade700 : Colors.black87,
            ),
            keyboardType: keyboardType,
            validator: validator,
            readOnly: readOnly,
            onTap: onTap,
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE91E63).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSave,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFFE91E63),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child:
            _isLoading
                ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: Color(0xFFE91E63),
                    strokeWidth: 2.5,
                  ),
                )
                : const Text(
                  'Save Changes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFE91E63),
                  ),
                ),
      ),
    );
  }

  void _handleSave() async {
    if (!mounted) return;

    if (_formKey.currentState!.validate() && _userModel != null) {
      // Store local reference to avoid lifecycle issues
      final currentUserModel = _userModel;
      if (currentUserModel == null) return;

      // Show loading state
      setState(() {
        _isLoading = true;
      });

      try {
        // Calculate age from birthday
        final age =
            _selectedDate != null
                ? _calculateAge(_selectedDate!)
                : currentUserModel.age;

        // Create updated user model
        final updatedUser = UserModel(
          uid: currentUserModel.uid,
          name: _nameController.text.trim(),
          age: age,
          birthday: _selectedDate, // Store the selected date as birthday
          height: currentUserModel.height,
          weight: currentUserModel.weight,
          bmi: currentUserModel.bmi,
          isRegularPeriod: currentUserModel.isRegularPeriod,
          crampsExperience: currentUserModel.crampsExperience,
          symptomDuration: currentUserModel.symptomDuration,
          additionalSymptoms: currentUserModel.additionalSymptoms,
          cycleLength: currentUserModel.cycleLength,
          periodLength: currentUserModel.periodLength,
          lastPeriodDate: currentUserModel.lastPeriodDate,
        );

        // Save to Firestore
        await _firestoreService.saveUserProfile(updatedUser);

        // Simulate API call with slight delay to match UI expectations
        await Future.delayed(const Duration(milliseconds: 300));

        // Check if widget is still mounted before updating state
        if (!mounted) return;

        setState(() {
          _isLoading = false;
          _userModel = updatedUser;
        });

        // Show success message before navigation
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.white),
                const SizedBox(width: 10),
                const Text(
                  'Personal information updated successfully',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(10),
            duration: const Duration(seconds: 2),
          ),
        );

        // Use a delayed navigation to allow the snackbar to be seen
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.pop(context);
          }
        });
      } catch (e) {
        // Check if widget is still mounted before updating state
        if (!mounted) return;

        setState(() {
          _isLoading = false;
        });

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
