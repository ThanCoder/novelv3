import 'package:flutter/widgets.dart';
import 'package:novel_v3/app/models/pdf_model.dart';
import 'package:novel_v3/app/services/pdf_services.dart';
import 'package:than_pkg/than_pkg.dart';
import 'package:than_pkg/types/src_dist_type.dart';

class PdfProvider with ChangeNotifier {
  final List<PdfModel> _list = [];
  bool isLoading = false;

  List<PdfModel> get getList => _list;

  Future<void> initList(
      {bool isReset = false, required String novelPath}) async {
    if (!isReset && _list.isNotEmpty) {
      return;
    }
    isLoading = true;
    notifyListeners();

    _list.clear();
    final res = await PdfServices.instance.getList(novelPath: novelPath);
    _list.addAll(res);
    //gen pdf cover
    final genList = res
        .map((pdf) => SrcDistType(
            src: pdf.path, dist: pdf.path.replaceAll('.pdf', '.png')))
        .toList();
    await ThanPkg.platform.genPdfThumbnail(pathList: genList);

    isLoading = false;
    notifyListeners();
  }
}
