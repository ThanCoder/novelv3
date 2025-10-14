import 'package:flutter/material.dart';
import 'package:novel_v3/app/ui/routes_helper.dart';
import 'package:novel_v3/app/others/n3_data/n3_data_scanner.dart';
import 'package:novel_v3/app/ui/main_ui/screens/scanners/pdf_scanner_screen.dart';
import 'package:novel_v3/app/others/share/share_home_screen.dart';
import 'package:novel_v3/more_libs/setting_v2.0.0/setting.dart';
import 'package:novel_v3/more_libs/setting_v2.0.0/thancoder_about_widget.dart';
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
          _getN3DataSannerWidget(),
          _getShareWidget(),
          Divider(),
          ThancoderAboutWidget(),
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
          builder: (context) => PdfScannerScreen(onClicked: goRecentPdfReader),
        );
      },
    );
  }

  Widget _getN3DataSannerWidget() {
    return TListTileWithDesc(
      title: 'N3 Data Scanner',
      onClick: () {
        goRoute(context, builder: (context) => N3DataScanner());
      },
    );
  }

  Widget _getShareWidget() {
    return TListTileWithDesc(
      title: 'Novel Share',
      desc: 'Novel မျှဝေမယ်',
      onClick: () {
        goRoute(context, builder: (context) => ShareHomeScreen());
      },
    );
  }
}
