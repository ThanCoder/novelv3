import 'package:flutter/material.dart';
import 'package:novel_v3/app/models/novel_model.dart';
import 'package:novel_v3/app/widgets/core/index.dart';

class NovelGridItem extends StatelessWidget {
  NovelModel novel;
  void Function(NovelModel novel) onClicked;
  NovelGridItem({
    super.key,
    required this.novel,
    required this.onClicked,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onClicked(novel),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: MyImageFile(
                    path: novel.coverPath,
                    fit: BoxFit.fill,
                    width: double.infinity,
                  ),
                ),
              ],
            ),
            Positioned(
              left: 0,
              bottom: 0,
              right: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color.fromARGB(178, 0, 0, 0),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(4),
                    bottomRight: Radius.circular(4),
                  ),
                ),
                child: Text(
                  novel.title,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
