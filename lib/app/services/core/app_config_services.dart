import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:than_pkg/than_pkg.dart';
import '../../constants.dart';
import '../../models/core/app_config_model.dart';
import '../../notifiers/app_notifier.dart';

Future<void> initAppConfigService() async {
  try {
    final rootPath = await ThanPkg.platform.getAppRootPath();
    final externalPath = await ThanPkg.platform.getAppExternalPath();
    //set
    if (rootPath != null) {
      appRootPathNotifier.value = '$rootPath/.$appName';
      appConfigPathNotifier.value = '$rootPath/.$appName';
    }
    if (externalPath != null) {
      appExternalPathNotifier.value = externalPath;
    }
    await _initAppConfig();
  } catch (e) {
    debugPrint('initConfig: ${e.toString()}');
  }
}

Future<void> _initAppConfig() async {
  try {
    final config = getConfigFile();
    appConfigNotifier.value = config;
    //custom path
    if (config.isUseCustomPath && config.customPath.isNotEmpty) {
      appRootPathNotifier.value = config.customPath;
    }
    isDarkThemeNotifier.value = config.isDarkTheme;
  } catch (e) {
    debugPrint('_initAppConfig: ${e.toString()}');
  }
}

AppConfigModel getConfigFile() {
  final file = File('${appConfigPathNotifier.value}/$appConfigFileName');
  if (!file.existsSync()) {
    return AppConfigModel();
  }
  return AppConfigModel.fromJson(jsonDecode(file.readAsStringSync()));
}

void setConfigFile(AppConfigModel appConfig) {
  final file = File('${appConfigPathNotifier.value}/$appConfigFileName');
  String data = const JsonEncoder.withIndent('  ').convert(appConfig.toJson());
  file.writeAsStringSync(data);
  appConfigNotifier.value = appConfig;
}
