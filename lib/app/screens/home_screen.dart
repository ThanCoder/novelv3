import 'package:flutter/material.dart';
import 'package:novel_v3/app/pages/home_page.dart';
import 'package:novel_v3/app/pages/novel_lib_page.dart';
import 'package:novel_v3/app/pages/novel_online_page.dart';
import 'package:novel_v3/app/pages/home_more_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        body: TabBarView(
          children: [
            const HomePage(),
            const NovelOnlinePage(),
            NovelLibPage(),
            const HomeMorePage(),
          ],
        ),
        bottomNavigationBar: const TabBar(
          tabs: [
            Tab(
              text: 'Home',
              icon: Icon(Icons.home),
            ),
            Tab(
              text: 'Online',
              icon: Icon(Icons.cloud_download_outlined),
            ),
            Tab(
              text: 'Library',
              icon: Icon(Icons.local_library_outlined),
            ),
            Tab(
              text: 'More',
              icon: Icon(Icons.grid_view_rounded),
            ),
          ],
        ),
      ),
    );
  }
}
