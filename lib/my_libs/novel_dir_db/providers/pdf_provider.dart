import 'package:flutter/material.dart';
import '../novel_dir_db.dart';

class PdfProvider extends ChangeNotifier {
  final List<NovelPdf> _list = [];
  NovelPdf? _pdf;
  // get
  bool isLoading = false;
  List<NovelPdf> get getList => _list;
  NovelPdf? get getCurrent => _pdf;

  Future<void> initList(String novelPath) async {
    isLoading = true;
    notifyListeners();
    _list.clear();

    final res = await PdfServices.getList(novelPath);
    _list.addAll(res);

    isLoading = false;
    notifyListeners();
  }

  Future<void> setCurrent(NovelPdf pdf) async {
    _pdf = pdf;
    notifyListeners();
  }
}
