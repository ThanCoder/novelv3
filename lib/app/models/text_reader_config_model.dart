// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:io';

class TextReaderConfigModel {
  double fontSize;
  String fontColor;
  String bgColor;
  bool usedCustomTheme;
  TextReaderConfigModel({
    this.fontSize = 21,
    this.fontColor = '',
    this.bgColor = '',
    this.usedCustomTheme = false,
  });

  factory TextReaderConfigModel.fromPath(String path) {
    final file = File(path);
    if (!file.existsSync()) return TextReaderConfigModel();
    //ရှိနေရင်
    Map<String, dynamic> map = jsonDecode(file.readAsStringSync());
    return TextReaderConfigModel(
      fontSize: map['font_size'] ?? 21,
      fontColor: map['font_color'] ?? '',
      bgColor: map['bg_color'] ?? '',
      usedCustomTheme: map['used_custom_theme'] ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'font_size': fontSize,
        'font_color': fontColor,
        'bg_color': bgColor,
        'used_custom_theme': usedCustomTheme,
      };

  @override
  String toString() {
    return '\nfontSize => $fontSize\nfontColor => $fontColor\nbgColor => $bgColor \nusedCustomTheme => $usedCustomTheme\n';
  }
}
