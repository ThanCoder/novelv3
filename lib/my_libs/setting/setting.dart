import 'package:flutter/material.dart';
import 'package:than_pkg/than_pkg.dart';
import 'app_config_model.dart';
import 'app_notifier.dart';
import 'constants.dart';

class Setting {
  static String getForwardProxyUrl(String url) {
    if (appConfigNotifier.value.isUseProxyServer) {
      return '${appConfigNotifier.value.forwardProxyUrl}?url=$url';
    }
    return url;
  }

  static Future<void> initAppConfigService() async {
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

  static Future<void> _initAppConfig() async {
    try {
      final config = AppConfigModel.get();
      appConfigNotifier.value = config;
      //custom path
      if (config.isUseCustomPath && config.customPath.isNotEmpty) {
        appRootPathNotifier.value = config.customPath;
      }
    } catch (e) {
      debugPrint('_initAppConfig: ${e.toString()}');
    }
  }
}
