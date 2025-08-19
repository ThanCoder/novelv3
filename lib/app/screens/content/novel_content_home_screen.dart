import 'package:flutter/material.dart';
import 'package:novel_v3/app/screens/content/content_chapter_bookmark_page.dart';
import 'package:novel_v3/more_libs/setting_v2.0.0/setting.dart';
import 'content_pdf_page.dart';
import 'content_chapter_page.dart';
import 'content_home_page.dart';

class NovelContentHomeScreen extends StatefulWidget {
  const NovelContentHomeScreen({super.key});

  @override
  State<NovelContentHomeScreen> createState() => _NovelContentHomeScreenState();
}

class _NovelContentHomeScreenState extends State<NovelContentHomeScreen> {
  List<Widget> pages = [
    ContentHomePage(),
    ContentPdfPage(),
    ContentChapterPage(),
    ContentChapterBookmarkPage(),
  ];
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Setting.getAppConfig.isDarkTheme
            ? Colors.white
            : Colors.black,
        onTap: (value) {
          setState(() {
            currentIndex = value;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.picture_as_pdf_rounded),
            label: 'Pdf',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Chapter'),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'BookMark',
          ),
        ],
      ),
    );
  }
}
