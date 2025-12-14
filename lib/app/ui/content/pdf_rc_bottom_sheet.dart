import 'dart:io';

import 'package:flutter/material.dart';
import 'package:novel_v3/app/core/managers/copy_progress_manager.dart';
import 'package:novel_v3/app/core/providers/pdf_provider.dart';
import 'package:provider/provider.dart';
import 'package:novel_v3/app/core/providers/novel_provider.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

class PdfRcBottomSheet extends StatefulWidget {
  final List<String> files;
  final VoidCallback? onClosed;
  const PdfRcBottomSheet({super.key, required this.files, this.onClosed});

  @override
  State<PdfRcBottomSheet> createState() => _PdfRcBottomSheetState();
}

class _PdfRcBottomSheetState extends State<PdfRcBottomSheet> {
  PdfProvider get getRProvier => context.read<PdfProvider>();
  String get getNovelPath => context.read<NovelProvider>().currentNovel!.path;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(Icons.copy_all),
          title: Text('Copy All'),
          onTap: _copyAll,
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.move_to_inbox_rounded),
          title: Text('Move All'),
          onTap: _moveAll,
        ),
      ],
    );
  }

  void _copyAll() async {
    // for (var path in widget.files) {
    //   final file = File(path);
    //   final novelPdfFile = File(pathJoin(getNovelPath, file.getName()));
    //   // သွင်းမယ့် pdf မရှိရင် ကျော်မယ်
    //   // novel ထဲက pdf name တူနေရင် ကျော်မယ်
    //   if (!file.existsSync() || novelPdfFile.existsSync()) continue;

    //   await file.copy(novelPdfFile.path);
    // }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => TProgressDialog(
        manager: CopyProgressManager(
          onTest: (item) {
            final sourceFile = File(item.sourcePath);
            final novelPdfFile = File(item.destPath);
            if (!sourceFile.existsSync() || novelPdfFile.existsSync()) false;

            return true;
          },
          list: widget.files
              .map(
                (path) => CopyItem(
                  sourcePath: path,
                  destPath: pathJoin(getNovelPath, path.getName()),
                ),
              )
              .toList(),
          onCanceled: () {
            showTSnackBar(context, 'ပယ်ဖျက်လိုက်ပါပြီ');
            widget.onClosed?.call();
          },
          onSuccess: () {
            showTSnackBar(context, 'ကူးယူပြီးပါပြီ');
            // refersh provider
            getRProvier.init(getNovelPath);
            widget.onClosed?.call();
          },
        ),
      ),
    );
  }

  Future<void> _moveAll() async {
    for (var path in widget.files) {
      final file = File(path);
      final novelPdfFile = File(pathJoin(getNovelPath, file.getName()));
      // သွင်းမယ့် pdf မရှိရင် ကျော်မယ်
      // novel ထဲက pdf name တူနေရင် ကျော်မယ်
      if (!file.existsSync() || novelPdfFile.existsSync()) continue;

      await file.rename(novelPdfFile.path);
    }
    // refersh provider
    getRProvier.init(getNovelPath);

    widget.onClosed?.call();
  }
}
