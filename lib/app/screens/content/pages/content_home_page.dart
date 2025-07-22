import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novel_v3/app/screens/content/actions/novel_content_action_bottom_sheet.dart';
import 'package:novel_v3/app/action_buttons/novel_bookmark_button.dart';
import 'package:novel_v3/app/components/chapter_count_view.dart';
import 'package:novel_v3/app/screens/content/buttons/novel_chapter_start_button.dart';
import 'package:novel_v3/app/screens/content/buttons/novel_page_button.dart';
import 'package:novel_v3/app/screens/content/buttons/novel_readed_button.dart';
import 'package:novel_v3/app/screens/content/buttons/novel_readed_number_button.dart';
import 'package:novel_v3/app/screens/content/buttons/novel_recent_pdf_button.dart';
import 'package:novel_v3/app/screens/content/buttons/novel_recent_text_button.dart';
import 'package:novel_v3/app/components/status_text.dart';
import 'package:novel_v3/app/constants.dart';
import 'package:novel_v3/app/models/index.dart';
import 'package:novel_v3/app/riverpods/providers.dart';
import 'package:novel_v3/app/screens/content/background_scaffold.dart';
import 'package:novel_v3/app/services/index.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:novel_v3/app/widgets/t_list_tile.dart';
import 'package:than_pkg/than_pkg.dart';

class ContentHomePage extends ConsumerStatefulWidget {
  const ContentHomePage({super.key});

  @override
  ConsumerState<ContentHomePage> createState() => _ContentHomePageState();
}

class _ContentHomePageState extends ConsumerState<ContentHomePage> {
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  void init() {
    final novel = ref.read(novelNotifierProvider.notifier).getCurrent;
    if (novel == null) return;
    ref.read(recentNotifierProvider.notifier).add(novel);
  }

  void _copyTitleText(String text) {
    copyText(text);
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
            child: TImageFile(
              path: novel.coverPath,
              fit: BoxFit.fill,
            ),
          ),
          Column(
            spacing: 3,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // title
              GestureDetector(
                onLongPress: () => _copyTitleText(novel.title),
                onSecondaryTap: () => _copyTitleText(novel.title),
                child: Row(
                  children: [
                    const Icon(Icons.title),
                    Expanded(
                      child: Text(
                        novel.title,
                        // overflow: TextOverflow.ellipsis,
                        maxLines: null,
                      ),
                    ),
                  ],
                ),
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
              // TListTile(
              //   leading: const Icon(Icons.access_time_filled),
              //   title: Text(DateTime.fromMillisecondsSinceEpoch(novel.date)
              //       .toParseTime()),
              // ),
              TListTile(
                leading: const Icon(Icons.access_time_filled),
                title: Text(
                    '${DateTime.fromMillisecondsSinceEpoch(novel.date).toParseTime()}\n${DateTime.fromMillisecondsSinceEpoch(novel.date).toTimeAgo()}'),
              ),
              // status
              Wrap(
                spacing: 5,
                runSpacing: 5,
                children: [
                  StatusText(
                    bgColor: novel.isCompleted
                        ? StatusText.completedColor
                        : StatusText.onGoingColor,
                    text: novel.isCompleted ? 'Completed' : 'OnGoing',
                  ),
                  novel.isAdult
                      ? StatusText(
                          text: 'Adult',
                          bgColor: StatusText.adultColor,
                        )
                      : const SizedBox.shrink(),
                ],
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
          spacing: 5,
          children: [
            NovelPageButton(novel: novel),
            NovelChapterStartButton(novel: novel),
            NovelReadedButton(novel: novel),
            NovelRecentPdfButton(novel: novel),
            NovelRecentTextButton(novel: novel),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final novel = ref.watch(novelNotifierProvider).novel;
    if (novel == null) return const Text('novel is null');
    return BackgroundScaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(0, 97, 97, 97),
        title: const Text('Content'),
        actions: [
          NovelBookmarkButton(novel: novel),
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => NovelContentActionBottomSheet(
                  onLoading: (isLoading) {
                    setState(() {
                      this.isLoading = isLoading;
                    });
                  },
                  onBackpress: () {
                    Navigator.pop(this.context);
                  },
                ),
              );
            },
            icon: const Icon(Icons.more_vert),
          )
        ],
      ),
      stackChildren:  [
        RefreshIndicator(
          onRefresh: () async {
            ref.read(novelNotifierProvider.notifier).refreshCurrent();
          },
          child: isLoading ? TLoader() : CustomScrollView(
            slivers: [
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
                        child: TImageFile(
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
      ],
    );
  }
}
