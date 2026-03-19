import 'package:flutter/material.dart';
import 'package:novel_v3/bloc_app/ui/content/chapter_bookmark_list_page.dart';
import 'package:novel_v3/bloc_app/ui/content/chapter_list_page.dart';
import 'package:novel_v3/bloc_app/ui/content/novel_detail_page.dart';
import 'package:novel_v3/bloc_app/ui/content/pdf_list_page.dart';
import 'package:novel_v3/core/models/novel.dart';
import 'package:t_widgets/t_widgets.dart';

class ContentStyleTwo extends StatefulWidget {
  final Novel novel;
  const ContentStyleTwo({super.key, required this.novel});

  @override
  State<ContentStyleTwo> createState() => _ContentStyleTwoState();
}

class _ContentStyleTwoState extends State<ContentStyleTwo> {
  int _selectedIndex = 0;
  // Widget _getPage() {
  //   if (_selectedIndex == 1) {
  //     return ChapterListPage(novel: widget.novel);
  //   }
  //   if (_selectedIndex == 2) {
  //     return PdfListPage(novel: widget.novel);
  //   }
  //   return NovelDetailPage(novel: widget.novel);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          NovelDetailPage(novel: widget.novel),
          ChapterListPage(novel: widget.novel),
          PdfListPage(novel: widget.novel),
          ChapterBookmarkListPage(novel: widget.novel),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.shifting,
        currentIndex: _selectedIndex,
        onTap: (value) {
          setState(() {
            _selectedIndex = value;
          });
        },
        selectedItemColor: Colors.blue,
        unselectedItemColor: Theme.brightnessOf(context).isDark
            ? Colors.white
            : Colors.black,
        items: [
          BottomNavigationBarItem(
            label: 'Description',
            icon: Icon(Icons.description),
          ),
          BottomNavigationBarItem(label: 'Chapter', icon: Icon(Icons.list)),
          BottomNavigationBarItem(
            label: 'PDF',
            icon: Icon(Icons.picture_as_pdf),
          ),
          BottomNavigationBarItem(
            label: 'BookMark',
            icon: Icon(Icons.bookmark_added),
          ),
        ],
      ),
    );
  }
}
