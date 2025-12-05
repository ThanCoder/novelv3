import 'package:flutter/material.dart';
import 'package:novel_v3/app/core/models/pdf_file.dart';
import 'package:novel_v3/app/core/providers/novel_provider.dart';
import 'package:novel_v3/app/core/providers/pdf_provider.dart';
import 'package:novel_v3/app/others/pdf_reader/screens/pdfrx_reader_screen.dart';
import 'package:novel_v3/app/others/pdf_reader/types/pdf_config.dart';
import 'package:novel_v3/app/routes.dart';
import 'package:novel_v3/app/ui/components/pdf_cover_thumbnail_image.dart';
import 'package:provider/provider.dart';
import 'package:t_widgets/widgets/index.dart';
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

  late String novelPath;
  Future<void> init() async {
    novelPath = context.read<NovelProvider>().currentNovel!.path;
    context.read<PdfProvider>().init(novelPath);
  }

  PdfProvider get getProvider => context.watch<PdfProvider>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: getProvider.isLoading
          ? Center(child: TLoader.random())
          : CustomScrollView(controller: controller, slivers: [_getList()]),
    );
  }

  Widget _getList() {
    if (getProvider.list.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Text(
            'List Empty!...',
            style: TextTheme.of(context).headlineMedium,
          ),
        ),
      );
    }
    return SliverList.builder(
      itemCount: getProvider.list.length,
      itemBuilder: (context, index) => _getListItem(getProvider.list[index]),
    );
  }

  Widget _getListItem(PdfFile file) {
    return GestureDetector(
      onTap: () => _goReader(file),

      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Card(
          child: Row(
            spacing: 4,
            children: [
              SizedBox(
                width: 100,
                height: 120,
                child: PdfCoverThumbnailImage(
                  pdfFile: file,
                  savePath: file.getCoverPath,
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.title),
                        Expanded(
                          child: Text(
                            file.title,
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.sd_card),
                        Expanded(child: Text(file.getSize.toFileSizeLabel())),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.date_range),
                        Expanded(child: Text(file.date.toParseTime())),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _goReader(PdfFile pdf) {
    final configPath = PdfFile.getConfigPath(novelPath);
    goRoute(
      context,
      builder: (context) => PdfrxReaderScreen(
        sourcePath: pdf.path,
        title: pdf.title,
        pdfConfig: PdfConfig.fromPath(PdfFile.getConfigPath(novelPath)),
        onConfigUpdated: (pdfConfig) {
          pdfConfig.savePath(configPath);
        },
      ),
    );
  }
}
