import 'package:flutter/material.dart';

import '../pages/index.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DefaultTabController(
      length: 2,
      child: Scaffold(
        body: TabBarView(
          children: [
            HomePage(),
            AppMorePage(),
          ],
        ),
        bottomNavigationBar: TabBar(
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
  }
}
