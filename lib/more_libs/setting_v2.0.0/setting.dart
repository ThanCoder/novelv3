import 'package:flutter/material.dart';
import 'package:than_pkg/than_pkg.dart';

import 'others/index.dart';
export 'others/index.dart';

typedef OnShowMessageCallback =
    void Function(BuildContext context, String message);

class Setting {
  // singleton
  static final Setting instance = Setting._();
  Setting._();
  factory Setting() => instance;
  //app config
  static AppConfig get getAppConfig => appConfigNotifier.value;
  // app config.json အတွက်
  static String appConfigPath = '';
  // app custom path or root path
  static String appRootPath = '';
  // app output path
  static String appExternalPath = '';
  static ValueNotifier<AppConfig> get getAppConfigNotifier => appConfigNotifier;
  static String get getOutPath => PathUtil.getOutPath();
  static String versionLable = '';

  //widget
  static Widget get getHomeScreen => AppSettingScreen();
  static Widget get getThemeSwitcherWidget => ThemeComponent();
  static Widget get getSettingListTileWidget => AppSettingListTile();
  static Widget get getCurrentVersionWidget => AppCurrentVersion();
  static Widget get getCacheManagerWidget => AppCacheManager();

  static bool isShowDebugLog = true;
  static bool isAppRefreshConfigPathChanged = true;
  late String appName;
  OnShowMessageCallback? onShowMessage;

  Future<void> initSetting({
    required String appName,
    bool isShowDebugLog = true,
    OnShowMessageCallback? onShowMessage,
    bool isAppRefreshConfigPathChanged = false,
    String versionLable = '',
  }) async {
    try {
      Setting.isShowDebugLog = isShowDebugLog;
      Setting.isAppRefreshConfigPathChanged = isAppRefreshConfigPathChanged;
      Setting.versionLable = versionLable;
      this.appName = appName;
      this.onShowMessage = onShowMessage;

      final rootPath = await ThanPkg.platform.getAppRootPath();
      final externalPath = await ThanPkg.platform.getAppExternalPath();
      if (rootPath == null || rootPath.isEmpty) {
        throw Exception('app root path is null Or Empty!');
      }
      //set
      appConfigPath = PathUtil.createDir('$rootPath/.$appName');
      appRootPath = appConfigPath;
      appExternalPath = externalPath ?? '';

      await initSetConfigFile();
    } catch (e) {
      showDebugLog(e.toString(), tag: 'Setting:initSetting');
    }
  }

  static String getForwardProxyUrl(String url) {
    // proxy ကို ဦးစားပေးမယ်
    // if (getAppConfig.isUseProxy && getAppConfig.proxyUrl.isNotEmpty) {
    //   return '${getAppConfig.proxyUrl}?url=$url';
    // }

    if (getAppConfig.isUseForwardProxy &&
        getAppConfig.forwardProxyUrl.isNotEmpty) {
      return '${getAppConfig.forwardProxyUrl}?url=$url';
    }
    return url;
  }

  // လိုအပ်တာတွေကို init ပြန်လုပ်
  Future<void> initSetConfigFile() async {
    try {
      final config = await AppConfig.getConfig();
      appConfigNotifier.value = config;
      //custom path
      if (config.isUseCustomPath && config.customPath.isNotEmpty) {
        appRootPath = config.customPath;
      }
    } catch (e) {
      showDebugLog(e.toString(), tag: 'Setting:_initAppConfig');
    }
  }

  void showMessage(BuildContext context, String message) {
    if (onShowMessage == null) return;
    onShowMessage!(context, message);
  }

  // static
  static void restartApp(BuildContext context) {
    if (isAppRefreshConfigPathChanged) {
      AppRestartWidget.restartApp(context);
    }
  }

  static void showDebugLog(String message, {String? tag}) {
    if (!isShowDebugLog) return;
    if (tag != null) {
      debugPrint('[$tag]: $message');
    } else {
      debugPrint(message);
    }
  }

  static String get getErrorLog {
    return ''' await Setting.instance.initSetting''';
  }
}
