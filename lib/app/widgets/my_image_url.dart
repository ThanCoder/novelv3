import 'package:flutter/material.dart';
import 'package:novel_v3/app/constants.dart';

class MyImageUrl extends StatelessWidget {
  String url;
  String defaultAssetsPath;
  BoxFit fit;
  double? width;
  double? height;
  MyImageUrl({
    super.key,
    required this.url,
    this.defaultAssetsPath = defaultIconAssetsPath,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
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
}
