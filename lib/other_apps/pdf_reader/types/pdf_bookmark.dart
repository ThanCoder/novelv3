// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:than_pkg/than_pkg.dart';

class PdfBookmark {
  final String title;
  final int page;
  const PdfBookmark({required this.title, required this.page});

  factory PdfBookmark.create({String title = 'Untitled', required int page}) {
    return PdfBookmark(title: title, page: page);
  }

  factory PdfBookmark.fromMap(Map<String, dynamic> map) {
    var page = MapServices.get<int>(map, ['page_index'], defaultValue: 0);
    if (map['page_index'] == null) {
      page = MapServices.get<int>(map, ['page'], defaultValue: 0);
    }

    return PdfBookmark(
      title: MapServices.get<String>(map, ['title'], defaultValue: 'Untitled'),
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
