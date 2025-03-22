import 'package:flutter/material.dart';
import '../../widgets/navigation-buttons.dart';
import '../../services/firestore_service.dart';
import 'period-length-screen.dart';

class CycleLengthScreen extends StatefulWidget {
  final String userId;

  const CycleLengthScreen({super.key, required this.userId});

  @override
  State<CycleLengthScreen> createState() => _CycleLengthScreenState();
}

class _CycleLengthScreenState extends State<CycleLengthScreen> {
  int selectedLength = 28; // Default selected value
  bool _isLoading = false;
  final FirestoreService _firestoreService = FirestoreService();

  final List<int> cycleLengths = List.generate(
    21,
    (index) => index + 20,
  ); // 20 to 40 days

  Future<void> _saveCycleLengthAndProceed() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Update user document with cycle length
      await _firestoreService.users.doc(widget.userId).update({
        'cycleLength': selectedLength,
      });

      // Navigate to next screen
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PeriodLengthScreen(userId: widget.userId),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving cycle length: $e')),
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
    Navigator.pop(context); // Go back to Additional Symptoms Screen
  }

  Future<void> _handleIDontKnow() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Save default cycle length (28 days) if user doesn't know
      await _firestoreService.users.doc(widget.userId).update({
        'cycleLength': 28, // Default value
      });

      // Navigate to next screen
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PeriodLengthScreen(userId: widget.userId),
          ),
        );
      }
    } catch (e) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Apply the gradient background
        decoration: const BoxDecoration(color: Color(0xFFFCF0F7)),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const SizedBox(height: 40),
                const Text(
                  'Enter the average length of\nyour cycle',
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
                                selectedLength = cycleLengths[index];
                              });
                            },
                            childDelegate: ListWheelChildBuilderDelegate(
                              builder: (context, index) {
                                if (index < 0 || index >= cycleLengths.length) {
                                  return null;
                                }
                                final length = cycleLengths[index];
                                final isSelected = length == selectedLength;
                                return AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 200),
                                  style: TextStyle(
                                    fontSize: isSelected ? 28 : 22,
                                    fontWeight:
                                        isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                    color:
                                        isSelected
                                            ? Colors.black
                                            : Colors.black.withOpacity(0.5),
                                  ),
                                  child: Center(child: Text(length.toString())),
                                );
                              },
                              childCount: cycleLengths.length,
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
                TextButton(
                  onPressed: _isLoading ? null : _handleIDontKnow,
                  child: const Text(
                    "I don't remember",
                    style: TextStyle(color: Colors.black54, fontSize: 18),
                  ),
                ),
                const SizedBox(height: 20),

                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : NavigationButtonRow(
                      onPrevious: _handlePrevious,
                      onNext: _saveCycleLengthAndProceed,
                      isNextEnabled:
                          true, // Always enabled as we have a default
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
