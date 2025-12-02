import 'package:flutter/material.dart';
import 'package:novel_v3/app/core/extensions/chapter_extension.dart';
import 'package:novel_v3/app/core/models/chapter.dart';
import 'package:novel_v3/app/core/services/chapter_services.dart';

class ChapterProvider extends ChangeNotifier {
  List<Chapter> list = [];
  bool isLoading = false;
  String? currentNovelPath;

  Future<void> init(String novelPath, {bool isUsedCache = true}) async {
    if (isUsedCache && list.isNotEmpty && novelPath == currentNovelPath) return;

    isLoading = true;
    notifyListeners();
    currentNovelPath = novelPath;
    list = await ChapterServices.instance.getAll(novelPath);

    list.sortChapterNumber();

    isLoading = false;
    notifyListeners();
  }

  Future<void> add(Chapter chapter) async {
    list.add(chapter);

    notifyListeners();
  }

  bool isExistsNumber(int number) {
    final index = list.indexWhere((e) => e.number == number);
    return index != -1;
  }

  int get getLatestChapter => list.isEmpty ? 0 : list.last.number;
}
