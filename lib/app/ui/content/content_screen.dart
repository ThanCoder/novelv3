import 'package:flutter/material.dart';
import 'package:novel_v3/app/core/models/novel.dart';
import 'package:novel_v3/app/core/providers/chapter_bookmark_provider.dart';
import 'package:novel_v3/app/core/providers/novel_provider.dart';
import 'package:novel_v3/app/others/bookmark/novel_bookmark_toggle_action.dart';
import 'package:novel_v3/app/ui/content/chapter_bookmark_page.dart';
import 'package:novel_v3/app/ui/content/chapter_page.dart';
import 'package:novel_v3/app/ui/content/content_cover.dart';
import 'package:novel_v3/app/ui/content/content_home_page.dart';
import 'package:novel_v3/app/ui/content/pdf_page.dart';
import 'package:provider/provider.dart';

class ContentScreen extends StatefulWidget {
  const ContentScreen({super.key});

  @override
  State<ContentScreen> createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen> {
  NovelProvider get getNovelProvider => context.watch<NovelProvider>();

  Novel? get currentNovel => context.read<NovelProvider>().currentNovel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  void init() {
    if (currentNovel == null) return;
    context.read<ChapterBookmarkProvider>().init(currentNovel!.path);
  }

  @override
  Widget build(BuildContext context) {
    if (currentNovel == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Current Novel is Null!')),
      );
    }
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            _getAppbar(),
            SliverPersistentHeader(
              delegate: ContentCover(novel: currentNovel!),
            ),
            SliverAppBar(
              automaticallyImplyLeading: false,
              flexibleSpace: _getNovelContentWidget(),
              collapsedHeight: 130,
              bottom: TabBar(
                tabs: [
                  Tab(text: 'Content', icon: Icon(Icons.description)),
                  Tab(text: 'PDF', icon: Icon(Icons.picture_as_pdf_rounded)),
                  Tab(text: 'Chapter', icon: Icon(Icons.article)),
                  Tab(text: 'Bookmark', icon: Icon(Icons.bookmark)),
                ],
              ),
            ),
          ],
          body: TabBarView(
            children: [
              ContentHomePage(),
              PdfPage(),
              ChapterPage(),
              ChapterBookmarkPage(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getNovelContentWidget() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(currentNovel!.title),
          Text('Author: ${currentNovel!.meta.author}'),
          Text('Translator: ${currentNovel!.meta.translator}'),
          Text('Adult: ${currentNovel!.meta.isAdult}'),
          Text('Completed: ${currentNovel!.meta.isCompleted ? 'Yes' : 'No'}'),
        ],
      ),
    );
  }

  Widget _getAppbar() {
    final provider = context.watch<NovelProvider>();
    return SliverAppBar(
      floating: true,
      snap: true,
      pinned: false,
      actions: [
        provider.currentNovel == null
            ? SizedBox.shrink()
            : NovelBookmarkToggleAction(
                novelTitle: provider.currentNovel!.title,
              ),
      ],
    );
  }
}
