import 'package:flutter/material.dart';
import 'package:novel_v3/core/types/home_page_list_style_type.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

class HomeListStyleListTile extends StatefulWidget {
  final void Function()? onCloseParent;
  const HomeListStyleListTile({super.key, this.onCloseParent});

  @override
  State<HomeListStyleListTile> createState() => _HomeListStyleListTileState();
}

class _HomeListStyleListTileState extends State<HomeListStyleListTile> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.style),
      title: Text('List Style'),
      onTap: _showMenu,
    );
  }

  void _showMenu() {
    widget.onCloseParent?.call();
    showTMenuBottomSheetSingle(
      context,
      child: ValueListenableBuilder(
        valueListenable: homePageListStyleNotifier,
        builder: (context, listStyle, child) {
          return Column(
            children: [
              ListTile(
                leading: Icon(Icons.view_list_rounded),
                trailing: listStyle != ListStyleType.list
                    ? null
                    : Icon(Icons.check),
                title: Text('List Style'),
                onTap: () {
                  homePageListStyleNotifier.value = ListStyleType.list;
                  TRecentDB.getInstance.putString(
                    'home_page_list_style',
                    homePageListStyleNotifier.value.name,
                  );
                },
              ),
              // Divider(),
              ListTile(
                leading: Icon(Icons.grid_view),
                trailing: listStyle != ListStyleType.grid
                    ? null
                    : Icon(Icons.check),
                title: Text('Grid Style'),
                onTap: () {
                  homePageListStyleNotifier.value = ListStyleType.grid;
                  TRecentDB.getInstance.putString(
                    'home_page_list_style',
                    homePageListStyleNotifier.value.name,
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
