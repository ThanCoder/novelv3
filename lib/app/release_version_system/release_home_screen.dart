import 'package:flutter/material.dart';

import 'pages/change_log_page.dart';
import 'pages/readme_page.dart';
import 'pages/release_license_page.dart';
import 'pages/release_list_page.dart';
import 'release_home_header.dart';

class ReleaseHomeScreen extends StatelessWidget {
  const ReleaseHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Release'),
        ),
        body: const Column(
          children: [
            ReleaseHomeHeader(),
            Expanded(
              child: TabBarView(
                children: [
                  ReleaseListPage(),
                  ChangeLogPage(),
                  ReadmePage(),
                  ReleaseLicensePage(),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: TabBar(
          tabs: [
            Tab(
              text: 'Release List',
            ),
            Tab(
              text: 'Change Log',
            ),
            Tab(
              text: 'Readme',
            ),
            Tab(
              text: 'License',
            ),
          ],
        ),
      ),
    );
  }
}
