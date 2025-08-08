import 'package:flutter/material.dart';
import 'content_pdf_page.dart';
import 'content_chapter_page.dart';
import 'content_home_page.dart';

class NovelContentHomeScreen extends StatelessWidget {
  const NovelContentHomeScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: const Scaffold(
          body: TabBarView(children: [
            ContentHomePage(),
            ContentChapterPage(),
            ContentPdfPage(),
          ]),
          bottomNavigationBar: TabBar(tabs: [
            Tab(
              icon: Icon(Icons.home),
            ),
            Tab(
              icon: Icon(Icons.list_alt_rounded),
            ),
            Tab(
              icon: Icon(Icons.picture_as_pdf),
            ),
          ]),
        ));
  }
}
