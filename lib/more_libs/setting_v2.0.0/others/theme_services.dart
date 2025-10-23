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

// class ThemeListener {
//   static final ThemeListener instance = ThemeListener._();
//   ThemeListener._();
//   factory ThemeListener() => instance;

//   StreamSubscription<ThemeModes>? _themeSub;
//   StreamSubscription<ThemeModes> getStreamSubscription(){
//     _themeSub ??= ThemeServices().onBrightnessChanged;
//   }
// }

class ThemeServices with WidgetsBindingObserver {
  static final ThemeServices instance = ThemeServices._();
  ThemeServices._();
  factory ThemeServices() => instance;

  final _controller = StreamController<ThemeModes>.broadcast();
  Stream<ThemeModes> get onBrightnessChanged => _controller.stream;

  void init() {
    WidgetsBinding.instance.addObserver(this);
    // initial check
    check();
  }

  void check() {
    // Android <10, Linux မှာ အမြဲ light ဖြစ်နိုင်တယ်
    final brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    _controller.add(ThemeModes.fromBrightness(brightness));
  }

  @override
  void didChangePlatformBrightness() {
    // OS theme ပြောင်းတာ detect
    check();
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.close();
  }
}
