class CalendarUtils {
  static const List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static const Map<String, String> monthNumbers = {
    'January': '01', 'February': '02', 'March': '03', 'April': '04',
    'May': '05', 'June': '06', 'July': '07', 'August': '08',
    'September': '09', 'October': '10', 'November': '11', 'December': '12',
    // Short forms for better compatibility
    'Jan': '01', 'Feb': '02', 'Mar': '03', 'Apr': '04',
    'Ma': '05', 'Jun': '06', 'Jul': '07', 'Aug': '08',
    'Sep': '09', 'Oct': '10', 'Nov': '11', 'Dec': '12',
  };

  // Calendar generation methods
  static List<List<String>> getWeeksForMonth(int year, int month) {
    List<List<String>> weeks = [];
    DateTime firstDay = DateTime(year, month, 1);
    int daysInMonth = DateTime(year, month + 1, 0).day;

    int startWeekday =
        firstDay.weekday % 7; // Adjust for Sunday as first day (0)
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
        return DateTime.parse('$year-$monthNumber-${day.padLeft(2, '0')}');
      }
    } catch (e) {
      print('Error parsing display date: $e');
      return null;
    }
    return null;
  }

  static String formatToStandardDate(
    String monthName,
    String day,
    String year,
  ) {
    final monthNumber = getMonthNumber(monthName);
    return '$year-$monthNumber-${day.padLeft(2, '0')}';
  }

  // Calculate cycle dates
  static DateTime calculateNextPeriod(
    DateTime lastPeriod, {
    int cycleLength = 28,
  }) {
    return lastPeriod.add(Duration(days: cycleLength));
  }

  static int calculateDaysUntil(DateTime targetDate) {
    final now = DateTime.now();
    final nowWithoutTime = DateTime(now.year, now.month, now.day);
    final targetWithoutTime = DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
    );
    return targetWithoutTime.difference(nowWithoutTime).inDays;
  }

  // Get today's formatted date
  static String getTodayFormatted() {
    final now = DateTime.now();
    final day = now.day;
    final month = _getMonthAbbreviation(now.month);
    final weekday = _getWeekdayAbbreviation(now.weekday);

    return '$day $month, $weekday';
  }

  // Get month abbreviation
  static String _getMonthAbbreviation(int month) {
    const monthAbbreviations = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return monthAbbreviations[month - 1];
  }

  // Get weekday abbreviation
  static String _getWeekdayAbbreviation(int weekday) {
    const days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    return days[(weekday - 1) % 7];
  }

  // Format a date to a standard string format (YYYY-MM-DD)
  static String formatToYYYYMMDD(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  // Parse a date from a standard string format (YYYY-MM-DD)
  static DateTime? parseFromYYYYMMDD(String dateString) {
    try {
      final parts = dateString.split('-');
      if (parts.length == 3) {
        final year = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final day = int.parse(parts[2]);
        return DateTime(year, month, day);
      }
      return null;
    } catch (e) {
      print('Error parsing date: $e');
      return null;
    }
  }

  // Convert month-day-year format (January-01-2023) to YYYY-MM-DD format
  static String convertMonthDayYearToISO(String dateKey) {
    final parts = dateKey.split('-');
    if (parts.length == 3) {
      final month = parts[0];
      final day = parts[1];
      final year = parts[2];

      final monthNumber = getMonthNumber(month);
      return '$year-$monthNumber-$day';
    }
    return dateKey; // Return original if format not matched
  }

  // Get current week dates starting from Sunday
  static List<DateTime> getCurrentWeekDates() {
    final DateTime now = DateTime.now();
    final int currentWeekday = now.weekday % 7; // 0 for Sunday

    // Get the date of the Sunday of this week
    final DateTime startOfWeek = now.subtract(Duration(days: currentWeekday));

    // Generate dates for the whole week
    return List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
  }

  // Find consecutive days in a list of date strings
  static List<List<String>> findConsecutiveDays(List<String> dates) {
    if (dates.isEmpty) return [];

    // Convert to DateTime objects and sort
    List<DateTime> dateTimes = [];
    for (String date in dates) {
      final dateTime = parseFromYYYYMMDD(date);
      if (dateTime != null) {
        dateTimes.add(dateTime);
      }
    }
    dateTimes.sort();

    // Find consecutive sequences
    List<List<String>> sequences = [];
    List<String> currentSequence = [formatToYYYYMMDD(dateTimes[0])];

    for (int i = 1; i < dateTimes.length; i++) {
      final prevDate = dateTimes[i - 1];
      final currentDate = dateTimes[i];

      if (currentDate.difference(prevDate).inDays == 1) {
        // Consecutive day, add to current sequence
        currentSequence.add(formatToYYYYMMDD(currentDate));
      } else {
        // Non-consecutive, start a new sequence
        sequences.add(List.from(currentSequence));
        currentSequence = [formatToYYYYMMDD(currentDate)];
      }
    }

    // Add the last sequence
    if (currentSequence.isNotEmpty) {
      sequences.add(currentSequence);
    }

    return sequences;
  }
}
