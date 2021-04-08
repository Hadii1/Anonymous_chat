extension DateTimeFormatting on int {
  String formatDate() {
    DateTime time = DateTime.fromMillisecondsSinceEpoch(this);
    Duration difference = time.difference(DateTime.now());
    if (difference.inDays < 1) {
      bool am = time.hour < 12;
      return '${time.hour}:${time.minute} ${am ? 'AM' : 'PM'}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays > 7) {
      switch (time.weekday) {
        case 1:
          return 'Mon';
        case 2:
          return 'Tue';
        case 3:
          return 'Wed';
        case 4:
          return 'Thu';
        case 5:
          return 'Fri';
        case 6:
          return 'Sat';
        case 7:
          return 'Sun';
      }
    } else {
      return '${time.day}/${time.month}';
    }
    return 'NOOO';
  }
}
