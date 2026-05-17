import 'package:cf_lite/cf_lite.dart';
import 'package:flutter/material.dart';
import 'package:novel_v3/core/types/home_page_list_style_type.dart';

class HomeListStyleChooserMenu extends StatelessWidget {
  const HomeListStyleChooserMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: currentHomeListStyleNotifier,
      builder: (context, current, child) {
        return Column(
          children: [
            CheckboxListTile.adaptive(
              value: HomeListStyleType.list == current,
              title: Text("Home List Style"),
              onChanged: (value) {
                if (current == HomeListStyleType.list) return;
                currentHomeListStyleNotifier.value = HomeListStyleType.list;
                CFLite.getInstance().put(
                  'home_list_style_type',
                  HomeListStyleType.list.name,
                );
              },
            ),
            CheckboxListTile.adaptive(
              value: HomeListStyleType.grid == current,
              title: Text("Home Grid Style"),
              onChanged: (value) {
                if (current == HomeListStyleType.grid) return;
                currentHomeListStyleNotifier.value = HomeListStyleType.grid;
                CFLite.getInstance().put(
                  'home_list_style_type',
                  HomeListStyleType.grid.name,
                );
              },
            ),
          ],
        );
      },
    );
  }
}
