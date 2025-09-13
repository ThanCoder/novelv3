import 'dart:io';

import 'package:than_pkg/than_pkg.dart';

class ShareDirFile {
  String name;
  String path;
  String mime;
  String size;
  DateTime date;
  ShareDirFile({
    required this.name,
    required this.path,
    required this.mime,
    required this.size,
    required this.date,
  });

  factory ShareDirFile.fromFile(FileSystemEntity file) {
    return ShareDirFile(
      name: file.getName(),
      path: file.path,
      mime: lookupMimeType(file.path) ?? '',
      size: file.getSizeLabel(),
      date: file.getDate,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'path': path,
      'mime': mime,
      'size': size,
      'date': date.millisecondsSinceEpoch,
    };
  }

  factory ShareDirFile.fromMap(Map<String, dynamic> map) {
    return ShareDirFile(
      name: map['name'] as String,
      path: map['path'] as String,
      mime: map['mime'] as String,
      size: map['size'] as String,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
    );
  }

  // get
  bool get isChapterFile {
    return int.tryParse(name) != null;
  }

  bool get isConfigFile {
    if (name == 'readed' ||
        name == 'mc' ||
        name == 'content' ||
        name == 'author' ||
        name == 'translator' ||
        name == 'tags' ||
        name == 'link' ||
        name.endsWith('json')) {
      return true;
    }
    return false;
  }
}
