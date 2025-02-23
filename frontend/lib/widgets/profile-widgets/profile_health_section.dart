// lib/screens/profile/widgets/profile_health_section.dart
import 'package:flutter/material.dart';

class ProfileHealthSection extends StatefulWidget {
  const ProfileHealthSection({super.key});

  @override
  State<ProfileHealthSection> createState() => _ProfileHealthSectionState();
}

class _ProfileHealthSectionState extends State<ProfileHealthSection> {
  final Map<String, String> _healthInfo = {
    'Age': '25 years',
    'Height': '165 cm',
    'Weight': '58 kg',
    'Blood Type': 'A+',
    'Cycle Length': '28 days',
    'Period Length': '5 days',
  };

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
      child: Column(
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
                onPressed: () => _showEditDialog(context),
                color: Colors.blue,
              ),
            ],
          ),
          const SizedBox(height: 20),
          ..._healthInfo.entries.map((entry) => _buildHealthItem(entry.key, entry.value)),
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
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final controllers = _healthInfo.map(
      (key, value) => MapEntry(key, TextEditingController(text: value)),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Health Information'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: controllers.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TextFormField(
                    controller: entry.value,
                    decoration: InputDecoration(
                      labelText: entry.key,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'This field is required';
                      }
                      return _validateHealthInfo(entry.key, value);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                setState(() {
                  controllers.forEach((key, controller) {
                    _healthInfo[key] = controller.text;
                  });
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Health information updated')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
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
        final height = double.tryParse(value.replaceAll(RegExp(r'[^0-9.]'), ''));
        if (height == null || height < 50 || height > 250) {
          return 'Please enter a valid height between 50 and 250 cm';
        }
        break;
      
      case 'Weight':
        final weight = double.tryParse(value.replaceAll(RegExp(r'[^0-9.]'), ''));
        if (weight == null || weight < 20 || weight > 300) {
          return 'Please enter a valid weight between 20 and 300 kg';
        }
        break;
      
      case 'Blood Type':
        final validBloodTypes = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];
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