import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:novel_v3/bloc_app/bloc/chapter_bookmark_list_cubit.dart';
import 'package:novel_v3/bloc_app/bloc/chapter_list_cubit.dart';
import 'package:novel_v3/bloc_app/bloc/novel_detail_cubit.dart';
import 'package:novel_v3/bloc_app/bloc/novel_list_cubit.dart';
import 'package:novel_v3/bloc_app/ui/content/content_screen.dart';
import 'package:novel_v3/bloc_app/ui/search/search_result_screen.dart';
import 'package:novel_v3/bloc_app/ui/search/search_screen.dart';
import 'package:novel_v3/core/models/chapter.dart';
import 'package:novel_v3/core/models/novel.dart';
import 'package:novel_v3/core/models/pdf_file.dart';
import 'package:novel_v3/core/services/chapter_services.dart';
import 'package:novel_v3/more_libs/setting/core/path_util.dart';
import 'package:novel_v3/old_app/routes.dart';
import 'package:novel_v3/other_apps/chapter_reader/chapter_reader_config.dart';
import 'package:novel_v3/other_apps/chapter_reader/chapter_reader_screen.dart';
import 'package:novel_v3/other_apps/pdf_reader/pdf_reader.dart';

void goBlocRoute(
  BuildContext context, {
  required Widget Function(BuildContext context) builder,
}) {
  Navigator.push(context, MaterialPageRoute(builder: builder));
}

Future<void> goNovelContentScreen(
  BuildContext context, {
  required Novel novel,
}) async {
  await context.read<NovelDetailCubit>().setCurrentNovel(novel);
  if (!context.mounted) return;
  goRoute(context, builder: (context) => ContentScreen(novel: novel));
}

// go pdf reader
Future<void> goBlocPdfReader(
  BuildContext context, {
  required PdfFile pdf,
}) async {
  final pdfConfig = PdfConfig.fromPath(pdf.getCurrentConfigPath);
  goBlocRoute(
    context,
    builder: (context) => PdfrxReaderScreen(
      sourcePath: pdf.path,
      pdfConfig: pdfConfig,
      title: pdf.title,
      onConfigUpdated: (updatedPdfConfig) {
        updatedPdfConfig.savePath(pdf.getCurrentConfigPath);
      },
    ),
  );
}

void goBlocSearch(BuildContext context) {
  final list = context.read<NovelListCubit>().state.list;
  goBlocRoute(
    context,
    builder: (context) => SearchScreen(
      list: list,
      onClicked: (novel) {
        goNovelContentScreen(context, novel: novel);
      },
      onSearchResultPage: (title, list) {
        goBlocRoute(
          context,
          builder: (context) => SearchResultScreen(
            title: title,
            list: list,
            onClicked: (novel) {
              goNovelContentScreen(context, novel: novel);
            },
          ),
        );
      },
    ),
  );
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
  final bookmarkProvider = context.read<ChapterBookmarkListCubit>();

  goBlocRoute(
    context,
    builder: (context) => ChapterReaderScreen(
      currentNovel: novel,
      allList: context.read<ChapterListCubit>().state.list,
      getReaded: () => novel.meta.readed,
      onUpdateReaded: (context, readed) async {
        await context.read<NovelDetailCubit>().updateNovel(
          novel.id,
          novel.copyWith(meta: novel.meta.copyWith(readed: chapter.number)),
        );
      },
      isExistsChapterBookmark: (chapterNumber) =>
          bookmarkProvider.isExists(chapterNumber),
      onAddChapterBookmark: (bookmark) async {
        await bookmarkProvider.toggle(bookmark);
      },
      onRemoveChapter: (chapterNumber) async {
        await bookmarkProvider.removeNumber(chapterNumber);
      },
      chapter: chapter,
      config: ChapterReaderConfig.fromPath(configPath),
      getChapterContent: (context, chapterNumber) async {
        try {
          final res = await ChapterServices().getContent(
            chapterNumber,
            novel.id,
          );
          // set recent
          // await TRecentDB.getInstance.putString(
          //   'recent-chapter-name:${novel.path.getName()}',
          //   chapterNumber.toString(),
          // );
          return res;
        } catch (e) {
          debugPrint('[goBlocChapterReader]: $e');
        }
        return null;
      },
      onUpdateConfig: (updatedConfig) {
        updatedConfig.savePath(configPath);
      },
    ),
  );
}
