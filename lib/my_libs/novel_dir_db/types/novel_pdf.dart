import 'dart:io';

import 'package:t_widgets/extensions/double_extension.dart';
import 'package:than_pkg/extensions/string_extension.dart';

class NovelPdf {
  String path;
  NovelPdf({
    required this.path,
  });

  factory NovelPdf.createPath(String path) {
    return NovelPdf(path: path);
  }

  static bool isPdf(String path) {
    return path.endsWith('.pdf');
  }

  String get getTitle {
    return path.getName();
  }

  String get getConfigPath {
    return path.replaceAll('.pdf', '-config.json');
  }

  DateTime get getDate {
    final file = File(path);
    return file.statSync().modified;
  }

  String get getSize {
    final file = File(path);
    return file.statSync().size.toDouble().toFileSizeLabel();
  }

  String get getCoverPath {
    return path.replaceAll('.pdf', '.png');
  }
}
