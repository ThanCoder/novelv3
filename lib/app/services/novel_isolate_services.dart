import 'dart:async';
import 'dart:io';
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
    String sourcePath = getSourcePath();
    final list = Isolate.run<List<NovelModel>>(() {
      List<NovelModel> novelList = [];
      final dir = Directory(sourcePath);
      if (dir.existsSync()) {
        for (final file in dir.listSync()) {
          if (file.statSync().type == FileSystemEntityType.directory) {
            novelList.add(NovelModel.fromPath(file.path));
          }
        }
      }
      //sort
      novelList.sort((a, b) {
        return a.date.compareTo(b.date) == 1 ? -1 : 1;
      });
      return novelList;
    });
    completer.complete(list);
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
