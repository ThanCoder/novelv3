// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:io';

import 'package:t_widgets/t_widgets.dart';

import 'package:novel_v3/more_libs/setting/core/path_util.dart';

class CopyItem {
  final String sourcePath;
  final String destPath;
  CopyItem({required this.sourcePath, required this.destPath});
}

class CopyProgressManager extends TProgressManagerSimple {
  bool isCancel = false;
  bool onCancelDeletedFile;
  final List<CopyItem> list;
  final bool Function(CopyItem item)? onTest;
  final void Function()? onCanceled;
  final void Function()? onSuccess;
  CopyProgressManager({
    required this.list,
    this.onCancelDeletedFile = true,
    this.onTest,
    this.onCanceled,
    this.onSuccess,
  });

  @override
  void cancel() {
    isCancel = true;
  }

  @override
  Future<void> startWorking(StreamController<TProgress> controller) async {
    int index = 0;
    final resList = list.where((e) {
      if (onTest?.call(e) ?? true) return true;
      return false;
    }).toList();
    for (var item in resList) {
      index++;

      await PathUtil.copyWithProgress(
        File(item.sourcePath),
        destFile: File(item.destPath),
        onCancelDeletedFile: onCancelDeletedFile,
        isCancel: () => isCancel,
        onProgerss: (total, loaded) {
          controller.add(
            TProgress.progress(
              index: index,
              indexLength: list.length,
              loaded: loaded,
              total: total,
              message: 'Copying: \n${item.sourcePath} \n-> \n${item.destPath}',
            ),
          );
        },
      );
    }
    await controller.close();
    if (isCancel) {
      onCanceled?.call();
    } else {
      onSuccess?.call();
    }
  }
}
