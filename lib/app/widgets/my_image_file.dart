import 'dart:io';

import 'package:flutter/material.dart';
import 'package:novel_v3/app/constants.dart';

class MyImageFile extends StatelessWidget {
  String path;
  String defaultAssetsPath;
  BoxFit fit;
  double? width;
  double? height;
  MyImageFile({
    super.key,
    required this.path,
    this.defaultAssetsPath = defaultIconAssetsPath,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final file = File(path);
    if (file.existsSync()) {
      // final uniqueKey = file.statSync().modified.millisecondsSinceEpoch;
      return Image.file(
        file,
        // key: ValueKey<int>(uniqueKey),
        fit: fit,
        width: width,
        height: height,
      );
    } else {
      return Image.asset(
        defaultAssetsPath,
        fit: fit,
      );
    }
  }
}
