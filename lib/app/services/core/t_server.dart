import 'dart:io';

import 'package:flutter/cupertino.dart';

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

class _SocketListener {
  String url;
  void Function(HttpRequest req, WebSocket socket) onListen;
  _SocketListener({
    required this.url,
    required this.onListen,
  });
}

class TServer {
  static final TServer instance = TServer._internal();
  TServer._internal();

  late HttpServer _httpServer;
  void Function(String msg)? onError;
  final List<_Listener> _listenerList = [];
  final List<_SocketListener> _webSocktetlistenerList = [];

  Future<TServer> startServer({
    int port = 3300,
    bool shared = true,
  }) async {
    try {
      //all clear
      _listenerList.clear();
      _webSocktetlistenerList.clear();

      _httpServer = await HttpServer.bind(
        InternetAddress.anyIPv4,
        port,
        shared: shared,
      );
      _httpServer.listen(_onListen);
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
    //for websocket
    if (WebSocketTransformer.isUpgradeRequest(req)) {
      _handleWebSocket(req);
      return;
    }
    //for http
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

  //set listener
  void get(String url, void Function(HttpRequest req) onReq) {
    _listenerList.add(_Listener(url: url, method: 'GET', onRequest: onReq));
  }

  //post
  void post(String url, void Function(HttpRequest req) onReq) {
    _listenerList.add(_Listener(url: url, method: 'POST', onRequest: onReq));
  }

  //delete
  void delete(String url, void Function(HttpRequest req) onReq) {
    _listenerList.add(_Listener(url: url, method: 'DELETE', onRequest: onReq));
  }

  //put
  void put(String url, void Function(HttpRequest req) onReq) {
    _listenerList.add(_Listener(url: url, method: 'PUT', onRequest: onReq));
  }

  //websocket set listener
  void onSocket(
      String url, void Function(HttpRequest http, WebSocket socket) onListen) {
    final socketListener = _SocketListener(
      url: url,
      onListen: onListen,
    );
    _webSocktetlistenerList.add(socketListener);
  }

  //web socket
  void _handleWebSocket(HttpRequest req) async {
    try {
      final url = req.uri.path;
      for (final _listener in _webSocktetlistenerList) {
        if (_listener.url == url) {
          final socket = await WebSocketTransformer.upgrade(req);
          _listener.onListen(req, socket);
          return;
        }
      }

      // No matching route, return 404 response
      req.response
        ..statusCode = HttpStatus.notFound
        ..write('404 Not Found')
        ..close();
    } catch (e) {
      if (onError != null) {
        onError!('websocket: ${e.toString()}');
      }
    }
  }

  //send body
  void send(
    HttpRequest req, {
    String body = 'new route',
    ContentType? contentType,
    int httpStatus = 200,
  }) {
    contentType ??= ContentType.text;
    req.response
      ..statusCode = httpStatus
      ..write(body)
      ..close();
  }

  //send file
  Future<void> sendFile(HttpRequest req, String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      req.response
        ..statusCode = HttpStatus.notFound
        ..write('File Not Found')
        ..close();
      return;
    }
    final name = file.path.split('/').last;
    final encodedFileName = Uri.encodeComponent(name);
    //file ရှိရင်
    req.response.headers
      ..set(HttpHeaders.contentTypeHeader, 'application/octet-stream')
      ..set(HttpHeaders.contentLengthHeader, file.lengthSync())
      ..set(HttpHeaders.contentDisposition,
          'attachment;filename*=UTF-8' '$encodedFileName');
    req.response.headers.chunkedTransferEncoding = false;

    //send file
    // await file.openRead().pipe(req.response);
    // Stream buffer ကိုအသုံးပြုပြီး file data ပို့
    final stream = file.openRead();
    try {
      await stream.pipe(req.response);
    } catch (e) {
      debugPrint('Error sending file: $e');
    } finally {
      await req.response.close();
    }
  }

  //stop server
  Future<void> stopServer({bool force = false}) async {
    try {
      _httpServer.close(force: force);
    } catch (e) {}
  }
}
