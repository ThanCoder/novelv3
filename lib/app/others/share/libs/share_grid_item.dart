import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:novel_v3/app/core/models/novel.dart';
import 'package:t_widgets/t_widgets.dart';

class ShareGridItem extends StatelessWidget {
  final String hostUrl;
  final Novel novel;
  final void Function(Novel novel)? onClicked;
  const ShareGridItem({
    super.key,
    required this.hostUrl,
    required this.novel,
    this.onClicked,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onClicked?.call(novel),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              // child: TImageUrl(url: '$hostUrl/cover/id/${novel.id}'),
              child: CachedNetworkImage(
                fit: BoxFit.cover,
                imageUrl: '$hostUrl/cover/id/${novel.id}',
                placeholder: (context, url) => TLoader.random(),
                errorWidget: (context, url, error) =>
                    Icon(Icons.broken_image_outlined),
              ),
            ),
            Positioned(
              left: 0,
              top: 0,
              child: _getStatus(
                novel.meta.isCompleted ? 'Completed' : 'OnGoing',
                bgColor: novel.meta.isCompleted
                    ? const Color.fromARGB(255, 4, 121, 109)
                    : const Color.fromARGB(255, 7, 97, 92),
              ),
            ),
            !novel.meta.isAdult
                ? SizedBox.shrink()
                : Positioned(
                    right: 0,
                    top: 0,
                    child: _getStatus(
                      'Adult',
                      bgColor: const Color.fromARGB(255, 165, 30, 20),
                    ),
                  ),
            Positioned(
              left: 0,
              bottom: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(2),
                    bottomRight: Radius.circular(2),
                  ),
                ),
                child: Text(
                  novel.meta.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    overflow: TextOverflow.ellipsis,
                  ),
                  maxLines: 2,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getStatus(String text, {Color bgColor = Colors.blue}) {
    return Container(
      padding: EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(color: Colors.white, fontSize: 11),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
