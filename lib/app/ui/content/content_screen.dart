import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:novel_v3/core/models/novel.dart';
import 'package:novel_v3/core/providers/chapter_bookmark_provider.dart';
import 'package:novel_v3/core/providers/chapter_provider.dart';
import 'package:novel_v3/core/providers/novel_provider.dart';
import 'package:novel_v3/app/others/bookmark/novel_bookmark_toggle_action.dart';
import 'package:novel_v3/app/ui/components/page_url_icon_button.dart';
import 'package:novel_v3/app/ui/content/chapter_bookmark_page/chapter_bookmark_page.dart';
import 'package:novel_v3/app/ui/content/chapter_page/chapter_page.dart';
import 'package:novel_v3/app/ui/content/home/content_cover.dart';
import 'package:novel_v3/app/ui/content/home/content_home_page.dart';
import 'package:novel_v3/app/ui/content/home/content_main_menu_actions.dart';
import 'package:novel_v3/app/ui/content/pdf_page/pdf_page.dart';
import 'package:novel_v3/app/ui/content/home/readed_button.dart';
import 'package:provider/provider.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

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
    context.read<ChapterProvider>().init(currentNovel!.path);
  }

  @override
  Widget build(BuildContext context) {
    if (currentNovel == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Current Novel is Null!')),
      );
    }
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(child: TImage(source: currentNovel!.getCoverPath)),
            Positioned.fill(
              child: ClipRect(
                // Blur effect အပြင်မထွက်အောင် ClipRect သုံးပေးရပါမယ်
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4), // Blur ပမာဏ
                  child: Container(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.5)
                        : Colors.white.withValues(
                            alpha: 0.1,
                          ), // အမည်းရောင်အုပ်မည့် ပမာဏ
                  ),
                ),
              ),
            ),
            // Positioned.fill(
            //   child: Container(color: Colors.black.withValues(alpha: 0.6)),
            // ),
            NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                _getAppbar(),
                SliverPersistentHeader(
                  delegate: ContentCover(novel: currentNovel!),
                ),
                _getNovelContentAppbar(),
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
          ],
        ),
      ),
    );
  }

  Widget _getAppbar() {
    // final provider = context.watch<NovelProvider>();
    // final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDesktop = TPlatform.isDesktop;
    return SliverAppBar(
      floating: isDesktop,
      snap: isDesktop,
      pinned: false,
      backgroundColor: Colors.transparent, // ဖောက်ထွင်းမြင်ရအောင်
      elevation: 0,
      // နောက်ခံက အမည်းရောင်အုပ်ထားတာမို့ Icon တွေကို အဖြူရောင်ပဲ ပေးလိုက်ပါ
      foregroundColor: Colors.white,
      actions: [ContentMainMenuActions()],
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        color: Colors.white,
        style: IconButton.styleFrom(
          backgroundColor: Colors.black.withValues(alpha: 0.7),
        ),
        icon: Icon(Icons.arrow_back),
      ),
    );
  }

  Widget _getNovelContentAppbar() {
    final width = MediaQuery.of(context).size.width;
    return SliverAppBar(
      automaticallyImplyLeading: false,
      flexibleSpace: _getNovelContentWidget(),
      collapsedHeight: 200,
      expandedHeight: 220,
      bottom: TabBar(
        labelColor: Colors.blue,
        isScrollable: width <= 360,
        tabs: [
          Tab(text: 'Content', icon: Icon(Icons.description)),
          Tab(text: 'PDF', icon: Icon(Icons.picture_as_pdf_rounded)),
          Tab(text: 'Chapter', icon: Icon(Icons.article)),
          Tab(text: 'Bookmark', icon: Icon(Icons.bookmark)),
        ],
      ),
    );
  }

  Widget _getNovelContentWidget() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4,
        children: [
          GestureDetector(
            onLongPress: () {
              try {
                ThanPkg.appUtil.copyText(currentNovel!.meta.title);
                if (!TPlatform.isDesktop) return;
                showTSnackBar(context, 'Copied `${currentNovel!.meta.title}`');
              } catch (e) {
                debugPrint('[ContentScreen:_getNovelContentWidget]: $e');
              }
            },
            child: Text(
              currentNovel!.meta.title,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
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
                NovelBookmarkToggleAction(novelTitle: currentNovel!.meta.title),
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
