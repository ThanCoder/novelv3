import 'dart:io';

import 'package:novel_v3/app/core/interfaces/index.dart';
import 'package:novel_v3/app/ui/novel_dir_app.dart';
import 'package:novel_v3/more_libs/setting_v2.0.0/others/index.dart';
import 'package:than_pkg/than_pkg.dart';

class NovelFolderDatabase extends FolderDatabase<Novel> {
  NovelFolderDatabase() : super(root: PathUtil.getSourcePath());

  @override
  Novel? from(FileSystemEntity file) {
    if (file.isDirectory) {
      return Novel.fromPath(file.path);
    }
    return null;
  }

  @override
  String getId(Novel value) {
    return value.title;
  }

  @override
  Future<Novel?> getById({required String id}) async {
    final dir = Directory('$root/$id');
    if (!dir.existsSync()) return null;
    return Novel.fromPath(dir.path);
  }
}
