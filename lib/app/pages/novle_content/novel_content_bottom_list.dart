import 'dart:io';

import 'package:flutter/material.dart';
import 'package:novel_v3/app/components/app_components.dart';
import 'package:novel_v3/app/components/novel_content/index.dart';
import 'package:novel_v3/app/dialogs/novel_page_link_dialog.dart';
import 'package:novel_v3/app/models/index.dart';
import 'package:novel_v3/app/models/novel_model.dart';
import 'package:novel_v3/app/notifiers/novel_notifier.dart';
import 'package:novel_v3/app/screens/pdf_screens/pdf_reader_screen.dart';
import 'package:novel_v3/app/services/index.dart';
import 'package:than_pkg/than_pkg.dart';

import '../../screens/novel_screens/chapter_text_reader_screen.dart';

class NovelContentBottomList extends StatefulWidget {
  NovelModel novel;
  NovelContentBottomList({super.key, required this.novel});

  @override
  State<NovelContentBottomList> createState() => _NovelContentBottomListState();
}

class _NovelContentBottomListState extends State<NovelContentBottomList> {
  bool isExistsFile(String path) {
    final file = File(path);
    return file.existsSync();
  }

  void _openPageUrl(String url) async {
    try {
      await ThanPkg.platform.launch(url);
    } catch (e) {
      if (!mounted) return;
      showMessage(
          context, 'Url မဖွင့်နိုင်ဘူး! ဒါကြောင့် copy ကူးပေးလိုက်ပါတယ်');
      copyText(url);
      debugPrint(e.toString());
    }
  }

  void _showPageDialog(String pageUrl) {
    final file = File(pageUrl);
    final content = file.readAsStringSync();
    if (content.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => NovelPageLinkDialog(
        pageUrl: content,
        onClick: _openPageUrl,
      ),
    );
  }

  Widget getRecentTextButton(NovelModel novel) {
    final chapterTitle = getRecentDB<String>(
            'chapter_list_page_${currentNovelNotifier.value!.title}') ??
        '';
    final file = File('${currentNovelNotifier.value!.path}/$chapterTitle');
    if (file.existsSync()) {
      return ElevatedButton(
        onPressed: () {
          //go reader
          currentChapterNotifier.value = ChapterModel.fromFile(file);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ChapterTextReaderScreen(),
            ),
          );
        },
        child: const Text('မကြာခင်က Text'),
      );
    }
    return Container();
  }

  Widget getRecentPdfButton(NovelModel novel) {
    final pdfTitle = getRecentDB<String>(
            'pdf_list_page_${currentNovelNotifier.value!.title}') ??
        '';
    final file = File('${currentNovelNotifier.value!.path}/$pdfTitle');
    if (file.existsSync()) {
      return ElevatedButton(
        onPressed: () {
          //go reader
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  PdfReaderScreen(pdfFile: PdfFileModel.fromPath(file.path)),
            ),
          );
        },
        child: const Text('မကြာခင်က PDF'),
      );
    }
    return Container();
  }

  Widget getPageButton(NovelModel novel) {
    final file = File('${novel.path}/link');
    if (file.existsSync() && file.readAsStringSync().isNotEmpty) {
      return ElevatedButton(
        onPressed: () {
          _showPageDialog('${novel.path}/link');
        },
        child: const Text('Go Page'),
      );
    }
    return const SizedBox.shrink();
  }

  Widget getStartButton(NovelModel novel) {
    return isExistsFile('${novel.path}/1')
        ? ElevatedButton(
            onPressed: () {
              final chapter = ChapterModel.fromPath('${novel.path}/1');
              currentChapterNotifier.value = chapter;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChapterTextReaderScreen(),
                ),
              );
            },
            child: const Text('Start Read'),
          )
        : Container();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          spacing: 5,
          children: [
            //page
            getPageButton(widget.novel),
            //start Chapter
            getStartButton(widget.novel),
            //readed
            NovelContentReadedBotttom(novel: widget.novel),
            //recent go page
            getRecentTextButton(widget.novel),
            //recent pdf
            getRecentPdfButton(widget.novel),
          ],
        ),
      ),
    );
  }
}
