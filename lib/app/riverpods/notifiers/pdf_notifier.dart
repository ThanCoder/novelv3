import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novel_v3/app/riverpods/states/pdf_state.dart';
import 'package:than_pkg/than_pkg.dart';
import 'package:than_pkg/types/src_dist_type.dart';

import '../../models/pdf_model.dart';
import '../../services/pdf_services.dart';
import '../../utils/path_util.dart';

class PdfNotifier extends StateNotifier<PdfState> {
  PdfNotifier() : super(PdfState.init());

  Future<void> initList({
    bool isReset = false,
    required String novelPath,
  }) async {
    if (!isReset && state.list.isNotEmpty) {
      return;
    }

    state = state.copyWith(list: [], isLoading: true);

    final res = await PdfServices.instance.getList(novelPath: novelPath);

    //gen pdf cover
    final genList = res
        .map((pdf) => SrcDistType(
              src: pdf.path,
              dist: pdf.path.replaceAll('.pdf', '.png'),
            ))
        .toList();
    await ThanPkg.platform.genPdfThumbnail(pathList: genList);

    state = state.copyWith(list: res, isLoading: false);
  }

  void delete(PdfModel pdf) {
    final res = state.list.where((pf) => pf.title != pdf.title).toList();
    //del
    pdf.delete();
    state = state.copyWith(list: res);
  }

  void restore(PdfModel pdf) {
    //del
    final outPath = '${PathUtil.getOutPath()}/${pdf.path.getName()}';
    final pdfFile = File(pdf.path);
    if (!pdfFile.existsSync()) return;
    if (File(outPath).existsSync()) {
      throw Exception('ရှိနေပြီးသား ဖြစ်နေပါတယ်။ Path: `$outPath');
    }
    //move
    pdfFile.renameSync(outPath);

    final res = state.list.where((pf) => pf.title != pdf.title).toList();
    state = state.copyWith(list: res);
  }
}
