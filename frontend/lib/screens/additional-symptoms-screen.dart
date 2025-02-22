import '../widgets/navigation-buttons.dart';
import 'package:flutter/material.dart';

class AdditionalSymptomsScreen extends StatefulWidget {
  const AdditionalSymptomsScreen({super.key});

  @override
  State<AdditionalSymptomsScreen> createState() => _AdditionalSymptomsScreenState();
}

class _AdditionalSymptomsScreenState extends State<AdditionalSymptomsScreen> {
  final List<Map<String, dynamic>> _symptoms = [
    {'name': 'Headaches', 'isSelected': false},
    {'name': 'Mood changes', 'isSelected': false},
    {'name': 'Bloating', 'isSelected': false},
    {'name': 'Back Pain', 'isSelected': false},
    {'name': 'Nausea', 'isSelected': false},
    {'name': 'Fatigue', 'isSelected': false},
    {'name': 'Diarrhea', 'isSelected': false},
  ];

  bool get hasSelectedSymptoms => _symptoms.any((symptom) => symptom['isSelected']);

  void _handleNext() {
  }

  void _handlePrevious() {
    Navigator.pop(context);
  }

  Widget _buildSymptomOption(Map<String, dynamic> symptom) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: () {
          setState(() {
            symptom['isSelected'] = !symptom['isSelected'];
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
          decoration: BoxDecoration(
            color: symptom['isSelected']
                ? const Color(0xFFE1F5FE)
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: symptom['isSelected']
                  ? Colors.blue
                  : Colors.grey.shade300,
              width: 2,
            ),
            boxShadow: symptom['isSelected']
                ? [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ]
                : [],
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  symptom['name'],
                  style: TextStyle(
                    fontSize: 16,
                    color: symptom['isSelected']
                        ? Colors.blue.shade700
                        : Colors.black87,
                    fontWeight: symptom['isSelected']
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),
              if (symptom['isSelected'])
                Icon(
                  Icons.check_circle,
                  color: Colors.blue.shade700,
                ),
            ],
          ),
        ),
      ),
    );
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
                const Text(
                  'What additional symptoms do you\nexperience during menstruation?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: ListView.builder(
                    itemCount: _symptoms.length,
                    itemBuilder: (context, index) {
                      return _buildSymptomOption(_symptoms[index]);
                    },
                  ),
                ),
                const SizedBox(height: 20),
                NavigationButtonRow(
                  onPrevious: _handlePrevious,
                  onNext: _handleNext,
                  // Since this screen doesn't require selection, we can always enable the next button
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