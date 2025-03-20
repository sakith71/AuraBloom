import 'package:flutter/material.dart';
import '../widgets/custom-text-field.dart';
import '../utils/validators.dart';
import '../widgets/personal-info-illustration.dart';
import '../widgets/navigation-buttons.dart';
import '../services/auth-service.dart';
import 'menstrual-symptoms-screen.dart';

class PersonalInfoScreen extends StatefulWidget {
  final String userId; // Pass the user ID from the previous screen

  const PersonalInfoScreen({super.key, required this.userId});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  double? _bmi;
  bool _showErrorMessage = false; // Flag to control error visibility

  bool get _isFormValid => _formKey.currentState?.validate() ?? false;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  // Calculate BMI
  double _calculateBMI(double heightInCm, double weightInKg) {
    // BMI formula: weight (kg) / (height (m))²
    double heightInMeters = heightInCm / 100;
    return weightInKg / (heightInMeters * heightInMeters);
  }

  // Save personal info and proceed
  Future<void> _savePersonalInfoAndProceed() async {
    // Force validate and show error message if invalid
    if (!_formKey.currentState!.validate()) {
      setState(() {
        _showErrorMessage = true;
      });
      return;
    }

    try {
      setState(() {
        _isLoading = true;
        _showErrorMessage = false; // Hide error when proceeding
      });

      // Calculate BMI before saving
      double height = double.parse(_heightController.text);
      double weight = double.parse(_weightController.text);
      _bmi = _calculateBMI(height, weight);

      // Save the personal info with BMI to Firestore
      await _authService.createUserProfile(
        widget.userId,
        _nameController.text,
        int.parse(_ageController.text),
        height,
        weight,
        _bmi!,
      );

      // Navigate to next screen
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => MenstrualSymptomsScreen(userId: widget.userId),
          ),
        );
      }
    } catch (e) {
      // Show error snackbar
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving data: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handlePrevious() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFCF0F7),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      onChanged: () => setState(() {
                        // Hide error message when form is valid
                        if (_showErrorMessage && _isFormValid) {
                          _showErrorMessage = false;
                        }
                      }),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const PersonalInfoIllustration(),
                          const SizedBox(height: 20),
                          const Text(
                            'Personal Information',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 30),
                          // Name TextField with box shadow
                          Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: CustomTextField(
                              controller: _nameController,
                              hintText: 'Enter your Name',
                              validator: Validators.validateUsername,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Age TextField with box shadow
                          Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: CustomTextField(
                              controller: _ageController,
                              hintText: 'Enter Age',
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your age';
                                }
                                final age = int.tryParse(value);
                                if (age == null || age < 8 || age > 100) {
                                  return 'Please enter a valid age';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Height TextField with box shadow
                          Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: CustomTextField(
                              controller: _heightController,
                              hintText: 'Enter Height (cm)',
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your height';
                                }
                                final height = double.tryParse(value);
                                if (height == null ||
                                    height < 50 ||
                                    height > 250) {
                                  return 'Please enter a valid height';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Weight TextField with box shadow
                          Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: CustomTextField(
                              controller: _weightController,
                              hintText: 'Enter Weight (kg)',
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your weight';
                                }
                                final weight = double.tryParse(value);
                                if (weight == null ||
                                    weight < 20 ||
                                    weight > 300) {
                                  return 'Please enter a valid weight';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : NavigationButtonRow(
                      onPrevious: _handlePrevious,
                      onNext: _savePersonalInfoAndProceed,
                      isNextEnabled: true,
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}