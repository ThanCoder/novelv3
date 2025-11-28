import 'dart:convert';
import 'dart:io';

import 'package:than_pkg/than_pkg.dart';

class NovelMeta {
  static final String metaName = 'meta.json';
  final String title;
  final String author;
  final String? translator;
  final String mc;
  final String desc;
  final List<String> otherTitleList;
  final bool isAdult;
  final bool isCompleted;
  final List<String> pageUrls;
  final List<String> tags;
  final int readed;
  NovelMeta({
    required this.title,
    required this.author,
    this.translator,
    required this.mc,
    required this.desc,
    required this.otherTitleList,
    required this.isAdult,
    required this.isCompleted,
    required this.pageUrls,
    required this.tags,
    required this.readed,
  });

  factory NovelMeta.create() {
    return NovelMeta(
      title: 'Untitled',
      author: 'Unknown',
      mc: 'Unknown',
      desc: '',
      otherTitleList: [],
      isAdult: false,
      isCompleted: false,
      pageUrls: [],
      tags: [],
      readed: 0,
    );
  }

  static Future<NovelMeta> fromPath(String novelPath) async {
    final metaFile = File(pathJoin(novelPath, metaName));

    if (metaFile.existsSync()) {
      final source = await metaFile.readAsString();
      if (source.isEmpty) return NovelMeta.create();
      return NovelMeta.fromMap(jsonDecode(source));
    } else {
      // read old files
      return await _getOldConfig(novelPath);
    }
  }

  Future<void> save(String novelPath) async {
    final metaFile = File(pathJoin(novelPath, metaName));
    final contents = jsonEncode(toMap());
    await metaFile.writeAsString(contents);
  }

  static List<String> _getListFromString(String value) {
    if (value.isNotEmpty) {
      return value.split(',');
    }
    return [];
  }

  NovelMeta copyWith({
    String? title,
    String? author,
    String? translator,
    String? mc,
    String? desc,
    List<String>? otherTitleList,
    bool? isAdult,
    bool? isCompleted,
    List<String>? pageUrls,
    List<String>? tags,
    int? readed,
  }) {
    return NovelMeta(
      title: title ?? this.title,
      author: author ?? this.author,
      translator: translator ?? this.translator,
      mc: mc ?? this.mc,
      desc: desc ?? this.desc,
      otherTitleList: otherTitleList ?? this.otherTitleList,
      isAdult: isAdult ?? this.isAdult,
      isCompleted: isCompleted ?? this.isCompleted,
      pageUrls: pageUrls ?? this.pageUrls,
      tags: tags ?? this.tags,
      readed: readed ?? this.readed,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'title': title,
      'author': author,
      'translator': translator,
      'mc': mc,
      'desc': desc,
      'otherTitleList': otherTitleList,
      'isAdult': isAdult,
      'isCompleted': isCompleted,
      'pageUrls': pageUrls,
      'tags': tags,
      'readed': readed,
    };
  }

  factory NovelMeta.fromMap(Map<String, dynamic> map) {
    return NovelMeta(
      title: map['title'] as String,
      author: map['author'] as String,
      translator: map['translator'] != null
          ? map['translator'] as String
          : null,
      mc: map['mc'] as String,
      desc: map['desc'] as String,
      otherTitleList: List<String>.from((map['otherTitleList'] ?? [])),
      isAdult: map['isAdult'] as bool,
      isCompleted: map['isCompleted'] as bool,
      pageUrls: List<String>.from((map['pageUrls'] ?? [])),
      tags: List<String>.from((map['tags'] ?? [])),
      readed: map['readed'] as int,
    );
  }

  static Future<NovelMeta> _getOldConfig(String novelPath) async {
    final authorFile = File(pathJoin(novelPath, 'author'));
    final readedFile = File(pathJoin(novelPath, 'readed'));
    final translatorFile = File(pathJoin(novelPath, 'translator'));
    final mcFile = File(pathJoin(novelPath, 'mc'));
    final isAdultFile = File(pathJoin(novelPath, 'is-adult'));
    final isCompletedFile = File(pathJoin(novelPath, 'is-completed'));
    final descFile = File(pathJoin(novelPath, 'content'));
    final pageUrlsFile = File(pathJoin(novelPath, 'link'));
    final tagsFile = File(pathJoin(novelPath, 'tags'));

    int readed = 0;
    final title = novelPath.getName();
    if (readedFile.existsSync()) {
      readed = int.tryParse(await readedFile.readAsString()) ?? 0;
    }
    final meta = NovelMeta(
      title: title,
      author: authorFile.existsSync()
          ? await authorFile.readAsString()
          : 'Unknown',
      mc: mcFile.existsSync() ? await mcFile.readAsString() : 'Unknown',
      translator: translatorFile.existsSync()
          ? await translatorFile.readAsString()
          : null,
      desc: descFile.existsSync() ? await descFile.readAsString() : '',
      otherTitleList: [],
      isAdult: isAdultFile.existsSync(),
      isCompleted: isCompletedFile.existsSync(),
      pageUrls: pageUrlsFile.existsSync()
          ? _getListFromString(await pageUrlsFile.readAsString())
          : [],
      tags: tagsFile.existsSync()
          ? _getListFromString(await tagsFile.readAsString())
          : [],
      readed: readed,
    );
    // delete
    if (mcFile.existsSync()) {
      await mcFile.delete();
    }
    if (readedFile.existsSync()) {
      await readedFile.delete();
    }
    if (authorFile.existsSync()) {
      await authorFile.delete();
    }
    if (translatorFile.existsSync()) {
      await translatorFile.delete();
    }
    if (isAdultFile.existsSync()) {
      await isAdultFile.delete();
    }
    if (isCompletedFile.existsSync()) {
      await isCompletedFile.delete();
    }
    if (descFile.existsSync()) {
      await descFile.delete();
    }
    if (pageUrlsFile.existsSync()) {
      await pageUrlsFile.delete();
    }
    if (tagsFile.existsSync()) {
      await tagsFile.delete();
    }
    await meta.save(novelPath);

    return meta;
  }
}
