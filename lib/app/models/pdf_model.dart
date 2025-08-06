// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:novel_v3/app/constants.dart';
import 'package:novel_v3/my_libs/pdf_readers_v1.0.1/types/pdf_config_model.dart';
import 'package:than_pkg/than_pkg.dart';

class PdfModel {
  String title;
  String path;
  String coverPath;
  int size;
  DateTime date;
  String configPath;
  String bookMarkPath;
  PdfModel({
    required this.title,
    required this.path,
    required this.coverPath,
    required this.size,
    required this.date,
    this.bookMarkPath = '',
    this.configPath = '',
  });

  factory PdfModel.fromPath(
    String path, {
    String? coverPath,
    String? configPath,
    String? bookmarkPath,
  }) {
    final file = File(path);
    final name = file.path.getName(withExt: false);
    var cp = coverPath ?? file.path.replaceAll('.pdf', '.png');
    var config = configPath ?? file.path.replaceAll('.pdf', pdfConfigName);
    var bookmark =
        bookmarkPath ?? file.path.replaceAll('.pdf', pdfBookListName);

    return PdfModel(
      title: name,
      path: path,
      coverPath: cp,
      size: file.statSync().size,
      date: file.statSync().modified,
      configPath: config,
      bookMarkPath: bookmark,
    );
  }

  void delete() {
    final pdfFile = File(path);
    final coverFile = File(coverPath);
    final configFile = File(path);
    if (pdfFile.existsSync()) {
      pdfFile.deleteSync();
    }
    if (coverFile.existsSync()) {
      coverFile.deleteSync();
    }
    if (configFile.existsSync()) {
      configFile.deleteSync();
    }
  }
  Future<void> moveTo(String newPath)async{
    if(File(newPath).existsSync()){
      throw ErrorDescription('new path already!');
    }
    final oriPath = File(path);
    if(!oriPath.existsSync()){
      throw ErrorDescription('pdf path not exists');
    }
    await oriPath.rename(newPath);
  }
  Future<void> copyCover(String newPath)async{
    final coverFile = File(coverPath);
    if(coverFile.existsSync()){
      coverFile.copySync(newPath);
    }
  }

  PdfConfigModel getConfig() {
    return PdfConfigModel.fromPath(configPath);
  }

  void setConfig(PdfConfigModel config) {
    config.savePath(configPath);
  }

  @override
  String toString() {
    return title;
  }
}
