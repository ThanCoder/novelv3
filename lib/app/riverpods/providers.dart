import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novel_v3/app/riverpods/notifiers/bookmark_notifier.dart';
import 'package:novel_v3/app/riverpods/notifiers/chapter_bookmark_notifier.dart';
import 'package:novel_v3/app/riverpods/notifiers/recent_notifier.dart';
import 'package:novel_v3/app/riverpods/states/bookmark_state.dart';
import 'package:novel_v3/app/riverpods/notifiers/chapter_notifier.dart';
import 'package:novel_v3/app/riverpods/states/chapter_bookmark_state.dart';
import 'package:novel_v3/app/riverpods/states/chapter_state.dart';
import 'package:novel_v3/app/riverpods/notifiers/novel_notifier.dart';
import 'package:novel_v3/app/riverpods/states/novel_state.dart';
import 'package:novel_v3/app/riverpods/notifiers/pdf_notifier.dart';
import 'package:novel_v3/app/riverpods/states/pdf_state.dart';
import 'package:novel_v3/app/riverpods/states/recent_state.dart';

final chapterBookmarkNotifierProvider =
    StateNotifierProvider<ChapterBookmarkNotifier, ChapterBookmarkState>(
  (ref) => ChapterBookmarkNotifier(),
);
final novelNotifierProvider = StateNotifierProvider<NovelNotifier, NovelState>(
  (ref) => NovelNotifier(),
);
final bookmarkNotifierProvider =
    StateNotifierProvider<BookmarkNotifier, BookmarkState>(
  (res) => BookmarkNotifier(),
);
final chapterNotifierProvider =
    StateNotifierProvider<ChapterNotifier, ChapterState>(
  (ref) => ChapterNotifier(),
);
final pdfNotifierProvider = StateNotifierProvider<PdfNotifier, PdfState>(
  (ref) => PdfNotifier(),
);
final recentNotifierProvider = StateNotifierProvider<RecentNotifier, RecentState>(
  (ref) => RecentNotifier(),
);
