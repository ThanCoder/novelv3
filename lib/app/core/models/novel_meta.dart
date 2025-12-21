// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:io';

import 'package:flutter/rendering.dart';
import 'package:hb_db/hb_db.dart';
import 'package:than_pkg/than_pkg.dart';
import 'package:uuid/uuid.dart';

class NovelMetaAdapter extends HBAdapter<NovelMeta> {
  @override
  NovelMeta fromMap(Map<String, dynamic> map) {
    return NovelMeta.fromMap(map);
  }

  @override
  int getUniqueFieldId() {
    return 2;
  }

  @override
  Map<String, dynamic> toMap(NovelMeta value) {
    return value.toMap();
  }
}

class NovelMeta {
  static final String metaName = 'meta.json';
  final String id;
  final String title;
  final String author;
  final String translator;
  final String mc;
  final String desc;
  final List<String> otherTitleList;
  final bool isAdult;
  final bool isCompleted;
  final List<String> pageUrls;
  final List<String> tags;
  final int readed;
  final String originalTitle;
  final String englishTitle;
  final DateTime date;
  NovelMeta({
    required this.id,
    required this.title,
    required this.author,
    required this.translator,
    required this.mc,
    required this.desc,
    required this.otherTitleList,
    required this.isAdult,
    required this.isCompleted,
    required this.pageUrls,
    required this.tags,
    required this.readed,
    required this.originalTitle,
    required this.englishTitle,
    required this.date,
  });

  factory NovelMeta.createEmpty() {
    return NovelMeta.create();
  }

  factory NovelMeta.create({String title = 'Untitled', String? id}) {
    return NovelMeta(
      id: id ?? Uuid().v4(),
      title: title,
      originalTitle: '',
      englishTitle: '',
      author: 'Unknown',
      mc: 'Unknown',
      translator: 'Unknown',
      desc: '',
      otherTitleList: [],
      isAdult: false,
      isCompleted: false,
      pageUrls: [],
      tags: [],
      readed: 0,
      date: DateTime.now(),
    );
  }

  static Future<NovelMeta> fromPath(String novelPath) async {
    final metaFile = File(pathJoin(novelPath, metaName));
    final novelDir = Directory(novelPath);

    if (metaFile.existsSync()) {
      final source = await metaFile.readAsString();
      if (source.isEmpty) return NovelMeta.create(title: novelPath.getName());
      return NovelMeta.fromMap(
        jsonDecode(source),
        novelDirMiliDateNumber: novelDir.getDate.millisecondsSinceEpoch,
      );
    } else {
      // read old files
      return await _getOldConfig(novelPath);
    }
  }

  Future<void> save(String novelPath) async {
    try {
      final metaFile = File(pathJoin(novelPath, metaName));
      final contents = jsonEncode(toMap());
      await metaFile.writeAsString(contents);
    } catch (e) {
      debugPrint('[NovelMeta:save]: $e');
    }
  }

  static List<String> _getListFromString(String value) {
    if (value.isNotEmpty) {
      return value.split(',');
    }
    return [];
  }

  factory NovelMeta.fromMap(
    Map<String, dynamic> map, {
    int novelDirMiliDateNumber = 0,
  }) {
    final id = map.getString(['id'], def: Uuid().v4());
    final date = map.getInt(['date'], def: novelDirMiliDateNumber);
    final otherTitleList = map['otherTitleList'] ?? [];
    final pageUrls = map['pageUrls'] ?? [];
    final tags = map['tags'] ?? [];
    return NovelMeta(
      id: id,
      title: map['title'] as String,
      author: map['author'] as String,
      translator: map['translator'] as String,
      mc: map['mc'] as String,
      desc: map['desc'] as String,
      otherTitleList: List<String>.from(otherTitleList),
      isAdult: map['isAdult'] as bool,
      isCompleted: map['isCompleted'] as bool,
      pageUrls: List<String>.from(pageUrls),
      tags: List<String>.from(tags),
      readed: map['readed'] as int,
      originalTitle: map.getString(['originalTitle']),
      englishTitle: map.getString(['englishTitle']),
      date: DateTime.fromMillisecondsSinceEpoch(date),
      //get from novel folder -> date
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
    final dirName = novelPath.getName();
    if (readedFile.existsSync()) {
      readed = int.tryParse(await readedFile.readAsString()) ?? 0;
    }
    final meta = NovelMeta(
      id: Uuid().v4(),
      title: dirName,
      originalTitle: '',
      englishTitle: '',
      author: authorFile.existsSync()
          ? await authorFile.readAsString()
          : 'Unknown',
      mc: mcFile.existsSync() ? await mcFile.readAsString() : 'Unknown',
      translator: translatorFile.existsSync()
          ? await translatorFile.readAsString()
          : '',
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
      date: DateTime.now(),
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

  NovelMeta copyWith({
    String? id,
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
    String? originalTitle,
    String? englishTitle,
    DateTime? date,
  }) {
    return NovelMeta(
      id: id ?? this.id,
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
      originalTitle: originalTitle ?? this.originalTitle,
      englishTitle: englishTitle ?? this.englishTitle,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
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
      'originalTitle': originalTitle,
      'englishTitle': englishTitle,
      'date': date.millisecondsSinceEpoch,
    };
  }
}
