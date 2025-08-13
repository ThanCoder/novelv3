import 'package:flutter/material.dart';
import '../novel_v3_uploader.dart';
import 'pages/home_page.dart';
import 'pages/uploader_file_page.dart';

class NovelContentScreen extends StatefulWidget {
  UploaderNovel novel;
  NovelContentScreen({super.key, required this.novel});

  @override
  State<NovelContentScreen> createState() => _NovelContentScreenState();
}

class _NovelContentScreenState extends State<NovelContentScreen> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Content Page'),
        actions: [...NovelV3Uploader.instance.appBarActions],
      ),
      body: _getPages()[index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        selectedItemColor: Colors.blue,
        onTap: (value) {
          setState(() {
            index = value;
          });
        },
        items: [
          BottomNavigationBarItem(label: 'Home', icon: Icon(Icons.home)),
          BottomNavigationBarItem(
            label: 'Download Data',
            icon: Icon(Icons.cloud_download_rounded),
          ),
        ],
      ),
    );
  }

  List<Widget> _getPages() {
    return [
      HomePage(novel: widget.novel),
      UploaderFilePage(novel: widget.novel),
    ];
  }
}
