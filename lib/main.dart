import 'package:flutter/material.dart';
import 'package:novel_v3/core/utils/app_utils.dart';
import 'package:novel_v3/modules/module_manager.dart';
import 'package:novel_v3/modules/modules_test/another_page_module.dart';
import 'package:novel_v3/modules/modules_test/internet_checker.dart';
import 'package:novel_v3/modules/modules_test/pdf_scanner_module.dart';
import 'package:novel_v3/my_app.dart';

void main() async {
  await AppUtils.instance.init();

  ModuleManager.instance.register(InternetCheckerModule());
  ModuleManager.instance.register(AnotherPageModule());
  ModuleManager.instance.register(PdfScannerModule());

  runApp(const MyApp());
}
