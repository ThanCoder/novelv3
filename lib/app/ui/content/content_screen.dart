import 'package:flutter/material.dart';
import 'package:novel_v3/app/core/models/novel.dart';
import 'package:novel_v3/app/core/providers/chapter_bookmark_provider.dart';
import 'package:novel_v3/app/core/providers/novel_provider.dart';
import 'package:novel_v3/app/others/bookmark/novel_bookmark_toggle_action.dart';
import 'package:novel_v3/app/ui/components/page_url_icon_button.dart';
import 'package:novel_v3/app/ui/content/chapter_bookmark_page.dart';
import 'package:novel_v3/app/ui/content/chapter_page.dart';
import 'package:novel_v3/app/ui/content/content_cover.dart';
import 'package:novel_v3/app/ui/content/content_home_page.dart';
import 'package:novel_v3/app/ui/content/content_main_menu_actions.dart';
import 'package:novel_v3/app/ui/content/pdf_page.dart';
import 'package:novel_v3/app/ui/content/readed_button.dart';
import 'package:novel_v3/more_libs/setting/setting.dart';
import 'package:provider/provider.dart';
import 'package:t_widgets/widgets/index.dart';

class ContentScreen extends StatefulWidget {
  const ContentScreen({super.key});

  @override
  State<ContentScreen> createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen> {
  NovelProvider get getNovelRProvider => context.watch<NovelProvider>();

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
    final width = MediaQuery.of(context).size.width;
    if (currentNovel == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Current Novel is Null!')),
      );
    }
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.9),
                child: TImage(source: currentNovel!.getCoverPath),
              ),
            ),
            Positioned.fill(
              child: Container(
                color: Setting.getAppConfig.isDarkTheme
                    ? Colors.black.withValues(alpha: 0.7)
                    : Colors.white.withValues(
                        alpha: 0.7,
                      ), // 🔹 background color
                child: NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) => [
                    _getAppbar(),
                    SliverPersistentHeader(
                      delegate: ContentCover(novel: currentNovel!),
                    ),
                    SliverAppBar(
                      automaticallyImplyLeading: false,
                      flexibleSpace: _getNovelContentWidget(),
                      // toolbarHeight: 180,
                      collapsedHeight: 200,
                      expandedHeight: 220,
                      bottom: TabBar(
                        labelColor: Colors.blue,
                        isScrollable: width <= 360,
                        tabs: [
                          Tab(text: 'Content', icon: Icon(Icons.description)),
                          Tab(
                            text: 'PDF',
                            icon: Icon(Icons.picture_as_pdf_rounded),
                          ),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _getAppbar() {
    // final provider = context.watch<NovelProvider>();
    return SliverAppBar(
      floating: true,
      snap: true,
      pinned: false,
      backgroundColor: Setting.getAppConfig.isDarkTheme
          ? const Color.fromARGB(106, 0, 0, 0)
          : const Color.fromARGB(106, 255, 255, 255),
      foregroundColor: Setting.getAppConfig.isDarkTheme
          ? Colors.white
          : Colors.black,
      actions: [ContentMainMenuActions()],
    );
  }

  Widget _getNovelContentWidget() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4,
        children: [
          Text(
            currentNovel!.title,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),

          Text('Author: ${currentNovel!.meta.author}'),
          Text('Main MC: ${currentNovel!.meta.mc}'),
          Text('Translator: ${currentNovel!.meta.translator}'),
          Divider(),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              spacing: 3,
              children: [
                NovelBookmarkToggleAction(novelTitle: currentNovel!.title),
                !currentNovel!.meta.isAdult
                    ? SizedBox.shrink()
                    : Chip(
                        label: Text('Adult', style: TextStyle(fontSize: 8)),
                        avatar: Icon(Icons.check_box),
                      ),
                Chip(
                  padding: EdgeInsets.all(1),
                  label: Text(
                    currentNovel!.meta.isCompleted ? 'Completed' : 'OnGoing',
                    style: TextStyle(fontSize: 12),
                  ),
                  avatar: currentNovel!.meta.isCompleted
                      ? Icon(Icons.check_box)
                      : null,
                ),
                ReadedButton(),
                _getPageUrlWidget(),
              ],
            ),
          ),
          // Divider(),
        ],
      ),
    );
  }

  Widget _getPageUrlWidget() {
    final pageUrls = getNovelRProvider.currentNovel!.meta.pageUrls;
    if (pageUrls.isEmpty) return SizedBox.shrink();
    return PageUrlIconButton(list: pageUrls);
  }
}
