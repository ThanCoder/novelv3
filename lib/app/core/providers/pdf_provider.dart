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
}
