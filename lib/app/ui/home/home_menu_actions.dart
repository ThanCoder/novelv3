import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:novel_v3/app/core/models/novel_meta.dart';
import 'package:novel_v3/app/others/novel_config/novel_config_services.dart';
import 'package:novel_v3/app/routes.dart';
import 'package:novel_v3/app/ui/home/create_novel_website_info_result_dialog.dart';
import 'package:novel_v3/app/ui/home/home_list_style_list_tile.dart';
import 'package:novel_v3/more_libs/fetcher_v1.0.0/screens/fetcher_web_novel_url_screen.dart';
import 'package:novel_v3/more_libs/fetcher_v1.0.0/types/website_info.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:novel_v3/app/core/models/pdf_file.dart';
import 'package:novel_v3/app/core/services/novel_services.dart';
import 'package:novel_v3/app/others/pdf_scanner/pdf_scanner_screen.dart';
import 'package:novel_v3/app/ui/forms/edit_novel_screen.dart';
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
        ListTile(
          leading: Icon(Icons.add),
          title: Text('Add Novel From Config.JSON'),
          onTap: () {
            closeContext(context);
            _addNewNovelFromConfigJson();
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
        final index = list.indexWhere((e) => e.meta.title == text);
        if (index != -1) {
          return 'title ရှိနေပြီးသားဖြစ်နေပါတယ်!...';
        }
        return null;
      },
      text: 'Untitled',
      onSubmit: (text) async {
        if (text.isEmpty) return;

        final novel = await NovelServices.createNovelFolder(
          meta: NovelMeta.create(title: text.trim()),
        );
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
        final index = list.indexWhere((e) => e.meta.title == (text.trim()));
        if (index != -1) {
          return 'title ရှိနေပြီးသားဖြစ်နေပါတယ်!...';
        }
        return null;
      },
      onSubmit: (text) async {
        if (text.isEmpty) return;
        try {
          final novel = await NovelServices.createNovelFolder(
            meta: NovelMeta.create(title: text.trim()),
          );
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

  void _addNewNovelFromConfigJson() async {
    try {
      const XTypeGroup typeGroup = XTypeGroup(
        label: 'Novel Meta Config File',
        extensions: <String>['.meta.json'],
      );
      final XFile? file = await openFile(
        initialDirectory: _initialDirectory,
        acceptedTypeGroups: <XTypeGroup>[typeGroup],
      );
      if (file == null) return;
      if (TPlatform.isDesktop) {
        _initialDirectory = File(file.path).parent.path;
      }
      final meta = await NovelConfigServices.getNovelMetaFromPath(file.path);
      if (meta == null) {
        throw Exception('Meta Is Null,Meta File မှာပြသနာရှိနေပါတယ်!...');
      }
      if (!mounted) return;

      final provider = context.read<NovelProvider>();
      final novel = await NovelServices.createNovelFolder(meta: meta);

      provider.add(novel);
      if (!mounted) return;
      goRoute(
        context,
        builder: (context) => EditNovelScreen(
          novel: novel,
          coverUrl: meta.coverUrl,
          onUpdated: (updatedNovel) {
            provider.update(updatedNovel);
          },
        ),
      );
    } catch (e) {
      if (!mounted) return;
      showTMessageDialogError(context, e.toString());
    }
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

String? _initialDirectory;
