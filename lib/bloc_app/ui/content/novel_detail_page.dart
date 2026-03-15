import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:novel_v3/bloc_app/ui/content/novel_detail.dart';
import 'package:novel_v3/core/models/novel.dart';
import 'package:t_widgets/t_widgets.dart';

class NovelDetailPage extends StatelessWidget {
  const NovelDetailPage({super.key, required this.novel});
  final Novel novel;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: 330,
            width: size.width,
            child: Stack(
              children: [
                Positioned.fill(
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                    child: TImage(source: novel.getCoverPath),
                  ),
                ),
                Row(
                  children: [
                    Spacer(),
                    Container(
                      width: size.width * 0.6,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(36),
                          // bottomRight: Radius.circular(36),
                        ),
                      ),
                      child: TImage(
                        source: novel.getCoverPath,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          NovelDetail(novel: novel),
        ],
      ),
    );
  }
}
