import 'package:flutter/material.dart';
import 'package:frontend/models/user-model.dart';
import 'package:frontend/services/auth-service.dart';
import 'package:frontend/services/firestore_service.dart';

class ProfileHealthSection extends StatefulWidget {
  const ProfileHealthSection({super.key});

  @override
  State<ProfileHealthSection> createState() => _ProfileHealthSectionState();
}

class _ProfileHealthSectionState extends State<ProfileHealthSection> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  UserModel? _userModel;
  bool _isLoading = true;
  Map<String, String> _healthInfo = {};

  @override
  void initState() {
    super.initState();
    _loadUserData();
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

        // Check if widget is still mounted after async operation
        if (!mounted) return;

        if (userData != null) {
          setState(() {
            _userModel = userData;
            _healthInfo = {
              'Age': '${userData.age} years',
              'Height': '${userData.height} cm',
              'Weight': '${userData.weight} kg',
              'Blood Type': 'A+', // Not in UserModel, so using a default
              'Cycle Length': '${userData.cycleLength} days',
              'Period Length': '${userData.periodLength} days',
            };
            _isLoading = false;
          });
        }
      } else {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');

      // Check if widget is still mounted before updating state
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _healthInfo = {
          'Age': '25 years',
          'Height': '165 cm',
          'Weight': '58 kg',
          'Blood Type': 'A+',
          'Cycle Length': '28 days',
          'Period Length': '5 days',
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
              : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Health Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          if (mounted) {
                            _showEditDialog(context);
                          }
                        },
                        color: Colors.pink,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ..._healthInfo.entries.map(
                    (entry) => _buildHealthItem(entry.key, entry.value),
                  ),
                ],
              ),
    );
  }

  Widget _buildHealthItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    // Store local references to avoid lifecycle issues
    final localHealthInfo = Map<String, String>.from(_healthInfo);
    final localUserModel = _userModel;

    showDialog(
      context: context,
      builder:
          (dialogContext) => EditHealthInfoScreen(
            initialHealthInfo: localHealthInfo,
            userModel: localUserModel,
            onSave: (updatedInfo, updatedUserModel) async {
              // Close dialog first to avoid lifecycle issues
              Navigator.pop(dialogContext);

              try {
                // Save to Firestore
                if (updatedUserModel != null) {
                  await _firestoreService.saveUserProfile(updatedUserModel);

                  // Check if widget is still mounted before updating state
                  if (!mounted) return;

                  setState(() {
                    _healthInfo.clear();
                    _healthInfo.addAll(updatedInfo);
                    _userModel = updatedUserModel;
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Health information updated'),
                      backgroundColor: Colors.pink,
                    ),
                  );
                }
              } catch (e) {
                print('Error updating health info: $e');

                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error updating health information: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
    );
  }
}

class EditHealthInfoScreen extends StatefulWidget {
  final Map<String, String> initialHealthInfo;
  final UserModel? userModel;
  final Function(Map<String, String>, UserModel?) onSave;

  const EditHealthInfoScreen({
    Key? key,
    required this.initialHealthInfo,
    this.userModel,
    required this.onSave,
  }) : super(key: key);

  @override
  State<EditHealthInfoScreen> createState() => _EditHealthInfoScreenState();
}

class _EditHealthInfoScreenState extends State<EditHealthInfoScreen> {
  late final Map<String, TextEditingController> _controllers;
  final _formKey = GlobalKey<FormState>();
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _controllers = widget.initialHealthInfo.map(
      (key, value) => MapEntry(key, TextEditingController(text: value)),
    );
  }

  @override
  void dispose() {
    _controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(
                  child: Text(
                    'Edit Health Information',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ..._buildFormFields(),
                const SizedBox(height: 24),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFormFields() {
    return _controllers.entries.map((entry) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
            child: Text(
              entry.key,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: TextFormField(
              controller: entry.value,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                border: InputBorder.none,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'This field is required';
                }
                return _validateHealthInfo(entry.key, value);
              },
            ),
          ),
        ],
      );
    }).toList();
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isUpdating ? null : () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(fontSize: 16, color: Colors.purple),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _isUpdating ? null : _saveChanges,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.pink,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child:
                _isUpdating
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
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
          ),
        ),
      ],
    );
  }

  void _saveChanges() async {
    if (!mounted) return;

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isUpdating = true;
      });

      try {
        // Extract updated values from controllers
        final updatedHealthInfo = _controllers.map(
          (key, controller) => MapEntry(key, controller.text),
        );

        // Extract numeric values for UserModel update
        int? age = int.tryParse(
          updatedHealthInfo['Age']?.replaceAll(RegExp(r'[^0-9]'), '') ?? '',
        );
        double? height = double.tryParse(
          updatedHealthInfo['Height']?.replaceAll(RegExp(r'[^0-9.]'), '') ?? '',
        );
        double? weight = double.tryParse(
          updatedHealthInfo['Weight']?.replaceAll(RegExp(r'[^0-9.]'), '') ?? '',
        );
        int? cycleLength = int.tryParse(
          updatedHealthInfo['Cycle Length']?.replaceAll(
                RegExp(r'[^0-9]'),
                '',
              ) ??
              '',
        );
        int? periodLength = int.tryParse(
          updatedHealthInfo['Period Length']?.replaceAll(
                RegExp(r'[^0-9]'),
                '',
              ) ??
              '',
        );

        // Create updated user model if original exists
        UserModel? updatedUserModel;
        if (widget.userModel != null) {
          updatedUserModel = UserModel(
            uid: widget.userModel!.uid,
            name: widget.userModel!.name,
            age: age ?? widget.userModel!.age,
            height: height ?? widget.userModel!.height,
            weight: weight ?? widget.userModel!.weight,
            isRegularPeriod: widget.userModel!.isRegularPeriod,
            crampsExperience: widget.userModel!.crampsExperience,
            symptomDuration: widget.userModel!.symptomDuration,
            additionalSymptoms: widget.userModel!.additionalSymptoms,
            cycleLength: cycleLength ?? widget.userModel!.cycleLength,
            periodLength: periodLength ?? widget.userModel!.periodLength,
            lastPeriodDate: widget.userModel!.lastPeriodDate,
          );
        }

        // Invoke callback with updated data
        widget.onSave(updatedHealthInfo, updatedUserModel);
      } catch (e) {
        print('Error processing health info: $e');

        if (!mounted) return;

        setState(() {
          _isUpdating = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error processing health information: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String? _validateHealthInfo(String key, String value) {
    switch (key) {
      case 'Age':
        final age = int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), ''));
        if (age == null || age < 8 || age > 100) {
          return 'Please enter a valid age between 8 and 100';
        }
        break;

      case 'Height':
        final height = double.tryParse(
          value.replaceAll(RegExp(r'[^0-9.]'), ''),
        );
        if (height == null || height < 50 || height > 250) {
          return 'Please enter a valid height between 50 and 250 cm';
        }
        break;

      case 'Weight':
        final weight = double.tryParse(
          value.replaceAll(RegExp(r'[^0-9.]'), ''),
        );
        if (weight == null || weight < 20 || weight > 300) {
          return 'Please enter a valid weight between 20 and 300 kg';
        }
        break;

      case 'Blood Type':
        final validBloodTypes = [
          'A+',
          'A-',
          'B+',
          'B-',
          'O+',
          'O-',
          'AB+',
          'AB-',
        ];
        if (!validBloodTypes.contains(value.toUpperCase())) {
          return 'Please enter a valid blood type (A+, A-, B+, B-, O+, O-, AB+, AB-)';
        }
        break;

      case 'Cycle Length':
        final days = int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), ''));
        if (days == null || days < 21 || days > 45) {
          return 'Please enter a valid cycle length between 21 and 45 days';
        }
        break;

      case 'Period Length':
        final days = int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), ''));
        if (days == null || days < 2 || days > 10) {
          return 'Please enter a valid period length between 2 and 10 days';
        }
        break;
    }
    return null;
  }
}
