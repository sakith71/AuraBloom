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

  bool get _isFormValid => _formKey.currentState?.validate() ?? false;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  // Save personal info and proceed
  Future<void> _savePersonalInfoAndProceed() async {
    if (!_formKey.currentState!.validate()) return;
    
    try {
      setState(() {
        _isLoading = true;
      });
      
      // Save the personal info to Firestore
      await _authService.createUserProfile(
        widget.userId,
        _nameController.text,
        int.parse(_ageController.text),
        double.parse(_heightController.text),
        double.parse(_weightController.text),
      );
      
      // Navigate to next screen
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MenstrualSymptomsScreen(userId: widget.userId),
          ),
        );
      }
    } catch (e) {
      // Show error snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving data: $e')),
        );
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
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF4C2CA), // Light Pink
              Color(0xFFD4C0D6), // Light Purple
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Expanded(
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      onChanged: () => setState(() {}),
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
                          CustomTextField(
                            controller: _nameController,
                            hintText: 'Enter your Name',
                            validator: Validators.validateUsername,
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
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
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _heightController,
                            hintText: 'Enter Height (cm)',
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your height';
                              }
                              final height = double.tryParse(value);
                              if (height == null || height < 50 || height > 250) {
                                return 'Please enter a valid height';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _weightController,
                            hintText: 'Enter Weight (kg)',
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your weight';
                              }
                              final weight = double.tryParse(value);
                              if (weight == null || weight < 20 || weight > 300) {
                                return 'Please enter a valid weight';
                              }
                              return null;
                            },
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
                        isNextEnabled: _isFormValid,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}