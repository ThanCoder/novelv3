import 'dart:io';

import 'package:flutter/material.dart';
import 'package:novel_v3/app/components/novel_data_list_item.dart';
import 'package:novel_v3/app/extensions/index.dart';
import 'package:novel_v3/app/models/index.dart';
import 'package:novel_v3/app/services/novel_data_services.dart';
import 'package:novel_v3/app/widgets/core/index.dart';
import 'package:than_pkg/than_pkg.dart';

class NovelDataScanner extends StatefulWidget {
  const NovelDataScanner({super.key});

  @override
  State<NovelDataScanner> createState() => _NovelDataScannerState();
}

class _NovelDataScannerState extends State<NovelDataScanner> {
  @override
  void initState() {
    super.initState();
    init();
  }

  bool isLoading = false;
  List<NovelDataModel> list = [];

  Future<void> init() async {
    if (Platform.isAndroid) {
      if (!await ThanPkg.android.permission.isStoragePermissionGranted()) {
        await ThanPkg.android.permission.requestStoragePermission();
        return;
      }
    }

    setState(() {
      isLoading = true;
    });
    list = await NovelDataServices.instance.dataScanner();
    //gen cover
    await NovelDataServices.instance.genCover(list: list);

    if (!mounted) return;
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      appBar: AppBar(
        title: const Text('Data Scanner'),
        actions: [
          PlatformExtension.isDesktop()
              ? IconButton(
                  onPressed: init,
                  icon: const Icon(Icons.refresh),
                )
              : const SizedBox.shrink(),
        ],
      ),
      body: isLoading
          ? TLoader()
          : RefreshIndicator(
              onRefresh: init,
              child: ListView.builder(
                itemBuilder: (context, index) => NovelDataListItem(
                  novelData: list[index],
                  onClicked: (novelData) {},
                ),
                itemCount: list.length,
              ),
            ),
    );
  }
}
