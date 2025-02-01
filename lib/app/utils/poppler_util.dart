//linux
//sudo apt-get install poppler-utils

import 'dart:io';
import 'dart:isolate';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';

const _libName = 'pdftoppm';

Future<void> genPdfList({
  required String pdfPath,
  required String outImagePath,
  String type = 'png',
}) async {
  try {
    await Process.run(_libName, ['-$type', pdfPath, '$outImagePath/0']);
  } catch (err) {
    debugPrint('genPdfList: ${err.toString()}');
  }
}

Future<void> genPdfCoverLinuxPlatform({
  required String pdfPath,
  required String outImagePath,
  String type = 'png',
}) async {
  try {
    final oldCoverFile = File(outImagePath);
    if (!await oldCoverFile.exists()) {
      //create new
      await Process.run(_libName, [
        '-f',
        '0',
        '-l',
        '1',
        '-$type',
        pdfPath,
        '${oldCoverFile.parent.path}/'
      ]);
    }

    //rename
    File file = File('${oldCoverFile.parent.path}/-001.png');
    if (await file.exists()) {
      await file.rename(outImagePath);
    }
    File file2 = File('${oldCoverFile.parent.path}/-0001.png');
    if (await file2.exists()) {
      await file2.rename(outImagePath);
    }
    File file3 = File('${oldCoverFile.parent.path}/-00001.png');
    if (await file3.exists()) {
      await file3.rename(outImagePath);
    }
    File file4 = File('${oldCoverFile.parent.path}/-000001.png');
    if (await file4.exists()) {
      await file4.rename(outImagePath);
    }
    File file5 = File('${oldCoverFile.parent.path}/-0000001.png');
    if (await file5.exists()) {
      await file5.rename(outImagePath);
    }
    File file6 = File('${oldCoverFile.parent.path}/-00000001.png');
    if (await file6.exists()) {
      await file6.rename(outImagePath);
    }
  } catch (err) {
    debugPrint('genPdfCover: ${err.toString()}');
  }
}

Future<String> getPdfHash(String pdfPath) async {
  // Read the PDF file as bytes
  File file = File(pdfPath);
  List<int> fileBytes = await file.readAsBytes();

  // Create an MD5 hash of the file's bytes
  var digest = md5.convert(fileBytes);

  // Return the hash as a string
  return digest.toString();
}

//isolate
Future<void> genPdfListIsolate({
  required String pdfPath,
  required String outImagePath,
  String type = 'png',
  bool isOverride = false,
  required void Function() onSuccess,
  required void Function(String msg) onError,
}) async {
  final receivePort = ReceivePort();
  await Isolate.spawn(_genPdfListIsolate,
      [receivePort.sendPort, pdfPath, outImagePath, type, isOverride]);

  receivePort.listen((data) {
    if (data is Map) {
      final type = data['type'] ?? '';
      if (type == 'err') {
        onError(data['msg']);
      }
      if (type == 'succ') {
        onSuccess();
      }
    }
  });
}

//isolate private
void _genPdfListIsolate(List<Object> args) async {
  try {
    final sendPort = args[0] as SendPort;
    final pdfPath = args[1] as String;
    final outImagePath = args[2] as String;
    final type = args[3] as String;
    final isOverride = args[4] as bool;

    ProcessResult res;
    int resultCode = 0;
    String msg = '';
    final dir = Directory(outImagePath);

    if (isOverride) {
      res = await Process.run(_libName, ['-$type', pdfPath, '$outImagePath/0']);
      resultCode = res.exitCode;
      msg = res.stderr.toString();
    } else {
      //not override
      if (dir.listSync().isEmpty) {
        res =
            await Process.run(_libName, ['-$type', pdfPath, '$outImagePath/0']);
        resultCode = res.exitCode;
        msg = res.stderr.toString();
      }
    }

    // final res = await Process.run('ls', []);

    if (resultCode == 0) {
      // if (dir.existsSync()) {
      //   for (final file in dir.listSync()) {
      //     if (file.statSync().type != FileSystemEntityType.file) continue;
      //     final newP = file.path.replaceAll('0-', '');
      //     file.renameSync(newP);
      //   }
      // }

      sendPort.send({'type': 'succ'});
    }
    if (resultCode == 1) {
      sendPort.send({'type': 'err', 'msg': msg});
    }
  } catch (err) {
    debugPrint('genPdfList: ${err.toString()}');
  }
}
