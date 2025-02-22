import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../notifiers/app_notifier.dart';

class TLoader extends StatelessWidget {
  double size;
  Color? color;
  bool isCustomTheme;
  bool isDarkMode;
  TLoader({
    super.key,
    this.size = 50,
    this.color,
    this.isCustomTheme = false,
    this.isDarkMode = false,
  });

  Color _getCurrentColor() {
    if (isCustomTheme) {
      return isDarkMode ? Colors.white : Colors.black;
    } else {
      return isDarkThemeNotifier.value ? Colors.white : Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SpinKitFadingCircle(
      size: size,
      color: _getCurrentColor(),
    );
  }
}
