import 'dart:io';

import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

import '../index.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  ReleaseAppModel releaseApp;
  HomePage({super.key, required this.releaseApp});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    init();
  }

  ReleaseAppModel? app;
  List<ReleaseAppModel> appList = [];
  List<ReleaseAppModel> appCurrentVersionList = [];
  bool isLoading = false;

  Future<void> init() async {
    setState(() {
      isLoading = true;
    });

    appList = await GeneralServices.instance.getCurrentReleaseAppList();

    for (var releaseApp in appList) {
      if (releaseApp.releaseId == releaseApp.releaseId &&
          releaseApp.platform == Platform.operatingSystem) {
        app = releaseApp;
        break;
      }
    }
    //current platfom
    appCurrentVersionList = appList
        .where((app) => app.platform == Platform.operatingSystem)
        .toList();

    //other platfom
    appList = appList
        .where((app) => app.platform != Platform.operatingSystem)
        .toList();
    setState(() {
      isLoading = false;
    });
  }

  Widget _getHeader() {
    if (app != null) {
      return ReleaseAppListItem(
        app: app!,
        onDownloadClicked: (app) {
          ThanPkg.platform.launch(app.url);
        },
      );
    }

    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return TLoader();
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: RefreshIndicator(
        onRefresh: init,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
                child: Center(
              child: appList.isEmpty
                  ? const Text('Version မရှိပါ')
                  : const Text('Latest Version'),
            )),
            SliverToBoxAdapter(
              child: _getHeader(),
            ),

            // current platform
            SliverToBoxAdapter(
              child: appList.isEmpty
                  ? const SizedBox.shrink()
                  : const Center(
                      child: Text('Current Platform'),
                    ),
            ),
            SliverList.separated(
              itemCount: appCurrentVersionList.length,
              itemBuilder: (context, index) => ReleaseAppListItem(
                app: appCurrentVersionList[index],
              ),
              separatorBuilder: (context, index) => const Divider(),
            ),
            // other platform
            SliverToBoxAdapter(
              child: appList.isEmpty
                  ? const SizedBox.shrink()
                  : const Center(
                      child: Text('Other Platform'),
                    ),
            ),
            SliverList.separated(
              itemCount: appList.length,
              itemBuilder: (context, index) => ReleaseAppListItem(
                app: appList[index],
              ),
              separatorBuilder: (context, index) => const Divider(),
            ),
          ],
        ),
      ),
    );
  }
}

class ReleaseAppListItem extends StatelessWidget {
  ReleaseAppModel app;
  void Function(ReleaseAppModel app)? onDownloadClicked;
  ReleaseAppListItem({
    super.key,
    required this.app,
    this.onDownloadClicked,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          spacing: 5,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 100, height: 100, child: TImageUrl(url: '')),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 3,
                children: [
                  Text('Version: ${app.version}'),
                  Text('Platform: ${app.platform}'),
                  // Text(app.url),
                  app.description.isEmpty
                      ? const SizedBox.shrink()
                      : Text('Desc: ${app.description}'),
                  Text('Date: ${DateTime.parse(app.date).toParseTime()}'),
                  Text('Ago: ${DateTime.parse(app.date).toAutoParseTime()}'),
                  app.url.isEmpty
                      ? const SizedBox.shrink()
                      : IconButton(
                          onPressed: () {
                            if (onDownloadClicked != null) {
                              onDownloadClicked!(app);
                            }
                          },
                          icon: const Icon(Icons.download),
                        )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
