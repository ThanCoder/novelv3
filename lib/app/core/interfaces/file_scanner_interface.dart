import 'dart:io';
import 'dart:isolate';

abstract class FileScannerInterface<T> {
  void onError(String message);
  Future<T?> onParseFile(FileSystemEntity file);

  Future<List<T>> getList(String path) async {
    return await Isolate.run<List<T>>(() async {
      List<T> list = [];
      try {
        final dir = Directory(path);
        if (!dir.existsSync()) {
          onError('[not found!]: $path');
          return list;
        }
        // found
        for (var file in dir.listSync(followLinks: false)) {
          final res = await onParseFile(file);
          if (res == null) continue;
          list.add(res);
          // // dir မဟုတ်ရင် ကျော်မယ်
          // if (file.statSync().type != FileSystemEntityType.directory) continue;
          // // dir ပဲယူမယ်
          // final T = T.fromPath(file.path);
          // if (isAllCalc) {
          //   // တွက်ပြီးထည့်မယ်
          //   final descLines = await File(T.getContentPath).readAsLines();
          //   T.cacheIsExistsDesc = descLines.isNotEmpty;
          //   // calc all size
          //   T.cacheSize = await T.getAllSize();
          // }
          // list.add(T);
        }
        // sort
      } catch (e) {
        onError(e.toString());
      }
      return list;
    });
  }
}
