import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:than_pkg/t_database/index.dart';

import 'database.dart';

abstract class JsonDatabase<T> extends Database<T> {
  JsonDatabase({required super.root, this.isUseCacheList = true});
  final JsonIO io = JsonIO.instance;
  final bool isUseCacheList;

  T from(Map<String, dynamic> map);
  Map<String, dynamic> to(T value);
  String getId(T value);
  final List<T> _list = [];

  @override
  Future<List<T>> getAll({Map<String, dynamic>? query}) async {
    try {
      if (isUseCacheList && _list.isNotEmpty) return _list;
      final source = await io.read(root);

      if (source.isEmpty) return [];
      List<dynamic> jsonList = jsonDecode(source);
      // print(jsonList[0]);
      _list.clear();
      final res = jsonList.map((map) => from(map)).toList();
      _list.addAll(res);
    } catch (e) {
      debugPrint('[JsonDatabase:getAll]:${e.toString()}');
    }
    return _list;
  }

  @override
  Future<T> add(T value) async {
    final list = await getAll();
    list.add(value);
    await save(list);
    notify(DatabaseChangedListenerTypes.add, getId(value));
    return value;
  }

  @override
  Future<T?> getById(String id) async {
    final list = await getAll();
    final index = list.indexWhere((e) => getId(e) == id);
    if (index == -1) return null;
    return list[index];
  }

  @override
  Future<int> delete(String id) async {
    final list = await getAll();
    final index = list.indexWhere((e) => getId(e) == id);
    if (index == -1) return index;
    list.removeAt(index);
    return index;
  }

  @override
  Future<bool> update(String id, T value) async {
    final list = await getAll();
    final index = list.indexWhere((e) => getId(e) == id);
    if (index == -1) return false;
    list[index] = value;
    notify(DatabaseChangedListenerTypes.update, id);
    await save(list, id: id);
    return true;
  }

  Future<void> save(List<T> list, {String? id}) async {
    final jsonList = list.map((e) => to(e)).toList();
    final content = JsonEncoder.withIndent(' ').convert(jsonList);
    await io.write(root, content);
    notify(DatabaseChangedListenerTypes.save, id);
  }
}
