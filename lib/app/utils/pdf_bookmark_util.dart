import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:novel_v3/app/models/pdf_bookmark_model.dart';

void togglePdfBookmarkList({
  required String bookmarkPath,
  String title = 'Untitled',
  required int pageIndex,
}) {
  try {
    if (isExistsPdfBookmark(bookmarkPath: bookmarkPath, pageIndex: pageIndex)) {
      //remove
      removePdfBookmarkList(bookmarkPath: bookmarkPath, pageIndex: pageIndex);
    } else {
      //add
      addPdfBookmarkList(bookmarkPath: bookmarkPath, pageIndex: pageIndex);
    }
  } catch (e) {
    debugPrint('togglePdfBookmarkList: ${e.toString()}');
  }
}

void addPdfBookmarkList({
  required String bookmarkPath,
  String title = 'Untitled',
  required int pageIndex,
}) {
  try {
    List<PdfBookmarkModel> list =
        PdfBookmarkModel.getListFromPath(bookmarkPath);
    final file = File(bookmarkPath);
    list.add(PdfBookmarkModel(title: title, pageIndex: pageIndex));
    //sort
    list.sort((a, b) => a.pageIndex.compareTo(b.pageIndex));
    //save
    final mapList = list.map((bm) => bm.toMap()).toList();
    file.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(mapList));
  } catch (e) {
    debugPrint('addPdfBookmarkList: ${e.toString()}');
  }
}

void removePdfBookmarkList({
  required String bookmarkPath,
  required int pageIndex,
}) {
  try {
    List<PdfBookmarkModel> list =
        PdfBookmarkModel.getListFromPath(bookmarkPath);
    final file = File(bookmarkPath);
    //remove
    list = list.where((bm) => bm.pageIndex != pageIndex).toList();
    //save
    final mapList = list.map((bm) => bm.toMap()).toList();
    file.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(mapList));
  } catch (e) {
    debugPrint('removePdfBookmarkList: ${e.toString()}');
  }
}

bool isExistsPdfBookmark({
  required String bookmarkPath,
  required int pageIndex,
}) {
  bool res = false;
  try {
    List<PdfBookmarkModel> list =
        PdfBookmarkModel.getListFromPath(bookmarkPath);

    for (final bm in list) {
      if (bm.pageIndex == pageIndex) {
        res = true;
        break;
      }
    }
  } catch (e) {
    debugPrint('isExistsPdfBookmark: ${e.toString()}');
  }
  return res;
}
