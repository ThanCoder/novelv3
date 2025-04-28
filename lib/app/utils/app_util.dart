import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppUtil {
  static String getParseMinutes(int minutes) {
    String res = '';
    try {
      final dur = Duration(minutes: minutes);
      res = '${_getTwoZero(dur.inHours)}:${_getTwoZero(dur.inMinutes)}';
    } catch (e) {
      debugPrint('getParseMinutes: ${e.toString()}');
    }
    return res;
  }

  static String _getTwoZero(int num) {
    return num < 10 ? '0$num' : '$num';
  }
}
