import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:novel_v3/bloc_app/bloc/pdf_list_cubit.dart';
import 'package:novel_v3/bloc_app/bloc_routes_func.dart';
import 'package:novel_v3/bloc_app/ui/components/refresh_btn_component.dart';
import 'package:novel_v3/core/models/novel.dart';
import 'package:novel_v3/core/models/pdf_file.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/extensions/t_platform.dart';

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
                  IconButton(onPressed: () {}, icon: Icon(Icons.more_vert)),
                ],
              ),
              if (state.isLoading)
                SliverFillRemaining(child: Center(child: TLoader.random()))
              else if (state.errorMessage != null)
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
    return ListTile(
      textColor: Theme.brightnessOf(context).isDark
          ? Colors.white
          : Colors.black,
      titleTextStyle: TextStyle(fontSize: 13),
      title: Text(
        pdf.title,
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(pdf.getSize.fileSizeLabel()),
      onTap: () {
        goBlocPdfReader(context, pdf: pdf);
      },
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
}
