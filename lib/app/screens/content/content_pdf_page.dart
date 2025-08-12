import 'package:flutter/material.dart';
import 'package:novel_v3/app/screens/content/content_image_wrapper.dart';
import 'package:novel_v3/more_libs/sort_dialog_v1.0.0/sort_component.dart';
import 'package:provider/provider.dart';
import 'package:than_pkg/than_pkg.dart';

import '../../novel_dir_app.dart';

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
      title: Text('PDF'),
      isLoading: isLoading,
      automaticallyImplyLeading: PlatformExtension.isDesktop(),
      sliverBuilder: (context, novel) => [_getSliverList(list)],
      onRefresh: init,
      appBarAction: [_getSortAction()],
    );
  }

  Widget _getSortAction() {
    return SortComponent(
      value: context.watch<PdfProvider>().getCurrentSortType,
      onChanged: (type) {
        context.read<PdfProvider>().sortList(type);
      },
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
            onPressed: init,
            icon: Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }

  Widget _getSliverList(List<NovelPdf> list) {
    if (list.isEmpty) {
      return SliverToBoxAdapter(child: _getEmptyListWidget());
    }
    return SliverList.builder(
      itemCount: list.length,
      itemBuilder: (context, index) => PdfListItem(
        pdf: list[index],
        onClicked: (pdf) => NovelDirApp.instance.goPdfReader(context, pdf),
      ),
      // separatorBuilder: (context, index) => Divider(),
    );
  }
}
