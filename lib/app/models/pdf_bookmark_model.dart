// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:io';

class PdfBookmarkModel {
  String title;
  int pageIndex;
  PdfBookmarkModel({
    required this.title,
    required this.pageIndex,
  });

  factory PdfBookmarkModel.fromMap(Map<String, dynamic> map) =>
      PdfBookmarkModel(
        title: map['title'] ?? 'Untitled',
        pageIndex: map['page_index'] ?? 0,
      );

  static List<PdfBookmarkModel> getListFromPath(String path) {
    List<PdfBookmarkModel> list = [];
    final file = File(path);
    if (!file.existsSync()) return list;
    List<dynamic> ml = jsonDecode(file.readAsStringSync());
    list = ml.map((m) => PdfBookmarkModel.fromMap(m)).toList();
    return list;
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'page_index': pageIndex,
      };

  @override
  String toString() {
    return '\ntitle => $title\npage_index => $pageIndex\n';
  }
}
