import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:novel_v3/more_libs/general_static_server/general_server.dart';

import 'database.dart';

abstract class ApiDatabase<T> extends Database<T> {
  ApiDatabase({required super.root});

  T from(Map<String, dynamic> map);
  String getId(T value);
  final List<T> _list = [];

  @override
  Future<List<T>> getAll({Map<String, dynamic>? query}) async {
    if (_list.isNotEmpty) return _list;

    try {
      final res = await GeneralServer.instance.getContentFromUrl(root);

      List<dynamic> jsonList = jsonDecode(res);
      _list.clear();
      final resList = jsonList.map((map) => from(map)).toList();
      _list.addAll(resList);
    } catch (e) {
      debugPrint('[ApiDatabase:getAll]: ${e.toString()}');
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

  @override
  Future<T> add(T value) {
    throw UnimplementedError();
  }

  @override
  Future<bool> update(String id, T value) {
    throw UnimplementedError();
  }

  @override
  Future<int> delete(String id) {
    throw UnimplementedError();
  }
}
