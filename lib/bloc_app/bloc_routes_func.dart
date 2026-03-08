import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:novel_v3/bloc_app/bloc/chapter_list_cubit.dart';
import 'package:novel_v3/bloc_app/bloc/novel_detail_cubit.dart';
import 'package:novel_v3/core/models/chapter.dart';
import 'package:novel_v3/core/services/chapter_services.dart';
import 'package:novel_v3/more_libs/setting/core/path_util.dart';
import 'package:novel_v3/other_apps/chapter_reader/chapter_reader_config.dart';
import 'package:novel_v3/other_apps/chapter_reader/chapter_reader_screen.dart';

void goBlocRoute(
  BuildContext context, {
  required Widget Function(BuildContext context) builder,
}) {
  Navigator.push(context, MaterialPageRoute(builder: builder));
}

Future<void> goBlocChapterReader(
  BuildContext context, {
  required Chapter chapter,
}) async {
  final novel = context.read<NovelDetailCubit>().state.currentNovel;
  if (novel == null) return;

  final configPath = PathUtil.getConfigPath(name: 'chapter.config.json');

  // // set recent
  // await TRecentDB.getInstance.putString(
  //   'recent-chapter-name:${novel.path.getName()}',
  //   chapter.number.toString(),
  // );
  if (!context.mounted) return;

  goBlocRoute(
    context,
    builder: (context) => ChapterReaderScreen(
      currentNovel: novel,
      allList: context.read<ChapterListCubit>().state.list,
      getReaded: () => novel.meta.readed,
      onUpdateReaded: (context, readed) async {
        // final provider = context.read<NovelProvider>();
        // await provider.update(
        //   provider.currentNovel!.copyWith(
        //     meta: provider.currentNovel!.meta.copyWith(readed: chapter.number),
        //   ),
        // );
      },
      isExistsChapterBookmark: (chpaterNumber) => false,
      onAddChapterBookmark: (bookmark) async {},
      onRemoveChapter: (chpaterNumber) async {},
      chapter: chapter,
      config: ChapterReaderConfig.fromPath(configPath),
      getChapterContent: (context, chapterNumber) async {
        try {
          final res = await ChapterServices().getContent(
            chapterNumber,
            novel.path,
          );
          // set recent
          // await TRecentDB.getInstance.putString(
          //   'recent-chapter-name:${novel.path.getName()}',
          //   chapterNumber.toString(),
          // );
          if (!context.mounted) return res;
          // context.read<ChapterBookmarkProvider>().refershUI();
          // context.read<ChapterProvider>().refershUI();
          return res;
        } catch (e) {
          debugPrint('[goBlocChapterReader]: $e');
        }
        return null;
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
