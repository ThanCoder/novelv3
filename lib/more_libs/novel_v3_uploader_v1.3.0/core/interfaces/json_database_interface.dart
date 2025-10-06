import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:than_pkg/t_database/data_io.dart';

import 'database_interface.dart';

abstract class JsonDatabaseInterface<T> extends DatabaseInterface<T> {
  final JsonIO io;

  JsonDatabaseInterface({required super.root, required super.storage})
    : io = JsonIO.instance;

  Map<String, dynamic> toMap(T value);
  T fromMap(Map<String, dynamic> map);
  Future<String> getDBContent(String sourceRoot);
  String getId(T value);

  List<T> _list = [];

  @override
  Future<List<T>> getAll({Map<String, dynamic> query = const {}}) async {
    try {
      if (_list.isNotEmpty) {
        return _list;
      }
      final content = await getDBContent(root);
      // print(content);
      List<dynamic> mapList = jsonDecode(content);
      _list = mapList.map((map) => fromMap(map)).toList();
    } catch (e) {
      debugPrint('[JsonDatabaseInterface:getAll]: ${e.toString()}');
    }
    return _list;
  }

  @override
  Future<T?> getById(String id) async {
    final list = await getAll();
    final index = list.indexWhere((e) => getId(e) == id);
    if (index == -1) return null;
    return list[index];
  }

  Future<void> save(String sourceRoot, List<T> list) async {
    final data = list.map((e) => toMap(e)).toList();
    await io.write(sourceRoot, JsonEncoder.withIndent(' ').convert(data));
    notify(null, DatabaseListenerTypes.saved);
  }

  @override
  Future<void> add(T value) async {
    final list = await getAll();
    list.insert(0, value);
    notify(null, DatabaseListenerTypes.added);
    await save(root, list);
  }

  @override
  Future<void> delete(String id) async {
    final list = await getAll();
    final index = list.indexWhere((e) => getId(e) == id);
    if (index == -1) return;
    list.removeAt(index);
    notify(id, DatabaseListenerTypes.deleted);
    await save(root, list);
  }

  @override
  Future<void> update(String id, T value) async {
    final list = await getAll();
    final index = list.indexWhere((e) => getId(e) == id);
    if (index == -1) return;
    list[index] = value;
    notify(id, DatabaseListenerTypes.update);
    await save(root, list);
  }

  @override
  Future<T?> getOne({Map<String, dynamic> query = const {}}) {
    // TODO: implement getOne
    throw UnimplementedError();
  }
}
