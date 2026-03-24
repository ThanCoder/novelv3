import 'package:flutter/material.dart';
import 'package:novel_v3/bloc_app/ui/components/bloc_tag_view.dart';
import 'package:novel_v3/core/models/novel.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

class NovelInfo extends StatelessWidget {
  final Novel novel;
  const NovelInfo({super.key, required this.novel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(novel.meta.title, style: TextStyle(fontSize: 14)),
          Text('Author: ${novel.meta.author}'),
          Text('MC: ${novel.meta.mc}'),
          Text('Translator: ${novel.meta.translator}'),
          BlocTagView(
            values: novel.meta.otherTitleList,
            onClick: (value) {
              ThanPkg.appUtil.copyText(value);
              if (TPlatform.isDesktop) {
                showTSnackBar(context, 'Copied');
              }
            },
          ),
        ],
      ),
    );
  }
}
