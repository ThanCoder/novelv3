import 'package:flutter/material.dart';
import 'package:novel_v3/app/routes_helper.dart';
import 'package:novel_v3/app/screens/scanners/pdf_scanner_screen.dart';
import 'package:novel_v3/more_libs/pdf_readers_v1.0.2/pdf_reader.dart';
import 'package:novel_v3/more_libs/setting_v2.0.0/setting.dart';
import 'package:t_widgets/t_widgets.dart';

class MorePage extends StatefulWidget {
  const MorePage({super.key});

  @override
  State<MorePage> createState() => _MorePageState();
}

class _MorePageState extends State<MorePage> {
  @override
  Widget build(BuildContext context) {
    return TScaffold(
      appBar: AppBar(title: Text('More')),
      body: TScrollableColumn(
        spacing: 3,
        children: [
          Setting.getThemeSwitcherWidget,
          Setting.getSettingListTileWidget,
          Divider(),
          Setting.getCurrentVersionWidget,
          Setting.getCacheManagerWidget,
          Divider(),
          // scanner
          _getPdfScannerWidget(),
        ],
      ),
    );
  }

  Widget _getPdfScannerWidget() {
    return TListTileWithDesc(
      title: 'PDF Scanner',
      onClick: () {
        goRoute(
          context,
          builder: (context) => PdfScannerScreen(
            onClicked: (pdf) {
              final configPath =
                  '${PathUtil.getCachePath()}/${pdf.getTitle.replaceAll('.pdf', '.config.json')}';

              goRoute(
                context,
                builder: (context) => PdfrxReaderScreen(
                  title: pdf.getTitle,
                  sourcePath: pdf.path,
                  pdfConfig: PdfConfigModel.fromPath(configPath),
                  onConfigUpdated: (pdfConfig) {
                    pdfConfig.savePath(configPath);
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}
