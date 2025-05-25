import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:archive/archive_io.dart';
import 'package:flutter/material.dart';
import 'package:novel_v3/app/constants.dart';
import 'package:novel_v3/app/models/novel_data_model.dart';
import 'package:novel_v3/app/services/core/android_app_services.dart';
import 'package:novel_v3/app/utils/path_util.dart';
import 'package:than_pkg/than_pkg.dart';

class NovelDataServices {
  static final NovelDataServices instance = NovelDataServices._();
  NovelDataServices._();
  factory NovelDataServices() => instance;

  // import
  static Future<Isolate> importIsolate(
    String path, {
    required String saveDir,
    bool isAlreadyExistsOverride = false,
    bool isConfigFilesAdd = false,
    required void Function(double progress, String message) onProgress,
    required void Function() onDone,
    required void Function(String msg) onError,
  }) async {
    final receivePort = ReceivePort();

    final isolate = await Isolate.spawn(_import, [
      receivePort.sendPort,
      path,
      saveDir,
      isAlreadyExistsOverride,
      isConfigFilesAdd,
    ]);
    receivePort.listen((data) {
      if (data is Map) {
        // is progress
        final type = data['type'] ?? '';
        if (type == 'progress') {
          onProgress(data['progress'] as double, data['message'] as String);
        }
        if (type == 'success') {
          receivePort.close();
          onDone();
        }
        if (type == 'error') {
          receivePort.close();
          onError(data['message']);
        }
      }
    });
    return isolate;
  }

  // export
  static Future<Isolate> exportIsolate(
    String novelPath, {
    required void Function(double progress, String message) onProgress,
    required void Function(String savedPath) onDone,
    required void Function(String msg) onError,
  }) async {
    final receivePort = ReceivePort();
    final outPath = PathUtil.getOutPath();

    final isolate = await Isolate.spawn(_export, [
      receivePort.sendPort,
      novelPath,
      outPath,
    ]);
    receivePort.listen((data) {
      if (data is Map) {
        // is progress
        final type = data['type'] ?? '';
        if (type == 'progress') {
          onProgress(data['progress'] as double, data['message'] as String);
        }
        if (type == 'success') {
          receivePort.close();
          onDone(data['message']);
        }
        if (type == 'error') {
          receivePort.close();
          onError(data['message']);
        }
      }
    });
    return isolate;
  }

  static void _import(List<Object> args) async {
    final sendPort = args[0] as SendPort;

    try {
      final filePath = args[1] as String;
      final savePath = args[2] as String;
      final isAlreadyExistsOverride = args[3] as bool;
      final isConfigFilesAdd = args[4] as bool;

      // Read the ZIP file
      final zipFile = File(filePath);
      if (!zipFile.existsSync()) {
        sendPort.send({'message': 'path:`$filePath` မရှိပါ!', 'type': 'error'});
        return;
      }
      final bytes = await zipFile.readAsBytes();
      String novelDir = '';

      // Decode the archive
      final archive = ZipDecoder().decodeBytes(bytes);

      //progress
      // onProgress(archive.files.length, 0, "Preparing...");
      sendPort.send({
        'type': 'progress',
        'progress': 0.0,
        'message': 'Preparing...',
      });

      // Extract the files
      int i = 1;
      for (final file in archive) {
        final name = file.name.getName();
        final filePath = '$savePath/$name';

        //progress
        // onProgress(archive.files.length, i, "${file.name} ထည့်သွင်းနေပါတယ်...");
        sendPort.send({
          'type': 'progress',
          'progress': (i / archive.files.length).toDouble(),
          'message': name,
        });

        if (file.isFile) {
          // Write the file content
          final outFile = File(filePath);
          //is skip
          if (!isAlreadyExistsOverride && outFile.existsSync()) {
            continue;
          }
          //config file skip
          if (!isConfigFilesAdd) {
            if (name.endsWith('.json') || name == 'readed') {
              continue;
            }
          }

          await outFile.writeAsBytes(file.content as List<int>);
        } else {
          // Create the directory
          // Directory(filePath).createSync(recursive: true);
          // novelDir = '$sourcePath/$filePath';
        }

        i++;
        // await Future.delayed(const Duration(milliseconds: 400));
      }

      //done
      sendPort.send({
        'type': 'success',
        'message': novelDir,
      });
    } catch (e) {
      sendPort.send({
        'type': 'error',
        'message': e.toString(),
      });
    }
  }

  static void _export(List<Object> args) async {
    final sendPort = args[0] as SendPort;
    try {
      final novelPath = args[1] as String;
      final outPath = args[2] as String;

      if (!Directory(novelPath).existsSync()) {
        sendPort.send({
          'type': 'error',
          'message': 'မရှိပါ! : path:$novelPath',
        });
        return;
      }
      //progress
      // onProgress(0, 0, "Preparing...");
      sendPort.send({
        'type': 'progress',
        'progress': 0.0,
        'message': 'Preparing...',
      });

      // Create an archive object
      final archive = Archive();
      final String novelTitle = novelPath.getName();

      // Recursively add files and subfolders to the archive
      Future<void> addFolderToArchive(
          String folderPath, String basePath) async {
        final directory = Directory(folderPath);
        final res = directory.listSync(recursive: true);
        int i = 1;
        for (final entity in res) {
          if (entity is File) {
            //progress
            sendPort.send({
              'type': 'progress',
              'progress': (i / res.length).toDouble(),
              'message': '${entity.getName()}...',
            });
            //delay
            // await Future.delayed(const Duration(milliseconds: 300));

            // Read file bytes
            final fileBytes = entity.readAsBytesSync();

            // Get relative path for the file (to preserve folder structure)
            // final relativePath = entity.path.substring(basePath.length + 1);
            final relativePath =
                '$novelTitle/${PathUtil.getBasename(entity.path)}';

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
      await addFolderToArchive(novelPath, novelPath);

      // Encode the archive as a ZIP file
      final zipEncoder = ZipEncoder();
      final zipData = zipEncoder.encode(archive);

      //add novel directory title
      archive.add(ArchiveFile.directory(novelTitle));

      // Write the ZIP file
      final outputFile = File('$outPath/$novelTitle.$novelDataExtName');
      outputFile.writeAsBytesSync(zipData);

      //done
      sendPort.send({
        'type': 'success',
        'message': outputFile.path,
      });
    } catch (e) {
      sendPort.send({
        'type': 'error',
        'message': e.toString(),
      });
    }
  }

//data scanner
  Future<List<NovelDataModel>> dataScanner() async {
    final dirs = await getScanDirPathList();
    final filterPaths = getScanFilteringPathList();
    //
    final cachePath = PathUtil.getCachePath();

    return await Isolate.run<List<NovelDataModel>>(() async {
      List<NovelDataModel> list = [];
      // inner function
      void scanDir(Directory dir) async {
        try {
          // if (await dir.exists())
          for (var file in dir.listSync()) {
            //hidden skip
            if (file.path.getName().startsWith('.')) continue;

            if (file.statSync().type == FileSystemEntityType.directory) {
              scanDir(Directory(file.path));
            }
            if (file.statSync().type != FileSystemEntityType.file) continue;
            if (filterPaths.contains(file.path.getName())) continue;

            // final mime = lookupMimeType(file.path) ?? '';
            // if (!mime.startsWith('application/zip')) continue;
            //add pdf
            if (!isNovelData(file.path)) continue;
            //add
            final name = file.path.getName(withExt: false);
            final novelData = NovelDataModel.fromPath(
              file.path,
              coverPath: '$cachePath/$name.png',
            );

            //add list
            list.add(novelData);
          }
        } catch (e) {
          debugPrint(e.toString());
        }
      }

      for (var path in dirs) {
        final dir = Directory(path);
        if (!dir.existsSync()) continue;
        scanDir(dir);
      }
      //sort
      list.sort((a, b) {
        if (a.date > b.date) return -1;
        if (a.date < b.date) return 1;
        return 0;
      });

      return list;
    });
  }

  static bool isNovelData(String path) {
    return path.endsWith('.$novelDataExtName');
  }

  //get dir name
  static Future<String?> getNovelTitle(String path) async {
    final zipFile = File(path);
    if (!zipFile.existsSync()) return null;
    final bytes = zipFile.readAsBytesSync();

    final archive = ZipDecoder().decodeBytes(bytes);
    String? title;

    for (final file in archive) {
      if (file.name.endsWith('/')) {
        title = file.name.replaceAll('/', '');
      } else {
        final f = File(file.name);
        title = f.parent.path.getName().replaceAll('/', '');
      }
      break;
    }
    return title;
  }

//gen cover
  Future<void> genCover({required List<NovelDataModel> list}) async {
    await Isolate.run(() {
      try {
        for (final data in list) {
          // Read the ZIP file
          final zipFile = File(data.path);
          if (!zipFile.existsSync()) continue;
          final bytes = zipFile.readAsBytesSync();

          final archive = ZipDecoder().decodeBytes(bytes);

          for (final file in archive) {
            if (file.name.endsWith('cover.png')) {
              final coverFile = File(data.coverPath);
              if (!coverFile.existsSync()) {
                coverFile.writeAsBytesSync(file.content);
              }
              break;
            }
          }
        }
      } catch (e) {
        debugPrint(e.toString());
      }
    });
  }

//novel data check isAdult
  bool dataCheckIsAdult({required String dataFilePath}) {
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
    } catch (e) {
      debugPrint(e.toString());
    }
    return res;
  }

//novel data check isAdult
  bool dataCheckIsCompleted({required String dataFilePath}) {
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
    } catch (e) {
      debugPrint(e.toString());
    }
    return res;
  }

//novel data check isAdult
  String dataGetTitleFromPath({required String dataFilePath}) {
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
    } catch (e) {
      debugPrint(e.toString());
    }
    return res;
  }
}
