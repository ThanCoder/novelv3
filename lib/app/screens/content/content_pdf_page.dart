import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:t_widgets/t_widgets.dart';
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
    final novel = context.watch<NovelProvider>().getCurrent;
    final provider = context.watch<PdfProvider>();
    final isLoading = provider.isLoading;
    final list = provider.getList;
    return TScaffold(
      appBar: AppBar(
        title: Text('PDF'),
        automaticallyImplyLeading: PlatformExtension.isDesktop(),
      ),
      body: Stack(
        children: [
          Positioned.fill(
              child: TImage(source: novel == null ? '' : novel.getCoverPath)),
          Container(
            color: Colors.black.withValues(alpha: 0.8),
          ),
          isLoading
              ? Center(child: TLoaderRandom())
              : list.isEmpty
                  ? _getEmptyListWidget()
                  : CustomScrollView(
                      slivers: [
                        _getSliverList(list),
                      ],
                    ),
        ],
      ),
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
              color: Colors.blue, onPressed: init, icon: Icon(Icons.refresh)),
        ],
      ),
    );
  }

  Widget _getSliverList(List<NovelPdf> list) {
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
