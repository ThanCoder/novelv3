import 'dart:io';

import 'package:flutter/material.dart';
import 'package:novel_v3/app/core/models/novel.dart';
import 'package:novel_v3/more_libs/fetcher_v1.0.0/types/website_info.dart';
import 'package:novel_v3/more_libs/setting_v2.0.0/others/path_util.dart';
import 'package:t_client/t_client.dart';
import 'package:t_widgets/t_widgets.dart';

class AddWebsiteResultDialog extends StatefulWidget {
  final Novel novel;
  final WebsiteInfoResult result;
  final void Function(String novelPath)? onLoaded;
  final void Function(String message)? onError;
  const AddWebsiteResultDialog({
    super.key,
    required this.novel,
    required this.result,
    this.onLoaded,
    this.onError,
  });

  @override
  State<AddWebsiteResultDialog> createState() => _AddWebsiteResultDialogState();
}

class _AddWebsiteResultDialogState extends State<AddWebsiteResultDialog> {
  late Novel novel;
  late WebsiteInfoResult result;
  @override
  void initState() {
    novel = widget.novel;
    result = widget.result;

    super.initState();
    init();
  }

  void init() async {
    try {
      // await Future.delayed(Duration(seconds: 2));
      final newDir = Directory(PathUtil.getSourcePath(name: result.title));

      var sourcePath = widget.novel.path;
      if (result.title != null && !newDir.existsSync()) {
        await PathUtil.renameDir(oldDir: Directory(novel.path), newDir: newDir);
        sourcePath = newDir.path;
      }
      if (result.coverUrl != null) {
        final client = TClient();
        await client.download(
          result.coverUrl!,
          savePath: '$sourcePath/cover.png',
        );
      }
      if (result.description != null) {
        novel.setContent(result.description!);
      }
      if (result.author != null) {
        novel.setAuthor(result.author!);
      }
      if (result.translator != null) {
        novel.setTranslator(result.translator!);
      }
      if (result.tags != null) {
        novel.setTagContent(result.tags!);
      }

      // success
      widget.onLoaded?.call(sourcePath);
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      widget.onError?.call(e.toString());
      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      title: Text('Installing'),
      content: TScrollableColumn(
        children: [
          Center(
            child: SizedBox(width: 100, height: 100, child: TLoader.random()),
          ),
          Center(child: Text('Please Wait...')),
        ],
      ),
    );
  }
}
