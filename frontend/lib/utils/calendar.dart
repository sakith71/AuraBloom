class CalendarUtils {
  static const List<String> months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  static const Map<String, String> monthNumbers = {
    'January': '01', 'February': '02', 'March': '03', 'April': '04',
    'May': '05', 'June': '06', 'July': '07', 'August': '08',
    'September': '09', 'October': '10', 'November': '11', 'December': '12'
  };

  // Calendar generation methods
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

  // Date formatting methods
  static String getMonthNumber(String month) {
    return monthNumbers[month] ?? '01';
  }

  static String formatDateForDisplay(DateTime date) {
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  // Parse date methods
  static DateTime? parseDisplayDate(String displayDate) {
    try {
      final parts = displayDate.split(' ');
      if (parts.length >= 3) {
        final month = parts[0];
        final day = parts[1].replaceAll(',', '');
        final year = parts[2];
        
        final monthNumber = getMonthNumber(month);
        return DateTime.parse('$year-$monthNumber-$day');
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  static String formatToStandardDate(String monthName, String day, String year) {
    final monthNumber = getMonthNumber(monthName);
    return '$year-$monthNumber-${day.padLeft(2, '0')}';
  }

  // Calculate cycle dates
  static DateTime calculateNextPeriod(DateTime lastPeriod, {int cycleLength = 28}) {
    return lastPeriod.add(Duration(days: cycleLength));
  }

  static int calculateDaysUntil(DateTime targetDate) {
    final now = DateTime.now();
    return targetDate.difference(now).inDays;
  }
}