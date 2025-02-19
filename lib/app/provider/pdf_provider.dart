import 'dart:io';

import 'package:flutter/material.dart';
import 'package:novel_v3/app/models/pdf_file_model.dart';
import 'package:novel_v3/app/notifiers/novel_notifier.dart';

import '../services/index.dart';
import '../utils/path_util.dart';

class PdfProvider with ChangeNotifier {
  final List<PdfFileModel> _list = [];
  bool _isLoading = false;

  List<PdfFileModel> get getList => _list;
  bool get isLoading => _isLoading;

  void initList() async {
    try {
      _isLoading = true;
      notifyListeners();

      var pdfList =
          await getPdfList(sourcePath: currentNovelNotifier.value!.path);

      pdfList = await genPdfCover(pdfList: pdfList);

      _list.clear();
      _list.addAll(pdfList);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('initList: ${e.toString()}');
    }
  }

  void rename(
      {required PdfFileModel pdfFile, required String renamedTitle}) async {
    try {
      final file = File(pdfFile.path);
      if (file.existsSync()) {
        final newPath = pdfFile.path
            .replaceAll(getBasename(file.path), '$renamedTitle.pdf');
        pdfFile.changeFullPath(newPath);
        //update ui
        final index = _list.indexWhere((pdf) => pdf.title == pdfFile.title);
        final pdf = _list[index];
        pdf.title = '$renamedTitle.pdf';
        _list[index] = pdf;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('add: ${e.toString()}');
    }
  }

  void add() async {
    try {} catch (e) {
      debugPrint('add: ${e.toString()}');
    }
  }

  void update() async {
    try {} catch (e) {
      debugPrint('update: ${e.toString()}');
    }
  }

  void delete() async {
    try {} catch (e) {
      debugPrint('delete: ${e.toString()}');
    }
  }
}
