import 'dart:io';

import 'package:than_pkg/than_pkg.dart';

class Novel {
  String title;
  String path;
  DateTime date;
  Novel({
    required this.title,
    required this.path,
    required this.date,
  });

  factory Novel.fromPath(String path) {
    final dir = Directory(path);
    return Novel(
      title: path.getName(),
      path: path,
      date: dir.statSync().modified,
    );
  }

  @override
  String toString() => 'Novel(title: $title, path: $path, date: $date)';
}
