// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:io';

import 'package:novel_v3/app/constants.dart';
import 'package:novel_v3/app/models/chapter_model.dart';
import 'package:novel_v3/app/models/pdf_model.dart';
import 'package:novel_v3/app/utils/path_util.dart';
import 'package:than_pkg/than_pkg.dart';

class NovelModel {
  String title;
  String path;
  bool isCompleted;
  bool isAdult;
  int date;
  String content;
  String pageLink;
  int readed;
  String mc;
  String author;
  late String coverPath;
  late String contentCoverPath;
  late String chapterBookmarkPath;

  NovelModel({
    required this.title,
    required this.path,
    required this.isCompleted,
    required this.isAdult,
    required this.date,
    this.content = '',
    this.pageLink = '',
    this.readed = 0,
    this.mc = 'Unknown',
    this.author = 'Unknown',
  }) {
    coverPath = '$path/cover.png';
    contentCoverPath = '$path/content_cover';
    chapterBookmarkPath = '$path/$chapterBookMarkListName';
  }

  set allPath(String _path) {
    path = _path;
    coverPath = '$_path/cover.png';
    contentCoverPath = '$_path/content_cover';
  }

  String get getContent {
    final file = File('$path/content');
    if (!file.existsSync()) return '';
    return file.readAsStringSync();
  }

  List<String> get getPageLinkList {
    return pageLink.split(',').where((name) => name.isNotEmpty).toList();
  }

  void setPageLinkList(List<String> list) {
    String data = list.join(',');
    pageLink = data;
    final file = File('$path/link');
    file.writeAsStringSync(data);
  }

  void setContent(String text) {
    final file = File('$path/content');
    file.writeAsStringSync(text);
  }

  factory NovelModel.fromTitle(String title, {bool isFullInfo = false}) {
    return NovelModel.fromPath('${PathUtil.getSourcePath()}/$title');
  }

  factory NovelModel.fromPath(String path, {bool isFullInfo = false}) {
    final dir = Directory(path);
    bool isAdult = File('${dir.path}/is-adult').existsSync();
    bool isCompleted = File('${dir.path}/is-completed').existsSync();
    String content = '';
    String pageLink = '';
    String mc = 'Unknown';
    String author = 'Unknown';
    int readed = 0;

    final readedFile = File('${dir.path}/readed');
    final mcFile = File('${dir.path}/mc');
    final authorFile = File('${dir.path}/author');

    if (readedFile.existsSync()) {
      String res = readedFile.readAsStringSync();
      if (res.isNotEmpty && int.tryParse(res) != null) {
        readed = int.parse(res);
      }
    }
    if (mcFile.existsSync()) {
      mc = mcFile.readAsStringSync();
    }
    if (authorFile.existsSync()) {
      author = authorFile.readAsStringSync();
    }

    //full info
    if (isFullInfo) {
      final contentFile = File('${dir.path}/content');
      final pageLinkFile = File('${dir.path}/link');

      if (pageLinkFile.existsSync()) {
        pageLink = pageLinkFile.readAsStringSync();
      }

      if (contentFile.existsSync()) {
        content = contentFile.readAsStringSync();
      }
    }

    return NovelModel(
      title: PathUtil.getBasename(dir.path),
      path: dir.path,
      isCompleted: isCompleted,
      isAdult: isAdult,
      content: content,
      readed: readed,
      pageLink: pageLink,
      mc: mc,
      author: author,
      date: dir.statSync().modified.millisecondsSinceEpoch,
    );
  }

  factory NovelModel.fromMap(Map<String, dynamic> map) {
    final novel = NovelModel(
      title: map['title'] ?? '',
      path: map['path'] ?? '',
      isCompleted: map['is_completed'] ?? false,
      isAdult: map['is_adult'] ?? false,
      date: map['date'] ?? 0,
    );
    novel.pageLink = map['page_link'] ?? '';
    novel.coverPath = map['cover_path'] ?? '';
    novel.mc = map['mc'] ?? '';
    novel.author = map['author'] ?? '';
    novel.content = map['content'] ?? '';
    novel.readed = map['readed'] ?? '';

    return novel;
  }

  factory NovelModel.create(String title) {
    final dir = Directory('${PathUtil.getSourcePath()}/$title');
    if (!dir.existsSync()) {
      dir.createSync();
    }
    return NovelModel(
      title: title,
      path: dir.path,
      isCompleted: false,
      isAdult: false,
      date: dir.statSync().modified.millisecondsSinceEpoch,
    );
  }

  Map<String, dynamic> toMap() => {
        "title": title,
        "path": path,
        'cover_path': coverPath,
        'is_completed': isCompleted,
        'is_adult': isAdult,
        'content': content,
        'readed': readed,
        'mc': mc,
        'author': author,
        'date': date,
        'page_link': pageLink,
      };

  bool get isExistsReaded {
    final file = File('$path/$readed');
    return file.existsSync();
  }

  Future<void> delete() async {
    final dir = Directory('${PathUtil.getSourcePath()}/$title');
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }

  Future<NovelModel> changeTitle(String newTitle) async {
    final newDir = Directory('${PathUtil.getSourcePath()}/$newTitle');
    final oldDir = Directory(path);
    if (await newDir.exists()) {
      throw Exception('newTitle is already exists');
    }
    if (!await oldDir.exists()) {
      throw Exception('oldDir not found!');
    }
    // create new dir
    await newDir.create();
    //move to new
    for (var file in oldDir.listSync()) {
      await file.rename('${newDir.path}/${file.getName()}');
    }
    //delete old dir
    await oldDir.delete();

    return NovelModel.fromPath(newDir.path);
  }

  Future<void> save() async {
    final readedFile = File('$path/readed');
    final mcFile = File('$path/mc');
    final authorFile = File('$path/author');
    final contentFile = File('$path/content');
    final pageLinkFile = File('$path/link');
    //write
    await readedFile.writeAsString(readed.toString());
    await mcFile.writeAsString(mc);
    await authorFile.writeAsString(author);
    await contentFile.writeAsString(content);
    await pageLinkFile.writeAsString(pageLink);
    //
    final adultFile = File('$path/is-adult');
    final completedFile = File('$path/is-completed');
    if (isAdult) {
      await adultFile.writeAsString('');
    } else {
      if (adultFile.existsSync()) {
        adultFile.deleteSync();
      }
    }
    if (isCompleted) {
      await completedFile.writeAsString('');
    } else {
      if (completedFile.existsSync()) {
        completedFile.deleteSync();
      }
    }
  }

  void setRecentPdfReader(PdfModel pdf) {
    final file = File('${PathUtil.getCachePath()}/$title.recent.pdf');
    file.writeAsStringSync(pdf.path);
  }

  PdfModel? getRecentPdfReader() {
    final file = File('${PathUtil.getCachePath()}/$title.recent.pdf');
    if (!file.existsSync()) return null;
    final _path = file.readAsStringSync();
    if (!File(_path).existsSync()) return null;
    return PdfModel.fromPath(_path);
  }

  void setRecenTextReader(ChapterModel chapter) {
    final file = File('${PathUtil.getCachePath()}/$title.recent.text');
    file.writeAsStringSync(chapter.number.toString());
  }

  ChapterModel? getRecentTextReader() {
    final file = File('${PathUtil.getCachePath()}/$title.recent.text');
    if (!file.existsSync()) return null;
    final _path = '$path/${file.readAsStringSync()}';
    if (!File(_path).existsSync()) return null;
    return ChapterModel.fromPath(_path);
  }

  int get getReaded {
    final file = File('$path/readed');
    if (file.existsSync()) {
      final res = file.readAsStringSync();
      if (res.isEmpty) return 0;
      if (int.tryParse(res) != null) return int.parse(res);
    }
    return 0;
  }

  void setReaded(int num) {
    readed = num;
    final file = File('$path/readed');
    file.writeAsStringSync(num.toString());
  }

  void exportConfig(Directory saveDir) {
    if (!saveDir.existsSync()) return;
    final coverFile = File(coverPath);
    if (coverFile.existsSync()) {
      coverFile.copySync('${saveDir.path}/$title.png');
    }
    //config
    final configFile = File('${saveDir.path}/$title.config.json');
    configFile
        .writeAsStringSync(const JsonEncoder.withIndent(' ').convert(toMap()));
  }

  DateTime get getDate => DateTime.fromMillisecondsSinceEpoch(date);

  double get getSize {
    double allSize = 0;
    final dir = Directory(path);
    if (!dir.existsSync()) return allSize;

    for (var file in dir.listSync()) {
      if (file.isDirectory()) continue;
      allSize += file.statSync().size;
    }
    return allSize;
  }

  @override
  String toString() {
    return title;
  }
}
