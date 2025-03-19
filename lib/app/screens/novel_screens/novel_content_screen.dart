import 'dart:io';

import 'package:flutter/material.dart';
import 'package:novel_v3/app/constants.dart';
import 'package:novel_v3/app/models/novel_bookmark_model.dart';
import 'package:novel_v3/app/models/novel_model.dart';
import 'package:novel_v3/app/notifiers/app_notifier.dart';
import 'package:novel_v3/app/notifiers/novel_notifier.dart';
import 'package:novel_v3/app/pages/novle_content/chapter_list_page.dart';
import 'package:novel_v3/app/pages/novle_content/chapter_bookmark_list_page.dart';
import 'package:novel_v3/app/pages/novle_content/novel_content_page.dart';
import 'package:novel_v3/app/pages/novle_content/pdf_list_page.dart';
import 'package:novel_v3/app/provider/index.dart';
import 'package:novel_v3/app/services/novel_bookmark_services.dart';
import 'package:novel_v3/app/modal_bottom_sheets/novel_content_modal_bottom_sheet.dart';
import 'package:provider/provider.dart';

import '../../widgets/index.dart';

class NovelContentScreen extends StatefulWidget {
  NovelModel novel;
  NovelContentScreen({super.key, required this.novel});

  @override
  State<NovelContentScreen> createState() => _NovelContentScreenState();
}

class _NovelContentScreenState extends State<NovelContentScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<NovelProvider>()
          .setCurrentNovel(novelSourcePath: widget.novel.path);
      init();
      //show default
      isShowContentBottomBarNotifier.value = true;
    });
  }

  bool isExistsBookmark = false;

  void init() {
    try {
      final title = widget.novel.title;
      final path = widget.novel.path;
      isExistsBookmark = isExistsNovelBookmarkList(
          bookmark: NovelBookmarkModel(title: title, path: path));
      setState(() {});
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _goBack() {
    Navigator.pop(context);
  }

  void showBottomMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => NovelContentModalBottomSheet(
        novel: widget.novel,
        onBackPress: _goBack,
      ),
    );
  }

  void _toggleBookMark() {
    final title = currentNovelNotifier.value!.title;
    final path = currentNovelNotifier.value!.path;
    toggleNovelBookmarkList(
      bookmark: NovelBookmarkModel(title: title, path: path),
    );
    //remove ui
    if (isExistsBookmark) {
      final resList = novelBookMarkListNotifier.value
          .where((nv) => nv.title != title)
          .toList();
      novelBookMarkListNotifier.value = resList;
    }
    setState(() {
      isExistsBookmark = !isExistsBookmark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isShowContentBottomBarNotifier,
      builder: (context, isShowAppBar, child) {
        return AnimatedSize(
          duration: const Duration(milliseconds: 1500),
          child: MyScaffold(
            contentPadding: 0,
            appBar: !isShowAppBar
                ? null
                : AppBar(
                    title: const Text('Novel Content'),
                    actions: [
                      IconButton(
                        onPressed: _toggleBookMark,
                        icon: Icon(
                            color: isExistsBookmark ? dangerColor : activeColor,
                            isExistsBookmark
                                ? Icons.bookmark_remove
                                : Icons.bookmark_add),
                      ),
                      IconButton(
                        onPressed: () {
                          showBottomMenu();
                        },
                        icon: const Icon(Icons.more_vert),
                      ),
                    ],
                  ),
            body: const _BodyTab(),
          ),
        );
      },
    );
  }
}

class _BodyTab extends StatelessWidget {
  const _BodyTab();

  @override
  Widget build(BuildContext context) {
    final novel = context.watch<NovelProvider>().getNovel;
    final coverFile = File(novel == null ? '' : novel.coverPath);
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        body: AnimatedContainer(
          duration: const Duration(milliseconds: 1500),
          curve: Curves.easeInOut, // Curve for smoothness
          decoration: appConfigNotifier.value.isShowNovelContentBgImage
              ? BoxDecoration(
                  gradient: isDarkThemeNotifier.value
                      ? const LinearGradient(
                          colors: [
                            Color.fromARGB(255, 3, 14, 17),
                            Color.fromARGB(193, 2, 2, 15),
                            Color.fromARGB(193, 12, 12, 12),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        )
                      : null,
                  image: DecorationImage(
                    image: coverFile.existsSync()
                        ? FileImage(coverFile)
                        : const AssetImage(defaultIconAssetsPath),
                    fit: BoxFit.cover,
                    opacity: 0.2,
                    scale: 0.8,
                  ),
                )
              : null,
          child: const TabBarView(
            children: [
              NovelContentPage(),
              ChapterListPage(),
              PdfListPage(),
              ChapterBookmarkListPage(),
            ],
          ),
        ),
        bottomNavigationBar: ValueListenableBuilder(
          valueListenable: isShowContentBottomBarNotifier,
          builder: (context, value, child) {
            return AnimatedSize(
              duration: const Duration(milliseconds: 400),
              child: !value
                  ? const SizedBox.shrink()
                  : const TabBar(
                      tabs: [
                        Tab(
                          text: 'Home',
                          icon: Icon(Icons.home),
                        ),
                        Tab(
                          text: 'Chapter',
                          icon: Icon(Icons.list),
                        ),
                        Tab(
                          text: 'PDF List',
                          icon: Icon(Icons.picture_as_pdf),
                        ),
                        Tab(
                          text: 'Book Mark List',
                          icon: Icon(Icons.bookmark_added),
                        ),
                      ],
                    ),
            );
          },
        ),
      ),
    );
  }
}
