import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novel_v3/app/dialogs/add_bookmark_title_dialog.dart';
import 'package:novel_v3/app/models/chapter_bookmark_model.dart';
import 'package:novel_v3/app/models/index.dart';
import 'package:novel_v3/app/models/pdf_model.dart';
import 'package:novel_v3/app/pdf_readers/pdfrx_reader_screen.dart';
import 'package:novel_v3/app/riverpods/providers.dart';
import 'package:novel_v3/app/screens/chapter_edit_form.dart';
import 'package:novel_v3/app/screens/novel_content_screen.dart';
import 'package:novel_v3/app/screens/novel_edit_form_screen.dart';
import 'package:novel_v3/app/screens/novel_see_all_screen.dart';
import 'package:novel_v3/app/text_reader/text_reader_config_model.dart';
import 'package:novel_v3/app/text_reader/text_reader_screen.dart';

void goNovelContentPage(
  BuildContext context,
  WidgetRef ref,
  NovelModel novel,
) async {
  ref.read(novelNotifierProvider.notifier).setCurrent(novel);
  ref.read(chapterNotifierProvider.notifier).listClear();

  if (!context.mounted) return;
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => NovelContentScreen(novel: novel),
    ),
  );
}

void goNovelEditForm(
  BuildContext context,
  WidgetRef ref,
  NovelModel novel,
) async {
  await ref.read(novelNotifierProvider.notifier).setCurrent(novel);
  if (!context.mounted) return;
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => NovelEditFormScreen(novel: novel),
    ),
  );
}

void goChapterEditForm(BuildContext context, WidgetRef ref) async {
  final novel = ref.read(novelNotifierProvider.notifier).getCurrent;
  if (novel == null) return;
  if (!context.mounted) return;
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ChapterEditForm(novelPath: novel.path),
    ),
  );
}

void goPdfReader(BuildContext context, WidgetRef ref, PdfModel pdf) async {
  final provider = ref.read(novelNotifierProvider.notifier);
  final novel = provider.getCurrent;
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => PdfrxReaderScreen(
        title: pdf.title,
        pdfConfig: PdfConfigModel.fromPath(pdf.configPath),
        bookmarkPath: pdf.bookMarkPath,
        sourcePath: pdf.path,
        saveConfig: (pdfConfig) {
          pdfConfig.savePath(pdf.configPath);
          if (novel == null) return;
          novel.setRecentPdfReader(pdf);
          provider.refreshCurrent();
        },
      ),
    ),
  );
}

int globalReadLine = 0;

void goTextReader(
  BuildContext context,
  WidgetRef ref,
  ChapterModel chapter,
) async {
  final provider = ref.read(chapterBookmarkNotifierProvider.notifier);
  await provider.initList(chapter.getNovelPath);

  if (!context.mounted) return;
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => TextReaderScreen(
        data: chapter,
        config: TextReaderConfigModel.fromPath(chapter.getConfigPath),
        onConfigChanged: (config) {
          config.savePath(chapter.getConfigPath);
        },
        // book mark
        bookmarkValue: provider.isExists(chapter.number),
        onBookmarkChanged: (currentChapter, bookmarkValue) async {
          if (bookmarkValue) {
            //remove
            await provider.toggle(
              chapter.getNovelPath,
              ChapterBookmarkModel(
                title: chapter.title,
                chapter: chapter.number,
              ),
            );
          } else {
            // add book
            final res = await showDialog<bool>(
              context: context,
              barrierDismissible: false,
              builder: (context) => AddBookmarkTitleDialog(
                chapter: currentChapter,
                readLine: globalReadLine,
                onSubmit: (title, readLine) async {
                  globalReadLine = readLine;
                  await provider.toggle(
                    chapter.getNovelPath,
                    ChapterBookmarkModel(
                      title: title,
                      chapter: chapter.number,
                    ),
                  );
                },
              ),
            );
            return res ?? false;
          }
          return false;
        },
      ),
    ),
  );
}

void goSeeAllScreenWithAuthor(
  BuildContext context,
  WidgetRef ref,
  String author,
) {
  final list = ref.read(novelNotifierProvider.notifier).getList;
  final res = list.where((nv) => nv.author == author).toList();
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => NovelSeeAllScreen(title: author, list: res),
    ),
  );
}

void goSeeAllScreenWithMC(
  BuildContext context,
  WidgetRef ref,
  String mc,
) {
  final list = ref.read(novelNotifierProvider.notifier).getList;
  final res = list.where((nv) => nv.mc == mc).toList();
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => NovelSeeAllScreen(title: mc, list: res),
    ),
  );
}
