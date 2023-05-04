import 'package:intl/intl.dart';

extension DateTimeExtensions on DateTime {
  String toShortString() {
    DateTime now = DateTime.now();
    if (now.isAfter(DateTime(year, month, day, 23, 59, 59, 999, 999))) {
      if (now.year != year) {
        return DateFormat('dd/MM/yy').format(this);
      }

      return DateFormat('dd/MM').format(this);
    }

    return DateFormat('HH:mm').format(this);
  }
}
