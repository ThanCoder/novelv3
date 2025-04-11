import 'package:flutter/material.dart';
import 'package:novel_v3/app/components/pdf_list_item.dart';
import 'package:novel_v3/app/provider/novel_provider.dart';
import 'package:novel_v3/app/provider/pdf_provider.dart';
import 'package:novel_v3/app/widgets/index.dart';
import 'package:provider/provider.dart';

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
    context.read<PdfProvider>().initList(novelPath: novel.path, isReset: true);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PdfProvider>();
    final isLoading = provider.isLoading;
    final list = provider.getList;
    return MyScaffold(
      appBar: AppBar(
        title: const Text('PDF'),
      ),
      body: isLoading
          ? TLoader()
          : ListView.builder(
              itemBuilder: (context, index) => PdfListItem(
                pdf: list[index],
                onClicked: (chapter) {},
              ),
              // separatorBuilder: (context, index) => const Divider(),
              itemCount: list.length,
            ),
    );
  }
}
