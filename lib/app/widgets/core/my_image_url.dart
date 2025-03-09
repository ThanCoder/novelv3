import 'package:flutter/material.dart';

import '../../constants.dart';

class MyImageUrl extends StatelessWidget {
  String url;
  String defaultAssetsPath;
  BoxFit fit;
  double? width;
  double? height;
  double borderRadius;

  MyImageUrl({
    super.key,
    required this.url,
    this.defaultAssetsPath = defaultIconAssetsPath,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius = 5,
  });

  Widget _getImageWidget() {
    if (url.isEmpty) {
      return Image.asset(
        defaultAssetsPath,
        fit: fit,
      );
    } else {
      return Image.network(
        url,
        fit: fit,
        width: width,
        height: height,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          if (isDebugPrint) {
            debugPrint('MyImageUrl:error $url');
          }
          return Image.asset(
            defaultAssetsPath,
            fit: fit,
          );
        },
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
