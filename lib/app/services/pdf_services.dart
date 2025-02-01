import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:novel_v3/app/models/pdf_file_model.dart';
import 'package:novel_v3/app/services/app_path_services.dart';
import 'package:novel_v3/app/utils/path_util.dart';
import 'package:novel_v3/app/utils/poppler_util.dart';
import 'package:than_pkg/than_pkg_method_channel.dart';

Future<List<PdfFileModel>> pdfScannerIsolate() async {
  final completer = Completer<List<PdfFileModel>>();

  final receivePort = ReceivePort();
  final rootPath = Platform.isLinux
      ? '${getAppExternalRootPath()}/Downloads'
      : getAppExternalRootPath();
  await Isolate.spawn(_pdfScannerIsolate, [receivePort.sendPort, rootPath]);

  receivePort.listen((data) {
    if (data is Map) {
      String type = data['type'];
      if (type == 'err') {
        // onError();
        completer.completeError(data['msg']);
        receivePort.close();
      }
      if (type == 'succ') {
        completer.complete(data['list']);
        // onSuccess();
        receivePort.close();
      }
    }
  });
  return completer.future;
}

void _pdfScannerIsolate(List<Object> args) {
  final sendPort = args[0] as SendPort;
  final rootPath = args[1] as String;

  pdfScanner(
    rootPath: rootPath,
    onSuccess: (pdfList) {
      sendPort.send({'type': 'succ', 'list': pdfList});
    },
    onError: (msg) {
      sendPort.send({'type': 'err', 'msg': msg});
    },
  );
}

void pdfScanner({
  required String rootPath,
  required void Function(List<PdfFileModel> pdfList) onSuccess,
  required void Function(String msg) onError,
}) async {
  try {
    final dir = Directory(rootPath);
    if (!dir.existsSync()) return onSuccess([]);
    List<PdfFileModel> pdfList = [];

    Future<void> scanPdfFile(Directory folder) async {
      for (final file in folder.listSync()) {
        String name = getBasename(file.path);
        if (name.startsWith('.') ||
            name.startsWith('Android') ||
            name.startsWith('android-studio') ||
            name.startsWith('AndroidStudioProjects') ||
            name.startsWith('AndroidIDEProjects') ||
            name.startsWith('DCMI')) {
          continue;
        }
        if (file.statSync().type == FileSystemEntityType.directory) {
          scanPdfFile(Directory(file.path));
        }
        if (!file.path.endsWith('.pdf')) continue;
        //add
        pdfList.add(PdfFileModel.fromPath(file.path));
        // await Future.delayed(const Duration(milliseconds: 900));
      }
    }

    await scanPdfFile(dir);
    //sort
    pdfList.sort((a, b) {
      // return a.date.compareTo(b.date);
      return a.date.compareTo(b.date) == 1 ? -1 : 1;
    });
    onSuccess(pdfList);
  } catch (e) {
    onError(e.toString());
    debugPrint('pdfScanner: ${e.toString()}');
  }
}

Future<List<PdfFileModel>> genPdfCover(
    {required List<PdfFileModel> pdfList}) async {
  final completer = Completer<List<PdfFileModel>>();
  try {
    //change pdf cover path
    pdfList = pdfList.map((pdf) {
      pdf.coverPath = '${getCachePath()}/${pdf.title}.png';
      return pdf;
    }).toList();

    if (Platform.isLinux) {
      for (final pdf in pdfList) {
        await genPdfCoverLinuxPlatform(
            pdfPath: pdf.path, outImagePath: pdf.coverPath);
      }
    }
    if (Platform.isAndroid) {
      final pathList = pdfList.map((pdf) => pdf.path).toList();

      await ThanPkgMethodChannel.instance.genPdfCover(
        outDirPath: getCachePath(),
        pdfPathList: pathList,
      );
    }
    completer.complete(pdfList);
  } catch (e) {
    debugPrint('genPdfCover: ${e.toString()}');
    completer.completeError(e);
  }
  return completer.future;
}
