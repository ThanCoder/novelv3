import 'dart:io';
import 'package:flutter/material.dart';
import 'package:novel_v3/app/extensions/index.dart';
import 'package:t_release/models/t_release_version_model.dart';
import 'package:t_release/services/t_release_version_services.dart';

import '../../components/index.dart';
import '../../dialogs/download_dialog.dart';
import '../../services/dio_services.dart';
import '../../utils/path_util.dart';
import '../../widgets/core/index.dart';
import '../release_list_item.dart';

class ReleaseListPage extends StatefulWidget {
  const ReleaseListPage({super.key});

  @override
  State<ReleaseListPage> createState() => _ReleaseListPageState();
}

class _ReleaseListPageState extends State<ReleaseListPage> {
  void _download(TReleaseVersionModel release) {
    final title = release.url.getName();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => DownloadDialog(
        title: 'Download App',
        url: DioServices.instance.getForwardProxyUrl(release.url),
        saveFullPath: '${PathUtil.instance.getOutPath()}/$title',
        message: '$title downloading...',
        onError: (msg) {
          showDialogMessage(context, msg);
        },
        onSuccess: () {
          showDialogMessage(context,
              'download လုပ်ပြီးပါပြီ။\npath: ${PathUtil.instance.getOutPath()}/${release.url.getName()}');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: FutureBuilder(
        future: TReleaseVersionServices.instance.getVersionList(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return TLoader();
          }
          if (snapshot.hasData) {
            var list = snapshot.data ?? [];
            list = list
                .where((re) => re.platform == Platform.operatingSystem)
                .toList();
            return ListView.separated(
              itemCount: list.length,
              itemBuilder: (context, index) => ReleaseListItem(
                release: list[index],
                onClicked: _download,
              ),
              separatorBuilder: (context, index) => const Divider(),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
