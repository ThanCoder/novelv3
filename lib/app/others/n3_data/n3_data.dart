import 'dart:io';
import 'dart:isolate';

import 'package:archive/archive.dart';
import 'package:novel_v3/app/others/n3_data/constants.dart';
import 'package:novel_v3/more_libs/setting/core/path_util.dart';
import 'package:than_pkg/than_pkg.dart';

class N3Data {
  String path;
  String? _dataTitle;
  bool isNovelExists = false;
  N3Data({required this.path});

  factory N3Data.createPath(String path) {
    return N3Data(path: path);
  }

  static bool isN3Data(String path) {
    return path.endsWith('.$getExt');
  }

  String get getTitle {
    return path.getName();
  }

  DateTime get getDate {
    final file = File(path);
    return file.statSync().modified;
  }

  String get getSize {
    final file = File(path);
    return file.statSync().size.toDouble().toFileSizeLabel();
  }

  String get getCoverPath {
    return '${PathUtil.getCachePath()}/$getTitle.cover';
  }

  String get getParentPath {
    final file = File(path);
    return file.parent.path;
  }

  Future<void> rename(String newPath) async {
    final file = File(path);
    await file.rename(newPath);
    path = newPath;
  }

  Future<void> copy(String newPath) async {
    final file = File(path);
    final newFile = File(newPath);
    if (newFile.existsSync()) return;
    await file.copy(newPath);
  }

  Future<void> delete() async {
    final file = File(path);
    if (file.existsSync()) {
      await file.delete();
    }
  }

  Future<String?> getDataTitle() async {
    if (_dataTitle != null) return _dataTitle;
    // Zip file ကို read
    return await Isolate.run<String?>(() async {
      try {
        final inputStream = InputFileStream(path);
        final archive = ZipDecoder().decodeStream(inputStream);
        if (archive.files.isEmpty) return null;
        final title = File(archive.files.first.name).uri.pathSegments.first;

        await inputStream.close();
        return title.trim();
      } catch (e) {
        // NovelDirApp.showDebugLog(e.toString(), tag: 'N3Data:getDataTitle');
      }
      return null;
    });
  }

  // extract
  Future<void> saveCover(String savedPath) async {
    final saveFile = File(savedPath);
    if (saveFile.existsSync()) return;
    final password = getSecretKey();

    // Zip file ကို read
    await Isolate.run(() async {
      try {
        final inputStream = InputFileStream(path);
        final outputStream = OutputFileStream(savedPath);

        final archive = ZipDecoder().decodeStream(
          inputStream,
          password: password,
        );
        if (archive.files.isEmpty) return;
        final title = archive.files.first.name.replaceAll('/', '');
        _dataTitle = title;

        for (var file in archive.files) {
          if (file.name.endsWith('cover.png')) {
            file.writeContent(outputStream, freeMemory: true);
            break;
          }
        }
        await inputStream.close();
      } catch (e) {
        // NovelDirApp.showDebugLog(e.toString(), tag: 'N3Data:saveCover');
        final saveFile = File(savedPath);
        if (saveFile.existsSync()) {
          await saveFile.delete();
        }
      }
    });
  }

  // static

  // static dataIsEnctry(String zipPath) {
  //   final inputStream = InputFileStream(zipPath);
  //   final archive = ZipDecoder().decodeStream(inputStream);

  //   // encrypted entries ရှိ/မရှိ စမ်း
  //   final hasEncrypted = archive.any((file) => file.compression == ComPre);

  //   inputStream.close();
  // }

  static String get getExt => 'npz';
}
