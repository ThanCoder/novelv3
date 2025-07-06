// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:novel_v3/app/setting/home_list_styles.dart';

import '../constants.dart';

class AppConfigModel {
  bool isUseCustomPath;
  String customPath;
  bool isDarkTheme;
  bool isShowNovelContentBgImage;
  String forwardProxy;
  String browserProxy;
  HomeListStyles homeListStyle;

  AppConfigModel({
    this.isUseCustomPath = false,
    this.customPath = '',
    this.isDarkTheme = false,
    this.isShowNovelContentBgImage = true,
    this.forwardProxy = appForwardProxyHostUrl,
    this.browserProxy = appBrowserProxyHostUrl,
    required this.homeListStyle,
  });

  factory AppConfigModel.create() {
    return AppConfigModel(
      homeListStyle: HomeListStyles.homeGridStyle,
    );
  }

  factory AppConfigModel.fromJson(Map<String, dynamic> map) {
    var homeListStyle = HomeListStyles.homeGridStyle;
    if (map['home_list_styles'] != null) {
      homeListStyle = HomeListStyles.getStyle(map['home_list_styles']);
    }
    return AppConfigModel(
      isUseCustomPath: map['is_use_custom_path'] ?? '',
      customPath: map['custom_path'] ?? '',
      isDarkTheme: map['is_dark_theme'] ?? false,
      isShowNovelContentBgImage: map['is_show_novel_content_bg_image'] ?? true,
      forwardProxy: map['forward_proxy'] ?? appForwardProxyHostUrl,
      browserProxy: map['browser_proxy'] ?? appBrowserProxyHostUrl,
      homeListStyle: homeListStyle,
    );
  }
  Map<String, dynamic> toJson() => {
        'is_use_custom_path': isUseCustomPath,
        'custom_path': customPath,
        'is_dark_theme': isDarkTheme,
        'is_show_novel_content_bg_image': isShowNovelContentBgImage,
        'forward_proxy': forwardProxy,
        'browser_proxy': browserProxy,
        'home_list_styles': homeListStyle.name,
      };

  @override
  String toString() {
    return 'is_use_custom_path => $isUseCustomPath \ncustom_path => $customPath \nis_dark_theme => $isDarkTheme\n';
  }
}
