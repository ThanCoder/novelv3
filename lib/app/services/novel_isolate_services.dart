import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:novel_v3/app/models/novel_model.dart';
import 'package:novel_v3/app/utils/path_util.dart';

enum PortType {
  error,
  success,
}

//novel
Future<List<NovelModel>> getNovelListFromPathIsolate() async {
  final completer = Completer<List<NovelModel>>();
  try {
    String sourcePath = PathUtil.instance.getSourcePath();
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
