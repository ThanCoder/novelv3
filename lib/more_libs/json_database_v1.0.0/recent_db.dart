// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:than_pkg/than_pkg.dart';

class RecentDB {
  static RecentDB? _instance;
  static Future<RecentDB> getInstance({required String dbPath}) async {
    _instance ??= RecentDB(dbPath);
    return _instance!;
  }

  final String dbPath;
  Map<String, dynamic> _db = {};

  RecentDB(this.dbPath) {
    _init();
  }
  void _init() async {
    _db = await _getDB;
  }

  // get
  String getString(String key, {String def = ''}) {
    return _db.getString([key], def: def);
  }
  int getInt(String key, {int def = 0}) {
    return _db.getInt([key], def: def);
  }
  double getDouble(String key, {double def = 0.0}) {
    return _db.getDouble([key], def: def);
  }
  bool getBool(String key, {bool def = false}) {
    return _db.getBool([key], def: def);
  }

  // set
  Future<void> setString(String key, String value) async {
    _db[key] = value;
    await _save();
  }

  Future<void> setInt(String key, int value) async {
    _db[key] = value;
    await _save();
  }

  Future<void> setDouble(String key, double value) async {
    _db[key] = value;
    await _save();
  }

  Future<void> setBool(String key, bool value) async {
    _db[key] = value;
    await _save();
  }

  Future<Map<String, dynamic>> get _getDB async {
    // if (_db.isNotEmpty) return _db;
    final file = File(dbPath);
    if (!file.existsSync()) return {};
    try {
      final json = jsonDecode(await file.readAsString());
      return Map<String, dynamic>.from(json);
    } catch (e) {
      debugPrint('[RecentDB:_getDB]: ${e.toString()}');
    }
    return {};
  }

  Future<void> _save() async {
    final file = File(dbPath);
    final json = JsonEncoder.withIndent(' ').convert(_db);
    await file.writeAsString(json);
  }
}
