import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/material.dart';

class UploaderConfigServices {
  static Future<void> setConfig(
    Map<String, dynamic> map, {
    String dbName = 'main.db.json',
    bool isPrettyJson = false,
  }) async {
    final fpath = File('${Directory.current.path}/server/$dbName');
    await Isolate.run(() async {
      try {
        String content = jsonEncode(map);
        if (isPrettyJson) {
          content = JsonEncoder.withIndent(' ').convert(map);
        }
        fpath.writeAsStringSync(content);
      } catch (e) {
        debugPrint('UploaderServices:setConfig -> ${e.toString()}');
      }
    });
  }

  static Future<Map<String, dynamic>> getConfig({
    String dbName = 'main.db.json',
    bool isPrettyJson = false,
  }) async {
    final fpath = File('${Directory.current.path}/server/$dbName');
    if (!fpath.existsSync()) {
      return {};
    }
    return await Isolate.run(() async {
      String content = fpath.readAsStringSync();
      return jsonDecode(content) as Map<String, dynamic>;
    });
  }

  // list config
  static Future<void> setListConfig(
    List<Map<String, dynamic>> mapList, {
    String dbName = 'main.db.json',
    bool isPrettyJson = false,
  }) async {
    final fpath = File('${Directory.current.path}/server/$dbName');
    await Isolate.run(() async {
      try {
        String content = jsonEncode(mapList);
        if (isPrettyJson) {
          content = JsonEncoder.withIndent(' ').convert(mapList);
        }
        fpath.writeAsStringSync(content);
      } catch (e) {
        debugPrint('UploaderServices:setConfig -> ${e.toString()}');
      }
    });
  }

  static Future<List<dynamic>> getListConfig({
    String dbName = 'main.db.json',
    bool isPrettyJson = false,
  }) async {
    final fpath = File('${Directory.current.path}/server/$dbName');
    if (!fpath.existsSync()) {
      return [];
    }
    return await Isolate.run(() async {
      String content = fpath.readAsStringSync();
      List<dynamic> mapList = jsonDecode(content);
      return mapList;
    });
  }
}
