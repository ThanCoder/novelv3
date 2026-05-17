import 'dart:convert';
import 'dart:io';

import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:novel_v3/core/models/novel_meta.dart';

class NovelConfigServices {
  static Future<NovelMeta?> getNovelMetaFromPath(String path) async {
    final file = File(path);
    if (!file.existsSync()) return null;
    final name = file.getName();
    if (!name.endsWith('.meta.json')) return null;

    final json = jsonDecode(await file.readAsString());
    return NovelMeta.fromMap(json);
  }
}
