// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:novel_v3/app/others/novl_db/novl_db.dart';
import 'package:novel_v3/app/others/novl_db/novl_info.dart';
import 'package:t_widgets/progress_manager/progress_manager_interface.dart';
import 'package:t_widgets/progress_manager/progress_message.dart';

import 'package:novel_v3/app/core/models/novel.dart';

class NovlExportProgressManager extends ProgressManagerInterface {
  final Novel novel;
  final String outPath;
  final NovlInfo info;
  final VoidCallback? onDone;
  NovlExportProgressManager({
    required this.novel,
    required this.info,
    required this.outPath,
    this.onDone,
  });

  @override
  void cancel() {}

  @override
  Future<void> start(StreamController<ProgressMessage> streamController) async {
    try {
      streamController.add(ProgressMessage.preparing());
      await Future.delayed(Duration(milliseconds: 1200));
      final outFile = File('$outPath.${NovlDB.extName}');
      if (outFile.existsSync()) {
        await outFile.delete();
      }

      await NovlDB.exportHBDB(
        Directory(novel.path),
        info: info,
        dbPath: outFile.path,
        onProgress: (progress, message) {
          streamController.add(
            ProgressMessage.progress(
              index: 0,
              indexLength: 0,
              progress: progress,
              message: message,
            ),
          );
        },
      );

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
