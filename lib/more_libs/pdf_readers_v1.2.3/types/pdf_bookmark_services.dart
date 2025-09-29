import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'pdf_bookmark.dart';

class PdfBookmarkServices {
  static Future<List<PdfBookmark>> getList(String path) async {
    List<PdfBookmark> list = [];
    try {
      final file = File(path);
      if (!await file.exists()) return list;
      //ရှိနေရင်
      List<dynamic> resList = jsonDecode(await file.readAsString());
      list = resList.map((map) => PdfBookmark.fromMap(map)).toList();
    } catch (e) {
      debugPrint('[PdfBookmarkServices:getList] ${e.toString()}');
    }
    return list;
  }

  static Future<void> setList(String path, List<PdfBookmark> list) async {
    try {
      final file = File(path);
      final data = list.map((bm) => bm.toMap).toList();
      final contents = const JsonEncoder.withIndent(' ').convert(data);

      await file.writeAsString(contents);
    } catch (e) {
      debugPrint('[PdfBookmarkServices:setList] ${e.toString()}');
    }
  }
}
