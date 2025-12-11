import 'package:flutter/material.dart';
import 'package:novel_v3/app/core/models/pdf_file.dart';
import 'package:novel_v3/app/core/services/pdf_services.dart';

class PdfProvider extends ChangeNotifier {
  List<PdfFile> list = [];
  bool isLoading = false;

  Future<void> init(String novelPath) async {
    isLoading = true;
    notifyListeners();

    list = await PdfServices.getAll(novelPath);

    isLoading = false;
    notifyListeners();
  }

  Future<void> rename(PdfFile pdf, {required String oldName}) async {
    final index = list.indexWhere((e) => e.title == oldName);
    if (index == -1) return;
    list[index] = pdf;
    // rename pdf && config
    await pdf.rename(oldName);

    notifyListeners();
  }

  Future<void> deleteForever(PdfFile pdf) async {
    final index = list.indexWhere((e) => e.title == pdf.title);
    if (index == -1) return;
    list.removeAt(index);
    await pdf.deleteForever();

    notifyListeners();
  }
}
