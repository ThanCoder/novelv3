import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:novel_v3/core/extensions/build_context_extensions.dart';
import 'package:novel_v3/more_libs/setting/core/path_util.dart';
import 'package:t_widgets/progress_manager/progress_dialog.dart';
import 'package:t_widgets/progress_manager/progress_manager_interface.dart';
import 'package:t_widgets/progress_manager/progress_message.dart';

void showSingleFileCopyDialog(
  BuildContext context, {
  required String sourcePath,
  required String destPath,
  void Function()? onClosed,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => ProgressDialog(
      progressManager: FileProgressManager(
        fileCopySources: [
          FileCopySource(
            sourceFile: File(sourcePath),
            destFile: File(destPath),
          ),
        ],
        onClosed: () {
          context.closeNavigator();
          onClosed?.call();
        },
      ),
    ),
  );
}

void showFileCopyDialog(
  BuildContext context, {
  required List<FileCopySource> fileCopySources,
  void Function()? onClosed,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => ProgressDialog(
      progressManager: FileProgressManager(
        fileCopySources: fileCopySources,
        onClosed: () {
          context.closeNavigator();
          onClosed?.call();
        },
      ),
    ),
  );
}

class FileCopySource {
  final File sourceFile;
  final File destFile;

  const FileCopySource({required this.sourceFile, required this.destFile});
}

class FileProgressManager extends ProgressManagerInterface {
  final bool onCancelDeletedFile;
  final List<FileCopySource> fileCopySources;
  bool isCancel;
  final void Function()? onClosed;
  FileProgressManager({
    required this.fileCopySources,
    this.onCancelDeletedFile = true,
    this.isCancel = false,
    this.onClosed,
  });
  @override
  void cancel() {
    isCancel = true;
  }

  @override
  Future<void> start(StreamController<ProgressMessage> streamController) async {
    try {
      streamController.add(
        ProgressMessage.preparing(message: 'ပြင်ဆင်နေပါတယ်.....'),
      );
      int index = 0;
      for (var source in fileCopySources) {
        index++;

        await PathUtil.copyWithProgress(
          source.sourceFile,
          destFile: source.destFile,
          isCancel: () => isCancel,
          onCancelDeletedFile: onCancelDeletedFile,
          onProgerss: (total, loaded) {
            streamController.add(
              ProgressMessage.progress(
                index: index,
                indexLength: fileCopySources.length,
                progress: total / loaded,
                message:
                    'Copying: `${source.sourceFile.path}` > `${source.destFile.path}`...',
              ),
            );
          },
        );
      }

      streamController.close();
      onClosed?.call();
    } catch (e) {
      streamController.addError(e);
    }
  }
}
