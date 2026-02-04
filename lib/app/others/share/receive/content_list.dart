import 'package:flutter/material.dart';
import 'package:novel_v3/app/others/share/libs/novel_file.dart';
import 'package:novel_v3/app/others/share/receive/content_list_item.dart';

class ContentList extends StatefulWidget {
  final String hostUrl;
  final String novelId;
  final List<NovelFile> list;
  const ContentList({
    super.key,
    required this.hostUrl,
    required this.novelId,
    required this.list,
  });

  @override
  State<ContentList> createState() => _ContentListState();
}

class _ContentListState extends State<ContentList> {
  final controller = ScrollController();

  @override
  dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: controller,
      // physics: NeverScrollableScrollPhysics(),
      slivers: [
        SliverList.builder(
          itemCount: widget.list.length,
          itemBuilder: (context, index) => ContentListItem(
            hostUrl: widget.hostUrl,
            novelId: widget.novelId,
            file: widget.list[index],
          ),
        ),
      ],
    );
  }
}
