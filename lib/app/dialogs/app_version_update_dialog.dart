import 'package:flutter/material.dart';
import 'package:novel_v3/app/components/app_components.dart';
import 'package:novel_v3/app/dialogs/download_dialog.dart';
import 'package:novel_v3/app/services/index.dart';
import 'package:than_pkg/than_pkg.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../widgets/index.dart';

class AppVersionUpdateDialog extends StatefulWidget {
  const AppVersionUpdateDialog({super.key});

  @override
  State<AppVersionUpdateDialog> createState() => _AppVersionUpdateDialogState();
}

class _AppVersionUpdateDialogState extends State<AppVersionUpdateDialog> {
  @override
  void initState() {
    super.initState();
    init();
  }

  Map<String, dynamic>? version = {};
  bool isLoading = true;

  void init() async {
    final res = await ReleaseServices.instance.getLatestVersion();
    setState(() {
      version = res!;
      isLoading = false;
    });
  }

  Widget _getDownloadWidget(String url) {
    if (url.isEmpty) {
      return Container();
    }
    return Wrap(
      spacing: 10,
      children: [
        const Text('Download Url'),
        TextButton(
          onPressed: () async {
            Navigator.pop(context);
            if (await canLaunchUrlString(url)) {
              launchUrlString(url);
            } else {
              ThanPkg.platform.openUrl(url: url);
            }
          },
          child: Text(
            url,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _getContent() {
    if (isLoading) {
      return Center(child: TLoader());
    }
    if (version == null) {
      return const Center(child: Text('Version is null'));
    }
    return SingleChildScrollView(
      child: Column(
        spacing: 10,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Platform: ${version!['platform'] ?? ''}'),
          Text('Size: ${version!['size'] ?? '0MB'}'),
          Text('Update Version: ${version!['version'] ?? ''}'),
          _getDownloadWidget(version!['download_url'] ?? ''),
          Text('Description ${version!['description'] ?? ''}'),
        ],
      ),
    );
  }

  void _downloadApp() {
    showDialog(
      context: context,
      builder: (context) => DownloadDialog(
        title: 'Download App',
        url: version!['direct_download_url'],
        saveFullPath: '/home/thancoder/Videos/file.tar.gz',
        message: 'App Downloading',
        onError: (msg) {
          showMessage(context, msg);
          debugPrint(msg);
        },
        onSuccess: (savedPath) {
          showMessage(context, 'Downloaded');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Update Version'),
      content: _getContent(),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: version == null ||
                  version!['direct_download_url'] == null ||
                  version!['direct_download_url'].toString().isEmpty
              ? null
              : () {
                  Navigator.pop(context);
                  _downloadApp();
                },
          child: const Text('Upgrade'),
        ),
      ],
    );
  }
}
