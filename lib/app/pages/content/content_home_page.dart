import 'dart:io';

import 'package:flutter/material.dart';
import 'package:novel_v3/app/action_buttons/novel_content_action_button.dart';
import 'package:novel_v3/app/action_buttons/novel_bookmark_button.dart';
import 'package:novel_v3/app/components/chapter_count_view.dart';
import 'package:novel_v3/app/components/content/novel_page_button.dart';
import 'package:novel_v3/app/components/content/novel_readed_button.dart';
import 'package:novel_v3/app/components/content/novel_readed_number_button.dart';
import 'package:novel_v3/app/constants.dart';
import 'package:novel_v3/app/extensions/index.dart';
import 'package:novel_v3/app/models/index.dart';
import 'package:novel_v3/app/provider/novel_provider.dart';
import 'package:novel_v3/app/provider/recent_provider.dart';
import 'package:novel_v3/app/widgets/index.dart';
import 'package:novel_v3/app/widgets/t_list_tile.dart';
import 'package:provider/provider.dart';

class ContentHomePage extends StatefulWidget {
  const ContentHomePage({super.key});

  @override
  State<ContentHomePage> createState() => _ContentHomePageState();
}

class _ContentHomePageState extends State<ContentHomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  void init() {
    final novel = context.read<NovelProvider>().getCurrent;
    if (novel == null) return;
    context.read<RecentProvider>().add(novel);
  }

  ImageProvider _getImage(String path) {
    final file = File(path);
    if (file.existsSync()) {
      return FileImage(file);
    }
    return const AssetImage(defaultIconAssetsPath);
  }

  Widget _header(NovelModel novel) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        spacing: 3,
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 170,
            height: 190,
            child: MyImageFile(
              path: novel.coverPath,
              fit: BoxFit.fill,
            ),
          ),
          Column(
            spacing: 3,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TListTile(
                leading: const Icon(Icons.title),
                title: Text(novel.title),
              ),
              TListTile(
                leading: const Icon(Icons.edit_document),
                title: Text(novel.author),
              ),
              TListTile(
                leading: const Icon(Icons.person),
                title: Text(novel.mc),
              ),
              NovelReadedNumberButton(novel: novel),
              TListTile(
                leading: const Icon(Icons.access_time_filled),
                title: Text(DateTime.fromMillisecondsSinceEpoch(novel.date)
                    .toParseTime()),
              ),
              TListTile(
                leading: const Icon(Icons.access_time_filled),
                title: Text(DateTime.fromMillisecondsSinceEpoch(novel.date)
                    .toTimeAgo()),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bottomBar(NovelModel novel) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            NovelPageButton(novel: novel),
            NovelReadedButton(novel: novel),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final novel = context.watch<NovelProvider>().getCurrent;
    if (novel == null) return const Text('novel is null');
    return MyScaffold(
      contentPadding: 0,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 1400),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: _getImage(novel.coverPath),
            opacity: 0.2,
          ),
          // color: const Color.fromARGB(232, 32, 32, 32),
        ),
        child: CustomScrollView(
          slivers: [
            // app bar
            SliverAppBar(
              title: const Text('Content'),
              snap: true,
              floating: true,
              actions: [
                NovelBookmarkButton(novel: novel),
                NovelContentActionButton(
                  onBackpress: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // header
            SliverToBoxAdapter(child: _header(novel)),
            // chapter count
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(),
                    ChapterCountView(
                      title: 'Chapter Count: ',
                      novelPath: novel.path,
                      style: const TextStyle(
                        color: Colors.white,
                        backgroundColor: Color.fromARGB(171, 0, 0, 0),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            //bottom bar
            SliverToBoxAdapter(child: _bottomBar(novel)),

            //content cover
            SliverToBoxAdapter(
              child: File(novel.contentCoverPath).existsSync()
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: MyImageFile(
                        path: novel.contentCoverPath,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

            // content text
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SelectableText(
                  novel.content,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
