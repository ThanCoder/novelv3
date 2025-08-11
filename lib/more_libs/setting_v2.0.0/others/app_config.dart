import 'dart:convert';
import 'dart:io';

import '../setting.dart';

// ignore_for_file: public_member_api_docs, sort_constructors_first
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
  }) {
    return AppConfig(
      customPath: customPath ?? this.customPath,
      forwardProxyUrl: forwardProxyUrl ?? this.forwardProxyUrl,
      browserForwardProxyUrl: browserForwardProxyUrl ?? this.browserForwardProxyUrl,
      proxyUrl: proxyUrl ?? this.proxyUrl,
      hostUrl: hostUrl ?? this.hostUrl,
      isUseCustomPath: isUseCustomPath ?? this.isUseCustomPath,
      isUseForwardProxy: isUseForwardProxy ?? this.isUseForwardProxy,
      isUseProxy: isUseProxy ?? this.isUseProxy,
      isDarkTheme: isDarkTheme ?? this.isDarkTheme,
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
    };
  }

  factory AppConfig.fromMap(Map<String, dynamic> map) {
    return AppConfig(
      customPath: map['customPath'] as String,
      forwardProxyUrl: map['forwardProxyUrl'] as String,
      browserForwardProxyUrl: map['browserForwardProxyUrl'] as String,
      proxyUrl: map['proxyUrl'] as String,
      hostUrl: map['hostUrl'] as String,
      isUseCustomPath: map['isUseCustomPath'] as bool,
      isUseForwardProxy: map['isUseForwardProxy'] as bool,
      isUseProxy: map['isUseProxy'] as bool,
      isDarkTheme: map['isDarkTheme'] as bool,
    );
  }

  // void
  Future<void> save() async {
    try {
      final file = File('${Setting.appConfigPath}/$configName');
      final contents = JsonEncoder.withIndent(' ').convert(toMap());
      await file.writeAsString(contents);
      // appConfigNotifier.value = this;
      Setting.instance.initSetConfigFile();
      
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
