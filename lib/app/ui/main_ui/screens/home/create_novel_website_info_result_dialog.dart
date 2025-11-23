import 'dart:io';

import 'package:flutter/material.dart';
import 'package:novel_v3/app/core/models/novel.dart';
import 'package:novel_v3/more_libs/fetcher_v1.0.0/types/website_info.dart';
import 'package:novel_v3/more_libs/setting_v2.0.0/others/path_util.dart';
import 'package:t_client/t_client.dart';
import 'package:t_widgets/t_widgets.dart';

class CreateNovelWebsiteInfoResultDialog extends StatefulWidget {
  final WebsiteInfoResult result;
  final void Function()? onSuccess;
  const CreateNovelWebsiteInfoResultDialog({
    super.key,
    required this.result,
    this.onSuccess,
  });

  @override
  State<CreateNovelWebsiteInfoResultDialog> createState() =>
      _CreateNovelWebsiteInfoResultDialogState();
}

class _CreateNovelWebsiteInfoResultDialogState
    extends State<CreateNovelWebsiteInfoResultDialog> {
  late WebsiteInfoResult result;
  @override
  void initState() {
    result = widget.result;
    super.initState();
    init();
  }

  void init() async {
    try {
      final dir = Directory(PathUtil.getSourcePath(name: result.title));
      if (!dir.existsSync()) {
        await dir.create();
      }
      final novel = await Novel.fromPath(dir.path);
      var newMeta = novel.meta;

      if (result.url.isNotEmpty) {
        final urls = novel.meta.pageUrls;
        urls.insert(0, result.url);
        newMeta = newMeta.copyWith(pageUrls: urls.toSet().toList());
      }

      // download cover
      if (result.coverUrl != null) {
        final client = TClient();
        await client.download(
          result.coverUrl!,
          savePath: '${dir.path}/cover.png',
        );
      }

      newMeta = newMeta.copyWith(
        desc: result.description,
        author: result.author,
        translator: result.translator,
        tags: result.tags,
      );
      await novel.setMeta(newMeta);

      if (!mounted) return;
      Navigator.pop(context);

      WidgetsBinding.instance.addPostFrameCallback(
        (_) => widget.onSuccess?.call(),
      );
    } catch (e) {
      debugPrint(e.toString());
      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      scrollable: true,
      content: Column(
        spacing: 5,
        children: [
          TLoader.random(),
          Text('Please Wait....', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
