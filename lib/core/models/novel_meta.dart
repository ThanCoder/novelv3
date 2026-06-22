// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:io';

import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';

class NovelMeta {
  final String id;
  final String title;
  final String author;
  final String mc;
  final String translator;
  final int readed;
  final bool isAdult;
  final bool isCompleted;
  final int date;
  final List<String> otherTitleList;
  final List<String> pageUrls;
  final List<String> tags;
  final String desc;
  const NovelMeta({
    required this.id,
    required this.title,
    required this.author,
    required this.translator,
    required this.readed,
    required this.isAdult,
    required this.isCompleted,
    required this.date,
    required this.otherTitleList,
    required this.pageUrls,
    required this.tags,
    required this.desc,
    required this.mc,
  });

  static NovelMeta? fromPath(String path) {
    final metaFile = File(join(path, 'meta.json'));
    if (!metaFile.existsSync()) return null;
    try {
      final res = jsonDecode(metaFile.readAsStringSync());
      return NovelMeta.fromMap(Map<String, dynamic>.from(res));
    } catch (e) {
      debugPrint('[NovelMeta::fromPath]: $e');
      return null;
    }
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'author': author,
      'mc': mc,
      'translator': translator,
      'readed': readed,
      'isAdult': isAdult,
      'isCompleted': isCompleted,
      'date': date,
      'otherTitleList': otherTitleList,
      'pageUrls': pageUrls,
      'tags': tags,
      'desc': desc,
    };
  }

  factory NovelMeta.fromMap(Map<String, dynamic> map) {
    return NovelMeta(
      id: map['id'] as String,
      title: map['title'] as String,
      author: map['author'] as String,
      mc: map.getString(['mc']),
      translator: map['translator'] as String,
      readed: map['readed'] ?? 0,
      isAdult: map['isAdult'] ?? false,
      isCompleted: map['isCompleted'] ?? false,
      date: map['date'] as int,
      otherTitleList: map.getStringList(['otherTitleList']),
      pageUrls: map.getStringList(['pageUrls']),
      tags: map.getStringList(['tags']),
      desc: map['desc'] as String,
    );
  }

  NovelMeta copyWith({
    String? id,
    String? title,
    String? author,
    String? mc,
    String? translator,
    int? readed,
    bool? isAdult,
    bool? isCompleted,
    int? date,
    List<String>? otherTitleList,
    List<String>? pageUrls,
    List<String>? tags,
    String? desc,
  }) {
    return NovelMeta(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      mc: mc ?? this.mc,
      translator: translator ?? this.translator,
      readed: readed ?? this.readed,
      isAdult: isAdult ?? this.isAdult,
      isCompleted: isCompleted ?? this.isCompleted,
      date: date ?? this.date,
      otherTitleList: otherTitleList ?? this.otherTitleList,
      pageUrls: pageUrls ?? this.pageUrls,
      tags: tags ?? this.tags,
      desc: desc ?? this.desc,
    );
  }
}
