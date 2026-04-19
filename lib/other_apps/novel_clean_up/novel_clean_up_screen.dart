import 'package:flutter/material.dart';
import 'package:novel_v3/bloc_app/ui/components/novel_alert_dialog.dart';
import 'package:novel_v3/other_apps/novel_clean_up/cover_image_size_reducer_dialog.dart';
import 'package:t_widgets/t_widgets.dart';

class NovelCleanUpScreen extends StatelessWidget {
  const NovelCleanUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Novel Clean Up')),
      body: TScrollableColumn(
        children: [
          Card(
            child: ListTile(
              title: Text('Cover Image Size Reducer'),
              onTap: () {
                showNovelAlertDialog(
                  context,
                  barrierDismissible: false,
                  showButtonActions: false,
                  title: Text('Cover Image Size Reducer'),
                  content: CoverImageSizeReducerDialog(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
