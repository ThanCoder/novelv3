import 'package:flutter/material.dart';
import 'package:than_pkg/than_pkg.dart';

import '../../novel_v3_uploader.dart';
import 'desktop_ui/novel_content_screen.dart';
import 'mobile_ui/novel_content_mobile_screen.dart';

class NovelContentUiSwitcher extends StatelessWidget {
  final Novel novel;
  const NovelContentUiSwitcher({super.key, required this.novel});

  @override
  Widget build(BuildContext context) {
    //is mobile
    if (TPlatform.isMobile) {
      return NovelContentMobileScreen(novel: novel);
    }
    return NovelContentScreen(novel: novel);
  }
}
