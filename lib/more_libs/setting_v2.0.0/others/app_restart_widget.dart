import 'package:flutter/material.dart';

class AppRestartWidget extends StatefulWidget {
  Widget child;
  Future<void> Function() onRestartLogic;
  AppRestartWidget({
    super.key,
    required this.child,
    required this.onRestartLogic,
  });

  @override
  State<AppRestartWidget> createState() => _AppRestartWidgetState();

  /// Static method for restarting the app
  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_AppRestartWidgetState>()?.restartApp();
  }

  static Future<void> Function()? _onInitializeApp;

  static Future<void> initializeApp({
    required Future<void> Function() onInitializeApp,
  }) async {
    AppRestartWidget._onInitializeApp = onInitializeApp;
    await onInitializeApp();
  }
}

class _AppRestartWidgetState extends State<AppRestartWidget> {
  Key _restartKey = UniqueKey();

  Future<void> restartApp() async {
    // run custom restart logic
    await widget.onRestartLogic();

    if (AppRestartWidget._onInitializeApp != null) {
      await AppRestartWidget._onInitializeApp!();
    }

    // force rebuild
    setState(() {
      _restartKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(key: _restartKey, child: widget.child);
  }
}
