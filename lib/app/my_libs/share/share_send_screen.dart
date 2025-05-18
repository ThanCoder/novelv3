import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:novel_v3/app/components/core/app_components.dart';
import 'package:novel_v3/app/constants.dart';
import 'package:novel_v3/app/services/index.dart';
import 'package:novel_v3/app/services/novel_services.dart';
import 'package:novel_v3/app/my_libs/share/share_file.dart';
import 'package:novel_v3/app/utils/path_util.dart';
import 'package:t_server/t_server.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';



class ShareSendScreen extends StatefulWidget {
  const ShareSendScreen({super.key});

  @override
  State<ShareSendScreen> createState() => _ShareSendScreenState();
}

class _ShareSendScreenState extends State<ShareSendScreen> {
  @override
  void initState() {
    super.initState();
    hostController.text = 'localhost';
    portController.text = '$serverPort';
    init();
  }

  @override
  void dispose() {
    TServer.instance.stopServer(force: true);
    ThanPkg.platform.toggleKeepScreen(isKeep: false);
    super.dispose();
  }

  final hostController = TextEditingController();
  final portController = TextEditingController();
  String statusText = 'Send All';
  bool isServerRunning = false;
  List<String> wifiList = [];

  void init() async {
    try {
      ThanPkg.platform.toggleKeepScreen(isKeep: true);
    } catch (e) {
      debugPrint(e.toString());
    }
    _start();
  }

  void _start() async {
    try {
      final port = int.parse(portController.text);
      await TServer.instance.startServer(port: port);
      if (!mounted) return;
      setState(() {
        isServerRunning = true;
        statusText = 'Server is Running...';
      });
      _sendData();
      _showHostFields();
    } catch (e) {
      if (!mounted) return;
      showDialogMessage(context, e.toString());
    }
  }

  void _stop() async {
    try {
      await TServer.instance.stopServer(force: true);
      if (!mounted) return;
      setState(() {
        isServerRunning = false;
        statusText = 'Server is Stopped';
      });
    } catch (e) {
      if (!mounted) return;
      showDialogMessage(context, e.toString());
    }
  }

  Future<String> _getThumbnailPath(String path) async {
    var thumbnailPath = defaultIconAssetsPath;
    final file = File(path);
    if (file.existsSync()) {
      thumbnailPath = await PathUtil.getAssetRealPathPath('file.png');
    }
    //check config
    if (file.getName().endsWith('.json') ||
        file.getName().startsWith('author') ||
        file.getName().startsWith('content') ||
        file.getName().startsWith('link') ||
        file.getName().startsWith('readed') ||
        file.getName().startsWith('mc')) {
      return await PathUtil.getAssetRealPathPath('config.png');
    }

    if (file.getName().endsWith('.json')) {
      return await PathUtil.getAssetRealPathPath('fav.png');
    }
    if (file.getName().endsWith('.pdf')) {
      return await PathUtil.getAssetRealPathPath('pdf.png');
    }
    if (file.getName().endsWith('.cover') || file.getName().endsWith('.png')) {
      return file.path;
    }
    return thumbnailPath;
  }

  void _sendData() async {
    try {
      final list = await NovelServices.instance.getList(isFullInfo: true);
      //send data
      TServer.instance.get('/', (req) {
        final queryTitle = req.uri.queryParameters['title'] ?? '';
        if (queryTitle.isNotEmpty) {
          final res = list.where((nv) => nv.title == queryTitle);
          // မရှိရင်
          if (res.isEmpty) {
            tServerSend(
              req,
              httpStatus: HttpStatus.notFound,
              body: 'file not found!',
            );
            return;
          }
          //ရှိနေရင်
          tServerSend(
            req,
            contentType: ContentType.json,
            body: const JsonEncoder.withIndent(' ').convert(res.first.toMap()),
          );
          return;
        }
        final data = list.map((nv) => nv.toMap()).toList();
        tServerSend(
          req,
          contentType: ContentType.json,
          body: const JsonEncoder.withIndent(' ').convert(data),
        );
      });

      //send file
      TServer.instance.get('/download', (req) async {
        final path = req.uri.queryParameters['path'] ?? '';
        // path is empty
        if (path.isEmpty) {
          tServerSend(
            req,
            httpStatus: HttpStatus.notFound,
            body: '`path` is empty',
          );
          return;
        }
        final file = File(path);
        // not found
        if (!file.existsSync()) {
          tServerSend(
            req,
            httpStatus: HttpStatus.notFound,
            body: '`$path` not found!',
          );
          return;
        }
        // send file
        // tServerSendFile(req, file.path);
        req.response.headers
          ..set(HttpHeaders.contentTypeHeader, 'application/octet-stream')
          ..set(HttpHeaders.contentLengthHeader, file.lengthSync());
        await file.openRead().pipe(req.response);
      });
      //send thumbnail
      TServer.instance.get('/thumbnail', (req) async {
        final path = req.uri.queryParameters['path'] ?? '';
        var thumbnailPath = await _getThumbnailPath(path);

        final thumbnail = File(thumbnailPath);
        // send thumbnail
        req.response.headers
          ..set(HttpHeaders.contentTypeHeader, 'image/png')
          ..set(HttpHeaders.contentLengthHeader, thumbnail.lengthSync());
        //send file
        await thumbnail.openRead().pipe(req.response);
      });

      //send files list
      TServer.instance.get('/files', (req) {
        final path = req.uri.queryParameters['path'] ?? '';
        // path is empty
        if (path.isEmpty) {
          tServerSend(
            req,
            httpStatus: HttpStatus.notFound,
            body: '`path` is empty',
          );
          return;
        }
        final dir = Directory(path);
        // not found
        if (!dir.existsSync()) {
          tServerSend(
            req,
            httpStatus: HttpStatus.notFound,
            body: 'dir `$path` not found!',
          );
          return;
        }
        // send files
        final pathList = dir.listSync().map((file) => file.path).toList();
        final files = pathList
            .map((path) => ShareFile.fromPath(path))
            .map((f) => f.toMap)
            .toList();

        tServerSend(
          req,
          contentType: ContentType.json,
          body: const JsonEncoder.withIndent(' ').convert(files),
        );
      });
    } catch (e) {
      debugPrint('_sendData: ${e.toString()}');
    }
  }

  void _showHostFields() async {
    try {
      wifiList = await ThanPkg.platform.getWifiAddressList();
      if (wifiList.isNotEmpty) {
        hostController.text = wifiList.first;
      }
      if (!mounted) return;
      setState(() {});
    } catch (e) {
      debugPrint('_showHostFields: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Screen'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 7,
            children: [
              const Text('Server Config'),
              TTextField(
                controller: hostController,
                label: const Text('Host Address'),
                maxLines: 1,
                isSelectedAll: true,
              ),
              TTextField(
                controller: portController,
                label: const Text('PORT'),
                textInputType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLines: 1,
              ),
              const Divider(),
              Text(statusText),
              IconButton(
                color: isServerRunning ? Colors.red : Colors.green,
                iconSize: 30,
                onPressed: () {
                  if (isServerRunning) {
                    _stop();
                  } else {
                    _start();
                  }
                },
                icon: Icon(isServerRunning ? Icons.stop : Icons.send),
              ),
              // show wifi list
              wifiList.isEmpty
                  ? const SizedBox()
                  : const Text('အသုံးပြုနိုင်သော host များ'),
              wifiList.isEmpty
                  ? const SizedBox()
                  : Column(
                      children: List.generate(
                        wifiList.length,
                        (index) {
                          return ListTile(
                            title: Text(wifiList[index]),
                            onLongPress: () {
                              copyText(wifiList[index]);
                            },
                          );
                        },
                      ),
                    )
            ],
          ),
        ),
      ),
    );
  }
}
