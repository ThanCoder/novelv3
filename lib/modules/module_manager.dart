import 'package:flutter/material.dart';

abstract class ModuleApp<P, R> {
  String get title;
  bool get showUIList;

  Future<R?> go(BuildContext context, P params);
}

class ModuleManager {
  static ModuleManager instance = ModuleManager._();
  ModuleManager._();
  factory ModuleManager() => instance;

  final Map<Type, ModuleApp> _apps = {};

  void register(ModuleApp app) {
    _apps[app.runtimeType] = app;
  }

  Future<R?> open<T extends ModuleApp<P, R>, P, R>(
    BuildContext context,
    P params,
  ) async {
    final app = _apps[T];
    if (app == null) {
      print('Module: `$T` No Found!');
      return null;
    }
    return await (app as T).go(context, params);
  }
}
