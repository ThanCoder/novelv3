import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:novel_v3/app/services/app_path_services.dart';

T? getRecentDB<T>(String key) {
  T? res;
  try {
    final dbFile = File('${getAppRootPath()}/recent.db.json');
    if (!dbFile.existsSync()) return null;
    //ရှိနေရင်
    Map<String, dynamic> map = jsonDecode(dbFile.readAsStringSync());
    if (map.containsKey(key)) {
      res = map[key] as T;
    }
  } catch (e) {
    debugPrint('getRecentDB: ${e.toString()}');
  }
  return res;
}

void setRecentDB<T>(String key, T value) {
  try {
    final dbFile = File('${getAppRootPath()}/recent.db.json');
    Map<String, dynamic> map = {};
    //ရှိနေရင်
    if (dbFile.existsSync()) {
      map = jsonDecode(dbFile.readAsStringSync());
    }

    map[key] = value;
    final jsondb = const JsonEncoder.withIndent('  ').convert(map);
    dbFile.writeAsStringSync(jsondb);
  } catch (e) {
    debugPrint('setRecentDB: ${e.toString()}');
  }
}

void recentDBClear(String key) {
  try {
    final dbFile = File('${getAppRootPath()}/recent.db.json');
    Map<String, dynamic> map = {};
    //ရှိနေရင်
    if (dbFile.existsSync()) {
      map = jsonDecode(dbFile.readAsStringSync());
    }

    if (map.containsKey(key)) {
      map.remove(key);
    }
    final jsondb = const JsonEncoder.withIndent('  ').convert(map);
    dbFile.writeAsStringSync(jsondb);
  } catch (e) {
    debugPrint('setRecentDB: ${e.toString()}');
  }
}
