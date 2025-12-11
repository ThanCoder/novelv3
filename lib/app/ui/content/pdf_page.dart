import 'package:flutter/material.dart';
import 'package:novel_v3/app/core/models/pdf_file.dart';
import 'package:novel_v3/app/core/providers/novel_provider.dart';
import 'package:novel_v3/app/core/providers/pdf_provider.dart';
import 'package:novel_v3/app/others/pdf_reader/screens/pdfrx_reader_screen.dart';
import 'package:novel_v3/app/others/pdf_reader/types/pdf_config.dart';
import 'package:novel_v3/app/routes.dart';
import 'package:novel_v3/app/ui/components/file_on_drop_wiget.dart';
import 'package:novel_v3/app/ui/components/pdf_file_list_item.dart';
import 'package:novel_v3/app/ui/components/sort_dialog_action.dart';
import 'package:novel_v3/app/ui/content/pdf_item_menu_bottom_sheet.dart';
import 'package:novel_v3/app/ui/content/pdf_menu_botton_sheet.dart';
import 'package:novel_v3/app/ui/content/pdf_rc_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

class PdfPage extends StatefulWidget {
  const PdfPage({super.key});

  @override
  State<PdfPage> createState() => _PdfPageState();
}

class _PdfPageState extends State<PdfPage> {
  final controller = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  String? novelPath;
  Future<void> init() async {
    novelPath = context.read<NovelProvider>().currentNovel!.path;
    await context.read<PdfProvider>().init(novelPath!);
    setState(() {});
  }

  PdfProvider get getWProvider => context.watch<PdfProvider>();

  @override
  Widget build(BuildContext context) {
    return FileOnDropWiget(
      onTest: (path) => path.endsWith('.pdf'),
      onDragDone: _addPdfConfirmDialog,
      child: Scaffold(
        body: getWProvider.isLoading
            ? Center(child: TLoader.random())
            : RefreshIndicator.adaptive(
                onRefresh: init,
                child: CustomScrollView(
                  controller: controller,
                  slivers: [_getAppbar(), _getList()],
                ),
              ),
      ),
    );
  }

  Widget _getAppbar() {
    return SliverAppBar(
      automaticallyImplyLeading: false,
      pinned: false,
      floating: true,
      snap: true,
      title: _getRecentButton(),
      actions: [
        !TPlatform.isDesktop
            ? SizedBox.shrink()
            : IconButton(onPressed: init, icon: Icon(Icons.refresh)),
        // sort
        SortDialogAction(
          isAsc: getWProvider.sortAsc,
          currentId: getWProvider.currentSortId,
          sortList: getWProvider.sortList,
          sortDialogCallback: (id, isAsc) {
            context.read<PdfProvider>().sort(id, isAsc);
          },
        ),
        IconButton(
          onPressed: () {
            showTMenuBottomSheetSingle(
              context,
              child: PdfMenuBottonSheet(onClosed: () => closeContext(context)),
            );
          },
          icon: Icon(Icons.more_vert_rounded),
        ),
      ],
    );
  }

  Widget? _getRecentButton() {
    return _getRecentName() == ''
        ? null
        : TextButton(onPressed: _goRecentPdf, child: Text('Recent PDF'));
  }

  Widget _getList() {
    if (getWProvider.list.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 3,
            children: [
              Text(
                'List Empty!...',
                style: TextTheme.of(context).headlineSmall,
              ),
              IconButton(
                onPressed: init,
                icon: Icon(Icons.refresh, color: Colors.blue),
              ),
            ],
          ),
        ),
      );
    }
    return SliverList.builder(
      itemCount: getWProvider.list.length,
      itemBuilder: (context, index) => _getListItem(getWProvider.list[index]),
    );
  }

  Widget _getListItem(PdfFile pdf) {
    return PdfFileListItem(
      pdf: pdf,
      cardColor: _getRecentName() == pdf.title
          ? const Color.fromARGB(45, 33, 149, 243)
          : null,
      onClicked: (pdf) => _goReader(pdf),
      onRightClicked: _showItemMenu,
    );
  }

  String _getRecentName() {
    if (novelPath != null) {
      final recent = TRecentDB.getInstance.getString(
        'recent-pdf-name:${novelPath!.getName()}',
      );
      if (recent.isEmpty) return '';
      return recent;
    }
    return '';
  }

  void _showItemMenu(PdfFile pdf) {
    showTMenuBottomSheetSingle(
      context,
      title: Text(pdf.title),
      child: PdfItemMenuBottomSheet(
        pdf: pdf,
        onClosedMenu: () {
          if (!mounted) return;
          closeContext(context);
        },
      ),
    );
  }

  void _goReader(PdfFile pdf) async {
    if (novelPath == null) return;
    final configPath = pdf.getCurrentConfigPath;
    // set recent
    await TRecentDB.getInstance.putString(
      'recent-pdf-name:${novelPath!.getName()}',
      pdf.title,
    );
    if (!mounted) return;
    setState(() {});
    goRoute(
      context,
      builder: (context) => PdfrxReaderScreen(
        sourcePath: pdf.path,
        title: pdf.title,
        pdfConfig: PdfConfig.fromPath(configPath),
        bookmarkPath: pdf.getCurrentBookmarkConfigPath,
        onConfigUpdated: (pdfConfig) async {
          pdfConfig.savePath(configPath);
          if (!mounted) return;
          setState(() {});
        },
      ),
    );
  }

  void _goRecentPdf() async {
    final list = context.read<PdfProvider>().list;
    final index = list.indexWhere((e) => e.title == _getRecentName());
    if (index == -1) {
      TRecentDB.getInstance.delete('recent-pdf-name:${novelPath!.getName()}');
      setState(() {});
      return;
    }
    _goReader(list[index]);
  }

  // file drop
  void _addPdfConfirmDialog(List<String> files) {
    if (files.isEmpty) {
      showTMessageDialogError(context, 'PDF file ပဲလက်ခံပါတယ်!...');
      return;
    }
    showTMenuBottomSheetSingle(
      context,
      child: PdfRcBottomSheet(
        files: files,
        onClosed: () => closeContext(context),
      ),
    );
  }
}
