import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';

import '../../core/models/helper_file.dart';

class HelperGridItem extends StatelessWidget {
  HelperFile helper;
  void Function(HelperFile helper) onClicked;
  HelperGridItem({super.key, required this.helper, required this.onClicked});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onClicked(helper),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Stack(
          children: [
            Positioned.fill(
              child: TImageUrl(
                url: helper.imagesUrl.isEmpty ? '' : helper.imagesUrl.first,
                fit: BoxFit.fill,
                width: double.infinity,
              ),
            ),
            // cover

            // title
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
                  helper.title,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: TextStyle(
                    color: Colors.white,
                    // fontSize: fontSize,
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
