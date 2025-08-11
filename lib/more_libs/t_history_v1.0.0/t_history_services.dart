import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/material.dart';

import 't_history_record.dart';

class THistoryServices {
  static final THistoryServices instance = THistoryServices._();
  THistoryServices._();
  factory THistoryServices() => instance;

  String? path;
  bool _showDebug = false;
  void init(String dbPath, {bool showDebugLog = false}) {
    path = dbPath;
    _showDebug = showDebugLog;
  }

  Future<void> add(THistoryRecord record) async {
    try {
      final list = await getList();
      list.insert(0, record);
      //save
      final data = list.map((e) => e.toMap).toList();
      await _getDBFile.writeAsString(jsonEncode(data));
    } catch (e) {
      if (_showDebug) {
        debugPrint(e.toString());
      }
    }
  }

  Future<void> delete() async {
    if (await _getDBFile.exists()) {
      await _getDBFile.delete();
    }
  }

  Future<List<THistoryRecord>> getList() async {
    if (!await _getDBFile.exists()) return [];

    return await Isolate.run<List<THistoryRecord>>(() async {
      List<THistoryRecord> list = [];

      try {
        List<dynamic> resList = jsonDecode(await _getDBFile.readAsString());
        list = resList.map((map) => THistoryRecord.fromMap(map)).toList();
      } catch (e) {
        if (_showDebug) {
          debugPrint(e.toString());
        }
      }

      return list;
    });
  }

  File get _getDBFile {
    if (path == null) {
      throw Exception('Usage `THistoryServices.instance.init!`');
    }
    return File(path ?? '');
  }
}
