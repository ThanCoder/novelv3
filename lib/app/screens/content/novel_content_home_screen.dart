import 'package:flutter/material.dart';
import 'content_pdf_page.dart';
import 'content_chapter_page.dart';
import 'content_home_page.dart';

class NovelContentHomeScreen extends StatefulWidget {
  const NovelContentHomeScreen({
    super.key,
  });

  @override
  State<NovelContentHomeScreen> createState() => _NovelContentHomeScreenState();
}

class _NovelContentHomeScreenState extends State<NovelContentHomeScreen> {
  List<Widget> pages = [
    ContentHomePage(),
    ContentPdfPage(),
    ContentChapterPage(),
  ];
  int currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: Colors.blue,
        onTap: (value) {
          setState(() {
            currentIndex = value;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.picture_as_pdf_rounded), label: 'Pdf'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Chapter'),
        ],
      ),
    );
  }
}
