import 'dart:async';
import 'dart:isolate';

import 'package:novel_v3/app/models/chapter_model.dart';
import 'package:novel_v3/app/models/novel_model.dart';
import 'package:novel_v3/app/services/novel_services.dart';
import 'package:novel_v3/app/utils/path_util.dart';

enum PortType {
  error,
  success,
}

//novel
Future<List<NovelModel>> getNovelListFromPathIsolate() async {
  final completer = Completer<List<NovelModel>>();
  try {
    final receivePort = ReceivePort();

    await Isolate.spawn(
        _getNovelListFromPath, [receivePort.sendPort, getSourcePath()]);

    receivePort.listen((data) {
      if (data is Map) {
        String type = data['type'] ?? '';
        if (type == PortType.error.name) {
          completer.completeError(Exception(data['msg']));
          receivePort.close();
        }
        if (type == PortType.success.name) {
          completer.complete(data['data']);
          receivePort.close();
        }
      }
    });
  } catch (e) {
    completer.completeError(e.toString());
  }
  return completer.future;
}

//chapter
Future<List<ChapterModel>> getChapterListFromPathIsolate(
    {required String novelSourcePath}) async {
  final receivePort = ReceivePort();
  final completer = Completer<List<ChapterModel>>();
  //send isolate
  await Isolate.spawn(
      _getChapterListFromPath, [receivePort.sendPort, novelSourcePath]);
  receivePort.listen((data) {
    if (data is Map) {
      String type = data['type'] ?? '';
      if (type == PortType.error.name) {
        String msg = data['msg'] ?? '';
        completer.completeError(msg);
        receivePort.close();
      }
      if (type == PortType.success.name) {
        completer.complete(data['data']);
        receivePort.close();
      }
    }
  });
  return completer.future;
}

//isolate
void _getChapterListFromPath(List<Object> args) {
  SendPort sendPort = args[0] as SendPort;
  String novelSourcePath = args[1] as String;

  getChapterListFromPath(
    novelSourcePath: novelSourcePath,
    onSuccess: (chapterList) async {
      sendPort.send({'type': PortType.success.name, 'data': chapterList});
    },
    onError: (err) {
      sendPort.send({'type': PortType.error.name, 'msg': err});
    },
  );
}

//novel
void _getNovelListFromPath(List<Object> args) async {
  final sendPort = args[0] as SendPort;
  final sourcePath = args[1] as String;
  try {
    final novelList = await getNovelListFromPath(sourcePath: sourcePath);

    sendPort.send({'type': PortType.success.name, 'data': novelList});
  } catch (e) {
    sendPort.send({'type': PortType.error.name, 'msg': e.toString()});
  }
}
