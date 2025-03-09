import 'dart:io';

import 'package:flutter/material.dart';

import '../../constants.dart';

class MyImageFile extends StatelessWidget {
  String path;
  String defaultAssetsPath;
  BoxFit fit;
  double? width;
  double? height;
  double borderRadius;

  MyImageFile({
    super.key,
    required this.path,
    this.defaultAssetsPath = defaultIconAssetsPath,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius = 5,
  });

  Widget _getImageWidget() {
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

  @override
  Widget build(BuildContext context) {
    if (borderRadius > 0) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: _getImageWidget(),
      );
    }
    return _getImageWidget();
  }
}
