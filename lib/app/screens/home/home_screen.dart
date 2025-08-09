import 'package:flutter/material.dart';
import 'package:novel_v3/my_libs/novel_dir_db/screens/novel_dir_home_screen.dart';
import 'package:novel_v3/my_libs/novel_v3_uploader_v1.3.0/screens/novel_v3_uploader_home_screen.dart';
import 'pages/app_more_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;
  List<Widget> pages = [
    NovelDirHomeScreen(),
    NovelV3UploaderHomeScreen(),
    AppMorePage(),
  ];
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
                icon: Icon(Icons.cloud_download_outlined), label: 'Online Lib'),
            BottomNavigationBarItem(
                icon: Icon(Icons.grid_view_rounded), label: 'More'),
          ]),
      // floatingActionButton: FloatingActionButton(onPressed: () {
      //   THistoryServices.instance.add(THistoryRecord.create());
      // }),
    );
  }
}
