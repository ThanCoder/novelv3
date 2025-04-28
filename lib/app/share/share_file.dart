// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:novel_v3/app/extensions/file_system_entity_extension.dart';
import 'package:novel_v3/app/extensions/string_extension.dart';
import 'package:novel_v3/app/share/share_file_type.dart';

class ShareFile {
  String path;
  String name;
  ShareFileType type;
  int size;
  int date;

  bool isExists = false;
  ShareFile({
    required this.path,
    required this.name,
    required this.size,
    required this.date,
    required this.type,
  });

  factory ShareFile.fromPath(String path) {
    final name = path.getName();
    var type = ShareFileType.unknownFile;

    final file = File(path);
    final size = file.statSync().size;
    final date = file.statSync().modified.millisecondsSinceEpoch;

    if (name.endsWith('.json') ||
        name.endsWith('mc') ||
        name.endsWith('author') ||
        name.endsWith('readed') ||
        name.endsWith('link') ||
        name.endsWith('content')) {
      type = ShareFileType.config;
    }

    if (name.endsWith('.pdf')) {
      type = ShareFileType.pdf;
    }
    if (name.endsWith('png') || name.endsWith('cover.png')) {
      type = ShareFileType.cover;
    }
    // check chapter
    if (int.tryParse(name) != null) {
      type = ShareFileType.chapter;
    }
    return ShareFile(
      path: path,
      name: name,
      size: size,
      type: type,
      date: date,
    );
  }

  String getParentName() {
    final parent = File(path).parent;
    return parent.getName();
  }

  factory ShareFile.fromMap(Map<String, dynamic> map) {
    var type = ShareFileType.unknownFile;
    if (map['type'] != null) {
      final ty = map['type'] ?? '';
      type = ShareFileTypeExtension.getTypeFromString(ty);
    }
    return ShareFile(
      path: map['path'],
      name: map['name'],
      size: map['size'],
      date: map['date'],
      type: type,
    );
  }

  Map<String, dynamic> get toMap => {
        'name': name,
        'path': path,
        'type': type.name,
        'size': size,
        'date': date,
      };

  @override
  String toString() {
    return name;
  }
}
