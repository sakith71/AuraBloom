// lib/utils/calendar_utils.dart
class CalendarUtils {
  static const List<String> months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  static List<List<String>> getWeeksForMonth(int year, int month) {
    List<List<String>> weeks = [];
    DateTime firstDay = DateTime(year, month, 1);
    int daysInMonth = DateTime(year, month + 1, 0).day;
    
    int startWeekday = firstDay.weekday - 1;
    List<String> currentWeek = List.filled(7, '');
    int dayCounter = 1;
    
    for (int i = 0; i < startWeekday; i++) {
      currentWeek[i] = '';
    }
    
    for (int i = startWeekday; dayCounter <= daysInMonth; i++) {
      if (i == 7) {
        weeks.add(List.from(currentWeek));
        currentWeek = List.filled(7, '');
        i = 0;
      }
      currentWeek[i] = dayCounter.toString().padLeft(2, '0');
      dayCounter++;
    }
    
    if (currentWeek.any((day) => day.isNotEmpty)) {
      weeks.add(currentWeek);
    }
    
    return weeks;
  }
}