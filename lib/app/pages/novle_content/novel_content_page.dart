import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:novel_v3/app/models/novel_model.dart';
import 'package:novel_v3/app/notifiers/app_notifier.dart';
import 'package:novel_v3/app/pages/novle_content/novel_content_bottom_list.dart';
import 'package:novel_v3/app/pages/novle_content/novel_header.dart';
import 'package:novel_v3/app/provider/index.dart';
import 'package:provider/provider.dart';
import '../../widgets/index.dart';

class NovelContentPage extends StatefulWidget {
  const NovelContentPage({super.key});

  @override
  State<NovelContentPage> createState() => NovelContentPageState();
}

class NovelContentPageState extends State<NovelContentPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    _scrollController.addListener(_onListViewScroll);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      init();
    });
  }

  void init() {
    // if (currentNovelNotifier.value == null) return;
    // currentNovelNotifier.value =
    //     NovelModel.fromPath(, isFullInfo: true);
  }

  void _onListViewScroll() {
    //down
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      isShowContentBottomBarNotifier.value = false;
    }
    //up
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      isShowContentBottomBarNotifier.value = true;
    }
  }

  //dialog

  Widget getContentWidget(NovelModel novel) {
    final coverFile = File(novel.contentCoverPath);
    if (coverFile.existsSync()) {
      return MyImageFile(path: novel.contentCoverPath);
    }
    return Container();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final novelProvider = context.watch<NovelProvider>();
    final isLoading = novelProvider.isLoading;
    final novel = novelProvider.getNovel;
    if (isLoading) {
      return Center(child: TLoader());
    }
    if (novel == null) {
      return const Center(
        child: Text('Novel မရှိပါ'),
      );
    } else {
      return GestureDetector(
        onTap: () {
          if (!isShowContentBottomBarNotifier.value) {
            isShowContentBottomBarNotifier.value = true;
          }
        },
        child: ListView(
          controller: _scrollController,
          children: [
            //novel header
            NovelHeader(novel: novel),
            const Divider(),
            //go page
            NovelContentBottomList(novel: novel),
            const SizedBox(height: 10),
            //des
            //content cover
            getContentWidget(novel),
            //text
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SelectableText(
                novel.content,
                style: const TextStyle(fontSize: 17),
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      );
    }
  }
}
