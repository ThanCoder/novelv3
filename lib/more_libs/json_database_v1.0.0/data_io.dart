import 'dart:io';

abstract class DataIO {
  Future<void> write(String source, String data);
  Future<String> read(String source);
}

class JsonIO implements DataIO {
  static final JsonIO instance = JsonIO._();
  JsonIO._();
  factory JsonIO() => instance;

  @override
  Future<void> write(String path, String json) async {
    final file = File(path);
    await file.writeAsString(json);
  }

  @override
  Future<String> read(String path) async {
    final file = File(path);
    if (!file.existsSync()) return '';
    return await file.readAsString();
  }
}
