import 'package:flutter/material.dart';
import 'package:novel_v3/app/models/index.dart';
import 'package:novel_v3/app/pages/content/content_chapter_book_page.dart';
import 'package:novel_v3/app/pages/content/content_chapter_page.dart';
import 'package:novel_v3/app/pages/content/content_home_page.dart';
import 'package:novel_v3/app/pages/content/content_pdf_page.dart';

class NovelContentScreen extends StatefulWidget {
  NovelModel novel;
  NovelContentScreen({super.key, required this.novel});

  @override
  State<NovelContentScreen> createState() => _NovelContentScreenState();
}

class _NovelContentScreenState extends State<NovelContentScreen> {
  @override
  Widget build(BuildContext context) {
    return const DefaultTabController(
      length: 4,
      child: Scaffold(
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
    );
  }
}
