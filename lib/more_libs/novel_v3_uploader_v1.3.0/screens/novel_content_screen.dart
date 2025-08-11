import 'package:flutter/material.dart';
import '../novel_v3_uploader.dart';
import 'pages/home_page.dart';
import 'pages/uploader_file_page.dart';

class NovelContentScreen extends StatelessWidget {
  UploaderNovel novel;
  NovelContentScreen({super.key, required this.novel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Content Page'),
        actions: [...NovelV3Uploader.instance.appBarActions],
      ),
      body: DefaultTabController(
        length: 2,
        child: Scaffold(
          body: TabBarView(
            children: [
              HomePage(novel: novel),
              UploaderFilePage(novel: novel),
            ],
          ),
          bottomNavigationBar: TabBar(
            tabs: const [
              Tab(icon: Icon(Icons.home)),
              Tab(icon: Icon(Icons.cloud_download_outlined)),
            ],
          ),
        ),
      ),
    );
  }
}
