import 'dart:io';

import 'package:flutter/material.dart';
import 'package:novel_v3/app/action_buttons/content_action_button.dart';
import 'package:novel_v3/app/action_buttons/novel_bookmark_button.dart';
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
                leading: const Icon(Icons.person_4_rounded),
                title: Text(novel.mc),
              ),
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
            SliverAppBar(
              title: const Text('Content'),
              snap: true,
              floating: true,
              actions: [
                NovelBookmarkButton(novel: novel),
                const ContentActionButton(),
              ],
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // header
            SliverToBoxAdapter(child: _header(novel)),
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
