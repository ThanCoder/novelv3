typedef JsonDBList = List<dynamic>;

class JsonData {}

class JsonDb {
  static Future<void> setList({
    required String dbFilePath,
    required JsonData jsonData,
  }) async {}
  static Future<JsonDBList> getList({required String dbFilePath}) async {
    return [];
  }
}
