import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:novel_v3/app/routes_helper.dart';
import 'package:novel_v3/app/ui/main_ui/screens/content/content_image_wrapper.dart';
import 'package:novel_v3/app/ui/main_ui/screens/scanners/pdf_scanner_screen.dart';
import 'package:novel_v3/more_libs/pdf_readers_v1.2.3/dialogs/edit_pdf_config_dialog.dart';
import 'package:novel_v3/more_libs/pdf_readers_v1.2.3/pdf_reader.dart';
import 'package:novel_v3/more_libs/setting_v2.0.0/others/index.dart';
import 'package:provider/provider.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

import '../../../../novel_dir_app.dart';

class ContentPdfPage extends StatefulWidget {
  const ContentPdfPage({super.key});

  @override
  State<ContentPdfPage> createState() => _ContentPdfPageState();
}

class _ContentPdfPageState extends State<ContentPdfPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  Future<void> init() async {
    final novel = context.read<NovelProvider>().getCurrent;
    if (novel == null) return;
    await context.read<PdfProvider>().initList(novel.path);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PdfProvider>();
    final isLoading = provider.isLoading;
    final list = provider.getList;

    return ContentImageWrapper(
      appBarAction: [
        _getSortAction(),
        IconButton(onPressed: _showMenu, icon: Icon(Icons.more_vert_rounded)),
      ],
      title: Text('PDF'),
      isLoading: isLoading,
      automaticallyImplyLeading: TPlatform.isDesktop,
      sliverBuilder: (context, novel) => [_getSliverList(list)],
      onRefresh: init,
    );
  }

  Widget _getSortAction() {
    final provider = context.read<PdfProvider>();
    return IconButton(
      onPressed: () {
        showTSortDialog(
          context,
          currentId: provider.currentSortId,
          isAsc: provider.isSortAsc,
          sortDialogCallback: (id, isAsc) {
            provider.setSort(id, isAsc);
          },
        );
      },
      icon: Icon(Icons.sort),
    );
  }

  Widget _getEmptyListWidget() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('List မရှိပါ...'),
          IconButton(
            color: Colors.blue,
            onPressed: _goAddPdfPage,
            icon: Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  Widget _getSliverList(List<NovelPdf> list) {
    if (list.isEmpty) {
      return SliverFillRemaining(child: _getEmptyListWidget());
    }
    return SliverList.builder(
      itemCount: list.length,
      itemBuilder: (context, index) => PdfListItem(
        pdf: list[index],
        isEnableRecent: list.length > 1,
        onClicked: (pdf) async {
          // set recent
          await PdfServices.setRecent(
            novelId: pdf.getParentPath.getName(),
            pdfName: pdf.getTitle,
          );
          if (!context.mounted) return;
          setState(() {});
          goPdfReader(context, pdf);
        },
        onRightClicked: _showItemMenu,
      ),
      // separatorBuilder: (context, index) => Divider(),
    );
  }

  String get getNovelPath {
    final novel = context.read<NovelProvider>().getCurrent;
    if (novel == null) '';
    return novel!.path;
  }

  // main menu
  void _showMenu() {
    showTMenuBottomSheet(
      context,
      children: [
        ListTile(
          leading: Icon(Icons.add),
          title: Text('Add PDF'),
          onTap: () {
            closeContext(context);
            _goAddPdfPage();
          },
        ),
      ],
    );
  }

  // pdf scanner အတွက် global key
  final GlobalKey<PdfScannerScreenState> _pdfScannerScreenState = GlobalKey();

  void _goAddPdfPage() {
    final novel = context.read<NovelProvider>().getCurrent;
    if (novel == null) return;
    goRoute(
      context,
      builder: (context) => PdfScannerScreen(
        key: _pdfScannerScreenState,
        onClicked: (context, pdf) {
          // closeContext(context);
          _showPdfMenu(pdf);
        },
      ),
    );
  }

  // pdf chooser menu
  void _showPdfMenu(NovelPdf pdf) {
    showTMenuBottomSheet(
      context,
      children: [
        Padding(padding: const EdgeInsets.all(8.0), child: Text(pdf.getTitle)),
        Divider(),
        ListTile(
          leading: Icon(Icons.launch),
          title: Text('Open PDF Reader'),
          onTap: () {
            closeContext(context);
            _goPdfReader(pdf);
          },
        ),
        ListTile(
          leading: Icon(Icons.info_outline_rounded),
          title: Text('Infomation'),
          onTap: () {
            closeContext(context);
            _showPdfInfo(pdf);
          },
        ),
        ListTile(
          leading: Icon(Icons.copy),
          title: Text('Copy Name'),
          onTap: () {
            closeContext(context);
            ThanPkg.appUtil.copyText(pdf.getTitle);
          },
        ),
        ListTile(
          leading: Icon(Icons.add),
          title: Text('Novel ထဲကို ရွေ့မယ် (Move)'),
          onTap: () {
            closeContext(context);
            _moveInPdf(pdf);
          },
        ),
        ListTile(
          leading: Icon(Icons.copy),
          title: Text('Novel ထဲကို ကူးမယ် (Copy)'),
          onTap: () {
            closeContext(context);
            _copyPdf(pdf);
          },
        ),
        ListTile(
          leading: Icon(Icons.image),
          title: Text('Set Cover'),
          onTap: () {
            closeContext(context);
            _setCover(pdf);
          },
        ),
      ],
    );
  }

  void _goPdfReader(NovelPdf pdf) {
    goRecentPdfReader(context, pdf);
  }

  void _moveInPdf(NovelPdf pdf) async {
    try {
      await pdf.rename('$getNovelPath/${pdf.getTitle}');
      if (!mounted) return;
      context.read<PdfProvider>().initList(getNovelPath);

      _pdfScannerScreenState.currentState?.removeUIPdf(pdf);
    } catch (e) {
      NovelDirApp.showDebugLog(e.toString());
    }
  }

  void _copyPdf(NovelPdf pdf) async {
    try {
      final pdfFile = File(pdf.path);
      final novelPdfFile = File('$getNovelPath/${pdf.getTitle}');

      // async copy
      await pdfFile.copy(novelPdfFile.path);

      if (!mounted) return;
      context.read<PdfProvider>().initList(getNovelPath);
      NovelDirApp.instance.showMessage(context, 'PDF ကူးယူပြီးပါပြီ');
    } catch (e) {
      NovelDirApp.showDebugLog(e.toString());
    }
  }

  void _setCover(NovelPdf pdf) async {
    try {
      final novel = context.read<NovelProvider>().getCurrent;
      if (novel == null) return;
      final coverFile = File(pdf.getCoverPath);
      final novelCoverFile = File(novel.getCoverPath);
      if (coverFile.existsSync()) {
        await novelCoverFile.writeAsBytes(coverFile.readAsBytesSync());
        await ThanPkg.appUtil.clearImageCache();
        if (!mounted) return;
        setState(() {});
        NovelDirApp.instance.showMessage(context, 'Cover ထည့်သွင်းပြီးပါပြီ');
      }
    } catch (e) {
      NovelDirApp.showDebugLog(e.toString());
    }
  }

  void _showPdfInfo(NovelPdf pdf) {
    showTMessageDialog(
      context,
      'Title: ${pdf.getTitle}\nSize: ${pdf.getSize}\nရက်စွဲ: ${pdf.getDate.toParseTime()}\nPath: ${pdf.path}',
    );
  }

  // item menu
  void _showItemMenu(NovelPdf pdf) {
    showTMenuBottomSheet(
      context,
      children: [
        Padding(padding: const EdgeInsets.all(8.0), child: Text(pdf.getTitle)),
        Divider(),
        ListTile(
          leading: Icon(Icons.edit_document),
          title: Text('အမည်ပြောင်းလဲမယ် (Rename)'),
          onTap: () {
            closeContext(context);
            _renamePdf(pdf);
          },
        ),
        ListTile(
          iconColor: Colors.orange,
          leading: Icon(Icons.restore),
          title: Text('အပြင်ကို ပြန်ရွှေ့ (Move)'),
          onTap: () {
            closeContext(context);
            _moveOutPdf(pdf);
          },
        ),
        ListTile(
          iconColor: Colors.green,
          leading: Icon(Icons.restore),
          title: Text('အပြင်ကို ကူးထုတ် (Copy)'),
          onTap: () {
            closeContext(context);
            _moveOutCopyPdf(pdf);
          },
        ),
        ListTile(
          leading: Icon(Icons.edit_document),
          title: Text('Edit PDF Config'),
          onTap: () {
            closeContext(context);
            _editPdfConfigCover(pdf);
          },
        ),
        ListTile(
          leading: Icon(Icons.image),
          title: Text('Set Cover'),
          onTap: () {
            closeContext(context);
            _setCover(pdf);
          },
        ),
        ListTile(
          iconColor: Colors.red,
          leading: Icon(Icons.delete_forever_rounded),
          title: Text('Delete'),
          onTap: () {
            closeContext(context);
            _deleteConfirmPdf(pdf);
          },
        ),
      ],
    );
  }

  void _editPdfConfigCover(NovelPdf pdf) {
    showCupertinoDialog(
      context: context,
      builder: (context) => EditPdfConfigDialog(
        title: Text('PDF Config'),
        pdfConfig: PdfConfig.fromPath(pdf.getConfigPath),
        onUpdated: (updatedConfig) {
          updatedConfig.savePath(pdf.getConfigPath);
          showTSnackBar(context, 'Config Saved');
        },
      ),
    );
  }

  void _deleteConfirmPdf(NovelPdf pdf) {
    showTConfirmDialog(
      context,
      submitText: 'Delete Forever!',
      contentText: 'ဖျက်ချင်တာ သေချာပြီလား',
      onSubmit: () {
        context.read<PdfProvider>().delete(pdf);
      },
    );
  }

  void _moveOutPdf(NovelPdf pdf) async {
    await pdf.rename('${PathUtil.getOutPath()}/${pdf.getTitle}');
    if (!mounted) return;
    context.read<PdfProvider>().removeUI(pdf);
  }

  void _moveOutCopyPdf(NovelPdf pdf) async {
    await pdf.copy('${PathUtil.getOutPath()}/${pdf.getTitle}');
    if (!mounted) return;
    showTSnackBar(context, 'ကူးထုတ်ပြီးပါပြီ...');
  }

  void _renamePdf(NovelPdf pdf) {
    showTReanmeDialog(
      context,
      text: pdf.path.getName(withExt: false),
      barrierDismissible: false,
      onSubmit: (text) async {
        try {
          if (text.isEmpty) return;
          await pdf.renameTitle('${text.trim()}.pdf');
          if (!mounted) return;
          init();
        } catch (e) {
          if (!mounted) return;
          showTMessageDialogError(context, e.toString());
        }
      },
    );
  }
}
