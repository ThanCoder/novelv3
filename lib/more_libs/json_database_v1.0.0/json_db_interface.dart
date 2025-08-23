import 'dart:convert';

import 'database_listener.dart';
import 'data_io.dart';

abstract class JsonDBInterface<T> {
  final DataIO io;
  final String path;

  T fromMap(Map<String, dynamic> map);
  Map<String, dynamic> toMap(T value);
  // ကြိုပေးထား

  JsonDBInterface(this.io, this.path);

  Future<void> save(List<T> list, {bool isPretty = true}) async {
    final jsonList = list.map((e) => toMap(e)).toList();
    await io.write(path, JsonEncoder.withIndent(' ').convert(jsonList));
  }

  Future<List<T>> load() async {
    final json = await io.read(path);
    if (json.isEmpty) return [];
    List<dynamic> jsonList = jsonDecode(json);
    return jsonList.map((e) => fromMap(e)).toList();
  }

  Future<List<T>> get() async {
    return await load();
  }

  Future<void> add(T value) async {
    final list = await get();
    list.add(value);
    await save(list);
    notify(value);
  }

  Future<void> update(int index, T value) async {
    final list = await get();
    list[index] = value;
    await save(list);
    notify(value);
  }

  Future<void> delete(int index, T value) async {
    final list = await get();
    list.removeAt(index);
    await save(list);
    notify(value);
  }

  // listener
  // 🔔 listener list
  final List<DatabaseListener<T>> _listeners = [];

  // register/unregister methods
  void addListener(DatabaseListener<T> listener) {
    _listeners.add(listener);
  }

  void removeListener(DatabaseListener<T> listener) {
    _listeners.remove(listener);
  }

  void notify(T? value) {
    for (final listener in _listeners) {
      listener.onChanged(value);
    }
  }
}
