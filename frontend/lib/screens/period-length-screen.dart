import 'package:flutter/material.dart';
import '../widgets/navigation-buttons.dart';
import '../services/firestore_service.dart';
import 'period-logging-screen.dart';

class PeriodLengthScreen extends StatefulWidget {
  final String userId;
  
  const PeriodLengthScreen({super.key, required this.userId});

  @override
  State<PeriodLengthScreen> createState() => _PeriodLengthScreenState();
}

class _PeriodLengthScreenState extends State<PeriodLengthScreen> {
  int? selectedLength; // Allow null for "I don't know"
  bool _isLoading = false;
  final FirestoreService _firestoreService = FirestoreService();
  
  final List<int> periodLengths = List.generate(15, (index) => index + 1); // 1 to 15 days

  Future<void> _savePeriodLengthAndProceed() async {
    if (selectedLength == null) return;
    
    try {
      setState(() {
        _isLoading = true;
      });
      
      // Update user document with period length
      await _firestoreService.users.doc(widget.userId).update({
        'periodLength': selectedLength,
      });
      
      // Navigate to next screen
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PeriodLoggingScreen(userId: widget.userId),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving period length: $e')),
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
    Navigator.pop(context); // Navigate back to Cycle Length Screen
  }

  Future<void> _handleIDontKnow() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      // Save default period length (5 days) if user doesn't know
      await _firestoreService.users.doc(widget.userId).update({
        'periodLength': 5, // Default value
      });
      
      // Navigate to next screen
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PeriodLoggingScreen(userId: widget.userId),
          ),
        );
      }
    } catch (e) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Apply the gradient background
        decoration: const BoxDecoration(
          color: Color(0xFFFCF0F7),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const SizedBox(height: 40),
                const Text(
                  'Enter the average length of\nyour periods',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: SizedBox(
                      height: 150, // Fixed height to show 3 items
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          ListWheelScrollView.useDelegate(
                            itemExtent: 60,
                            diameterRatio: 2.0,
                            useMagnifier: true,
                            magnification: 1.4,
                            overAndUnderCenterOpacity: 0.5,
                            physics: const FixedExtentScrollPhysics(),
                            onSelectedItemChanged: (index) {
                              setState(() {
                                selectedLength = periodLengths[index];
                              });
                            },
                            childDelegate: ListWheelChildBuilderDelegate(
                              builder: (context, index) {
                                if (index < 0 || index >= periodLengths.length) {
                                  return null;
                                }
                                final length = periodLengths[index];
                                final isSelected = length == selectedLength;
                                return AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 200),
                                  style: TextStyle(
                                    fontSize: isSelected ? 28 : 22, // Larger font for selected item
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected 
                                        ? Colors.black 
                                        : Colors.black.withOpacity(0.5),
                                  ),
                                  child: Center( // Ensures proper alignment in the box
                                    child: Text(length.toString()),
                                  ),
                                );
                              },
                              childCount: periodLengths.length,
                            ),
                          ),
                          Positioned.fill(
                            child: IgnorePointer(
                              child: Center(
                                child: Container(
                                  height: 60,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // "I Don't Know" Button - Navigates Directly
                TextButton(
                  onPressed: _isLoading ? null : _handleIDontKnow,
                  child: const Text(
                    "I don't remember",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Navigation Buttons (Previous & Next)
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : NavigationButtonRow(
                        onPrevious: _handlePrevious,
                        onNext: _savePeriodLengthAndProceed,
                        isNextEnabled: selectedLength != null, // Enable "Next" only if a selection is made
                      ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}