import '../widgets/navigation-buttons.dart';
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import 'additional-symptoms-screen.dart';

class MenstrualSymptomsScreen extends StatefulWidget {
  final String userId;
  
  const MenstrualSymptomsScreen({super.key, required this.userId});

  @override
  State<MenstrualSymptomsScreen> createState() => _MenstrualSymptomsScreenState();
}

class _MenstrualSymptomsScreenState extends State<MenstrualSymptomsScreen> {
  int _currentPageIndex = 0;
  String? _regularityAnswer;
  String? _crampsAnswer;
  String? _daysAnswer;
  bool _isLoading = false;
  
  final FirestoreService _firestoreService = FirestoreService();

  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'Are your periods regular?',
      'options': ['Yes', 'No', "I don't know"],
      'answer': null,
    },
    {
      'question': 'Do you experience menstrual pain (cramps) during your period?',
      'options': ['Yes, every cycle', 'Sometimes', 'Rarely', 'No'],
      'answer': null,
    },
    {
      'question': 'How many days per cycle do you experience symptoms?',
      'options': ['1-3 days', '3-5 days', '6 or more days'],
      'answer': null,
    },
  ];

  String? _getCurrentAnswer() {
    switch (_currentPageIndex) {
      case 0:
        return _regularityAnswer;
      case 1:
        return _crampsAnswer;
      case 2:
        return _daysAnswer;
      default:
        return null;
    }
  }

  void _setCurrentAnswer(String? value) {
    setState(() {
      switch (_currentPageIndex) {
        case 0:
          _regularityAnswer = value;
          break;
        case 1:
          _crampsAnswer = value;
          break;
        case 2:
          _daysAnswer = value;
          break;
      }
    });
  }

  Future<void> _saveAnswersAndProceed() async {
    if (_currentPageIndex < _questions.length - 1) {
      setState(() {
        _currentPageIndex++;
      });
      return;
    }
    
    // Save all answers to Firestore
    try {
      setState(() {
        _isLoading = true;
      });
      
      // Update user document with menstrual symptoms data
      await _firestoreService.users.doc(widget.userId).update({
        'isRegularPeriod': _regularityAnswer == 'Yes',
        'crampsExperience': _crampsAnswer ?? 'No',
        'symptomDuration': _daysAnswer ?? '1-3 days',
      });
      
      // Navigate to next screen
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdditionalSymptomsScreen(userId: widget.userId),
          ),
        );
      }
    } catch (e) {
      // Show error message
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
    if (_currentPageIndex > 0) {
      setState(() {
        _currentPageIndex--;
      });
    } else {
      Navigator.pop(context);
    }
  }

  Widget _buildOption(String option, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: () => _setCurrentAnswer(option),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
          decoration: BoxDecoration(
            color: isSelected 
                ? const Color.fromARGB(255, 240, 99, 153).withOpacity(0.001)
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? const Color.fromARGB(255, 240, 99, 153)
                  : Colors.grey.shade300,
              width: 2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color.fromARGB(255, 240, 99, 153).withOpacity(0.001),
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
                  option,
                  style: TextStyle(
                    fontSize: 16,
                    color: isSelected
                        ? const Color.fromARGB(255, 240, 99, 153)
                        : Colors.black87,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),
              if (isSelected)
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
                Text(
                  _questions[_currentPageIndex]['question'],
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: ListView.builder(
                    itemCount: _questions[_currentPageIndex]['options'].length,
                    itemBuilder: (context, index) {
                      final option = _questions[_currentPageIndex]['options'][index];
                      final isSelected = _getCurrentAnswer() == option;
                      return _buildOption(option, isSelected);
                    },
                  ),
                ),
                const SizedBox(height: 20),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : NavigationButtonRow(
                        onPrevious: _handlePrevious,
                        onNext: _saveAnswersAndProceed,
                        isNextEnabled: _getCurrentAnswer() != null,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}