import 'package:novel_v3/core/models/novel.dart';

extension NovelFiltersExtension on List<Novel> {
  Set<String> get getAllAuthors {
    final list = <String>[];
    for (var item in this) {
      if (item.meta.author.isEmpty) continue;
      list.add(item.meta.author);
    }
    return list.toSet();
  }

  Set<String> get getAllMC {
    final list = <String>[];
    for (var item in this) {
      if (item.meta.mc.isEmpty) continue;
      list.add(item.meta.mc);
    }
    return list.toSet();
  }

  Set<String> get getAllTranslators {
    final list = <String>[];
    for (var item in this) {
      if (item.meta.translator.isEmpty) continue;
      list.add(item.meta.translator);
    }
    return list.toSet();
  }

  Set<String> get getAllTags {
    return expand((e) => e.meta.tags).toSet();
  }

  List<Novel> filterAuthor(String name) {
    return where(
      (e) => e.meta.author.toLowerCase().contains(name.toLowerCase()),
    ).toList();
  }

  List<Novel> filterMC(String name) {
    return where(
      (e) => e.meta.mc.toLowerCase().contains(name.toLowerCase()),
    ).toList();
  }

  List<Novel> filterTranslator(String name) {
    return where(
      (e) => e.meta.translator.toLowerCase().contains(name.toLowerCase()),
    ).toList();
  }

  List<Novel> filterTag(String name) {
    return where(
      (e) => e.meta.tags.toLowerCaseList.contains(name.toLowerCase()),
    ).toList();
  }
}

extension TagListExtension on List<String> {
  List<String> get toUpperCaseList {
    return map((e) => e.toUpperCase()).toList();
  }

  List<String> get toLowerCaseList {
    return map((e) => e.toLowerCase()).toList();
  }
}
