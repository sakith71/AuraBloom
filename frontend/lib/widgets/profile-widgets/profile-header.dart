import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/models/user-model.dart';
import 'package:frontend/services/auth-service.dart';
import 'package:frontend/services/firestore_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

class ProfileHeader extends StatefulWidget {
  const ProfileHeader({super.key});

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  final ImagePicker _imagePicker = ImagePicker();
  UserModel? _userModel;
  bool _isLoading = true;
  bool _isProfileVisible = true;
  String? _localImagePath;

  @override
  void initState() {
    super.initState();
    _loadProfileVisibility();
    _loadUserData();
    _loadLocalImagePath();
  }

  Future<void> _loadProfileVisibility() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    setState(() {
      _isProfileVisible = prefs.getBool('profileVisible') ?? true;
    });
  }

  Future<void> _loadLocalImagePath() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    setState(() {
      _localImagePath = prefs.getString('profileImagePath');
    });
  }

  Future<void> _saveLocalImagePath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profileImagePath', path);
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        if (!mounted) return;

        // Save the path to SharedPreferences
        await _saveLocalImagePath(pickedFile.path);

        setState(() {
          _localImagePath = pickedFile.path;
        });

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile picture updated'),
              backgroundColor: Color(0xFFE91E63),
            ),
          );
        }
      }
    } catch (e) {
      print('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadUserData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (_authService.currentUserId != null) {
        final userData = await _firestoreService.getUserProfile(
          _authService.currentUserId!,
        );
        if (!mounted) return;

        setState(() {
          _userModel = userData;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // If profile is not visible, return an empty container
    if (!_isProfileVisible) {
      return const SizedBox.shrink(); // Returns an empty widget that takes no space
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Row(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            shape: BoxShape.circle,
                            image:
                                _localImagePath != null
                                    ? DecorationImage(
                                      image: FileImage(File(_localImagePath!)),
                                      fit: BoxFit.cover,
                                    )
                                    : null,
                          ),
                          child:
                              _localImagePath == null
                                  ? Center(
                                    child: Text(
                                      _getInitials(),
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade700,
                                      ),
                                    ),
                                  )
                                  : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE91E63),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _userModel?.name ?? 'User',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          _authService.currentUser?.email ?? 'No email',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                        // Premium Member section removed
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      if (mounted) {
                        _showEditProfileDialog(context);
                      }
                    },
                    color: const Color.fromARGB(255, 240, 99, 153),
                  ),
                ],
              ),
    );
  }

  String _getInitials() {
    if (_userModel == null || _userModel!.name.isEmpty) return 'U';
    final nameParts = _userModel!.name.split(' ');
    if (nameParts.length > 1) {
      return '${nameParts[0][0]}${nameParts[1][0]}';
    }
    return nameParts[0][0];
  }

  void _showEditProfileDialog(BuildContext context) {
    // Store a local reference to the current user model to avoid issues
    // if _userModel changes during dialog display
    final currentUserModel = _userModel;

    final nameController = TextEditingController(
      text: currentUserModel?.name ?? '',
    );
    final emailController = TextEditingController(
      text: _authService.currentUser?.email ?? '',
    );

    // Using separate variable to track dialog state
    bool isUpdating = false;

    // Get the screen size to make the dialog responsive
    final screenSize = MediaQuery.of(context).size;
    final dialogWidth = screenSize.width * 0.85;

    showDialog(
      context: context,
      builder:
          (dialogContext) => StatefulBuilder(
            builder:
                (builderContext, setDialogState) => Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  child: Container(
                    width: dialogWidth,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Edit Profile',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Profile Picture section
                        GestureDetector(
                          onTap: () async {
                            await _pickImage();
                            // To see the change immediately in the dialog
                            setDialogState(() {});
                          },
                          child: Column(
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  shape: BoxShape.circle,
                                  image:
                                      _localImagePath != null
                                          ? DecorationImage(
                                            image: FileImage(
                                              File(_localImagePath!),
                                            ),
                                            fit: BoxFit.cover,
                                          )
                                          : null,
                                ),
                                child:
                                    _localImagePath == null
                                        ? Center(
                                          child: Text(
                                            _getInitials(),
                                            style: TextStyle(
                                              fontSize: 36,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue.shade700,
                                            ),
                                          ),
                                        )
                                        : null,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Change Photo',
                                style: TextStyle(
                                  color: const Color(0xFFE91E63),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Name field
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Name',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF666666),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: nameController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                    width: 1,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.pink.shade200,
                                    width: 1.5,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Email field
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Email',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF666666),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: emailController,
                              enabled:
                                  false, // Email changes require authentication, so disable it here
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                    width: 1,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.pink.shade200,
                                    width: 1.5,
                                  ),
                                ),
                                filled: true,
                                fillColor:
                                    Colors
                                        .grey
                                        .shade200, // Darker background to indicate disabled
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                              ),
                              keyboardType: TextInputType.emailAddress,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Buttons
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed:
                                    isUpdating
                                        ? null
                                        : () => Navigator.pop(dialogContext),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    side: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                ),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(
                                    color: Color(0xFF666666),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed:
                                    isUpdating
                                        ? null
                                        : () async {
                                          if (nameController.text
                                              .trim()
                                              .isEmpty) {
                                            ScaffoldMessenger.of(
                                              dialogContext,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Name cannot be empty',
                                                ),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                            return;
                                          }

                                          // Update dialog state
                                          setDialogState(() {
                                            isUpdating = true;
                                          });

                                          try {
                                            if (currentUserModel != null &&
                                                _authService.currentUserId !=
                                                    null) {
                                              // Create updated user model
                                              final updatedUser = UserModel(
                                                uid: currentUserModel.uid,
                                                name:
                                                    nameController.text.trim(),
                                                age: currentUserModel.age,
                                                height: currentUserModel.height,
                                                weight: currentUserModel.weight,
                                                bmi: currentUserModel.bmi,
                                                isRegularPeriod:
                                                    currentUserModel
                                                        .isRegularPeriod,
                                                crampsExperience:
                                                    currentUserModel
                                                        .crampsExperience,
                                                symptomDuration:
                                                    currentUserModel
                                                        .symptomDuration,
                                                additionalSymptoms:
                                                    currentUserModel
                                                        .additionalSymptoms,
                                                cycleLength:
                                                    currentUserModel
                                                        .cycleLength,
                                                periodLength:
                                                    currentUserModel
                                                        .periodLength,
                                                lastPeriodDate:
                                                    currentUserModel
                                                        .lastPeriodDate,
                                              );

                                              // Save to Firestore
                                              await _firestoreService
                                                  .saveUserProfile(updatedUser);

                                              // Close dialog first
                                              Navigator.pop(dialogContext);

                                              // Then update state if widget is still mounted
                                              if (mounted) {
                                                setState(() {
                                                  _userModel = updatedUser;
                                                });

                                                // Show success message after dialog is closed
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Profile updated successfully',
                                                    ),
                                                    backgroundColor: Color(
                                                      0xFFE91E63,
                                                    ),
                                                  ),
                                                );
                                              }
                                            } else {
                                              // Just close the dialog if we don't have a user model
                                              Navigator.pop(dialogContext);
                                            }
                                          } catch (e) {
                                            print('Error updating profile: $e');

                                            // Only update dialog state if still in dialog
                                            setDialogState(() {
                                              isUpdating = false;
                                            });

                                            ScaffoldMessenger.of(
                                              dialogContext,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Error updating profile: $e',
                                                ),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  backgroundColor: const Color(
                                    0xFFE91E63,
                                  ), // Pink color matching AuraBloom theme
                                  elevation: 0,
                                ),
                                child:
                                    isUpdating
                                        ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                        : const Text(
                                          'Save',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
          ),
    );
  }
}
