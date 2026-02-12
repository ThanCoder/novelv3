import 'package:flutter/material.dart';
import 'package:novel_v3/core/models/chapter.dart';
import 'package:novel_v3/core/models/novel.dart';
import 'package:novel_v3/core/providers/chapter_bookmark_provider.dart';
import 'package:novel_v3/core/providers/chapter_provider.dart';
import 'package:novel_v3/core/providers/novel_provider.dart';
import 'package:novel_v3/app/others/chapter_reader/chapter_reader_config.dart';
import 'package:novel_v3/app/others/chapter_reader/chapter_reader_screen.dart';
import 'package:novel_v3/app/ui/search/search_result_screen.dart';
import 'package:novel_v3/more_libs/setting/core/path_util.dart';
import 'package:provider/provider.dart';
import 'package:than_pkg/than_pkg.dart';

void goRoute(
  BuildContext context, {
  required Widget Function(BuildContext context) builder,
}) {
  Navigator.push(context, MaterialPageRoute(builder: builder));
}

void closeContext(BuildContext context) {
  Navigator.pop(context);
}

void goSearchResultScreen(
  BuildContext context, {
  required String title,
  required List<Novel> list,
}) {
  context.read<NovelProvider>().setSearchResultList(list);
  goRoute(context, builder: (context) => SearchResultScreen(title: title));
}

Future<void> goChapterReader(
  BuildContext context, {
  required Chapter chapter,
}) async {
  final novel = context.read<NovelProvider>().currentNovel;
  if (novel == null) return;

  final configPath = PathUtil.getConfigPath(name: 'chapter.config.json');

  // set recent
  await TRecentDB.getInstance.putString(
    'recent-chapter-name:${novel.path.getName()}',
    chapter.number.toString(),
  );
  if (!context.mounted) return;

  goRoute(
    context,
    builder: (context) => ChapterReaderScreen(
      allList: context.read<ChapterProvider>().list,
      chapter: chapter,
      config: ChapterReaderConfig.fromPath(configPath),
      getChapterContent: (context, chapterNumber) async {
        final res = await context.read<ChapterProvider>().getContent(
          chapterNumber,
          novelPath: novel.path,
        );
        // set recent
        await TRecentDB.getInstance.putString(
          'recent-chapter-name:${novel.path.getName()}',
          chapterNumber.toString(),
        );
        if (!context.mounted) return res;
        context.read<ChapterBookmarkProvider>().refershUI();
        context.read<ChapterProvider>().refershUI();
        return res;
      },
      onUpdateConfig: (updatedConfig) {
        updatedConfig.savePath(configPath);
      },
      // onReaderClosed: (lastChapter) async {
      //   // set recent
      //   await TRecentDB.getInstance.putString(
      //     'recent-chapter-name:${novel.path.getName()}',
      //     lastChapter.number.toString(),
      //   );
      //   if (!context.mounted) return;
      //   context.read<ChapterBookmarkProvider>().refershUI();
      //   context.read<ChapterProvider>().refershUI();
      // },
    ),
  );
}
