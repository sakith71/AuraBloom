import 'package:flutter/material.dart';
import 'package:frontend/models/user-model.dart';
import 'package:frontend/services/auth-service.dart';
import 'package:frontend/services/firestore_service.dart';
import 'package:intl/intl.dart'; // For date formatting

class PersonalInfoPage extends StatefulWidget {
  const PersonalInfoPage({super.key});

  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
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
        if (userData != null) {
          setState(() {
            _userModel = userData;
            _nameController.text = userData.name;

            // Phone number is not in the UserModel, so we'll use a default
            _phoneController.text = '+1 234 567 8900';

            // Convert age to birthday (approximate)
            final now = DateTime.now();
            _selectedDate = DateTime(
              now.year - userData.age,
              now.month,
              now.day,
            );
            _birthdayController.text = _formatDate(_selectedDate!);
          });
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading user data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isInitializing = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
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
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFE8D5E4), // Light lavender
                      Color(0xFFF8C4D9), // Light pink
                    ],
                  ),
                ),
                child: const Center(child: CircularProgressIndicator()),
              )
              : Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFE8D5E4), // Light lavender
                      Color(0xFFF8C4D9), // Light pink
                    ],
                  ),
                ),
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
                        readOnly:
                            true, // Email changes require authentication, so make it read-only
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
                        controller: _phoneController,
                        label: 'Phone Number',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your phone number';
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
                                    primary: Color(
                                      0xFFE91E63,
                                    ), // Pink color for selected date
                                    onPrimary:
                                        Colors
                                            .white, // White text for selected date
                                    onSurface:
                                        Colors.black, // Black text for calendar
                                  ),
                                  textButtonTheme: TextButtonThemeData(
                                    style: TextButton.styleFrom(
                                      foregroundColor: const Color(
                                        0xFFE91E63,
                                      ), // Pink text for buttons
                                    ),
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (date != null) {
                            setState(() {
                              _selectedDate = date;
                              _birthdayController.text = _formatDate(date);
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

                      const SizedBox(height: 40),

                      // Save button
                      _buildSaveButton(),
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
    if (_formKey.currentState!.validate() && _userModel != null) {
      // Show loading state
      setState(() {
        _isLoading = true;
      });

      try {
        // Calculate age from birthday
        final age =
            _selectedDate != null
                ? _calculateAge(_selectedDate!)
                : _userModel!.age;

        // Create updated user model
        final updatedUser = UserModel(
          uid: _userModel!.uid,
          name: _nameController.text.trim(),
          age: age,
          height: _userModel!.height,
          weight: _userModel!.weight,
          isRegularPeriod: _userModel!.isRegularPeriod,
          crampsExperience: _userModel!.crampsExperience,
          symptomDuration: _userModel!.symptomDuration,
          additionalSymptoms: _userModel!.additionalSymptoms,
          cycleLength: _userModel!.cycleLength,
          periodLength: _userModel!.periodLength,
          lastPeriodDate: _userModel!.lastPeriodDate,
        );

        // Save to Firestore
        await _firestoreService.saveUserProfile(updatedUser);

        // Simulate API call with slight delay to match UI expectations
        await Future.delayed(const Duration(milliseconds: 300));

        setState(() {
          _isLoading = false;
        });

        // Show success message
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

        // Navigate back
        Navigator.pop(context);
      } catch (e) {
        print('Error updating profile: $e');
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
