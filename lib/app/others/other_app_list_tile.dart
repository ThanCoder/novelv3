import 'package:flutter/material.dart';
import 'package:novel_v3/app/others/n3_data/n3_data_scanner_screen.dart';
import 'package:novel_v3/app/others/novl_db/novl_data_scanner_screen.dart';
import 'package:novel_v3/app/others/pdf_reader/pdf_reader.dart';
import 'package:novel_v3/app/others/pdf_scanner/pdf_scanner_screen.dart';
import 'package:novel_v3/app/others/share/share_home_screen.dart';
import 'package:novel_v3/app/routes.dart';
import 'package:novel_v3/more_libs/setting/core/path_util.dart';

class OtherAppListTile extends StatelessWidget {
  const OtherAppListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 4,
          children: [
            Text('Other Apps', style: TextStyle(fontSize: 17)),

            ListTile(
              leading: Icon(Icons.file_present),
              title: Text('Novl Data Scanner'),
              onTap: () {
                goRoute(context, builder: (context) => NovlDataScannerScreen());
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.file_present),
              title: Text('N3 Data Scanner'),
              onTap: () {
                goRoute(context, builder: (context) => N3DataScannerScreen());
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.picture_as_pdf_rounded),
              title: Text('PDF Scanner'),
              onTap: () {
                goRoute(
                  context,
                  builder: (context) => PdfScannerScreen(
                    onClicked: (context, pdf) {
                      final cacheConfig = PathUtil.getCachePath(
                        name: '${pdf.title}.config.json',
                      );
                      goRoute(
                        context,
                        builder: (context) => PdfrxReaderScreen(
                          title: pdf.title,
                          sourcePath: pdf.path,
                          pdfConfig: PdfConfig.fromPath(cacheConfig),
                          onConfigUpdated: (pdfConfig) =>
                              pdfConfig.savePath(cacheConfig),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.share),
              title: Text('Novel Share'),
              onTap: () {
                goRoute(context, builder: (context) => ShareHomeScreen());
              },
            ),
          ],
        ),
      ),
    );
  }
}
