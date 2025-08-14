// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';
import 'dart:isolate';

import 'package:archive/archive_io.dart';
import 'package:flutter/material.dart';
import 'package:novel_v3/app/types/n3_data.dart';
import 'package:novel_v3/app/types/novel.dart';
import 'package:novel_v3/more_libs/setting_v2.0.0/others/index.dart';
import 'package:t_widgets/extensions/index.dart';

class N3DataTask {
  String zipPath;
  String novelPath;
  N3DataTask({required this.zipPath, required this.novelPath});

  factory N3DataTask.fromPath({
    required String novelPath,
    required String zipPath,
  }) {
    return N3DataTask(zipPath: zipPath, novelPath: novelPath);
  }
}

class N3DataWorker {
  static Future<void> export(Novel novel) async {
    final task = N3DataTask(
      zipPath: '${PathUtil.getOutPath()}/${novel.title}.${N3Data.getExt}',
      novelPath: novel.path,
    );
    await Isolate.run(() async {
      await exportDataTask(task);
    });
    // await Future.delayed(Duration(seconds: 3));
  }
}

Future<void> exportDataTask(N3DataTask task) async {
  try {
    // Output zip file stream
    final zipStream = OutputFileStream(task.zipPath);

    // Zip encoder
    final encoder = ZipFileEncoder();
    encoder.create(task.zipPath);
    await encoder.addDirectory(
      Directory(task.novelPath),
      onProgress: (progress) {
        debugPrint(
          '${task.novelPath.getName()} progress: ${(progress * 100).toStringAsFixed(2)}%',
        );
      },
    );

    // for (final path in task.pathList) {
    //   await encoder.addDirectory(Directory('path'));
    //   await encoder.addFile(File(path));
    // }

    await encoder.close(); // zip file close
    await zipStream.close();
  } catch (e) {
    debugPrint(e.toString());
  }
}
