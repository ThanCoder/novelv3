import 'package:flutter/material.dart';
import 'package:novel_v3/more_libs/setting_v2.0.0/others/novel_home_list_styles.dart';
import 'package:novel_v3/more_libs/setting_v2.0.0/setting.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

class HomeListStyleMenu extends StatelessWidget {
  const HomeListStyleMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Setting.getAppConfigNotifier,
      builder: (context, config, child) {
        return TScrollableColumn(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Home List Style',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
            Divider(),
            ListTile(
              title: Text(NovelHomeListStyles.defaultStyle.name.toCaptalize()),
              trailing: Icon(
                config.homeListStyle == NovelHomeListStyles.defaultStyle
                    ? Icons.check_box_rounded
                    : Icons.check_box_outline_blank_rounded,
              ),
              onTap: () {
                Setting.getAppConfigNotifier.value = config.copyWith(
                  homeListStyle: NovelHomeListStyles.defaultStyle,
                );
                Setting.getAppConfigNotifier.value.save();
              },
            ),
            ListTile(
              title: Text(
                '${NovelHomeListStyles.list.name.toCaptalize()} Style',
              ),
              trailing: Icon(
                config.homeListStyle == NovelHomeListStyles.list
                    ? Icons.check_box_rounded
                    : Icons.check_box_outline_blank_rounded,
              ),
              onTap: () {
                Setting.getAppConfigNotifier.value = config.copyWith(
                  homeListStyle: NovelHomeListStyles.list,
                );
                Setting.getAppConfigNotifier.value.save();
              },
            ),
            ListTile(
              title: Text(
                '${NovelHomeListStyles.grid.name.toCaptalize()} Style',
              ),
              trailing: Icon(
                config.homeListStyle == NovelHomeListStyles.grid
                    ? Icons.check_box_rounded
                    : Icons.check_box_outline_blank_rounded,
              ),
              onTap: () {
                Setting.getAppConfigNotifier.value = config.copyWith(
                  homeListStyle: NovelHomeListStyles.grid,
                );
                Setting.getAppConfigNotifier.value.save();
              },
            ),
          ],
        );
      },
    );
  }
}
