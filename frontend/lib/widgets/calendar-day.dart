import 'package:flutter/material.dart';

class CalendarDay extends StatelessWidget {
  final String day;
  final bool isSelected;
  final bool isEnabled;
  final bool isPastOrToday;
  final bool isToday;
  final Function()? onTap;

  const CalendarDay({
    super.key,
    required this.day,
    required this.isSelected,
    required this.isEnabled,
    required this.isPastOrToday,
    required this.isToday,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected 
              ? const Color(0xFFE1F5FE) 
              : isToday 
                  ? Colors.red.withOpacity(0.1)
                  : Colors.transparent,
          border: isSelected
              ? Border.all(color: Colors.blue, width: 2)
              : isToday
                  ? Border.all(color: Colors.red, width: 1)
                  : null,
        ),
        child: Text(
          day,
          style: TextStyle(
            color: !isEnabled || !isPastOrToday
                ? Colors.grey.shade300
                : isSelected
                    ? Colors.blue
                    : isToday
                        ? Colors.red
                        : Colors.black87,
            fontWeight: isSelected || isToday 
                ? FontWeight.bold 
                : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}