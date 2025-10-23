import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

import '../../core/models/app.dart';

class AppListItem extends StatelessWidget {
  final App app;
  final void Function(App app)? onClicked;
  final void Function(App app)? onRightClicked;
  const AppListItem({
    super.key,
    required this.app,
    this.onClicked,
    this.onRightClicked,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onClicked?.call(app),
      onSecondaryTap: () => onRightClicked?.call(app),
      onLongPress: () => onRightClicked?.call(app),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Card(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 5,
            children: [
              SizedBox(
                width: 160,
                height: 200,
                child: TImage(source: app.coverSource),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  Text('T: ${app.title}'),
                  Text('PackageName: ${app.packageName}'),
                  Text('Date: ${app.date.toParseTime()}'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
