import 'dart:io';

import 'package:flutter/material.dart';
import 'package:novel_v3/app/core/models/pdf_file.dart';
import 'package:novel_v3/app/others/pdf_scanner/pdf_extension.dart';
import 'package:novel_v3/app/others/pdf_scanner/pdf_list_item.dart';
import 'package:novel_v3/app/others/pdf_scanner/pdf_scanner.dart';
import 'package:novel_v3/app/routes.dart';
import 'package:novel_v3/more_libs/setting/core/path_util.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

typedef PdfScannerOnClickedCallback =
    void Function(BuildContext context, PdfFile pdf);
typedef PdfScannerOnMultiChoosedCallback =
    void Function(BuildContext context, List<PdfFile> files);

class PdfScannerScreen extends StatefulWidget {
  final PdfScannerOnClickedCallback? onClicked;
  final PdfScannerOnMultiChoosedCallback? onChoosed;
  final bool isMultipleSelected;
  const PdfScannerScreen({
    super.key,
    this.onClicked,
    this.onChoosed,
    this.isMultipleSelected = false,
  });

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
  List<PdfFile> list = [];
  int currentSortId = TSort.getDateId;
  bool isSortAsc = false;
  bool isAllSelected = false;
  List<PdfFile> selectedList = [];

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

      list = await PdfScanner().scan();

      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    } catch (e) {
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
          !widget.isMultipleSelected
              ? SizedBox.shrink()
              : Text('Count: ${selectedList.length}'),
          !widget.isMultipleSelected
              ? SizedBox.shrink()
              : Checkbox.adaptive(
                  value: isAllSelected,
                  onChanged: (value) {
                    isAllSelected = value!;
                    _onSelectAll();
                  },
                ),
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
      bottomNavigationBar: !widget.isMultipleSelected
          ? null
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () =>
                        widget.onChoosed?.call(context, selectedList),
                    child: Text('Choose'),
                  ),
                ],
              ),
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
        onExists: (pdf) {
          final index = selectedList.indexWhere((e) => e.title == pdf.title);
          return index != -1;
        },
        pdf: list[index],
        onClicked: _onItemClicked,
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
          isAsc: isSortAsc,
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

  void _onItemClicked(PdfFile pdf) {
    if (!widget.isMultipleSelected) {
      widget.onClicked?.call(context, pdf);
      return;
    }
    // is multi
    if (selectedList.isEmpty) {
      selectedList.add(pdf);
    } else {
      // check
      final index = selectedList.indexWhere((e) => e.title == pdf.title);
      if (index == -1) {
        selectedList.add(pdf);
      }
      //remove
      else {
        selectedList.removeAt(index);
      }
    }
    setState(() {});
  }

  void _onSelectAll() {
    selectedList.clear();
    if (isAllSelected) {
      selectedList.addAll(list);
    }
    setState(() {});
  }

  // remove ui pdf
  void removeUIPdf(PdfFile pdf) {
    if (!mounted) return;
    // ui remove
    final index = list.indexWhere((e) => e.title == pdf.title);
    if (index == -1) return;
    list.removeAt(index);
    if (!mounted) return;
    setState(() {});
  }

  // item menu
  void _showItemMenu(PdfFile pdf) {
    showTMenuBottomSheet(
      context,
      children: [
        Padding(padding: const EdgeInsets.all(8.0), child: Text(pdf.title)),
        Divider(),
        ListTile(
          leading: Icon(Icons.info),
          title: Text('Infomation'),
          onTap: () {
            closeContext(context);
            _showInfo(pdf);
          },
        ),
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

  void _showInfo(PdfFile pdf) {
    final mime = lookupMimeType(pdf.path);
    showTMenuBottomSheet(
      context,
      title: Text('အချက်အလက်များ'),
      children: [
        Row(
          children: [
            Icon(Icons.title),
            Expanded(child: Text(pdf.title)),
          ],
        ),
        mime == null
            ? SizedBox.shrink()
            : Row(children: [Text('MimeType: '), Text(mime)]),
        Row(
          children: [
            Icon(Icons.sd_card),
            Expanded(child: Text(pdf.getSize.toFileSizeLabel())),
          ],
        ),
        Row(
          children: [
            Icon(Icons.date_range),
            Expanded(child: Text(pdf.date.toParseTime())),
          ],
        ),
        Row(
          children: [
            Icon(Icons.folder),
            Expanded(child: Text(File(pdf.path).parent.path)),
          ],
        ),
        SizedBox(height: 30),
      ],
    );
  }

  void _rename(PdfFile pdf) {
    // showTReanmeDialog(
    //   context,
    //   barrierDismissible: false,
    //   title: Text('Rename'),
    //   submitText: 'Rename',
    //   text: pdf.title.getName(withExt: false),
    //   onSubmit: (text) async {
    //     try {
    //       final index = list.indexWhere((e) => e.title == pdf.title);
    //       if (index == -1) return;
    //       await pdf.rename('${pdf.getParentPath}/$text.pdf');
    //       list[index] = pdf;

    //       if (!mounted) return;
    //       setState(() {});
    //     } catch (e) {
    //       NovelDirApp.showDebugLog(
    //         e.toString(),
    //         tag: 'PdfScannerScreen:_rename',
    //       );
    //     }
    //   },
    // );
  }

  void _deleteConfirm(PdfFile pdf) {
    showTConfirmDialog(
      context,
      submitText: 'Delete Forever!',
      contentText: 'ဖျက်ချင်တာ သေချာပြီလား?',
      onSubmit: () async {
        await pdf.deleteForever();
        removeUIPdf(pdf);
      },
    );
  }
}
