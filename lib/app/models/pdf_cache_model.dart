import 'package:novel_v3/app/utils/path_util.dart';

class PdfCacheModel {
  String title;
  String path;
  PdfCacheModel({
    required this.title,
    required this.path,
  });

  factory PdfCacheModel.fromPath(String path) {
    return PdfCacheModel(title: PathUtil.instance.getBasename(path), path: path);
  }
}
