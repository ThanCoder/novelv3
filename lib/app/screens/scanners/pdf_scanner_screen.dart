import 'package:flutter/material.dart';
import 'package:novel_v3/app/extensions/pdf_extension.dart';
import 'package:novel_v3/app/novel_dir_app.dart';
import 'package:novel_v3/app/routes_helper.dart';
import 'package:novel_v3/more_libs/setting_v2.0.0/others/index.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

typedef PdfScannerOnClickedCallback =
    void Function(BuildContext context, NovelPdf pdf);

class PdfScannerScreen extends StatefulWidget {
  PdfScannerOnClickedCallback? onClicked;

  PdfScannerScreen({super.key, this.onClicked});

  @override
  State<PdfScannerScreen> createState() => PdfScannerScreenState();
}

class PdfScannerScreenState extends State<PdfScannerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  bool isLoading = false;
  List<NovelPdf> list = [];
  int currentSortId = TSort.getDateId;
  bool isSortAsc = false;

  Future<void> init() async {
    try {
      // check storage persmission
      if (!await ThanPkg.platform.isStoragePermissionGranted()) {
        await ThanPkg.platform.requestStoragePermission();
        return;
      }

      setState(() {
        isLoading = true;
      });

      list = await PdfServices.getScanList();

      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      NovelDirApp.showDebugLog(e.toString(), tag: 'PdfScannerScreen:init');
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TScaffold(
      appBar: AppBar(
        title: Text('PDF Scanner'),
        actions: [
          _getSortWidget(),
          TPlatform.isDesktop
              ? IconButton(onPressed: init, icon: Icon(Icons.refresh))
              : SizedBox.shrink(),
        ],
      ),
      body: isLoading
          ? Center(child: TLoaderRandom())
          : list.isEmpty
          ? _getEmptyList()
          : RefreshIndicator.adaptive(
              onRefresh: init,
              child: CustomScrollView(slivers: [_getSliverList()]),
            ),
    );
  }

  Widget _getEmptyList() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('PDF Not Found...'),
          IconButton(
            color: Colors.blue,
            onPressed: init,
            icon: Icon(Icons.refresh_rounded),
          ),
        ],
      ),
    );
  }

  Widget _getSliverList() {
    return SliverList.builder(
      itemCount: list.length,
      itemBuilder: (context, index) => PdfListItem(
        cachePath: PathUtil.getCachePath(),
        pdf: list[index],
        onClicked: (pdf) => widget.onClicked?.call(context, pdf),
        onRightClicked: _showItemMenu,
      ),
    );
  }

  Widget _getSortWidget() {
    return IconButton(
      onPressed: () {
        showTSortDialog(
          context,
          currentId: currentSortId,
          sortDialogCallback: (id, isAsc) {
            currentSortId = id;
            isSortAsc = isAsc;
            _onSort();
          },
        );
      },
      icon: Icon(Icons.sort),
    );
  }

  void _onSort() {
    if (currentSortId == TSort.getTitleId) {
      list.sortTitle(aToZ: isSortAsc);
    }
    if (currentSortId == TSort.getDateId) {
      list.sortDate(isNewest: !isSortAsc);
    }
    setState(() {});
  }

  // remove ui pdf
  void removeUIPdf(NovelPdf pdf) {
    if (!mounted) return;
    // ui remove
    final index = list.indexWhere((e) => e.getTitle == pdf.getTitle);
    if (index == -1) return;
    list.removeAt(index);
    if (!mounted) return;
    setState(() {});
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
          title: Text('Rename'),
          onTap: () {
            closeContext(context);
            _rename(pdf);
          },
        ),
        ListTile(
          iconColor: Colors.red,
          leading: Icon(Icons.delete_forever_rounded),
          title: Text('Delete'),
          onTap: () {
            closeContext(context);
            _deleteConfirm(pdf);
          },
        ),
      ],
    );
  }

  void _rename(NovelPdf pdf) {
    showTReanmeDialog(
      context,
      barrierDismissible: false,
      title: Text('Rename'),
      submitText: 'Rename',
      text: pdf.getTitle.getName(withExt: false),
      onSubmit: (text) async {
        try {
          final index = list.indexWhere((e) => e.getTitle == pdf.getTitle);
          if (index == -1) return;
          await pdf.rename('${pdf.getParentPath}/$text.pdf');
          list[index] = pdf;

          if (!mounted) return;
          setState(() {});
        } catch (e) {
          NovelDirApp.showDebugLog(
            e.toString(),
            tag: 'PdfScannerScreen:_rename',
          );
        }
      },
    );
  }

  void _deleteConfirm(NovelPdf pdf) {
    showTConfirmDialog(
      context,
      submitText: 'Delete Forever!',
      contentText: 'ဖျက်ချင်တာ သေချာပြီလား?',
      onSubmit: () async {
        await pdf.delete();
        removeUIPdf(pdf);
      },
    );
  }
}
