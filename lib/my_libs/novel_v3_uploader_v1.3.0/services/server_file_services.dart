import 'dart:io';

import '../constants.dart';
import '../novel_v3_uploader.dart';

class ServerFileServices {
  static String getRootPath({bool absPath = true}) {
    // for custom server
    final customServerDir = NovelV3Uploader.instance.getCustomServerPath();
    if (customServerDir.isNotEmpty && Directory(customServerDir).existsSync()) {
      return customServerDir;
    }
    var rootPath = absPath ? Directory.current.path : '';
    return '$rootPath/server';
  }

  static String getImagePath({bool absPath = true}) {
    return '${getRootPath(absPath: absPath)}/images';
  }

  static String getFilesPath({bool absPath = true}) {
    return '${getRootPath(absPath: absPath)}/files';
  }

  static String getContentDBFilesPath(String name, {bool absPath = true}) {
    return '${getRootPath(absPath: absPath)}/content_db/$name.db.json';
  }

  static String getImageUrl(String name) {
    return '$serverGithubImageUrl/$name';
  }

  static String getFileUrl(String name) {
    return '$serverGithubFileUrl/$name';
  }

  static String getContentDBUrl(String name) {
    return '$serverGithubContentDBUrl/$name.db.json';
  }

  // helper
  // local
  static String getHelperDBLocalPath(String name) {
    return '${getRootPath()}/helper/db_files/$name.db.json';
  }

  static String getHelperFileLocalPath(String name) {
    return '${getRootPath()}/helper/files/$name';
  }

  // online
  static String getHelperDBUrl(String name) {
    return '$serverGithubHelperDBUrl/$name.db.json';
  }

  static String getHelperFileUrl(String name) {
    return '$serverGithubHelperFilesUrl/$name';
  }

  static List<String> getAccessableFiles(List<String> list) {
    list = list.where((e) {
      if (e.endsWith('.npz') || e.endsWith('.pdf')) {
        return true;
      }
      return false;
    }).toList();
    return list;
  }

  static List<String> getAccessableConfigFiles(List<String> list) {
    list = list.where((e) {
      if (e.endsWith('.config.json')) {
        return true;
      }
      return false;
    }).toList();
    return list;
  }

  static List<String> getAccessableCoverFiles(List<String> list) {
    list = list.where((e) {
      if (e.endsWith('.png') || e.endsWith('.jpg')) {
        return true;
      }
      return false;
    }).toList();
    return list;
  }
}
