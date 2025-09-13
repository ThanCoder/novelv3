import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:than_pkg/than_pkg.dart';

import 'database.dart';

abstract class JsonDatabase<T> extends Database<T> {
  final JsonIO io = JsonIO.instance;

  JsonDatabase({required super.root, required super.storage});

  T from(Map<String, dynamic> map);
  Map<String, dynamic> to(T value);

  @override
  Future<void> add(T value) async {
    final list = await getAll();
    list.add(value);
    await save(list);
  }

  @override
  Future<List<T>> getAll() async {
    final file = File(root);
    List<T> list = [];
    if (!file.existsSync()) return list;
    final source = await file.readAsString();
    if (source.isEmpty) return list;
    try {
      List<dynamic> jsonList = jsonDecode(source);
      list = jsonList.map((e) => from(e)).toList();
    } catch (e) {
      debugPrint(e.toString());
    }
    return list;
  }

  Future<void> save(List<T> list) async {
    final file = File(root);
    final jsonList = list.map((e) => to(e)).toList();
    await file.writeAsString(JsonEncoder.withIndent(' ').convert(jsonList));
    notify();
  }
}
