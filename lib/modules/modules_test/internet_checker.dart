import 'package:flutter/material.dart';
import 'package:novel_v3/modules/module_manager.dart';

class ConnectionResult {
  final bool isConnected;
  ConnectionResult(this.isConnected);
}

class InternetCheckerModule extends ModuleApp<void, ConnectionResult> {
  @override
  Future<ConnectionResult> go(BuildContext context, void params) async {
    await Future.delayed(Duration(seconds: 2));
    return ConnectionResult(true);
  }

  @override
  // TODO: implement moduleId
  String get id => throw UnimplementedError();
}
