import 'package:flutter/material.dart';
import 'package:novel_v3/my_libs/novel_dir_db/screens/novel_dir_home_screen.dart';
import 'package:novel_v3/my_libs/novel_v3_uploader_v1.3.0/screens/novel_v3_uploader_home_screen.dart';
import 'pages/app_more_page.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: const TabBarView(
              children: [
                // HomePage(),
                NovelDirHomeScreen(),
                NovelV3UploaderHomeScreen(),
                AppMorePage(),
              ],
            ),
          ),
        ),
        bottomNavigationBar: const TabBar(
          tabs: [
            Tab(
              icon: Icon(Icons.home),
            ),
            Tab(
              icon: Icon(Icons.cloud_download_outlined),
            ),
            Tab(
              icon: Icon(Icons.grid_view_rounded),
            ),
          ],
        ),
        // floatingActionButton: FloatingActionButton(onPressed: () {
        //   THistoryServices.instance.add(THistoryRecord.create());
        // }),
      ),
    );
  }
}
