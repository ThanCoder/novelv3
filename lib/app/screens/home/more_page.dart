import 'package:flutter/material.dart';
import 'package:novel_v3/more_libs/setting_v2.0.0/setting.dart';
import 'package:t_widgets/t_widgets.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return TScaffold(
      appBar: AppBar(title: Text('More')),
      body: TScrollableColumn(
        children: [
          Setting.getThemeSwitcher,
          Setting.getSettingListTile,
          Divider(),
        ],
      ),
    );
  }
}
