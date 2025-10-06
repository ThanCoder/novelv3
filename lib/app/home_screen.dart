import 'package:flutter/material.dart';
import 'package:novel_v3/app/ui/main_ui/screens/home/more_page.dart';
import 'package:novel_v3/more_libs/novel_v3_uploader_v1.3.0/novel_v3_uploader.dart';

import 'package:t_widgets/widgets/index.dart';

import 'ui/main_ui/screens/home/home_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int index = 0;
  List<Widget> pages = [HomePage(), NovelV3Uploader.getHomeScreen, MorePage()];
  @override
  Widget build(BuildContext context) {
    return TScaffold(
      body: pages[index],
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.blue,
        currentIndex: index,
        onTap: (value) {
          setState(() {
            index = value;
          });
        },
        items: const [
          BottomNavigationBarItem(label: 'Home', icon: Icon(Icons.home)),
          BottomNavigationBarItem(
            label: 'Online Lib',
            icon: Icon(Icons.cloud_download),
          ),
          BottomNavigationBarItem(
            label: 'More',
            icon: Icon(Icons.grid_view_outlined),
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {

      //   },
      // ),
    );
  }
}
