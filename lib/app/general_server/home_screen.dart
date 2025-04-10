import 'package:than_pkg/than_pkg.dart';

import 'index.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  ReleaseAppModel releaseApp;
  HomeScreen({super.key, required this.releaseApp});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: FutureBuilder(
            future: ThanPkg.platform.getPackageInfo(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final info = snapshot.data;
                if (info != null) {
                  return Text('Current V: ${info.version}');
                }
              }
              return Text('Version');
            },
          ),
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              Tab(
                text: 'Latest',
              ),
              Tab(
                text: 'CHANGELOG',
              ),
              Tab(
                text: 'README',
              ),
              Tab(
                text: 'LICENSE',
              ),
              Tab(
                text: 'Release App',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            HomePage(releaseApp: releaseApp),
            RawPage(rawName: 'CHANGELOG.md', releaseApp: releaseApp),
            RawPage(rawName: 'README.md', releaseApp: releaseApp),
            RawPage(rawName: 'LICENSE', releaseApp: releaseApp),
            ReleasePage(),
          ],
        ),
      ),
    );
  }
}
