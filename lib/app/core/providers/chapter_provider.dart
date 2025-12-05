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
    list = await ChapterServices.getAll(novelPath);

    list.sortChapterNumber();

    isLoading = false;
    notifyListeners();
  }

  Future<void> add(Chapter chapter) async {
    chapter = chapter.copyWith(novelPath: currentNovelPath);
    list.add(chapter);
    await ChapterServices.setChapter(chapter);
    notifyListeners();
  }

  bool isExistsNumber(int number) {
    final index = list.indexWhere((e) => e.number == number);
    return index != -1;
  }

  Future<String?> getContent(int chapterNumber) async {
    final content = await ChapterServices.getContent(
      chapterNumber,
      currentNovelPath!,
    );
    return content;
  }

  Future<void> setChapter(Chapter chapter) async {
    await ChapterServices.setChapter(chapter);

    int index = list.indexWhere((e) => e.number == chapter.number);
    if (index == -1) return;
    list[index] = chapter;
  }

  int get getLatestChapter => list.isEmpty ? 0 : list.last.number;
}
