import 'dart:io';

import 'package:flutter/material.dart';
import 'package:novel_v3/app/constants.dart';
import 'package:novel_v3/app/notifiers/app_notifier.dart';
import 'package:novel_v3/app/services/app_config_services.dart';
import 'package:path_provider/path_provider.dart';

Future<void> initConfig() async {
  try {
    if (Platform.isLinux) {
      appRootPathNotifier.value = '${Directory.current.path}/.$appName';
    } else if (Platform.isAndroid) {
      final dir = await getExternalStorageDirectory();
      appRootPathNotifier.value = dir!.path;
      appDataRootPathNotifier.value = dir.path;
    }
    appConfigPathNotifier.value =
        '${appRootPathNotifier.value}/$appConfigFileName';
    //config
    await initAppConfig();
  } catch (e) {
    debugPrint('initConfig: ${e.toString()}');
  }
}
