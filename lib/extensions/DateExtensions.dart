import 'package:intl/intl.dart';

extension DateConversion on DateTime {
  String formatDate() {
    return DateFormat.yMMMd().format(this);
  }
}

extension DateFormatConversion on String {
  String dateToMonth() {
    return this.substring(0, 3) + this.substring(this.length - 4);
  }
}
