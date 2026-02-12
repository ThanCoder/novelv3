import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:novel_v3/core/models/novel.dart';
import 'package:novel_v3/core/services/chapter_services.dart';
import 'package:novel_v3/app/others/share/html_pages/html_content_page.dart';
import 'package:novel_v3/app/others/share/html_pages/html_home_page.dart';
import 'package:novel_v3/app/others/share/libs/novel_chapter.dart';
import 'package:novel_v3/app/others/share/libs/novel_file.dart';
import 'package:novel_v3/more_libs/setting/core/path_util.dart';
import 'package:than_pkg/than_pkg.dart';

class NovelShareServices {
  ///
  /// --- Api ---
  ///
  static Future<String> viewChapters(Novel novel) async {
    List<NovelChapter> chapters = [];
    final dir = Directory(pathJoin(PathUtil.getSourcePath(), novel.id));
    if (dir.existsSync()) {
      for (var chapter in await ChapterServices.getAll(dir.path)) {
        chapters.add(
          NovelChapter(
            id: chapter.autoId,
            novelId: novel.id,
            chapter: chapter.number,
          ),
        );
      }
    }
    // sort
    chapters.sort((a, b) {
      if (a.chapter > b.chapter) return 1;
      if (a.chapter < b.chapter) return -1;
      return 0;
    });
    return jsonEncode({'chapters': chapters.map((e) => e.toMap()).toList()});
  }

  static Future<String> viewChapterContent(
    Novel novel,
    int chapterNumber,
  ) async {
    String? content;
    final dir = Directory(pathJoin(PathUtil.getSourcePath(), novel.id));
    if (dir.existsSync()) {
      content = await ChapterServices.getContent(chapterNumber, dir.path);
    }
    return jsonEncode({'chapter_content': content ?? ''});
  }

  static String viewNovel(Novel novel) {
    List<NovelFile> files = [];
    final dir = Directory(pathJoin(PathUtil.getSourcePath(), novel.id));
    if (dir.existsSync()) {
      for (final file in dir.listSync(followLinks: false)) {
        if (!file.isFile) continue;
        files.add(
          NovelFile(
            name: file.getName(),
            mime: lookupMimeType(file.path) ?? '',
            size: file.getSize,
            date: file.getDate,
          ),
        );
      }
    }

    return jsonEncode({
      'novel': novel.toMap(),
      'files': files.map((e) => e.toMap()).toList(),
    });
  }

  static String getJson(List<Novel> list) {
    final jsonList = list.map((e) => e.toMap()).toList();
    // return JsonEncoder.withIndent(' ').convert(jsonList);
    return jsonEncode(jsonList);
  }

  ///
  /// --- Web ---
  ///
  static String getHomeHtml(List<Novel> list) {
    try {
      final html = HtmlHomePage(list).renderHtml();
      return html;
    } catch (e) {
      debugPrint('[NovelShareServices:getHomeHtml]: $e');
      return '<h1>Error: $e</h1>';
    }
    // File('res.html').writeAsStringSync(html);
  }

  static String viewWebNovel(Novel novel) {
    List<NovelFile> files = [];
    final dir = Directory(pathJoin(PathUtil.getSourcePath(), novel.id));
    if (dir.existsSync()) {
      for (final file in dir.listSync(followLinks: false)) {
        if (!file.isFile) continue;
        files.add(
          NovelFile(
            name: file.getName(),
            mime: lookupMimeType(file.path) ?? '',
            size: file.getSize,
            date: file.getDate,
          ),
        );
      }
    }
    try {
      final html = HtmlContentPage(novel: novel, files: files).renderHtml();
      return html;
    } catch (e) {
      debugPrint('[NovelShareServices:getHomeHtml]: $e');
      return '<h1>Error: $e</h1>';
    }
  }
}
