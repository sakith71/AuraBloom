import 'package:flutter/material.dart';

class NavigationButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isNext;
  final bool isEnabled;

  const NavigationButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isNext = false,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: isEnabled ? onPressed : null,
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: isNext ? 40 : 30,
          vertical: 15,
        ),
        backgroundColor: _getBackgroundColor(),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      ),
      child: Text(text, style: TextStyle(color: _getTextColor(), fontSize: 16)),
    );
  }

  Color _getBackgroundColor() {
    if (!isEnabled) return Colors.grey.shade300;
    return isNext ? const Color.fromARGB(255, 240, 99, 153) : Colors.white;
  }

  Color _getTextColor() {
    if (!isEnabled) return Colors.grey.shade700;
    return isNext ? Colors.white : Colors.black87;
  }
}

class NavigationButtonRow extends StatelessWidget {
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final bool isNextEnabled;

  const NavigationButtonRow({
    super.key,
    required this.onPrevious,
    required this.onNext,
    this.isNextEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        NavigationButton(text: 'Previous', onPressed: onPrevious),
        NavigationButton(
          text: 'Next',
          onPressed: onNext,
          isNext: true,
          isEnabled: isNextEnabled,
        ),
      ],
    );
  }
}
