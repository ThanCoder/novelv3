import 'package:flutter/material.dart';
import 'package:novel_v3/app/core/models/novel.dart';
import 'package:novel_v3/app/core/services/novel_services.dart';

class NovelProvider extends ChangeNotifier {
  List<Novel> list = [];
  bool isLoading = false;
  Novel? currentNovel;

  Future<void> init({bool isUsedCache = true}) async {
    if (isUsedCache && list.isNotEmpty) return;
    isLoading = true;
    notifyListeners();

    list = await NovelServices.instance.getAll();

    isLoading = false;
    notifyListeners();
  }

  Future<void> setCurrentNovel(Novel novel) async {
    currentNovel = novel;
    await Future.delayed(Duration.zero);
    notifyListeners();
  }
}
