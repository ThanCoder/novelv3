import 'dart:convert';

import 'data_io.dart';
import 'converter.dart';

abstract class DBStrategy<T> {
  final DataIO io;
  final String path;
  final MapConverter<T> converter;

  DBStrategy(this.io, this.path, this.converter);

  Future<void> save(List<T> list, {bool isPretty = true}) async {
    final jsonList = list.map((e) => converter.to(e)).toList();
    await io.write(path, JsonEncoder.withIndent(' ').convert(jsonList));
  }

  Future<List<T>> load() async {
    final json = await io.read(path);
    if (json.isEmpty) return [];
    List<dynamic> jsonList = jsonDecode(json);
    return jsonList.map((e) => converter.from(e)).toList();
  }
}
