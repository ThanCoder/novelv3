import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:novel_v3/app/core/interfaces/index.dart';
import 'package:than_pkg/than_pkg.dart';

abstract class JsonDatabase<T> extends Database<T> {
  final JsonIO io = JsonIO.instance;

  JsonDatabase({required super.root}) : super(storage: FileStorage(root: ''));

  T from(Map<String, dynamic> map);
  Map<String, dynamic> to(T value);
  String getId(T value);

  final List<T> _list = [];

  @override
  Future<void> add(T value) async {
    final list = await getAll();
    list.add(value);
    notify(DatabaseListenerEvent.add, id: getId(value));
    await save(list);
  }

  @override
  Future<void> update(String id, T value) async {
    final list = await getAll();
    final index = list.indexWhere((e) => getId(e) == id);
    if (index == -1) return;
    list[index] = value;
    notify(DatabaseListenerEvent.update, id: id);
    await save(list, id: id);
  }

  @override
  Future<void> delete(String id) async {
    final list = await getAll();
    final index = list.indexWhere((e) => getId(e) == id);
    if (index == -1) return;
    list.removeAt(index);
    notify(DatabaseListenerEvent.delete, id: id);
    await save(list, id: id);
  }

  @override
  Future<T?> getById({required String id}) async {
    final list = await getAll();
    final index = list.indexWhere((e) => getId(e) == id);
    if (index == -1) return null;
    return list[index];
  }

  @override
  Future<List<T>> getAll({Map<String, dynamic>? query}) async {
    query ??= {};

    final isUsedCache = query.getBool(['isUsedCache']);
    if (isUsedCache && _list.isNotEmpty) {
      return _list;
    }

    final file = File(root);
    List<T> list = [];
    if (!file.existsSync()) return list;
    final source = await file.readAsString();
    if (source.isEmpty) return list;
    try {
      List<dynamic> jsonList = jsonDecode(source);
      list = jsonList.map((e) => from(e)).toList();
      _list.addAll(list);
    } catch (e) {
      debugPrint(e.toString());
    }
    return list;
  }

  Future<void> save(List<T> list, {String? id}) async {
    final file = File(root);
    final jsonList = list.map((e) => to(e)).toList();
    await file.writeAsString(JsonEncoder.withIndent(' ').convert(jsonList));
    notify(DatabaseListenerEvent.saved, id: id);
  }
}
