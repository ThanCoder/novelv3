import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../notifiers/app_notifier.dart';

class TLoader extends StatelessWidget {
  double? size;
  Color? color;
  bool isCustomTheme;
  bool isDarkMode;
  TLoader({
    super.key,
    this.size,
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
    if (size != null) {
      return SizedBox(
        width: size,
        height: size,
        child: SpinKitFadingCircle(
          size: size ?? 50,
          color: _getCurrentColor(),
        ),
      );
    }
    return SpinKitFadingCircle(
      size: size ?? 50,
      color: _getCurrentColor(),
    );
  }
}
