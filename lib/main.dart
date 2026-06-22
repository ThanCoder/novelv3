import 'package:flutter/material.dart';
import 'package:novel_v3/core/utils/app_utils.dart';
import 'package:novel_v3/my_app.dart';

void main() async {
  await AppUtils.instance.init();

  runApp(const MyApp());
}
