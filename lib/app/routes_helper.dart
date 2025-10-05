import 'package:flutter/material.dart';
import 'package:novel_v3/app/others/chapter_reader/chapter_reader_config.dart';
import 'package:novel_v3/app/others/chapter_reader/chapter_reader_screen.dart';
import 'package:novel_v3/app/ui/main_ui/screens/content/novel_content_home_screen.dart';
import 'package:novel_v3/more_libs/pdf_readers_v1.2.3/screens/pdfrx_reader_screen.dart';
import 'package:novel_v3/more_libs/pdf_readers_v1.2.3/types/pdf_config.dart';
import 'package:novel_v3/more_libs/setting_v2.0.0/others/path_util.dart';
import 'package:provider/provider.dart';

import 'novel_dir_app.dart';

void goNovelSeeAllScreen(BuildContext context, String title, List<Novel> list) {
  novelSeeAllScreenNotifier.value = list;
  goRoute(context, builder: (context) => NovelSeeAllScreen(title: title));
}

Future<void> goNovelContentScreen(BuildContext context, Novel novel) async {
  await context.read<NovelProvider>().setCurrent(novel);
  if (!context.mounted) return;
  goRoute(context, builder: (context) => NovelContentHomeScreen());
}

// text reader
void goChapterReader(
  BuildContext context, {
  required Chapter chapter,
  OnChapterReaderCloseCallback? onReaderClosed,
}) {
  final configPath = PathUtil.getConfigPath(name: 'chapter_reader.config.json');
  goRoute(
    context,
    builder: (context) => ChapterReaderScreen(
      chapter: chapter,
      config: ChapterReaderConfig.fromPath(configPath),
      onUpdateConfig: (updatedConfig) {
        updatedConfig.savePath(configPath);
      },
      onReaderClosed: onReaderClosed,
    ),
  );
}

// pdf reader
void goPdfReader(BuildContext context, NovelPdf pdf) {
  goRoute(
    context,
    builder: (context) => PdfrxReaderScreen(
      title: pdf.getTitle,
      sourcePath: pdf.path,
      bookmarkPath: pdf.getBookmarkPath,
      pdfConfig: PdfConfig.fromPath(pdf.getConfigPath),
      onConfigUpdated: (pdfConfig) {
        //save config
        pdfConfig.savePath(pdf.getConfigPath);
      },
    ),
  );
}

void goRecentPdfReader(BuildContext context, NovelPdf pdf) {
  final configPath =
      '${PathUtil.getCachePath()}/${pdf.getTitle.replaceAll('.pdf', '.config.json')}';

  goRoute(
    context,
    builder: (context) => PdfrxReaderScreen(
      title: pdf.getTitle,
      sourcePath: pdf.path,
      pdfConfig: PdfConfig.fromPath(configPath),
      onConfigUpdated: (pdfConfig) {
        pdfConfig.savePath(configPath);
      },
    ),
  );
}

void closeContext(BuildContext context) {
  Navigator.pop(context);
}

void goRoute(
  BuildContext context, {
  required Widget Function(BuildContext context) builder,
}) {
  Navigator.push(context, MaterialPageRoute(builder: builder));
}
