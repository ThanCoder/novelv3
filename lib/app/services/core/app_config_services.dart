import 'dart:convert';
import 'dart:io';

import 'package:novel_v3/app/models/app_config_model.dart';
import 'package:novel_v3/app/notifiers/app_notifier.dart';

Future<void> initAppConfig() async {
  final config = getConfigFile();
  appConfigNotifier.value = config;
  //custom path
  if (config.isUseCustomPath && config.customPath.isNotEmpty) {
    appRootPathNotifier.value = config.customPath;
  }
  isDarkThemeNotifier.value = config.isDarkTheme;
}

AppConfigModel getConfigFile() {
  final file = File(appConfigPathNotifier.value);
  if (!file.existsSync()) {
    return AppConfigModel();
  }
  return AppConfigModel.fromJson(jsonDecode(file.readAsStringSync()));
}

void setConfigFile(AppConfigModel appConfig) {
  final file = File(appConfigPathNotifier.value);
  String data = const JsonEncoder.withIndent('  ').convert(appConfig.toJson());
  file.writeAsStringSync(data);
}
