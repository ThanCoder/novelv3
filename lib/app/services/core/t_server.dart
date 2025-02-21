// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:novel_v3/app/constants.dart';

class _Listener {
  String url;
  String method;
  void Function(HttpRequest req) onRequest;
  _Listener({
    required this.url,
    required this.method,
    required this.onRequest,
  });
}

class TServer {
  static final TServer instance = TServer._internal();
  TServer._internal();

  late HttpServer httpServer;
  void Function(String msg)? onError;
  final List<_Listener> _listenerList = [];

  Future<TServer> startServer({
    int port = serverPort,
    bool shared = true,
  }) async {
    try {
      _listenerList.clear();
      httpServer = await HttpServer.bind(
        InternetAddress.anyIPv4,
        serverPort,
        shared: shared,
      );
      httpServer.listen(_onListen);
    } catch (e) {
      if (onError != null) {
        onError!(e.toString());
      }
    }
    return this;
  }

  void _onListen(HttpRequest req) {
    final method = req.method;
    final url = req.uri.path;
    for (final _listener in _listenerList) {
      if (_listener.method == method && _listener.url == url) {
        _listener.onRequest(req);
        return;
      }
    }

    // No matching route, return 404 response
    req.response
      ..statusCode = HttpStatus.notFound
      ..write('404 Not Found')
      ..close();
  }

  void get(String url, void Function(HttpRequest req) onReq) {
    _listenerList.add(_Listener(url: url, method: 'GET', onRequest: onReq));
  }

  // void post(String url, void Function(HttpRequest req) onReq) {
  //   _listenerList.add(_Listener(url: url, method: 'POST', onRequest: onReq));
  // }
}
