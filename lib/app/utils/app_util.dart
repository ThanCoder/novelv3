import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppUtil {
  static final AppUtil instance = AppUtil._();
  AppUtil._();
  factory AppUtil() => instance;

  String getParseMinutes(int minutes) {
    String res = '';
    try {
      final dur = Duration(minutes: minutes);
      res = '${_getTwoZero(dur.inHours)}:${_getTwoZero(dur.inMinutes)}';
    } catch (e) {
      debugPrint('getParseMinutes: ${e.toString()}');
    }
    return res;
  }

  String _getTwoZero(int num) {
    return num < 10 ? '0$num' : '$num';
  }

  String getParseDate(int date, {String format = 'yyyy-MM-dd HH:mm:ss'}) {
    String res = '';
    try {
      final lastModifiedDateTime = DateTime.fromMillisecondsSinceEpoch(date);
      // Format DateTime
      res = DateFormat(format).format(lastModifiedDateTime);
    } catch (e) {
      debugPrint('getParseDate: ${e.toString()}');
    }
    return res;
  }

  String getParseFileSize(double size) {
    String res = '';
    int pow = 1024;
    final labels = ['byte', 'KB', 'MB', 'GB', 'TB'];
    int i = 0;
    while (size > pow) {
      size /= pow;
      i++;
    }

    res = '${size.toStringAsFixed(2)} ${labels[i]}';

    return res;
  }
}
