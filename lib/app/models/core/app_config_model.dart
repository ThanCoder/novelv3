// ignore_for_file: public_member_api_docs, sort_constructors_first
class AppConfigModel {
  bool isUseCustomPath;
  String customPath;
  bool isDarkTheme;
  bool isShowNovelContentBgImage;

  AppConfigModel({
    this.isUseCustomPath = false,
    this.customPath = '',
    this.isDarkTheme = false,
    this.isShowNovelContentBgImage = true,
  });

  factory AppConfigModel.fromJson(Map<String, dynamic> map) {
    return AppConfigModel(
      isUseCustomPath: map['is_use_custom_path'] ?? '',
      customPath: map['custom_path'] ?? '',
      isDarkTheme: map['is_dark_theme'] ?? false,
      isShowNovelContentBgImage: map['is_show_novel_content_bg_image'] ?? true,
    );
  }
  Map<String, dynamic> toJson() => {
        'is_use_custom_path': isUseCustomPath,
        'custom_path': customPath,
        'is_dark_theme': isDarkTheme,
        'is_show_novel_content_bg_image': isShowNovelContentBgImage,
      };

  @override
  String toString() {
    return 'is_use_custom_path => $isUseCustomPath \ncustom_path => $customPath \nis_dark_theme => $isDarkTheme\n';
  }
}
