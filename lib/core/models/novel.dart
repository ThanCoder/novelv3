import 'package:novel_v3/core/models/novel_meta.dart';
import 'package:novel_v3/core/utils/novel_source_scanner.dart';

class Novel {
  final NovelMeta meta;
  final String folderName;
  final int size;
  const Novel({
    required this.meta,
    required this.folderName,
    required this.size,
  });

  String get coverPath => getSourcePath(folderName, 'cover.png');
  String get chapterDBPath => getSourcePath(folderName, 'chapters.2.db');

  @override
  String toString() {
    return 'ID: ${meta.id} - Title: ${meta.title}';
  }
}
