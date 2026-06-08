// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dart_core_extensions/dart_core_extensions.dart';

class PdfBookmark {
  final String title;
  final int page;
  const PdfBookmark({required this.title, required this.page});

  factory PdfBookmark.create({String title = 'Untitled', required int page}) {
    return PdfBookmark(title: title, page: page);
  }

  factory PdfBookmark.fromMap(Map<String, dynamic> map) {
    var page = map.getInt(['page_index'], def: -1);
    if (page == -1) {
      page = map.getInt(['page']);
    }
    return PdfBookmark(
      title: map.getString(['title'], def: 'Untitled'),
      page: page,
    );
  }

  Map<String, dynamic> get toMap => {'title': title, 'page': page};

  @override
  String toString() {
    return 'page: $page';
  }

  PdfBookmark copyWith({String? title, int? page}) {
    return PdfBookmark(title: title ?? this.title, page: page ?? this.page);
  }
}
