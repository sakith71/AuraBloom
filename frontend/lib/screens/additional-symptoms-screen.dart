import '../widgets/navigation-buttons.dart';
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import 'cycle-length-screen.dart';

class AdditionalSymptomsScreen extends StatefulWidget {
  final String userId;
  
  const AdditionalSymptomsScreen({super.key, required this.userId});

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

  bool _isLoading = false;
  final FirestoreService _firestoreService = FirestoreService();

  bool get hasSelectedSymptoms => _symptoms.any((symptom) => symptom['isSelected']);

  Future<void> _saveSymptomsThenProceed() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      // Extract selected symptoms
      List<String> selectedSymptoms = _symptoms
          .where((symptom) => symptom['isSelected'])
          .map((symptom) => symptom['name'] as String)
          .toList();
      
      // Update user document with selected symptoms
      await _firestoreService.users.doc(widget.userId).update({
        'additionalSymptoms': selectedSymptoms,
      });
      
      // Navigate to next screen
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CycleLengthScreen(userId: widget.userId),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving symptoms: $e')),
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
                ? const Color.fromARGB(255, 240, 99, 153).withOpacity(0.001)
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: symptom['isSelected']
                  ? const Color.fromARGB(255, 240, 99, 153)
                  : Colors.grey.shade300,
              width: 2,
            ),
            boxShadow: symptom['isSelected']
                ? [
                    BoxShadow(
                      color: const Color.fromARGB(255, 240, 99, 153).withOpacity(0.1),
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
                        ? const Color.fromARGB(255, 240, 99, 153)
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
                  color: const Color.fromARGB(255, 240, 99, 153),
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
          color: Color(0xFFFCF0F7),
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
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : NavigationButtonRow(
                        onPrevious: _handlePrevious,
                        onNext: _saveSymptomsThenProceed,
                        isNextEnabled: true, // Symptoms selection is optional
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}