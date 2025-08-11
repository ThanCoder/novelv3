// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:than_pkg/than_pkg.dart';

class PdfBookmarkModel {
  String title;
  int page;
  PdfBookmarkModel({
    this.title = 'Untitled',
    required this.page,
  });

  factory PdfBookmarkModel.fromMap(Map<String, dynamic> map) {
    var page = MapServices.get<int>(map, ['page_index'], defaultValue: 0);
    if (map['page_index'] == null) {
      page = MapServices.get<int>(map, ['page'], defaultValue: 0);
    }

    return PdfBookmarkModel(
      title: MapServices.get<String>(map, ['title'], defaultValue: 'Untitled'),
      page: page,
    );
  }

  Map<String, dynamic> get toMap => {'title': title, 'page': page};

  static Future<List<PdfBookmarkModel>> getBookmarkListFromPath(
      String bookmarkPath) async {
    List<PdfBookmarkModel> list = [];
    try {
      final file = File(bookmarkPath);
      if (!await file.exists()) return list;
      //ရှိနေရင်
      List<dynamic> resList = jsonDecode(await file.readAsString());
      list = resList.map((map) => PdfBookmarkModel.fromMap(map)).toList();
    } catch (e) {
      debugPrint('getListFromPath: ${e.toString()}');
    }
    return list;
  }

  static Future<void> setBookmarkListFromPath(
      String bookmarkPath, List<PdfBookmarkModel> list) async {
    try {
      final file = File(bookmarkPath);
      final data = list.map((bm) => bm.toMap).toList();
      final contents = const JsonEncoder.withIndent(' ').convert(data);

      await file.writeAsString(contents);
    } catch (e) {
      debugPrint('setBookmarkListFromPath: ${e.toString()}');
    }
  }

  @override
  String toString() {
    return 'page: $page';
  }
}
