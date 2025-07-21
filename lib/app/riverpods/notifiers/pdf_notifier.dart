import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novel_v3/app/riverpods/states/pdf_state.dart';
import 'package:than_pkg/than_pkg.dart';

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
    await Future.delayed(const Duration(milliseconds: 300));

    final res = await PdfServices.instance.getList(novelPath: novelPath);

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
