import 'package:flutter/material.dart';
import 'package:novel_v3/app/models/chapter_bookmark_model.dart';
import 'package:novel_v3/app/models/index.dart';
import 'package:novel_v3/app/models/pdf_model.dart';
import 'package:novel_v3/app/pdf_readers/pdfrx_reader_screen.dart';
import 'package:novel_v3/app/provider/chapter_bookmark_provider.dart';
import 'package:novel_v3/app/provider/novel_provider.dart';
import 'package:novel_v3/app/screens/novel_content_screen.dart';
import 'package:novel_v3/app/screens/novel_edit_form_screen.dart';
import 'package:novel_v3/app/text_reader/text_reader_config_model.dart';
import 'package:novel_v3/app/text_reader/text_reader_screen.dart';
import 'package:provider/provider.dart';

void goNovelContentPage(BuildContext context, NovelModel novel) async {
  await context.read<NovelProvider>().setCurrent(novel);
  if (!context.mounted) return;
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => NovelContentScreen(novel: novel),
    ),
  );
}

void goPdfReader(BuildContext context, PdfModel pdf) async {
  if (!context.mounted) return;
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => PdfrxReaderScreen(
        title: pdf.title,
        pdfConfig: PdfConfigModel.fromPath(pdf.configPath),
        sourcePath: pdf.path,
        saveConfig: (pdfConfig) {
          pdfConfig.savePath(pdf.configPath);
        },
      ),
    ),
  );
}

void goTextReader(BuildContext context, ChapterModel chapter) async {
  final provider = context.read<ChapterBookmarkProvider>();
  await provider.initList(chapter.getNovelPath);

  if (!context.mounted) return;
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => TextReaderScreen(
        data: chapter,
        bookmarkValue: provider.isExists(chapter.number),
        onBookmarkChanged: (bookmarkValue) {
          provider.toggle(
            chapter.getNovelPath,
            ChapterBookmarkModel(
              title: chapter.title,
              chapter: chapter.number,
            ),
          );
        },
        config: TextReaderConfigModel.fromPath(chapter.getConfigPath),
        onConfigChanged: (config) {
          config.savePath(chapter.getConfigPath);
        },
      ),
    ),
  );
}

void goNovelEditForm(BuildContext context, NovelModel novel) async {
  await context.read<NovelProvider>().setCurrent(novel);
  if (!context.mounted) return;
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => NovelEditFormScreen(novel: novel),
    ),
  );
}
