import 'package:flutter/material.dart';

import 'pages/app_more_page.dart';
import 'pages/home_page.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: const TabBarView(
              children: [
                HomePage(),
                AppMorePage(),
              ],
            ),
          ),
        ),
        bottomNavigationBar: const TabBar(
          tabs: [
            Tab(
              // text: 'Home',
              icon: Icon(Icons.home),
            ),
            Tab(
              // text: 'More',
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
