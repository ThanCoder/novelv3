// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';
import 'dart:isolate';

enum PathScannerTest { add, skip }

abstract class PathScanner {
  final List<String> scanFolders;
  PathScanner({required this.scanFolders});
  bool isExcluded(FileSystemEntity file, String name) => name.startsWith('.');
  PathScannerTest onFolderTest(FileSystemEntity file, String name) =>
      PathScannerTest.add;
  PathScannerTest onFileTest(FileSystemEntity file, String name);

  Future<List<FileSystemEntity>> scan() async {
    return Isolate.run(() {
      final list = <FileSystemEntity>[];
      for (var path in scanFolders) {
        final subDirs = [Directory(path)];
        while (subDirs.isNotEmpty) {
          final currentDir = subDirs.removeLast();

          final dirList = currentDir.listSync(followLinks: false);
          for (var file in dirList) {
            final name = file.path.split(Platform.pathSeparator).last;
            if (isExcluded(file, name)) continue;

            // folder ကိုစစ်တာ
            if (file.statSync().type == FileSystemEntityType.directory) {
              final res = onFolderTest(file, name);
              if (res == .add) {
                subDirs.add(Directory(file.path));
              }
              if (res == .skip) continue;
            }
            // file
            if (file.statSync().type == FileSystemEntityType.file) {
              if (onFileTest(file, name) == .add) {
                list.add(file);
              }
            }
          }
        }
      }
      return list;
    });
  }
}
