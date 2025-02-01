import 'dart:io';

import 'package:flutter/material.dart';
import 'package:novel_v3/app/my_app.dart';
import 'package:novel_v3/app/utils/config_util.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isLinux) {
    await WindowManager.instance.ensureInitialized();
  }
  //init config
  await initConfig();

  runApp(const MyApp());
}
