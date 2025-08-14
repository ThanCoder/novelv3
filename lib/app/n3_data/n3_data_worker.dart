// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';
import 'dart:isolate';

import 'package:archive/archive_io.dart';
import 'package:flutter/material.dart';
import 'package:novel_v3/app/n3_data/n3_data.dart';
import 'package:novel_v3/more_libs/setting_v2.0.0/others/index.dart';
import 'package:t_widgets/extensions/index.dart';

import '../novel_dir_app.dart';

class N3DataTask {
  String zipPath;
  String novelPath;
  SendPort? sendPort;
  String? password;
  bool isInstallConfigFiles;
  bool isInstallFileOverride;
  N3DataTask({
    required this.zipPath,
    required this.novelPath,
    this.sendPort,
    this.password,
    this.isInstallConfigFiles = false,
    this.isInstallFileOverride = false,
  });

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
      password: NovelDirApp.instance.onGetN3DataPassword(),
    );
    await Isolate.run(() async {
      await exportN3DataTask(task);
    });
    // await Future.delayed(Duration(seconds: 3));
  }

  static Future<void> exportProgress(
    Novel novel, {
    bool isSetPassword = false,
    Function()? onSuccess,
    Function(double progress)? onProgress,
    Function(String message)? onError,
  }) async {
    try {
      final receivePort = ReceivePort();

      final task = N3DataTask(
        zipPath: '${PathUtil.getOutPath()}/${novel.title}.${N3Data.getExt}',
        novelPath: novel.path,
        sendPort: receivePort.sendPort,
        password: isSetPassword
            ? NovelDirApp.instance.onGetN3DataPassword()
            : null,
      );

      receivePort.listen((message) {
        if (message is Map) {
          if (message['done'] is bool) {
            receivePort.close();
            onSuccess?.call();
          }
          if (message['message'] is String) {
            receivePort.close();
            onError?.call(message['message']);
          }
          if (message['progress'] is double) {
            onProgress?.call(message['progress']);
          }
        }
      });

      await Isolate.spawn(exportN3DataTask, task);
    } catch (e) {
      onError?.call(e.toString());
    }
  }

  // install
  static Future<void> install({
    required N3Data n3Data,
    bool isInstallConfigFiles = false,
    bool isInstallFileOverride = false,
  }) async {
    final dataTitle = await n3Data.getDataTitle();

    final task = N3DataTask(
      zipPath: n3Data.path,
      novelPath: '${PathUtil.getSourcePath()}/$dataTitle',
      password: NovelDirApp.instance.onGetN3DataPassword(),
      isInstallConfigFiles: isInstallConfigFiles,
      isInstallFileOverride: isInstallFileOverride,
    );
    await Isolate.run(() async {
      await installN3DataTask(task);
    });
    // await Future.delayed(Duration(seconds: 3));
  }
}

// install task
Future<void> installN3DataTask(N3DataTask task) async {
  try {
    final novelDir = Directory(task.novelPath);
    if (!novelDir.existsSync()) {
      await novelDir.create();
    }
    final inputStream = InputFileStream(task.zipPath);
    final archive = ZipDecoder().decodeStream(
      inputStream,
      password: task.password,
    );

    for (var file in archive.files) {
      if (!file.isFile) continue;
      // config file ကို ကျော်မယ်ဆိုရင်
      if (!task.isInstallConfigFiles) {
        if (file.name.endsWith('config.json') ||
            file.name.endsWith('readed') ||
            file.name.endsWith('fav2_list2.json')) {
          continue;
        }
      }
      // print(file.name);
      final outFile = File('${novelDir.path}/${file.name.getName()}');
      // override == false နေပြီးတော့ file လည်းရှိနေရင် ကျော်မယ်
      if (!task.isInstallFileOverride && outFile.existsSync()) {
        continue;
      }
      final output = OutputFileStream(outFile.path);
      file.writeContent(output);

      await output.close();
    }
    // extractArchiveToDisk(archive, outputPath)

    await inputStream.close(); // zip file close

    if (task.sendPort != null) {
      task.sendPort!.send({'done': true});
    }
  } catch (e) {
    if (task.sendPort != null) {
      task.sendPort!.send({'error': true, 'message': e.toString()});
    }
    debugPrint(e.toString());
  }
}

// export task
Future<void> exportN3DataTask(N3DataTask task) async {
  try {
    // Output zip file stream
    final zipStream = OutputFileStream(task.zipPath);

    // Zip encoder
    final encoder = ZipFileEncoder(password: task.password);
    encoder.create(task.zipPath);
    await encoder.addDirectory(
      Directory(task.novelPath),
      onProgress: task.sendPort != null
          ? (progress) {
              task.sendPort!.send({'progress': progress});
              // debugPrint(
              //   '${task.novelPath.getName()} progress: ${(progress * 100).toStringAsFixed(2)}%',
              // );
            }
          : null,
    );

    await encoder.close(); // zip file close
    await zipStream.close();
    if (task.sendPort != null) {
      task.sendPort!.send({'done': true});
    }
  } catch (e) {
    debugPrint(e.toString());
    if (task.sendPort != null) {
      task.sendPort!.send({'error': true, 'message': e.toString()});
    }
  }
}
