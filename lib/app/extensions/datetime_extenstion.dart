import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

extension DatetimeExtenstion on DateTime {
  String toParseTime({String pattern = 'hh:mm a dd/MM/yyyy'}) {
    return DateFormat(pattern).format(this);
  }

  String toTimeAgo() {
    return timeago.format(this);
  }
}
