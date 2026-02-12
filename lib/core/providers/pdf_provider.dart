import 'package:flutter/material.dart';
import 'package:novel_v3/core/extensions/pdf_file_extension.dart';
import 'package:novel_v3/core/models/pdf_file.dart';
import 'package:novel_v3/core/services/pdf_services.dart';
import 'package:t_widgets/t_widgets.dart';

class PdfProvider extends ChangeNotifier {
  List<PdfFile> list = [];
  bool isLoading = false;

  Future<void> init(String novelPath) async {
    isLoading = true;
    notifyListeners();

    list = await PdfServices.getAll(novelPath);

    sort(currentSortId, sortAsc);

    isLoading = false;
    notifyListeners();
  }

  Future<void> rename(PdfFile pdf, {required String oldName}) async {
    final index = list.indexWhere((e) => e.title == oldName);
    if (index == -1) return;
    list[index] = pdf;
    // rename pdf && config
    await pdf.renameAllConfig(oldName);

    notifyListeners();
  }

  Future<void> deleteForever(PdfFile pdf) async {
    final index = list.indexWhere((e) => e.title == pdf.title);
    if (index == -1) return;
    list.removeAt(index);
    await pdf.deleteForever();

    notifyListeners();
  }

  // sort
  bool sortAsc = true;
  int currentSortId = TSort.getTitleId;
  List<TSort> sortList = TSort.getDefaultList
    ..add(
      TSort(id: 1, title: 'Size', ascTitle: 'Smallest', descTitle: 'Biggest'),
    );

  void sort(int currentId, bool isAsc) {
    sortAsc = isAsc;
    currentSortId = currentId;

    if (currentSortId == TSort.getDateId) {
      // date
      list.sortDate(isNewest: !sortAsc);
    }
    if (currentSortId == TSort.getTitleId) {
      // title
      list.sortTitle(aToZ: sortAsc);
    }
    if (currentSortId == 1) {
      // size
      list.sortSize(isSmallest: sortAsc);
    }
    notifyListeners();
  }
}
