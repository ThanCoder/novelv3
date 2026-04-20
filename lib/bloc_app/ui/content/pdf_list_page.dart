import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:novel_v3/bloc_app/bloc/novel_list_cubit.dart';
import 'package:novel_v3/bloc_app/bloc/pdf_list_cubit.dart';
import 'package:novel_v3/bloc_app/bloc_routes_func.dart';
import 'package:novel_v3/bloc_app/ui/components/file_copy_dialog_func.dart';
import 'package:novel_v3/bloc_app/ui/components/pdf_list_item.dart';
import 'package:novel_v3/bloc_app/ui/components/refresh_btn_component.dart';
import 'package:novel_v3/core/models/novel.dart';
import 'package:novel_v3/core/models/pdf_file.dart';
import 'package:novel_v3/core/extensions/build_context_extensions.dart';
import 'package:novel_v3/old_app/routes.dart';
import 'package:novel_v3/other_apps/pdf_scanner/pdf_scanner_screen.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

class PdfListPage extends StatefulWidget {
  final Novel novel;
  const PdfListPage({super.key, required this.novel});

  @override
  State<PdfListPage> createState() => _PdfListPageState();
}

class _PdfListPageState extends State<PdfListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  Future<void> init() async {
    await context.read<PdfListCubit>().fetchList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PdfListCubit, PdfListCubitState>(
      builder: (context, state) {
        return RefreshIndicator.adaptive(
          onRefresh: init,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                snap: true,
                floating: true,
                // pinned: true,
                automaticallyImplyLeading: false,
                title: state.list.isEmpty
                    ? null
                    : Text(
                        'Count: ${state.list.length}',
                        style: TextStyle(fontSize: 16),
                      ),
                actions: [
                  !TPlatform.isDesktop
                      ? SizedBox.shrink()
                      : IconButton(onPressed: init, icon: Icon(Icons.refresh)),
                  state.list.isEmpty
                      ? SizedBox.shrink()
                      : IconButton(
                          onPressed: () => _showSortDialog(state.sortAsc),
                          icon: Icon(Icons.sort),
                        ),
                  IconButton(
                    onPressed: _showMainMenu,
                    icon: Icon(Icons.more_vert),
                  ),
                ],
              ),
              if (state.isLoading)
                SliverFillRemaining(child: Center(child: TLoader.random()))
              else if (state.errorMessage.isNotEmpty)
                SliverFillRemaining(
                  child: Center(child: Text('Error: ${state.errorMessage}')),
                )
              else if (state.list.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: RefreshBtnComponent(
                      text: Text('Pdf မရှိပါ...'),
                      onClicked: init,
                    ),
                  ),
                )
              else
                _chapterList(state.list),
            ],
          ),
        );
      },
    );
  }

  Widget _chapterList(List<PdfFile> list) {
    return SliverList.separated(
      separatorBuilder: (context, index) => Divider(),
      itemCount: list.length,
      itemBuilder: (context, index) => _listItem(list[index]),
    );
  }

  Widget _listItem(PdfFile pdf) {
    return Card(
      child: PdfListItem(
        pdf: pdf,
        onClicked: (pdf) {
          goBlocPdfReader(context, pdf: pdf);
        },
        onRightClicked: _showItemMenu,
      ),
    );
  }

  void _showSortDialog(bool isAsc) {
    showTSortDialog(
      context,
      currentId: context.read<PdfListCubit>().state.sortId,
      isAsc: context.read<PdfListCubit>().state.sortAsc,
      sortList: PdfListCubit.sortList,
      sortDialogCallback: (id, isAsc) {
        context.read<PdfListCubit>().sort(id, isAsc);
      },
    );
  }

  void _showMainMenu() {
    showTMenuBottomSheet(
      context,
      children: [
        ListTile(
          iconColor: Colors.green,
          leading: Icon(Icons.add),
          title: Text('Add PDF Files'),
          onTap: () {
            context.closeNavigator();
            _addPdfFromScanner();
          },
        ),
      ],
    );
  }

  void _showItemMenu(PdfFile pdf) {
    showTMenuBottomSheet(
      context,
      children: [
        ListTile(
          iconColor: Colors.red,
          leading: Icon(Icons.delete_forever),
          title: Text('Delete PDF File'),
          onTap: () {
            context.closeNavigator();
            _deleteConfirm(pdf);
          },
        ),
        ListTile(
          iconColor: Colors.green,
          leading: Icon(Icons.now_wallpaper),
          title: Text('Set PDF Cover'),
          onTap: () {
            context.closeNavigator();
            _setCoverImage(pdf.getCoverPath);
          },
        ),
      ],
    );
  }

  void _setCoverImage(String path) async {
    try {
      final cover = File(path);
      if (!cover.existsSync()) return;
      await cover.copy(widget.novel.getCoverPath);
      if (!mounted) return;
      showTSnackBar(context, 'Novel Cover Added', showCloseIcon: true);
      context.read<NovelListCubit>().refreshState();
    } catch (e) {
      if (!mounted) return;
      showTMessageDialogError(context, e.toString());
    }
  }

  void _addPdfFromScanner() {
    goRoute(
      context,
      builder: (scannerMainContext) => PdfScannerScreen(
        title: Text('Add Multiple Pdf'),
        isMultipleSelected: true,
        onChoosed: (scannerContext, files) {
          scannerContext.closeNavigator();
          showFileCopyDialog(
            context,
            fileCopySources: files
                .map(
                  (e) => FileCopySource(
                    sourceFile: File(e.path),
                    destFile: File(pathJoin(widget.novel.path, e.title)),
                  ),
                )
                .toList(),
            onClosed: init,
          );
        },
      ),
    );
  }

  // item menu funcs
  void _deleteConfirm(PdfFile pdf) async {
    showTConfirmDialog(
      context,
      contentText: 'ဖျက်ချင်တာ သေချာပြီလား?',
      submitText: 'Delete Forever',
      onSubmit: () {
        context.read<PdfListCubit>().deleteForever(pdf);
      },
    );
  }
}
