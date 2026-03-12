import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:novel_v3/core/models/novel.dart';
import 'package:t_widgets/t_widgets.dart';

class HeaderImageComponent extends StatelessWidget {
  final Novel novel;
  const HeaderImageComponent({super.key, required this.novel});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        TImage(source: novel.getCoverPath),
        ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(color: Colors.black.withValues(alpha: 0.1)),
          ),
        ),
        Center(
          child: SizedBox(
            width: 200,
            height: 220,
            child: TImage(
              // fit: BoxFit.contain,
              borderRadius: 10,
              source: novel.getCoverPath,
            ),
          ),
        ),
      ],
    );
  }
}
