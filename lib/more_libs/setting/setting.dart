import 'package:novel_v3/more_libs/setting/app_config.dart';
import 'package:novel_v3/more_libs/setting/app_setting_screen.dart';
import 'package:novel_v3/more_libs/setting/core/app_cache_manager.dart';
import 'package:novel_v3/more_libs/setting/core/app_current_version.dart';
import 'package:novel_v3/more_libs/setting/core/app_setting_list_tile.dart';
import 'package:novel_v3/more_libs/setting/core/path_util.dart';
import 'package:novel_v3/more_libs/setting/core/thancoder_about_widget.dart';
import 'package:flutter/material.dart';
import 'package:than_pkg/than_pkg.dart';
import 'package:novel_v3/more_libs/setting/core/theme_modes_chooser.dart';

typedef OnSettingSavedCallback =
    void Function(BuildContext context, String message);

//config
ValueNotifier<AppConfig> _appConfigNotifier = ValueNotifier(AppConfig.create());

class Setting {
  // singleton
  static final Setting instance = Setting._();
  Setting._();
  factory Setting() => instance;

  ///
  /// ### Static
  ///
  //app config
  static AppConfig get getAppConfig => _appConfigNotifier.value;
  // app config.json အတွက်
  static String appConfigPath = '';
  // app custom path or root path
  static String appRootPath = '';
  // app output path
  static String appExternalPath = '';
  static String appVersionLabel = '';
  static ValueNotifier<AppConfig> get getAppConfigNotifier =>
      _appConfigNotifier;
  static String get getOutPath => PathUtil.getOutPath();
  static String configFileName = 'main.config.json';

  //widget
  static Widget get getHomeScreen => AppSettingScreen();
  static Widget get getSettingListTileWidget => AppSettingListTile();
  static Widget get getCurrentVersionWidget => AppCurrentVersion();
  static Widget get getCacheManagerWidget => AppCacheManager();
  static Widget get getThanCoderAboutWidget => ThancoderAboutWidget();
  static Widget get getThemeModeChooser => ThemeModesChooser();

  static bool isShowDebugLog = true;

  ///
  /// ### Instance
  ///
  late String appName;
  late String packageName;
  late String version;
  String? releaseUrl;
  OnSettingSavedCallback? onSettingSaved;

  Future<void> init({
    required String appName,
    String? customPackageName,
    bool isShowDebugLog = true,
    OnSettingSavedCallback? onSettingSaved,
    bool isAppRefreshConfigPathChanged = false,
    String appVersionLabel = '',
    String? releaseUrl,
  }) async {
    try {
      Setting.isShowDebugLog = isShowDebugLog;
      Setting.appVersionLabel = appVersionLabel;
      this.appName = appName;
      this.onSettingSaved = onSettingSaved;
      this.releaseUrl = releaseUrl;
      // set package
      final pInfo = await ThanPkg.platform.getPackageInfo();
      packageName = customPackageName ?? pInfo.packageName;
      version = pInfo.version;

      final rootPath = await ThanPkg.platform.getAppRootPath();
      final externalPath = await ThanPkg.platform.getAppExternalPath();
      if (rootPath == null || rootPath.isEmpty) {
        throw Exception('app root path is null Or Empty!');
      }
      //set
      appConfigPath = PathUtil.createDir('$rootPath/.$packageName');
      appRootPath = appConfigPath;
      appExternalPath = externalPath ?? '';

      await reSetConfig();
    } catch (e) {
      showDebugLog(e.toString(), tag: 'Setting:init');
    }
  }

  // လိုအပ်တာတွေကို init ပြန်လုပ်
  Future<void> reSetConfig() async {
    try {
      final config = await AppConfig.getConfig();
      _appConfigNotifier.value = config;
      //custom path
      if (config.isUseCustomPath && config.customPath.isNotEmpty) {
        appRootPath = config.customPath;
      } else {
        appRootPath = appConfigPath;
      }

      PathUtil.getSourcePath();
      PathUtil.getConfigPath();
    } catch (e) {
      showDebugLog(e.toString(), tag: 'Setting:reSetConfig');
    }
  }

  ///
  /// Static Methods
  ///
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

  static String getForwardProxyUrl(String url) {
    if (getAppConfig.isUseForwardProxy &&
        getAppConfig.forwardProxyUrl.isNotEmpty) {
      return '${getAppConfig.forwardProxyUrl}?url=$url';
    }
    return url;
  }
}
