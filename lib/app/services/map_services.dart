class MapServices {
  static String getString(dynamic mapValue, {String defaultValue = ''}) {
    return mapValue ?? defaultValue;
  }

  static double getDouble(
    dynamic mapValue, {
    double defaultValue = 0.0,
  }) {
    final res = mapValue;
    if (res == null) return defaultValue;
    if (res is String) {
      if (double.tryParse(res) != null) {
        return double.parse(res);
      }
    }
    if (res is int) {
      return res.toDouble();
    }
    return res;
  }

  static int getInt(
    dynamic mapValue, {
    int defaultValue = 0,
  }) {
    final res = mapValue;
    if (res == null) return defaultValue;
    if (res is String) {
      if (int.tryParse(res) != null) {
        return int.parse(res);
      }
    }
    if (res is double) {
      return res.toInt();
    }
    return res;
  }

  static T get<T>(
    Map<String, dynamic> map,
    List<String> keys, {
    required T defaultValue,
  }) {
    dynamic current = map;
    for (var key in keys) {
      if (current is Map<String, dynamic> && current.containsKey(key)) {
        current = map[key];
      } else {
        return defaultValue;
      }
    }
    if (T == String && current is int) {
      current = int.parse(current as String);
    }
    if (T == String && current is double) {
      current = double.parse(current as String);
    }
    if (T == int && current is String) {
      current = int.parse(current);
    }
    if (T == double && current is String) {
      current = double.parse(current);
    }
    return current is T ? current : defaultValue;
  }
}
