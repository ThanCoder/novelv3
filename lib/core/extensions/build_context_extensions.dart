import 'package:flutter/material.dart';

extension BuildContextExtensions on BuildContext {
  void closeNavigator({bool? isReturned}) {
    if (isReturned != null) {
      Navigator.pop(this, isReturned);
    } else {
      Navigator.pop(this);
    }
  }

  void goRoute({required Widget Function(BuildContext context) builder}) {
    Navigator.push(this, MaterialPageRoute(builder: builder));
  }

  Brightness get brightness {
    return Theme.of(this).brightness;
  }

  bool get isAppDark => brightness == Brightness.dark;
}
