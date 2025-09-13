import 'dart:async';

import 'package:flutter/widgets.dart';

enum ThemeModes {
  system,
  light,
  dark;

  bool get isDarkMode {
    return this == dark;
  }

  static ThemeModes getName(String name) {
    if (name == Brightness.light.name) {
      return ThemeModes.light;
    }
    if (name == Brightness.dark.name) {
      return ThemeModes.dark;
    }

    return ThemeModes.system;
  }

  static ThemeModes fromBrightness(Brightness brightness) {
    if (brightness == Brightness.light) {
      return ThemeModes.light;
    }
    if (brightness == Brightness.dark) {
      return ThemeModes.dark;
    }

    return ThemeModes.system;
  }
}

class ThemeServices with WidgetsBindingObserver {
  ThemeServices() {
    WidgetsBinding.instance.addObserver(this);
    // init
    final brightness = WidgetsBinding.instance.window.platformBrightness;
    Future.delayed(Duration(milliseconds: 900), () {
      _controller.add(ThemeModes.fromBrightness(brightness));
    });
  }
  final _controller = StreamController<ThemeModes>.broadcast();
  Stream<ThemeModes> get onBrightnessChanged => _controller.stream;

  @override
  void didChangePlatformBrightness() {
    final brightness = WidgetsBinding.instance.window.platformBrightness;
    _controller.add(ThemeModes.fromBrightness(brightness));
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.close();
  }
}
