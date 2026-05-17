import 'package:flutter/material.dart';
import 'package:novel_v3/more_libs/desktop_exe/desktop_exe.dart';
import 'package:novel_v3/more_libs/setting/setting.dart';
import 'package:novel_v3/other_apps/other_app_list_tile.dart';
import 'package:t_widgets/t_widgets.dart';

class MoreApp extends StatelessWidget {
  const MoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('More App')),
      body: TScrollableColumn(
        children: [
          Setting.getThemeModeChooser,
          Setting.getSettingListTileWidget,
          Setting.getCurrentVersionWidget,
          Setting.getCacheManagerWidget,
          Divider(),
          DesktopExe.createDesktopListTile(
            context,
            assetsIconPath: 'assets/logo_3.jpg',
          ),
          Divider(),
          OtherAppListTile(),
          Divider(),
          Setting.getThanCoderAboutWidget,
        ],
      ),
    );
  }
}
