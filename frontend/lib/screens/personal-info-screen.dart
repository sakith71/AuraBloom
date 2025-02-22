import 'package:flutter/material.dart';
import '../widgets/custom-text-field.dart';
import '../utils/validators.dart';
import '../widgets/personal-info-illustration.dart';
import '../widgets/navigation-buttons.dart';
import 'menstrual-symptoms-screen.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  bool get _isFormValid => _formKey.currentState?.validate() ?? false;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _handleNext() {
    if (_formKey.currentState!.validate()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const MenstrualSymptomsScreen(),
        ),
      );
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
                NavigationButtonRow(
                  onPrevious: _handlePrevious,
                  onNext: _handleNext,
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