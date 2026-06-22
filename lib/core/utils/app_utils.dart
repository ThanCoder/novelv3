import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';

class AppUtils {
  static AppUtils instance = AppUtils._();
  AppUtils._();
  factory AppUtils() => instance;

  late String cachePath;

  Future<void> init() async {
    try {
      final cacheP = await getApplicationCacheDirectory();
      cachePath = cacheP.path;
    } catch (e) {
      debugPrint('[AppUtils:init]: $e');
    }
  }
}
