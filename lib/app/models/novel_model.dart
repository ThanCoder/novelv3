// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:novel_v3/app/constants.dart';
import 'package:novel_v3/app/utils/path_util.dart';

class NovelModel {
  String title;
  String path;
  bool isCompleted;
  bool isAdult;
  int date;
  String content;
  String pageLink;
  int readed;
  String mc;
  String author;
  late String coverPath;
  late String contentCoverPath;
  late String chapterBookmarkPath;

  NovelModel({
    required this.title,
    required this.path,
    required this.isCompleted,
    required this.isAdult,
    required this.date,
    this.content = '',
    this.pageLink = '',
    this.readed = 0,
    this.mc = 'Unknown',
    this.author = 'Unknown',
  }) {
    coverPath = '$path/cover.png';
    contentCoverPath = '$path/content_cover';
    chapterBookmarkPath = '$path/$chapterBookMarkListName';
  }

  set allPath(String _path) {
    path = _path;
    coverPath = '$_path/cover.png';
    contentCoverPath = '$_path/content_cover';
  }

  factory NovelModel.fromPath(String path, {bool isFullInfo = false}) {
    final dir = Directory(path);
    bool isAdult = File('${dir.path}/is-adult').existsSync();
    bool isCompleted = File('${dir.path}/is-completed').existsSync();
    String content = '';
    String pageLink = '';
    String mc = 'Unknown';
    String author = 'Unknown';
    int readed = 0;

    final readedFile = File('${dir.path}/readed');
    final mcFile = File('${dir.path}/mc');
    final authorFile = File('${dir.path}/author');

    if (readedFile.existsSync()) {
      String res = readedFile.readAsStringSync();
      if (res.isNotEmpty && int.tryParse(res) != null) {
        readed = int.parse(res);
      }
    }
    if (mcFile.existsSync()) {
      mc = mcFile.readAsStringSync();
    }
    if (authorFile.existsSync()) {
      author = authorFile.readAsStringSync();
    }

    //full info
    if (isFullInfo) {
      final contentFile = File('${dir.path}/content');
      final pageLinkFile = File('${dir.path}/link');

      if (pageLinkFile.existsSync()) {
        pageLink = pageLinkFile.readAsStringSync();
      }

      if (contentFile.existsSync()) {
        content = contentFile.readAsStringSync();
      }
    }

    return NovelModel(
      title: PathUtil.instance.getBasename(dir.path),
      path: dir.path,
      isCompleted: isCompleted,
      isAdult: isAdult,
      content: content,
      readed: readed,
      pageLink: pageLink,
      mc: mc,
      author: author,
      date: dir.statSync().modified.millisecondsSinceEpoch,
    );
  }

  factory NovelModel.fromMap(Map<String, dynamic> map) {
    final novel = NovelModel(
      title: map['title'] ?? '',
      path: map['path'] ?? '',
      isCompleted: map['is_completed'] ?? false,
      isAdult: map['is_adult'] ?? false,
      date: map['date'] ?? 0,
    );
    novel.pageLink = map['page_link'] ?? '';
    novel.coverPath = map['cover_path'] ?? '';
    novel.mc = map['mc'] ?? '';
    novel.author = map['author'] ?? '';
    novel.content = map['content'] ?? '';
    novel.readed = map['readed'] ?? '';

    return novel;
  }

  Map<String, dynamic> toMap() => {
        "title": title,
        "path": path,
        'cover_path': coverPath,
        'is_completed': isCompleted,
        'is_adult': isAdult,
        'content': content,
        'readed': readed,
        'mc': mc,
        'author': author,
        'date': date,
        'page_link': pageLink,
      };

  @override
  String toString() {
    return title;
  }
}
