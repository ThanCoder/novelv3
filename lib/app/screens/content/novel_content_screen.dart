import 'package:flutter/material.dart';
import 'package:novel_v3/app/models/index.dart';
import 'package:novel_v3/app/setting/app_notifier.dart';
import 'package:novel_v3/app/screens/content/pages/content_chapter_book_page.dart';
import 'package:novel_v3/app/screens/content/pages/content_chapter_page.dart';
import 'package:novel_v3/app/screens/content/pages/content_home_page.dart';
import 'package:novel_v3/app/screens/content/pages/content_pdf_page.dart';

class NovelContentScreen extends StatefulWidget {
  NovelModel novel;
  NovelContentScreen({super.key, required this.novel});

  @override
  State<NovelContentScreen> createState() => _NovelContentScreenState();
}

class _NovelContentScreenState extends State<NovelContentScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, result) {
          isFileDropHomePageNotifier.value = true;
        },
        child: const Scaffold(
          body: TabBarView(children: [
            ContentHomePage(),
            ContentPdfPage(),
            ContentChapterPage(),
            ContentChapterBookPage(),
          ]),
          bottomNavigationBar: TabBar(
            isScrollable: true,
            tabs: [
              Tab(
                text: 'Content',
                icon: Icon(Icons.home),
              ),
              Tab(
                text: 'PDF',
                icon: Icon(Icons.picture_as_pdf_rounded),
              ),
              Tab(
                text: 'Chapter',
                icon: Icon(Icons.view_array_rounded),
              ),
              Tab(
                text: 'Book Mark',
                icon: Icon(Icons.bookmark_added),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
