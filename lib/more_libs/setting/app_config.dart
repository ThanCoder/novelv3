import 'dart:convert';
import 'dart:io';

import 'package:t_widgets/theme/t_theme_services.dart';
import 'package:than_pkg/than_pkg.dart';

import 'setting.dart';

class AppConfig {
  String customPath;
  String forwardProxyUrl;
  String browserForwardProxyUrl;
  String proxyUrl;
  String hostUrl;
  bool isUseCustomPath;
  bool isUseForwardProxy;
  bool isUseProxy;
  bool isDarkTheme;
  TThemeModes themeMode;
  AppConfig({
    required this.customPath,
    required this.forwardProxyUrl,
    required this.browserForwardProxyUrl,
    required this.proxyUrl,
    required this.hostUrl,
    required this.isUseCustomPath,
    required this.isUseForwardProxy,
    required this.isUseProxy,
    required this.isDarkTheme,
    required this.themeMode,
  });

  factory AppConfig.create({
    String customPath = '',
    String forwardProxyUrl = '',
    String browserForwardProxyUrl = '',
    String proxyUrl = '',
    String hostUrl = '',
    bool isUseCustomPath = false,
    bool isUseForwardProxy = false,
    bool isUseProxy = false,
    bool isDarkTheme = false,
    TThemeModes themeMode = TThemeModes.system,
  }) {
    return AppConfig(
      customPath: customPath,
      forwardProxyUrl: forwardProxyUrl,
      browserForwardProxyUrl: browserForwardProxyUrl,
      proxyUrl: proxyUrl,
      hostUrl: hostUrl,
      isUseCustomPath: isUseCustomPath,
      isUseForwardProxy: isUseForwardProxy,
      isUseProxy: isUseProxy,
      isDarkTheme: isDarkTheme,
      themeMode: themeMode,
    );
  }

  AppConfig copyWith({
    String? customPath,
    String? forwardProxyUrl,
    String? browserForwardProxyUrl,
    String? proxyUrl,
    String? hostUrl,
    bool? isUseCustomPath,
    bool? isUseForwardProxy,
    bool? isUseProxy,
    bool? isDarkTheme,
    TThemeModes? themeMode,
  }) {
    return AppConfig(
      customPath: customPath ?? this.customPath,
      forwardProxyUrl: forwardProxyUrl ?? this.forwardProxyUrl,
      browserForwardProxyUrl:
          browserForwardProxyUrl ?? this.browserForwardProxyUrl,
      proxyUrl: proxyUrl ?? this.proxyUrl,
      hostUrl: hostUrl ?? this.hostUrl,
      isUseCustomPath: isUseCustomPath ?? this.isUseCustomPath,
      isUseForwardProxy: isUseForwardProxy ?? this.isUseForwardProxy,
      isUseProxy: isUseProxy ?? this.isUseProxy,
      isDarkTheme: isDarkTheme ?? this.isDarkTheme,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  // map
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'customPath': customPath,
      'forwardProxyUrl': forwardProxyUrl,
      'browserForwardProxyUrl': browserForwardProxyUrl,
      'proxyUrl': proxyUrl,
      'hostUrl': hostUrl,
      'isUseCustomPath': isUseCustomPath,
      'isUseForwardProxy': isUseForwardProxy,
      'isUseProxy': isUseProxy,
      'isDarkTheme': isDarkTheme,
      'themeMode': themeMode.name,
    };
  }

  factory AppConfig.fromMap(Map<String, dynamic> map) {
    return AppConfig(
      customPath: map.getString(['customPath']),
      forwardProxyUrl: map.getString(['forwardProxyUrl']),
      browserForwardProxyUrl: map.getString(['browserForwardProxyUrl']),
      proxyUrl: map.getString(['proxyUrl']),
      hostUrl: map.getString(['hostUrl']),
      isUseCustomPath: map.getBool(['isUseCustomPath']),
      isUseForwardProxy: map.getBool(['isUseForwardProxy']),
      isUseProxy: map.getBool(['isUseProxy']),
      isDarkTheme: map.getBool(['isDarkTheme']),
      themeMode: TThemeModes.getName(map.getString(['themeMode'])),
    );
  }

  // void
  Future<void> save() async {
    try {
      final file = File('${Setting.appConfigPath}/${Setting.configFileName}');
      final contents = JsonEncoder.withIndent(' ').convert(toMap());
      await file.writeAsString(contents);
      await Setting.instance.reSetConfig();
    } catch (e) {
      Setting.showDebugLog(e.toString(), tag: 'AppConfig:save');
    }
  }

  // get config
  static Future<AppConfig> getConfig() async {
    final file = File('${Setting.appConfigPath}/${Setting.configFileName}');
    if (file.existsSync()) {
      final source = await file.readAsString();
      return AppConfig.fromMap(jsonDecode(source));
    }
    return AppConfig.create();
  }
}
