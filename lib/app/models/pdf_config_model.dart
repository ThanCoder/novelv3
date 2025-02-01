// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:io';

class PdfConfigModel {
  int page;
  bool isDarkMode;
  bool isPanLocked;
  bool isShowScrollThumb;
  double offsetDx;
  double offsetDy;
  double zoom;
  PdfConfigModel({
    this.page = 1,
    this.isDarkMode = false,
    this.isPanLocked = false,
    this.isShowScrollThumb = true,
    this.offsetDx = 0,
    this.offsetDy = 0,
    this.zoom = 0,
  });

  factory PdfConfigModel.fromPath(String configPath) {
    final file = File(configPath);
    if (file.existsSync()) {
      final map = jsonDecode(file.readAsStringSync());
      return PdfConfigModel(
        page: map['page'] ?? 1,
        offsetDx: map['offset_dx'] ?? 0,
        offsetDy: map['offset_dy'] ?? 0,
        zoom: map['zoom'] ?? 0,
        isDarkMode: map['dark_mode'] ?? false,
        isPanLocked: map['pan_locked'] ?? false,
        isShowScrollThumb: map['show_scroll_thumb'] ?? false,
      );
    } else {
      return PdfConfigModel(
        page: 1,
        isDarkMode: false,
        isPanLocked: false,
        isShowScrollThumb: true,
      );
    }
  }

  Map<String, dynamic> toJson() => {
        'page': page,
        'dark_mode': isDarkMode,
        'pan_locked': isPanLocked,
        'show_scroll_thumb': isShowScrollThumb,
        'offset_dx': offsetDx,
        'offset_dy': offsetDy,
        'zoom': zoom,
      };

  @override
  String toString() {
    return '\npage => $page\ndark_mode => $isDarkMode\npan_locked => $isPanLocked\nshow_scroll_thumb => $isShowScrollThumb\n';
  }
}
