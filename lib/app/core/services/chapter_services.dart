import 'dart:io';

import 'package:novel_v3/app/core/models/chapter.dart';
import 'package:than_pkg/extensions/file_system_entity_extension.dart';

class ChapterServices {
  static final ChapterServices instance = ChapterServices._();
  ChapterServices._();
  factory ChapterServices() => instance;

  Future<List<Chapter>> getAll(String novelPath) async {
    List<Chapter> list = [];
    final dir = Directory(novelPath);
    if (!dir.existsSync()) return list;
    // check db
    final chapterDBFile = File('$novelPath/chapters.db');
    if (chapterDBFile.existsSync()) {
      return list;
    }
    // not exists
    for (var file in dir.listSync(followLinks: false)) {
      if (!file.isFile) continue;
      final title = file.getName();
      if (!Chapter.isChapterFile(title)) continue;
      list.add(
        Chapter(
          number: int.parse(title),
          title: 'Untitled',
          date: file.getDate,
          novelPath: novelPath,
        ),
      );
    }

    return list;
  }

  Future<String?> getContent(int chapterNumber, String novelPath) async {
    final file = File('$novelPath/$chapterNumber');
    if (!file.existsSync()) {
      return null;
    }
    return await file.readAsString();
  }

  Future<void> setChapter(Chapter chapter) async {
    if (chapter.novelPath == null) return;
    final file = File('${chapter.novelPath}/${chapter.number}');
    await file.writeAsString(chapter.content ?? '');
  }
}
