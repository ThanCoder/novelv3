import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../constants.dart';
import '../../utils/path_util.dart';

class DioServices {
  static final DioServices instance = DioServices._();
  DioServices._();
  factory DioServices() => instance;

  final _dio = Dio();

  Future<String> getForwardProxyHtml(String url) async {
    try {
      final res = await getDio.get(getForwardProxyUrl(url));

      return res.data.toString();
    } catch (e) {
      debugPrint('getForwardProxy: ${e.toString()}');
      return '';
    }
  }

  String getForwardProxyUrl(String targetUrl) {
    return '$appForwardProxyHostUrl?url=$targetUrl';
  }

  Future<String> getBrowsesrProxyHtml(String url) async {
    try {
      final res = await getDio.get('$appBrowserProxyHostUrl?url=$url');
      return res.data.toString();
    } catch (e) {
      debugPrint('getBrowsesrProxyHtml: ${e.toString()}');
      return '';
    }
  }

  Future<void> downloadCover({
    required String url,
    required String savePath,
  }) async {
    try {
      if (url.isEmpty) return;

      final cacheFile = File(savePath);
      if (await cacheFile.exists()) return;
      //မရှိရင်
      await getDio.download(url, savePath);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<String> getCacheHtml({
    required String url,
    required String cacheName,
    bool isOverride = false,
  }) async {
    var res = '';
    try {
      if (url.isEmpty) return res;
      final savePath = '${PathUtil.instance.getCachePath()}/$cacheName.html';
      final cacheFile = File(savePath);
      if (!isOverride && await cacheFile.exists()) {
        res = await cacheFile.readAsString();
        return res;
      }
      //မရှိရင်
      final result = await getDio.get(url);
      await cacheFile.writeAsString(result.data.toString());
      res = result.data.toString();
    } catch (e) {
      debugPrint(e.toString());
    }
    return res;
  }

  Future<int?> getContentSize(String url) async {
    try {
      var response = await getDio.head(url);
      return int.tryParse(response.headers.value('content-length') ?? '0');
    } catch (e) {
      return null;
    }
  }

  Dio get getDio {
    // if (appConfigNotifier.value.isUseProxyServer) {
    //   final proxyAddress = appConfigNotifier.value.proxyAddress;
    //   final proxyPort = appConfigNotifier.value.proxyPort;
    //   _dio.httpClientAdapter = IOHttpClientAdapter(
    //     createHttpClient: () {
    //       final client = HttpClient();
    //       client.findProxy = (uri) {
    //         // return "PROXY 192.168.191.253:8081";
    //         return "PROXY $proxyAddress:$proxyPort";
    //       };
    //       return client;
    //     },
    //   );
    // }
    return _dio;
  }
}
