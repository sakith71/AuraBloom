import '../widgets/navigation-buttons.dart';
import 'package:flutter/material.dart';
import 'additional-symptoms-screen.dart';

class MenstrualSymptomsScreen extends StatefulWidget {
  const MenstrualSymptomsScreen({super.key});

  @override
  State<MenstrualSymptomsScreen> createState() => _MenstrualSymptomsScreenState();
}

class _MenstrualSymptomsScreenState extends State<MenstrualSymptomsScreen> {
  int _currentPageIndex = 0;
  String? _regularityAnswer;
  String? _crampsAnswer;
  String? _daysAnswer;

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

  void _handleNext() {
    if (_currentPageIndex < _questions.length - 1) {
      setState(() {
        _currentPageIndex++;
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AdditionalSymptomsScreen(),
        ),
      );
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
                ? const Color(0xFFE1F5FE)
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? Colors.blue
                  : Colors.grey.shade300,
              width: 2,
            ),
            boxShadow: isSelected
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
                  option,
                  style: TextStyle(
                    fontSize: 16,
                    color: isSelected
                        ? Colors.blue.shade700
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
                NavigationButtonRow(
                  onPrevious: _handlePrevious,
                  onNext: _handleNext,
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