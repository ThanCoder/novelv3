import 'package:flutter/material.dart';
import 'package:novel_v3/app/extensions/pdf_extension.dart';
import 'package:novel_v3/more_libs/sort_dialog_v1.0.0/sort_type.dart';
import '../novel_dir_app.dart';

class PdfProvider extends ChangeNotifier {
  final List<NovelPdf> _list = [];
  NovelPdf? _pdf;
  SortType sortType = SortType.getDefaultDate();
  // get
  bool isLoading = false;
  List<NovelPdf> get getList => _list;
  NovelPdf? get getCurrent => _pdf;
  SortType get getCurrentSortType => sortType;

  Future<void> initList(String novelPath) async {
    isLoading = true;
    notifyListeners();
    _list.clear();

    final res = await PdfServices.getList(novelPath);
    _list.addAll(res);

    sortList(sortType);

    isLoading = false;
    notifyListeners();
  }

  Future<void> setCurrent(NovelPdf pdf) async {
    _pdf = pdf;
    notifyListeners();
  }

  void sortList(SortType type) {
    sortType = type;
    if (sortType.title == 'title') {
      _list.sortTitle(aToZ: type.isAsc);
    }
    if (sortType.title == 'date') {
      _list.sortDate(isNewest: !sortType.isAsc);
    }
    notifyListeners();
  }
}
