import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:novel_v3/app/constants.dart';
import 'package:novel_v3/app/models/chapter_book_mark_model.dart';
import 'package:novel_v3/app/models/chapter_model.dart';
import 'package:novel_v3/app/models/novel_model.dart';
import 'package:novel_v3/app/models/pdf_file_model.dart';
import 'package:novel_v3/app/notifiers/novel_notifier.dart';
import 'package:novel_v3/app/utils/path_util.dart';

//novel readed
void updateNovelReaded({required NovelModel novel}) {
  try {
    final readedFile = File('${novel.path}/readed');
    readedFile.writeAsStringSync(novel.readed.toString());
  } catch (e) {
    debugPrint(e.toString());
  }
}

String getChapterContent({required String chapterPath}) {
  String res = "";
  final file = File(chapterPath);
  if (file.existsSync()) {
    res = file.readAsStringSync();
  }
  return res;
}

//delete chapter
void deleteChapter({required ChapterModel chapter}) {
  try {
    final file = File(chapter.path);
    if (file.existsSync()) {
      file.deleteSync();
    }
    List<ChapterModel> cList = chapterListNotifier.value;
    cList = cList.where((c) => c.title != chapter.title).toList();
    chapterListNotifier.value = cList;
  } catch (e) {
    debugPrint(e.toString());
  }
}

//novel
Future<List<NovelModel>> getNovelListFromPath(
    {required String sourcePath}) async {
  final completer = Completer<List<NovelModel>>();
  try {
    List<NovelModel> novelList = [];
    final dir = Directory(sourcePath);
    if (dir.existsSync()) {
      for (final file in dir.listSync()) {
        if (file.statSync().type == FileSystemEntityType.directory) {
          novelList.add(NovelModel.fromPath(file.path));
        }
      }
    }

    //sort
    novelList.sort((a, b) {
      return a.date.compareTo(b.date) == 1 ? -1 : 1;
    });

    completer.complete(novelList);
  } catch (e) {
    completer.completeError(e);
  }
  return completer.future;
}

//delete novel
void deleteNovel({
  required NovelModel novel,
  required void Function() onSuccess,
  required void Function(String msg) onError,
}) {
  try {
    final dir = Directory(novel.path);
    if (!dir.existsSync()) return;
    //del
    dir.deleteSync(recursive: true);
    //del ui
    final res =
        novelListNotifier.value.where((n) => n.title != novel.title).toList();
    novelListNotifier.value = res;
    currentNovelNotifier.value = null;

    //callback
    onSuccess();
  } catch (e) {
    onError(e.toString());
    debugPrint('deleteNovel: ${e.toString()}');
  }
}

//update novel
Future<void> updateNovel(
    {required String oldNovelTitle, required NovelModel novel}) async {
  final completer = Completer();
  try {
    //update content
    final isAdultFile = File('${novel.path}/is-adult');
    final isCompletedFileFile = File('${novel.path}/is-completed');
    final contentFile = File('${novel.path}/content');
    final pageLinkFile = File('${novel.path}/link');
    final readedFile = File('${novel.path}/readed');
    final mcFile = File('${novel.path}/mc');
    final authorFile = File('${novel.path}/author');

    contentFile.writeAsStringSync(novel.content);
    readedFile.writeAsStringSync(novel.readed.toString());
    mcFile.writeAsStringSync(novel.mc);
    authorFile.writeAsStringSync(novel.author);

    if (novel.pageLink.isEmpty) {
      if (pageLinkFile.existsSync()) {
        pageLinkFile.deleteSync();
      }
    } else {
      pageLinkFile.writeAsStringSync(novel.pageLink);
    }

    if (novel.isAdult) {
      isAdultFile.writeAsStringSync('');
    } else {
      if (isAdultFile.existsSync()) {
        isAdultFile.deleteSync();
      }
    }
    if (novel.isCompleted) {
      isCompletedFileFile.writeAsStringSync('');
    } else {
      if (isCompletedFileFile.existsSync()) {
        isCompletedFileFile.deleteSync();
      }
    }

    //update title
    if (novel.title != oldNovelTitle) {
      final newDir = Directory('${getSourcePath()}/${novel.title}');
      final oldDir = Directory('${getSourcePath()}/$oldNovelTitle');

      if (!await oldDir.exists() || await newDir.exists()) return;
      await newDir.create();
      //move old dir content
      for (final file in oldDir.listSync()) {
        final newPath = '${newDir.path}/${getBasename(file.path)}';
        file.renameSync(newPath);
      }
      //delete old dir
      await oldDir.delete();
      //change novel class path -> new path
      novel.allPath = newDir.path;
    }

    //update ui
    currentNovelNotifier.value = novel;
    List<NovelModel> oldList = novelListNotifier.value;
    oldList = oldList.where((n) => n.title != oldNovelTitle).toList();
    oldList.insert(0, novel);
    novelListNotifier.value = oldList;

    completer.complete();
  } catch (e) {
    completer.completeError(e);
    debugPrint('updateNovel: ${e.toString()}');
  }
  return completer.future;
}

//book mark
void getBookMarkList({
  required String sourcePath,
  required void Function(List<ChapterBookMarkModel> chapterBookList) onSuccess,
  required void Function(String err) onError,
}) {
  try {
    final file = File('$sourcePath/$chapterBookMarkListName');
    if (!file.existsSync()) {
      onSuccess([]);
      return;
    }
    List<dynamic> jlist = jsonDecode(file.readAsStringSync());
    List<ChapterBookMarkModel> cList =
        jlist.map((json) => ChapterBookMarkModel.fromJson(json)).toList();

    //sort
    cList.sort((a, b) {
      int ac = int.tryParse(a.chapter) ?? 0;
      int bc = int.tryParse(b.chapter) ?? 0;
      return ac.compareTo(bc);
    });

    onSuccess(cList);
  } catch (e) {
    onError(e.toString());
  }
}

void toggleBookMark({
  required String sourcePath,
  required String title,
  required String chapter,
  required void Function() onSuccess,
  required void Function(String err) onError,
}) {
  try {
    final file = File('$sourcePath/$chapterBookMarkListName');
    List<ChapterBookMarkModel> cList = [];
    if (file.existsSync()) {
      //get
      List<dynamic> jlist = jsonDecode(file.readAsStringSync());
      cList = jlist.map((json) => ChapterBookMarkModel.fromJson(json)).toList();
    }

    if (existsBookMark(sourcePath: sourcePath, chapter: chapter)) {
      //remove
      cList = cList.where((bm) => bm.title != title).toList();
    } else {
      //add
      cList.add(ChapterBookMarkModel(title: title, chapter: chapter));
    }

    //save
    file.writeAsStringSync(jsonEncode(ChapterBookMarkModel.toMapList(cList)));
    //callback
    onSuccess();
  } catch (e) {
    onError(e.toString());
  }
}

bool existsBookMark({
  required String sourcePath,
  required String chapter,
}) {
  bool res = false;
  try {
    final file = File('$sourcePath/$chapterBookMarkListName');
    if (!file.existsSync()) {
      return false;
    }
    //get
    List<dynamic> jlist = jsonDecode(file.readAsStringSync());
    List<ChapterBookMarkModel> cList =
        jlist.map((json) => ChapterBookMarkModel.fromJson(json)).toList();
    for (final bm in cList) {
      if (bm.chapter == chapter) {
        res = true;
        break;
      }
    }
  } catch (e) {}
  return res;
}

void removeBookMark({
  required String sourcePath,
  required String title,
  required void Function() onSuccess,
  required void Function(String err) onError,
}) {
  try {
    final file = File('$sourcePath/$chapterBookMarkListName');
    if (!file.existsSync()) {
      return;
    }
    //get
    List<dynamic> jlist = jsonDecode(file.readAsStringSync());
    List<ChapterBookMarkModel> cList =
        jlist.map((json) => ChapterBookMarkModel.fromJson(json)).toList();
    //remove
    cList = cList.where((bm) => bm.title != title).toList();
    //set
    file.writeAsStringSync(jsonEncode(cList));
    //callback
    onSuccess();
  } catch (e) {
    onError(e.toString());
  }
}

//pdf list
Future<List<PdfFileModel>> getPdfList({required String sourcePath}) async {
  final completer = Completer<List<PdfFileModel>>();
  try {
    final dir = Directory(sourcePath);
    if (!dir.existsSync()) {
      completer.complete([]);
    } else {
      List<PdfFileModel> cList = [];

      final files = dir.listSync();
      for (final file in files) {
        if (file.statSync().type != FileSystemEntityType.file) continue;
        if (!getBasename(file.path).endsWith('.pdf')) continue;
        cList.add(PdfFileModel.fromPath(file.path));
      }

      cList.sort((a, b) {
        return a.title.compareTo(b.title);
      });

      completer.complete(cList);
    }
  } catch (e) {
    completer.completeError(e);
  }
  return completer.future;
}
