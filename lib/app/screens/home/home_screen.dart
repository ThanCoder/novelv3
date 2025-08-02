import 'package:flutter/material.dart';
import 'package:novel_v3/my_libs/novel_v3_uploader/screens/online_novel_home_screen.dart';

import 'pages/app_more_page.dart';
import 'pages/home_page.dart';

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
                HomePage(),
                OnlineNovelHomeScreen(),
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
