import 'dart:io';

import 'package:novel_v3/app/core/interfaces/index.dart';
import 'package:novel_v3/app/ui/novel_dir_app.dart';
import 'package:novel_v3/more_libs/setting_v2.0.0/others/index.dart';
import 'package:than_pkg/than_pkg.dart';

class NovelFolderDatabase extends FolderDatabase<Novel> {
  NovelFolderDatabase()
    : super(
        root: PathUtil.getSourcePath(),
        storage: FileStorage(root: PathUtil.getSourcePath()),
      );

  @override
  Future<void> add(Novel value) {
    // TODO: implement add
    throw UnimplementedError();
  }

  @override
  Novel? from(FileSystemEntity file) {
    if (file.isDirectory) {
      return Novel.fromPath(file.path);
    }
    return null;
  }

  @override
  Future<void> update(String id, Novel value) {
    // TODO: implement update
    throw UnimplementedError();
  }
}
