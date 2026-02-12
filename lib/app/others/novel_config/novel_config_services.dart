import 'dart:convert';
import 'dart:io';

import 'package:novel_v3/core/models/novel_meta.dart';
import 'package:than_pkg/extensions/file_system_entity_extension.dart';

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
