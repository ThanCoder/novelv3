import 'package:flutter/material.dart';
import 'package:novel_v3/app/extensions/pdf_extension.dart';
import 'package:t_widgets/t_sort/index.dart';
import '../novel_dir_app.dart';

class PdfProvider extends ChangeNotifier {
  final List<NovelPdf> _list = [];
  NovelPdf? _pdf;

  int currentSortId = TSort.getTitleId;
  bool isSortAsc = true;
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

    sortList();

    isLoading = false;
    notifyListeners();
  }

  Future<void> setCurrent(NovelPdf pdf) async {
    _pdf = pdf;
    notifyListeners();
  }

  Future<void> delete(NovelPdf pdf) async {
    try {
      final index = _list.indexWhere((e) => e.getTitle == pdf.getTitle);
      if (index == -1) return;
      _list.removeAt(index);

      await pdf.delete();
      notifyListeners();
    } catch (e) {
      NovelDirApp.showDebugLog(e.toString());
    }
  }

  void setSort(int id, bool isAsc) {
    currentSortId = id;
    isSortAsc = isAsc;
    sortList();
  }

  void sortList() {
    if (currentSortId == TSort.getTitleId) {
      _list.sortTitle(aToZ: isSortAsc);
    }
    if (currentSortId == TSort.getDateId) {
      _list.sortDate(isNewest: !isSortAsc);
    }
    notifyListeners();
  }

  Future<void> removeUI(NovelPdf pdf) async {
    try {
      final index = _list.indexWhere((e) => e.getTitle == pdf.getTitle);
      if (index == -1) return;
      _list.removeAt(index);
      notifyListeners();
    } catch (e) {
      NovelDirApp.showDebugLog(e.toString());
    }
  }
}
