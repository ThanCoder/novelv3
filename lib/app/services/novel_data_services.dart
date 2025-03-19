import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:archive/archive_io.dart';
import 'package:flutter/material.dart';
import 'package:novel_v3/app/constants.dart';
import 'package:novel_v3/app/models/novel_data_model.dart';
import 'package:novel_v3/app/services/core/app_path_services.dart';
import 'package:novel_v3/app/utils/path_util.dart';

//isolate
void exportNovelDataIsolate({
  required String folderPath,
  required String outDirPath,
  required void Function(int max, int progress, String title) onProgress,
  required void Function(String filePath) onSuccess,
  required void Function(Object err) onError,
}) async {
  final receivePort = ReceivePort();
  await Isolate.spawn(
      _exportNovelDataIsolate, [receivePort.sendPort, folderPath, outDirPath]);

  receivePort.listen((data) {
    if (data is Map) {
      String type = data['type'];
      if (type == 'err') {
        onError(data['msg']);
        receivePort.close();
      }
      if (type == 'succ') {
        onSuccess(data['path']);
        receivePort.close();
      }
      if (type == 'progress') {
        String title = data['title'];
        int max = data['max'];
        int progress = data['progress'];
        onProgress(max, progress, title);
      }
    }
  });
}

void importNovelDataIsolate({
  required String filePath,
  required String outDirPath,
  required void Function(String novelPath) onSuccess,
  required void Function(int max, int progress, String title) onProgress,
  required void Function(String err) onError,
}) async {
  final receivePort = ReceivePort();
  await Isolate.spawn(
      _importNovelDataIsolate, [receivePort.sendPort, filePath, outDirPath]);

  receivePort.listen((data) {
    if (data is Map) {
      String type = data['type'];
      if (type == 'err') {
        onError(data['msg']);
        receivePort.close();
      }
      if (type == 'succ') {
        onSuccess(data['path']);
        receivePort.close();
      }
      if (type == 'progress') {
        String title = data['title'];
        int max = data['max'];
        int progress = data['progress'];
        onProgress(max, progress, title);
      }
    }
  });
}

//isolate private
void _exportNovelDataIsolate(List<Object> args) {
  final sendPort = args[0] as SendPort;
  final folderPath = args[1] as String;
  final outDirPath = args[2] as String;

  exportNovelData(
    folderPath: folderPath,
    outDirPath: outDirPath,
    onSuccess: (filePath) {
      sendPort.send({'type': 'succ', 'path': filePath});
    },
    onProgress: (max, progress, title) {
      sendPort.send({
        'type': 'progress',
        'max': max,
        'progress': progress,
        'title': title,
      });
    },
    onError: (err) {
      sendPort.send({'type': 'err', 'msg': err});
    },
  );
}

void _importNovelDataIsolate(List<Object> args) {
  final sendPort = args[0] as SendPort;
  final filePath = args[1] as String;
  final outDirPath = args[2] as String;

  importNovelData(
    filePath: filePath,
    outDirPath: outDirPath,
    onSuccess: (novelPath) {
      sendPort.send({'type': 'succ', 'path': novelPath});
    },
    onProgress: (max, progress, title) {
      sendPort.send({
        'type': 'progress',
        'max': max,
        'progress': progress,
        'title': title,
      });
    },
    onError: (err) {
      sendPort.send({'type': 'err', 'msg': err});
    },
  );
}

void importNovelData({
  required String filePath,
  required String outDirPath,
  required void Function(String novelPath) onSuccess,
  required void Function(int max, int progress, String title) onProgress,
  required void Function(String err) onError,
}) {
  try {
    // Read the ZIP file
    final zipFile = File(filePath);
    if (!zipFile.existsSync()) throw Exception('မရှိပါ! path:$filePath');
    final bytes = zipFile.readAsBytesSync();
    String novelDir = '';

    // Decode the archive
    final archive = ZipDecoder().decodeBytes(bytes);

    //progress
    onProgress(archive.files.length, 0, "Preparing...");

    // Extract the files
    int i = 1;
    for (final file in archive) {
      final filePath = '$outDirPath/${file.name}';

      //progress
      onProgress(archive.files.length, i, "${file.name} ထည့်သွင်းနေပါတယ်...");

      if (file.isFile) {
        // Write the file content
        final outFile = File(filePath)..createSync(recursive: true);
        outFile.writeAsBytesSync(file.content as List<int>);
      } else {
        // Create the directory
        Directory(filePath).createSync(recursive: true);
        novelDir = '$outDirPath/$filePath';
      }

      i++;
    }
    onSuccess(novelDir);
  } catch (e) {
    onError(e.toString());
    debugPrint('importNovelData: ${e.toString()}');
  }
}

void exportNovelData({
  required String folderPath,
  required String outDirPath,
  required void Function(int max, int progress, String title) onProgress,
  required void Function(String filePath) onSuccess,
  required void Function(Object err) onError,
}) async {
  try {
    if (!Directory(folderPath).existsSync()) {
      throw Exception('မရှိပါ! : path:$folderPath');
    }
    //progress
    onProgress(0, 0, "Preparing...");

    // Create an archive object
    final archive = Archive();
    final String novelTitle = PathUtil.instance.getBasename(folderPath);

    // Recursively add files and subfolders to the archive
    Future<void> addFolderToArchive(String folderPath, String basePath) async {
      final directory = Directory(folderPath);
      final res = directory.listSync(recursive: true);
      int i = 1;
      for (final entity in res) {
        if (entity is File) {
          //progress
          onProgress(
              res.length, i, "${PathUtil.instance.getBasename(entity.path)} ထည့်သွင်းနေပါတယ်...");
          //delay
          // await Future.delayed(const Duration(milliseconds: 300));

          // Read file bytes
          final fileBytes = entity.readAsBytesSync();

          // Get relative path for the file (to preserve folder structure)
          // final relativePath = entity.path.substring(basePath.length + 1);
          final relativePath = '$novelTitle/${PathUtil.instance.getBasename(entity.path)}';

          //add novel directory title
          final novelFolderArchive = ArchiveFile.directory(novelTitle);

          archive.add(novelFolderArchive);

          // Add file to the archive
          final archiveFile =
              ArchiveFile(relativePath, fileBytes.length, fileBytes);
          archive.addFile(archiveFile);
        }
        i++;
      }
    }

    // Start adding from the folder
    await addFolderToArchive(folderPath, folderPath);

    // Encode the archive as a ZIP file
    final zipEncoder = ZipEncoder();
    final zipData = zipEncoder.encode(archive);

    //add novel directory title
    archive.add(ArchiveFile.directory(novelTitle));

    // Write the ZIP file
    final outputFile = File('$outDirPath/$novelTitle.$novelDataExtName');
    outputFile.writeAsBytesSync(zipData);

    onSuccess(outputFile.path);
  } catch (e) {
    onError(e);
    debugPrint('exportNovelData: ${e.toString()}');
  }
}

//data scanner
Future<List<NovelDataModel>> novelDataScannerIsolate() async {
  final completer = Completer<List<NovelDataModel>>();
  final receivePort = ReceivePort();
  final rootPath = Platform.isLinux
      ? '${getAppExternalRootPath()}/Downloads'
      : getAppExternalRootPath();
  await Isolate.spawn(_novelDataScannerIsolate, [
    receivePort.sendPort,
    rootPath,
    PathUtil.instance.getSourcePath(),
  ]);

  receivePort.listen((data) {
    if (data is Map) {
      String type = data['type'];
      if (type == 'err') {
        completer.completeError(data['msg']);
        receivePort.close();
      }
      if (type == 'succ') {
        completer.complete(data['list']);
        receivePort.close();
      }
    }
  });
  return completer.future;
}

void _novelDataScannerIsolate(List<Object> args) {
  final sendPort = args[0] as SendPort;
  final rootPath = args[1] as String;
  final novelSourceDir = args[2] as String;

  novelDataScanner(
    rootPath: rootPath,
    novelSourceDir: novelSourceDir,
    onSuccess: (dataList) {
      sendPort.send({'type': 'succ', 'list': dataList});
    },
    onError: (msg) {
      sendPort.send({'type': 'err', 'msg': msg});
    },
  );
}

void novelDataScanner({
  required String rootPath,
  required String novelSourceDir,
  required void Function(List<NovelDataModel> novelDataList) onSuccess,
  required void Function(String msg) onError,
}) async {
  try {
    final dir = Directory(rootPath);
    if (!dir.existsSync()) return onSuccess([]);
    List<NovelDataModel> dataList = [];

    Future<void> scanPdfFile(Directory folder) async {
      for (final file in folder.listSync()) {
        String name = PathUtil.instance.getBasename(file.path);
        if (name.startsWith('.') ||
            name.startsWith('Android') ||
            name.startsWith('android-studio') ||
            name.startsWith('AndroidStudioProjects') ||
            name.startsWith('AndroidIDEProjects') ||
            name.startsWith('DCMI')) {
          continue;
        }
        if (file.statSync().type == FileSystemEntityType.directory) {
          scanPdfFile(Directory(file.path));
        }
        if (!file.path.endsWith('.$novelDataExtName')) continue;
        //add
        final novelData = NovelDataModel.fromPath(file.path);

        //add list
        dataList.add(novelData);
      }
    }

    await scanPdfFile(dir);
    //sort
    dataList.sort((a, b) {
      return a.date.compareTo(b.date) == 1 ? -1 : 1;
    });
    onSuccess(dataList);
  } catch (e) {
    onError(e.toString());
    debugPrint('pdfScanner: ${e.toString()}');
  }
}

//gen cover
Future<List<NovelDataModel>> genNovelDataCoverIsolate({
  required List<NovelDataModel> novelDataList,
  required String outDir,
}) async {
  final receivePort = ReceivePort();
  final completer = Completer<List<NovelDataModel>>();

  await Isolate.spawn(
      _genNovelDataCoverIsolate, [receivePort.sendPort, novelDataList, outDir]);

  receivePort.listen((data) {
    if (data is Map) {
      String type = data['type'];
      if (type == 'err') {
        completer.completeError(data['msg']);
        receivePort.close();
      }
      if (type == 'succ') {
        completer.complete(data['list']);
        receivePort.close();
      }
    }
  });
  return completer.future;
}

void _genNovelDataCoverIsolate(List<Object> args) {
  final sendPort = args[0] as SendPort;
  try {
    final novelDataList = args[1] as List<NovelDataModel>;
    final outDir = args[2] as String;

    PathUtil.instance.createDir(outDir);
    int i = 0;
    for (final data in novelDataList) {
      // Read the ZIP file
      final zipFile = File(data.path);
      if (!zipFile.existsSync()) continue;
      final bytes = zipFile.readAsBytesSync();

      final archive = ZipDecoder().decodeBytes(bytes);

      for (final file in archive) {
        if (file.name.endsWith('cover.png')) {
          final dirName = File(file.name).parent.path;
          final coverFile = File('$outDir/$dirName.png');
          if (!coverFile.existsSync()) {
            coverFile.writeAsBytesSync(file.content);
          }
          novelDataList[i].coverPath = coverFile.path;
          novelDataList[i].title = dirName;
          break;
        }
      }
      i++;
    }

    sendPort.send({'type': 'succ', 'list': novelDataList});
  } catch (e) {
    sendPort.send({'type': 'err', 'msg': e.toString()});
  }
}

void genNovelDataCover({
  required String filePath,
  required String outDir,
  required void Function(String coverPath) onSuccess,
  required void Function(String err) onError,
}) {
  try {
    PathUtil.instance.createDir(outDir);
    // Read the ZIP file
    final zipFile = File(filePath);
    if (!zipFile.existsSync()) throw Exception('မရှိပါ! path:$filePath');
    final bytes = zipFile.readAsBytesSync();

    final archive = ZipDecoder().decodeBytes(bytes);

    for (final file in archive) {
      if (file.name.endsWith('cover.png')) {
        final dirName = File(file.name).parent.path;
        final coverFile = File('$outDir/$dirName.png');
        if (!coverFile.existsSync()) {
          coverFile.writeAsBytesSync(file.content);
        }
        onSuccess(coverFile.path);
        break;
      }
    }
  } catch (e) {
    onError(e.toString());
    debugPrint('genNovelDataCover: ${e.toString()}');
  }
}

//novel data check isAdult
bool novelDataCheckIsAdult({required String dataFilePath}) {
  bool res = false;
  try {
    final file = File(dataFilePath);
    if (!file.existsSync()) return false;

    final zipFile = ZipDecoder().decodeBytes(file.readAsBytesSync());
    for (final file in zipFile) {
      if (file.name.endsWith('is-adult')) {
        res = true;
        break;
      }
    }
  } catch (e) {}
  return res;
}

//novel data check isAdult
bool novelDataCheckIsCompleted({required String dataFilePath}) {
  bool res = false;
  try {
    final file = File(dataFilePath);
    if (!file.existsSync()) return false;

    final zipFile = ZipDecoder().decodeBytes(file.readAsBytesSync());
    for (final file in zipFile) {
      if (file.name.endsWith('is-completed')) {
        res = true;
        break;
      }
    }
  } catch (e) {}
  return res;
}

//novel data check isAdult
String novelDataGetTitleFromPath({required String dataFilePath}) {
  String res = '';
  try {
    final file = File(dataFilePath);
    if (!file.existsSync()) return '';

    final zipFile = ZipDecoder().decodeBytes(file.readAsBytesSync());
    for (final file in zipFile) {
      if (file.isDirectory) {
        res = file.name.replaceAll('/', '').trim();
        break;
      }
    }
  } catch (e) {}
  return res;
}
