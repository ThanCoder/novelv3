import 'package:flutter/src/widgets/framework.dart';
import 'package:novel_v3/modules/module_manager.dart';

/// P -> [path list]
///
/// R -> [pdf file list]
class PdfScannerModule extends ModuleApp<List<String>, List<String>> {
  @override
  Future<List<String>?> go(BuildContext context, List<String> params) async {
    print('your params: $params');

    await Future.delayed(Duration(seconds: 2));

    return ['one.pdf', 'two,pdf', 'three.pdf'];
  }

  @override
  // TODO: implement moduleId
  String get id => throw UnimplementedError();
}
