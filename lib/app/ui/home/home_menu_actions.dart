import 'dart:io';

import 'package:flutter/material.dart';
import 'package:novel_v3/app/routes.dart';
import 'package:novel_v3/app/ui/home/create_novel_website_info_result_dialog.dart';
import 'package:novel_v3/app/ui/home/home_list_style_list_tile.dart';
import 'package:novel_v3/more_libs/fetcher_v1.0.0/screens/fetcher_web_novel_url_screen.dart';
import 'package:novel_v3/more_libs/fetcher_v1.0.0/types/website_info.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:novel_v3/app/core/models/pdf_file.dart';
import 'package:novel_v3/app/core/services/novel_services.dart';
import 'package:novel_v3/app/others/pdf_scanner/pdf_scanner_screen.dart';
import 'package:novel_v3/app/ui/forms/edit_novel/edit_novel_screen.dart';
import 'package:provider/provider.dart';
import 'package:novel_v3/app/core/providers/novel_provider.dart';
import 'package:than_pkg/than_pkg.dart';

class HomeMenuActions extends StatefulWidget {
  const HomeMenuActions({super.key});

  @override
  State<HomeMenuActions> createState() => _HomeMenuActionsState();
}

class _HomeMenuActionsState extends State<HomeMenuActions> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _showMainMenu,
      icon: Icon(Icons.more_vert_rounded),
    );
  }

  void _showMainMenu() {
    showTMenuBottomSheet(
      context,
      children: [
        ListTile(
          leading: Icon(Icons.add),
          title: Text('New'),
          onTap: () {
            closeContext(context);
            _showAddMainMenu();
          },
        ),
        HomeListStyleListTile(onCloseParent: () => Navigator.pop(context)),
      ],
    );
  }

  // add main menu
  void _showAddMainMenu() {
    showTMenuBottomSheet(
      context,
      children: [
        ListTile(
          leading: Icon(Icons.add),
          title: Text('Add Novel'),
          onTap: () {
            closeContext(context);
            _addNewNovel();
          },
        ),
        ListTile(
          leading: Icon(Icons.add),
          title: Text('Add Novel From PDF'),
          onTap: () {
            closeContext(context);
            _addNewNovelFromPdf();
          },
        ),
        ListTile(
          leading: Icon(Icons.add),
          title: Text('Add Novel From Url'),
          onTap: () {
            closeContext(context);
            _addNewNovelFromUrl();
          },
        ),
      ],
    );
  }

  void _addNewNovel() {
    final provider = context.read<NovelProvider>();
    final list = provider.list;

    showTReanmeDialog(
      context,
      barrierDismissible: false,
      submitText: 'New',
      title: Text('New Title'),
      onCheckIsError: (text) {
        final index = list.indexWhere((e) => e.title == text);
        if (index != -1) {
          return 'title ရှိနေပြီးသားဖြစ်နေပါတယ်!...';
        }
        return null;
      },
      text: 'Untitled',
      onSubmit: (text) async {
        if (text.isEmpty) return;

        final novel = await NovelServices.createNovelWithTitle(text.trim());
        if (novel == null) {
          if (!mounted) return;
          showTMessageDialogError(
            context,
            'Novel: `${text.trim()}` ဖန်တီးလို့ရမပါ',
          );
          return;
        }
        provider.add(novel);
        if (!mounted) return;
        goRoute(
          context,
          builder: (context) => EditNovelScreen(
            novel: novel,
            onUpdated: (updatedNovel) {
              provider.update(updatedNovel);
            },
          ),
        );
      },
    );
  }

  // create form pdf
  void _addNewNovelFromPdf() {
    goRoute(
      context,
      builder: (context) => PdfScannerScreen(
        onClicked: (pdfCtx, pdf) async {
          closeContext(pdfCtx);
          _createPdfWithNovel(pdf);
        },
      ),
    );
  }

  // create with rename novel dialog
  void _createPdfWithNovel(PdfFile pdf) {
    final provider = context.read<NovelProvider>();
    final list = provider.list;
    // rename novel title
    showTReanmeDialog(
      context,
      barrierDismissible: false,
      autofocus: true,
      submitText: 'New',
      title: Text('New Novel'),
      text: pdf.title.getName(withExt: false),
      onCheckIsError: (text) {
        final index = list.indexWhere((e) => e.title == (text.trim()));
        if (index != -1) {
          return 'title ရှိနေပြီးသားဖြစ်နေပါတယ်!...';
        }
        return null;
      },
      onSubmit: (text) async {
        if (text.isEmpty) return;
        try {
          final novel = await NovelServices.createNovelWithTitle(text.trim());
          if (novel == null) {
            throw Exception('Novel `${text.trim()}` Create Failed!');
          }
          // copy cover
          final pdfCoverFile = File(pdf.getCoverPath);
          if (pdfCoverFile.existsSync()) {
            await pdfCoverFile.copy(novel.getCoverPath);
          }
          // move pdf file to novel
          final pdfFile = File(pdf.path);
          if (pdfFile.existsSync()) {
            await pdfFile.rename(pathJoin(novel.path, pdf.title));
          }
          await provider.add(novel);

          if (!mounted) return;
          goRoute(
            context,
            builder: (context) => EditNovelScreen(
              novel: novel,
              onUpdated: (updatedNovel) {
                context.read<NovelProvider>().update(updatedNovel);
              },
            ),
          );
        } catch (e) {
          showTMessageDialogError(context, e.toString());
        }
      },
    );
  }

  void _addNewNovelFromUrl() {
    goRoute(
      context,
      builder: (context) =>
          FetcherWebNovelUrlScreen(url: '', onSaved: _createNovelWithWebResult),
    );
  }

  void _createNovelWithWebResult(WebsiteInfoResult result) async {
    if (result.title == null) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CreateNovelWebsiteInfoResultDialog(
        result: result,
        onSuccess: (novel) {
          context.read<NovelProvider>().add(novel);
        },
      ),
    );
  }
}
