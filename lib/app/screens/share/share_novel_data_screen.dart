import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:novel_v3/app/constants.dart';
import 'package:novel_v3/app/services/novel_services.dart';
import 'package:novel_v3/app/services/t_server.dart';
import 'package:novel_v3/app/utils/path_util.dart';
import 'package:novel_v3/app/widgets/my_scaffold.dart';
import 'package:than_pkg/than_pkg.dart';

class ShareNovelDataScreen extends StatefulWidget {
  const ShareNovelDataScreen({super.key});

  @override
  State<ShareNovelDataScreen> createState() => _ShareNovelDataScreenState();
}

class _ShareNovelDataScreenState extends State<ShareNovelDataScreen> {
  bool isServerRunning = false;
  String hostAddress = 'localhost';
  HttpServer? _httpServer;
  List<String> wifiList = [];

  @override
  void initState() {
    _startServer();
    super.initState();
  }

  void _startServer() async {
    try {
      final server = await TServer.instance.startServer();
      _httpServer = server.httpServer;
      //get wifi
      try {
        final res = await ThanPkg.platform.getWifiAddressList();
        setState(() {
          wifiList = res;
        });
      } catch (e) {
        debugPrint('getWifilist: ${e.toString()}');
      }
      //send all novel list
      server.get('/', (req) async {
        try {
          final novelList =
              await getNovelListFromPath(sourcePath: getSourcePath());
          final ml = novelList.map((nv) => nv.toMap()).toList();
          req.response
            ..headers.contentType = ContentType.json
            ..write(const JsonEncoder.withIndent('  ').convert(ml))
            ..close();
        } catch (e) {
          req.response
            ..statusCode = HttpStatus.internalServerError
            ..write(e.toString())
            ..close();
        }
      });

      //cover file download
      server.get('/download', (req) async {
        try {
          String path = req.uri.queryParameters['path'] ?? '';
          final file = File(path);

          if (path.isEmpty || !file.existsSync()) {
            req.response
              ..statusCode = HttpStatus.notFound
              ..write('file not found!')
              ..close();
            return;
          }

          try {
            await file.openRead().pipe(req.response);
          } catch (e) {
            debugPrint("Error sending file: $e");
            req.response.statusCode = HttpStatus.internalServerError;
            req.response.write("Error reading file");
            await req.response.close();
          }
        } catch (e) {
          req.response
            ..statusCode = HttpStatus.internalServerError
            ..write("Error sending file")
            ..close();
        }
      });
      //novel dir list
      server.get('/list', (req) {
        String path = req.uri.queryParameters['dir'] ?? '';
        final dir = Directory(path);
        if (path.isEmpty || !dir.existsSync()) {
          req.response
            ..statusCode = HttpStatus.notFound
            ..write('dir is empty')
            ..close();
          return;
        }
        // ရှိနေရင်
        List<File> fl = [];
        for (final file in dir.listSync()) {
          if (file.statSync().type == FileSystemEntityType.directory) {
            continue;
          }
          fl.add(File(file.path));
        }
        final ml = fl
            .map((f) => {
                  'name': getBasename(f.path),
                  'path': f.path,
                  'size': f.statSync().size,
                  'date': f.statSync().modified.millisecondsSinceEpoch,
                })
            .toList();
        req.response
          ..headers.contentType = ContentType.json
          ..write(const JsonEncoder.withIndent('  ').convert(ml))
          ..close();
      });

      setState(() {
        isServerRunning = true;
      });

      //android address
      if (wifiList.isNotEmpty) {
        hostAddress = wifiList.first;
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _stopServer({bool force = false}) async {
    try {
      if (_httpServer == null) return;
      //close server
      _httpServer!.close(force: force);

      setState(() {
        isServerRunning = false;
      });
    } catch (e) {
      debugPrint('stopServer: ${e.toString()}');
    }
  }

  @override
  void dispose() {
    _stopServer(force: true);
    super.dispose();
  }

  Widget _getWifiListWidget() {
    if (wifiList.isEmpty) {
      return Container();
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const ScrollPhysics(),
      itemCount: wifiList.length,
      itemBuilder: (context, index) => Center(
        child: Text(
          wifiList[index],
          style: TextStyle(
            color: Colors.teal[900],
          ),
        ),
      ),
      separatorBuilder: (context, index) => const Divider(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      appBar: AppBar(
        title: const Text('Novel Data မျှဝေခြင်း'),
      ),
      body: Center(
        child: Column(
          spacing: 5,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            wifiList.isNotEmpty ? const Text('Active Wifi List') : Container(),
            wifiList.isNotEmpty ? const Divider() : Container(),
            //wifi list
            _getWifiListWidget(),
            const Divider(),
            //status
            isServerRunning
                ? SelectableText(
                    'Server Running on http://$hostAddress:$serverPort')
                : Container(),
            Text(
              isServerRunning ? 'Stop Server' : 'Start Server',
              style: TextStyle(
                color: isServerRunning ? Colors.green : Colors.red,
              ),
            ),
            IconButton(
              onPressed: () {
                if (isServerRunning) {
                  _stopServer();
                } else {
                  _startServer();
                }
              },
              icon: Icon(isServerRunning ? Icons.pause : Icons.play_arrow),
            ),
          ],
        ),
      ),
    );
  }
}
