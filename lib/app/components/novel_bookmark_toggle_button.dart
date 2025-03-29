import 'package:flutter/material.dart';
import 'package:novel_v3/app/constants.dart';
import 'package:novel_v3/app/notifiers/novel_notifier.dart';
import 'package:novel_v3/app/provider/novel_provider.dart';
import 'package:novel_v3/app/services/index.dart';
import 'package:novel_v3/app/widgets/core/index.dart';
import 'package:provider/provider.dart';

class NovelBookmarkToggleButton extends StatefulWidget {
  const NovelBookmarkToggleButton({super.key});

  @override
  State<NovelBookmarkToggleButton> createState() =>
      _NovelBookmarkToggleButtonState();
}

class _NovelBookmarkToggleButtonState extends State<NovelBookmarkToggleButton> {
  @override
  Widget build(BuildContext context) {
    final novel = context.watch<NovelProvider>().getNovel;
    if (novel == null) return const SizedBox.shrink();

    return FutureBuilder(
      initialData: false,
      future: NovelBookmarkServices.instance.isExists(novel),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            width: 25,
            height: 25,
            child: TLoader(size: 25),
          );
        }
        if (snapshot.hasData && snapshot.data != null) {
          return IconButton(
            onPressed: () async {
              await NovelBookmarkServices.instance.toggle(novel: novel);
              novelBookMarkListNotifier.value = [];
              novelBookMarkListNotifier.value =
                  await NovelBookmarkServices.instance.getList();
              if (!mounted) return;
              setState(() {});
            },
            color: snapshot.data! ? dangerColor : activeColor,
            icon: Icon(
              snapshot.data! ? Icons.bookmark_remove : Icons.bookmark_add,
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
