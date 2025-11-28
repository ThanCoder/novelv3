import 'package:flutter/material.dart';
import 'package:novel_v3/app/core/extensions/chapter_extension.dart';
import 'package:novel_v3/app/core/models/chapter.dart';
import 'package:novel_v3/app/core/services/chapter_services.dart';

class ChapterProvider extends ChangeNotifier {
  List<Chapter> list = [];
  bool isLoading = false;

  Future<void> init(String novelPath) async {
    isLoading = true;
    notifyListeners();

    list = await ChapterServices.instance.getAll(novelPath);

    list.sortChapterNumber();

    isLoading = false;
    notifyListeners();
  }
}
