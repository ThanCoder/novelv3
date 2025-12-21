// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hb_db/hb_db.dart';
import 'package:t_widgets/progress_manager/progress_manager_interface.dart';
import 'package:t_widgets/progress_manager/progress_message.dart';
import 'package:than_pkg/utils/index.dart';

class NovlInstallProgressManager extends ProgressManagerInterface {
  final List<DBFEntry> installList;
  final String installNovelPath;
  final VoidCallback? onDone;
  NovlInstallProgressManager({
    required this.installList,
    required this.installNovelPath,
    this.onDone,
  });
  @override
  void cancel() {}

  @override
  Future<void> start(StreamController<ProgressMessage> streamController) async {
    try {
      streamController.add(ProgressMessage.preparing());
      await Future.delayed(Duration(milliseconds: 1200));
      final dir = Directory(installNovelPath);
      if (!dir.existsSync()) {
        await dir.create();
      }

      int index = 0;
      for (var file in installList) {
        index++;
        await file.extract(
          pathJoin(installNovelPath, file.name),
          onProgress: (progress, message) {
            streamController.add(
              ProgressMessage.progress(
                index: index,
                indexLength: installList.length,
                progress: progress,
                message: message,
              ),
            );
          },
        );
      }

      streamController.add(ProgressMessage.done());
      await streamController.close();
      onDone?.call();
    } catch (e) {
      streamController.add(ProgressMessage.done(message: e.toString()));
      streamController.addError(e);
      await streamController.close();
      onDone?.call();
    }
  }
}
