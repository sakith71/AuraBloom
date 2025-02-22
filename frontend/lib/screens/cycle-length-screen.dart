import 'package:flutter/material.dart';
import '../widgets/navigation-buttons.dart';
import 'period-logging-screen.dart';

class CycleLengthScreen extends StatefulWidget {
  const CycleLengthScreen({super.key});

  @override
  State<CycleLengthScreen> createState() => _CycleLengthScreenState();
}

class _CycleLengthScreenState extends State<CycleLengthScreen> {
  int selectedLength = 28; // Default selected value
  final List<int> cycleLengths = List.generate(
    21,
    (index) => index + 20,
  ); // 20 to 40 days

  void _handleNext() {
    if (selectedLength != null) {
      // Ensure a cycle length is selected
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PeriodLoggingScreen()),
      );
    }
  }

  void _handlePrevious() {
    Navigator.pop(context); // Go back to Additional Symptoms Screen
  }

  void _handleIDontKnow() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => const PeriodLoggingScreen(), // Skip cycle selection
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Apply the gradient background
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
                                    fontSize:
                                        isSelected
                                            ? 28
                                            : 22, // Larger font for selected item
                                    fontWeight:
                                        isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                    color:
                                        isSelected
                                            ? Colors.black
                                            : Colors.black.withOpacity(0.5),
                                  ),
                                  child: Center(
                                    // Ensures proper alignment in the box
                                    child: Text(length.toString()),
                                  ),
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
                  onPressed: _handleIDontKnow,
                  child: const Text(
                    "I don't remember",
                    style: TextStyle(color: Colors.black54, fontSize: 18),
                  ),
                ),
                const SizedBox(height: 20),

                const SizedBox(height: 20),
                NavigationButtonRow(
                  onPrevious: _handlePrevious,
                  onNext: _handleNext,
                  isNextEnabled:
                      // ignore: unnecessary_null_comparison
                      selectedLength !=null, // Enable "Next" only if a selection is made
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
