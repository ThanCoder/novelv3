import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novel_v3/app/models/index.dart';
import 'package:novel_v3/app/screens/novel_see_all_screen.dart';
import 'package:novel_v3/app/utils/path_util.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

class NovelDataConfigExporterDialog extends ConsumerStatefulWidget {
  List<NovelModel> list;
  NovelDataConfigExporterDialog({
    super.key,
    required this.list,
  });

  @override
  ConsumerState<NovelDataConfigExporterDialog> createState() =>
      _NovelDataConfigExporterDialogState();
}

class _NovelDataConfigExporterDialogState
    extends ConsumerState<NovelDataConfigExporterDialog> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((e) => init());
  }

  bool isLoading = true;
  String successText = 'Config Files အားလုံးထုတ်ပြီးပါပြီ';

  Future<void> init() async {
    try {
      if (!await ThanPkg.android.permission.isStoragePermissionGranted()) {
        await ThanPkg.android.permission.requestStoragePermission();
        setState(() {
          isLoading = false;
        });
        throw Exception('Storage Permission Denied');
      }
      for (var nv in novelSeeAllScreenNotifier.value) {
        await nv.exportConfig(Directory(PathUtil.getOutPath()));
      }
      // await Future.delayed(Duration(seconds: 2));
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      successText = e.toString();
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Data Config ထုတ်ပေးနေပါတယ်...'),
      scrollable: true,
      content: isLoading
          ? Center(child: TLoaderRandom())
          : Text(
              successText,
              maxLines: null,
            ),
      actions: [
        TextButton(
            onPressed: isLoading
                ? null
                : () {
                    Navigator.pop(context);
                  },
            child: const Text('Close'))
      ],
    );
  }
}
