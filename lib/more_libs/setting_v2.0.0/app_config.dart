import 'dart:convert';
import 'dart:io';

import 'package:novel_v3/more_libs/setting_v2.0.0/others/novel_home_list_styles.dart';
import 'package:than_pkg/than_pkg.dart';

import 'setting.dart';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class AppConfig {
  final String customPath;
  final String forwardProxyUrl;
  final String browserForwardProxyUrl;
  final String proxyUrl;
  final String hostUrl;
  final bool isUseCustomPath;
  final bool isUseForwardProxy;
  final bool isUseProxy;
  final String customNovelContentImagePath;
  final ThemeModes themeMode;
  final bool isDarkMode;
  final NovelHomeListStyles homeListStyle;

  const AppConfig({
    required this.customPath,
    required this.forwardProxyUrl,
    required this.browserForwardProxyUrl,
    required this.proxyUrl,
    required this.hostUrl,
    required this.isUseCustomPath,
    required this.isUseForwardProxy,
    required this.isUseProxy,
    required this.customNovelContentImagePath,
    required this.themeMode,
    required this.isDarkMode,
    required this.homeListStyle,
  });

  factory AppConfig.create({
    String customPath = '',
    String customNovelContentImagePath = '',
    String forwardProxyUrl = '',
    String browserForwardProxyUrl = '',
    String proxyUrl = '',
    String hostUrl = '',
    bool isUseCustomPath = false,
    bool isUseForwardProxy = false,
    bool isUseProxy = false,
    bool isDarkTheme = false,
    bool isDarkMode = false,
    ThemeModes themeMode = ThemeModes.system,
    NovelHomeListStyles homeListStyle = NovelHomeListStyles.defaultStyle,
  }) {
    return AppConfig(
      customPath: customPath,
      customNovelContentImagePath: customNovelContentImagePath,
      forwardProxyUrl: forwardProxyUrl,
      browserForwardProxyUrl: browserForwardProxyUrl,
      proxyUrl: proxyUrl,
      hostUrl: hostUrl,
      isUseCustomPath: isUseCustomPath,
      isUseForwardProxy: isUseForwardProxy,
      isUseProxy: isUseProxy,
      themeMode: themeMode,
      isDarkMode: isDarkMode,
      homeListStyle: homeListStyle,
    );
  }

  AppConfig copyWith({
    String? customPath,
    String? customNovelContentImagePath,
    String? forwardProxyUrl,
    String? browserForwardProxyUrl,
    String? proxyUrl,
    String? hostUrl,
    bool? isUseCustomPath,
    bool? isUseForwardProxy,
    bool? isUseProxy,
    ThemeModes? themeMode,
    bool? isDarkMode,
    NovelHomeListStyles? homeListStyle,
  }) {
    return AppConfig(
      customPath: customPath ?? this.customPath,
      customNovelContentImagePath:
          customNovelContentImagePath ?? this.customNovelContentImagePath,
      forwardProxyUrl: forwardProxyUrl ?? this.forwardProxyUrl,
      browserForwardProxyUrl:
          browserForwardProxyUrl ?? this.browserForwardProxyUrl,
      proxyUrl: proxyUrl ?? this.proxyUrl,
      hostUrl: hostUrl ?? this.hostUrl,
      isUseCustomPath: isUseCustomPath ?? this.isUseCustomPath,
      isUseForwardProxy: isUseForwardProxy ?? this.isUseForwardProxy,
      isUseProxy: isUseProxy ?? this.isUseProxy,
      themeMode: themeMode ?? this.themeMode,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      homeListStyle: homeListStyle ?? this.homeListStyle,
    );
  }

  // map
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'customPath': customPath,
      'customNovelContentImagePath': customNovelContentImagePath,
      'forwardProxyUrl': forwardProxyUrl,
      'browserForwardProxyUrl': browserForwardProxyUrl,
      'proxyUrl': proxyUrl,
      'hostUrl': hostUrl,
      'isUseCustomPath': isUseCustomPath,
      'isUseForwardProxy': isUseForwardProxy,
      'isUseProxy': isUseProxy,
      'themeMode': themeMode.name,
      'isDarkMode': isDarkMode,
      'homeListStyle': homeListStyle.name,
    };
  }

  factory AppConfig.fromMap(Map<String, dynamic> map) {
    final themeStr = map.getString(['themeMode']);
    final homeListStyleStr = map.getString(['homeListStyle']);

    return AppConfig(
      customPath: map['customPath'] as String,
      customNovelContentImagePath: MapServices.getString(map, [
        'customNovelContentImagePath',
      ]),
      forwardProxyUrl: map['forwardProxyUrl'] as String,
      browserForwardProxyUrl: map['browserForwardProxyUrl'] as String,
      proxyUrl: map['proxyUrl'] as String,
      hostUrl: map['hostUrl'] as String,
      isUseCustomPath: map['isUseCustomPath'] as bool,
      isUseForwardProxy: map['isUseForwardProxy'] as bool,
      isUseProxy: map['isUseProxy'] as bool,
      themeMode: ThemeModes.getName(themeStr),
      isDarkMode: map.getBool(['isDarkMode']),
      homeListStyle: NovelHomeListStyles.getName(homeListStyleStr),
    );
  }

  // void
  Future<void> save() async {
    try {
      final file = File('${Setting.appConfigPath}/$configName');
      final contents = JsonEncoder.withIndent(' ').convert(toMap());
      await file.writeAsString(contents);
      // appConfigNotifier.value = this;
      await Setting.instance.initSetConfigFile();
    } catch (e) {
      Setting.showDebugLog(e.toString(), tag: 'AppConfig:save');
    }
  }

  // get config
  static Future<AppConfig> getConfig() async {
    final file = File('${Setting.appConfigPath}/$configName');
    if (file.existsSync()) {
      final source = await file.readAsString();
      return AppConfig.fromMap(jsonDecode(source));
    }
    return AppConfig.create();
  }

  static String configName = 'main.config.json';
}
