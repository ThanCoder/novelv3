import 'package:flutter/material.dart';
import 'package:novel_v3/app/notifiers/app_notifier.dart';
import 'package:novel_v3/app/pages/home/home_page.dart';
import 'package:novel_v3/app/pages/home/home_more_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    isShowHomeBottomBarNotifier.value = true;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isShowHomeBottomBarNotifier,
      builder: (context, isShowTabBar, child) {
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            body: const TabBarView(
              children: [
                HomePage(),
                HomeMorePage(),
              ],
            ),
            bottomNavigationBar: !isShowTabBar
                ? null
                : const TabBar(
                    tabs: [
                      Tab(
                        text: 'Home',
                        icon: Icon(Icons.home),
                      ),
                      Tab(
                        text: 'More',
                        icon: Icon(Icons.grid_view_rounded),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
