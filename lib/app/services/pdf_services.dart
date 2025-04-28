import 'dart:io';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:novel_v3/app/constants.dart';
import 'package:novel_v3/app/extensions/string_extension.dart';
import 'package:novel_v3/app/models/pdf_model.dart';
import 'package:novel_v3/app/services/core/android_app_services.dart';
import 'package:novel_v3/app/utils/path_util.dart';

class PdfServices {
  static final PdfServices instance = PdfServices._();
  PdfServices._();
  factory PdfServices() => instance;

  Future<List<PdfModel>> getList({required String novelPath}) async {
    List<PdfModel> list = [];
    final dir = Directory(novelPath);
    if (!await dir.exists()) return [];
    for (var file in dir.listSync()) {
      if (file.statSync().type != FileSystemEntityType.file) continue;
      final mime = lookupMimeType(file.path);
      if (mime == null || !mime.startsWith('application/pdf')) continue;
      list.add(PdfModel.fromPath(file.path));
    }
    //sort
    list.sort((a, b) => a.title.compareTo(b.title));
    return list;
  }

  Future<List<PdfModel>> pdfScanner() async {
    final dirs = await getScanDirPathList();
    final filterPaths = getScanFilteringPathList();
    //
    final cachePath = PathUtil.getCachePath();

    final list = await Isolate.run<List<PdfModel>>(() async {
      List<PdfModel> list = [];
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

            final mime = lookupMimeType(file.path) ?? '';
            if (!mime.startsWith('application/pdf')) continue;
            //add pdf
            list.add(PdfModel.fromPath(
              file.path,
              coverPath: '$cachePath/${file.path.getName(withExt: false)}.png',
              configPath:
                  '$cachePath/${file.path.getName(withExt: false)}$pdfConfigName',
              bookmarkPath:
                  '$cachePath/${file.path.getName(withExt: false)}$pdfBookListName',
            ));
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
    return list;
  }
}
